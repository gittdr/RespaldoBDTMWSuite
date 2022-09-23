SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RowSecDynamicTrigger_sp](@rst_table_name sysname, @apply bit, @debug bit)

AS

BEGIN
	DECLARE @Message varchar(1024)
	DECLARE	@Owner nvarchar(10)
	DECLARE	@SqlTriggerDrop nvarchar(1024)
	DECLARE	@SqlTriggerCreate nvarchar(2048)
	DECLARE @SqlInsertRowSecRowValue nvarchar(1024)
	DECLARE @SqlUpdateTableRowSec nvarchar(1024)
	DECLARE @TriggerName nvarchar(256)

	DECLARE @ColumnPtr int
	DECLARE	@rst_id_string varchar(10)
	DECLARE @rsc_column_name varchar(20)
	DECLARE @rsc_unknown_value varchar(12)
	DECLARE @MaxSequence smallint
	DECLARE @ColumnSetList varchar(1024)
	DECLARE @ColumnSetListComma varchar(3)
	DECLARE @ColumnConditionList nvarchar(1024)

	DECLARE @ColumnUpdateCheckList nvarchar(1024)
	DECLARE @ColumnUpdateCheckListOr varchar(4)

	DECLARE @ApplyAllTables	bit
	
	CREATE TABLE #ColumnsToCheck (
		rsc_column_name sysname NULL,
		rsc_unknown_value varchar(12) NULL,
		rsc_sequence smallint NULL,
		ColumnID int NULL
	)

	SET NOCOUNT ON
	
	--init static values
	SELECT	@Owner = 'dbo.'

	SELECT	@ApplyAllTables = 0
	IF @rst_table_name IS NULL BEGIN
		SELECT	@rst_table_name = MIN(rst.rst_table_name)
		FROM	RowSecTables rst
		
		SELECT @ApplyAllTables = 1
	END
	
	IF	@debug = 1 BEGIN
		PRINT	'Starting trigger create'
		SELECT	'@ApplyAllTables', @ApplyAllTables
	END

	WHILE	(@rst_table_name IS NOT NULL)	BEGIN
		IF @ApplyAllTables = 1 BEGIN
			SELECT 	@apply = rst.rst_applied
			FROM	RowSecTables rst
			WHERE	rst.rst_table_name = @rst_table_name	
		END
		
		IF	@debug = 1 BEGIN
			PRINT	'Working on table: ' + @rst_table_name
			SELECT	'@apply', @apply
		END
		
		--Trigger setup
		SELECT	@TriggerName = 'iut_' + @rst_table_name + '_rowsec_dynamic'

		--Trigger drop
		SELECT	@SqlTriggerDrop = 'IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N''' + @Owner + @TriggerName + ''')) '
							+ 'DROP TRIGGER ' + @Owner + @TriggerName 

		SELECT	@SqlTriggerCreate = ''
		
		--Should trigger be created?
		IF @apply = 1 BEGIN
		
			DELETE	#ColumnsToCheck
								
			--Trigger body
			INSERT	#ColumnsToCheck
					(	rsc_column_name,
						rsc_unknown_value,
						rsc_sequence,
						ColumnID
					)
			SELECT	rsc.rsc_column_name,
					ISNULL(rsc.rsc_unknown_value, 'UNK'),
					rsc.rsc_sequence,
					ColumnID =	(	SELECT	colid 
									FROM	syscolumns 
									where name = rsc.rsc_column_name and id = OBJECT_ID(rst.rst_table_name) 
								)
			FROM	RowSecTables rst 
					INNER JOIN RowSecColumns rsc on rst.rst_id = rsc.rst_id
			WHERE	rst.rst_table_name = @rst_table_name
					and rsc.rsc_sequence > 0 
			
			--If there's no columns selected, then no need to create
			IF	(	SELECT	count(*)
					FROM	#ColumnsToCheck
				) > 0 BEGIN
				IF @debug = 1 BEGIN	
					PRINT 'Columns to include...'
					SELECT * FROM #ColumnsToCheck
				END

				IF EXISTS	(	SELECT	* 
								FROM	#ColumnsToCheck
								WHERE	ColumnID IS NULL) BEGIN
					SELECT @Message = 'Please contact support.  Column name does not exist for row security definition corresponding to table = ' + convert(varchar(10), @rst_table_name)
					RAISERROR(@Message, 16, 1)
					RETURN
				END

				SELECT	@MaxSequence = 4

				SELECT	@rst_id_string = convert(varchar(10), rst.rst_id)
				FROM	RowSecTables rst
				WHERE	rst.rst_table_name = @rst_table_name

				SELECT	@ColumnPtr = 1
				SELECT	@ColumnSetList = ''
				SELECT	@ColumnSetListComma = ''
				SELECT	@ColumnConditionList = ''
				SELECT	@ColumnUpdateCheckList = ''
				SELECT	@ColumnUpdateCheckListOr = ''

				WHILE 	@ColumnPtr <= @MaxSequence BEGIN
					SELECT	@rsc_column_name = NULL
					
					SELECT	@rsc_column_name = rsc_column_name,
							@rsc_unknown_value = rsc_unknown_value
					FROM	#ColumnsToCheck
					WHERE	rsc_sequence = @ColumnPtr
					
					IF @rsc_column_name IS NULL BEGIN
						SELECT	@ColumnSetList = @ColumnSetList + @ColumnSetListComma + quotename('rscv_value' + convert(varchar(1), @ColumnPtr)) + ' = null'
					END
					ELSE BEGIN
						SELECT	@ColumnSetList = @ColumnSetList + @ColumnSetListComma + quotename('rscv_value' + convert(varchar(1), @ColumnPtr)) + ' = isnull(i.' + quotename(@rsc_column_name) + ', ''' + @rsc_unknown_value + ''')'
						SELECT	@ColumnConditionList = @ColumnConditionList + ' AND rsrv.' + quotename('rscv_value' + convert(varchar(1), @ColumnPtr)) + ' = isnull(i.' + quotename(@rsc_column_name) + ', ''' + @rsc_unknown_value + ''')'
						SELECT	@ColumnUpdateCheckList = @ColumnUpdateCheckList + @ColumnUpdateCheckListOr  + 'UPDATE(' + quotename(@rsc_column_name) + ')'
					END	
					
					SELECT @ColumnSetListComma = ', '
					SELECT @ColumnUpdateCheckListOr = ' OR '	
					SELECT @ColumnPtr = @ColumnPtr + 1
				END
				SELECT	@ColumnUpdateCheckList = 'IF ' + @ColumnUpdateCheckList + ' BEGIN '

				SELECT	@SqlInsertRowSecRowValue = 'INSERT RowSecRowValues (rst_id, rscv_value1, rscv_value2, rscv_value3, rscv_value4)'
							+ ' SELECT DISTINCT ' + @rst_id_string + ', '
							+ @ColumnSetList
							+ ' FROM inserted i '
							+ ' WHERE NOT EXISTS ( SELECT *'
							+					' FROM RowSecRowValues rsrv'
							+					' WHERE rsrv.rst_id = ' + @rst_id_string
							+					@ColumnConditionList
							+					') '
				FROM	RowSecTables rst
				WHERE	rst.rst_table_name = @rst_table_name

				IF @debug = 1 BEGIN
					PRINT 'Dynamic query INSERT RowSecRowValues: ' + @SqlInsertRowSecRowValue
					PRINT 'Length: ' + convert(varchar(10), len(@SqlInsertRowSecRowValue))
				END


				SELECT	@SqlUpdateTableRowSec = 'UPDATE ' + quotename(rst_table_name)
							+ ' SET ' + quotename(rst.rst_belongsto_column) + ' = rsrv.rsrv_id'
							+ ' FROM RowSecRowValues rsrv, inserted i'
							+ ' WHERE ' + quotename(rst_table_name) + '.' + quotename(rst_primary_key) + ' = i.' + quotename(rst_primary_key)
							+			' AND rsrv.rst_id = ' + @rst_id_string
							+			' AND ISNULL(i.' + quotename(rst.rst_belongsto_column) + ', 0) <> ISNULL(rsrv.rsrv_id, 0)'
							+			@ColumnConditionList
							+ ' '
				FROM	RowSecTables rst
				WHERE	rst.rst_table_name = @rst_table_name

				IF @debug = 1 BEGIN
					PRINT 'Dynamic query UPDATE affected table: ' + @SqlUpdateTableRowSec
					PRINT 'Length: ' + convert(varchar(10), len(@SqlUpdateTableRowSec))
				END
				--end trigger body

				--Trigger create
				SELECT	@SqlTriggerCreate = 'CREATE TRIGGER ' + @Owner + @TriggerName + ' ON [dbo].' + @rst_table_name + ' FOR INSERT, UPDATE AS BEGIN /*WARNING: THIS TRIGGER IS DYNAMICALLY GENERATED FOR USE BY ROW SECURITY.  DO NOT ATTEMPT TO MODIFY.*/ SET NOCOUNT ON '
				SELECT	@SqlTriggerCreate = @SqlTriggerCreate + @ColumnUpdateCheckList
				SELECT	@SqlTriggerCreate = @SqlTriggerCreate + @SqlInsertRowSecRowValue
				SELECT	@SqlTriggerCreate = @SqlTriggerCreate + @SqlUpdateTableRowSec
				SELECT	@SqlTriggerCreate = @SqlTriggerCreate + ' END '  --If Update condition end
				SELECT	@SqlTriggerCreate = @SqlTriggerCreate + ' END '  --Trigger body end
			END
		END

		--Debug
		IF @Debug = 1 BEGIN
			PRINT	'Executing dynamic sql...'
			SELECT	@rst_table_name as rst_table_name
			SELECT	@TriggerName as triggername 
			SELECT	len(@SqlTriggerDrop) as length, @SqlTriggerDrop as sqltriggerdrop
			SELECT	len(@SqlTriggerCreate) as length, @SqlTriggerCreate as sqltriggercreate
		END
		
		EXECUTE sp_executesql @SqlTriggerDrop
		
		IF @Debug = 1 BEGIN
			PRINT '@Finished executing @SqlTriggerDrop'
		END

		IF LEN(@SqlTriggerCreate) > 0 BEGIN
			EXECUTE sp_executesql @SqlTriggerCreate
			
			IF @Debug = 1 BEGIN
				PRINT '@Finished executing @SqlTriggerCreate'
			END 
		END
		
		IF @debug = 1 BEGIN
			PRINT	'End Working on table: ' + @rst_table_name
		END  
		
		IF @ApplyAllTables = 1 BEGIN
			SELECT	@rst_table_name = MIN(rst.rst_table_name)
			FROM	RowSecTables rst
			WHERE	rst.rst_table_name > @rst_table_name
		END	
		ELSE BEGIN
			SELECT @rst_table_name = null
		END
		
		IF @debug = 1 BEGIN
			PRINT	'End loop found next table: ' + ISNULL(@rst_table_name, 'NULL')
		END  

	END
	
	DROP TABLE #ColumnsToCheck

	IF @debug = 1 BEGIN
		PRINT	'Ended trigger create'
	END  
END
GO
GRANT EXECUTE ON  [dbo].[RowSecDynamicTrigger_sp] TO [public]
GO
