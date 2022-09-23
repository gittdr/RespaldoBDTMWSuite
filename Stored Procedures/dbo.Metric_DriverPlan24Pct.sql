SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Metric_DriverPlan24Pct] 
(
	--Standard Parameters
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	@MetricCode varchar(128) = '',
	--Additional/Optional Parameters
	@OnlyRevClass1List varchar(128) ='',
	@OnlyRevClass2List varchar(128) ='',
	@OnlyRevClass3List varchar(128) ='',
	@OnlyRevClass4List varchar(128) ='',
	@Only_mpp_id varchar(128) = '', --Driver ID
	@Only_mpp_teamleader	varchar(128) ='',
	@Only_mpp_fleet		varchar(128) ='',
	@Only_mpp_division	varchar(128) ='',
	@Only_mpp_domicile	varchar(128) ='',
	@Only_mpp_company	varchar(128) ='',
	@Only_mpp_terminal	varchar(128) ='',
	@Only_mpp_type1		varchar(128) ='',
	@Only_mpp_type2		varchar(128) ='',
	@Only_mpp_type3		varchar(128) ='',
	@Only_mpp_type4		varchar(128) ='',
	@Only_trc_company	varchar(128) ='',	
	@Only_trc_division	varchar(128) ='',	
	@Only_trc_fleet		varchar(128) ='',
	@Only_trc_terminal	varchar(128) ='',
	@Only_trc_type1		varchar(128) ='',
	@Only_trc_type2		varchar(128) ='',
	@Only_trc_type3		varchar(128) ='',
	@Only_trc_type4		varchar(128) =''

)
AS
	SET NOCOUNT ON  -- PTS46367

	--Standard Metric Initialization
	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'DriverPlan24Pct',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 103, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = '% Drivers Planned (24 hr)',
		@sCaptionFull = 'Percent of drivers with legheaders within the next 24 hourst',
		@sProcedureName = 'Metric_DriverPlan24Pct',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
	*/

	--Standard Parameter Initialization
	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	Set @Only_mpp_id =',' + ISNULL(@Only_mpp_id,'') + ','
	Set @Only_mpp_teamleader= ',' + ISNULL(@Only_mpp_teamleader,'') + ','
	Set @Only_mpp_fleet= ',' + ISNULL(@Only_mpp_fleet,'') + ','
	Set @Only_mpp_division= ',' + ISNULL(@Only_mpp_division,'') + ','
	Set @Only_mpp_domicile= ',' + ISNULL(@Only_mpp_domicile,'') + ','
	Set @Only_mpp_company= ',' + ISNULL(@Only_mpp_company,'') + ','
	Set @Only_mpp_terminal= ',' + ISNULL(@Only_mpp_terminal,'') + ','

	Set @Only_mpp_type1= ',' + ISNULL(@Only_mpp_type1,'') + ','
	Set @Only_mpp_type2= ',' + ISNULL(@Only_mpp_type2,'') + ','
	Set @Only_mpp_type3= ',' + ISNULL(@Only_mpp_type3,'') + ','
	Set @Only_mpp_type4= ',' + ISNULL(@Only_mpp_type4,'') + ','

	Set @Only_trc_company= ',' + ISNULL(@Only_trc_company,'') + ','
	Set @Only_trc_division= ',' + ISNULL(@Only_trc_division,'') + ','
	Set @Only_trc_fleet= ',' + ISNULL(@Only_trc_fleet,'') + ','
	Set @Only_trc_terminal= ',' + ISNULL(@Only_trc_terminal,'') + ','

	Set @Only_trc_type1= ',' + ISNULL(@Only_trc_type1,'') + ','
	Set @Only_trc_type2= ',' + ISNULL(@Only_trc_type2,'') + ','
	Set @Only_trc_type3= ',' + ISNULL(@Only_trc_type3,'') + ','
	Set @Only_trc_type4= ',' + ISNULL(@Only_trc_type4,'') + ','


	IF @DateStart = CAST(CONVERT(char(8),getdate(),112) as datetime)
	BEGIN
		-- Step 1: get count of Legheaders for next 24 hours
		-- Step 2: Get count of Legheaders where assingment has been made
		Declare @DriverCountNext24Hours Float -- Drivers without Expirations in the next 24 Hours
		Declare @DriverCountNext24HoursWithAssignments Float -- Drivers without Expirations with Assignments in the next 24 Hours
		
		--Determine total driver base
		--select distinct mpp_id, 0 as expirations from manpowerprofile (NOLOCK)

		--Determine the Expirations Per Driver
		select distinct m.mpp_id, dbo.fnc_TMWRN_TotalDriverExpirationsForWeek(GETDATE(),dateAdd(d,1,GETDATE()),mpp_id,'9') as expirations
		into #DriversWithExpirations
		from manpowerprofile m (NOLOCK)
		where  mpp_hiredate < GETDATE()
		   	AND mpp_terminationdt > GETDATE()
			AND (@Only_mpp_id =',,' or CHARINDEX(',' + RTRIM( m.mpp_id ) + ',', @Only_mpp_id) >0)
			AND (@Only_mpp_teamleader =',,' or CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @Only_mpp_teamleader) >0)
			AND (@Only_mpp_fleet =',,' or CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @Only_mpp_fleet) >0)
			AND (@Only_mpp_division =',,' or CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @Only_mpp_division) >0)
			AND (@Only_mpp_domicile =',,' or CHARINDEX(',' + RTRIM( m.mpp_domicile ) + ',', @Only_mpp_domicile) >0)
			AND (@Only_mpp_company =',,' or CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @Only_mpp_company) >0)
			AND (@Only_mpp_terminal =',,' or CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @Only_mpp_terminal) >0)
			AND (@Only_mpp_type1 =',,' or CHARINDEX(',' + RTRIM( m.mpp_type1 ) + ',', @Only_mpp_type1) >0)
			AND (@Only_mpp_type2 =',,' or CHARINDEX(',' + RTRIM( m.mpp_type2 ) + ',', @Only_mpp_type2) >0)
			AND (@Only_mpp_type3 =',,' or CHARINDEX(',' + RTRIM( m.mpp_type3 ) + ',', @Only_mpp_type3) >0)
			AND (@Only_mpp_type4 =',,' or CHARINDEX(',' + RTRIM( m.mpp_type4 ) + ',', @Only_mpp_type4) >0)

		--Determine Working Drivers in the Next 24 Hours
		SELECT DISTINCT lgh_driver1
		INTO #DriversWithAssignments
		FROM 	legheader l (NOLOCK)
		WHERE 	(l.lgh_startdate between GETDATE() and dateAdd(d,1,GETDATE()) 
				or l.lgh_enddate between GETDATE() and dateAdd(d,1,GETDATE())
				or GETDATE() between l.lgh_startdate and l.lgh_enddate)
				and l.lgh_outstatus <> 'CAN'
				AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( l.lgh_class1 ) + ',', @OnlyRevClass1List) >0)
				AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( l.lgh_class2 ) + ',', @OnlyRevClass2list) >0)
				AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( l.lgh_class3 ) + ',', @OnlyRevClass3List) >0)
				AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( l.lgh_class4 ) + ',', @OnlyRevClass4List) >0)
				AND (@Only_trc_company =',,' or CHARINDEX(',' + RTRIM( l.trc_company ) + ',', @Only_trc_company) >0)
				AND (@Only_trc_division =',,' or CHARINDEX(',' + RTRIM( l.trc_division ) + ',', @Only_trc_division) >0)
				AND (@Only_trc_fleet =',,' or CHARINDEX(',' + RTRIM( l.trc_fleet ) + ',', @Only_trc_fleet) >0)
				AND (@Only_trc_terminal =',,' or CHARINDEX(',' + RTRIM( l.trc_terminal ) + ',', @Only_trc_terminal) >0)
				AND (@Only_trc_type1 =',,' or CHARINDEX(',' + RTRIM( l.trc_type1 ) + ',', @Only_trc_type1) >0)
				AND (@Only_trc_type2 =',,' or CHARINDEX(',' + RTRIM( l.trc_type2 ) + ',', @Only_trc_type2) >0)
				AND (@Only_trc_type3 =',,' or CHARINDEX(',' + RTRIM( l.trc_type3 ) + ',', @Only_trc_type3) >0)
				AND (@Only_trc_type4 =',,' or CHARINDEX(',' + RTRIM( l.trc_type4 ) + ',', @Only_trc_type4) >0)
				AND (@Only_mpp_teamleader =',,' or CHARINDEX(',' + RTRIM( l.mpp_teamleader ) + ',', @Only_mpp_teamleader) >0)
				AND (@Only_mpp_fleet =',,' or CHARINDEX(',' + RTRIM( l.mpp_fleet ) + ',', @Only_mpp_fleet) >0)
				AND (@Only_mpp_division =',,' or CHARINDEX(',' + RTRIM( l.mpp_division ) + ',', @Only_mpp_division) >0)
				AND (@Only_mpp_domicile =',,' or CHARINDEX(',' + RTRIM( l.mpp_domicile ) + ',', @Only_mpp_domicile) >0)
				AND (@Only_mpp_company =',,' or CHARINDEX(',' + RTRIM( l.mpp_company ) + ',', @Only_mpp_company) >0)
				AND (@Only_mpp_terminal =',,' or CHARINDEX(',' + RTRIM( l.mpp_teamleader ) + ',', @Only_mpp_terminal) >0)
				AND (@Only_mpp_type1 =',,' or CHARINDEX(',' + RTRIM( l.mpp_type1 ) + ',', @Only_mpp_type1) >0)
				AND (@Only_mpp_type2 =',,' or CHARINDEX(',' + RTRIM( l.mpp_type2 ) + ',', @Only_mpp_type2) >0)
				AND (@Only_mpp_type3 =',,' or CHARINDEX(',' + RTRIM( l.mpp_type3 ) + ',', @Only_mpp_type3) >0)
				AND (@Only_mpp_type4 =',,' or CHARINDEX(',' + RTRIM( l.mpp_type4 ) + ',', @Only_mpp_type4) >0)
				
		--If a Driver is Working, but is marked with an expiration, change the expiraton status to 0.
		--This accounts for Drivers with partial day expirations
		update #DriversWithExpirations
		set expirations = 0
		From #DriversWithExpirations, #DriversWithAssignments 
		Where mpp_id = lgh_driver1	
	
		Set @DriverCountNext24Hours = 
			(select distinct count(d.mpp_id) 
			 from #DriversWithExpirations d 
			 where expirations <= 0
			)
	
		Set @DriverCountNext24HoursWithAssignments = 
			(select distinct count(d.lgh_driver1) 
			 from #DriversWithAssignments d
			)
	
		IF ( abs( DateDiff(d, Getdate(),@DateStart))>1 )
		BEGIN
			Set @ThisTotal= 
				(Select DailyTotal from MetricDetail where MetricCode=@MetricCode and PlainDate =@DateStart)
			Set @ThisCount = 
				(Select DailyCount from MetricDetail where MetricCode=@MetricCode and PlainDate =@DateStart)
		END
	
		IF ( abs( DateDiff(d, Getdate(),@DateStart))<=1 )
		BEGIN
	
			SELECT @ThisTotal =@DriverCountNext24Hours
			SELECT @ThisCount = @DriverCountNext24HoursWithAssignments
		END 
	
	END --StartDate = GetDate()
	ELSE
	BEGIN
		select @ThisTotal = dailytotal, @ThisCount = dailycount
		from metricdetail
		where plaindate = @datestart
			and @metriccode = metriccode
	END

	--Standard Result Calculation
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

GO
GRANT EXECUTE ON  [dbo].[Metric_DriverPlan24Pct] TO [public]
GO
