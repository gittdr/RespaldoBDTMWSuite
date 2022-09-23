SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_extra_Data]  
		 @table_name varchar(50), 
		 @extra_id varchar(50),
		 @table_key varchar(50),
		 @tab_name varchar(50), 
		 @tab_id varchar(50),
		 @col_name varchar(50), 
		 @col_id varchar(50),
		 @col_row varchar(50),
		@FilterValue VARCHAR(50)
AS

SET NOCOUNT ON 

	-- Fixed 1/22/2003 DAG
	CREATE TABLE #ExtraDataSearch (WorkRow int)


	DECLARE @WhereStatement varchar(8000)
	DECLARE @BaseSelect varchar(8000)
	DECLARE @RealRowDesired varchar(50)
	
	SET @WhereStatement = ''
	SET @RealRowDesired = @col_row

	IF isnull(@table_name, '') <> ''
		SET @WhereStatement = @WhereStatement + ' AND extra_info_header.table_name = ''' + REPLACE(@table_name, '''', '''''') + ''''
	IF isnull(@extra_id, '') <> ''
		SET @WhereStatement = @WhereStatement + ' AND extra_info_Data.extra_id = ' + @extra_id 
	IF isnull(@table_key, '') <> ''
		SET @WhereStatement = @WhereStatement + ' AND extra_info_Data.table_key = ''' + REPLACE(@table_key, '''', '''''') + ''''
	IF isnull(@tab_name, '') <> ''
		SET @WhereStatement = @WhereStatement + ' AND extra_info_tab.tab_name = ''' +  REPLACE(@tab_name, '''', '''''') + ''''
	IF isnull(@tab_id, '') <> ''
		SET @WhereStatement = @WhereStatement + ' AND extra_info_tab.tab_id = ' + @tab_id 
	IF isnull(@col_name, '') <> ''
		SET @WhereStatement = @WhereStatement + ' AND extra_info_cols.col_name = ''' +  REPLACE(@col_name, '''', '''''') + ''''
	IF isnull(@col_id, '') <> ''
		SET @WhereStatement = @WhereStatement + ' AND extra_info_cols.col_id = ' + @col_id 
	IF ISNULL(@FilterValue, '') > ''
		SET @WhereStatement = @WhereStatement + ' AND extra_info_data.col_data = ''' +  REPLACE(@FilterValue, '''', '''''') + ''''
	IF isnull(@col_row, '') <> '' and isnull(@col_row, '') <> '-1'
		SET @WhereStatement = @WhereStatement + ' AND extra_info_data.col_row = ' + @col_row
	
	IF @WhereStatement <> '' 
		SET @WhereStatement = ' WHERE' + SUBSTRING(@WhereStatement, 5, 8000)

	IF isnull(@col_row, '') = '-1'
		BEGIN
		SET @BaseSelect = 'INSERT INTO #ExtraDataSearch (WorkRow)
		SELECT MAX(extra_info_Data.col_row) 
		from extra_info_Data 
		inner join extra_info_header on extra_info_Data.extra_id = extra_info_header.extra_id
		inner join extra_info_tab on extra_info_tab.tab_id = extra_info_Data.tab_id AND extra_info_tab.extra_id = extra_info_data.extra_id
		inner join extra_info_cols on extra_info_cols.col_id = extra_info_Data.col_id'
		SET @BaseSelect = @BaseSelect + @WhereStatement
		EXEC ( @BaseSelect )
		SELECT @col_row = ISNULL(MIN(WorkRow), '') 
		FROM #ExtraDataSearch
		IF @col_row <> ''
			BEGIN
			IF @WhereStatement <> ''
				SET @WhereStatement = @WhereStatement + ' AND extra_info_data.col_row = ' + @col_row 
			ELSE
				SET @WhereStatement = 'WHERE extra_info_data.col_row = ' + @col_row 
			END
		END

	SET @BaseSelect = 'Select extra_info_header.table_name, extra_info_Data.extra_id, extra_info_Data.table_key,
	extra_info_tab.tab_name, extra_info_tab.tab_id,
	extra_info_cols.col_name, extra_info_cols.col_id,
	extra_info_data.col_data, extra_info_data.col_row,
	''' + @RealRowDesired + ''' row_desired
	from extra_info_Data 
	inner join extra_info_header on extra_info_Data.extra_id = extra_info_header.extra_id
	inner join extra_info_tab on extra_info_tab.tab_id = extra_info_Data.tab_id AND extra_info_tab.extra_id = extra_info_data.extra_id
	inner join extra_info_cols on extra_info_cols.col_id = extra_info_Data.col_id'
	
	SET @BaseSelect = @BaseSelect + @WhereStatement + ' Order by col_row'
	
	EXEC ( @BaseSelect )

GO
GRANT EXECUTE ON  [dbo].[tmail_extra_Data] TO [public]
GO
