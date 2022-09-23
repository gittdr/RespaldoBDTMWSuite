SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Watchdog_AssetLocationMismatch]
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
	@AssetType VARCHAR(6) = 'TRL'

)
AS
	-- Simple "Mismatched trailers"
	-- Objective: Shows trailers whose GPS report are a mismatch compared to TMWSuite data.
	-- 		Really try not to show mismatched that are really okay. In other words, error by showing too little, instead of too much information.
	-- Could be more efficient, but should be okay for now.

	/*
	if not exists (select WatchName from WatchDogItem where WatchName = 'AssetLocationMismatch')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	VALUES ('AssetLocationMismatch','12/30/1899','12/30/1899','Watchdog_AssetLocationMismatch','','',0,0,'','','','','',1,0,'','','')
	*/

	SET NOCOUNT ON

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	

	DECLARE @DateStart datetime, @DateEnd datetime
	DECLARE @ckc_number int, @ckc_date datetime, @ckc_asgnid varchar(10), @stp_number int, @cty_code int, @evt_startdate datetime

	CREATE TABLE #TrailerCheckcalls (ckc_number int, ckc_date datetime, ckc_asgnid varchar(12), ckc_latitude int, ckc_longitude int, cty_code int, evt_startdate datetime, stp_number int)

	SELECT @DateStart = DATEADD(mi,@minsback,GETDATE())
	SELECT @DateEnd = GETDATE()

	-- Get pool of last checkcalls for each trailer during the appropriate time frame.
	INSERT INTO #TrailerCheckcalls (ckc_asgnid, ckc_number) 
		SELECT ckc_asgnid, MAX(ckc_number) 
			FROM checkcall (NOLOCK) 
			WHERE ckc_date > @DateStart AND ckc_date < @DateEnd 
				AND ckc_asgntype = @AssetType 
			GROUP BY ckc_asgnid 

	-- Update date, latitude, and longitude for those checkcalls.
	UPDATE #TrailerCheckcalls 
		SET #TrailerCheckcalls.ckc_date = checkcall.ckc_date,
			ckc_latitude = checkcall.ckc_latseconds,
			ckc_longitude = checkcall.ckc_longseconds
		FROM checkcall (NOLOCK) WHERE checkcall.ckc_number = #TrailerCheckcalls.ckc_number

	-- Get the stop number that occured before the trailer checkcall.
	UPDATE #TrailerCheckcalls 
		SET stp_number = (SELECT TOP 1 stp_number FROM event (NOLOCK)
								WHERE evt_trailer1 = #TrailerCheckcalls.ckc_asgnid 
									AND evt_startdate > DATEADD(week, -1, #TrailerCheckcalls.ckc_date) 
									AND evt_startdate <= #TrailerCheckcalls.ckc_date 
								ORDER BY evt_startdate desc)

	-- Don't know what to do with these. Could look at next stops, but eliminate for now.
	DELETE #TrailerCheckcalls WHERE stp_number IS NULL

	-- Fill in other stop and event information for that stop.
	UPDATE #TrailerCheckcalls SET #TrailerCheckcalls.evt_startdate = event.evt_startdate , cty_code = stops.stp_city
	FROM event (NOLOCK) INNER JOIN stops (nolock) ON event.stp_number = stops.stp_number
	WHERE #TrailerCheckcalls.stp_number = event.stp_number
	
	-- Put into a temp table to ease the order by.
	SELECT 
		AssetType = @AssetType,
		AssetID = ckc_asgnid,
		-- Event
		LastEventDate = evt_startdate , LastEventLatitude = tCity.cty_latitude, LastEventLongitude = tCity.cty_longitude,
		-- Checkcall
		CheckCallDate = t1.ckc_date , CheckCallLatitude = t1.ckc_latitude / 3600.0, CheckCallLongitude = t1.ckc_longitude  /3600.0,
		-- Calculations
		AirMiles = dbo.fnc_AirMilesBetweenLatLongSeconds(tCity.cty_latitude * 3600, t1.ckc_latitude, tCity.cty_longitude * 3600, t1.ckc_longitude ),
		TimeDifference = DATEDIFF(minute, t1.evt_startdate, t1.ckc_date),

		-- Calculation of above.
		RequiredAirMPH = CASE WHEN DATEDIFF(minute, t1.evt_startdate, t1.ckc_date) = 0 THEN -1 
				ELSE dbo.fnc_AirMilesBetweenLatLongSeconds(tCity.cty_latitude * 3600, t1.ckc_latitude, tCity.cty_longitude * 3600, t1.ckc_longitude )
						 / (DATEDIFF(minute, t1.evt_startdate, t1.ckc_date)/60.0) END
	INTO #t1
	FROM #TrailerCheckcalls t1 INNER JOIN city tCity (NOLOCK) ON t1.cty_code = tCity.cty_code

	SELECT * 
	INTO #TempResults
	FROM #t1 
	WHERE RequiredAirMPH > @MinThreshold
	ORDER BY RequiredAirMPH DESC

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
GRANT EXECUTE ON  [dbo].[Watchdog_AssetLocationMismatch] TO [public]
GO
