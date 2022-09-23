SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE PROCEDURE [dbo].[Metric_TMEfficiencyV2]
(
	--Standard Parameters
	@Result DECIMAL(20, 5) OUTPUT, 
	@ThisCount DECIMAL(20, 5) OUTPUT, 
	@ThisTotal DECIMAL(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms INT = 0, 
	@ShowDetail INT = 0,

	--Additional/Optional Parameters
	@DateType VARCHAR(50) ='STOP',				-- MoveEnd, OrderEnd, StopEnd, LegEnd
	@Numerator varchar(25) = 'AllAuto',			-- AutoArrive, AutoDepart, AutoBoth, AutoEither, ManualArrive, ManualDepart, ManualBoth, ManualEither
	@Denominator varchar(25) = 'AllStops',		-- Day, AllStops
	@BillableStopsOnlyYN char(1) = 'N',
	@OnlyRevType1List VARCHAR(255) ='',
	@OnlyRevType2List VARCHAR(255) ='',
	@OnlyRevType3List VARCHAR(255) ='',
	@OnlyRevType4List VARCHAR(255) ='',
	@OnlyOriginRegionList VARCHAR(255) ='',
	@OnlyDestinationRegionList VARCHAR(255) ='',
	@OnlyShipperIDList VARCHAR(255) = '',
	@OnlyConsigneeIDList VARCHAR(255) = '',
	@OnlyBillToIDList VARCHAR(255) = '',
	@OnlyDrvType1List varchar(255) = '',
	@OnlyDrvType2List varchar(255) = '',
	@OnlyDrvType3List varchar(255) = '',
	@OnlyDrvType4List varchar(255) = '',
	@OnlyTrcTerminalList varchar(255)='',
	@OnlyTrcType1List varchar(255) = '',
	@OnlyTrcType2List varchar(255) = '',
	@OnlyTrcType3List varchar(255) = '',
	@OnlyTrcType4List varchar(255) = ''
)

AS

/*
Created:	10/12/2008
By:			Stephen Pembridge
Purpose: This proc provides a % of stops completed via TotalMail.  

*/

	--Standard Setting
	-- Don't touch the following line. It allows for multiple drill down options
	-- DETAILOPTIONS=1:All Trips,2:By TeamLeader,3:By Tractor
	SET NOCOUNT ON

	--Standard Parameter Initialization
	SET @OnlyRevType1List= ',' + ISNULL(@OnlyRevType1List,'') + ','
	SET @OnlyRevType2List= ',' + ISNULL(@OnlyRevType2List,'') + ','
	SET @OnlyRevType3List= ',' + ISNULL(@OnlyRevType3List,'') + ','
	SET @OnlyRevType4List= ',' + ISNULL(@OnlyRevType4List,'') + ','

 	SET @OnlyBillToIDList= ',' + ISNULL(@OnlyBillToIDList,'') + ','
  	SET @OnlyConsigneeIDList= ',' + ISNULL(@OnlyConsigneeIDList,'') + ','
	SET @OnlyShipperIDList= ',' + ISNULL(@OnlyShipperIDList,'') + ','

	SET @OnlyOriginRegionList= ',' + ISNULL(@OnlyOriginRegionList,'') + ','
	SET @OnlyDestinationRegionList= ',' + ISNULL(@OnlyDestinationRegionList,'') + ','

	Set @OnlyDrvType1List = ',' + ISNULL(@OnlyDrvType1List,'') + ',' 
	Set @OnlyDrvType2List = ',' + ISNULL(@OnlyDrvType2List,'') + ',' 
	Set @OnlyDrvType3List = ',' + ISNULL(@OnlyDrvType3List,'') + ',' 
	Set @OnlyDrvType4List = ',' + ISNULL(@OnlyDrvType4List,'') + ',' 

	Set @OnlyTrcTerminalList = ',' + ISNULL(@OnlyTrcTerminalList,'') + ',' 
	Set @OnlyTrcType1List = ',' + ISNULL(@OnlyTrcType1List,'') + ',' 
	Set @OnlyTrcType2List = ',' + ISNULL(@OnlyTrcType2List,'') + ',' 
	Set @OnlyTrcType3List = ',' + ISNULL(@OnlyTrcType3List,'') + ',' 
	Set @OnlyTrcType4List = ',' + ISNULL(@OnlyTrcType4List,'') + ',' 

	Create Table #StopList (stp_number int, ord_hdrnumber int)

	If (@DateType = 'StopEnd')
		begin
			Insert into #StopList (stp_number,ord_hdrnumber)
			Select stp_number,ord_hdrnumber
			from stops (NOLOCK) 
			where stp_departuredate >= @DateStart AND stp_departuredate < @DateEnd 
			AND	stp_status = 'DNE'
		end
	Else
		begin
			Declare @TempTriplets Table (mov_number int, lgh_number int, ord_hdrnumber int)

			If (@DateType = 'MoveEnd')
				begin
					Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
						Select mov_number
						,lgh_number
						,ord_hdrnumber
						From ResNow_Triplets (NOLOCK)
						where MoveEndDate >= @DateStart AND MoveEndDate < @DateEnd
				end
			Else If (@DateType = 'LegEnd')
				Begin
					Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
						Select mov_number
						,lgh_number
						,ord_hdrnumber
						From ResNow_Triplets (NOLOCK)
						where lgh_enddate >= @DateStart AND lgh_enddate < @DateEnd
				End
			Else	-- If (@DateType = 'OrderEnd')
				Begin
					Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
						Select mov_number
						,lgh_number
						,ord_hdrnumber
						From ResNow_Triplets (NOLOCK)
						where ord_completiondate >= @DateStart AND ord_completiondate < @DateEnd
				End

			Insert into #StopList (stp_number,ord_hdrnumber)
			Select stp_number,ord_hdrnumber
			From Stops (NOLOCK)
			Where lgh_number in (select lgh_number from @TempTriplets)
			AND	stp_status = 'DNE'
		end

	If @BillableStopsOnlyYN = 'Y'
		begin
			delete from #StopList where ord_hdrnumber = 0
		end



	-- Custom Metric SQL here
	Select L1.ord_hdrnumber as 'Order'
	,ord_revtype1 as 'RevType1'
	,ord_startdate as 'ShipDate'
	,ord_completiondate as 'DeliveryDate'
	,ord_shipper as 'Shipper'
	,ord_consignee as 'Consignee'
	,lgh_driver1 as 'Driver'
	,lgh_tractor as 'Tractor'
	,lgh_primary_trailer as 'Trailer'
	,S1.cmp_id as 'StopCompany'
	,S1.stp_event as 'StopEvent'
	,S1.stp_arrivaldate as 'StopArrival'
	,IsNull(S1.stp_arr_confirmed,'N') as 'ArrByTotalMail'
	,S1.last_updateby as 'ArrUpdateBy'
	,S1.stp_departuredate as 'StopDeparture'
	,IsNull(S1.stp_dep_confirmed,'N') as 'DepByTotalMail'
	,S1.last_updatebydepart as 'DepUpdateBy'
--	,L1.mpp_teamleader as 'TeamLeader'
	,[TeamLeaderName] = (select name from LabelFile (NOLOCK) where LabelFile.labeldefinition = 'TeamLeader' AND Labelfile.ABBR = L1.mpp_teamleader)
	Into #ResultsTable
	From stops S1 (NOLOCK) join legheader L1 (NOLOCK) on S1.lgh_number = L1.lgh_number
		join orderheader OH (NOLOCK) on L1.ord_hdrnumber = OH.ord_hdrnumber
		Left Join City C1 (NOLOCK) On C1.cty_code = ord_origincity 
		Left Join City C2 (NOLOCK) On C2.cty_code = ord_Destcity
	WHERE S1.stp_number IN (SELECT stp_number FROM #StopList)
	AND (@OnlyRevType1List =',,' or CHARINDEX(',' + ord_revtype1 + ',', @OnlyRevType1List) >0)
	AND (@OnlyRevType2List =',,' or CHARINDEX(',' + ord_revtype2 + ',', @OnlyRevType2list) >0)
   	AND (@OnlyRevType3List =',,' or CHARINDEX(',' + ord_revtype3 + ',', @OnlyRevType3List) >0)
   	AND (@OnlyRevType4List =',,' or CHARINDEX(',' + ord_revtype4 + ',', @OnlyRevType4List) >0)
   	AND (@OnlyShipperIDList =',,' OR CHARINDEX(',' + ord_shipper + ',', @OnlyShipperIDList) >0)			
	AND (@OnlyConsigneeIDList= ',,' OR CHARINDEX(',' + ord_consignee + ',', @OnlyConsigneeIDList) >0)			
	AND (@OnlyBillToIDList= ',,' OR CHARINDEX(',' + OH.ord_billto + ',', @OnlyBillToIDList) >0)			
   	AND (@OnlyOriginRegionList =',,' or CHARINDEX(',' + C1.cty_region1 + ',', @OnlyOriginRegionList) >0)			
   	AND (@OnlyDestinationRegionList= ',,' or CHARINDEX(',' + C2.cty_region1 + ',', @OnlyDestinationRegionList) >0)		
   	AND (@OnlyDrvType1List =',,' or CHARINDEX(',' + mpp_type1 + ',', @OnlyDrvType1List) >0) 
   	AND (@OnlyDrvType2List =',,' or CHARINDEX(',' + mpp_type2 + ',', @OnlyDrvType2List) >0) 
   	AND (@OnlyDrvType3List =',,' or CHARINDEX(',' + mpp_type3 + ',', @OnlyDrvType3List) >0) 
   	AND (@OnlyDrvType4List =',,' or CHARINDEX(',' + mpp_type4 + ',', @OnlyDrvType4List) >0) 
   	AND (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + trc_terminal + ',', @OnlyTrcTerminalList) >0) 
   	AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + trc_type1 + ',', @OnlyTrcType1List) >0) 
   	AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + trc_type2 + ',', @OnlyTrcType2List) >0) 
   	AND (@OnlyTrcType3List =',,' or CHARINDEX(',' + trc_type3 + ',', @OnlyTrcType3List) >0) 
   	AND (@OnlyTrcType4List =',,' or CHARINDEX(',' + trc_type4 + ',', @OnlyTrcType4List) >0) 



	Set @ThisCount = 
		Case
			When @Numerator = 'AutoArrive' Then (Select count(*) from #ResultsTable where ArrByTotalMail = 'Y')
			When @Numerator = 'AutoDepart' Then (Select count(*) from #ResultsTable where DepByTotalMail = 'Y')
			When @Numerator = 'AutoBoth' Then (Select count(*) from #ResultsTable where ArrByTotalMail = 'Y' AND DepByTotalMail = 'Y')
			When @Numerator = 'AutoEither' Then (Select count(*) from #ResultsTable where ArrByTotalMail = 'Y' OR DepByTotalMail = 'Y')
			When @Numerator = 'ManualArrive' Then (Select count(*) from #ResultsTable where ArrByTotalMail = 'N')
			When @Numerator = 'ManualDepart' Then (Select count(*) from #ResultsTable where DepByTotalMail = 'N')
			When @Numerator = 'ManualBoth' Then (Select count(*) from #ResultsTable where ArrByTotalMail = 'N' AND DepByTotalMail = 'N')
			When @Numerator = 'ManualEither' Then (Select count(*) from #ResultsTable where ArrByTotalMail = 'N' OR DepByTotalMail = 'N')
		Else	-- 			When @Numerator = 'ManualEither' 
			(Select count(*) from #ResultsTable where ArrByTotalMail = 'N' OR DepByTotalMail = 'N')
		End			



	set @ThisTotal = 
		Case
			When @Denominator = 'AllStops' Then (Select count(*) from #ResultsTable)
		Else	-- When @Denominator = 'Day'
			CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) 
			END
		End	


	--Standard Final Result
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 

	--Detail (For returning detail for the ResultsNow detail request)
	IF (@ShowDetail = 1) -- All Trips
		BEGIN
			Select [Order]
				,[RevType1]
				,[ShipDate]
				,[DeliveryDate]
				,[Shipper]
				,[Consignee]
				,[Driver]
				,[Tractor]
				,[Trailer]
				,[StopCompany]
				,[StopEvent]
				,[StopArrival]
				,[ArrByTotalMail]
				,[ArrUpdateBy]
				,[StopDeparture]
				,[DepByTotalMail]
				,[DepUpdateBy]
--				,[TeamLeader]
				,[TeamLeaderName]
			FROM #ResultsTable
			order by [Order],StopArrival
		END
	ELSE IF (@ShowDetail = 2) -- By TeamLeader
		BEGIN
			Select [TeamLeaderName]
				,[ArrByTM] =
					(
						Select Count([ArrByTotalMail]) 
						from #ResultsTable RS2 
						Where RS2.[TeamLeaderName] = #ResultsTable.[TeamLeaderName]
						AND RS2.[ArrByTotalMail] = 'Y'
					)
				,Count([ArrByTotalMail]) as [TotalArr]
				,[DepByTM] =
					(
						Select Count([DepByTotalMail]) 
						from #ResultsTable RS2 
						Where RS2.[TeamLeaderName] = #ResultsTable.[TeamLeaderName]
						AND RS2.[DepByTotalMail] = 'Y'
					)
				,Count([DepByTotalMail]) as [TotalDep]
			Into #XX2
			FROM #ResultsTable
			Group by [TeamLeaderName]

			Select [TeamLeaderName]
				,[ArrByTM]
				,[TotalArr]
				,[ArrPctByTM] = Convert(varchar(10),Round((Convert(float,[ArrByTM]) / Convert(float,[TotalArr])) * 100,0)) + '%'
				,[DepByTM]
				,[TotalDep]
				,[DepPctByTM] = Convert(varchar(10),Round((Convert(float,[DepByTM]) / Convert(float,[TotalDep])) * 100,0)) + '%'
			From #XX2
			Order by [TeamLeaderName]
		END
	ELSE IF (@ShowDetail = 3) -- By Tractor
		BEGIN
			Select [Tractor]
				,[ArrByTM] =
					(
						Select Count([ArrByTotalMail]) 
						from #ResultsTable RS2 
						Where RS2.[Tractor] = #ResultsTable.[Tractor]
						AND RS2.[ArrByTotalMail] = 'Y'
					)
				,Count([ArrByTotalMail]) as [TotalArr]
				,[DepByTM] =
					(
						Select Count([DepByTotalMail]) 
						from #ResultsTable RS2 
						Where RS2.[Tractor] = #ResultsTable.[Tractor]
						AND RS2.[DepByTotalMail] = 'Y'
					)
				,Count([DepByTotalMail]) as [TotalDep]
			Into #XX3
			FROM #ResultsTable
			Group by [Tractor]

			Select [Tractor]
				,[ArrByTM]
				,[TotalArr]
				,[ArrPctByTM] = Convert(varchar(10),Round((Convert(float,[ArrByTM]) / Convert(float,[TotalArr])) * 100,0)) + '%'
				,[DepByTM]
				,[TotalDep]
				,[DepPctByTM] = Convert(varchar(10),Round((Convert(float,[DepByTM]) / Convert(float,[TotalDep])) * 100,0)) + '%'
			From #XX3
			Order by [Tractor]
		END


-- Part 3

	--Standard Initialization of the Metric
	--The following section of commented out code will
	--	insert the metric into the metric list and allow
	--  availability for edits within the ResultsNow Application
	/*

		EXEC MetricInitializeItem
			@sMetricCode = 'JeffFoster_TMEfficiencyV2',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 900, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDECIMAL = 0,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 1,
			@sCaption = 'TotalMail Efficiency',
			@sCaptionFull = 'Pct of Trips completed via TotalMail',
			@sPROCEDUREName = 'Metric_TMEfficiencyV2',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'

	*/

GO
GRANT EXECUTE ON  [dbo].[Metric_TMEfficiencyV2] TO [public]
GO
