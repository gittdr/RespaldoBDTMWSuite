SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[Metric_GeoMiles]

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
	@DateType varchar(50) = 'End', -- OR Ship, Book, Start, End, Delivery
	@AssignAreaMode varchar(10)= 'Start', --  End
	@DaysRange int = 30,
	@OnlyRevClass1List varchar(128) ='', 
	@OnlyRevClass2List varchar(128) ='', 
	@OnlyRevClass3List varchar(128) ='', 
	@OnlyRevClass4List varchar(128) ='',
	@OnlyMppType1List varchar(255) ='', 
	@OnlyMppType2List varchar(255) ='', 
	@OnlyMppType3List varchar(255) ='', 
	@OnlyMppType4List varchar(255) ='', 
	@OnlyTrcClass1List varchar(255) = '', 
	@OnlyTrcClass2List varchar(255) = '', 
	@OnlyTrcClass3List varchar(255) = '', 
	@OnlyTrcClass4List varchar(255) = '', 
	@OnlyTrcTerminalList varchar(255) = '', 
	@OrderStatusList varchar(128) = '', 
	@DispatchStatusList varchar(255) = '',
    @OnlyTeamLeaderList varchar(128) = '', -- Include only listed Team Leaders 
    @Mode varchar(50) = 'Miles', -- OR DHPCT, LDPCT
    @MilesType varchar(50) = 'Travel',--OR Billed, Travel, NonBilled 
    @LoadStatus varchar(255) = 'ALL', -- OR LD, MT 
	@OrderTrailerType1 varchar(255)='',
	@OnlyOrderSubCompanyList VARCHAR(128)='',
	@OnlyMppTerminal varchar(255)='',
	@OnlyShipperList varchar(255)=''
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

SET	@MetricCode = 'GeoMiles'
SET	@StateOrRegionMode ='State' --Region1 
SET	@OnlyIncludeRegion1List =''
SET	@OnlyIncludeStateList  =''

*/


	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'GeoMiles', 
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 701, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'GeoMiles',
		@sCaptionFull = 'Geographic based Miles',
		@sProcedureName = 'Metric_GeoMiles',
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
	DECLARE @MetricTempIDs TABLE (
		MetricItem varchar(13)
	)
	        
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
	Set @OrderStatusList= ',' + ISNULL(@OrderStatusList,'') + ',' 
	Set @DispatchStatusList= ',' + ISNULL(@DispatchStatusList,'') + ',' 
	Set @StopStatusList = ',' + ISNULL(@StopStatusList,'') + ',' 
	Set @OnlyTeamLeaderList = ',' + ISNULL(@OnlyTeamLeaderList,'') + ',' 
	Set @OrderTrailerType1 = ',' + ISNULL(@OrderTrailerType1,'') + ',' 
	SET @OnlyOrderSubCompanyList = ',' + ISNULL(@OnlyOrderSubCompanyList,'') + ','
	SET @OnlyMppTerminal = ',' + ISNULL(@OnlyMppTerminal,'') + ','
	SET @OnlyShipperList = ',' + ISNULL(@OnlyShipperList,'') + ','
	

	Set @OnlyIncludeStateList = ',' + ISNULL(@OnlyIncludeStateList ,'') + ','
	Set @OnlyIncludeRegion1List = ',' + ISNULL(@OnlyIncludeRegion1List ,'') + ','
	Set @OnlyIncludeRegion2List = ',' + ISNULL(@OnlyIncludeRegion2List ,'') + ','
	Set @OnlyIncludeRegion3List = ',' + ISNULL(@OnlyIncludeRegion3List ,'') + ','
	Set @OnlyIncludeRegion4List = ',' + ISNULL(@OnlyIncludeRegion4List ,'') + ','
	


IF @ShowDetail < 2
	BEGIN --UPDATE CACHE
	Select	l.mov_number as [Move Number],  
			l.ord_hdrnumber as [Order Number],
			lgh_startcty_nmstct as [Start City,State], 
			lgh_endcty_nmstct as [End City,State], 
			lgh_startdate as [Start Date],  
			lgh_enddate as [End Date],      
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
						),

			ISNULL(lgh_carrier,'UNKNOWN') CarrierID, 
			ISNULL(lgh_driver1,'UNKNOWN') DriverID,
			ISNULL(lgh_tractor,'UNKNOWN') TractorID, 
			IsNull(dbo.fnc_TMWRN_Miles('Segment',@MilesType,'Miles',l.mov_number,default,l.lgh_number,default,default,default,default,default),0) as TotalMiles,
			IsNull(dbo.fnc_TMWRN_Miles('Segment',@MilesType,'Miles',l.mov_number,default,l.lgh_number,default,'LD',default,default,default),0) as LoadedMiles,
			IsNull(dbo.fnc_TMWRN_Miles('Segment',@MilesType,'Miles',l.mov_number,default,l.lgh_number,default,'MT',default,default,default),0) as EmptyMiles,
			lgh_outstatus as [Dispatch Status] 
	INTO    #LegHeader 
	FROM	Legheader L (NOLOCK) Left Join OrderHeader O (NOLOCK) On L.ord_hdrnumber = O.ord_hdrnumber 
	where	( 
				(@DateType = 'Start' and lgh_startdate >= DateAdd(d, -(@DaysRange -1), @DateStart) AND lgh_startdate < @DateEnd) 
					OR 
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
			AND (@OnlyMppTerminal =',,' or CHARINDEX(',' + RTRIM( Mpp_Terminal ) + ',', @OnlyMppTerminal) >0) 
			AND (@OnlyShipperList =',,' or CHARINDEX(',' + RTRIM( ord_shipper) + ',', @OnlyMppTerminal) >0) 
			AND (@OnlyTeamLeaderList= ',,'  or CHARINDEX(',' + RTRIM( l.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0) 
			AND (@OnlyIncludeStateList =',,' or @StateOrRegionMode <> 'STATE' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( lgh_EndState) + ',', @OnlyIncludeStateList) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(lgh_StartState)  + ',', @OnlyIncludeStateList) >0)
			AND (@OnlyIncludeRegion1List =',,' or @StateOrRegionMode <> 'REGION1' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( lgh_EndRegion1) + ',', @OnlyIncludeRegion1List) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(lgh_StartRegion1) + ',', @OnlyIncludeRegion1List) >0)
			AND (@OnlyIncludeRegion2List =',,' or @StateOrRegionMode <> 'REGION2' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( lgh_EndRegion2) + ',', @OnlyIncludeRegion2List) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(lgh_StartRegion2) + ',', @OnlyIncludeRegion2List) >0)
			AND (@OnlyIncludeRegion3List =',,' or @StateOrRegionMode <> 'REGION3' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( lgh_EndRegion3) + ',', @OnlyIncludeRegion3List) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(lgh_StartRegion3) + ',', @OnlyIncludeRegion3List) >0)
			AND (@OnlyIncludeRegion4List =',,' or @StateOrRegionMode <> 'REGION4' or @AssignAreaMode = 'End' AND CHARINDEX(',' + RTRIM( lgh_EndRegion4) + ',', @OnlyIncludeRegion4List) >0 Or @AssignAreaMode = 'Start' AND CHARINDEX(',' + RTRIM(lgh_StartRegion4) + ',', @OnlyIncludeRegion4List) >0)
			AND L.lgh_outstatus <> 'CAN'    
			AND (@DispatchStatusList =',,' or CHARINDEX(',' + RTRIM( lgh_outstatus ) + ',', @DispatchStatusList) >0) 
			AND (@OrderStatusList = ',,' OR CHARINDEX(',' + RTRIM( ord_status ) + ',', @OrderStatusList) >0)
			AND (@OrderTrailerType1 =',,' or CHARINDEX(',' + RTRIM( O.trl_type1 ) + ',', @OrderTrailerType1) >0)                  
			AND (@OnlyOrderSubCompanyList=',,' OR CHARINDEX(',' + RTRIM( ord_subcompany ) + ',', @OnlyOrderSubCompanyList) >0)	

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
					SET DailyCount1 = IsNull(CASE WHEN @LoadStatus = 'LD' OR @Mode = 'LDPCT' THEN
												(Select sum(LoadedMiles) from #LegHeader WHERE StartState = Area)
											WHEN @LoadStatus = 'MT' OR @Mode = 'DHPCT' THEN
												(Select sum(EmptyMiles) from #LegHeader WHERE StartState = Area) 
											ELSE
												(Select sum(TotalMiles) from #LegHeader WHERE StartState = Area) 
									  END,0),
						DailyTotal1 = IsNull(CASE WHEN @Mode = 'Miles' THEN
											1
										   WHEN @Mode = 'PerLoad' THEN
											(Select count(*) from (select distinct [Order Number] From #Legheader WHERE StartState = Area) xx)
										   ELSE
											(Select sum(TotalMiles) from #LegHeader WHERE StartState = Area) 
		  							  END,0)
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = IsNull(CASE WHEN @LoadStatus = 'LD' OR @Mode = 'LDPCT' THEN
												(Select sum(LoadedMiles) from #LegHeader WHERE EndState = Area)
											WHEN @LoadStatus = 'MT' OR @Mode = 'DHPCT' THEN
												(Select sum(EmptyMiles) from #LegHeader WHERE EndState = Area) 
											ELSE
												(Select sum(TotalMiles) from #LegHeader WHERE EndState = Area) 
									  END,0),
						DailyTotal1 = IsNull(CASE WHEN @Mode = 'Miles' THEN
											1
										   WHEN @Mode = 'PerLoad' THEN
											(Select count(*) from (select distinct [Order Number] From #Legheader WHERE EndState = Area) xx)
										   ELSE
											(Select sum(TotalMiles) from #LegHeader WHERE EndState = Area) 
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
					SET DailyCount1 = IsNull(CASE WHEN @LoadStatus = 'LD' OR @Mode = 'LDPCT' THEN
												(Select sum(LoadedMiles) from #LegHeader WHERE StartRegion1 = Area)
											WHEN @LoadStatus = 'MT' OR @Mode = 'DHPCT' THEN
												(Select sum(EmptyMiles) from #LegHeader WHERE StartRegion1 = Area) 
											ELSE
												(Select sum(TotalMiles) from #LegHeader WHERE StartRegion1 = Area) 
									  END,0),
						DailyTotal1 = IsNull(CASE WHEN @Mode = 'Miles' THEN
											1
										   WHEN @Mode = 'PerLoad' THEN
											(Select count(*) from (select distinct [Order Number] From #Legheader WHERE StartRegion1 = Area) xx)
										   ELSE
											(Select sum(TotalMiles) from #LegHeader WHERE StartRegion1 = Area) 
		  							  END,0)
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = IsNull(CASE WHEN @LoadStatus = 'LD' OR @Mode = 'LDPCT' THEN
												(Select sum(LoadedMiles) from #LegHeader WHERE EndRegion1 = Area)
											WHEN @LoadStatus = 'MT' OR @Mode = 'DHPCT' THEN
												(Select sum(EmptyMiles) from #LegHeader WHERE EndRegion1 = Area) 
											ELSE
												(Select sum(TotalMiles) from #LegHeader WHERE EndRegion1 = Area) 
									  END,0),
						DailyTotal1 = IsNull(CASE WHEN @Mode = 'Miles' THEN
											1
										   WHEN @Mode = 'PerLoad' THEN
											(Select count(*) from (select distinct [Order Number] From #Legheader WHERE EndRegion1 = Area) xx)
										   ELSE
											(Select sum(TotalMiles) from #LegHeader WHERE EndRegion1 = Area) 
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
					SET DailyCount1 = IsNull(CASE WHEN @LoadStatus = 'LD' OR @Mode = 'LDPCT' THEN
												(Select sum(LoadedMiles) from #LegHeader WHERE StartRegion2 = Area)
											WHEN @LoadStatus = 'MT' OR @Mode = 'DHPCT' THEN
												(Select sum(EmptyMiles) from #LegHeader WHERE StartRegion2 = Area) 
											ELSE
												(Select sum(TotalMiles) from #LegHeader WHERE StartRegion2 = Area) 
									  END,0),
						DailyTotal1 = IsNull(CASE WHEN @Mode = 'Miles' THEN
											1
										   WHEN @Mode = 'PerLoad' THEN
											(Select count(*) from (select distinct [Order Number] From #Legheader WHERE StartRegion2 = Area) xx)
										   ELSE
											(Select sum(TotalMiles) from #LegHeader WHERE StartRegion2 = Area) 
		  							  END,0)
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = IsNull(CASE WHEN @LoadStatus = 'LD' OR @Mode = 'LDPCT' THEN
												(Select sum(LoadedMiles) from #LegHeader WHERE EndRegion2 = Area)
											WHEN @LoadStatus = 'MT' OR @Mode = 'DHPCT' THEN
												(Select sum(EmptyMiles) from #LegHeader WHERE EndRegion2 = Area) 
											ELSE
												(Select sum(TotalMiles) from #LegHeader WHERE EndRegion2 = Area) 
									  END,0),
						DailyTotal1 = IsNull(CASE WHEN @Mode = 'Miles' THEN
											1
										   WHEN @Mode = 'PerLoad' THEN
											(Select count(*) from (select distinct [Order Number] From #Legheader WHERE EndRegion2 = Area) xx)
										   ELSE
											(Select sum(TotalMiles) from #LegHeader WHERE EndRegion2 = Area) 
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
					SET DailyCount1 = IsNull(CASE WHEN @LoadStatus = 'LD' OR @Mode = 'LDPCT' THEN
												(Select sum(LoadedMiles) from #LegHeader WHERE StartRegion3 = Area)
											WHEN @LoadStatus = 'MT' OR @Mode = 'DHPCT' THEN
												(Select sum(EmptyMiles) from #LegHeader WHERE StartRegion3 = Area) 
											ELSE
												(Select sum(TotalMiles) from #LegHeader WHERE StartRegion3 = Area) 
									  END,0),
						DailyTotal1 = IsNull(CASE WHEN @Mode = 'Miles' THEN
											1
										   WHEN @Mode = 'PerLoad' THEN
											(Select count(*) from (select distinct [Order Number] From #Legheader WHERE StartRegion3 = Area) xx)
										   ELSE
											(Select sum(TotalMiles) from #LegHeader WHERE StartRegion3 = Area) 
		  							  END,0)
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = IsNull(CASE WHEN @LoadStatus = 'LD' OR @Mode = 'LDPCT' THEN
												(Select sum(LoadedMiles) from #LegHeader WHERE EndRegion3 = Area)
											WHEN @LoadStatus = 'MT' OR @Mode = 'DHPCT' THEN
												(Select sum(EmptyMiles) from #LegHeader WHERE EndRegion3 = Area) 
											ELSE
												(Select sum(TotalMiles) from #LegHeader WHERE EndRegion3 = Area) 
									  END,0),
						DailyTotal1 = IsNull(CASE WHEN @Mode = 'Miles' THEN
											1
										   WHEN @Mode = 'PerLoad' THEN
											(Select count(*) from (select distinct [Order Number] From #Legheader WHERE EndRegion3 = Area) xx)
										   ELSE
											(Select sum(TotalMiles) from #LegHeader WHERE EndRegion3 = Area) 
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
					SET DailyCount1 = IsNull(CASE WHEN @LoadStatus = 'LD' OR @Mode = 'LDPCT' THEN
												(Select sum(LoadedMiles) from #LegHeader WHERE StartRegion4 = Area)
											WHEN @LoadStatus = 'MT' OR @Mode = 'DHPCT' THEN
												(Select sum(EmptyMiles) from #LegHeader WHERE StartRegion4 = Area) 
											ELSE
												(Select sum(TotalMiles) from #LegHeader WHERE StartRegion4 = Area) 
									  END,0),
						DailyTotal1 = IsNull(CASE WHEN @Mode = 'Miles' THEN
											1
										   WHEN @Mode = 'PerLoad' THEN
											(Select count(*) from (select distinct [Order Number] From #Legheader WHERE StartRegion4 = Area) xx)
										   ELSE
											(Select sum(TotalMiles) from #LegHeader WHERE StartRegion4 = Area) 
		  							  END,0)
					WHERE MetricCode = @MetricCode
					AND PlainDate = @DateStart
					END
				ELSE IF @AssignAreaMode = 'End'
					BEGIN
					UPDATE RNMap_Cache_Values 
					SET DailyCount1 = IsNull(CASE WHEN @LoadStatus = 'LD' OR @Mode = 'LDPCT' THEN
												(Select sum(LoadedMiles) from #LegHeader WHERE EndRegion4 = Area)
											WHEN @LoadStatus = 'MT' OR @Mode = 'DHPCT' THEN
												(Select sum(EmptyMiles) from #LegHeader WHERE EndRegion4 = Area) 
											ELSE
												(Select sum(TotalMiles) from #LegHeader WHERE EndRegion4 = Area) 
									  END,0),
						DailyTotal1 = IsNull(CASE WHEN @Mode = 'Miles' THEN
											1
										   WHEN @Mode = 'PerLoad' THEN
											(Select count(*) from (select distinct [Order Number] From #Legheader WHERE EndRegion4 = Area) xx)
										   ELSE
											(Select sum(TotalMiles) from #LegHeader WHERE EndRegion4 = Area) 
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
		IF @Mode IN ('DHPCT', 'LDPCT') 
			SELECT DISTINCT Area, Convert(Decimal(4,1),CASE Sum(ISNULL(DailyTotal1, 0)) WHEN 0 THEN NULL ELSE Sum(ISNULL(DailyCount1,0))/ Sum(ISNULL(DailyTotal1, 0)) * 100 END) as DailyValue1, Sum(ISNULL(DailyCount1, 0)) as DailyValue2, Sum(ISNULL(DailyTotal1, 0)) as DailyValue3
			FROM RNMap_Cache_Values RNMC1 (NOLOCK) 
			WHERE metriccode = @MetricCode And RNMC1.PlainDate = (Select Max(RNMC2.PlainDate) From RNMap_Cache_Values RNMC2 (NOLOCK) WHERE RNMC1.metriccode = RNMC2.metriccode) 
			GROUP BY Area
		ELSE
			SELECT DISTINCT Area, Convert(Int,          CASE Sum(ISNULL(DailyTotal1, 0)) WHEN 0 THEN NULL ELSE Sum(ISNULL(DailyCount1,0))/ Sum(ISNULL(DailyTotal1, 0)) END) as DailyValue1, Convert(Int,CASE Sum(ISNULL(DailyTotal2, 0)) WHEN 0 THEN NULL ELSE Sum(ISNULL(DailyCount2,0))/ Sum(ISNULL(DailyTotal2, 0)) END) as DailyValue2
			FROM RNMap_Cache_Values RNMC1 (NOLOCK) 
			WHERE metriccode = @MetricCode And RNMC1.PlainDate = (Select Max(RNMC2.PlainDate) From RNMap_Cache_Values RNMC2 (NOLOCK) WHERE RNMC1.metriccode = RNMC2.metriccode) 
			GROUP BY Area




	Set @ThisCount = 1
	Set @ThisTotal = 1
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END	

GO
GRANT EXECUTE ON  [dbo].[Metric_GeoMiles] TO [public]
GO
