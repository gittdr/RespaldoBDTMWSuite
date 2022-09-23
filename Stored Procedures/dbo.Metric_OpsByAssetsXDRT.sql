SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

Create  PROCEDURE [dbo].[Metric_OpsByAssetsXDRT]
	(
		@Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,
	-- Additional / Optional Parameters
		@DateType varchar(50) = 'RoundTripEnd',			-- RoundTripStart,RoundTripEnd
		@Numerator varchar(20) = 'Revenue',				-- Revenue,Cost,Margin,TravelMile,LoadedMile,EmptyMile,BillMile,RTCount,LoadCount,OrderCount,Weight,Volume
		@Denominator varchar(20) = 'TravelMile',			-- Revenue,Cost,TravelMile,LoadedMile,EmptyMile,BillMile,Day,RTCount,LoadCount,OrderCount,Weight,Volume,TractorCount
		@UseTravelMilesForAllocationsYN char(1) = 'Y',	
		@RoundTripDefinitionList varchar(255) = '',
		@RTStateFirstOutboundOrAnySequenceOA char(1) = 'A',	-- O (state must be FIRST outbound state), A (state visited at ANY point in RT)
		@RTStateList varchar(255) ='',
		@RoundTripStatusList varchar(255) = '',			-- Complete, InProcess
	-- revenue related parameters
		@BaseRevenueCategoryTLAFN char(1) ='T',
		@SubtractFuelSurchargeYN char(1) = 'N',
		@IncludeChargeTypeList varchar(255) = '', 
		@ExcludeChargeTypeList varchar(255)='',		 
	-- cost related parameters
		@PreTaxYN char(1) = NULL,
		@IncludePayTypeList varchar(255)='',
		@ExcludePayTypeList varchar(255) = '',
	-- freight related parameters
		@WeightUOM varchar(10) = 'LBS',
		@VolumeUOM varchar(10) = 'GAL',
	-- filtering parameters: revtypes
		@OnlyRevType1List varchar(255) ='',
		@OnlyRevType2List varchar(255) ='',
		@OnlyRevType3List varchar(255) ='',
		@OnlyRevType4List varchar(255) ='',
		@OnlyFirstBillToList varchar(255) = '',
	-- filtering parameters: includes
		@OnlyTrcType1List varchar(255) = '',
		@OnlyTrcType2List varchar(255) = '',
		@OnlyTrcType3List varchar(255) = '',
		@OnlyTrcType4List varchar(255) = '',
		@OnlyTrcCompanyList varchar(255) = '',
		@OnlyTrcDivisionList varchar(255) = '',
		@OnlyTrcTerminalList varchar(255) = '',
		@OnlyTrcFleetList varchar(255) = '',
		@OnlyTrcBranchList varchar(255) = '',

	-- filtering parameters: excludes
		@ExcludeRevType1List varchar(255) ='',
		@ExcludeRevType2List varchar(255) ='',
		@ExcludeRevType3List varchar(255) ='',
		@ExcludeRevType4List varchar(255) ='',

		@ExcludeTrcType1List varchar(255) = '',
		@ExcludeTrcType2List varchar(255) = '',
		@ExcludeTrcType3List varchar(255) = '',
		@ExcludeTrcType4List varchar(255) = '',
		@ExcludeTrcCompanyList varchar(255) = '',
		@ExcludeTrcDivisionList varchar(255) = '',
		@ExcludeTrcTerminalList varchar(255) = '',
		@ExcludeTrcFleetList varchar(255) = '',
		@ExcludeTrcBranchList varchar(255) = '',

		@MetricCode varchar(255)= 'OpsByAssetsXD'
	)
AS

	SET NOCOUNT ON

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:RevType1,2:RevType1-2,3:RevType1-3,4:RevType1-4,5:ByDriver,6:ByTractor,7:ByRoundTrip,8:ByVisitedStates,9:By1stOutboundState,10:By1stBillTo,11:TripList

	--Populate DEFAULT currency and currency date types
	EXEC PopulateSessionIDParamatersInProc 'Revenue', @MetricCode  

	If DateDiff(mi,IsNull((Select MAX(DateLastRefresh) from ResNow_TripletsLastRefresh),'19500101'),GetDate()) > 65
		Begin
			exec ResNow_UpdateTripletsAssets
		End
--	Else 
--		Select DateDiff(mi,IsNull((Select DateLastRefresh from ResNow_TripletsLastRefresh),'19500101'),GetDate())

	Declare @TractorCount int



	SET @RoundTripDefinitionList = ',' + ISNULL(@RoundTripDefinitionList,'') + ','
	SET @RoundTripStatusList = ',' + ISNULL(@RoundTripStatusList,'') + ','
	Set @RTStateList= ',' + ISNULL(@RTStateList,'') + ','

	SET @OnlyRevType1List= ',' + ISNULL(@OnlyRevType1List,'') + ','
	SET @OnlyRevType2List= ',' + ISNULL(@OnlyRevType2List,'') + ','
	SET @OnlyRevType3List= ',' + ISNULL(@OnlyRevType3List,'') + ','
	SET @OnlyRevType4List= ',' + ISNULL(@OnlyRevType4List,'') + ','

	Set @OnlyFirstBillToList= ',' + ISNULL(@OnlyFirstBillToList,'') + ','

	Set @OnlyTrcType1List= ',' + ISNULL(@OnlyTrcType1List,'') + ','
	Set @OnlyTrcType2List= ',' + ISNULL(@OnlyTrcType2List,'') + ','
	Set @OnlyTrcType3List= ',' + ISNULL(@OnlyTrcType3List,'') + ','
	Set @OnlyTrcType4List= ',' + ISNULL(@OnlyTrcType4List,'') + ','
	Set @OnlyTrcCompanyList= ',' + ISNULL(@OnlyTrcCompanyList,'') + ','
	Set @OnlyTrcDivisionList= ',' + ISNULL(@OnlyTrcDivisionList,'') + ','
	Set @OnlyTrcTerminalList= ',' + ISNULL(@OnlyTrcTerminalList,'') + ','
	Set @OnlyTrcFleetList= ',' + ISNULL(@OnlyTrcFleetList,'') + ','
	Set @OnlyTrcBranchList= ',' + ISNULL(@OnlyTrcBranchList,'') + ','

	SET @ExcludeRevType1List= ',' + ISNULL(@ExcludeRevType1List,'') + ','
	SET @ExcludeRevType2List= ',' + ISNULL(@ExcludeRevType2List,'') + ','
	SET @ExcludeRevType3List= ',' + ISNULL(@ExcludeRevType3List,'') + ','
	SET @ExcludeRevType4List= ',' + ISNULL(@ExcludeRevType4List,'') + ','

	Set @ExcludeTrcType1List= ',' + ISNULL(@ExcludeTrcType1List,'') + ','
	Set @ExcludeTrcType2List= ',' + ISNULL(@ExcludeTrcType2List,'') + ','
	Set @ExcludeTrcType3List= ',' + ISNULL(@ExcludeTrcType3List,'') + ','
	Set @ExcludeTrcType4List= ',' + ISNULL(@ExcludeTrcType4List,'') + ','
	Set @ExcludeTrcCompanyList= ',' + ISNULL(@ExcludeTrcCompanyList,'') + ','
	Set @ExcludeTrcDivisionList= ',' + ISNULL(@ExcludeTrcDivisionList,'') + ','
	Set @ExcludeTrcTerminalList= ',' + ISNULL(@ExcludeTrcTerminalList,'') + ','
	Set @ExcludeTrcFleetList= ',' + ISNULL(@ExcludeTrcFleetList,'') + ','
	Set @ExcludeTrcBranchList= ',' + ISNULL(@ExcludeTrcBranchList,'') + ','



	Declare @TempTriplets Table (mov_number int, lgh_number int, ord_hdrnumber int)

	If (@DateType = 'RoundTripEnd')
		begin
			create table #QualifyingRTs (rt_Leg int)
		
			If @RTStateFirstOutboundOrAnySequenceOA = 'A'
				begin
					Insert into #QualifyingRTs (rt_Leg)
					select rt_Leg	
					from DW_RTLegCache RTLC (NOLOCK)
					where rt_StartLeg in
						(
							select rt_StartLeg 
							from DW_RTLegCache R2 (NOLOCK)
							where rt_EndDate >= @DateStart AND rt_EndDate < @DateEnd
							AND exists
								(
									select stp_number
									from stops (NOLOCK)
									where stops.lgh_number = R2.rt_Leg
									AND (@RTStateList =',,' or CHARINDEX(',' + stops.stp_state + ',',@RTStateList) > 0)
								)
						)
					AND (@RoundTripDefinitionList =',,' or CHARINDEX(',' + RTLC.rt_DefName + ',',@RoundTripDefinitionList) > 0)
				end
			Else	-- @RTStateFirstOutboundOrAnySequenceOA = 'O'
				begin
					Insert into #QualifyingRTs (rt_Leg)
					select rt_Leg	
					from DW_RTLegCache RTLC (NOLOCK)
					where rt_StartLeg in
						(
							select rt_StartLeg 
							from DW_RTLegCache R2 (NOLOCK)
							where rt_EndDate >= @DateStart AND rt_EndDate < @DateEnd
							AND exists
								(
									select lgh_number
									from legheader LH (NOLOCK)
									where LH.lgh_number = R2.rt_StartLeg
									AND (@RTStateList =',,' or CHARINDEX(',' + Case when LH.lgh_split_flag = 'S' then LH.lgh_endstate Else LH.lgh_rendstate End + ',',@RTStateList) > 0)
								)
						)
					AND (@RoundTripDefinitionList =',,' or CHARINDEX(',' + RTLC.rt_DefName + ',',@RoundTripDefinitionList) > 0)
				end

			If @RoundTripStatusList <> ',,'
				Begin
					select rt_Leg 
					into #TempDeleteRTs
					from dw_RTLegCache (NOLOCK)
					where rt_Leg in (select rt_Leg from #QualifyingRTs)
					AND CHARINDEX(',' + rt_Status + ',',@RoundTripStatusList) = 0

					Delete from #QualifyingRTs where rt_Leg in (select rt_Leg from #TempDeleteRTs)
				
					drop table #TempDeleteRTs
				End


			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets (NOLOCK)
				where lgh_number in (select rt_Leg from #QualifyingRTs)

			drop table #QualifyingRTs
		end


	Select mov_number
		,lgh_number
		,ord_hdrnumber
		,lgh_tractor
		,lgh_driver1
		,lgh_driver2
		,lgh_trailer1
		,lgh_trailer2
		,ord_totalmiles
		,ord_startdate
		,ord_completiondate
		,lgh_startdate
		,lgh_enddate
		,LegTravelMiles
		,LegLoadedMiles
		,LegEmptyMiles
		,MoveStartDate
		,MoveEndDate
		,CountOfOrdersOnThisLeg
		,CountOfLegsForThisOrder
		,GrossLegMilesForOrder
		,GrossLDLegMilesForOrder
		,GrossBillMilesForLeg
	into #TempAllTriplets
	from ResNow_Triplets (NOLOCK)
	Where Exists 
		(
			Select * 
			from @TempTriplets TT 
			where TT.mov_number = ResNow_Triplets.mov_number
		)
--	OR Exists (Select ord_hdrnumber from @TempTriplets TT where TT.ord_hdrnumber = ResNow_Triplets.ord_hdrnumber)
--	Where mov_number in (Select mov_number from @TempTriplets)
--	OR ord_hdrnumber in (Select ord_hdrnumber from @TempTriplets)

	Insert into #TempAllTriplets
	Select mov_number
		,lgh_number
		,ord_hdrnumber
		,lgh_tractor
		,lgh_driver1
		,lgh_driver2
		,lgh_trailer1
		,lgh_trailer2
		,ord_totalmiles
		,ord_startdate
		,ord_completiondate
		,lgh_startdate
		,lgh_enddate
		,LegTravelMiles
		,LegLoadedMiles
		,LegEmptyMiles
		,MoveStartDate
		,MoveEndDate
		,CountOfOrdersOnThisLeg
		,CountOfLegsForThisOrder
		,GrossLegMilesForOrder
		,GrossLDLegMilesForOrder
		,GrossBillMilesForLeg
	from ResNow_Triplets (NOLOCK)
	Where Exists 
		(
			Select * 
			from @TempTriplets TT 
			where TT.ord_hdrnumber = ResNow_Triplets.ord_hdrnumber
		)
	-- not ALREADY in the #TempAllTriplets table
	AND NOT Exists 
		(
			Select * 
			from #TempAllTriplets TAT 
			where TAT.lgh_number = ResNow_Triplets.lgh_number
			AND TAT.mov_number = ResNow_Triplets.mov_number
			AND TAT.ord_hdrnumber = ResNow_Triplets.ord_hdrnumber
		)


	SELECT RoundTrip = RT.rt_StartLeg
		,TT.ord_hdrnumber 
		,OrderNumber = IsNull(orderheader.ord_number,TT.ord_hdrnumber)
		,MoveNumber = TT.mov_number
		,LegNumber = TT.Lgh_number
		,OrderedBy = IsNull(orderheader.ord_company,'')
		,BillTo = IsNull(orderheader.ord_billto,'')
		,BillToName = IsNull(BillToCompany.cmp_name,'')
		,Shipper = IsNull(orderheader.ord_shipper,L.cmp_id_start)
		,ShipperName = Convert(varchar(100),'') -- (select cmp_name from company (NOLOCK) where cmp_id = IsNull(ord_shipper,cmp_id_start))
		,ShipperLocation = Convert(varchar(30),'') -- IsNull((Select cty_nmstct from City (NOLOCK) where City.cty_code = Orderheader.ord_origincity),'UNKNOWN')
		,orderheader.ord_origincity
		,ShipDate = IsNull(orderheader.ord_startdate,L.lgh_startdate)
		,Consignee = IsNull(orderheader.ord_consignee,L.cmp_id_end)
		,ConsigneeName = Convert(varchar(100),'') -- (select cmp_name from company (NOLOCK) where cmp_id = IsNull(ord_consignee,cmp_id_end))
		,ConsigneeLocation = Convert(varchar(30),'') -- IsNull((Select cty_nmstct from City (NOLOCK) where City.cty_code = Orderheader.ord_destcity),'UNKNOWN')
		,orderheader.ord_destcity
		,LegEndState = L.lgh_rendstate 
		,OutBoundLegEndState = Convert(varchar(2),'')
		,DeliveryDate = IsNull(orderheader.ord_completiondate,L.lgh_enddate)
		,TAT.MoveStartDate
		,LegStartDate = TAT.lgh_startdate
		,LegEndDate = TAT.lgh_enddate
		,TAT.MoveEndDate
		,DriverID = TAT.lgh_driver1
		,Tractor = TAT.lgh_tractor
		,Trailer = TAT.lgh_trailer1		--= Convert(varchar(15),'')
		,RevType1 = Convert(varchar(20),IsNull(orderheader.ord_revtype1,L.lgh_class1))
		,RevType2 = Convert(varchar(20),IsNull(orderheader.ord_revtype2,L.lgh_class2))
		,RevType3 = Convert(varchar(20),IsNull(orderheader.ord_revtype3,L.lgh_class3))
		,RevType4 = Convert(varchar(20),IsNull(orderheader.ord_revtype4,L.lgh_class4))
-- revenue
		,SelectedRevenue = ISNULL(dbo.fnc_TMWRN_XDRevenue('Order',0,DEFAULT,DEFAULT,TT.ord_hdrnumber,DEFAULT,DEFAULT,DEFAULT,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0)
-- cost
		,SelectedPay = IsNull(dbo.fnc_TMWRN_Pay('Segment',default,default,L.mov_number,default,L.lgh_number,@IncludePayTypeList,@ExcludePayTypeList,@PreTaxYN,default),0.00)
-- miles
		,TravelMiles = Convert(float, LegTravelMiles) 
		,LoadedMiles = Convert(float, LegLoadedMiles)
		,EmptyMiles = Convert(float, LegEmptyMiles)
		,BillMiles = Convert(float, TAT.ord_totalmiles) -- IsNull((select sum(stp_lgh_mileage) from stops (NOLOCK) where stops.lgh_number = l.lgh_number),0)
		,LoadCount = Convert(float,0.0)
		,OrderCount = Convert(float,1.0)
		,RoundTripCount = Convert(float,0.0)
		,InvoiceStatus = ord_invoicestatus
		,Weight = Convert(float,0.0)
		,WeightUOM = 'LBS'
		,Volume = Convert(float,0.0)
		,VolumeUOM = 'GAL'
		,PkgCount = Convert(float,0.0)
		,PkgCountUOM = Convert(varchar(10),'')
		,LegPct = 
			Case when GrossBillMilesForLeg > 0 Then
				TAT.ord_totalmiles / GrossBillMilesForLeg
			Else
				Convert(float,1 / CountOfOrdersOnThisLeg)
			End
		,OrderPct = 
			Case when TT.ord_hdrnumber < 0 then
				0
			Else
				Case when @UseTravelMilesForAllocationsYN = 'Y' then
					Case when GrossLegMilesForOrder > 0 Then
						LegTravelMiles / GrossLegMilesForOrder
					Else
						Convert(float,1 / CountOfLegsForThisOrder)
					End
				Else
					Case when GrossLDLegMilesForOrder > 0 Then
						LegLoadedMiles / GrossLDLegMilesForOrder
					Else
						Convert(float,1 / CountOfLegsForThisOrder)
					End
				End
			End
		,CurrentStatus = 
			Case 
				when @DateType like 'Move%' then L.lgh_outstatus 
				when @DateType like 'Leg%' then L.lgh_outstatus
			Else
				IsNull(orderheader.ord_status,L.lgh_outstatus)
			End		
		,RoundTripStatus = RT.rt_Status
	Into #LegList
	FROM @TempTriplets TT inner Join #TempAllTriplets TAT on TT.lgh_number = TAT.lgh_number AND TT.ord_hdrnumber = TAT.ord_hdrnumber
		inner join DW_RTLegCache RT (NOLOCK) on TT.lgh_number = RT.rt_Leg
		inner join Legheader L (NOLOCK) on TT.lgh_number = L.lgh_number
		inner join ResNow_DriverCache_Final DCF (NOLOCK) on TAT.lgh_driver1 = DCF.driver_id AND TAT.lgh_startdate >= DCF.driver_DateStart AND TAT.lgh_startdate < DCF.driver_DateEnd
		inner join ResNow_TrailerCache_Final TDF (NOLOCK) on TAT.lgh_trailer1 = TDF.trailer_id AND TAT.lgh_startdate >= TDF.trailer_DateStart AND TAT.lgh_startdate < TDF.trailer_DateEnd
		inner join ResNow_TractorCache_Final TCF (NOLOCK) on TAT.lgh_tractor = TCF.tractor_id AND TAT.lgh_startdate >= TCF.tractor_DateStart AND TAT.lgh_startdate < TCF.tractor_DateEnd
		left Join orderheader (NOLOCK) ON TT.ord_hdrnumber = orderheader.ord_hdrnumber
		left Join company BillToCompany (NOLOCK) on orderheader.ord_billto = BillToCompany.cmp_id
--		inner join ResNow_DriverCache_Final DCF (NOLOCK) on TAT.lgh_driver1 = DCF.driver_id
	WHERE 
--	TAT.lgh_startdate >= TDF.trailer_DateStart AND TAT.lgh_startdate < TDF.trailer_DateEnd
--	AND TAT.lgh_startdate >= TCF.tractor_DateStart AND TAT.lgh_startdate < TCF.tractor_DateEnd
--	AND TAT.lgh_startdate >= DCF.driver_DateStart AND TAT.lgh_startdate < DCF.driver_DateEnd
	-- transaction-grain filters
--	AND 
	(@OnlyRevType1List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype1,L.lgh_class1) + ',', @OnlyRevType1List) > 0)
	AND (@OnlyRevType2List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype2,L.lgh_class2) + ',', @OnlyRevType2list) > 0)
	AND (@OnlyRevType3List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype3,L.lgh_class3) + ',', @OnlyRevType3List) > 0)
	AND (@OnlyRevType4List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype4,L.lgh_class4) + ',', @OnlyRevType4List) > 0)

	AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype1,L.lgh_class1) + ',', @ExcludeRevType1List) = 0)
	AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype2,L.lgh_class2) + ',', @ExcludeRevType2List) = 0)
	AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype3,L.lgh_class3) + ',', @ExcludeRevType3List) = 0)
	AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + IsNull(orderheader.ord_revtype4,L.lgh_class4) + ',', @ExcludeRevType4List) = 0)

	AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + L.trc_type1 + ',', @OnlyTrcType1List) > 0)
	AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + L.trc_type2 + ',', @OnlyTrcType2List) > 0)
	AND (@OnlyTrcType3List =',,' or CHARINDEX(',' + L.trc_type3 + ',', @OnlyTrcType3List) > 0)
	AND (@OnlyTrcType4List =',,' or CHARINDEX(',' + L.trc_type4 + ',', @OnlyTrcType4List) > 0)
	AND (@OnlyTrcCompanyList =',,' or CHARINDEX(',' + L.trc_company + ',', @OnlyTrcCompanyList) > 0)
	AND (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + L.trc_division + ',', @OnlyTrcDivisionList) > 0)
	AND (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + L.trc_terminal + ',', @OnlyTrcTerminalList) > 0)
	AND (@OnlyTrcFleetList =',,' or CHARINDEX(',' + L.trc_fleet + ',', @OnlyTrcFleetList) > 0)
	AND (@OnlyTrcBranchList =',,' or CHARINDEX(',' + TCF.tractor_branch + ',', @OnlyTrcBranchList) > 0)

	AND (@ExcludeTrcType1List =',,' or CHARINDEX(',' + L.trc_type1 + ',', @ExcludeTrcType1List) = 0)
	AND (@ExcludeTrcType2List =',,' or CHARINDEX(',' + L.trc_type2 + ',', @ExcludeTrcType2List) = 0)
	AND (@ExcludeTrcType3List =',,' or CHARINDEX(',' + L.trc_type3 + ',', @ExcludeTrcType3List) = 0)
	AND (@ExcludeTrcType4List =',,' or CHARINDEX(',' + L.trc_type4 + ',', @ExcludeTrcType4List) = 0)
	AND (@ExcludeTrcCompanyList =',,' or CHARINDEX(',' + L.trc_company + ',', @ExcludeTrcCompanyList) = 0)
	AND (@ExcludeTrcDivisionList =',,' or CHARINDEX(',' + L.trc_division + ',', @ExcludeTrcDivisionList) = 0)
	AND (@ExcludeTrcTerminalList =',,' or CHARINDEX(',' + L.trc_terminal + ',', @ExcludeTrcTerminalList) = 0)
	AND (@ExcludeTrcFleetList =',,' or CHARINDEX(',' + L.trc_fleet + ',', @ExcludeTrcFleetList) = 0)
	AND (@ExcludeTrcBranchList =',,' or CHARINDEX(',' + TCF.tractor_branch + ',', @ExcludeTrcBranchList) = 0)


-- use the @TempALLTriplets table to limit the WORKING counts for Tractors & Drivers
	Delete from #LegList Where CurrentStatus <> 'AVL' AND Tractor = 'UNKNOWN'

	If @OnlyFirstBillToList <> ',,'
		begin
			Select RoundTrip 
			into #WrongBillToList
			from #LegList
			where RoundTrip = LegNumber
			AND CHARINDEX(',' + BillTo + ',', @OnlyFirstBillToList) = 0

			Delete from #LegList where RoundTrip in (select RoundTrip from #WrongBillToList)
			
			Drop table #WrongBillToList
		end

	-- set @TractorCount
	If @Numerator = 'TractorCount' OR @Denominator = 'TractorCount'
		Begin
			Set @TractorCount = (select count(distinct Tractor) from #LegList)
		End

	-- do fact allocations
	Update #LegList set OrderCount = Round(OrderPct,5,0)
	,BillMiles = Round(BillMiles * OrderPct,4,0)
	,SelectedRevenue = Round(SelectedRevenue * OrderPct,5,0)

	Update #LegList set TravelMiles = Round(TravelMiles * LegPct,4,0)
	,LoadedMiles = Round(LoadedMiles * LegPct,4,0)
	,EmptyMiles = Round(EmptyMiles * LegPct,4,0)
	,SelectedPay = Round(SelectedPay * LegPct,5,0)

	-- set LoadCount; by Leg COUNT to account for zero mile moves
	Select distinct mov_number
	,lgh_number
	,LegTravelMiles
	into #TempCalcTriplets
	from #TempAllTriplets

	Select mov_number
	,count(distinct lgh_number) as LegCount
	,sum(LegTravelMiles / CountOfOrdersOnThisLeg) as MoveMiles
	into #TempLegCount
	from #TempAllTriplets
	group by mov_number

	Update #LegList set LoadCount = Round(1.0 / Convert(float,LegCount),2,0)
	from #TempLegCount
	where #LegList.MoveNumber = #TempLegCount.mov_number

	-- set LoadCount; by Miles if miles not zero
	Update #LegList set LoadCount = Round(Convert(float,TravelMiles) / Convert(float,MoveMiles),2,0)
	from #TempLegCount
	where #LegList.MoveNumber = #TempLegCount.mov_number
	AND #TempLegCount.MoveMiles > 0

	-- set RoundTripCount
	Select RoundTrip,convert(float,SUM(TravelMiles)) as RTMileage
	into #RTMileage
	from #LegList
	group by RoundTrip

	Update #RTMileage set RTMileage = 1
	where RTMileage <= 0

	Update #LegList set RoundTripCount = Round(TravelMiles / RTMileage,4)
	from #RTMileage
	where #LegList.RoundTrip = #RTMileage.RoundTrip
	
	-- set Weight
	If @Numerator = 'Weight' OR @Denominator = 'Weight' OR @ShowDetail > 0
		Begin
			Update #LegList set Weight = 
				IsNull(	(
							Select Sum(dbo.fnc_TMWRN_UnitConversion(fgt_weightunit,@WeightUOM,IsNull(fgt_weight,0)))
							from freightdetail (NOLOCK) join stops (NOLOCK) on freightdetail.stp_number = stops.stp_number
							where stops.lgh_number = #LegList.LegNumber
							AND stops.ord_hdrnumber = #LegList.ord_hdrnumber
							AND stops.stp_type = 'DRP'
						),0)
		End

	-- set Volume
	If @Numerator = 'Volume' OR @Denominator = 'Volume' OR @ShowDetail > 0
		Begin
			Update #LegList set Volume = 
				IsNull(	(
							Select Sum(dbo.fnc_TMWRN_UnitConversion(fgt_volumeunit,@VolumeUOM,IsNull(fgt_volume,0)))
							from freightdetail (NOLOCK) join stops (NOLOCK) on freightdetail.stp_number = stops.stp_number
							where stops.lgh_number = #LegList.LegNumber
							AND stops.ord_hdrnumber = #LegList.ord_hdrnumber
--							AND freightdetail.cmd_code = #LegList.CommodityID
							AND stops.stp_type = 'DRP'
						),0)
		End

	-- set PkgCount
	If @Numerator = 'PkgCount' OR @Denominator = 'PkgCount' OR @ShowDetail > 0
		Begin
			Update #LegList set 
				PkgCount = 
					IsNull(	(
								Select Sum(IsNull(fgt_count,0))
								from freightdetail (NOLOCK) join stops (NOLOCK) on freightdetail.stp_number = stops.stp_number
								where stops.lgh_number = #LegList.LegNumber
								AND stops.ord_hdrnumber = #LegList.ord_hdrnumber
--								AND freightdetail.cmd_code = #LegList.CommodityID
								AND stops.stp_type = 'DRP'
							),0)
				,PkgCountUOM = 
					IsNull(	(
								Select Top 1 fgt_countunit
								from freightdetail (NOLOCK) join stops (NOLOCK) on freightdetail.stp_number = stops.stp_number
								where stops.lgh_number = #LegList.LegNumber
								AND stops.ord_hdrnumber = #LegList.ord_hdrnumber
--								AND freightdetail.cmd_code = #LegList.CommodityID
								AND stops.stp_type = 'DRP'
							),'Each')
		End

	Set @ThisCount = 
		Case 
			When @Numerator = 'Revenue' then (Select sum(SelectedRevenue) from #LegList)
			When @Numerator = 'Cost' then (Select sum(SelectedPay) from #LegList)
			When @Numerator = 'Margin' then (Select sum(SelectedRevenue) - sum(SelectedPay) from #LegList)
			When @Numerator = 'LoadCount' then (Select sum(LoadCount) from #LegList)
			When @Numerator = 'OrderCount' then (Select sum(OrderCount) from #LegList)
			When @Numerator = 'Weight' then (Select sum(Weight) from #LegList)
			When @Numerator = 'Volume' then (Select sum(Volume) from #LegList)
			When @Numerator = 'LoadedMile' then (Select sum(LoadedMiles) from #LegList)
			When @Numerator = 'EmptyMile' then (Select sum(EmptyMiles) from #LegList)
			When @Numerator = 'BillMile' then (Select sum(BillMiles) from #LegList)
			When @Numerator = 'RTCount' then (Select Round(SUM(RoundTripCount),0) from #LegList)
		Else -- @Numerator = 'TravelMile'
			(Select sum(TravelMiles) From #LegList) -- When @Numerator = 'Mile'
		End

	Set @ThisTotal =
		Case
			When @Denominator = 'Revenue' then (Select sum(SelectedRevenue) from #LegList)
			When @Denominator = 'Cost' then (Select sum(SelectedPay) from #LegList)
			When @Denominator = 'TravelMile' then (Select sum(TravelMiles) From #LegList)
			When @Denominator = 'LoadedMile' then (Select sum(LoadedMiles) From #LegList)
			When @Denominator = 'EmptyMile' then (Select sum(EmptyMiles) From #LegList)
			When @Denominator = 'BillMile' then (Select sum(BillMiles) from #LegList)
			When @Denominator = 'LoadCount' then (Select sum(LoadCount) From #LegList)
			When @Denominator = 'OrderCount' then (Select sum(OrderCount) from #LegList)
			When @Denominator = 'Weight' then (Select sum(Weight) from #LegList)
			When @Denominator = 'Volume' then (Select sum(Volume) from #LegList)
			When @Denominator = 'TractorCount' then @TractorCount
			When @Denominator = 'RTCount' then (Select count(distinct RoundTrip) from #LegList)
		Else -- @Denominator = 'Day'
			CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) 
			END
		End



	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 


	If @ShowDetail > 0	-- get textual information we need for good data display
		Begin
			Update #LegList set ShipperName = company.cmp_name
			From company (NOLOCK)
			Where #LegList.Shipper = company.cmp_id 

			Update #LegList set ConsigneeName = company.cmp_name
			From company (NOLOCK)
			Where #LegList.Consignee = company.cmp_id 

			Update #LegList set ShipperLocation = city.cty_nmstct
			From city (NOLOCK)
			Where #LegList.ord_origincity = city.cty_code

			Update #LegList set ConsigneeLocation = city.cty_nmstct
			From city (NOLOCK)
			Where #LegList.ord_destcity = city.cty_code

/*
			Update #LegList set Trailer = 
				(
					select top 1 evt_trailer1
					from event (NOLOCK)
					where #LegList.ord_hdrnumber = event.ord_hdrnumber
					AND evt_pu_dr = 'PUP'
				)
*/

			Update #LegList set RevType1 = LF.Name
			From labelfile LF (NOLOCK)
			Where LF.labeldefinition = 'RevType1'
			AND #LegList.RevType1 = LF.ABBR

			Update #LegList set RevType2 = LF.Name
			From labelfile LF (NOLOCK)
			Where LF.labeldefinition = 'RevType2'
			AND #LegList.RevType2 = LF.ABBR

			Update #LegList set RevType3 = LF.Name
			From labelfile LF (NOLOCK)
			Where LF.labeldefinition = 'RevType3'
			AND #LegList.RevType3 = LF.ABBR

			Update #LegList set RevType4 = LF.Name
			From labelfile LF (NOLOCK)
			Where LF.labeldefinition = 'RevType4'
			AND #LegList.RevType4 = LF.ABBR

			Update #LegList set LegEndState = LH.lgh_endstate
			from legheader LH (NOLOCK) 
			Where #LegList.LegNumber = LH.lgh_number
			AND LH.lgh_split_flag = 'S'

			select LegNumber,LegEndState
			into #RoundTripStates
			from #LegList
			where RoundTrip = LegNumber

			Update #LegList set OutBoundLegEndState = T1.LegEndState
			from #RoundTripStates T1
			where T1.LegNumber = #LegList.RoundTrip

		End

	If @ShowDetail = 1
		BEGIN
			SELECT RevType1
			,RoundTrips = Round(SUM(RoundTripCount),0)
			,Revenue = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			,PTE = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
			,Margin = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
			,LoadCount = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),4)
			,OrderCount = dbo.fnc_TMWRN_FormatNumbers(Sum(OrderCount),4)
			,Weight = dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0)
			,Volume = dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0)
			,LoadedMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadedMiles),0)
			,EmptyMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(EmptyMiles),0)
			,TravelMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0)
			,RevenuePerMile = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(TravelMiles) > 0 Then
					Sum(SelectedRevenue) / Sum(TravelMiles) 
				Else
					0
				End,2)
			,PTEPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * (Sum(SelectedPay) / Sum(SelectedRevenue))
				Else
					0
				End,2) + '%'
			,MarginPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
			,MarginPerLoad = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(LoadCount) > 0 Then
					Round((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(LoadCount),2)
				Else
					0
				End,0)
			FROM #LegList
			Group by RevType1
			order by RevType1
		END
	Else If @ShowDetail = 2
		BEGIN	
			SELECT RevType1
			,RevType2
			,RoundTrips = Round(SUM(RoundTripCount),0)
			,Revenue = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			,PTE = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
			,Margin = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
			,LoadCount = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),4)
			,OrderCount = dbo.fnc_TMWRN_FormatNumbers(Sum(OrderCount),4)
			,Weight = dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0)
			,Volume = dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0)
			,LoadedMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadedMiles),0)
			,EmptyMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(EmptyMiles),0)
			,TravelMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0)
			,RevenuePerMile = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(TravelMiles) > 0 Then
					Sum(SelectedRevenue) / Sum(TravelMiles) 
				Else
					0
				End,2)
			,PTEPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * (Sum(SelectedPay) / Sum(SelectedRevenue))
				Else
					0
				End,2) + '%'
			,MarginPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
			,MarginPerLoad = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(LoadCount) > 0 Then
					Round((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(LoadCount),2)
				Else
					0
				End,0)
			FROM #LegList
			Group by RevType1,RevType2
			order by RevType1,RevType2

		END
	Else If @ShowDetail = 3
		BEGIN
			SELECT RevType1
			,RevType2
			,RevType3
			,RoundTrips = Round(SUM(RoundTripCount),0)
			,Revenue = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			,PTE = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
			,Margin = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
			,LoadCount = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),4)
			,OrderCount = dbo.fnc_TMWRN_FormatNumbers(Sum(OrderCount),4)
			,Weight = dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0)
			,Volume = dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0)
			,LoadedMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadedMiles),0)
			,EmptyMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(EmptyMiles),0)
			,TravelMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0)
			,RevenuePerMile = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(TravelMiles) > 0 Then
					Sum(SelectedRevenue) / Sum(TravelMiles) 
				Else
					0
				End,2)
			,PTEPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * (Sum(SelectedPay) / Sum(SelectedRevenue))
				Else
					0
				End,2) + '%'
			,MarginPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
			,MarginPerLoad = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(LoadCount) > 0 Then
					Round((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(LoadCount),2)
				Else
					0
				End,0)
			FROM #LegList --join dbo.fnc_BranchHierarchyForRN() BH on #LegList.ReportingHierarchy = BH.RowID 
			Group by RevType1,RevType2,RevType3
			order by RevType1,RevType2,RevType3
		END
	Else If @ShowDetail = 4
		BEGIN
			SELECT RevType1
			,RevType2
			,RevType3
			,RevType4
			,RoundTrips = Round(SUM(RoundTripCount),0)
			,Revenue = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			,PTE = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
			,Margin = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
			,LoadCount = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),4)
			,OrderCount = dbo.fnc_TMWRN_FormatNumbers(Sum(OrderCount),4)
			,Weight = dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0)
			,Volume = dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0)
			,LoadedMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadedMiles),0)
			,EmptyMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(EmptyMiles),0)
			,TravelMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0)
			,RevenuePerMile = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(TravelMiles) > 0 Then
					Sum(SelectedRevenue) / Sum(TravelMiles) 
				Else
					0
				End,2)
			,PTEPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * (Sum(SelectedPay) / Sum(SelectedRevenue))
				Else
					0
				End,2) + '%'
			,MarginPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
			,MarginPerLoad = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(LoadCount) > 0 Then
					Round((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(LoadCount),2)
				Else
					0
				End,0)
			FROM #LegList --join dbo.fnc_BranchHierarchyForRN() BH on #LegList.ReportingHierarchy = BH.RowID 
			Group by RevType1,RevType2,RevType3,RevType4
			order by RevType1,RevType2,RevType3,RevType4
		END
	Else If @ShowDetail = 5
		BEGIN
			SELECT DriverID
			,RoundTrips = Round(SUM(RoundTripCount),0)
			,Revenue = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			,PTE = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
			,Margin = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
			,LoadCount = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),4)
			,OrderCount = dbo.fnc_TMWRN_FormatNumbers(Sum(OrderCount),4)
			,Weight = dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0)
			,Volume = dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0)
			,LoadedMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadedMiles),0)
			,EmptyMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(EmptyMiles),0)
			,TravelMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0)
			,RevenuePerMile = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(TravelMiles) > 0 Then
					Sum(SelectedRevenue) / Sum(TravelMiles) 
				Else
					0
				End,2)
			,PTEPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * (Sum(SelectedPay) / Sum(SelectedRevenue))
				Else
					0
				End,2) + '%'
			,MarginPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
			,MarginPerLoad = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(LoadCount) > 0 Then
					Round((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(LoadCount),2)
				Else
					0
				End,0)
			FROM #LegList
			Group by DriverID
			order by DriverID
		END
	Else If @ShowDetail = 6
		BEGIN
			SELECT Tractor
			,RoundTrips = Round(SUM(RoundTripCount),0)
			,Revenue = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			,PTE = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
			,Margin = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
			,LoadCount = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),4)
			,OrderCount = dbo.fnc_TMWRN_FormatNumbers(Sum(OrderCount),4)
			,Weight = dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0)
			,Volume = dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0)
			,LoadedMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadedMiles),0)
			,EmptyMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(EmptyMiles),0)
			,TravelMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0)
			,RevenuePerMile = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(TravelMiles) > 0 Then
					Sum(SelectedRevenue) / Sum(TravelMiles) 
				Else
					0
				End,2)
			,PTEPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * (Sum(SelectedPay) / Sum(SelectedRevenue))
				Else
					0
				End,2) + '%'
			,MarginPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
			,MarginPerLoad = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(LoadCount) > 0 Then
					Round((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(LoadCount),2)
				Else
					0
				End,0)
			FROM #LegList
			Group by Tractor
			order by Tractor
		END
	Else If @ShowDetail = 7
		BEGIN
			SELECT RoundTrip
			,RoundTripStatus
			,RoundTrips = Round(SUM(RoundTripCount),0)
			,Revenue = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			,PTE = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
			,Margin = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
			,LoadCount = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),4)
			,OrderCount = dbo.fnc_TMWRN_FormatNumbers(Sum(OrderCount),4)
			,Weight = dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0)
			,Volume = dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0)
			,LoadedMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadedMiles),0)
			,EmptyMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(EmptyMiles),0)
			,TravelMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0)
			,RevenuePerMile = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(TravelMiles) > 0 Then
					Sum(SelectedRevenue) / Sum(TravelMiles) 
				Else
					0
				End,2)
			,PTEPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * (Sum(SelectedPay) / Sum(SelectedRevenue))
				Else
					0
				End,2) + '%'
			,MarginPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
			,MarginPerLoad = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(LoadCount) > 0 Then
					Round((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(LoadCount),2)
				Else
					0
				End,0)
			FROM #LegList
			Group by RoundTrip,RoundTripStatus
			order by RoundTrip
		END
	Else If @ShowDetail = 8	-- by VisitedStates
		BEGIN
			SELECT LegEndState
			,RoundTrips = Round(SUM(RoundTripCount),0)
			,Revenue = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			,PTE = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
			,Margin = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
			,LoadCount = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),4)
			,OrderCount = dbo.fnc_TMWRN_FormatNumbers(Sum(OrderCount),4)
			,Weight = dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0)
			,Volume = dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0)
			,LoadedMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadedMiles),0)
			,EmptyMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(EmptyMiles),0)
			,TravelMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0)
			,RevenuePerMile = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(TravelMiles) > 0 Then
					Sum(SelectedRevenue) / Sum(TravelMiles) 
				Else
					0
				End,2)
			,PTEPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * (Sum(SelectedPay) / Sum(SelectedRevenue))
				Else
					0
				End,2) + '%'
			,MarginPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
			,MarginPerLoad = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(LoadCount) > 0 Then
					Round((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(LoadCount),2)
				Else
					0
				End,0)
			FROM #LegList
			Group by LegEndState
			order by LegEndState
		END
	Else If @ShowDetail = 9	-- by 1stOutboundState
		BEGIN
			SELECT OutboundLegEndState
			,RoundTrips = Round(SUM(RoundTripCount),0)
			,Revenue = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			,PTE = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
			,Margin = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
			,LoadCount = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),4)
			,OrderCount = dbo.fnc_TMWRN_FormatNumbers(Sum(OrderCount),4)
			,Weight = dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0)
			,Volume = dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0)
			,LoadedMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadedMiles),0)
			,EmptyMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(EmptyMiles),0)
			,TravelMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0)
			,RevenuePerMile = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(TravelMiles) > 0 Then
					Sum(SelectedRevenue) / Sum(TravelMiles) 
				Else
					0
				End,2)
			,PTEPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * (Sum(SelectedPay) / Sum(SelectedRevenue))
				Else
					0
				End,2) + '%'
			,MarginPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
			,MarginPerLoad = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(LoadCount) > 0 Then
					Round((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(LoadCount),2)
				Else
					0
				End,0)
			FROM #LegList
			Group by OutboundLegEndState
			order by OutboundLegEndState
		END
	Else If @ShowDetail = 10	-- by 1stBillTo
		BEGIN
			Select BillTo as FirstRTBillto
			,RoundTrip
			into #FirstBillToListing
			from #LegList
			where RoundTrip = LegNumber
		
			SELECT FirstRTBillto
			,RoundTrips = Round(SUM(RoundTripCount),0)
			,Revenue = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			,PTE = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
			,Margin = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
			,LoadCount = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),4)
			,OrderCount = dbo.fnc_TMWRN_FormatNumbers(Sum(OrderCount),4)
			,Weight = dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0)
			,Volume = dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0)
			,LoadedMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadedMiles),0)
			,EmptyMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(EmptyMiles),0)
			,TravelMiles = dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0)
			,RevenuePerMile = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(TravelMiles) > 0 Then
					Sum(SelectedRevenue) / Sum(TravelMiles) 
				Else
					0
				End,2)
			,PTEPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * (Sum(SelectedPay) / Sum(SelectedRevenue))
				Else
					0
				End,2) + '%'
			,MarginPercent = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
			,MarginPerLoad = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(LoadCount) > 0 Then
					Round((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(LoadCount),2)
				Else
					0
				End,0)
			FROM #LegList join #FirstBillToListing on #LegList.RoundTrip = #FirstBillToListing.RoundTrip
			Group by FirstRTBillto
			order by FirstRTBillto
		END
	Else If @ShowDetail = 11
		Begin
			SELECT RoundTrip
			,OrderNumber 
			,MoveNumber
			,LegNumber
			,OrderedBy
			,BillTo
			,BillToName
			,Shipper
			,ShipperName
			,ShipperLocation
			,ShipDate
			,Consignee
			,ConsigneeName
			,ConsigneeLocation
			,DeliveryDate
			,MoveStartDate
			,LegStartDate
			,LegEndDate
			,MoveEndDate
			,DriverID
			,Tractor
			,Trailer
			,RevType1
			,RevType2
			,RevType3
			,RevType4
			,SelectedRevenue
			,SelectedPay
			,TravelMiles
			,LoadedMiles
			,EmptyMiles
			,BillMiles
			,LoadCount
			,OrderCount
			,RoundTripCount
			,InvoiceStatus 
			,Weight
			,Volume
			,PkgCount
			,LegPct
			,OrderPct
			,CurrentStatus
			,RoundTripStatus
			From #LegList
			Order by RoundTrip,LegStartDate
		End

	SET NOCOUNT OFF


-- Part 3

	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'Asset_MarginPerTravelMileRT',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 112, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Revenue, Expense, Ops Metrics for Assets',
		@sCaptionFull = '60+ Measurements for trips by Assets',
		@sProcedureName = 'Metric_OpsByAssetsXDRT',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = null

	</METRIC-INSERT-SQL>
	*/

GO
GRANT EXECUTE ON  [dbo].[Metric_OpsByAssetsXDRT] TO [public]
GO
