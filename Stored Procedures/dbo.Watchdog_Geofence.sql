SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Watchdog_Geofence] 
(
	--Standard Parameters
	@MinThreshold FLOAT = 0, --NA
	@MinsBack INT=-60,
	@TempTableName VARCHAR(255) = '##WatchDogGlobalTractorInactivity',
	@WatchName VARCHAR(255)='WatchTractorInactivity',
	@ThresholdFieldName VARCHAR(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode VARCHAR(50) = 'Selected',
	--Additional/Optional Parameters
	@OutsideFenceYN char(1) = 'Y',
	--@MinutesBackStart int = 60,
	@MinutesBackEnd int = 0,
	@AssetType varchar(6)='TRL',
	@DateTimeReference datetime = NULL,
	@GeoFencePoints01 varchar(128) = '', -- Example for Ohio: '[41.8,85] [38.4, 85] [38.5, 80] [39.1777638, 86.850285]'
	@GeoFencePoints02 varchar(128) = '', 
	@GeoFencePoints03 varchar(128) = '',
	@GeoFencePoints04 varchar(128) = '',
	@GeoFencePoints05 varchar(128) = '',
	@GeoFencePoints06 varchar(128) = '',
	@CacheResultsWithNoRepetitionYN varchar(1)='N',
	@DaysToMaintainCache int = 1
)
AS
declare @ckc_number_temp int
	-- This can used to trigger an alert if a checkcall is 1) NOT within a certain geofence (like out of normal bounds).
	--						or 2) WITHIN a certain geofence.
	-- Sample usage:
	--		Watchdog_Geofence 'Y', @GeoFencePoints01 = '[41.710087,84.820459]   [41.940310, 80.585139] '
	--		Watchdog_Geofence 'Y', @GeoFencePoints01 = '[41.710087,84.820459]', @GeoFencePoints02 = '[41.940310, 80.585139]', @GeoFencePoints03 = '[39.1777638, 84.850285]'
	/*
	--Dawg Initialization
	if not exists (select WatchName from WatchDogItem where WatchName = 'Geofence')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateT

ype, Description)
	VALUES ('Geofence','12/30/1899','12/30/1899','Watchdog_Geofence','','',0,0,'','','','','',1,0,'','','')
	--Dawg Initialization
	*/
	SET NOCOUNT ON
	-- Put in points like this: [41.710087, 84.820459] [41.940310, 80.585139] 
	DECLARE @DateStart datetime, @DateEnd datetime
	DECLARE @GeoFencePoints varchar(4000)
	DECLARE @tblFencePoints TABLE (sn int identity, X float, Y float)
	-- CREATE TABLE @tblFencePoints (sn int identity, X float, Y float)
	DECLARE @CurX varchar(128), @CurY varchar(128)
	DECLARE @nIdxLeft int, @nIdxRight int, @nIdxComma int
	DECLARE @sn int
	DECLARE @MaxX float, @MinX float, @MaxY float, @MinY float
	DECLARE @P_X float, @P_Y float
	DECLARE @ckc_number int
	DECLARE @P0_X float -- X/Latitude for point 1 of triangle.
	DECLARE @P0_Y float  
	DECLARE @P1_X float -- X/Latitude for point 2 of triangle.
	DECLARE @P1_Y float 
	DECLARE @P2_X float -- X/Latitude for point 3 of triangle.
	DECLARE @P2_Y float 

	IF @DateTimeReference IS NULL 
		SET @DateTimeReference = GETDATE()

	SET @DateStart = DATEADD(minute, @MinsBack, @DateTimeReference)
	SET @DateEnd = DATEADD(minute, -@MinutesBackEnd, @DateTimeReference)

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	
	--Create TempTable
	CREATE Table #TempResultsPreCache
	(
		ckc_number INT, 
		ckc_date DATETIME, 
		ckc_tractor VARCHAR(8), 
		ckc_asgntype VARCHAR(8), 
		ckc_asgnid VARCHAR(8), 
		ckc_cityname VARCHAR(16), 
		ckc_state VARCHAR(6), 
		ckc_latitude DECIMAL(20,5), 
		ckc_longitude DECIMAL(20,5) , 
		ckc_comment VARCHAR(255)
	)
	-- Initialize Minimums and Maximums
	SELECT @MaxX = -1, @MinX = 99999, @MaxY = -1, @MinY = 99999

	-- Concatonate points or groups of points.
	SET @GeoFencePoints = @GeoFencePoints01 + @GeoFencePoints02 + @GeoFencePoints03
		 + @GeoFencePoints04 + @GeoFencePoints05 + @GeoFencePoints06 
		
	--print @GeoFencePoints
	-- Parse through @GeoFencePoints and place into table.
	WHILE LEN(@GeoFencePoints) > 0
	BEGIN
		SET @nIdxLeft = CHARINDEX('[', @GeoFencePoints)
		SET @nIdxRight = CHARINDEX(']', @GeoFencePoints)
		--print @nIdxLeft
		--print @nIdxRight
		IF @nIdxLeft > @nIdxRight 
		BEGIN
			RAISERROR ('Error in geofence points.', 16, 1)
			RETURN			
		END

		SET @nIdxComma = CHARINDEX(',', @GeoFencePoints, @nIdxLeft)
		--print @nIdxComma
		IF @nIdxComma = 0
		BEGIN
			RAISERROR ('Error in geofence points.', 16, 1)
			RETURN			
		END

		SET @CurX = LTRIM(RTRIM(SUBSTRING(@GeoFencePoints, @nIdxLeft + 1, @nIdxComma - @nIdxLeft - 1)))
		SET @CurY = LTRIM(RTRIM(SUBSTRING(@GeoFencePoints, @nIdxComma + 1, @nIdxRight - @nIdxComma - 1)))
		--print @curx
		--print @cury
		
		IF ISNUMERIC(@CurX) = 0 OR ISNUMERIC(@CurY) = 0 
		BEGIN
			RAISERROR ('Error in geofence points - non-numeric values.', 16, 1)
			RETURN
		END

		-- Put fence into a table so that we can loop through each triangle that 3 consecutive vertices create.
		INSERT INTO @tblFencePoints (x, y) SELECT @CurX, @CurY
	
		--select * from @tblFencePoints
		-- Set the Maximums and Minimums in order to skip the triangle check.
		IF @CurX > @MaxX SET @MaxX = @CurX
		IF @CurX < @MinX  SET @MinX = @CurX
		IF @CurY > @MaxY SET @MaxY = @CurY
		IF @CurY < @MinY SET @MinY = @CurY	
		
		SET @GeoFencePoints = SUBSTRING(@GeoFencePoints, @nIdxRight + 1, LEN(@GeoFencePoints))
	END

		--select count(*),'TableCount' from @tblFencePoints
	IF (@ColumnNamesOnly = 1) AND
		ISNULL((SELECT COUNT(*) FROM @tblFencePoints), 0) < 3
	BEGIN
		RAISERROR ('Error in geofence points - a geofence needs at least three points.', 16, 1)
		RETURN		
	END 
-- select * from @tblFencePoints

	SELECT @ckc_number = MIN(ckc_number) FROM checkcall (nolock) WHERE ckc_date BETWEEN @DateStart AND @DateEnd 
	WHILE ISNULL(@ckc_number , 0) > 0
	BEGIN
		select @ckc_number_temp = -1
		SELECT @P_X = ckc_latseconds / 3600.0, @P_Y = ckc_longseconds /3600.0 FROM checkcall (nolock) WHERE ckc_number = @ckc_number

		-- Always use point 0 as a reference to draw triangles.

declare @sn_pre int
declare @FenceCount int
select @fencecount = count(*) from @tblFencePoints


select @sn_pre = 1

while @sn_pre < @fenceCount - 1
BEGIN
SELECT @P0_X = x, @P0_Y = y FROM @tblFencePoints WHERE sn = @sn_pre

		-- Start from 3rd point and get the last three for triangle to check.
		SELECT @sn = MIN(sn) FROM @tblFencePoints WHERE sn > @sn_pre + 1 
		WHILE ISNULL(@sn, 0) > 0
		BEGIN
			SELECT @P1_X = x, @P1_Y = y 
				 FROM @tblFencePoints WHERE sn = @sn - 1

			SELECT @P2_X = x , @P2_Y = y
				 FROM @tblFencePoints WHERE sn = @sn 

			-- Determine if the point is INSIDE or OUTSIDE the geofence.
			IF dbo.fnc_TMWRN_IsPointInTriangle(@P_X, @P_Y, @P0_X, @P0_Y, @P1_X, @P1_Y, @P2_X, @P2_Y) = 1
					--CASE WHEN ISNULL(@OutsideFenceYN, 'Y') = 'Y' THEN 0 ELSE 1 END
			BEGIN
select @ckc_number_Temp = @ckc_number
/*
				INSERT INTO #TempResultsPreCache
				SELECT ckc_number, ckc_date, ckc_tractor, ckc_asgntype, ckc_asgnid, ckc_cityname, ckc_state, ckc_latseconds, ckc_longseconds, ckc_comment
				FROM checkcall (nolock) WHERE ckc_number = @ckc_number AND ckc_asgntype = @AssetType
*/				
			END
	
			SELECT @sn = MIN(sn) FROM @tblFencePoints WHERE sn > @sn
		END
	select @sn_pre = @sn_pre + 1
END

IF (@OutsideFenceYN = 'Y' AND @Ckc_number_temp = -1)
	OR (@OutsideFenceYN = 'N' AND @Ckc_number_temp <> -1)
BEGIN
				INSERT INTO #TempResultsPreCache
				SELECT ckc_number, ckc_date, ckc_tractor, ckc_asgntype, ckc_asgnid, ckc_cityname, ckc_state, cast(cast(ckc_latseconds as decimal(20,5)) /3600.00 as decimal(20,5)), cast(cast(ckc_longseconds as decimal(20,5))/3600.00 as decimal(20,5)), ckc_comment
				FROM checkcall (nolock) WHERE ckc_number = @ckc_number AND ckc_asgntype = @AssetType
END

		SELECT @ckc_number = MIN(ckc_number) FROM checkcall (nolock) WHERE ckc_number > @ckc_number 
			AND ckc_date BETWEEN @DateStart AND @DateEnd
	END


	IF @CacheResultsWithNoRepetitionYN = 'Y'
	BEGIN
		DELETE FROM #TempResultsPreCache
		WHERE EXISTS (
						SELECT * 
						from WatchDogCache_GeoFence
						where #TempResultsPreCache.ckc_number = WatchDogCache_GeoFence.ckc_number
					)
		
		Insert Into WatchDogCache_GeoFence
		SELECT 	ckc_number,
				GETDATE() as CacheDate
		FROM #TempResultsPreCache

		DELETE FROM WatchDogCache_GeoFence
		WHERE CacheDate < DateAdd(day,-@DaysToMaintainCache,GETDATE())

	END

	SELECT * 
	into #TempResults 
	from #TempResultsPreCache

--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResults'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
	End
	
	Exec (@SQL)
	
	
	Set NoCount Off
	

/*
SAMPLE USAGE:
	Watchdog_Geofence @OutsideFenceYN = 'Y', @GeoFencePoints01 = '[41.8,85]', @GeoFencePoints02 = '[38.4, 85]', 
		@GeoFencePoints03 = '[38.5, 80] [39.1777638, 86.850285]', @DateTimeReference = '6/4/2005 01:30'
*/




GO
GRANT EXECUTE ON  [dbo].[Watchdog_Geofence] TO [public]
GO
