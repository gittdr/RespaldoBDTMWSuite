SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[DOE_Import_Fuel_Code] (
	@ImportFuelCode varchar(30), 
	@afp_description varchar(30), 
	@OverwriteExistingRecords_YN VARCHAR(1),
	@OnlyAddRecordsAfterMostRecentDateForTable_YN VARCHAR(1)
)
AS
	DECLARE @SourceTableName varchar(30)
	DECLARE @SourceFieldName varchar(30)
	DECLARE @nDash int
	DECLARE @SqlTableName varchar(30)
	DECLARE @Region varchar(30), @afp_tableid varchar(8)
	DECLARE @SQL varchar(1000)
	DECLARE @MostRecentDate datetime

	SELECT @OverwriteExistingRecords_YN = LEFT(@OverwriteExistingRecords_YN, 1)
	SELECT @OnlyAddRecordsAfterMostRecentDateForTable_YN = LEFT(@OnlyAddRecordsAfterMostRecentDateForTable_YN, 1)

	--*************************************************************** Start: VALIDATION ********************************************************************************
	SELECT @nDash = CHARINDEX('-', @ImportFuelCode)

	IF @nDash < 1
	BEGIN
		RAISERROR('Import code is not recognized.', 16, 1)
		RETURN
	END

	IF LEN(@ImportFuelCode) < 4 
	BEGIN
		RAISERROR('Import code is too small.', 16, 1)
		RETURN
	END
	--*************************************************************** End: VALIDATION ********************************************************************************

	--*************************************************************** Start: TRANSLATIONS ********************************************************************************
	IF Left(@ImportFuelCode, 3) = 'ALL'
		SET @SourceTableName = 'DOE_FUEL_EXTRACT'
	ELSE IF Left(@ImportFuelCode, 3) = 'LSD'
		SET @SourceTableName = 'DOE_FUEL_EXTRACT_LSD'
	ELSE IF Left(@ImportFuelCode, 4) = 'ULSD'
		SET @SourceTableName = 'DOE_FUEL_EXTRACT_ULSD'

	SELECT @Region = SUBSTRING(@ImportFuelCode, @nDash + 1, 100)  -- Just use 100 since it will not be bigger than 100.  Expand if necessary.
	IF (@Region = 'PADDI')			SELECT @SourceFieldName = 'EastCoast'
	ELSE IF @Region = 'PADDIA'		SELECT @SourceFieldName = 'NewEngland'
	ELSE IF @Region = 'PADDIB'		SELECT @SourceFieldName = 'CentralAtlantic'
	ELSE IF @Region = 'PADDIC'		SELECT @SourceFieldName = 'LowerAtlantic'
	ELSE IF @Region = 'PADDII'		SELECT @SourceFieldName = 'Midwest'
	ELSE IF @Region = 'PADDIII'		SELECT @SourceFieldName = 'GulfCoast'
	ELSE IF @Region = 'PADDIV'		SELECT @SourceFieldName = 'RockyMountain'
	ELSE IF @Region = 'PADDV'		SELECT @SourceFieldName = 'WestCoast'
	ELSE SELECT @SourceFieldName = @Region
	--*************************************************************** End: TRANSLATIONS ********************************************************************************

	SELECT @afp_tableid = (SELECT TOP 1 afp_tableid FROM AverageFuelPrice WHERE afp_description = @afp_description)
	IF @afp_tableid IS NULL
	BEGIN
		SELECT @afp_tableid = ISNULL(1 + MAX(CASE WHEN ISNUMERIC(afp_tableid) > 0  THEN CONVERT(int, afp_tableid) ELSE 0 END), 1)
					FROM AverageFuelPrice (NOLOCK) WHERE ISNUMERIC(afp_tableid) > 0
	END
	--- SELECT @SourceTableName, @SourceFieldName, @Region

	IF @OnlyAddRecordsAfterMostRecentDateForTable_YN = 'Y'
		SELECT @MostRecentDate = MAX(afp_date) FROM AverageFuelPrice WHERE afp_tableid = @afp_tableid 
	IF (@MostRecentDate IS NULL) -- Default...
		SELECT @MostRecentDate = '19500101'


	/* SAMPLE LISTED SO THAT IT IS EASIER TO READ THEN DYNAMIC SQL -- First, insert records into table, taking into consideration the @MostRecentDate if necessary.
	INSERT INTO AverageFuelPrice (afp_tableid, afp_date, afp_description, afp_price)
		SELECT @afp_tableid, t2.FuelDate, @Region, t2.EastCoast  --<<-- @SourceFieldName...
			FROM DOE_FUEL_EXTRACT t2 --<<-- @SourceTableName...
			WHERE afp_tableid = @afp_tableid
				AND NOT EXISTS(SELECT * FROM AverageFuelPrice WHERE afp_tableid = @afp_tableid AND afp_date = t2.FuelDate)
				AND t2.EastCoast IS NOT NULL --<<-- @SourceFieldName...
	*/
	IF NOT EXISTS(SELECT id FROM sysobjects WHERE type='fn' AND name='DOE_CustomAdjustmentForAvgFuelPriceImport')
	BEGIN
		SELECT @SQL = 
			'INSERT INTO AverageFuelPrice (afp_tableid, afp_date, afp_description, afp_price) 
			SELECT ''' + @afp_tableid + ''', t2.FuelDate, ''' + @afp_description + ''', t2.' + @SourceFieldName + ' 
				FROM ' + @SourceTableName + ' t2 
				WHERE NOT EXISTS(SELECT * FROM AverageFuelPrice WHERE afp_tableid = ''' + @afp_tableid + ''' AND afp_date = t2.FuelDate)
					AND t2.' + @SourceFieldName + ' IS NOT NULL
					AND t2.FuelDate > ''' + CONVERT(varchar(35), @MostRecentDate, 121) + ''''
	END
	ELSE
	BEGIN
		SELECT @SQL = 
			'INSERT INTO AverageFuelPrice (afp_tableid, afp_date, afp_description, afp_price) 
			SELECT ''' + @afp_tableid + ''', dbo.DOE_CustomAdjustmentForAvgFuelPriceImport(''' + @afp_description + ''', t2.FuelDate)'
			+ ', ''' + @afp_description + ''', t2.' + @SourceFieldName + ' 
				FROM ' + @SourceTableName + ' t2 
				WHERE NOT EXISTS(SELECT * FROM AverageFuelPrice WHERE afp_tableid = ''' + @afp_tableid + ''' AND afp_date = dbo.DOE_CustomAdjustmentForAvgFuelPriceImport(''' + @afp_description + ''', t2.FuelDate))
					AND t2.' + @SourceFieldName + ' IS NOT NULL
					AND dbo.DOE_CustomAdjustmentForAvgFuelPriceImport(''' + @afp_description + ''', t2.FuelDate) > ''' + CONVERT(varchar(35), @MostRecentDate, 121) + ''''
	END
	EXEC (@SQL)

	IF @OverwriteExistingRecords_YN = 'Y'
	BEGIN
		/*
		UPDATE AverageFuelPrice SET afp_price = t2.EastCoast  --<<-- @SourceFieldName...
			FROM AverageFuelPrice t1 (NOLOCK) INNER JOIN DOE_FUEL_EXTRACT t2 ON t1.afp_date = t2.FuelDate --<<-- @SourceTableName...
			WHERE afp_tableid = @afp_tableid
				AND t2.EastCoast IS NOT NULL --<<-- @SourceFieldName...
		*/
		IF NOT EXISTS(SELECT id FROM sysobjects WHERE type='fn' AND name='DOE_CustomAdjustmentForAvgFuelPriceImport')
		BEGIN
			SELECT @SQL = 
				'UPDATE AverageFuelPrice SET afp_price = t2.' + @SourceFieldName + ' 
				FROM AverageFuelPrice t1 (NOLOCK) INNER JOIN ' + @SourceTableName + ' t2 ON t1.afp_date = t2.FuelDate 
				WHERE afp_tableid = ''' + @afp_tableid + ''' AND t2.' + @SourceFieldName + ' IS NOT NULL '
		END
		ELSE
		BEGIN
			SELECT @SQL = 
				'UPDATE AverageFuelPrice SET afp_price = t2.' + @SourceFieldName + ' 
				FROM AverageFuelPrice t1 (NOLOCK) INNER JOIN ' + @SourceTableName + ' t2 ON t1.afp_date = dbo.DOE_CustomAdjustmentForAvgFuelPriceImport(''' + @afp_description + ''', t2.FuelDate) 
				WHERE afp_tableid = ''' + @afp_tableid + ''' AND t2.' + @SourceFieldName + ' IS NOT NULL '
		END
		EXEC (@SQL)
	END
	ELSE -- @OverwriteExistingRecords_YN = 'N'
	BEGIN

		IF NOT EXISTS(SELECT id FROM sysobjects WHERE type='fn' AND name='DOE_CustomAdjustmentForAvgFuelPriceImport')
		BEGIN
			SELECT @SQL = 
				'UPDATE AverageFuelPrice SET afp_price = t2.' + @SourceFieldName + ' 
				FROM AverageFuelPrice t1 (NOLOCK) INNER JOIN ' + @SourceTableName + ' t2 ON t1.afp_date = t2.FuelDate 
				WHERE afp_tableid = ''' + @afp_tableid + ''' AND t2.' + @SourceFieldName + ' IS NOT NULL 
					AND EXISTS(SELECT * FROM AverageFuelPrice WHERE afp_tableid = ''' + @afp_tableid + ''' AND afp_date = t2.FuelDate AND ISNULL(afp_price, 0) = 0 ) 
				'
		END
		ELSE
		BEGIN
			SELECT @SQL = 
				'UPDATE AverageFuelPrice SET afp_price = t2.' + @SourceFieldName + ' 
				FROM AverageFuelPrice t1 (NOLOCK) INNER JOIN ' + @SourceTableName + ' t2 ON t1.afp_date = dbo.DOE_CustomAdjustmentForAvgFuelPriceImport(''' + @afp_description + ''', t2.FuelDate) 
				WHERE afp_tableid = ''' + @afp_tableid + ''' AND t2.' + @SourceFieldName + ' IS NOT NULL 
					AND EXISTS(SELECT * FROM AverageFuelPrice WHERE afp_tableid = ''' + @afp_tableid + ''' AND afp_date = dbo.DOE_CustomAdjustmentForAvgFuelPriceImport(''' + @afp_description + ''', t2.FuelDate) AND ISNULL(afp_price, 0) = 0 ) 
				'
		END

		EXEC (@SQL)

	END

GO
GRANT EXECUTE ON  [dbo].[DOE_Import_Fuel_Code] TO [public]
GO
