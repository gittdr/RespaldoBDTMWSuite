SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RowSecUpdateRows_sp](@rst_table_name sysname, @COLUMNS_UPDATED_BIT_MASK varbinary(500), @error int out, @message varchar(1024) out)

AS

BEGIN
	--PTS 62831 20121026 - Comment updated to indicate that triggers on tables should no longer be created that in turn reference this stored proc
	--Used by row security setup.  
	--Expects temp table #NewValue to be created by caller.  
	--This table should contain primary key for row(s) to be updated.
	--@COLUMNS_UPDATED_BIT_MASK is intended to be set from within a secured table's trigger.
		--Note though that triggers are now generated, so this should no longer be used.  Just pass null.
	SET NOCOUNT ON
		
	CREATE TABLE #ColumnsToCheck (
		rsc_column_name sysname NULL,
		rsc_unknown_value varchar(12) NULL,
		rsc_sequence smallint NULL,
		ColumnID int NULL
	)
	
	DECLARE @debug bit
	DECLARE @CurrentByte smallint
	DECLARE @ColumnBitmask int
	DECLARE @ColumnPtr int
	DECLARE @ColumnMinPtr int
	DECLARE @ColumnMaxPtr int
	DECLARE @MaxColumns int
	DECLARE	@rst_id_string varchar(10)
	DECLARE @SetBelongsTo smallint
	DECLARE @rsc_column_name varchar(20)
	DECLARE @rsc_unknown_value varchar(12)
	DECLARE @MaxSequence smallint
	DECLARE @addsymbol varchar(10)
	
	DECLARE @sql NVARCHAR(4000)
	
	DECLARE @columnSetList varchar(1024)
	DECLARE @columnSetListComma varchar(3)
	DECLARE @columnConditionList varchar(1024)

	
	SET @Debug = 0
	
	SELECT	@SetBelongsTo = 0
	SELECT	@ColumnMinPtr = 1
	SELECT	@ColumnMaxPtr = 8
	
	INSERT	#ColumnsToCheck
			(	rsc_column_name,
				rsc_unknown_value,
				rsc_sequence,
				ColumnID
			)
	SELECT	rsc.rsc_column_name,
			ISNULL(rsc.rsc_unknown_value, 'UNK'),
			rsc.rsc_sequence,
			--ColumnID = (SELECT COLUMNPROPERTY(OBJECT_ID(TABLE_SCHEMA + '.' + TABLE_NAME), COLUMN_NAME, 'ColumnID') FROM INFORMATION_SCHEMA.COLUMNS c  WHERE (c.COLUMN_NAME = rsc.rsc_column_name AND c.TABLE_NAME = rst.rst_table_name))
			ColumnID =	(	SELECT	colid 
							FROM	syscolumns 
							where name = rsc.rsc_column_name and id = OBJECT_ID(rst.rst_table_name) 
						)
	FROM	RowSecTables rst 
			INNER JOIN RowSecColumns rsc on rst.rst_id = rsc.rst_id
	WHERE	rst.rst_table_name = @rst_table_name
			and rsc.rsc_sequence > 0 

	IF @debug = 1 BEGIN	
		SELECT  'RowSecUpdateRows_sp @rst_table_name: ', @rst_table_name
		PRINT 'RowSecUpdateRows_sp Columns to include...'
		SELECT * FROM #ColumnsToCheck
	END
	
	IF EXISTS	(	SELECT	* 
					FROM	#ColumnsToCheck
					WHERE	ColumnID IS NULL) BEGIN
		SELECT @Message = 'Please contact support.  Column name does not exist for row security definition corresponding to table = ' + convert(varchar(10), @rst_table_name)
		SELECT @error = 16
		RAISERROR(@Message,16,1)
		RETURN
	END
	
	SELECT	@MaxColumns =	MAX(ColumnID) 
	FROM	#ColumnsToCheck
	
	SELECT	@MaxSequence = 4
	
	IF @COLUMNS_UPDATED_BIT_MASK IS NULL BEGIN
		SELECT @SetBelongsTo = 1
		IF @debug = 1 BEGIN
			SELECT 'RowSecUpdateRows_sp @COLUMNS_UPDATED_BIT_MASK was null, skipping column modified test'
		END
	END
	ELSE BEGIN
		IF @debug = 1 BEGIN
			SELECT 'RowSecUpdateRows_sp Looking for watched columns for modifications'
			SELECT '@COLUMNS_UPDATED_BIT_MASK', @COLUMNS_UPDATED_BIT_MASK
		END

		SELECT @CurrentByte = 1

		WHILE	(@ColumnMinPtr <= @MaxColumns) AND (@SetBelongsTo = 0) BEGIN
			SELECT	@ColumnBitmask = SUM(POWER(2, (ColumnID - @ColumnMinPtr)))
			FROM	#ColumnsToCheck
			WHERE 	ColumnID between @ColumnMinPtr and @ColumnMaxPtr
			
			IF SUBSTRING(@COLUMNS_UPDATED_BIT_MASK, @CurrentByte, 1) & @ColumnBitmask > 0 BEGIN
				SELECT @SetBelongsTo = 1
				IF @debug = 1 BEGIN
					SELECT 'RowSecUpdateRows_sp watched column was modified'
				END
			END
			
			SELECT @ColumnMinPtr = @ColumnMaxPtr + 1
			SELECT @ColumnMaxPtr = @ColumnMinPtr + 8 - 1 
			SELECT @CurrentByte = @CurrentByte + 1
		END	
		IF @debug = 1 and @SetBelongsTo = 0 BEGIN
			SELECT 'RowSecUpdateRows_sp no watched columns were modified...not updating'
		END

	END	
	IF @debug = 1 BEGIN
		SELECT 'RowSecUpdateRows_sp @SetBelongsTo', @SetBelongsTo
	END
	IF @SetBelongsTo = 1 BEGIN
		SELECT	@rst_id_string = convert(varchar(10), rst.rst_id)
		FROM	RowSecTables rst
		WHERE	rst.rst_table_name = @rst_table_name

		SELECT	@ColumnPtr = 1
		SELECT	@addsymbol = ''
		SELECT	@columnSetList = ''
		SELECT	@columnSetListComma = ''
		SELECT	@columnConditionList = ''
		
	
		WHILE 	@ColumnPtr <= @MaxSequence BEGIN
			SELECT	@rsc_column_name = NULL
			
			SELECT	@rsc_column_name = rsc_column_name,
					@rsc_unknown_value = rsc_unknown_value
			FROM	#ColumnsToCheck
			WHERE	rsc_sequence = @ColumnPtr
			
			IF @rsc_column_name IS NULL BEGIN
				SELECT @columnSetList = @columnSetList + @columnSetListComma + quotename('rscv_value' + convert(varchar(1), @ColumnPtr)) + ' = null'
			END
			ELSE BEGIN
				SELECT @columnSetList = @columnSetList + @columnSetListComma + quotename('rscv_value' + convert(varchar(1), @ColumnPtr)) + ' = isnull(' + quotename(@rst_table_name) + '.' + quotename(@rsc_column_name) + ', ''' + @rsc_unknown_value + ''')'
				SELECT @columnConditionList = @columnConditionList + ' AND rsrv.' + quotename('rscv_value' + convert(varchar(1), @ColumnPtr)) + ' = isnull(' + quotename(@rst_table_name) + '.' + quotename(@rsc_column_name) + ', ''' + @rsc_unknown_value + ''')'
			END	
			SELECT @columnSetListComma = ', '			
			SELECT @ColumnPtr = @ColumnPtr + 1
		END
		
		SELECT	@sql = 'INSERT RowSecRowValues '
					+ ' SELECT DISTINCT ' + @rst_id_string + ', '
					+ @columnSetList
					+ ' FROM #NewValues nv INNER JOIN ' + quotename(rst_table_name) + 'on nv.' + quotename(rst_primary_key) + ' = ' + quotename(rst_table_name) + '.' + quotename(rst_primary_key)
					+ ' WHERE NOT EXISTS ( SELECT *'
					+					' FROM RowSecRowValues rsrv'
					+					' WHERE rsrv.rst_id = ' + @rst_id_string
					+					@columnConditionList
					+					')'
		FROM	RowSecTables rst
		WHERE	rst.rst_table_name = @rst_table_name
		
		IF @debug = 1 BEGIN
			PRINT 'RowSecUpdateRows_sp Dynamic query INSERT RowSecRowValues: ' + @sql
			PRINT 'Length: ' + convert(varchar(10), len(@sql))
		END
		
		EXECUTE sp_executesql @sql
		
		SELECT @error = @@ERROR
		IF @error != 0 BEGIN
			SELECT @message = 'Error encountered during query: ' + @sql
		END

		SELECT	@sql = 'UPDATE ' + quotename(rst_table_name)
					+ ' SET ' + quotename(rst.rst_belongsto_column) + ' = rsrv.rsrv_id'
					+ ' FROM RowSecRowValues rsrv, #NewValues nv'
					+ ' WHERE ' + quotename(rst_table_name) + '.' + quotename(rst_primary_key) + ' = nv.' + quotename(rst_primary_key)
					+			' AND rsrv.rst_id = ' + @rst_id_string
					+			' AND ISNULL(' + quotename(rst_table_name) + '.' + quotename(rst.rst_belongsto_column) + ', 0) <> ISNULL(rsrv.rsrv_id, 0)'
					+			@columnConditionList
		FROM	RowSecTables rst
		WHERE	rst.rst_table_name = @rst_table_name
		
		IF @debug = 1 BEGIN
			PRINT 'RowSecUpdateRows_sp Dynamic query UPDATE affected table: ' + @sql
			PRINT 'Length: ' + convert(varchar(10), len(@sql))
		END
		
		EXECUTE sp_executesql @sql
		
		SELECT @error = @@ERROR
		IF @error != 0 BEGIN
			SELECT @message = 'Error encountered during query: ' + @sql
		END
		
		
		IF @debug = 1 BEGIN
			SELECT	@sql = 'SELECT ' + quotename(rst_table_name) + '.' + quotename(rst.rst_primary_key) + ',' + quotename(rst_table_name) + '.' + QUOTENAME(rst.rst_belongsto_column)
					+ ' FROM ' + rst_table_name + ' INNER JOIN #NewValues n on ' + quotename(rst_table_name) + '.' + quotename(rst_primary_key) + ' = n.' + quotename(rst_primary_key)
			FROM	RowSecTables rst
			WHERE	rst.rst_table_name = @rst_table_name	
			
			EXECUTE sp_executesql @sql
		END
	END
END

GO
GRANT EXECUTE ON  [dbo].[RowSecUpdateRows_sp] TO [public]
GO
