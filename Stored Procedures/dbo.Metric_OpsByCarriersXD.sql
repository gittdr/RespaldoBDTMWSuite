SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 2

CREATE  PROCEDURE [dbo].[Metric_OpsByCarriersXD]
	(
		@Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,
	-- Additional / Optional Parameters
		@DateType varchar(50) = 'MoveStart',			-- MoveStart,MoveEnd,LegStart,LegEnd,OrderStart,OrderEnd,PlanDate,ChgToStarted
		@Numerator varchar(20) = 'Margin',				-- Revenue,Cost,Margin,TravelMile,LoadedMile,EmptyMile,BillMile,LoadCount,OrderCount,Weight,Volume
		@Denominator varchar(20) = 'Revenue',			-- Revenue,Cost,TravelMile,LoadedMile,EmptyMile,BillMile,Day,LoadCount,OrderCount,Weight,Volume
		@EliminateAssetLoadsYN char(1) = 'Y',
	-- revenue related parameters
		@InvoiceStatusList varchar(128) = '',
		@DispatchStatusList varchar(255) = '',
		@IncludeMiscInvoicesYN char(1) = 'N',
		@ExcludeZeroRatedInvoicesYN char(1) = 'N',
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
	-- filtering parameters: includes
		@OnlyRevType1List varchar(255) ='',
		@OnlyRevType2List varchar(255) ='',
		@OnlyRevType3List varchar(255) ='',
		@OnlyRevType4List varchar(255) ='',
		
		@OnlySalesRepList varchar(255) = '',
		@OnlyBookedByList varchar(255) = '',
		@OnlyBookingTermList varchar(255) = '',
		@OnlyExecutingTermList varchar(255) = '',
		
		@OnlyBillToList varchar(255) = '',
		@OnlyShipperList varchar(255) = '',
		@OnlyShipperCityList varchar(255) = '',
		@OnlyConsigneeList varchar(255) = '',
		@OnlyConsigneeCityList varchar(255) = '',
		@OnlyOrderedByList varchar(255) = '',
		@OnlyCarrierList varchar(255) = '',
		@OnlyCarrierPayToList varchar(255) = '',
	-- filtering parameters: excludes
		@ExcludeRevType1List varchar(255) ='',
		@ExcludeRevType2List varchar(255) ='',
		@ExcludeRevType3List varchar(255) ='',
		@ExcludeRevType4List varchar(255) ='',

		@ExcludeSalesRepList varchar(255) = '',
		@ExcludeBookedByList varchar(255) = '',
		@ExcludeBookingTermList varchar(255) = '',
		@ExcludeExecutingTermList varchar(255) = '',

		@ExcludeBillToList varchar(255) = '',
		@ExcludeShipperList varchar(255) = '',
		@ExcludeShipperCityList varchar(255) = '',
		@ExcludeConsigneeList varchar(255) = '',
		@ExcludeConsigneeCityList varchar(255) = '',
		@ExcludeOrderedByList varchar(255) = '',
		@ExcludeCarrierList varchar(255)='',
		@ExcludeCarrierPayToList varchar(255) = '',

		@MetricCode varchar(255)= 'RevPTEBrokerXD'
	)
AS

	SET NOCOUNT ON

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:CRN,2:Terminal,3:Proyecto,4:Division,5:Vendedor,6:IngresadoPor,9:Cliente,10:Carrier,11:Viaje,12:Orden

	--Populate DEFAULT currency and currency date types
	EXEC PopulateSessionIDParamatersInProc 'Revenue', @MetricCode  

	If DateDiff(mi,IsNull((Select MAX(DateLastRefresh) from ResNow_TripletsLastRefresh),'19500101'),GetDate()) > 65
		Begin
			exec ResNow_UpdateTripletsAssets
		End

	Declare @OrderCount int

	SET @InvoiceStatusList = ',' + ISNULL(@InvoiceStatusList,'') + ','
	Set @DispatchStatusList= ',' + ISNULL(@DispatchStatusList,'') + ','

	SET @OnlyRevType1List= ',' + ISNULL(@OnlyRevType1List,'') + ','
	SET @OnlyRevType2List= ',' + ISNULL(@OnlyRevType2List,'') + ','
	SET @OnlyRevType3List= ',' + ISNULL(@OnlyRevType3List,'') + ','
	SET @OnlyRevType4List= ',' + ISNULL(@OnlyRevType4List,'') + ','
	Set @OnlyBillToList= ',' + ISNULL(@OnlyBillToList,'') + ','
	Set @OnlyShipperList= ',' + ISNULL(@OnlyShipperList,'') + ','
	Set @OnlyShipperCityList= ',' + ISNULL(@OnlyShipperCityList,'') + ','
	Set @OnlyConsigneeList= ',' + ISNULL(@OnlyConsigneeList,'') + ','
	Set @OnlyConsigneeCityList= ',' + ISNULL(@OnlyConsigneeCityList,'') + ','
	Set @OnlyOrderedByList= ',' + ISNULL(@OnlyOrderedByList,'') + ','
	Set @OnlyCarrierList= ',' + ISNULL(@OnlyCarrierList,'') + ','
	Set @OnlyCarrierPayToList= ',' + ISNULL(@OnlyCarrierPayToList,'') + ','

	SET @OnlySalesRepList= ',' + ISNULL(@OnlySalesRepList,'') + ','
	SET @OnlyBookedByList= ',' + ISNULL(@OnlyBookedByList,'') + ','
	SET @OnlyBookingTermList= ',' + ISNULL(@OnlyBookingTermList,'') + ','
	SET @OnlyExecutingTermList= ',' + ISNULL(@OnlyExecutingTermList,'') + ','

	SET @ExcludeRevType1List= ',' + ISNULL(@ExcludeRevType1List,'') + ','
	SET @ExcludeRevType2List= ',' + ISNULL(@ExcludeRevType2List,'') + ','
	SET @ExcludeRevType3List= ',' + ISNULL(@ExcludeRevType3List,'') + ','
	SET @ExcludeRevType4List= ',' + ISNULL(@ExcludeRevType4List,'') + ','

	Set @ExcludeBillToList= ',' + ISNULL(@ExcludeBillToList,'') + ','
	Set @ExcludeShipperList= ',' + ISNULL(@ExcludeShipperList,'') + ','
	Set @ExcludeShipperCityList= ',' + ISNULL(@ExcludeShipperCityList,'') + ','
	Set @ExcludeConsigneeList= ',' + ISNULL(@ExcludeConsigneeList,'') + ','
	Set @ExcludeConsigneeCityList= ',' + ISNULL(@ExcludeConsigneeCityList,'') + ','
	Set @ExcludeOrderedByList= ',' + ISNULL(@ExcludeOrderedByList,'') + ','
	Set @ExcludeCarrierList = ',' + ISNULL(@ExcludeCarrierList,'') + ','
	Set @ExcludeCarrierPayToList= ',' + ISNULL(@ExcludeCarrierPayToList,'') + ','

	SET @ExcludeSalesRepList= ',' + ISNULL(@ExcludeSalesRepList,'') + ','
	SET @ExcludeBookedByList= ',' + ISNULL(@ExcludeBookedByList,'') + ','
	SET @ExcludeBookingTermList= ',' + ISNULL(@ExcludeBookingTermList,'') + ','
	SET @ExcludeExecutingTermList= ',' + ISNULL(@ExcludeExecutingTermList,'') + ','


	Declare @TempTriplets Table (mov_number int, lgh_number int, ord_hdrnumber int)
	Declare @TempLastPlanned Table (PlannedOrder int)
	Declare @TempLastStarted Table (StartedOrder int)


	If (@DateType = 'MoveStart')
		begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where MoveStartDate >= @DateStart AND MoveStartDate < @DateEnd
		end
	Else If (@DateType = 'MoveEnd')
		begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where MoveEndDate >= @DateStart AND MoveEndDate < @DateEnd
		end
	Else If (@DateType = 'LegStart')
		Begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where lgh_startdate >= @DateStart AND lgh_startdate < @DateEnd
		End
	Else If (@DateType = 'LegEnd')
		Begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where lgh_enddate >= @DateStart AND lgh_enddate < @DateEnd
		End
	Else If (@DateType = 'OrderStart')
		Begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where ord_startdate >= @DateStart AND ord_startdate < @DateEnd
		End
	Else If (@DateType = 'OrderEnd')
		Begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where ord_completiondate >= @DateStart AND ord_completiondate < @DateEnd
		End
	Else If (@DateType = 'BookDate')
		Begin
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
				Select mov_number
				,lgh_number
				,ord_hdrnumber
				From ResNow_Triplets with (NOLOCK)
				where ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
		End
	ELSE IF (@DateType = 'PlanDate')
		BEGIN
			-- get orders planned today
			insert into @TempLastPlanned (PlannedOrder)
			select ROSC.ord_hdrnumber as PlannedOrder
			--,MAX(ROSC.updated_dt) as LastPlanDate 
			--into @TempLastPlanned
			from ResNow_OrderStatusChanges ROSC with (NOLOCK) 
			where ROSC.NextStatus in ('PLN','DSP','STD','CMP')
			AND NOT ROSC.PriorStatus in ('PLN','DSP','STD','CMP')
			group by ROSC.ord_hdrnumber
			having MAX(ROSC.updated_dt) >= @DateStart AND MAX(ROSC.updated_dt) < @DateEnd
			order by ROSC.ord_hdrnumber

			-- insert the valid triplets into the @TempTriplets table
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
			SELECT RNT.mov_number
			,RNT.lgh_number
			,T1.PlannedOrder 
			FROM @TempLastPlanned T1 join ResNow_Triplets RNT with (NOLOCK) on T1.PlannedOrder = RNT.ord_hdrnumber
			
			--drop table @TempLastPlanned
		END
	ELSE IF (@DateType='CHGTOSTARTED')
		BEGIN
			-- get orders started today
			insert into @TempLastStarted (StartedOrder)
			select ROSC.ord_hdrnumber as StartedOrder
			--,MAX(ROSC.updated_dt) as LastStartDate 
			--into @TempLastStarted
			from ResNow_OrderStatusChanges ROSC with (NOLOCK) 
			where ROSC.NextStatus in ('STD','CMP')
			AND NOT ROSC.PriorStatus in ('STD','CMP')
			group by ROSC.ord_hdrnumber
			having MAX(ROSC.updated_dt) >= @DateStart AND MAX(ROSC.updated_dt) < @DateEnd
			order by ROSC.ord_hdrnumber

			-- insert the valid triplets into the @TempTriplets table
			Insert into @TempTriplets (mov_number,lgh_number,ord_hdrnumber)
			SELECT RNT.mov_number
			,RNT.lgh_number
			,T1.StartedOrder 
			FROM @TempLastStarted T1 join ResNow_Triplets RNT with (NOLOCK) on T1.StartedOrder = RNT.ord_hdrnumber
			
			--drop table @TempLastStarted
		END

Declare @TempDeleteMoves Table (mov_number int)
Declare @TempStartedMoves Table (mov_number int)
Declare @TempDeleteLegs Table (lgh_number int)
Declare @TempDeleteOrders Table (ord_hdrnumber int)

	-- new code here to apply @DateType specific status level filtering
	If @DispatchStatusList <> ',,'
		Begin
			If @DateType Like 'Move%'
				Begin
					insert into @TempDeleteMoves (mov_number)
					Select TT.mov_number
					--into @TempDeleteMoves
					From @TempTriplets TT join legheader with (NOLOCK) on TT.mov_number = legheader.mov_number	
					-- select any moves that do NOT meet the dispatch criteria
					Where CHARINDEX(',' + lgh_outstatus + ',', @DispatchStatusList) = 0

					-- this code because possible for one leg of split trip to be in AVL or PLN status
					-- while other leg in STD or CMP status.  In this case, move IS started so we need
					-- to remove from delete list
					If CHARINDEX(',' + 'STD' + ',', @DispatchStatusList) > 0
						Begin
							insert into @TempStartedMoves (mov_number)
							select mov_number 
							--into @TempStartedMoves
							from legheader with (NOLOCK)
							where mov_number in (select mov_number from @TempDeleteMoves) 
							AND lgh_outstatus in ('STD','CMP')

							Delete from @TempDeleteMoves where mov_number in (select mov_number from @TempStartedMoves)
							--Drop Table @TempStartedMoves
						End

					Delete from @TempTriplets where mov_number in (select mov_number from @TempDeleteMoves)
					--Drop Table @TempDeleteMoves
				End
			Else If @DateType Like 'Leg%'
				Begin
					Insert into @TempDeleteLegs (lgh_number)
					Select TT.lgh_number
					--into @TempDeleteLegs
					From @TempTriplets TT join legheader with (NOLOCK) on TT.lgh_number = legheader.lgh_number	
					-- select any legs that do NOT meet the dispatch criteria
					Where CHARINDEX(',' + lgh_outstatus + ',', @DispatchStatusList) = 0

					Delete from @TempTriplets where lgh_number in (select lgh_number from @TempDeleteLegs)
					--Drop Table @TempDeleteLegs
				End
			Else	-- one of the Order type dates
				Begin
					Insert into @TempDeleteOrders (ord_hdrnumber)
					Select TT.ord_hdrnumber
					--into @TempDeleteOrders
					From @TempTriplets TT join orderheader with (NOLOCK) on TT.ord_hdrnumber = orderheader.ord_hdrnumber	
					-- select any orders that do NOT meet the dispatch criteria
					Where CHARINDEX(',' + ord_status + ',', @DispatchStatusList) = 0

					Delete from @TempTriplets where ord_hdrnumber in (select ord_hdrnumber from @TempDeleteOrders)
					--Drop Table @TempDeleteOrders
				End
		End

Declare @TempAllTriplets Table
	(
		mov_number int
		,lgh_number int
		,ord_hdrnumber int
		,ord_totalmiles float
		,ord_startdate datetime
		,ord_completiondate datetime
		,lgh_startdate datetime
		,lgh_enddate datetime
		,LegTravelMiles float
		,LegLoadedMiles float
		,LegEmptyMiles float
		,MoveStartDate datetime
		,MoveEndDate datetime
		,CountOfOrdersOnThisLeg float
		,CountOfLegsForThisOrder float
		,GrossLegMilesForOrder float
		,GrossBillMilesForLeg float
	)

Insert into @TempAllTriplets
	(
		mov_number,lgh_number,ord_hdrnumber,ord_totalmiles,ord_startdate,ord_completiondate,lgh_startdate,lgh_enddate,LegTravelMiles
		,LegLoadedMiles,LegEmptyMiles,MoveStartDate,MoveEndDate,CountOfOrdersOnThisLeg
		,CountOfLegsForThisOrder,GrossLegMilesForOrder,GrossBillMilesForLeg
	)
	Select distinct mov_number
		,lgh_number
		,ord_hdrnumber
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
		,GrossBillMilesForLeg
	--into @TempAllTriplets
	from ResNow_Triplets with (NOLOCK)
	Where mov_number in (Select mov_number from @TempTriplets)
	OR ord_hdrnumber in (Select ord_hdrnumber from @TempTriplets)

Declare @LegList Table
	(
		OrderNumber char (12)
		,MoveNumber int 
		,LegNumber int 
		,OrderedBy varchar (8)
		,BillTo varchar (8)
		,BillToName varchar (100)
		,Shipper varchar (8)
		,ShipperName varchar (100)
		,ShipperLocation varchar (30)
		,ord_origincity int 
		,ShipDate datetime 
		,Consignee varchar (8)
		,ConsigneeName varchar (100)
		,ConsigneeLocation varchar (30)
		,ord_destcity int 
		,DeliveryDate datetime
		,LegStartDate datetime
		,LegEndDate datetime
		,Carrier varchar (15)
		,CarrierName varchar (100)
		,RevType1 varchar (20)
		,RevType2 varchar (20)
		,RevType3 varchar (20)
		,RevType4 varchar (20)
		,SalesRep varchar(20)
		,BookedBy varchar(200)
		,BookingTerminal varchar(20)
		,ExecutingTerminal varchar(20)
		,ReportingHierarchy int
		,SelectedRevenue float 
		,SelectedPay float 
		,TravelMiles float 
		,LoadedMiles float
		,EmptyMiles float 
		,BillMiles float 
		,LoadCount float 
		,OrderCount float 
		,InvoiceStatus varchar (10)
		,Weight float 
		,WeightUOM varchar (10)
		,Volume float 
		,VolumeUOM varchar (10)
		,PkgCount float 
		,PkgCountUOM varchar (10)
		,LegPct float 
		,OrderPct float 
		,LegStatus varchar (10)
	)


	Insert into @LegList
		(
			OrderNumber,MoveNumber,LegNumber,OrderedBy,BillTo,BillToName,Shipper,ShipperName,ShipperLocation,ord_origincity,ShipDate
			,Consignee,ConsigneeName,ConsigneeLocation,ord_destcity,DeliveryDate,LegStartDate,LegEndDate,Carrier,CarrierName
			,RevType1,RevType2,RevType3,RevType4,SalesRep,BookedBy,BookingTerminal,ExecutingTerminal,ReportingHierarchy
			,SelectedRevenue,SelectedPay,TravelMiles,LoadedMiles,EmptyMiles,BillMiles,LoadCount,OrderCount,InvoiceStatus
			,Weight,WeightUOM,Volume,VolumeUOM,PkgCount,PkgCountUOM,LegPct,OrderPct,LegStatus
		)

	SELECT OrderNumber = orderheader.ord_number
		,MoveNumber = L.mov_number
		,LegNumber = L.Lgh_number
		,OrderedBy = IsNull(orderheader.ord_company,'')
		,BillTo = IsNull(orderheader.ord_billto,'')
		,BillToName = BillToCompany.cmp_name
		,Shipper = IsNull(orderheader.ord_shipper,L.cmp_id_start)
		,ShipperName = Convert(varchar(100),'') -- (select cmp_name from company with (NOLOCK) where cmp_id = IsNull(ord_shipper,cmp_id_start))
		,ShipperLocation = Convert(varchar(30),'') -- IsNull((Select cty_nmstct from City with (NOLOCK) where City.cty_code = Orderheader.ord_origincity),'UNKNOWN')
		,orderheader.ord_origincity
		,ShipDate = IsNull(orderheader.ord_startdate,L.lgh_startdate)
		,Consignee = IsNull(orderheader.ord_consignee,L.cmp_id_end)
		,ConsigneeName = Convert(varchar(100),'') -- (select cmp_name from company with (NOLOCK) where cmp_id = IsNull(ord_consignee,cmp_id_end))
		,ConsigneeLocation = Convert(varchar(30),'') -- IsNull((Select cty_nmstct from City with (NOLOCK) where City.cty_code = Orderheader.ord_destcity),'UNKNOWN')
		,orderheader.ord_destcity
		,DeliveryDate = IsNull(orderheader.ord_completiondate,L.lgh_enddate)
		,LegStartDate = L.lgh_startdate
		,LegEndDate = L.lgh_enddate
		,Carrier = L.lgh_carrier
		,CarrierName = IsNull(carrier.car_name,'')
		,RevType1 = Convert(varchar(20),IsNull(orderheader.ord_revtype1,L.lgh_class1))
		,RevType2 = Convert(varchar(20),IsNull(orderheader.ord_revtype2,L.lgh_class2))
		,RevType3 = Convert(varchar(20),IsNull(orderheader.ord_revtype3,L.lgh_class3))
		,RevType4 = Convert(varchar(20),IsNull(orderheader.ord_revtype4,L.lgh_class4))
		,SalesRep = ISNULL(BillToCompany.cmp_othertype1,'')
		,BookedBy = ISNULL(orderheader.ord_bookedby,L.lgh_createdby)
		,BookingTerminal = ISNULL(orderheader.ord_booked_revtype1,'')
		,ExecutingTerminal = ISNULL(L.lgh_booked_revtype1,'')
		,ReportingHierarchy = Convert(int,0)
-- revenue
		,SelectedRevenue = ISNULL(dbo.fnc_TMWRN_XDRevenue('Order',0,DEFAULT,DEFAULT,TT.ord_hdrnumber,DEFAULT,DEFAULT,DEFAULT,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0)
-- cost
		,SelectedPay = IsNull(dbo.fnc_TMWRN_Pay('Segment',default,default,L.mov_number,default,L.lgh_number,@IncludePayTypeList,@ExcludePayTypeList,@PreTaxYN,default),0.00)
-- miles
		,TravelMiles = Convert(float, LegTravelMiles) 
		,LoadedMiles = Convert(float, LegLoadedMiles)
		,EmptyMiles = Convert(float, LegEmptyMiles)
		,BillMiles = Convert(float, TAT.ord_totalmiles) -- IsNull((select sum(stp_lgh_mileage) from stops with (NOLOCK) where stops.lgh_number = l.lgh_number),0)
		,LoadCount = Convert(float,0.0)
		,OrderCount = Convert(float,1.0)
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
			Case when GrossLegMilesForOrder > 0 Then
				LegTravelMiles / GrossLegMilesForOrder
			Else
				Convert(float,1 / CountOfLegsForThisOrder)
			End
		,lgh_outstatus as LegStatus
	--Into @LegList
	FROM @TempTriplets TT Join @TempAllTriplets TAT on TT.lgh_number = TAT.lgh_number AND TT.ord_hdrnumber = TAT.ord_hdrnumber
		join Legheader L with (NOLOCK) on TT.lgh_number = L.lgh_number
		Join orderheader with (NOLOCK) ON TT.ord_hdrnumber = orderheader.ord_hdrnumber
		Join company BillToCompany with (NOLOCK) on orderheader.ord_billto = BillToCompany.cmp_id
		Join carrier with (NOLOCK) on L.lgh_carrier = carrier.car_id
	WHERE 
	-- transaction-grain filters
	(@OnlyRevType1List =',,' or CHARINDEX(',' + orderheader.ord_revtype1 + ',', @OnlyRevType1List) > 0)
	AND (@OnlyRevType2List =',,' or CHARINDEX(',' + orderheader.ord_revtype2 + ',', @OnlyRevType2list) > 0)
	AND (@OnlyRevType3List =',,' or CHARINDEX(',' + orderheader.ord_revtype3 + ',', @OnlyRevType3List) > 0)
	AND (@OnlyRevType4List =',,' or CHARINDEX(',' + orderheader.ord_revtype4 + ',', @OnlyRevType4List) > 0)
	AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @OnlyBillToList) > 0)
	AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @OnlyShipperList) > 0)
	AND (@OnlyShipperCityList =',,' or CHARINDEX(',' + IsNull(Convert(varchar,orderheader.ord_origincity),'') + ',', @OnlyShipperCityList) > 0)
	AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @OnlyConsigneeList) > 0)
	AND (@OnlyConsigneeCityList =',,' or CHARINDEX(',' + IsNull(Convert(varchar,orderheader.ord_destcity),'') + ',', @OnlyConsigneeCityList) > 0)
	AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @OnlyOrderedByList) > 0)
	AND (@OnlyCarrierList =',,' or CHARINDEX(',' + lgh_carrier + ',', @OnlyCarrierList) > 0)
	AND (@OnlyCarrierPayToList =',,' or CHARINDEX(',' + IsNull(pto_id,'') + ',', @OnlyCarrierPayToList) > 0)
	AND (@OnlySalesRepList =',,' or CHARINDEX(',' + IsNull(BillToCompany.cmp_othertype1,'') + ',', @OnlySalesRepList) >0)		 		 
	AND (@OnlyBookedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_bookedby,L.lgh_createdby) + ',', @OnlyBookedByList) >0)		 		 
	AND (@OnlyBookingTermList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_booked_revtype1,'') + ',', @OnlyBookingTermList) >0)		 		 
	AND (@OnlyExecutingTermList =',,' or CHARINDEX(',' + IsNull(L.lgh_booked_revtype1,'') + ',', @OnlyExecutingTermList) >0)		 		 

	AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + ord_revtype1 + ',', @ExcludeRevType1List) = 0)
	AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + ord_revtype2 + ',', @ExcludeRevType2List) = 0)
	AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + ord_revtype3 + ',', @ExcludeRevType3List) = 0)
	AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + ord_revtype4 + ',', @ExcludeRevType4List) = 0)
	AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @ExcludeBillToList) = 0)                  
	AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @ExcludeShipperList) = 0)                  
	AND (@ExcludeShipperCityList =',,' or CHARINDEX(',' + IsNull(Convert(varchar,orderheader.ord_origincity),'') + ',', @ExcludeShipperCityList) = 0)
	AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @ExcludeConsigneeList) = 0)
	AND (@ExcludeConsigneeCityList =',,' or CHARINDEX(',' + IsNull(Convert(varchar,orderheader.ord_destcity),'') + ',', @ExcludeConsigneeCityList) = 0)
	AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @ExcludeOrderedByList) = 0)                  
	AND (@ExcludeCarrierList =',,' or CHARINDEX(',' + lgh_carrier + ',', @ExcludeCarrierList) = 0)                  
	AND (@ExcludeCarrierPayToList =',,' or CHARINDEX(',' + IsNull(pto_id,'') + ',', @ExcludeCarrierPayToList) = 0)

	AND (@ExcludeSalesRepList =',,' or CHARINDEX(',' + IsNull(BillToCompany.cmp_othertype1,'') + ',', @ExcludeSalesRepList) =0)		 		 
	AND (@ExcludeBookedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_bookedby,L.lgh_createdby) + ',', @ExcludeBookedByList) =0)		 		 
	AND (@ExcludeBookingTermList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_booked_revtype1,'') + ',', @ExcludeBookingTermList) =0)		 		 
	AND (@ExcludeExecutingTermList =',,' or CHARINDEX(',' + IsNull(L.lgh_booked_revtype1,'') + ',', @ExcludeExecutingTermList) =0)		 		 

	AND (@InvoiceStatusList =',,' or CHARINDEX(',' + ord_invoicestatus + ',', @InvoiceStatusList) > 0)		 


-- adjust the @LegList result set as required
	If @EliminateAssetLoadsYN = 'Y'
		Delete from @LegList Where LegStatus <> 'AVL' AND Carrier = 'UNKNOWN'

	If @ExcludeZeroRatedInvoicesYN = 'Y'
		DELETE FROM @LegList where SelectedRevenue = 0

	If @IncludeMiscInvoicesYN = 'Y'
		begin
			Declare @MiscInvoices Table (ivh_hdrnumber int)
		
			If (@DateType in ('MoveStart','LegStart','OrderStart','Bookdate'))
				begin
					Insert into @MiscInvoices (ivh_hdrnumber)
						Select ivh_hdrnumber
						From invoiceheader with (NOLOCK)
						where ivh_shipdate >= @DateStart AND ivh_shipdate < @DateEnd
						AND ord_hdrnumber = 0
				end
			Else	-- (@DateType in ('MoveEnd','LegEnd','OrderEnd'))
				begin
					Insert into @MiscInvoices (ivh_hdrnumber)
						Select ivh_hdrnumber
						From invoiceheader with (NOLOCK)
						where ivh_deliverydate >= @DateStart AND ivh_deliverydate < @DateEnd
						AND ord_hdrnumber = 0
				end
		
			Insert into @LegList
				(
					OrderNumber,MoveNumber,LegNumber,OrderedBy,BillTo,BillToName,Shipper,ShipperName,ShipperLocation,ord_origincity,ShipDate
					,Consignee,ConsigneeName,ConsigneeLocation,ord_destcity,DeliveryDate,LegStartDate,LegEndDate,Carrier,CarrierName
					,RevType1,RevType2,RevType3,RevType4,SalesRep,BookedBy,BookingTerminal,ExecutingTerminal,ReportingHierarchy
					,SelectedRevenue,SelectedPay,TravelMiles,LoadedMiles,EmptyMiles,BillMiles,LoadCount,OrderCount,InvoiceStatus
					,Weight,WeightUOM,Volume,VolumeUOM,PkgCount,PkgCountUOM,LegPct,OrderPct,LegStatus
				)
			SELECT OrderNumber = IH.ivh_invoicenumber
				,MoveNumber = 0
				,LegNumber = 0
				,OrderedBy = IsNull(IH.ivh_order_by,'')
				,BillTo = IsNull(IH.ivh_billto,'')
				,BillToName = IsNull(BillToCompany.cmp_name,'')
				,Shipper = IsNull(IH.ivh_shipper,'')
				,ShipperName = Convert(varchar(100),'') -- (select cmp_name from company with (NOLOCK) where cmp_id = IsNull(ord_shipper,cmp_id_start))
				,ShipperLocation = Convert(varchar(30),'') -- IsNull((Select cty_nmstct from City with (NOLOCK) where City.cty_code = Orderheader.ord_origincity),'UNKNOWN')
				,IH.ivh_origincity
				,ShipDate = IH.ivh_shipdate
				,Consignee = IsNull(IH.ivh_consignee,'')
				,ConsigneeName = Convert(varchar(100),'') -- (select cmp_name from company with (NOLOCK) where cmp_id = IsNull(ord_consignee,cmp_id_end))
				,ConsigneeLocation = Convert(varchar(30),'') -- IsNull((Select cty_nmstct from City with (NOLOCK) where City.cty_code = Orderheader.ord_destcity),'UNKNOWN')
				,IH.ivh_destcity
				,DeliveryDate = IH.ivh_deliverydate
				,LegStartDate = IH.ivh_shipdate
				,LegEndDate = ivh_deliverydate
				,Carrier = IH.ivh_carrier
				,CarrierName = IsNull(carrier.car_name,'')
				,RevType1 = Convert(varchar(20),IH.ivh_revtype1)
				,RevType2 = Convert(varchar(20),IH.ivh_revtype2)
				,RevType3 = Convert(varchar(20),IH.ivh_revtype3)
				,RevType4 = Convert(varchar(20),IH.ivh_revtype4)
				,SalesRep = ISNULL(BillToCompany.cmp_othertype1,'')
				,BookedBy = 'UNK'
				,BookingTerminal = 'UNK'
				,ExecutingTerminal = 'UNK'
				,ReportingHierarchy = Convert(int,0)
		-- revenue
				,SelectedRevenue = ISNULL(dbo.fnc_TMWRN_XDRevenue('Invoice',0,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,IH.ivh_hdrnumber,@BaseRevenueCategoryTLAFN,@IncludeChargeTypeList,@ExcludeChargeTypeList,@SubtractFuelSurchargeYN,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT,DEFAULT),0)
		-- cost
				,SelectedPay = 0.00
		-- miles
				,TravelMiles = 0
				,LoadedMiles = 0
				,EmptyMiles = 0
				,BillMiles = IH.ivh_totalmiles -- IsNull((select sum(stp_lgh_mileage) from stops with (NOLOCK) where stops.lgh_number = l.lgh_number),0)
				,LoadCount = 0
				,OrderCount = 0
				,InvoiceStatus = IH.ivh_invoicestatus
				,Weight = Convert(float,0.0)
				,WeightUOM = 'LBS'
				,Volume = Convert(float,0.0)
				,VolumeUOM = 'GAL'
				,PkgCount = Convert(float,0.0)
				,PkgCountUOM = Convert(varchar(10),'')
				,LegPct = 1
				,OrderPct = 1
				,LegStatus = 'CMP'
			from @MiscInvoices MI join invoiceheader IH with (NOLOCK) on MI.ivh_hdrnumber = IH.ivh_hdrnumber
				inner Join company BillToCompany with (NOLOCK) on IH.ivh_billto = BillToCompany.cmp_id
				Join carrier with (NOLOCK) on IH.ivh_carrier = carrier.car_id
			WHERE 
			-- transaction-grain filters
			(@OnlyRevType1List =',,' or CHARINDEX(',' + IH.ivh_revtype1 + ',', @OnlyRevType1List) > 0)
			AND (@OnlyRevType2List =',,' or CHARINDEX(',' + IH.ivh_revtype2 + ',', @OnlyRevType2list) > 0)
			AND (@OnlyRevType3List =',,' or CHARINDEX(',' + IH.ivh_revtype3 + ',', @OnlyRevType3List) > 0)
			AND (@OnlyRevType4List =',,' or CHARINDEX(',' + IH.ivh_revtype4 + ',', @OnlyRevType4List) > 0)
			AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(IH.ivh_billto,'') + ',', @OnlyBillToList) > 0)
			AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(IH.ivh_shipper,'') + ',', @OnlyShipperList) > 0)
			AND (@OnlyShipperCityList =',,' or CHARINDEX(',' + IsNull(Convert(varchar,IH.ivh_origincity),'') + ',', @OnlyShipperCityList) > 0)
			AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(IH.ivh_consignee,'') + ',', @OnlyConsigneeList) > 0)
			AND (@OnlyConsigneeCityList =',,' or CHARINDEX(',' + IsNull(Convert(varchar,IH.ivh_destcity),'') + ',', @OnlyConsigneeCityList) > 0)
			AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(IH.ivh_order_by,'') + ',', @OnlyOrderedByList) > 0)

			AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + IH.ivh_revtype1 + ',', @ExcludeRevType1List) = 0)
			AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + IH.ivh_revtype2 + ',', @ExcludeRevType2List) = 0)
			AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + IH.ivh_revtype3 + ',', @ExcludeRevType3List) = 0)
			AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + IH.ivh_revtype4 + ',', @ExcludeRevType4List) = 0)
			AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(IH.ivh_billto,'') + ',', @ExcludeBillToList) = 0)                  
			AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(IH.ivh_shipper,'') + ',', @ExcludeShipperList) = 0)                  
			AND (@ExcludeShipperCityList =',,' or CHARINDEX(',' + IsNull(Convert(varchar,IH.ivh_origincity),'') + ',', @ExcludeShipperCityList) = 0)
			AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(IH.ivh_consignee,'') + ',', @ExcludeConsigneeList) = 0)
			AND (@ExcludeConsigneeCityList =',,' or CHARINDEX(',' + IsNull(Convert(varchar,IH.ivh_destcity),'') + ',', @ExcludeConsigneeCityList) = 0)
			AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(IH.ivh_order_by,'') + ',', @ExcludeOrderedByList) = 0)                  

		end



	-- do fact allocations
	Update @LegList set OrderCount = Round(OrderPct,5,0)
	,BillMiles = Round(BillMiles * OrderPct,0,0)
	,SelectedRevenue = Round(SelectedRevenue * OrderPct,5,0)

	Update @LegList set TravelMiles = Round(TravelMiles * LegPct,4,0)
	,LoadedMiles = Round(LoadedMiles * LegPct,4,0)
	,EmptyMiles = Round(EmptyMiles * LegPct,4,0)
	,SelectedPay = Round(SelectedPay * LegPct,4,0)

	-- set LoadCount; by Leg COUNT to account for zero mile moves
	--Declare @TempCalcTriplets Table (mov_number int, lgh_number int, LegTravelMiles float)

	--Insert into @TempCalcTriplets (mov_number,lgh_number,LegTravelMiles)
	--Select distinct mov_number
	--,lgh_number
	--,LegTravelMiles
	----into @TempCalcTriplets
	--from @TempAllTriplets

	Declare @TempLegCount Table (mov_number int, LegCount float, MoveMiles float)

	Insert into @TempLegCount (mov_number,LegCount,MoveMiles)
	Select mov_number
	,count(distinct lgh_number) as LegCount
	,sum(LegTravelMiles / CountOfOrdersOnThisLeg) as MoveMiles
	--into @TempLegCount
	from @TempAllTriplets
	group by mov_number

	Update @LegList set LoadCount = Round(1.0 / Convert(float,LegCount),4,0)
	from @TempLegCount TLC INNER JOIN @LegList LL on LL.MoveNumber = TLC.mov_number

	-- set LoadCount; by Miles if miles not zero
	Update @LegList set LoadCount = Round(Convert(float,TravelMiles) / Convert(float,MoveMiles),4,0)
	from @TempLegCount TLC INNER JOIN @LegList LL on LL.MoveNumber = TLC.mov_number
	where TLC.MoveMiles > 0

	-- set Weight
	If @Numerator = 'Weight' OR @Denominator = 'Weight' OR @ShowDetail > 0
		Begin
			Update @LegList set Weight = 
				IsNull(	(
							Select Sum(dbo.fnc_TMWRN_UnitConversion(fgt_weightunit,@WeightUOM,IsNull(fgt_weight,0)))
							from freightdetail with (NOLOCK) join stops with (NOLOCK) on freightdetail.stp_number = stops.stp_number
							where stops.lgh_number = LL.LegNumber
							AND stops.stp_type = 'DRP'
						),0)
			From @LegList LL
		End

	-- set Volume
	If @Numerator = 'Volume' OR @Denominator = 'Volume' OR @ShowDetail > 0
		Begin
			Update @LegList set Volume = 
				IsNull(	(
							Select Sum(dbo.fnc_TMWRN_UnitConversion(fgt_volumeunit,@VolumeUOM,IsNull(fgt_volume,0)))
							from freightdetail with (NOLOCK) join stops with (NOLOCK) on freightdetail.stp_number = stops.stp_number
							where stops.lgh_number = LL.LegNumber
--							AND freightdetail.cmd_code = @LegList.CommodityID
							AND stops.stp_type = 'DRP'
						),0)
			From @LegList LL
		End

	-- set PkgCount
	If @Numerator = 'PkgCount' OR @Denominator = 'PkgCount' OR @ShowDetail > 0
		Begin
			Update @LegList set 
				PkgCount = 
					IsNull(	(
								Select Sum(IsNull(fgt_count,0))
								from freightdetail with (NOLOCK) join stops with (NOLOCK) on freightdetail.stp_number = stops.stp_number
								where stops.lgh_number = LL.LegNumber
--								AND freightdetail.cmd_code = @LegList.CommodityID
								AND stops.stp_type = 'DRP'
							),0)
				,PkgCountUOM = 
					IsNull(	(
								Select Top 1 fgt_countunit
								from freightdetail with (NOLOCK) join stops with (NOLOCK) on freightdetail.stp_number = stops.stp_number
								where stops.lgh_number = LL.LegNumber
--								AND freightdetail.cmd_code = @LegList.CommodityID
								AND stops.stp_type = 'DRP'
							),'Each')
			From @LegList LL
		End

	Set @ThisCount = 
		Case 
			When @Numerator = 'Revenue' then (Select sum(SelectedRevenue) from @LegList)
			When @Numerator = 'Cost' then (Select sum(SelectedPay) from @LegList)
			When @Numerator = 'Margin' then (Select sum(SelectedRevenue) - sum(SelectedPay) from @LegList)
			When @Numerator = 'LoadCount' then (Select sum(LoadCount) from @LegList)
			When @Numerator = 'OrderCount' then (Select sum(OrderCount) from @LegList)
			When @Numerator = 'Weight' then (Select sum(Weight) from @LegList)
			When @Numerator = 'Volume' then (Select sum(Volume) from @LegList)
			When @Numerator = 'LoadedMile' then (Select sum(LoadedMiles) from @LegList)
			When @Numerator = 'EmptyMile' then (Select sum(EmptyMiles) from @LegList)
			When @Numerator = 'BillMile' then (Select sum(BillMiles) from @LegList)
		Else -- When @Numerator = 'TravelMile'
			(Select sum(TravelMiles) From @LegList) 
		End

	Set @ThisTotal =
		Case
			When @Denominator = 'Revenue' then (Select sum(SelectedRevenue) from @LegList)
			When @Denominator = 'Cost' then (Select sum(SelectedPay) from @LegList)
			When @Denominator = 'TravelMile' then (Select sum(TravelMiles) From @LegList)
			When @Denominator = 'LoadedMile' then (Select sum(LoadedMiles) From @LegList)
			When @Denominator = 'EmptyMile' then (Select sum(EmptyMiles) From @LegList)
			When @Denominator = 'BillMile' then (Select sum(BillMiles) from @LegList)
			When @Denominator = 'LoadCount' then (Select sum(LoadCount) From @LegList)
			When @Denominator = 'OrderCount' then (Select sum(OrderCount) from @LegList)
			When @Denominator = 'Weight' then (Select sum(Weight) from @LegList)
			When @Denominator = 'Volume' then (Select sum(Volume) from @LegList)
		Else -- When @Denominator = 'Day'
			CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) 
			END
		End


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 


	If @ShowDetail > 0	-- get textual information we need for good data display
		Begin
			Update @LegList set ShipperName = company.cmp_name
			From company with (NOLOCK) INNER JOIN @LegList LL ON LL.Shipper = company.cmp_id 

			Update @LegList set ConsigneeName = company.cmp_name
			From company with (NOLOCK) INNER JOIN @LegList LL ON LL.Consignee = company.cmp_id 

			Update @LegList set ShipperLocation = city.cty_nmstct
			From city with (NOLOCK) INNER JOIN @LegList LL ON LL.ord_origincity = city.cty_code

			Update @LegList set ConsigneeLocation = city.cty_nmstct
			From city with (NOLOCK) INNER JOIN @LegList LL ON LL.ord_destcity = city.cty_code

			Update @LegList set RevType1 = LF.Name
			From labelfile LF with (NOLOCK) INNER JOIN @LegList LL ON LL.RevType1 = LF.ABBR
			Where LF.labeldefinition = 'RevType1'

			Update @LegList set RevType2 = LF.Name
			From labelfile LF with (NOLOCK) INNER JOIN @LegList LL ON LL.RevType2 = LF.ABBR
			Where LF.labeldefinition = 'RevType2'

			Update @LegList set RevType3 = LF.Name
			From labelfile LF with (NOLOCK) INNER JOIN @LegList LL ON LL.RevType3 = LF.ABBR
			Where LF.labeldefinition = 'RevType3'

			Update @LegList set RevType4 = LF.Name
			From labelfile LF with (NOLOCK) INNER JOIN @LegList LL ON LL.RevType4 = LF.ABBR
			Where LF.labeldefinition = 'RevType4'

			Update @LegList Set ReportingHierarchy = RowID
			From dbo.fnc_BranchHierarchyForRN(), @LegList LL
			where (brn_id_1 = LL.BookingTerminal AND brn_id_2 is NULL)
			OR (brn_id_2 = LL.BookingTerminal AND brn_id_3 is NULL)
			OR (brn_id_3 = LL.BookingTerminal AND brn_id_4 is NULL)
			OR (brn_id_4 = LL.BookingTerminal AND brn_id_5 is NULL)

		End

	If @ShowDetail = 1
		BEGIN
			SELECT RevType1
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),0) as Revenue
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),0) as PTE
			,dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),0) as LoadCount
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0) as Weight
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0) as Volume
			,dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0) as TravelMiles
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
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),0) as Margin
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
			FROM @LegList
			Group by RevType1
			order by RevType1
		END
	Else If @ShowDetail = 2
		BEGIN	
			SELECT RevType1
			,RevType2
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),0) as Revenue
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),0) as PTE
			,dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),0) as LoadCount
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0) as Weight
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0) as Volume
			,dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0) as TravelMiles
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
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),0) as Margin
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
			FROM @LegList
			Group by RevType1,RevType2
			order by RevType1,RevType2

		END
	Else If @ShowDetail = 3
		BEGIN
			SELECT RevType1
			,RevType2
			,RevType3
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),0) as Revenue
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),0) as PTE
			,dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),0) as LoadCount
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0) as Weight
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0) as Volume
			,dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0) as TravelMiles
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
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),0) as Margin
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
			FROM @LegList --join dbo.fnc_BranchHierarchyForRN() BH on @LegList.ReportingHierarchy = BH.RowID 
			Group by RevType1,RevType2,RevType3
			order by RevType1,RevType2,RevType3
		END
	Else If @ShowDetail = 4
		BEGIN
			SELECT RevType1
			,RevType2
			,RevType3
			,RevType4
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),0) as Revenue
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),0) as PTE
			,dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),0) as LoadCount
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0) as Weight
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0) as Volume
			,dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0) as TravelMiles
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
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),0) as Margin
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
			FROM @LegList --join dbo.fnc_BranchHierarchyForRN() BH on @LegList.ReportingHierarchy = BH.RowID 
			Group by RevType1,RevType2,RevType3,RevType4
			order by RevType1,RevType2,RevType3,RevType4
		END
	Else If @ShowDetail = 5
		BEGIN
			SELECT SalesRep
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),0) as Revenue
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),0) as PTE
			,dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),2) as LoadCount
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0) as Weight
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0) as Volume
			,dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0) as TravelMiles
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
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),0) as Margin
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
			FROM @LegList
			Group by SalesRep
			order by SalesRep
		END
	Else If @ShowDetail = 6
		BEGIN
			SELECT BookedBy
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),0) as Revenue
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),0) as PTE
			,dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),2) as LoadCount
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0) as Weight
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0) as Volume
			,dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0) as TravelMiles
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
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),0) as Margin
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
			FROM @LegList
			Group by BookedBy
			order by BookedBy
		END
	Else If @ShowDetail = 7
		BEGIN
			SELECT BookingTerminal
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),0) as Revenue
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),0) as PTE
			,dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),2) as LoadCount
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0) as Weight
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0) as Volume
			,dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0) as TravelMiles
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
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),0) as Margin
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
			FROM @LegList
			Group by BookingTerminal
			order by BookingTerminal
		END
	Else If @ShowDetail = 8
		BEGIN
			SELECT ExecutingTerminal
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),0) as Revenue
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),0) as PTE
			,dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),2) as LoadCount
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0) as Weight
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0) as Volume
			,dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0) as TravelMiles
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
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),0) as Margin
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
			FROM @LegList
			Group by ExecutingTerminal
			order by ExecutingTerminal
		END
	Else If @ShowDetail = 9
		BEGIN
			SELECT BillToName
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),0) as Revenue
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),0) as PTE
			,dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),2) as LoadCount
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0) as Weight
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0) as Volume
			,dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0) as TravelMiles
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
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),0) as Margin
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
			FROM @LegList
			Group by BillToName
			order by BillToName
		END
	Else If @ShowDetail = 10
		BEGIN
			SELECT CarrierName
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),0) as Revenue
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),0) as PTE
			,dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),2) as LoadCount
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0) as Weight
			,dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0) as Volume
			,dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0) as TravelMiles
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
			,'$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),0) as Margin
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
			FROM @LegList
			Group by CarrierName
			order by CarrierName
		END
	Else If @ShowDetail = 11
		Begin
			SELECT OrderNumber 
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
				,SalesRep
				,BookedBy
				,BookingTerminal
				,ExecutingTerminal
				,LegStartDate
				,LegEndDate
				,Carrier
				,CarrierName
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
				,InvoiceStatus
				,Weight
				,Volume
				,PkgCount
				,LegPct
				,OrderPct
			From @LegList
			Order by OrderNumber
		End


Else If @ShowDetail = 12
		BEGIN
			SELECT  OrderNumber 
			,Ingreso = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue),2)
			,Costo = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedPay),2)
			,Margen = '$' + dbo.fnc_TMWRN_FormatNumbers(Sum(SelectedRevenue) - Sum(SelectedPay),2)
			,CuentaCargas = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadCount),4)
			,CuentaOrdenes = dbo.fnc_TMWRN_FormatNumbers(Sum(OrderCount),4)
			,Peso = dbo.fnc_TMWRN_FormatNumbers(Sum(Weight),0)
			,Volumen = dbo.fnc_TMWRN_FormatNumbers(Sum(Volume),0)
			,KmsCargados = dbo.fnc_TMWRN_FormatNumbers(Sum(LoadedMiles),0)
			,KmsVacios = dbo.fnc_TMWRN_FormatNumbers(Sum(EmptyMiles),0)
			,KmsTotales = dbo.fnc_TMWRN_FormatNumbers(Sum(TravelMiles),0)
			,IngresoXkm = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(TravelMiles) > 0 Then
					Sum(SelectedRevenue) / Sum(TravelMiles) 
				Else
					0
				End,2)
			,CostoPorCiento = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * (Sum(SelectedPay) / Sum(SelectedRevenue))
				Else
					0
				End,2) + '%'
			,MargenPorCiento = dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(SelectedRevenue) > 0 Then
					100 * ((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(SelectedRevenue)) 
				Else
					0
				End,2) + '%'
			,MargenPorCarga = '$' + dbo.fnc_TMWRN_FormatNumbers(
				Case When Sum(LoadCount) > 0 Then
					Round((Sum(SelectedRevenue) - Sum(SelectedPay)) / Sum(LoadCount),2)
				Else
					0
				End,0)
			FROM @LegList
			Group by OrderNumber 
			order by OrderNumber 
		END



		
	SET NOCOUNT OFF

-- Part 3

	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'OpsByCarriersXD',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 112, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Revenue, Expense, Ops Metrics by Carriers',
		@sCaptionFull = '60+ Measurements for Trips by Carriers',
		@sProcedureName = 'Metric_OpsByCarriersXD',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = null

	</METRIC-INSERT-SQL>
	*/
GO
GRANT EXECUTE ON  [dbo].[Metric_OpsByCarriersXD] TO [public]
GO
