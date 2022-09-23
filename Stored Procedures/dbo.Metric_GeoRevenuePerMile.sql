SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[Metric_GeoRevenuePerMile]

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
	@StateOrRegionMode varchar(10)='State', --Region1, Region2
	@OnlyIncludeStateList varchar(128) ='',
	@OnlyIncludeRegion1List varchar(255)='',
	@OnlyIncludeRegion2List varchar(255)='',
	@OnlyIncludeRegion3List varchar(255)='',
	@OnlyIncludeRegion4List varchar(255)='',
	@DateType varchar(50) = 'End', -- OR Start,Book, Ship, Delivery
	@AssignAreaMode varchar(10)= 'Start', --  End
	@DaysRange int = 30,
	@LineHaulRevenueOnlyYN char(1) ='N',
	@OnlyRevenueFromChargeTypesYN char(1) = 'N',
	@OnlyRevClass1List varchar(255) ='',
	@OnlyRevClass2List varchar(255) ='',
	@OnlyRevClass3List varchar(255) ='',
	@OnlyRevClass4List varchar(255) ='',
	@OnlyMppType1List varchar(255) ='',
	@OnlyMppType2List varchar(255) ='',
	@OnlyMppType3List varchar(255) ='',
	@OnlyMppType4List varchar(255) ='',
	@OnlyTrcClass1List varchar(255) = '',
	@OnlyTrcClass2List varchar(255) = '',
	@OnlyTrcClass3List varchar(255) = '',
	@OnlyTrcClass4List varchar(255) = '',
	@OnlyTrcTerminalList varchar(255) = '',
	@ExcludeChargeTypeList varchar(255)='',		  -- For line haul.
	@IncludeChargeTypeListOnly varchar(255) = '', -- For line haul.
	@DispatchStatusList varchar(128) = '',
	@OrderStatusList varchar(128) = '',
	@EliminateMilesYN char(1) = 'N',  -- This is to use the same revenue logic for Daily Revenue.  (i.e. set @ThisTotal = 1)
	@ExcludeZeroChargeYN char(1) = 'N', -- Used to remove Zero Charges from metric calculations
	@OnlyTeamLeaderList varchar(255) = '', -- Used to include only selected Team Leaders
	@DaysBackToStartEstimate int = 45,
	@DaysBackToEndEstimate int = 15,
	@DefaultEstimateAmount money = 35,
    @OnlyBookedBy varchar(255) = '', -- Used to include only orders booked by selection
	@MilesMode varchar(128)='Travel', -- Travel, Billed, NonBilled
	@LoadedStatus varchar(3)='ALL', -- All, LD, MT
	@InvoicedOrdersOnlyYN char(1) = 'N',
	@OnlyShipperList varchar(128)='',
	@OnlyConsigneeList varchar(128)='',
	@OrderTrailerType1 varchar(255)='',
	@AccRevenueOnlyYN char(1) = 'N',
	@OnlyOrderSubCompanyList VARCHAR(128)='',
	@OnlyCarrierLoadsYN VARCHAR(1)='N'
	)
AS
/*

declare
	@Result decimal(20, 5) , 
	@ThisCount decimal(20, 5) , 
	@ThisTotal decimal(20, 5) , 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int

set @ShowDetail =0
set @DateStart = '07/18/05'
set @DateEnd = '07/19/05'

Declare
	@OnlyIncludeStateList varchar(128) ,
	@MetricCode varchar(200) ,
	@StateOrRegionMode varchar(10), --Region1 
	@OnlyIncludeRegion1List varchar(255)

SET	@MetricCode = 'GeoRevenue'
SET	@StateOrRegionMode ='State' --Region1 
SET	@OnlyIncludeRegion1List =''
SET	@OnlyIncludeStateList  =''

*/


	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'GeoRevenuePerMile', 
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 701, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'GeoRevPerMile',
		@sCaptionFull = 'Geographic based Revenue Per Mile',
		@sProcedureName = 'Metric_GeoRevenuePerMile',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = 'ProcessOnly'

	</METRIC-INSERT-SQL>
*/


	IF IsNull(@DateStart,GetDate()) < DateAdd(d, -1, GetDate()) And @ShowDetail = 0
		RETURN

	SET NOCOUNT ON
	
--Local Variable Declaration
	
	Declare @Miles Float
	Declare @StopStatusList varchar(255)
	Declare @currdate datetime
		
	--Standard Parameter Initialization
	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	Set @OnlyMppType1List= ',' + ISNULL(@OnlyMppType1List,'') + ','
	Set @OnlyMppType2List= ',' + ISNULL(@OnlyMppType2List,'') + ','
	Set @OnlyMppType3List= ',' + ISNULL(@OnlyMppType3List,'') + ','
	Set @OnlyMppType4List= ',' + ISNULL(@OnlyMppType4List,'') + ','

	Set @OnlyTrcClass1List= ',' + ISNULL(@OnlyTrcClass1List,'') + ','
	Set @OnlyTrcClass2List= ',' + ISNULL(@OnlyTrcClass2List,'') + ','
	Set @OnlyTrcClass3List= ',' + ISNULL(@OnlyTrcClass3List,'') + ','
	Set @OnlyTrcClass4List= ',' + ISNULL(@OnlyTrcClass4List,'') + ','

	Set @OnlyTrcTerminalList= ',' + ISNULL(@OnlyTrcTerminalList,'') + ','
	Set @ExcludeChargeTypeList = ',' + ISNULL(@ExcludeChargeTypeList,'') + ','
	Set @IncludeChargeTypeListOnly = ',' + ISNULL(@IncludeChargeTypeListOnly,'') + ','
	Set @OrderStatusList = ',' + ISNULL(@OrderStatusList,'') + ','
	Set @StopStatusList = ',' + ISNULL(@StopStatusList,'') + ','
	Set @OnlyTeamLeaderList = ',' + ISNULL(@OnlyTeamLeaderList,'') + ','
	Set @DispatchStatusList = ',' + ISNULL(@DispatchStatusList,'') + ','
	Set @OnlyBookedBy = ',' + ISNULL(@OnlyBookedBy,'') + ','
	Set @OnlyShipperList= ',' + ISNULL(@OnlyShipperList,'') + ','
	Set @OnlyConsigneeList= ',' + ISNULL(@OnlyConsigneeList,'') + ','

	Set @OrderTrailerType1 = ',' + ISNULL(@OrderTrailerType1,'') + ',' 
	SET @OnlyOrderSubCompanyList = ',' + ISNULL(@OnlyOrderSubCompanyList,'') + ','

	Set @OnlyIncludeStateList = ',' + ISNULL(@OnlyIncludeStateList ,'') + ','
	Set @OnlyIncludeRegion1List = ',' + ISNULL(@OnlyIncludeRegion1List ,'') + ','
	Set @OnlyIncludeRegion2List = ',' + ISNULL(@OnlyIncludeRegion2List ,'') + ','
	Set @OnlyIncludeRegion3List = ',' + ISNULL(@OnlyIncludeRegion3List ,'') + ','
	Set @OnlyIncludeRegion4List = ',' + ISNULL(@OnlyIncludeRegion4List ,'') + ','

IF @ShowDetail < 2
	BEGIN --UPDATE CACHE
	Select 
		l.ord_hdrnumber as [Order Number],
		'Not Invoiced' as [Invoice Number],
		l.mov_number as [Move Number],	
		lgh_startcty_nmstct as [Start City,State],
		lgh_endcty_nmstct as [End City,State],
		lgh_startdate as [Start Date],	
		lgh_enddate as [End Date],	
		[TotalCharge] = IsNull(dbo.fnc_TMWRN_Revenue('Segment',Null,Null,L.mov_number,Null,L.lgh_number,Null,@IncludeChargeTypeListOnly,@ExcludeChargeTypeList,'','','','','','',''),0),
	    [LineHaulRevenue] = IsNull(dbo.fnc_TMWRN_Revenue('Segment',Null,Null,L.mov_number,Null,L.lgh_number,Null,@IncludeChargeTypeListOnly,@ExcludeChargeTypeList,'Y','','','','','',''),0),				 
		Case When @OnlyRevenueFromChargeTypesYN = 'Y' Then
			IsNull(dbo.fnc_TMWRN_Revenue('Segment',Null,Null,L.mov_number,NULL,L.lgh_number,Null,@IncludeChargeTypeListOnly,@ExcludeChargeTypeList,'',@AccRevenueOnlyYN,@OnlyRevenueFromChargeTypesYN,'','','',''),0)
		Else
			NULL
		End as ChargeTypeListCharge,
		ISNULL(lgh_carrier,'UNKNOWN') CarrierID,
		ISNULL(lgh_tractor,'UNKNOWN') TractorID,
		ISNULL(lgh_driver1,'UNKNOWN') DriverID,
		IsNull(dbo.fnc_TMWRN_Miles('Segment','Billed','Miles',l.mov_number,default,l.lgh_number,default,default,default,default,default),0) as BillableMiles,
		IsNull(dbo.fnc_TMWRN_Miles('Segment','Travel','Miles',l.mov_number,default,l.lgh_number,default,default,default,default,default),0) as TravelMiles,
		IsNull(dbo.fnc_TMWRN_Miles('Segment',@MilesMode,'Miles',l.mov_number,default,l.lgh_number,default,@LoadedStatus,default,default,default),0) as CalcMiles,
		lgh_outstatus as [Dispatch Status],
		ord_shipper as Shipper,
		ord_consignee as Consignee,
		O.ord_billto    as [Bill To],
		StartCityState =	(
						select left(cty_name,10)+ ', ' +cty_state 
						from city (NOLOCK) 
						where lgh_startcity = cty_code
					),
		StartState =	(
						select cty_state 
						from city (NOLOCK) 
						where lgh_startcity = cty_code
					),
		StartRegion1=	(
						select cty_region1 
						from city (NOLOCK) 
						where lgh_startcity = cty_code
					),
		StartRegion2=	(
						select cty_region2 
						from city (NOLOCK) 
						where lgh_startcity = cty_code
					),
		StartRegion3=	(
						select cty_region3 
						from city (NOLOCK) 
						where lgh_startcity = cty_code
					),
		StartRegion4=	(
						select cty_region4 
						from city (NOLOCK) 
						where lgh_startcity = cty_code
					),
		EndCityState =	(
						select left(cty_name,10)+ ', ' +cty_state 
						from city (NOLOCK) 
						where lgh_endcity = cty_code
					),
		EndState =	(
						select cty_state 
						from city (NOLOCK) 
						where lgh_endcity = cty_code
					),
		EndRegion1=	(
						select cty_region1 
						from city (NOLOCK) 
						where lgh_endcity = cty_code
					),
		EndRegion2=	(
						select cty_region2 
						from city (NOLOCK) 
						where lgh_endcity = cty_code
					),
		EndRegion3=	(
						select cty_region3 
						from city (NOLOCK) 
						where lgh_endcity = cty_code
					),
		EndRegion4=	(
						select cty_region4 
						from city (NOLOCK) 
						where lgh_endcity = cty_code
					)
	into    #LegHeader
	FROM  	Legheader L (NOLOCK) Left Join OrderHeader O (NOLOCK) On L.ord_hdrnumber = O.ord_hdrnumber
	where	(
		  		(@DateType = 'Start' and lgh_startdate >= DateAdd(d, -(@DaysRange -1), @DateStart) AND lgh_startdate < @DateEnd)
		   	 		Or
		  		(@DateType = 'End' And lgh_enddate >= DateAdd(d, -(@DaysRange -1), @DateStart) AND lgh_enddate < @DateEnd)
					OR
		  		(@DateType = 'Book' and ord_bookdate >= DateAdd(d, -(@DaysRange -1), @DateStart) AND ord_bookdate < @DateEnd)
					OR
		  		(@DateType = 'Ship' and ord_startdate >= DateAdd(d, -(@DaysRange -1), @DateStart) AND ord_startdate < @DateEnd)
		   			OR
		  		(@DateType = 'Delivery' and ord_completiondate >= DateAdd(d, -(@DaysRange -1), @DateStart) AND ord_completiondate < @DateEnd)	
		 	)
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( lgh_class1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( lgh_class2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( lgh_class3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( lgh_class4 ) + ',', @OnlyRevClass4List) >0)
		AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trc_type1 ) + ',', @OnlyTrcClass1List) >0)
		AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trc_type2 ) + ',', @OnlyTrcClass2List) >0)
		AND (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trc_type3 ) + ',', @OnlyTrcClass3List) >0)
		AND (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trc_type4 ) + ',', @OnlyTrcClass4List) >0)
		AND (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + RTRIM( trc_terminal ) + ',', @OnlyTrcTerminalList) >0)
		AND (@OnlyMppType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyMppType1List) >0)
		AND (@OnlyMppType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyMppType2List) >0)
		AND (@OnlyMppType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyMppType3List) >0)
		AND (@OnlyMppType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyMppType4List) >0)
		AND ((@OnlyCarrierLoadsYN = 'Y' AND lgh_carrier <> 'UNKNOWN')
				OR
			 (@OnlyCarrierLoadsYN = 'N')
			) 
			
		AND (@OnlyTeamLeaderList= ',,'  or CHARINDEX(',' + RTRIM( l.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
		AND L.lgh_outstatus <> 'CAN'	
		AND (@DispatchStatusList =',,' or CHARINDEX(',' + RTRIM( lgh_outstatus ) + ',', @DispatchStatusList) >0)
        	AND (@OnlyBookedBy= ',,'  or CHARINDEX(',' + RTRIM( O.ord_bookedby ) + ',', @OnlyBookedBy) >0)	
		AND (@OnlyShipperList =',,' or CHARINDEX(',' + RTRIM( ord_shipper ) + ',', @OnlyShipperList) >0)
		AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + RTRIM( ord_consignee ) + ',', @OnlyConsigneeList) >0)							
		AND (@OrderTrailerType1 =',,' or CHARINDEX(',' + RTRIM( O.trl_type1 ) + ',', @OrderTrailerType1) >0)                  
		AND (@OrderStatusList =',,' or CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatusList) >0)
		AND (@OnlyOrderSubCompanyList=',,' OR CHARINDEX(',' + RTRIM( ord_subcompany ) + ',', @OnlyOrderSubCompanyList) >0)
		AND (@OnlyIncludeStateList =',,' or @StateOrRegionMode <> 'STATE' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( lgh_EndState) + ',', @OnlyIncludeStateList) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(lgh_StartState ) + ',', @OnlyIncludeStateList) >0)
		AND (@OnlyIncludeRegion1List =',,' or @StateOrRegionMode <> 'REGION1' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( lgh_EndRegion1) + ',', @OnlyIncludeRegion1List) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(lgh_StartRegion1 ) + ',', @OnlyIncludeRegion1List) >0)
		AND (@OnlyIncludeRegion2List =',,' or @StateOrRegionMode <> 'REGION2' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( lgh_EndRegion2) + ',', @OnlyIncludeRegion2List) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(lgh_StartRegion2 ) + ',', @OnlyIncludeRegion2List) >0)
		AND (@OnlyIncludeRegion3List =',,' or @StateOrRegionMode <> 'REGION3' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( lgh_EndRegion3) + ',', @OnlyIncludeRegion3List) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(lgh_StartRegion3 ) + ',', @OnlyIncludeRegion3List) >0)
		AND (@OnlyIncludeRegion4List =',,' or @StateOrRegionMode <> 'REGION4' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( lgh_EndRegion4) + ',', @OnlyIncludeRegion4List) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(lgh_StartRegion4 ) + ',', @OnlyIncludeRegion4List) >0)
	
		
	IF @InvoicedOrdersOnlyYN = 'Y'
		DELETE FROM #LegHeader WHERE NOT EXISTS (SELECT * FROM invoiceheader where ord_number = [Order Number])
	
	UPDATE #LegHeader
	SET [Invoice Number] = I.ivh_invoicenumber
	FROM invoiceheader I (NOLOCK)
	WHERE [Order Number] = I.ord_hdrnumber

	--lbric 8/20/04 Remove Zero Charge
	IF (@ExcludeZeroChargeYN = 'Y')
	BEGIN
		DELETE #LegHeader where IsNull(TotalCharge,0) = 0
	END	


	    IF DATEDIFF(day, @DateStart, @DateEnd) < 2 And @ShowDetail = 0
			BEGIN
			DELETE RNMap_Cache_Values WHERE MetricCode = @MetricCode And @DateStart = PlainDate
			IF @StateOrRegionMode = 'State' 
				BEGIN
				INSERT INTO RNMap_Cache_Values (PlainDate, MetricCode, Area, DailyCount1, DailyTotal1, DailyCount2, DailyTotal2, DailyCount3, DailyTotal3)
				(SELECT distinct @Datestart, @MetricCode, cty_state as Area, 0,0,0,0,0,0
				from city (NOLOCK) )
	
				IF @AssignAreaMode = 'Start'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = IsNull(CASE WHEN @LineHaulRevenueOnlyYN ='Y' THEN
												(Select sum(IsNull(LineHaulRevenue,0)) from #LegHeader WHERE StartState = Area)
											WHEN @OnlyRevenueFromChargeTypesYN = 'Y' THEN
												(Select sum(IsNull(ChargeTypeListCharge,0)) from #LegHeader WHERE StartState = Area) 
											ELSE 
												(Select sum(IsNull(TotalCharge,0)) from #LegHeader WHERE StartState = Area) 
									  		END,0),
						DailyTotal1 = IsNull(CASE WHEN @EliminateMilesYN = 'Y' THEN
											1
										   	ELSE
												(select sum(isnull(CalcMiles,0)) from #Legheader WHERE StartState = Area) 
		  							  		END,0)
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = IsNull(CASE WHEN @LineHaulRevenueOnlyYN ='Y' THEN
												(Select sum(IsNull(LineHaulRevenue,0)) from #LegHeader WHERE EndState = Area)
											WHEN @OnlyRevenueFromChargeTypesYN = 'Y' THEN
												(Select sum(IsNull(ChargeTypeListCharge,0)) from #LegHeader WHERE EndState = Area)
											ELSE 
												(Select sum(IsNull(TotalCharge,0)) from #LegHeader WHERE EndState = Area)
									  		END,0),
						DailyTotal1 = IsNull(CASE WHEN @EliminateMilesYN = 'Y' THEN
											1
										   	ELSE
												(select sum(isnull(CalcMiles,0)) from #Legheader WHERE EndState = Area) 
		  							  		END,0)
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
					SET DailyCount1 = IsNull(CASE WHEN @LineHaulRevenueOnlyYN ='Y' THEN
												(Select sum(IsNull(LineHaulRevenue,0)) from #LegHeader WHERE StartRegion1 = Area) 
											WHEN @OnlyRevenueFromChargeTypesYN = 'Y' THEN
												(Select sum(IsNull(ChargeTypeListCharge,0)) from #LegHeader WHERE StartRegion1 = Area) 
											ELSE 
												(Select sum(IsNull(TotalCharge,0)) from #LegHeader WHERE StartRegion1 = Area) 
									  		END,0),
						DailyTotal1 = IsNull(CASE WHEN @EliminateMilesYN = 'Y' THEN
											1
										   	ELSE
												(select sum(isnull(CalcMiles,0)) from #Legheader WHERE StartRegion1 = Area) 
		  							  		END,0)
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = IsNull(CASE WHEN @LineHaulRevenueOnlyYN ='Y' THEN
												(Select sum(IsNull(LineHaulRevenue,0)) from #LegHeader WHERE EndRegion1 = Area)
											WHEN @OnlyRevenueFromChargeTypesYN = 'Y' THEN
												(Select sum(IsNull(ChargeTypeListCharge,0)) from #LegHeader WHERE EndRegion1 = Area)
											ELSE 
												(Select sum(IsNull(TotalCharge,0)) from #LegHeader WHERE EndRegion1 = Area)
									  		END,0),
						DailyTotal1 = IsNull(CASE WHEN @EliminateMilesYN = 'Y' THEN
											1
										   	ELSE
												(select sum(isnull(CalcMiles,0)) from #Legheader WHERE EndRegion1 = Area)
		  							  		END,0)
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
					SET DailyCount1 = IsNull(CASE WHEN @LineHaulRevenueOnlyYN ='Y' THEN
												(Select sum(IsNull(LineHaulRevenue,0)) from #LegHeader WHERE StartRegion2 = Area)
											WHEN @OnlyRevenueFromChargeTypesYN = 'Y' THEN
												(Select sum(IsNull(ChargeTypeListCharge,0)) from #LegHeader WHERE StartRegion2 = Area)
											ELSE 
												(Select sum(IsNull(TotalCharge,0)) from #LegHeader WHERE StartRegion2 = Area)
									  		END,0),
						DailyTotal1 = IsNull(CASE WHEN @EliminateMilesYN = 'Y' THEN
											1
										   	ELSE
												(select sum(isnull(CalcMiles,0)) from #Legheader WHERE StartRegion2 = Area)
		  							  		END,0)
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = IsNull(CASE WHEN @LineHaulRevenueOnlyYN ='Y' THEN
												(Select sum(IsNull(LineHaulRevenue,0)) from #LegHeader WHERE EndRegion2 = Area)
											WHEN @OnlyRevenueFromChargeTypesYN = 'Y' THEN
												(Select sum(IsNull(ChargeTypeListCharge,0)) from #LegHeader WHERE EndRegion2 = Area)
											ELSE 
												(Select sum(IsNull(TotalCharge,0)) from #LegHeader WHERE EndRegion2 = Area)
									  		END,0),
						DailyTotal1 = IsNull(CASE WHEN @EliminateMilesYN = 'Y' THEN
											1
										   	ELSE
												(select sum(isnull(CalcMiles,0)) from #Legheader WHERE EndRegion2 = Area)
		  							  		END,0)
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
					SET DailyCount1 = IsNull(CASE WHEN @LineHaulRevenueOnlyYN ='Y' THEN
												(Select sum(IsNull(LineHaulRevenue,0)) from #LegHeader WHERE StartRegion3 = Area)
											WHEN @OnlyRevenueFromChargeTypesYN = 'Y' THEN
												(Select sum(IsNull(ChargeTypeListCharge,0)) from #LegHeader WHERE StartRegion3 = Area)
											ELSE 
												(Select sum(IsNull(TotalCharge,0)) from #LegHeader WHERE StartRegion3 = Area)
									  		END,0),
						DailyTotal1 = IsNull(CASE WHEN @EliminateMilesYN = 'Y' THEN
											1
										   	ELSE
												(select sum(isnull(CalcMiles,0)) from #Legheader WHERE StartRegion3 = Area)
		  							  		END,0)
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = IsNull(CASE WHEN @LineHaulRevenueOnlyYN ='Y' THEN
												(Select sum(IsNull(LineHaulRevenue,0)) from #LegHeader WHERE EndRegion3 = Area)
											WHEN @OnlyRevenueFromChargeTypesYN = 'Y' THEN
												(Select sum(IsNull(ChargeTypeListCharge,0)) from #LegHeader WHERE EndRegion3 = Area)
											ELSE 
												(Select sum(IsNull(TotalCharge,0)) from #LegHeader WHERE EndRegion3 = Area)
									  		END,0),
						DailyTotal1 = IsNull(CASE WHEN @EliminateMilesYN = 'Y' THEN
											1
										   	ELSE
												(select sum(isnull(CalcMiles,0)) from #Legheader WHERE EndRegion3 = Area)
		  							  		END,0)
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
					SET DailyCount1 = IsNull(CASE WHEN @LineHaulRevenueOnlyYN ='Y' THEN
												(Select sum(IsNull(LineHaulRevenue,0)) from #LegHeader WHERE StartRegion4 = Area)
											WHEN @OnlyRevenueFromChargeTypesYN = 'Y' THEN
												(Select sum(IsNull(ChargeTypeListCharge,0)) from #LegHeader WHERE StartRegion4 = Area)
											ELSE 
												(Select sum(IsNull(TotalCharge,0)) from #LegHeader WHERE StartRegion4 = Area)
									  		END,0),
						DailyTotal1 = IsNull(CASE WHEN @EliminateMilesYN = 'Y' THEN
											1
										   	ELSE
												(select sum(isnull(CalcMiles,0)) from #Legheader WHERE StartRegion4 = Area)
		  							  		END,0)
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = IsNull(CASE WHEN @LineHaulRevenueOnlyYN ='Y' THEN
												(Select sum(IsNull(LineHaulRevenue,0)) from #LegHeader WHERE EndRegion4 = Area) 
											WHEN @OnlyRevenueFromChargeTypesYN = 'Y' THEN
												(Select sum(IsNull(ChargeTypeListCharge,0)) from #LegHeader WHERE EndRegion4 = Area) 
											ELSE 
												(Select sum(IsNull(TotalCharge,0)) from #LegHeader WHERE EndRegion4 = Area) 
									  		END,0),
						DailyTotal1 = IsNull(CASE WHEN @EliminateMilesYN = 'Y' THEN
											1
										   	ELSE
												(select sum(isnull(CalcMiles,0)) from #Legheader WHERE EndRegion4 = Area) 
		  							  		END,0)
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
			END  -- state, regions
		END -- update cache
    END -- showdetail < 2 so create temptable

	If @ShowDetail = 1
		SELECT * FROM #LegHeader 

	If @ShowDetail = 2
		begin	
		SELECT DISTINCT Area, Convert(Decimal(11,2),CASE Sum(ISNULL(DailyTotal1, 0)) WHEN 0 THEN NULL ELSE Sum(ISNULL(DailyCount1,0))/ Sum(ISNULL(DailyTotal1, 0)) END) as DailyValue1, Convert(Decimal(11,2),CASE Sum(ISNULL(DailyTotal2, 0)) WHEN 0 THEN NULL ELSE Sum(ISNULL(DailyCount2,0))/ Sum(ISNULL(DailyTotal2, 0)) END) as DailyValue2
		FROM RNMap_Cache_Values RNMC1 (NOLOCK) 
		WHERE metriccode = @MetricCode And RNMC1.PlainDate = (Select Max(RNMC2.PlainDate) From RNMap_Cache_Values RNMC2 (NOLOCK) WHERE RNMC1.metriccode = RNMC2.metriccode) 
		GROUP BY Area
--		select @metriccode		
		End

	Set @ThisCount = 1
	Set @ThisTotal = 1

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END	



GO
GRANT EXECUTE ON  [dbo].[Metric_GeoRevenuePerMile] TO [public]
GO
