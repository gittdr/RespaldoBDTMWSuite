SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_TmwXmlDataUpdater]
( @TmwXmlImportLog_id   INT
, @mapper_name          VARCHAR(50)
, @result               INT OUTPUT
)
AS

/**
 *
 * NAME:
 * dbo.sp_TmwXmlDataUpdater
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Stored Proc to update TMWSuite tables with XML data.  Source Columns can be expression.  Look into TmwXmlMapperColumn table for functions etc.
 *
 * RETURNS:
 *
 * INT
 *
 * PARAMETERS:
 * @TmwXmlImportLog_id  INT
 * @mapper_name         VARCHAR
 * @result              INT OUTPUT
 *
 * REVISION HISTORY:
 * PTS 56555 SPN Created 02/06/2013
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @SQLString                  NVARCHAR(MAX)
   DECLARE @ParmDefinition             NVARCHAR(500)

   DECLARE @staging_table              NVARCHAR(50)
   DECLARE @target_table               NVARCHAR(50)
   DECLARE @join_clause                NVARCHAR(500)
   DECLARE @where_clause               NVARCHAR(500)
   DECLARE @where_clause_and           NVARCHAR(500)
   DECLARE @mapping_type               CHAR(2)
   DECLARE @source_columnexpr          NVARCHAR(256)
   DECLARE @target_column              NVARCHAR(50)
   DECLARE @insert_columns             NVARCHAR(MAX)
   DECLARE @insert_values              NVARCHAR(MAX)
   DECLARE @update_columns             NVARCHAR(MAX)
   DECLARE @update_status_column       NVARCHAR(50)

   DECLARE @TmwXmlMapperTableInfo_Id   INT
   DECLARE @TmwXmlImportLogError_id    INT
   DECLARE @t_count                    INT
   DECLARE @t_ctr                      INT
   DECLARE @id                         INT
   DECLARE @count                      INT
   DECLARE @insert_flag                INT
   DECLARE @update_flag                INT
   DECLARE @msg                        NVARCHAR(1000)
   DECLARE @update_status              VARCHAR(10)

   SELECT @result = 0

   --Gather Mapping Info
   SELECT @insert_flag = 0
   SELECT @update_flag = 0

   SELECT @TmwXmlMapperTableInfo_Id = Id
        , @staging_table            = staging_table
        , @target_table             = target_table
        , @join_clause              = join_clause
        , @where_clause             = IsNull(where_clause,'')
        , @where_clause_and         = IsNull(where_clause,'')
        , @mapping_type             = IsNull(mapping_type,'XX')
        , @update_status_column     = IsNull(update_status_column,'')
     FROM TmwXmlMapperTableInfo
    WHERE mapper_name = @mapper_name
   IF @TmwXmlMapperTableInfo_Id IS NULL OR @TmwXmlMapperTableInfo_Id = 0
   BEGIN
      SELECT @msg = @mapper_name + ': No Table Mapping Info found'
      EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg
      RETURN
   END

   IF @where_clause <> ''
   BEGIN
      SELECT @where_clause     = '(' + @where_clause + ')'
      SELECT @where_clause_and = '(' + @where_clause_and + ') AND '
   END

   SELECT @insert_columns  = ''
   SELECT @insert_values   = ''
   SELECT @update_columns  = ''
   SELECT @id = 0
   WHILE 1 = 1
   BEGIN
      SELECT @id = MIN(id)
        FROM TmwXmlMapperColumnInfo
       WHERE TmwXmlMapperTableInfo_Id = @TmwXmlMapperTableInfo_Id
         AND id > @id
      IF @id IS NULL
         BREAK

      SELECT @source_columnexpr = source_columnexpr
           , @target_column = target_column
        FROM TmwXmlMapperColumnInfo
       WHERE id = @id

      SELECT @insert_columns  = @insert_columns + @target_column + ', '
      SELECT @insert_values   = @insert_values  + @source_columnexpr + ', '
      SELECT @update_columns  = @update_columns + @target_column + ' = ' + @source_columnexpr + ', '
   END
   IF @update_columns <> '' AND CHARINDEX('U',@mapping_type) > 0
      SELECT @update_flag = 1
   IF @insert_columns <> '' AND CHARINDEX('I',@mapping_type) > 0
      SELECT @insert_flag = 1
   IF @insert_flag = 0 AND @update_flag = 0
   BEGIN
      SELECT @msg = @mapper_name + ': No Table Mapping Info found'
      EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg
      RETURN
   END

   SELECT @insert_columns = SUBSTRING(RTRIM(@insert_columns),1, LEN(@insert_columns) -1)
   SELECT @insert_values  = SUBSTRING(RTRIM(@insert_values),1, LEN(@insert_values) -1)
   SELECT @update_columns = SUBSTRING(RTRIM(@update_columns),1, LEN(@update_columns) -1)


   --Begin Dynamic SQL
   SELECT @SQLString = N'SELECT @t_count = COUNT(1) FROM ' + @staging_table +
                        ' WHERE TmwXmlImportLog_id = @TmwXmlImportLog_id'
   SELECT @ParmDefinition = N'@TmwXmlImportLog_id INT, @t_count INT OUTPUT'
   EXECUTE sp_executesql @SQLString, @ParmDefinition, @TmwXmlImportLog_id = @TmwXmlImportLog_id, @t_count = @t_count OUTPUT
   --End Dynamic SQL

   --Begin processing
   SELECT @msg = @mapper_name + ': Processing row 0 of ' + Convert(Varchar,@t_count)
   EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg
   SELECT @TmwXmlImportLogError_id = Max(id)
     FROM TmwXmlImportLogError
    WHERE TmwXmlImportLog_id = @TmwXmlImportLog_id
      AND ErrorInfo Like (@mapper_name + ': Processing row %')

   --Begin Loop
   SELECT @t_ctr = 0
   SELECT @id = 0
   WHILE @t_ctr < @t_count
   BEGIN
      BEGIN TRY
         SELECT @t_ctr = @t_ctr + 1

         --Begin Dynamic SQL
         SELECT @SQLString = N'SELECT @id = MIN(id) FROM ' + @staging_table +
                              ' WHERE TmwXmlImportLog_id = @TmwXmlImportLog_id' +
                              '   AND id > @curid'
         SELECT @ParmDefinition = N'@TmwXmlImportLog_id INT, @curid INT, @id INT OUTPUT'
         EXECUTE sp_executesql @SQLString, @ParmDefinition, @TmwXmlImportLog_id = @TmwXmlImportLog_id, @curid = @id, @id = @id OUTPUT
         --End Dynamic SQL

         --Status Update
         IF @t_ctr % 100 = 0 OR @t_ctr = 1 OR @t_ctr = @t_count
         BEGIN
            SELECT @msg = @mapper_name + ': Processing row ' + Convert(Varchar,@t_ctr) + ' of ' + Convert(Varchar,@t_count)
            UPDATE TmwXmlImportLogError
               SET ErrorInfo = @msg
             WHERE id = @TmwXmlImportLogError_id
         END

         --Begin Dynamic SQL
         SELECT @SQLString = N'SELECT @count = Count(1) FROM ' + @staging_table + ' s' +
                              '  JOIN ' + @target_table + ' t ON ' + @join_clause +
                              ' WHERE s.id = @id'
         SELECT @ParmDefinition = N'@id INT, @count INT OUTPUT'
         EXECUTE sp_executesql @SQLString, @ParmDefinition, @id = @id, @count = @count OUTPUT
         --End Dynamic SQL

         SELECT @update_status = 'IGNORE'
         IF @count > 0
            BEGIN
               --Update
               IF @update_flag = 1
               BEGIN
                  --Begin Dynamic SQL
                  SELECT @SQLString = N'UPDATE ' + @target_table +
                                       '   SET ' + @update_columns +
                                       '  FROM ' + @staging_table + ' s' +
                                       '  JOIN ' + @target_table + ' t ON ' + @join_clause +
                                       ' WHERE ' + @where_clause_and + 's.id = @id'
                  SELECT @ParmDefinition = N'@id INT'
                  EXECUTE sp_executesql @SQLString, @ParmDefinition, @id = @id
                  --End Dynamic SQL
                  IF @@ROWCOUNT = 0
                     SELECT @update_status = 'REJECT'
                  ELSE
                     SELECT @update_status = 'UPDATE'
               END
            END
         ELSE
            BEGIN
               --Insert
               IF @insert_flag = 1
               BEGIN
                  --Begin Dynamic SQL
                  SELECT @SQLString = N'INSERT INTO ' + @target_table +
                                       '(' + @insert_columns + ') '  +
                                       'SELECT ' + @insert_values +
                                       '  FROM ' + @staging_table + ' s' +
                                       ' WHERE ' + @where_clause_and + 's.id = @id'
                  SELECT @ParmDefinition = N'@id INT'
                  EXECUTE sp_executesql @SQLString, @ParmDefinition, @id = @id
                  --End Dynamic SQL
                  IF @@ROWCOUNT = 0
                     SELECT @update_status = 'REJECT'
                  ELSE
                     SELECT @update_status = 'INSERT'
               END
            END

         --Update Status
         IF @update_status_column <> ''
         BEGIN
            --Begin Dynamic SQL
            SELECT @SQLString = N'UPDATE ' + @staging_table +
                                 '   SET ' + @update_status_column + ' = @update_status' +
                                 ' WHERE id = @id'
            SELECT @ParmDefinition = N'@id INT, @update_status VARCHAR(10)'
            EXECUTE sp_executesql @SQLString, @ParmDefinition, @id = @id, @update_status = @update_status
            --End Dynamic SQL
         END

      END TRY
      BEGIN CATCH
         SELECT @result = -1

         --Log Error
         SELECT @msg = @mapper_name + ': Error on Row#' + Convert(Varchar,@t_ctr) + ': '  + error_message()
         EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg
         --Update Status
         IF @update_status_column <> ''
         BEGIN
            --Begin Dynamic SQL
            SELECT @update_status = 'ERROR'
            SELECT @SQLString = N'UPDATE ' + @staging_table +
                                 '   SET ' + @update_status_column + ' = @update_status' +
                                 ' WHERE id = @id'
            SELECT @ParmDefinition = N'@id INT, @update_status VARCHAR(10)'
            EXECUTE sp_executesql @SQLString, @ParmDefinition, @id = @id, @update_status = @update_status
            --End Dynamic SQL
         END
      END CATCH

   END
   --End Loop

   --Complete
   SELECT @msg = @mapper_name + ': Process Complete.'
   EXEC sp_TmwXmlImportLogError @TmwXmlImportLog_id, @msg

END
GO
GRANT EXECUTE ON  [dbo].[sp_TmwXmlDataUpdater] TO [public]
GO
