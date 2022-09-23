SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE      PROCEDURE [dbo].[Metric_GeoOrderCount] 
(
	--Standard Parameters
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	--Additional/Optional Parameters
	@MetricCode varchar(200) = '',
	@StateOrRegionMode varchar(10)='State', --Region1, Region2, Region3, Region4
	@OnlyIncludeStateList varchar(128) ='',
	@OnlyIncludeRegion1List varchar(255)='',
	@OnlyIncludeRegion2List varchar(255)='',
	@OnlyIncludeRegion3List varchar(255)='',
	@OnlyIncludeRegion4List varchar(255)='',
	@DateType varchar(128) = 'Delivery',
	@AssignAreaMode varchar(10)= 'Start', --  End
	@DaysRange int = 30,
	@OnlyRevClass1List varchar(128) ='',
	@OnlyRevClass2List varchar(128) ='',
	@OnlyRevClass3List varchar(128) ='',
	@OnlyRevClass4List varchar(128) ='',
    @OrderStatus varchar(255)='',
    @OnlyBookedBy varchar(255)='',
	@OnlyDriverID varchar(255)='', 
	@OnlyDrvType1List varchar(255)='',
	@OnlyDrvType2List varchar(255)='',
	@OnlyDrvType3List varchar(255)='',
	@OnlyDrvType4List varchar(255)='',
	@OnlyShipperList varchar(128)='',
	@OnlyConsigneeList varchar(128)='',
	@OrderTrailerType1 varchar(255)='',
	@OnlyTrcTerminalList varchar(255)='',
	@OnlyShipperRevType1List varchar(128)='',
	@OnlyShipperRevType2List varchar(128)='',
	@OnlyShipperRevType3List varchar(128)='',
	@OnlyShipperRevType4List varchar(128)='',
	@OnlyConsigneeRevType1List varchar(128)='',
	@OnlyConsigneeRevType2List varchar(128)='',
	@OnlyConsigneeRevType3List varchar(128)='',
	@OnlyConsigneeRevType4List varchar(128)='',
	@SortByMode varchar(20)='Order', --Order, RevType1
	@Mode varchar(20)='ALL', --ALL, UnBilled
	@OnlyDrvTerminalList varchar(255)=''
)
AS

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	This example creates two metric based on one stored procedure. (The only difference is the cumulative flag.)
	Typically, only one MetricInitializeItem is necessary.
	

	EXEC MetricInitializeItem
		@sMetricCode = 'GeoOrderCount',
		@nActive = 1,	-- 1=active, 0=inactive.
		@nSort = 105, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 1,
		@sCaption = 'Orders booked',
		@sCaptionFull = 'Orders booked',
		@sProcedureName = 'Metric_GeoOrderCount',
		-- @sDetailFilename	= '',	
		-- @sThresholdAlertEmailAddress = '',  
		-- @nThresholdAlertValue = 0, 
		-- @sThresholdOperator = '',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = 'ProcessOnly'

*/

	IF IsNull(@DateStart,GetDate()) < DateAdd(d, -1, GetDate()) And @ShowDetail = 0
		RETURN

	SET NOCOUNT ON

	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','
	Set @OrderStatus = ',' + ISNULL(@OrderStatus,'') + ','
    Set @OnlyBookedBy = ',' + ISNULL(@OnlyBookedBy,'') + ','
  
	Set @OnlyDriverID = ',' + ISNULL(@OnlyDriverID,'') + ','  

	Set @OnlyDrvType1List= ',' + ISNULL(@OnlyDrvType1List,'') + ','
	Set @OnlyDrvType2List= ',' + ISNULL(@OnlyDrvType2List,'') + ','
	Set @OnlyDrvType3List= ',' + ISNULL(@OnlyDrvType3List,'') + ','
	Set @OnlyDrvType4List= ',' + ISNULL(@OnlyDrvType4List,'') + ','

	Set @OnlyShipperList= ',' + ISNULL(@OnlyShipperList,'') + ','
	Set @OnlyConsigneeList= ',' + ISNULL(@OnlyConsigneeList,'') + ','
	
	Set @OrderTrailerType1 = ',' + ISNULL(@OrderTrailerType1,'') + ',' 
	Set @OnlyTrcTerminalList = ',' + ISNULL(@OnlyTrcTerminalList,'') + ','

	Set @OnlyShipperRevType1List = ',' + ISNULL(@OnlyShipperRevType1List,'') + ','
	Set @OnlyShipperRevType2List = ',' + ISNULL(@OnlyShipperRevType2List,'') + ','
	Set @OnlyShipperRevType3List = ',' + ISNULL(@OnlyShipperRevType3List,'') + ','
	Set @OnlyShipperRevType4List = ',' + ISNULL(@OnlyShipperRevType4List,'') + ','

	Set @OnlyConsigneeRevType1List = ',' + ISNULL(@OnlyConsigneeRevType1List,'') + ','
	Set @OnlyConsigneeRevType2List = ',' + ISNULL(@OnlyConsigneeRevType2List,'') + ','
	Set @OnlyConsigneeRevType3List = ',' + ISNULL(@OnlyConsigneeRevType3List,'') + ','
	Set @OnlyConsigneeRevType4List = ',' + ISNULL(@OnlyConsigneeRevType4List,'') + ','	
	Set @OnlyDrvTerminalList = ',' + ISNULL(@OnlyDrvTerminalList,'') + ','

	Set @OnlyIncludeStateList = ',' + ISNULL(@OnlyIncludeStateList ,'') + ','
	Set @OnlyIncludeRegion1List = ',' + ISNULL(@OnlyIncludeRegion1List ,'') + ','
	Set @OnlyIncludeRegion2List = ',' + ISNULL(@OnlyIncludeRegion2List ,'') + ','
	Set @OnlyIncludeRegion3List = ',' + ISNULL(@OnlyIncludeRegion3List ,'') + ','
	Set @OnlyIncludeRegion4List = ',' + ISNULL(@OnlyIncludeRegion4List ,'') + ','
	
IF @ShowDetail < 2
	BEGIN --UPDATE CACHE
	SELECT 	ord_number, 
			'Driver' = ISNULL((select top 1 lgh_driver1 from legheader (NOLOCK) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber group by lgh_enddate , lgh_driver1 order by lgh_enddate desc), 'Unknown'), 
			ord_revtype1 as [RevType1],
			ord_revtype2 as [RevType2],
			ord_revtype3 as [RevType3],
			ord_revtype4 as [RevType4],
			ord_shipper,
			ord_consignee,
			ShipperCompany.cmp_revtype1 as ShipperRevType1,
			ConsigneeCompany.cmp_revtype1 as ConsigneeRevType1,
			ord_company, 
			ord_bookedby, 
			ord_status,
			'DriverType4' = ISNULL((select top 1 mpp_type4 from legheader (NOLOCK) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber group by lgh_enddate, mpp_type4 order by lgh_enddate desc), 'Unknown'), 
			StartCityState =	(
							select left(cty_name,10)+ ', ' +cty_state 
							from city (NOLOCK) 
							where ord_origincity = cty_code 
						),
			StartState =	(
							select cty_state 
							from city (NOLOCK) 
							where ord_origincity = cty_code
						),
			StartRegion1=	(
							select cty_region1 
							from city (NOLOCK) 
							where ord_origincity = cty_code
						),
			StartRegion2=	(
							select cty_region2 
							from city (NOLOCK) 
							where ord_origincity = cty_code
						),
			StartRegion3=	(
							select cty_region3 
							from city (NOLOCK) 
							where ord_origincity = cty_code
						),
			StartRegion4=	(
							select cty_region4 
							from city (NOLOCK) 
							where ord_origincity = cty_code
						),
			EndCityState =	(
							select left(cty_name,10)+ ', ' +cty_state 
							from city (NOLOCK) 
							where ord_destcity= cty_code
						),
			EndState =	(
							select cty_state 
							from city (NOLOCK) 
							where ord_destcity = cty_code
						),
			EndRegion1=	(
							select cty_region1 
							from city (NOLOCK) 
							where ord_destcity = cty_code
						),
			EndRegion2=	(
							select cty_region2 
							from city (NOLOCK) 
							where ord_destcity = cty_code
						),
			EndRegion3=	(
							select cty_region3 
							from city (NOLOCK) 
							where ord_destcity = cty_code
						),
			EndRegion4=	(
							select cty_region4 
							from city (NOLOCK) 
							where ord_destcity = cty_code
						),
			ord_description
	INTO #OrderHeader
	FROM orderheader (NoLock)
		JOIN Company ShipperCompany (NOLOCK) on ord_shipper = ShipperCompany.cmp_id
		JOIN Company ConsigneeCompany (NOLOCK) on ord_consignee = ConsigneeCompany.cmp_id
	WHERE 	(	
				(@DateType = 'Ship' and ord_startdate >= DateAdd(d, -(@DaysRange -1), @DateStart) AND ord_startdate < @DateEnd)
			 		Or
				(@DateType = 'Book' and ord_bookdate >= DateAdd(d, -(@DaysRange -1), @DateStart) AND ord_bookdate < @DateEnd)
		     		Or
				(@DateType = 'Delivery' and ord_completiondate >= DateAdd(d, -(@DaysRange -1), @DateStart) AND ord_completiondate < @DateEnd
						AND ord_status = 'CMP')
			)
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
		AND (@OnlyShipperRevType1List =',,' or CHARINDEX(',' + RTRIM( ShipperCompany.cmp_revtype1 ) + ',', @OnlyShipperRevType1List) >0)
		AND (@OnlyShipperRevType2List =',,' or CHARINDEX(',' + RTRIM( ShipperCompany.cmp_revtype2 ) + ',', @OnlyShipperRevType2List) >0)
		AND (@OnlyShipperRevType3List =',,' or CHARINDEX(',' + RTRIM( ShipperCompany.cmp_revtype3 ) + ',', @OnlyShipperRevType3List) >0)
		AND (@OnlyShipperRevType4List =',,' or CHARINDEX(',' + RTRIM( ShipperCompany.cmp_revtype4 ) + ',', @OnlyShipperRevType4List) >0)
		AND (@OnlyConsigneeRevType1List =',,' or CHARINDEX(',' + RTRIM( ConsigneeCompany.cmp_revtype1 ) + ',', @OnlyConsigneeRevType1List) >0)
		AND (@OnlyConsigneeRevType2List =',,' or CHARINDEX(',' + RTRIM( ConsigneeCompany.cmp_revtype2 ) + ',', @OnlyConsigneeRevType2List) >0)
		AND (@OnlyConsigneeRevType3List =',,' or CHARINDEX(',' + RTRIM( ConsigneeCompany.cmp_revtype3 ) + ',', @OnlyConsigneeRevType3List) >0)
		AND (@OnlyConsigneeRevType4List =',,' or CHARINDEX(',' + RTRIM( ConsigneeCompany.cmp_revtype4 ) + ',', @OnlyConsigneeRevType4List) >0)
		AND ord_status Not IN ('MST','CAN')
		AND (@OrderStatus =',,' or CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatus) >0)
		AND (@OnlyBookedBy =',,' or CHARINDEX(',' + RTRIM( ord_bookedby ) + ',', @OnlyBookedBy) >0)
        AND (@OnlyDriverID =',,' or CHARINDEX(',' + RTRIM( ISNULL((select top 1 lgh_driver1 from legheader (NOLOCK) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber group by lgh_enddate , lgh_driver1 order by lgh_enddate desc), 'Unknown') ) + ',', @OnlyDriverID) >0) 
		AND (@OnlyDrvType1List =',,' or CHARINDEX(',' + RTRIM( (select top 1 mpp_type1 from legheader (nolock) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber group by lgh_enddate, mpp_type1 order by lgh_enddate desc) ) + ',', @OnlyDrvType1List) >0)
		AND (@OnlyDrvType2List =',,' or CHARINDEX(',' + RTRIM( (select top 1 mpp_type2 from legheader (nolock) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber group by lgh_enddate, mpp_type2 order by lgh_enddate desc) ) + ',', @OnlyDrvType2List) >0)
		AND (@OnlyDrvType3List =',,' or CHARINDEX(',' + RTRIM( (select top 1 mpp_type3 from legheader (nolock) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber group by lgh_enddate, mpp_type3 order by lgh_enddate desc) ) + ',', @OnlyDrvType3List) >0)
		AND (@OnlyDrvType4List =',,' or CHARINDEX(',' + RTRIM( (select top 1 mpp_type4 from legheader (nolock) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber group by lgh_enddate, mpp_type4 order by lgh_enddate desc) ) + ',', @OnlyDrvType4List) >0)
		AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + RTRIM( (select top 1 mpp_terminal from legheader (nolock) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber group by lgh_enddate, mpp_terminal order by lgh_enddate desc) ) + ',', @OnlyDrvTerminalList) >0)
		AND (@OnlyShipperList =',,' or CHARINDEX(',' + RTRIM( ord_shipper ) + ',', @OnlyShipperList) >0)
		AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + RTRIM( ord_consignee ) + ',', @OnlyConsigneeList) >0)										
		AND (@OrderTrailerType1 =',,' or CHARINDEX(',' + RTRIM( orderheader.trl_type1 ) + ',', @OrderTrailerType1) >0)                  
		AND (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + RTRIM( ISNULL((select top 1 trc_terminal from legheader (NOLOCK) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber group by lgh_enddate, trc_terminal order by lgh_enddate desc), 'Unknown') ) + ',', @OnlyTrcTerminalList) >0) 
		AND (@Mode = 'ALL' OR @Mode = 'UnBilled' AND ord_number Not In (SELECT cast(ISNULL(ord_hdrnumber,0) as varchar(12)) from InvoiceHeader (NOLOCK)))
		AND (@OnlyIncludeStateList =',,' or @StateOrRegionMode <> 'STATE' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( ord_DestState) + ',', @OnlyIncludeStateList) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(ord_OriginState ) + ',', @OnlyIncludeStateList) >0)
		AND (@OnlyIncludeRegion1List =',,' or @StateOrRegionMode <> 'REGION1' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( ord_DestRegion1) + ',', @OnlyIncludeRegion1List) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(ord_OriginRegion1 ) + ',', @OnlyIncludeRegion1List) >0)
		AND (@OnlyIncludeRegion2List =',,' or @StateOrRegionMode <> 'REGION2' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( ord_DestRegion2) + ',', @OnlyIncludeRegion2List) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(ord_OriginRegion2 ) + ',', @OnlyIncludeRegion2List) >0)
		AND (@OnlyIncludeRegion3List =',,' or @StateOrRegionMode <> 'REGION3' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( ord_DestRegion3) + ',', @OnlyIncludeRegion3List) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(ord_OriginRegion3 ) + ',', @OnlyIncludeRegion3List) >0)
		AND (@OnlyIncludeRegion4List =',,' or @StateOrRegionMode <> 'REGION4' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( ord_DestRegion4) + ',', @OnlyIncludeRegion4List) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(ord_OriginRegion4 ) + ',', @OnlyIncludeRegion4List) >0)
		
	    IF DATEDIFF(day, @DateStart, @DateEnd) < 2 And @ShowDetail = 0
			BEGIN
			DELETE RNMap_Cache_Values WHERE MetricCode = @MetricCode And DateDiff(d, @DateStart,  PlainDate) = 0

			IF @StateOrRegionMode = 'State' 
				BEGIN
				INSERT INTO RNMap_Cache_Values (PlainDate, MetricCode, Area, DailyCount1, DailyTotal1, DailyCount2, DailyTotal2, DailyCount3, DailyTotal3)
				(SELECT distinct @Datestart, @MetricCode, cty_state as Area, 0,0,0,0,0,0
				from city (NOLOCK) )
				IF @AssignAreaMode = 'Start'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = (Select COUNT(*) FROM #orderheader WHERE StartState = Area),
						DailyTotal1 = 1
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = (Select COUNT(*) FROM #orderheader WHERE EndState = Area),
						DailyTotal1 = 1
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				END
			ELSE IF @StateOrRegionMode = 'Region1' 
				BEGIN
				INSERT INTO RNMap_Cache_Values (PlainDate, MetricCode, Area, DailyCount1, DailyTotal1, DailyCount2, DailyTotal2, DailyCount3, DailyTotal3)
				(SELECT distinct @Datestart, @MetricCode, cty_Region1 as Area, 0,0,0,0,0,0
				from city (NOLOCK) )
				IF @AssignAreaMode = 'Start'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = (Select COUNT(*) FROM #orderheader WHERE StartRegion1 = Area),
						DailyTotal1 = 1
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = (Select COUNT(*) FROM #orderheader WHERE EndRegion1 = Area),
						DailyTotal1 = 1
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				END
			ELSE IF @StateOrRegionMode = 'Region2' 
				BEGIN
				INSERT INTO RNMap_Cache_Values (PlainDate, MetricCode, Area, DailyCount1, DailyTotal1, DailyCount2, DailyTotal2, DailyCount3, DailyTotal3)
				(SELECT distinct @Datestart, @MetricCode, cty_Region2 as Area, 0,0,0,0,0,0
				from city (NOLOCK) )
	
				IF @AssignAreaMode = 'Start'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = (Select COUNT(*) FROM #orderheader WHERE StartRegion2 = Area),
						DailyTotal1 = 1
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = (Select COUNT(*) FROM #orderheader WHERE EndRegion2 = Area),
						DailyTotal1 = 1
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				END
			ELSE IF @StateOrRegionMode = 'Region3' 
				BEGIN
				INSERT INTO RNMap_Cache_Values (PlainDate, MetricCode, Area, DailyCount1, DailyTotal1, DailyCount2, DailyTotal2, DailyCount3, DailyTotal3)
				(SELECT distinct @Datestart, @MetricCode, cty_Region3 as Area, 0,0,0,0,0,0
				from city (NOLOCK) )
	
				IF @AssignAreaMode = 'Start'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = (Select COUNT(*) FROM #orderheader WHERE StartRegion3 = Area),
						DailyTotal1 = 1
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = (Select COUNT(*) FROM #orderheader WHERE EndRegion3 = Area),
						DailyTotal1 = 1
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				END  
			ELSE IF @StateOrRegionMode = 'Region4' 
				BEGIN
				INSERT INTO RNMap_Cache_Values (PlainDate, MetricCode, Area, DailyCount1, DailyTotal1, DailyCount2, DailyTotal2, DailyCount3, DailyTotal3)
				(SELECT distinct @Datestart, @MetricCode, cty_Region4 as Area, 0,0,0,0,0,0
				from city (NOLOCK) )
				IF @AssignAreaMode = 'Start'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = (Select COUNT(*) FROM #orderheader WHERE StartRegion4 = Area),
						DailyTotal1 = 1
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = (Select COUNT(*) FROM #orderheader WHERE EndRegion4 = Area),
						DailyTotal1 = 1
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
			END  -- state, regions
		END -- update cache
	END -- showdetail < 2 so create temptable


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 
	IF (@ShowDetail = 1)
	BEGIN
		If @SortByMode = 'Order'
			BEGIN
			SELECT * FROM #OrderHeader
				Order By ord_number
	     	END
		ELSE
			BEGIN
			SELECT * FROM #OrderHeader
				Order By [RevType1], ord_number
	     	END
	END
	
	
	If @ShowDetail = 2
		SELECT DISTINCT Area, Convert(Int,CASE Sum(ISNULL(DailyTotal1, 0)) WHEN 0 THEN NULL ELSE Sum(ISNULL(DailyCount1,0))/ Sum(ISNULL(DailyTotal1, 0)) END) as DailyValue1, Convert(Int,CASE Sum(ISNULL(DailyTotal2, 0)) WHEN 0 THEN NULL ELSE Sum(ISNULL(DailyCount2,0))/ Sum(ISNULL(DailyTotal2, 0)) END) as DailyValue2
		FROM RNMap_Cache_Values RNMC1 (NOLOCK) 
		WHERE metriccode = @MetricCode And RNMC1.PlainDate = (Select Max(RNMC2.PlainDate) From RNMap_Cache_Values RNMC2 (NOLOCK) WHERE RNMC1.metriccode = RNMC2.metriccode) 
		GROUP BY Area


	Set @ThisCount = 1
	Set @ThisTotal = 1
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END	

GO
GRANT EXECUTE ON  [dbo].[Metric_GeoOrderCount] TO [public]
GO
