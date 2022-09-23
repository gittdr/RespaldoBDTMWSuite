SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Metric_Plan24Pct] (
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	@MetricCode varchar(128) = '',
	@OnlyRevClass1List varchar(128) ='',
	@OnlyRevClass2List varchar(128) ='',
	@OnlyRevClass3List varchar(128) ='',
	@OnlyRevClass4List varchar(128) ='',
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

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'Plan24Pct',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 103, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = '% Planned (24 hr)',
		@sCaptionFull = 'Percent of orders that are planned 24 hours out',
		@sProcedureName = 'Metric_Plan24Pct',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/

	-- OLD and WRONG

	
	/*
	-- DISPATCH #3: Percent Planned (24 hours):
	SET NOCOUNT ON

	-- *********************************************************************************************
	-- Initialize the #orderheader table (temporary) to be used for many calculations.
	CREATE TABLE #orderheader (ord_hdrnumber int, ord_completiondate datetime, ord_bookdate datetime, ord_status varchar(6), ord_fromorder varchar(12),
							ord_billto varchar(8), ord_shipper varchar(8), ord_consignee varchar(8), ord_terms varchar(6), ord_totalweight decimal(20, 5),
							ord_refnum varchar(20), cmd_code varchar(8), ord_totalpieces decimal(20, 5)
							)
	INSERT INTO #orderheader 
	SELECT ord_hdrnumber, ord_completiondate, ord_bookdate, ord_status, ord_fromorder, ord_billto, ord_shipper, ord_consignee, ord_terms, ord_totalweight, ord_refnum, cmd_code, ord_totalpieces
		FROM orderheader WITH (NOLOCK) WHERE ord_completiondate >= @DateStart AND ord_completiondate < @DateEnd
	-- *********************************************************************************************

	-- TOTAL ORDERS started today.
	SELECT @ThisTotal = COUNT(*) FROM #orderheader 
	-- TOTAL ORDERS started today booked over 24 hours ago.
	SELECT @ThisCount = COUNT(*) FROM #orderheader WHERE DATEDIFF(hour, ord_bookdate, ord_completiondate) > 24
	-- PERCENTAGE of orders booked over 24 hours ago.
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
	SET NOCOUNT OFF
	*/

	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','


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
	Declare @LegheaderCountNext24Hours Float
	Declare @LegheaderCountNext24HoursWithAssignments Float
	Set @LegheaderCountNext24Hours =
		(select count(*) 
		from 	legheader (NOLOCK)
		where 	lgh_startdate between Getdate() and dateAdd(d,1,Getdate())
			and lgh_outstatus in ('CMP','DSP','PLN','STD','AVL')
			AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)

			AND (@Only_mpp_teamleader =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @Only_mpp_teamleader) >0)
			AND (@Only_mpp_fleet =',,' or CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @Only_mpp_fleet) >0)
			AND (@Only_mpp_division =',,' or CHARINDEX(',' + RTRIM( mpp_division ) + ',', @Only_mpp_division) >0)
			AND (@Only_mpp_domicile =',,' or CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @Only_mpp_domicile) >0)
			AND (@Only_mpp_company =',,' or CHARINDEX(',' + RTRIM( mpp_company ) + ',', @Only_mpp_company) >0)
			AND (@Only_mpp_terminal =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @Only_mpp_terminal) >0)

			AND (@Only_mpp_type1 =',,' or CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @Only_mpp_type1) >0)
			AND (@Only_mpp_type2 =',,' or CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @Only_mpp_type2) >0)
			AND (@Only_mpp_type3 =',,' or CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @Only_mpp_type3) >0)
			AND (@Only_mpp_type4 =',,' or CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @Only_mpp_type4) >0)


			AND (@Only_trc_company =',,' or CHARINDEX(',' + RTRIM( trc_company ) + ',', @Only_trc_company) >0)
			AND (@Only_trc_division =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @Only_trc_division) >0)
			AND (@Only_trc_fleet =',,' or CHARINDEX(',' + RTRIM( trc_fleet ) + ',', @Only_trc_fleet) >0)
			AND (@Only_trc_terminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @Only_trc_terminal) >0)

			AND (@Only_trc_type1 =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @Only_trc_type1) >0)
			AND (@Only_trc_type2 =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @Only_trc_type2) >0)
			AND (@Only_trc_type3 =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @Only_trc_type3) >0)
			AND (@Only_trc_type4 =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @Only_trc_type4) >0)
		)
	Set @LegheaderCountNext24HoursWithAssignments =
		(select count(*) 
		from 	legheader (NOLOCK)
		where 	lgh_startdate between Getdate() and dateAdd(d,1,Getdate())
			and lgh_outstatus in ('CMP','DSP','PLN','STD')
			AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)

			AND (@Only_mpp_teamleader =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @Only_mpp_teamleader) >0)
			AND (@Only_mpp_fleet =',,' or CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @Only_mpp_fleet) >0)
			AND (@Only_mpp_division =',,' or CHARINDEX(',' + RTRIM( mpp_division ) + ',', @Only_mpp_division) >0)
			AND (@Only_mpp_domicile =',,' or CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @Only_mpp_domicile) >0)
			AND (@Only_mpp_company =',,' or CHARINDEX(',' + RTRIM( mpp_company ) + ',', @Only_mpp_company) >0)
			AND (@Only_mpp_terminal =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @Only_mpp_terminal) >0)

			AND (@Only_mpp_type1 =',,' or CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @Only_mpp_type1) >0)
			AND (@Only_mpp_type2 =',,' or CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @Only_mpp_type2) >0)
			AND (@Only_mpp_type3 =',,' or CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @Only_mpp_type3) >0)
			AND (@Only_mpp_type4 =',,' or CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @Only_mpp_type4) >0)


			AND (@Only_trc_company =',,' or CHARINDEX(',' + RTRIM( trc_company ) + ',', @Only_trc_company) >0)
			AND (@Only_trc_division =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @Only_trc_division) >0)
			AND (@Only_trc_fleet =',,' or CHARINDEX(',' + RTRIM( trc_fleet ) + ',', @Only_trc_fleet) >0)
			AND (@Only_trc_terminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @Only_trc_terminal) >0)

			AND (@Only_trc_type1 =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @Only_trc_type1) >0)
			AND (@Only_trc_type2 =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @Only_trc_type2) >0)
			AND (@Only_trc_type3 =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @Only_trc_type3) >0)
			AND (@Only_trc_type4 =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @Only_trc_type4) >0)

		)


	IF ( abs( DateDiff(d, Getdate(),@DateStart))>1 )
	BEGIN
		Set @ThisTotal= 
			(Select DailyTotal from MetricDetail (NOLOCK) where MetricCode='Plan24Pct' and PlainDate =@DateStart)
		Set @ThisCount = 
			(Select DailyCount from MetricDetail (NOLOCK) where MetricCode='Plan24Pct' and PlainDate =@DateStart)
	END

	IF ( abs( DateDiff(d, Getdate(),@DateStart))<=1 )
	BEGIN

		SELECT @ThisTotal =@LegheaderCountNext24Hours
		SELECT @ThisCount = @LegheaderCountNext24HoursWithAssignments
	END 

END --StartDate = GetDate()
ELSE
BEGIN
	select @ThisTotal = dailytotal, @ThisCount = dailycount
	from metricdetail (NOLOCK)
	where plaindate = @datestart
		and @metriccode = metriccode
END

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

If @Showdetail = 1
BEGIN

		select 	ord_hdrnumber as [Order Number],
				lgh_startdate as [Start Date],
				lgh_outstatus as [Status] 
		from 	legheader (NOLOCK)
		where 	lgh_startdate between Getdate() and dateAdd(d,1,Getdate())
			and lgh_outstatus in ('CMP','DSP','PLN','STD','AVL')
			AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
			AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2list) >0)
			AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
			AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)

			AND (@Only_mpp_teamleader =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @Only_mpp_teamleader) >0)
			AND (@Only_mpp_fleet =',,' or CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @Only_mpp_fleet) >0)
			AND (@Only_mpp_division =',,' or CHARINDEX(',' + RTRIM( mpp_division ) + ',', @Only_mpp_division) >0)
			AND (@Only_mpp_domicile =',,' or CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @Only_mpp_domicile) >0)
			AND (@Only_mpp_company =',,' or CHARINDEX(',' + RTRIM( mpp_company ) + ',', @Only_mpp_company) >0)
			AND (@Only_mpp_terminal =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @Only_mpp_terminal) >0)

			AND (@Only_mpp_type1 =',,' or CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @Only_mpp_type1) >0)
			AND (@Only_mpp_type2 =',,' or CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @Only_mpp_type2) >0)
			AND (@Only_mpp_type3 =',,' or CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @Only_mpp_type3) >0)
			AND (@Only_mpp_type4 =',,' or CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @Only_mpp_type4) >0)


			AND (@Only_trc_company =',,' or CHARINDEX(',' + RTRIM( trc_company ) + ',', @Only_trc_company) >0)
			AND (@Only_trc_division =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @Only_trc_division) >0)
			AND (@Only_trc_fleet =',,' or CHARINDEX(',' + RTRIM( trc_fleet ) + ',', @Only_trc_fleet) >0)
			AND (@Only_trc_terminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @Only_trc_terminal) >0)

			AND (@Only_trc_type1 =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @Only_trc_type1) >0)
			AND (@Only_trc_type2 =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @Only_trc_type2) >0)
			AND (@Only_trc_type3 =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @Only_trc_type3) >0)
			AND (@Only_trc_type4 =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @Only_trc_type4) >0)
			AND lgh_number not in (
									select lgh_number
									from 	legheader (NOLOCK)
									where 	lgh_startdate between Getdate() and dateAdd(d,1,Getdate())
										and lgh_outstatus in ('CMP','DSP','PLN','STD')
										AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
										AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2list) >0)
										AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
										AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)
							
										AND (@Only_mpp_teamleader =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @Only_mpp_teamleader) >0)
										AND (@Only_mpp_fleet =',,' or CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @Only_mpp_fleet) >0)
										AND (@Only_mpp_division =',,' or CHARINDEX(',' + RTRIM( mpp_division ) + ',', @Only_mpp_division) >0)
										AND (@Only_mpp_domicile =',,' or CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @Only_mpp_domicile) >0)
										AND (@Only_mpp_company =',,' or CHARINDEX(',' + RTRIM( mpp_company ) + ',', @Only_mpp_company) >0)
										AND (@Only_mpp_terminal =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @Only_mpp_terminal) >0)
							
										AND (@Only_mpp_type1 =',,' or CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @Only_mpp_type1) >0)
										AND (@Only_mpp_type2 =',,' or CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @Only_mpp_type2) >0)
										AND (@Only_mpp_type3 =',,' or CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @Only_mpp_type3) >0)
										AND (@Only_mpp_type4 =',,' or CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @Only_mpp_type4) >0)
							
							
										AND (@Only_trc_company =',,' or CHARINDEX(',' + RTRIM( trc_company ) + ',', @Only_trc_company) >0)
										AND (@Only_trc_division =',,' or CHARINDEX(',' + RTRIM( trc_division ) + ',', @Only_trc_division) >0)
										AND (@Only_trc_fleet =',,' or CHARINDEX(',' + RTRIM( trc_fleet ) + ',', @Only_trc_fleet) >0)
										AND (@Only_trc_terminal =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @Only_trc_terminal) >0)
							
										AND (@Only_trc_type1 =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @Only_trc_type1) >0)
										AND (@Only_trc_type2 =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @Only_trc_type2) >0)
										AND (@Only_trc_type3 =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @Only_trc_type3) >0)
										AND (@Only_trc_type4 =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @Only_trc_type4) >0)




									)
END	

GO
GRANT EXECUTE ON  [dbo].[Metric_Plan24Pct] TO [public]
GO
