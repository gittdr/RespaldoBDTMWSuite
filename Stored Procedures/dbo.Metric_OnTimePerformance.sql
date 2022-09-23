SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- Part 2

CREATE Procedure [dbo].[Metric_OnTimePerformance]
	(
		--Standard Parameters
		@Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,
		
		-- Additional / Optional Parameters
		@DateType varchar(50) = 'StopEnd',				-- MoveEnd, OrderEnd, LegEnd, StopEnd
		@Numerator varchar(20) = 'StopsOnTime',			-- StopsOnTime, OrdersOnTime, StopsLate, OrdersLate
		@Denominator varchar(20) = 'Day',				-- Day, StopsTotal, OrdersTotal
		@TimeType varchar(10) = 'Window',				-- Window, Schedule
		@LateThresholdMinutes varchar(5) = '15',		-- "free" minutes late
		@AssetsCarriersBothACB char(1) = 'B',			-- only (A)sset loads, only (C)arrier loads, (B)oth
		@OnlyStopTypeList varchar(255) = '',			-- PUP, DRP
		@OnlyTrcCmpAOGFaultList varchar(255) = '',		-- Trucker (TRC), Customer (CMP), Act of God (AOG)

		-- filtering parameters: includes
		@OnlyRevType1List varchar(255) ='',
		@OnlyRevType2List varchar(255) ='',
		@OnlyRevType3List varchar(255) ='',
		@OnlyRevType4List varchar(255) ='',

		@OnlyBillToList varchar(255) = '',
		@OnlyShipperList varchar(255) = '',
		@OnlyConsigneeList varchar(255) = '',
		@OnlyOrderedByList varchar(255) = '',

		@OnlyStopEventList varchar(255) = '',

		@OnlyDrvType1List varchar(255) = '',
		@OnlyDrvType2List varchar(255) = '',
		@OnlyDrvType3List varchar(255) = '',
		@OnlyDrvType4List varchar(255) = '',
		@OnlyDrvCompanyList varchar(255) = '',
		@OnlyDrvDivisionList varchar(255) = '',
		@OnlyDrvTerminalList varchar(255) = '',
		@OnlyDrvFleetList varchar(255) = '',

		@OnlyTrcType1List varchar(255) = '',
		@OnlyTrcType2List varchar(255) = '',
		@OnlyTrcType3List varchar(255) = '',
		@OnlyTrcType4List varchar(255) = '',
		@OnlyTrcCompanyList varchar(255) = '',
		@OnlyTrcDivisionList varchar(255) = '',
		@OnlyTrcTerminalList varchar(255) = '',
		@OnlyTrcFleetList varchar(255) = '',

		-- filtering parameters: excludes
		@ExcludeRevType1List varchar(255) ='',
		@ExcludeRevType2List varchar(255) ='',
		@ExcludeRevType3List varchar(255) ='',
		@ExcludeRevType4List varchar(255) ='',

		@ExcludeBillToList varchar(255) = '',
		@ExcludeShipperList varchar(255) = '',
		@ExcludeConsigneeList varchar(255) = '',
		@ExcludeOrderedByList varchar(255) = '',

		@ExcludeStopEventList varchar(255) = '',

		@ExcludeDrvType1List varchar(255) = '',
		@ExcludeDrvType2List varchar(255) = '',
		@ExcludeDrvType3List varchar(255) = '',
		@ExcludeDrvType4List varchar(255) = '',
		@ExcludeDrvCompanyList varchar(255) = '',
		@ExcludeDrvDivisionList varchar(255) = '',
		@ExcludeDrvTerminalList varchar(255) = '',
		@ExcludeDrvFleetList varchar(255) = '',

		@ExcludeTrcType1List varchar(255) = '',
		@ExcludeTrcType2List varchar(255) = '',
		@ExcludeTrcType3List varchar(255) = '',
		@ExcludeTrcType4List varchar(255) = '',
		@ExcludeTrcCompanyList varchar(255) = '',
		@ExcludeTrcDivisionList varchar(255) = '',
		@ExcludeTrcTerminalList varchar(255) = '',
		@ExcludeTrcFleetList varchar(255) = ''
	)
AS
	SET NOCOUNT ON

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:EventosOnTime,2:EventosTarde,3:Cliente,4:Operador,5:Stops

/* Revision History
01/13/2009	modified calculation of [On Time Pct] in By Driver detail (@ShowDetail=3) to convert values
			from decimal(5,2) to decimal(8,2) to accommodate larger volume of trips

*/

	-- local variables
	declare @LateThresholdMins int
	set @LateThresholdMins = Convert(int,@LateThresholdMinutes)
	
	--Standard Parameter Initialization
	SET @OnlyStopTypeList= ',' + ISNULL(@OnlyStopTypeList,'') + ','
	SET @OnlyTrcCmpAOGFaultList= ',' + ISNULL(@OnlyTrcCmpAOGFaultList,'') + ','

	SET @OnlyRevType1List= ',' + ISNULL(@OnlyRevType1List,'') + ','
	SET @OnlyRevType2List= ',' + ISNULL(@OnlyRevType2List,'') + ','
	SET @OnlyRevType3List= ',' + ISNULL(@OnlyRevType3List,'') + ','
	SET @OnlyRevType4List= ',' + ISNULL(@OnlyRevType4List,'') + ','

	Set @OnlyBillToList= ',' + ISNULL(@OnlyBillToList,'') + ','
	Set @OnlyShipperList= ',' + ISNULL(@OnlyShipperList,'') + ','
	Set @OnlyConsigneeList= ',' + ISNULL(@OnlyConsigneeList,'') + ','
	Set @OnlyOrderedByList= ',' + ISNULL(@OnlyOrderedByList,'') + ','

	Set @OnlyStopEventList= ',' + ISNULL(@OnlyStopEventList,'') + ','

	Set @OnlyDrvType1List= ',' + ISNULL(@OnlyDrvType1List,'') + ','
	Set @OnlyDrvType2List= ',' + ISNULL(@OnlyDrvType2List,'') + ','
	Set @OnlyDrvType3List= ',' + ISNULL(@OnlyDrvType3List,'') + ','
	Set @OnlyDrvType4List= ',' + ISNULL(@OnlyDrvType4List,'') + ','
	Set @OnlyDrvCompanyList= ',' + ISNULL(@OnlyDrvCompanyList,'') + ','
	Set @OnlyDrvDivisionList= ',' + ISNULL(@OnlyDrvDivisionList,'') + ','
	Set @OnlyDrvTerminalList= ',' + ISNULL(@OnlyDrvTerminalList,'') + ','
	Set @OnlyDrvFleetList= ',' + ISNULL(@OnlyDrvFleetList,'') + ','

	Set @OnlyTrcType1List= ',' + ISNULL(@OnlyTrcType1List,'') + ','
	Set @OnlyTrcType2List= ',' + ISNULL(@OnlyTrcType2List,'') + ','
	Set @OnlyTrcType3List= ',' + ISNULL(@OnlyTrcType3List,'') + ','
	Set @OnlyTrcType4List= ',' + ISNULL(@OnlyTrcType4List,'') + ','
	Set @OnlyTrcCompanyList= ',' + ISNULL(@OnlyTrcCompanyList,'') + ','
	Set @OnlyTrcDivisionList= ',' + ISNULL(@OnlyTrcDivisionList,'') + ','
	Set @OnlyTrcTerminalList= ',' + ISNULL(@OnlyTrcTerminalList,'') + ','
	Set @OnlyTrcFleetList= ',' + ISNULL(@OnlyTrcFleetList,'') + ','

	SET @ExcludeRevType1List= ',' + ISNULL(@ExcludeRevType1List,'') + ','
	SET @ExcludeRevType2List= ',' + ISNULL(@ExcludeRevType2List,'') + ','
	SET @ExcludeRevType3List= ',' + ISNULL(@ExcludeRevType3List,'') + ','
	SET @ExcludeRevType4List= ',' + ISNULL(@ExcludeRevType4List,'') + ','

	Set @ExcludeBillToList= ',' + ISNULL(@ExcludeBillToList,'') + ','
	Set @ExcludeShipperList= ',' + ISNULL(@ExcludeShipperList,'') + ','
	Set @ExcludeConsigneeList= ',' + ISNULL(@ExcludeConsigneeList,'') + ','
	Set @ExcludeOrderedByList= ',' + ISNULL(@ExcludeOrderedByList,'') + ','

	Set @ExcludeStopEventList= ',' + ISNULL(@ExcludeStopEventList,'') + ','

	Set @ExcludeDrvType1List= ',' + ISNULL(@ExcludeDrvType1List,'') + ','
	Set @ExcludeDrvType2List= ',' + ISNULL(@ExcludeDrvType2List,'') + ','
	Set @ExcludeDrvType3List= ',' + ISNULL(@ExcludeDrvType3List,'') + ','
	Set @ExcludeDrvType4List= ',' + ISNULL(@ExcludeDrvType4List,'') + ','
	Set @ExcludeDrvCompanyList= ',' + ISNULL(@ExcludeDrvCompanyList,'') + ','
	Set @ExcludeDrvDivisionList= ',' + ISNULL(@ExcludeDrvDivisionList,'') + ','
	Set @ExcludeDrvTerminalList= ',' + ISNULL(@ExcludeDrvTerminalList,'') + ','
	Set @ExcludeDrvFleetList= ',' + ISNULL(@ExcludeDrvFleetList,'') + ','

	Set @ExcludeTrcType1List= ',' + ISNULL(@ExcludeTrcType1List,'') + ','
	Set @ExcludeTrcType2List= ',' + ISNULL(@ExcludeTrcType2List,'') + ','
	Set @ExcludeTrcType3List= ',' + ISNULL(@ExcludeTrcType3List,'') + ','
	Set @ExcludeTrcType4List= ',' + ISNULL(@ExcludeTrcType4List,'') + ','
	Set @ExcludeTrcCompanyList= ',' + ISNULL(@ExcludeTrcCompanyList,'') + ','
	Set @ExcludeTrcDivisionList= ',' + ISNULL(@ExcludeTrcDivisionList,'') + ','
	Set @ExcludeTrcTerminalList= ',' + ISNULL(@ExcludeTrcTerminalList,'') + ','
	Set @ExcludeTrcFleetList= ',' + ISNULL(@ExcludeTrcFleetList,'') + ','

	Create Table #StopList (stp_number int)

	If (@DateType = 'StopEnd')
		begin
			Insert into #StopList (stp_number)
			Select stp_number 
			from stops (NOLOCK) 
			where stp_arrivaldate >= @DateStart AND stp_arrivaldate < @DateEnd 
			AND ord_hdrnumber <> 0
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

			Insert into #StopList (stp_number)
			Select stp_number
			From Stops (NOLOCK)
			Where lgh_number in (select lgh_number from @TempTriplets)
			AND ord_hdrnumber in (select ord_hdrnumber from @TempTriplets)
			AND	stp_status = 'DNE'
		end

--select * from #StopList

	Create Table #ResultsTable
		(
			OrderNumber varchar(15)
			,ord_hdrnumber int
			,BillTo varchar(8)
			,BillToCompanyName varchar(100)
			,MoveNumber int
			,LegNumber int
			,StopNumber int
			,StopEvent varchar(8)
			,StopCmpID varchar(8)
			,StopCompanyName varchar(100)
			,StopCity varchar(100)
			,StopScheduledEarliest datetime
			,StopScheduledLatest datetime
			,StopArrivalDate datetime
			,StopDeparure datetime
			,StopReasonLateCode varchar(10)
			,StopReasonLateDesc varchar(20)
			,MinutesVariance int
			,IsLateVsThreshold char(1)
			,Driver varchar(10)
			,DriverName varchar(75)
			,Tractor varchar(15)
			,Carrier varchar(15)
			,StopStatus varchar(10)
			,FaultTCA varchar(3)
			,StopSequence int
		)

	--CREATE #ResultsTable 

	Insert into #ResultsTable 
		(
			OrderNumber,ord_hdrnumber,BillTo,BillToCompanyName,MoveNumber,LegNumber,StopNumber
			,StopEvent,StopCmpID,StopCompanyName,StopCity,StopScheduledEarliest,StopScheduledLatest
			,StopArrivalDate,StopDeparure,StopReasonLateCode,StopReasonLateDesc,MinutesVariance
			,IsLateVsThreshold,Driver,DriverName,Tractor,Carrier,StopStatus,FaultTCA,StopSequence 
		)
	SELECT 
		OrderNumber = ord_number
		,Stops.ord_hdrnumber
		,orderheader.ord_billto
		,BillToCompanyName = 
			IsNull(	(	
						SELECT cmp_name
						FROM Company BillToCompany (NOLOCK)
						WHERE orderheader.ord_billto = BillToCompany.cmp_id	
					),'')
		,Stops.mov_number
		,Stops.lgh_number
		,Stops.stp_number
		,stp_event as StopEvent
		,Stops.cmp_id as StopCmpID
		,StopsCompanyName = 
			IsNull(	(	
						SELECT cmp_name
						FROM Company StopsCompany (NOLOCK)
						WHERE stops.cmp_id=StopsCompany.cmp_id	
					),'')
		,StopCity =	
			(
				SELECT cty_nmstct
				FROM city StopsCity (NOLOCK)
				WHERE stops.stp_city = stopsCity.cty_code
			)
		,stp_schdtearliest as StopScheduledEarliest
		,stp_schdtlatest as StopScheduledLatest
		,stp_arrivaldate as StopArrivalDate
		,stp_departuredate as StopDeparure
		,stp_reasonlate as StopReasonLateCode
		,StopReasonLateDesc =
			(
				SELECT Name
				FROM LabelFile (NOLOCK) 
				WHERE stp_reasonlate = Abbr 
				AND labeldefinition = 'ReasonLate'
			) 
		,MinutesVariance = 
			Case when @TimeType = 'Schedule' then
				Datediff(mi, stp_schdtearliest, stp_arrivaldate)
			Else
				Datediff(mi, stp_schdtlatest, stp_arrivaldate)
			End
		,'N' as IsLateVsThreshold
		,Driver = lgh_driver1
		,mpp_lastfirst As DriverName
		,Tractor = lgh_tractor
		,Carrier = lgh_carrier
		,stp_status
-->	0 to 100 Means Our Fault - Transporter
-->	101 to 200 customer's fault
-->	201 Means No Fault
		,FaultTCA =
			CASE 
				WHEN	(
							SELECT CODE 
							FROM LabelFile (NOLOCK) 
							WHERE stp_reasonlate = Abbr 
							AND labeldefinition = 'ReasonLate'
						) < 101 THEN 'TRC' 
				WHEN	(
							SELECT CODE 
							FROM LabelFile (NOLOCK) 
							WHERE stp_reasonlate = Abbr 
							AND labeldefinition = 'ReasonLate'
						) BETWEEN 101 AND 200 THEN 'CMP' 
			ELSE 
				'AOG'
			END
		,stp_mfh_sequence as StopSequence
	FROM stops (NOLOCK) join legheader (NOLOCK) on legheader.lgh_number = stops.lgh_number
			join orderheader (NOLOCK) on stops.ord_hdrnumber = orderheader.ord_hdrnumber
			join manpowerprofile (NOLOCK) on manpowerprofile.mpp_id = legheader.lgh_driver1
	WHERE Stops.stp_number IN (SELECT stp_number FROM #StopList)
	AND (@OnlyStopTypeList =',,' or CHARINDEX(',' + RTrim(stp_type) + ',', @OnlyStopTypeList) > 0)
	-- transaction-grain filters
	AND (@OnlyRevType1List =',,' or CHARINDEX(',' + ord_revtype1 + ',', @OnlyRevType1List) > 0)
	AND (@OnlyRevType2List =',,' or CHARINDEX(',' + ord_revtype2 + ',', @OnlyRevType2list) > 0)
	AND (@OnlyRevType3List =',,' or CHARINDEX(',' + ord_revtype3 + ',', @OnlyRevType3List) > 0)
	AND (@OnlyRevType4List =',,' or CHARINDEX(',' + ord_revtype4 + ',', @OnlyRevType4List) > 0)

	AND (@ExcludeRevType1List =',,' or CHARINDEX(',' + ord_revtype1 + ',', @ExcludeRevType1List) = 0)
	AND (@ExcludeRevType2List =',,' or CHARINDEX(',' + ord_revtype2 + ',', @ExcludeRevType2List) = 0)
	AND (@ExcludeRevType3List =',,' or CHARINDEX(',' + ord_revtype3 + ',', @ExcludeRevType3List) = 0)
	AND (@ExcludeRevType4List =',,' or CHARINDEX(',' + ord_revtype4 + ',', @ExcludeRevType4List) = 0)

	AND (@OnlyBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @OnlyBillToList) > 0)
	AND (@OnlyShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @OnlyShipperList) > 0)
	AND (@OnlyConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @OnlyConsigneeList) > 0)
	AND (@OnlyOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @OnlyOrderedByList) > 0)

	AND (@ExcludeBillToList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_billto,'') + ',', @ExcludeBillToList) = 0)                  
	AND (@ExcludeShipperList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_shipper,'') + ',', @ExcludeShipperList) = 0)                  
	AND (@ExcludeConsigneeList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_consignee,'') + ',', @ExcludeConsigneeList) = 0)                  
	AND (@ExcludeOrderedByList =',,' or CHARINDEX(',' + IsNull(orderheader.ord_company,'') + ',', @ExcludeOrderedByList) = 0)                  

	-- operations-grain filters
	AND (@OnlyStopEventList =',,' or CHARINDEX(',' + stops.stp_event + ',', @OnlyStopEventList) > 0)
	AND (@ExcludeStopEventList =',,' or CHARINDEX(',' + stops.stp_event + ',', @ExcludeStopEventList) = 0)

	AND (@OnlyDrvType1List =',,' or CHARINDEX(',' + legheader.mpp_type1 + ',', @OnlyDrvType1List) > 0)
	AND (@OnlyDrvType2List =',,' or CHARINDEX(',' + legheader.mpp_type2 + ',', @OnlyDrvType2List) > 0)
	AND (@OnlyDrvType3List =',,' or CHARINDEX(',' + legheader.mpp_type3 + ',', @OnlyDrvType3List) > 0)
	AND (@OnlyDrvType4List =',,' or CHARINDEX(',' + legheader.mpp_type4 + ',', @OnlyDrvType4List) > 0)
	AND (@OnlyDrvCompanyList =',,' or CHARINDEX(',' + legheader.mpp_company + ',', @OnlyDrvCompanyList) > 0)
	AND (@OnlyDrvDivisionList =',,' or CHARINDEX(',' + legheader.mpp_division + ',', @OnlyDrvDivisionList) > 0)
	AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + legheader.mpp_terminal + ',', @OnlyDrvTerminalList) > 0)
	AND (@OnlyDrvFleetList =',,' or CHARINDEX(',' + legheader.mpp_fleet + ',', @OnlyDrvFleetList) > 0)

	AND (@ExcludeDrvType1List =',,' or CHARINDEX(',' + legheader.mpp_type1 + ',', @ExcludeDrvType1List) = 0)
	AND (@ExcludeDrvType2List =',,' or CHARINDEX(',' + legheader.mpp_type2 + ',', @ExcludeDrvType2List) = 0)
	AND (@ExcludeDrvType3List =',,' or CHARINDEX(',' + legheader.mpp_type3 + ',', @ExcludeDrvType3List) = 0)
	AND (@ExcludeDrvType4List =',,' or CHARINDEX(',' + legheader.mpp_type4 + ',', @ExcludeDrvType4List) = 0)
	AND (@ExcludeDrvCompanyList =',,' or CHARINDEX(',' + legheader.mpp_company + ',', @ExcludeDrvCompanyList) = 0)
	AND (@ExcludeDrvDivisionList =',,' or CHARINDEX(',' + legheader.mpp_division + ',', @ExcludeDrvDivisionList) = 0)
	AND (@ExcludeDrvTerminalList =',,' or CHARINDEX(',' + legheader.mpp_terminal + ',', @ExcludeDrvTerminalList) = 0)
	AND (@ExcludeDrvFleetList =',,' or CHARINDEX(',' + legheader.mpp_fleet + ',', @ExcludeDrvFleetList) = 0)

	AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + legheader.trc_type1 + ',', @OnlyTrcType1List) > 0)
	AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + legheader.trc_type2 + ',', @OnlyTrcType2List) > 0)
	AND (@OnlyTrcType3List =',,' or CHARINDEX(',' + legheader.trc_type3 + ',', @OnlyTrcType3List) > 0)
	AND (@OnlyTrcType4List =',,' or CHARINDEX(',' + legheader.trc_type4 + ',', @OnlyTrcType4List) > 0)
	AND (@OnlyTrcCompanyList =',,' or CHARINDEX(',' + legheader.trc_company + ',', @OnlyTrcCompanyList) > 0)
	AND (@OnlyTrcDivisionList =',,' or CHARINDEX(',' + legheader.trc_division + ',', @OnlyTrcDivisionList) > 0)
	AND (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + legheader.trc_terminal + ',', @OnlyTrcTerminalList) > 0)
	AND (@OnlyTrcFleetList =',,' or CHARINDEX(',' + legheader.trc_fleet + ',', @OnlyTrcFleetList) > 0)

	AND (@ExcludeTrcType1List =',,' or CHARINDEX(',' + legheader.trc_type1 + ',', @ExcludeTrcType1List) = 0)
	AND (@ExcludeTrcType2List =',,' or CHARINDEX(',' + legheader.trc_type2 + ',', @ExcludeTrcType2List) = 0)
	AND (@ExcludeTrcType3List =',,' or CHARINDEX(',' + legheader.trc_type3 + ',', @ExcludeTrcType3List) = 0)
	AND (@ExcludeTrcType4List =',,' or CHARINDEX(',' + legheader.trc_type4 + ',', @ExcludeTrcType4List) = 0)
	AND (@ExcludeTrcCompanyList =',,' or CHARINDEX(',' + legheader.trc_company + ',', @ExcludeTrcCompanyList) = 0)
	AND (@ExcludeTrcDivisionList =',,' or CHARINDEX(',' + legheader.trc_division + ',', @ExcludeTrcDivisionList) = 0)
	AND (@ExcludeTrcTerminalList =',,' or CHARINDEX(',' + legheader.trc_terminal + ',', @ExcludeTrcTerminalList) = 0)
	AND (@ExcludeTrcFleetList =',,' or CHARINDEX(',' + legheader.trc_fleet + ',', @ExcludeTrcFleetList) = 0)
	ORDER BY stops.Mov_number, stops.stp_mfh_sequence

	-- Evaluate trips to include
	If @AssetsCarriersBothACB = 'A'
		Begin
			Delete from #ResultsTable Where Carrier <> 'UNKNOWN'
		End
	Else If @AssetsCarriersBothACB = 'C'
		Begin
			Delete from #ResultsTable Where Carrier = 'UNKNOWN'
		End

	If @OnlyTrcCmpAOGFaultList <> ',,'
		begin
			Delete from #ResultsTable Where CHARINDEX(',' + FaultTCA + ',', @OnlyTrcCmpAOGFaultList) = 0
		end

	--Evaluate Late Status
	UPDATE #ResultsTable SET IsLateVsThreshold = 'Y' WHERE MinutesVariance > @LateThresholdMins

	Set @ThisCount = 
		Case 
			When @Numerator = 'StopsOnTime' then (Select Count(distinct StopNumber) from #ResultsTable where IsLateVsThreshold <> 'Y')
			When @Numerator = 'OrdersOnTime' then (Select Count(distinct OrderNumber) from #ResultsTable where IsLateVsThreshold <> 'Y')
			When @Numerator = 'StopsLate' then (Select Count(distinct StopNumber) from #ResultsTable where IsLateVsThreshold = 'Y')
		Else	--	@Numerator = 'OrdersLate'
			(Select Count(distinct OrderNumber) from #ResultsTable where IsLateVsThreshold = 'Y')
		End

	SET @ThisTotal =
		Case 
			When @Denominator = 'StopsTotal' then (Select Count(distinct StopNumber) from #ResultsTable)
			When @Denominator = 'OrdersTotal' then (Select Count(distinct OrderNumber) from #ResultsTable)
		Else	--	@Denominator = 'Day'
			CASE 
				WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1 
			ELSE 
				DATEDIFF(day, @DateStart, @DateEnd) 
			END
		End

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 


	If @ShowDetail > 0
		begin
			Create Table #TempQualifyingEventCount (Entity varchar(8), EntityName varchar(100), QualifyingCount float, TotalCount float, PerfPct float)
			Create Table #TempTotalEventCount (Entity varchar(8), TotalCount float)
		end

------------------------------------------------------------------------------------------------------------------------------------------------------
	IF (@ShowDetail = 1) -- CountedEvents 
	BEGIN
		If @Numerator like '%OnTime'
			begin
				Select 
                 Orden = OrderNumber
                ,Cliente = BillTo
                --,Tractor = Tractor
                --,Operador = DriverName
                ,Evento = StopEvent
                ,Stop = StopCompanyName                
                ,Ciudad = StopCity
                ,Earliest = StopScheduledEarliest
                ,Latest = StopScheduledLAtest
                ,Llegada = StopArrivalDate
                ,Diferencia = MinutesVariance
                 
                 
				From #ResultsTable
				Where IsLateVsThreshold <> 'Y'
				Order by Driver,Carrier,StopArrivalDate
			End
		Else	-- @Numerator like '%Late'
			Begin
				Select 
                 Orden = OrderNumber
                ,Cliente = BillTo
                --,Tractor = Tractor
                --,Operador = DriverName
                ,Evento = StopEvent
                ,Stop = StopCompanyName                
                ,Ciudad = StopCity
                ,Earliest = StopScheduledEarliest
                ,Latest = StopScheduledLAtest
                ,Llegada = StopArrivalDate
                ,Diferencia = MinutesVariance
                 
                
				From #ResultsTable
				Where IsLateVsThreshold = 'Y'
				Order by Driver,Carrier,StopArrivalDate
			End
	END


---------------------------------------------------------------------------------------------
	IF (@ShowDetail = 2) -- eventosTarde
	BEGIN
		If @Numerator like '%OnTime'
			begin
				Select 
                 Orden = OrderNumber
                ,Cliente = BillTo
                --,Tractor = Tractor
                --,Operador = DriverName
                ,Evento = StopEvent
                ,Stop = StopCompanyName                
                ,Ciudad = StopCity
                ,Earliest = StopScheduledEarliest
                ,Latest = StopScheduledLAtest
                ,Llegada = StopArrivalDate
                ,Diferencia = MinutesVariance
                 
                 
				From #ResultsTable
				Where IsLateVsThreshold = 'Y'
				Order by Driver,Carrier,StopArrivalDate
			End
		Else	-- @Numerator like '%Late'
			Begin
				Select 
                 Orden = OrderNumber
                ,Cliente = BillTo
                --,Tractor = Tractor
                --,Operador = DriverName
                ,Evento = StopEvent
                ,Stop = StopCompanyName                
                ,Ciudad = StopCity
                ,Earliest = StopScheduledEarliest
                ,Latest = StopScheduledLAtest
                ,Llegada = StopArrivalDate
                ,Diferencia = MinutesVariance
                 
                
				From #ResultsTable
				Where IsLateVsThreshold <> 'Y'
				Order by Driver,Carrier,StopArrivalDate
			End
	END



---------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF (@ShowDetail = 3) -- Por CLiente
	BEGIN
		If @Numerator like 'Stops%'
			begin
				If @Numerator like '%OnTime'
					begin
						Insert into #TempQualifyingEventCount (Entity, EntityName, QualifyingCount, TotalCount, PerfPct)
						SELECT 
                        BillTo
						 ,Cliente = BillToCompanyName
						,Convert(float,Count(distinct StopNumber)) as QualifyingCount
						,Convert(float,0)
						,Convert(float,0)
						From #ResultsTable
						Where IsLateVsThreshold <> 'Y'
						Group by BillTo,BillToCompanyName

						Insert into #TempTotalEventCount (Entity, TotalCount)
						SELECT BillTo
						,Convert(float,Count(distinct StopNumber)) as TotalCount
						From #ResultsTable
						Group by BillTo

						Update #TempQualifyingEventCount set TotalCount = #TempTotalEventCount.TotalCount
						From #TempTotalEventCount
						Where #TempQualifyingEventCount.Entity = #TempTotalEventCount.Entity

						Update #TempQualifyingEventCount Set PerfPct = QualifyingCount / TotalCount
					end
				Else	-- @Numerator like '%Late'
					Begin
						Insert into #TempQualifyingEventCount (Entity, EntityName, QualifyingCount, TotalCount, PerfPct)
						SELECT 
                       BillTo
						,Cliente = BillToCompanyName
						,Convert(float,Count(distinct StopNumber)) as QualifyingCount
						,Convert(float,0)
						,Convert(float,0)
						From #ResultsTable
						Where IsLateVsThreshold = 'Y'
						Group by BillTo,BillToCompanyName

						Insert into #TempTotalEventCount (Entity, TotalCount)
						SELECT BillTo
						,Convert(float,Count(distinct StopNumber)) as TotalCount
						From #ResultsTable
						Group by BillTo

						Update #TempQualifyingEventCount set TotalCount = #TempTotalEventCount.TotalCount
						From #TempTotalEventCount
						Where #TempQualifyingEventCount.Entity = #TempTotalEventCount.Entity

						Update #TempQualifyingEventCount Set PerfPct = QualifyingCount / TotalCount
					End
			end
		Else	-- @Numerator like 'Orders%'
			begin
				If @Numerator like '%OnTime'
					begin
						Insert into #TempQualifyingEventCount (Entity, EntityName, QualifyingCount, TotalCount, PerfPct)
						SELECT BillTo
						,BillToCompanyName
						,Convert(float,Count(distinct OrderNumber)) as QualifyingCount
						,Convert(float,0)
						,Convert(float,0)
						From #ResultsTable
						Where IsLateVsThreshold <> 'Y'
						Group by BillTo,BillToCompanyName

						Insert into #TempTotalEventCount (Entity, TotalCount)
						SELECT BillTo
						,Convert(float,Count(distinct OrderNumber)) as TotalCount
						From #ResultsTable
						Group by BillTo

						Update #TempQualifyingEventCount set TotalCount = #TempTotalEventCount.TotalCount
						From #TempTotalEventCount
						Where #TempQualifyingEventCount.Entity = #TempTotalEventCount.Entity

						Update #TempQualifyingEventCount Set PerfPct = QualifyingCount / TotalCount
					end
				Else	-- @Numerator like '%Late'
					Begin
						Insert into #TempQualifyingEventCount (Entity, EntityName, QualifyingCount, TotalCount, PerfPct)
						SELECT BillTo
						,BillToCompanyName
						,Convert(float,Count(distinct OrderNumber)) as QualifyingCount
						,Convert(float,0)
						,Convert(float,0)
						From #ResultsTable
						Where IsLateVsThreshold = 'Y'
						Group by BillTo,BillToCompanyName

						Insert into #TempTotalEventCount (Entity, TotalCount)
						SELECT BillTo
						,Convert(float,Count(distinct OrderNumber)) as TotalCount
						From #ResultsTable
						Group by BillTo

						Update #TempQualifyingEventCount set TotalCount = #TempTotalEventCount.TotalCount
						From #TempTotalEventCount
						Where #TempQualifyingEventCount.Entity = #TempTotalEventCount.Entity

						Update #TempQualifyingEventCount Set PerfPct = QualifyingCount / TotalCount
					End
			end

		Select 
         --Entity as BillTo
		EntityName as Cliente
		,QualifyingCount as CuentaOntime
		,TotalCount as CuentaTotal
		, dbo.fnc_TMWRN_FormatNumbers((100 * PerfPct),2) + '%' as PorcentajeOntime
		From #TempQualifyingEventCount
		Order by EntityName
	END

------------------------------------------------------------------------------------------------------------------
	IF (@ShowDetail = 4) -- Por OPERADOR
	BEGIN
		If @Numerator like 'Stops%'
			begin
				If @Numerator like '%OnTime'
					begin
						Insert into #TempQualifyingEventCount (Entity, EntityName, QualifyingCount, TotalCount, PerfPct)
						SELECT Driver
						,DriverName
						,Convert(float,Count(distinct StopNumber)) as QualifyingCount
						,Convert(float,0)
						,Convert(float,0)
						From #ResultsTable
						Where IsLateVsThreshold <> 'Y'
						Group by Driver,DriverName

						Insert into #TempTotalEventCount (Entity, TotalCount)
						SELECT Driver
						,Convert(float,Count(distinct StopNumber)) as TotalCount
						From #ResultsTable
						Group by Driver

						Update #TempQualifyingEventCount set TotalCount = #TempTotalEventCount.TotalCount
						From #TempTotalEventCount
						Where #TempQualifyingEventCount.Entity = #TempTotalEventCount.Entity

						Update #TempQualifyingEventCount Set PerfPct = QualifyingCount / TotalCount
					end
				Else	-- @Numerator like '%Late'
					Begin
						Insert into #TempQualifyingEventCount (Entity, EntityName, QualifyingCount, TotalCount, PerfPct)
						SELECT Driver
						,DriverName
						,Convert(float,Count(distinct StopNumber)) as QualifyingCount
						,Convert(float,0)
						,Convert(float,0)
						From #ResultsTable
						Where IsLateVsThreshold = 'Y'
						Group by Driver,DriverName

						Insert into #TempTotalEventCount (Entity, TotalCount)
						SELECT Driver
						,Convert(float,Count(distinct StopNumber)) as TotalCount
						From #ResultsTable
						Group by Driver

						Update #TempQualifyingEventCount set TotalCount = #TempTotalEventCount.TotalCount
						From #TempTotalEventCount
						Where #TempQualifyingEventCount.Entity = #TempTotalEventCount.Entity

						Update #TempQualifyingEventCount Set PerfPct = QualifyingCount / TotalCount
					End
			end
		Else	-- @Numerator like 'Orders%'
			begin
				If @Numerator like '%OnTime'
					begin
						Insert into #TempQualifyingEventCount (Entity, EntityName, QualifyingCount, TotalCount, PerfPct)
						SELECT Driver
						,DriverName
						,Convert(float,Count(distinct OrderNumber)) as QualifyingCount
						,Convert(float,0)
						,Convert(float,0)
						From #ResultsTable
						Where IsLateVsThreshold <> 'Y'
						Group by Driver,DriverName

						Insert into #TempTotalEventCount (Entity, TotalCount)
						SELECT Driver
						,Convert(float,Count(distinct OrderNumber)) as TotalCount
						From #ResultsTable
						Group by Driver

						Update #TempQualifyingEventCount set TotalCount = #TempTotalEventCount.TotalCount
						From #TempTotalEventCount
						Where #TempQualifyingEventCount.Entity = #TempTotalEventCount.Entity

						Update #TempQualifyingEventCount Set PerfPct = QualifyingCount / TotalCount
					end
				Else	-- @Numerator like '%Late'
					Begin
						Insert into #TempQualifyingEventCount (Entity, EntityName, QualifyingCount, TotalCount, PerfPct)
						SELECT Driver
						,DriverName
						,Convert(float,Count(distinct OrderNumber)) as QualifyingCount
						,Convert(float,0)
						,Convert(float,0)
						From #ResultsTable
						Where IsLateVsThreshold = 'Y'
						Group by Driver,DriverName

						Insert into #TempTotalEventCount (Entity, TotalCount)
						SELECT Driver
						,Convert(float,Count(distinct OrderNumber)) as TotalCount
						From #ResultsTable
						Group by Driver

						Update #TempQualifyingEventCount set TotalCount = #TempTotalEventCount.TotalCount
						From #TempTotalEventCount
						Where #TempQualifyingEventCount.Entity = #TempTotalEventCount.Entity

						Update #TempQualifyingEventCount Set PerfPct = QualifyingCount / TotalCount
					End
			end

        SELECT
         EntityName as Operador
		,QualifyingCount as CuentaOntime
		,TotalCount as CuentaTotal
		, dbo.fnc_TMWRN_FormatNumbers((100 * PerfPct),2) + '%' as PorcentajeOntime
		From #TempQualifyingEventCount
		Order by EntityName


	END
------------------------------------------------------------------------------------------------------------------------------------------------------
	/* IF (@ShowDetail = 4) -- ByCarrier
	BEGIN
		If @Numerator like 'Stops%'
			begin
				If @Numerator like '%OnTime'
					begin
						Insert into #TempQualifyingEventCount (Entity, EntityName, QualifyingCount, TotalCount, PerfPct)
						SELECT Carrier
						,CarrierName
						,Convert(float,Count(distinct StopNumber)) as QualifyingCount
						,Convert(float,0)
						,Convert(float,0)
						From #ResultsTable
						Where IsLateVsThreshold <> 'Y'
						Group by Carrier,CarrierName

						Insert into #TempTotalEventCount (Entity, TotalCount)
						SELECT Carrier
						,Convert(float,Count(distinct StopNumber)) as TotalCount
						From #ResultsTable
						Group by Carrier

						Update #TempQualifyingEventCount set TotalCount = #TempTotalEventCount.TotalCount
						From #TempTotalEventCount
						Where #TempQualifyingEventCount.Entity = #TempTotalEventCount.Entity

						Update #TempQualifyingEventCount Set PerfPct = QualifyingCount / TotalCount
					end
				Else	-- @Numerator like '%Late'
					Begin
						Insert into #TempQualifyingEventCount (Entity, EntityName, QualifyingCount, TotalCount, PerfPct)
						SELECT Carrier
						,CarrierName
						,Convert(float,Count(distinct StopNumber)) as QualifyingCount
						,Convert(float,0)
						,Convert(float,0)
						From #ResultsTable
						Where IsLateVsThreshold = 'Y'
						Group by Carrier,CarrierName

						Insert into #TempTotalEventCount (Entity, TotalCount)
						SELECT Carrier
						,Convert(float,Count(distinct StopNumber)) as TotalCount
						From #ResultsTable
						Group by Carrier

						Update #TempQualifyingEventCount set TotalCount = #TempTotalEventCount.TotalCount
						From #TempTotalEventCount
						Where #TempQualifyingEventCount.Entity = #TempTotalEventCount.Entity

						Update #TempQualifyingEventCount Set PerfPct = QualifyingCount / TotalCount
					End
			end
		Else	-- @Numerator like 'Orders%'
			begin
				If @Numerator like '%OnTime'
					begin
						Insert into #TempQualifyingEventCount (Entity, EntityName, QualifyingCount, TotalCount, PerfPct)
						SELECT Carrier
						,CarrierName
						,Convert(float,Count(distinct OrderNumber)) as QualifyingCount
						,Convert(float,0)
						,Convert(float,0)
						From #ResultsTable
						Where IsLateVsThreshold <> 'Y'
						Group by Carrier,CarrierName

						Insert into #TempTotalEventCount (Entity, TotalCount)
						SELECT Carrier
						,Convert(float,Count(distinct OrderNumber)) as TotalCount
						From #ResultsTable
						Group by Carrier

						Update #TempQualifyingEventCount set TotalCount = #TempTotalEventCount.TotalCount
						From #TempTotalEventCount
						Where #TempQualifyingEventCount.Entity = #TempTotalEventCount.Entity

						Update #TempQualifyingEventCount Set PerfPct = QualifyingCount / TotalCount
					end
				Else	-- @Numerator like '%Late'
					Begin
						Insert into #TempQualifyingEventCount (Entity, EntityName, QualifyingCount, TotalCount, PerfPct)
						SELECT Carrier
						,CarrierName
						,Convert(float,Count(distinct OrderNumber)) as QualifyingCount
						,Convert(float,0)
						,Convert(float,0)
						From #ResultsTable
						Where IsLateVsThreshold = 'Y'
						Group by Carrier,CarrierName

						Insert into #TempTotalEventCount (Entity, TotalCount)
						SELECT Carrier
						,Convert(float,Count(distinct OrderNumber)) as TotalCount
						From #ResultsTable
						Group by Carrier

						Update #TempQualifyingEventCount set TotalCount = #TempTotalEventCount.TotalCount
						From #TempTotalEventCount
						Where #TempQualifyingEventCount.Entity = #TempTotalEventCount.Entity

						Update #TempQualifyingEventCount Set PerfPct = QualifyingCount / TotalCount
					End
			end

		Select Entity as Carrier
		,EntityName as CarrierName
		,QualifyingCount
		,TotalCount
		,PerfPct
		From #TempQualifyingEventCount
		Order by EntityName
	END


	IF (@ShowDetail = 5) -- ByReason
	BEGIN
		Select StopReasonLateDesc as Razon
		,Count(distinct StopNumber) as CuentaEventos
		From #ResultsTable
		Where IsLateVsThreshold = 'Y'
		Group by StopReasonLateDesc
		Order by StopReasonLateDesc
	END



	IF (@ShowDetail = 5) -- ByFault
	BEGIN
		Select FaultTCA as Cp
		,Count(distinct StopNumber) as FaultCount
		From #ResultsTable
		Where IsLateVsThreshold = 'Y'
		Group by FaultTCA
		Order by FaultTCA
	END

*/

-----------------------------------------------------------------

IF (@ShowDetail = 5) -- stops totales
	BEGIN
		If @Numerator like '%OnTime'
			begin
				Select 
                 Status =  case when IsLateVsThreshold  = 'N'  then 'On Time' else 'Tarde' end
                ,Orden = OrderNumber
                ,Cliente = BillTo
                --,Tractor = Tractor
                --,Operador = DriverName
                ,Evento = StopEvent
                ,Stop = StopCompanyName                
                ,Ciudad = StopCity
                ,Earliest = StopScheduledEarliest
                ,Latest = StopScheduledLAtest
                ,Llegada = StopArrivalDate
                 ,Diferencia = MinutesVariance
                 
                 
				From #ResultsTable
				Order by Driver,Carrier,StopArrivalDate
			End
		Else	-- @Numerator like '%Late'
			Begin
				Select 
                 Status =  case when IsLateVsThreshold  = 'N' then 'On Time' else 'Tarde' end
                 ,Orden = OrderNumber
                ,Cliente = BillTo
                --,Tractor = Tractor
                --,Operador = DriverName
                ,Evento = StopEvent
                ,Stop = StopCompanyName                
                ,Ciudad = StopCity
                ,Earliest = StopScheduledEarliest
                ,Latest = StopScheduledLAtest
                ,Llegada = StopArrivalDate
                ,Diferencia = MinutesVariance
                 
                
				From #ResultsTable
				Order by Driver,Carrier,StopArrivalDate
			End
	END




Set NOCOUNT Off


-- Part 3

	--Standard Metric Initialization
	/* 	<METRIC-INSERT-SQL>

		EXEC MetricInitializeItem
			@sMetricCode = 'OnTimePerformance',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 107, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDECIMAL = 0,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 0,
			@sCaption = 'On Time Pct',
			@sCaptionFull = 'On Time & Late Stops',
			@sProcedureName = 'Metric_OnTimePerformance',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'
	
		</METRIC-INSERT-SQL>
	*/



GO
GRANT EXECUTE ON  [dbo].[Metric_OnTimePerformance] TO [public]
GO
