SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CorrectPrimarykey]
( @TableName   SYSNAME
, @ColumnNames NVARCHAR(394)
) AS

/**
 *
 * NAME:
 * dbo.CorrectPrimarykey
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for fixing Primary keys.  This procedure will terminate if there is already
 * a clustered primary key on the table regardless if the current columns match the desires columns.
 * The routine will drop any existing nonclustered PKs and will drop any clustered index, regardless
 * of unique status.  It will also drop an obvious future duplicate index featuring the same column(s)
 * as the proposed clustered index.
 *
 * Finally, it will create the desired clustered primary key.
 *
 * RETURNS:
 *  Nothing
 * RESULT:
 *
 * PARAMETERS:
 * 001 @TableName        SYSNAME       --Table name to be modified
 * 002 @ColumnNames      NVARCHAR(394) --CSV list of up to 3 columns sized with room for 3 SYSNAMES(NCHAR(128)) + 3 [ + 3 ] + 2 , + 2 " "
 *
 * REVISION HISTORY:
 * PTS 100365 SPN 02/25/16 - Initial Version Created
 *
 **/

SET NOCOUNT ON;

BEGIN

   DECLARE @IndexName      SYSNAME;
   DECLARE @SQL            NVARCHAR(4000);
   DECLARE @CurSeq         INT;
   DECLARE @ColumnName     SYSNAME;

   DECLARE @ColumnNameTable TABLE
   ( ColName             SYSNAME NOT NULL
   , index_column_id     INT     NOT NULL
   , column_id           INT     NULL
   );

   --Return if a PKey already exists
   IF EXISTS(SELECT TOP 1 1
               FROM sys.tables a
               JOIN sys.indexes b ON a.object_id = b.object_id
              WHERE a.name = @TableName
                AND b.type_desc = 'CLUSTERED'
                AND b.is_primary_key = 1
            )
   BEGIN
     RETURN;
   END;

   --We're going to remove any brackets so that we can compare to sys.columns later.
   SET @ColumnNames = REPLACE(@ColumnNames, '[', '');
   SET @ColumnNames = REPLACE(@ColumnNames, ']', '');

   INSERT INTO @ColumnNameTable(index_column_id,ColName)
   SELECT SeqNo,LTRIM(RTRIM(Items))
     FROM dbo.fn_SplitString( @ColumnNames, ',');


   --If someone sent the same column more than once.
   IF EXISTS(SELECT ColName
               FROM @ColumnNameTable
              GROUP BY ColName
              HAVING COUNT(*) > 1)
   BEGIN
     RAISERROR ('A requested key column is repeated more than once', 16, 1);
     RETURN;
   END;


   UPDATE c
   SET column_id = b.column_id
   FROM
     sys.tables a
       INNER JOIN
     sys.columns b on a.object_id = b.object_id
       INNER JOIN
     @ColumnNameTable c ON b.name = c.ColName
   WHERE
     a.name = @TableName;

   --This indicates we didn't get a match.
   IF EXISTS(SELECT TOP 1 1
               FROM @ColumnNameTable
              WHERE column_id IS NULL)
   BEGIN
     RAISERROR ('A requested key column does not exist', 16, 1);
     RETURN;
   END;

   --We're going to put the brackets back in case there are spaces I need to deal with.
   SET @ColumnNames = NULL
   SELECT @ColumnNames = COALESCE(@ColumnNames + ',','') + '[' + ColName + ']'
   FROM @ColumnNameTable;

   --Drop existing PK
   SELECT @IndexName = b.name
     FROM sys.tables a
     JOIN sys.indexes b ON a.object_id = b.object_id
    WHERE a.name = @TableName
      AND b.is_primary_key = 1;

   IF @@ROWCOUNT = 1
   BEGIN
      SET @SQL = N'ALTER TABLE [dbo].' + QUOTENAME(@TableName) + N' DROP CONSTRAINT ' + QUOTENAME(@IndexName);
      EXEC sp_executeSQL @SQL;
   END;

   --Drop existing clustered index
   SELECT @IndexName = b.name
     FROM sys.tables a
     JOIN sys.indexes b ON a.object_id = b.object_id
    WHERE a.name = @TableName
      AND b.type_desc = 'CLUSTERED';
   IF @@ROWCOUNT = 1
   BEGIN
      SET @SQL = N'DROP INDEX ' + QUOTENAME(@IndexName) + N' ON [dbo].' + QUOTENAME(@TableName);
      EXEC sp_executeSQL @SQL;
   END;

  --If a non clustered index exists on with the same first column as our future cluster, we can safely drop that.
  --There could theoretically be more than one, but we only attempt to remove 1 here.

  --We'll look at the first X number of column on an index to match the new PK
  DECLARE @ColumnCount TINYINT;
  SELECT @ColumnCount = COUNT(*) FROM @ColumnNameTable;

  DECLARE @ExistingSuspectIndexes TABLE (IndexName SYSNAME, index_column_id SMALLINT, ColName SYSNAME NULL);

  INSERT @ExistingSuspectIndexes
  SELECT b.name
        ,c.index_column_id
        ,d.ColName
    FROM sys.tables a
    JOIN sys.indexes b ON a.object_id = b.object_id
    JOIN sys.index_columns c ON b.object_id = c.object_id
                            AND b.index_id = c.index_id
                            AND c.index_column_id <= @ColumnCount
    LEFT JOIN @ColumnNameTable d ON c.column_id = d.column_id
   WHERE a.name = @TableName;

  --This will remove indexes where the lead columns are only made up of new PK columns.
  --It does not take into account the order.
  DELETE @ExistingSuspectIndexes
  WHERE IndexName IN (SELECT x.IndexName FROM @ExistingSuspectIndexes x WHERE x.ColName IS NULL);

  DECLARE DuplicateIndexes CURSOR LOCAL FAST_FORWARD FOR
  SELECT DISTINCT IndexName FROM @ExistingSuspectIndexes;

  OPEN DuplicateIndexes;

  FETCH NEXT FROM DuplicateIndexes INTO @IndexName;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    --Drop existing nonclustered index
    SET @SQL = N'DROP INDEX ' + QUOTENAME(@IndexName) + N' ON [dbo].' + QUOTENAME(@TableName);
    EXEC sp_executeSQL @SQL;

    FETCH NEXT FROM DuplicateIndexes INTO @IndexName;
  END;


  CLOSE DuplicateIndexes;
  DEALLOCATE DuplicateIndexes;

  --Rename an existing nonclustered index that is using our desired PK name.
  --We do this now rather than earlier because it is likely that any offending
  --index will have been dropped during the previous step and I would rather
  --drop the index than rename it and later drop it.
  SELECT @IndexName = b.name
    FROM sys.tables a
    JOIN sys.indexes b ON a.object_id = b.object_id
   WHERE a.name = @TableName
     AND b.name = N'[PK_' + @TableName + N']';

  IF @@ROWCOUNT = 1
  BEGIN
    SET @SQL = N'EXEC sp_rename N''[dbo].' + QUOTENAME(@TableName) + N'.' + QUOTENAME(@IndexName) + N''', N''' + QUOTENAME(@IndexName + N'NOTPK') + ''', N''INDEX'' ';
    EXEC sp_executeSQL @SQL;
  END;

  --Now that we know it has neither a clustered index nor a PK, we can make a clustered PK
  SET @SQL = N'ALTER TABLE [dbo].' + QUOTENAME(@TableName) + N' ADD CONSTRAINT [PK_' + @TableName + N'] PRIMARY KEY CLUSTERED (' + @ColumnNames + N')';
  EXEC sp_executeSQL @SQL;

END
GO
GRANT EXECUTE ON  [dbo].[CorrectPrimarykey] TO [public]
GO
