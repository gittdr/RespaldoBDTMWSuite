SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dynamic_outbound_call] (
	@dv_id		VARCHAR(6),
	@proc_name	VARCHAR(255) = 'outbound_view')
AS
BEGIN
	DECLARE	@parameter_name		NVARCHAR(128),
			@ordinal_position	INTEGER,
			@data_type			NVARCHAR(128),
			@sql				NVARCHAR(4000),
			@sql_column_select	NVARCHAR(4000),
			@column_parm_def	NVARCHAR(4000),
			@sql_values_select	NVARCHAR(4000),
			@values_parm_def	NVARCHAR(4000),
			@column_name		VARCHAR(255),
			@column_values		VARCHAR(4000),
			@parm_list			NVARCHAR(4000)

	SELECT	@parm_list = '', @sql = 'EXEC ' + @proc_name + ' '

	SELECT	@sql_column_select = N'SELECT @col_name = column_name FROM outbound_view_parm_mapping WHERE dv_type = ''OB'' and parm_name = @parm_name'
	SELECT	@column_parm_def = N'@parm_name VARCHAR(255), @col_name VARCHAR(255) OUTPUT'
	SELECT	@values_parm_def = N'@view_id VARCHAR(6), @col_values VARCHAR(4000) OUTPUT'

	SELECT	TOP 1 @parameter_name = parameter_name,
			@ordinal_position = ordinal_position,
			@data_type = data_type
	  FROM	INFORMATION_SCHEMA.PARAMETERS
	 WHERE	specific_name = 'outbound_view'
	ORDER BY ordinal_position

	WHILE ISNULL(@parameter_name, 'END OF PARAMETERS') <> 'END OF PARAMETERS'
	BEGIN
		EXECUTE sp_executesql @sql_column_select, @column_parm_def, @parm_name = @parameter_name, @col_name = @column_name OUTPUT

		SELECT	@sql_values_select = CASE
									   WHEN @data_type LIKE '%CHAR%' THEN 'SELECT @col_values = ' + @column_name + ' FROM dispatchview WHERE dv_type = ''OB'' AND dv_id = @view_id'
									   ELSE 'SELECT @col_values = ' + @column_name + ' FROM dispatchview WHERE dv_type = ''OB'' AND dv_id = @view_id'
									 END

		EXECUTE sp_executesql @sql_values_select, @values_parm_def, @view_id = @dv_id, @col_values = @column_values OUTPUT

		SELECT	@column_values = CASE 
									WHEN @data_type LIKE '%CHAR%' THEN RTRIM(ISNULL(@column_values, '')) 
									ELSE CASE 
											WHEN @column_name = 'ord_totalmiles_max' THEN RTRIM(ISNULL(@column_values, 9999))
											ELSE RTRIM(ISNULL(@column_values, 0)) 
										 END
								 END
		
		SELECT	@parm_list = CASE 
								WHEN LEN(@parm_list) = 0 THEN CASE
																--WHEN @column_values IS NULL THEN @parm_list + 'NULL'
																--ELSE CASE
																		WHEN @data_type like '%CHAR%' THEN @parm_list + '''' + @column_values + ''''
																		ELSE @parm_list + @column_values 
																--	 END
															  END
								ELSE CASE
										--WHEN @column_values IS NULL THEN @parm_list + ', NULL'
										--ELSE CASE
												WHEN @data_type like '%CHAR%' THEN @parm_list + ', ''' + @column_values + ''''
												ELSE @parm_list + ', ' + @column_values 
										--	 END
									 END
							 END
		
		SELECT	@parameter_name = NULL

		SELECT	TOP 1 @parameter_name = parameter_name,
				@ordinal_position = ordinal_position,
				@data_type = data_type
		  FROM	INFORMATION_SCHEMA.PARAMETERS
		 WHERE	specific_name = 'outbound_view'
		   AND	ordinal_position > @ordinal_position
		ORDER BY ordinal_position
	END

	SELECT	@sql = @sql + @parm_list

	EXEC sp_executesql @sql
END
GO
GRANT EXECUTE ON  [dbo].[dynamic_outbound_call] TO [public]
GO
