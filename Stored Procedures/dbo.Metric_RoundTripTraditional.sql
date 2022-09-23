SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Metric_RoundTripTraditional]
(

	@Result DECIMAL(20, 5) OUTPUT, 
	@ThisCount DECIMAL(20, 5) OUTPUT, 
	@ThisTotal DECIMAL(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms INT = 0, 
	@ShowDetail INT = 0,
	@RTDefName varchar(255),
	@Mode varchar(20) = 'RTTotalRevenuePerDay',	-- RTTotalRevenuePerDay, RTTotalRevPerRTEstDays, RTTotalRevPerAllMile
												-- RTTotalRevPerLDMile, RTLHRevPerLDMile, RTTotalRevPerTruck
												-- RTTotalRevPerRT, RTCostPerRT, RTMarginPerRT, RTMarginPerTotalRevenue
												-- RTAllMilesPerRT, RTAllMilesPerRTEstDays, RTDHMilesPerRT
												-- RTDHMilesPerAllMiles, RTEstDaysPerRT

	@TractorList varchar(255) = '',
	@TrcType1List varchar(255) = '',
	@TrcType2List varchar(255) = '',
	@TrcType3List varchar(255) = '',
	@TrcType4List varchar(255) = '',
	@OutboundDestinationCompany varchar(255) = '',
	@OutboundDestinationCity varchar(255) = '',
	@OutboundDestinationState varchar(255) = '',
	@OutboundDestinationZip varchar(255) = '',
	@OutboundDestinationRegion1 varchar(255) = '',
	@OutboundDestinationRegion2 varchar(255) = '',
	@OutboundDestinationRegion3 varchar(255) = '',
	@OutboundDestinationRegion4 varchar(255) = ''

)

AS

/*
This stored procedure identifies completed round trips and provides
a selection of different metric calculations based on those round
trips.  
*/

	SET NOCOUNT ON


	SET @TractorList = ',' + ISNULL(@TractorList,'') + ','
	SET @TrcType1List = ',' + ISNULL(@TrcType1List,'') + ','
	SET @TrcType2List = ',' + ISNULL(@TrcType2List,'') + ','
	SET @TrcType3List = ',' + ISNULL(@TrcType3List,'') + ','
	SET @TrcType4List = ',' + ISNULL(@TrcType4List,'') + ','
	SET @OutboundDestinationCompany = ',' + ISNULL(@OutboundDestinationCompany,'') + ','
	SET @OutboundDestinationCity = ',' + ISNULL(@OutboundDestinationCity,'') + ','
	SET @OutboundDestinationState = ',' + ISNULL(@OutboundDestinationState,'') + ','
	SET @OutboundDestinationZip = ',' + ISNULL(@OutboundDestinationZip,'') + ','
	SET @OutboundDestinationRegion1 = ',' + ISNULL(@OutboundDestinationRegion1,'') + ','
	SET @OutboundDestinationRegion2 = ',' + ISNULL(@OutboundDestinationRegion2,'') + ','
	SET @OutboundDestinationRegion3 = ',' + ISNULL(@OutboundDestinationRegion3,'') + ','
	SET @OutboundDestinationRegion4 = ',' + ISNULL(@OutboundDestinationRegion4,'') + ','


	--	create Consolidated RoundTrip table
	Select rt_EndLeg as Trip
	,rt_EndDate as RTEndDate
	,rt_Truck as Truck
	,TimeRT = Sum(rt_TimeForLeg)
	,LegCount = count(*)
	,LHRevRT = Sum(rt_LHRevForLeg)
	,ACCRevRT = Sum(rt_ACCRevForLeg)
	,TotalRevRT = Sum(rt_LHRevForLeg) + Sum(rt_ACCRevForLeg)
	,LoadMilesRT = Sum(rt_LoadMiles)
	,DHMilesRT = Sum(rt_DHMiles)
	,AllMilesRT = Cast(0 as int)
	,LHRevPerLDMilesRT = Cast(0.00 as Float)
	,AllRevPerAllMilesRT = Cast(0.00 as Float)
	,GrossPayRT = Sum(rt_GrossPayForLeg)
	,TollRt = Sum(rt_TollForLeg)
	,EstFuelCostRT = Sum(rt_EstFuelCostForLeg)
	,TVCRT = Cast(0.00 as Float)
	,ThruputRT = Cast(0.00 as Float)
	,ThruputPerDayRT = Cast(0.00 as Float)
	,Cast('' as varchar(8)) as FirstOutCom 
	,Cast('' as varchar(8)) as FirstOutCity
	,Cast('' as varchar(8)) as FirstOutState
	,Cast('' as varchar(8)) as FirstOutZip3
	,Cast('' as varchar(8)) as FirstOutReg1 
	,Cast('' as varchar(8)) as FirstOutReg2 
	,Cast('' as varchar(8)) as FirstOutReg3
	,Cast('' as varchar(8)) as FirstOutReg4 
	,Cast('' as varchar(8)) as LastOutCom 
	,Cast('' as varchar(8)) as LastOutCity
	,Cast('' as varchar(8)) as LastOutState
	,Cast('' as varchar(8)) as LastOutZip3
	,Cast('' as varchar(8)) as LastOutReg1 
	,Cast('' as varchar(8)) as LastOutReg2 
	,Cast('' as varchar(8)) as LastOutReg3
	,Cast('' as varchar(8)) as LastOutReg4 
	,Cast('' as varchar(8)) as FirstInCom 
	,Cast('' as varchar(8)) as FirstInCity
	,Cast('' as varchar(8)) as FirstInState
	,Cast('' as varchar(8)) as FirstInZip3
	,Cast('' as varchar(8)) as FirstInReg1 
	,Cast('' as varchar(8)) as FirstInReg2 
	,Cast('' as varchar(8)) as FirstInReg3
	,Cast('' as varchar(8)) as FirstInReg4 
	,Cast('' as varchar(8)) as LastInCom 
	,Cast('' as varchar(8)) as LastInCity
	,Cast('' as varchar(8)) as LastInState
	,Cast('' as varchar(8)) as LastInZip3
	,Cast('' as varchar(8)) as LastInReg1 
	,Cast('' as varchar(8)) as LastInReg2 
	,Cast('' as varchar(8)) as LastInReg3
	,Cast('' as varchar(8)) as LastInReg4 
	into #WorkingRTTable
	from Metric_RTLegCache
	where rt_DefName = @RTDefName
		AND rt_EndLeg in (select distinct rt_EndLeg from Metric_RTLegCache MRL (NOLOCK) where MRL.rt_DefName = @RTDefName AND MRL.rt_LegType = 'E' AND MRL.rt_EndDate between @DateStart AND @DateEnd)
--		AND rt_EndDate between @DateStart AND @DateEnd
	group by rt_EndLeg,rt_EndDate,rt_Truck

UNION

	Select rt_EndLeg as Trip
	,rt_EndDate as RTEndDate
	,rt_Truck as Truck
	,TimeRT = Sum(rt_TimeForLeg)
	,LegCount = count(*)
	,LHRevRT = Sum(rt_LHRevForLeg)
	,ACCRevRT = Sum(rt_ACCRevForLeg)
	,TotalRevRT = Sum(rt_LHRevForLeg) + Sum(rt_ACCRevForLeg)
	,LoadMilesRT = Sum(rt_LoadMiles)
	,DHMilesRT = Sum(rt_DHMiles)
	,AllMilesRT = Cast(0 as int)
	,LHRevPerLDMilesRT = Cast(0.00 as Float)
	,AllRevPerAllMilesRT = Cast(0.00 as Float)
	,GrossPayRT = Sum(rt_GrossPayForLeg)
	,TollRt = Sum(rt_TollForLeg)
	,EstFuelCostRT = Sum(rt_EstFuelCostForLeg)
	,TVCRT = Cast(0.00 as Float)
	,ThruputRT = Cast(0.00 as Float)
	,ThruputPerDayRT = Cast(0.00 as Float)
	,Cast('' as varchar(8)) as FirstOutCom 
	,Cast('' as varchar(8)) as FirstOutCity
	,Cast('' as varchar(8)) as FirstOutState
	,Cast('' as varchar(8)) as FirstOutZip3
	,Cast('' as varchar(8)) as FirstOutReg1 
	,Cast('' as varchar(8)) as FirstOutReg2 
	,Cast('' as varchar(8)) as FirstOutReg3
	,Cast('' as varchar(8)) as FirstOutReg4 
	,Cast('R' as varchar(8)) as LastOutCom 
	,Cast('R' as varchar(8)) as LastOutCity
	,Cast('R' as varchar(8)) as LastOutState
	,Cast('R' as varchar(8)) as LastOutZip3
	,Cast('R' as varchar(8)) as LastOutReg1 
	,Cast('R' as varchar(8)) as LastOutReg2 
	,Cast('R' as varchar(8)) as LastOutReg3
	,Cast('R' as varchar(8)) as LastOutReg4 
	,Cast('R' as varchar(8)) as FirstInCom 
	,Cast('R' as varchar(8)) as FirstInCity
	,Cast('R' as varchar(8)) as FirstInState
	,Cast('R' as varchar(8)) as FirstInZip3
	,Cast('R' as varchar(8)) as FirstInReg1 
	,Cast('R' as varchar(8)) as FirstInReg2 
	,Cast('R' as varchar(8)) as FirstInReg3
	,Cast('R' as varchar(8)) as FirstInReg4 
	,Cast('' as varchar(8)) as LastInCom 
	,Cast('' as varchar(8)) as LastInCity
	,Cast('' as varchar(8)) as LastInState
	,Cast('' as varchar(8)) as LastInZip3
	,Cast('' as varchar(8)) as LastInReg1 
	,Cast('' as varchar(8)) as LastInReg2 
	,Cast('' as varchar(8)) as LastInReg3
	,Cast('' as varchar(8)) as LastInReg4 
	from Metric_RTLegCache
	where rt_DefName = @RTDefName
		AND rt_EndLeg in (select distinct rt_EndLeg from Metric_RTLegCache MRL (NOLOCK) where MRL.rt_DefName = @RTDefName AND MRL.rt_LegType = 'R' AND MRL.rt_EndDate between @DateStart AND @DateEnd)
--		AND rt_EndDate between @DateStart AND @DateEnd
	group by rt_EndLeg,rt_EndDate,rt_Truck
	order by rt_Truck,rt_EndDate,rt_EndLeg

	--	update Consolidated RoundTrip table
	Update #WorkingRTTable 
		Set AllMilesRT = LoadMilesRT + DHMilesRT
		,LHRevPerLDMilesRT = 
			Case When IsNull(LoadMilesRT,0) = 0 then
				NULL
			Else
				Round(LHRevRT / Cast(LoadMilesRT as Float),2)
			End
		,AllRevPerAllMilesRT = 
			Case When IsNull((LoadMilesRT + DHMilesRT),0) = 0 then
				NULL
			Else
				Round((LHRevRT + AccRevRT) / Cast(LoadMilesRT + DHMilesRT as Float),2)
			End
		,TVCRT = GrossPayRT + TollRT + EstFuelCostRT
		,ThruputRT = TotalRevRT - (GrossPayRT + TollRT + EstFuelCostRT)
		,ThruputPerDayRT = 
			Case When IsNull(TimeRT,0) = 0 then
				NULL
			Else
				Round((TotalRevRT - (GrossPayRT + TollRT + EstFuelCostRT)) / TimeRT,2)
			End
		,FirstOutCom = rt_FirstCom
		,FirstOutCity = rt_FirstCity
		,FirstOutZip3 = rt_FirstZip3
		,FirstOutState = rt_FirstState
		,FirstOutReg1 = rt_FirstReg1
		,FirstOutReg2 = rt_FirstReg2
		,FirstOutReg3 = rt_FirstReg3
		,FirstOutReg4 = rt_FirstReg4
		,LastOutCom =
			Case When LastOutCom = 'R' then
				rt_FirstDRPCom
			Else
				rt_LastCom
			End
		,LastOutCity =
			Case When LastOutCom = 'R' then
				rt_FirstDRPCity
			Else
				rt_LastCity
			End
		,LastOutState =
			Case When LastOutCom = 'R' then
				rt_FirstDRPState
			Else
				rt_LastState
			End
		,LastOutZip3 =
			Case When LastOutCom = 'R' then
				rt_FirstDRPZip3
			Else
				rt_LastZip3
			End
		,LastOutReg1 =
			Case When LastOutCom = 'R' then
				rt_FirstDRPReg1
			Else
				rt_LastReg1
			End
		,LastOutReg2 =
			Case When LastOutCom = 'R' then
				rt_FirstDRPReg2
			Else
				rt_LastReg2
			End
		,LastOutReg3 =
			Case When LastOutCom = 'R' then
				rt_FirstDRPReg3
			Else
				rt_LastReg3
			End
		,LastOutReg4 =
			Case When LastOutCom = 'R' then
				rt_FirstDRPReg4
			Else
				rt_LastReg4
			End
	From #WorkingRTTable join Metric_RTLegCache on #WorkingRTTable.Trip = Metric_RTLegCache.rt_EndLeg
	Where rt_DefName = @RTDefName
		AND rt_Seq = (Select max(rt_Seq) from Metric_RTLegCache T1 where T1.rt_DefName = @RTDefName AND T1.rt_EndLeg = Metric_RTLegCache.rt_EndLeg)

	Update #WorkingRTTable 
		Set FirstInCom =
			Case When FirstInCom = 'R' then
				rt_PUP2ndCom
			Else
				rt_FirstCom
			End
		,FirstInCity =
			Case When FirstInCity = 'R' then
				rt_PUP2ndCity
			Else
				rt_FirstCity
			End 
		,FirstInState =
			Case When FirstInState = 'R' then
				rt_PUP2ndState
			Else
				rt_FirstState
			End 
		,FirstInZip3 =
			Case When FirstInZip3 = 'R' then
				rt_PUP2ndZip3
			Else
				rt_FirstZip3
			End 
		,FirstInReg1 =
			Case When FirstInReg1 = 'R' then
				rt_PUP2ndReg1
			Else
				rt_FirstReg1
			End 
		,FirstInReg2 =
			Case When FirstInReg2 = 'R' then
				rt_PUP2ndReg2
			Else
				rt_FirstReg2
			End 
		,FirstInReg3 =
			Case When FirstInReg3 = 'R' then
				rt_PUP2ndReg3
			Else
				rt_FirstReg3
			End 
		,FirstInReg4 =
			Case When FirstInReg4 = 'R' then
				rt_PUP2ndReg4
			Else
				rt_FirstReg4
			End 
		,LastInCom = rt_LastCom
		,LastInCity = rt_LastCity
		,LastInState = rt_LastState
		,LastInZip3 = rt_LastZip3
		,LastInReg1 = rt_LastReg1
		,LastInReg2 = rt_LastReg2
		,LastInReg3 = rt_LastReg3
		,LastInReg4 = rt_LastReg4
	From #WorkingRTTable join Metric_RTLegCache on #WorkingRTTable.Trip = Metric_RTLegCache.rt_EndLeg
	Where rt_DefName = @RTDefName
		AND rt_Seq = (Select min(rt_Seq) from Metric_RTLegCache T1 where T1.rt_DefName = @RTDefName AND T1.rt_EndLeg = Metric_RTLegCache.rt_EndLeg)

	Select *
	Into #ResultsTable
	From #WorkingRTTable
	Where LastOutCom is NULL
		AND (@TractorList =',,' or CHARINDEX(',' + RTRIM( Truck ) + ',', @TractorList) >0)
		AND (@TrcType1List =',,' or CHARINDEX(',' + RTRIM( (Select trc_type1 from tractorprofile TP where TP.trc_number = Truck) ) + ',', @TrcType1List) >0)
		AND (@TrcType2List =',,' or CHARINDEX(',' + RTRIM( (Select trc_type2 from tractorprofile TP where TP.trc_number = Truck) ) + ',', @TrcType2List) >0)
		AND (@TrcType3List =',,' or CHARINDEX(',' + RTRIM( (Select trc_type3 from tractorprofile TP where TP.trc_number = Truck) ) + ',', @TrcType3List) >0)
		AND (@TrcType4List =',,' or CHARINDEX(',' + RTRIM( (Select trc_type4 from tractorprofile TP where TP.trc_number = Truck) ) + ',', @TrcType4List) >0)
		AND (@OutboundDestinationCompany =',,' or CHARINDEX(',' + RTRIM( LastInCom ) + ',', @OutboundDestinationCompany) >0)
		AND (@OutboundDestinationCity =',,' or CHARINDEX(',' + RTRIM( LastInCity ) + ',', @OutboundDestinationCity) >0)
		AND (@OutboundDestinationState =',,' or CHARINDEX(',' + RTRIM( LastInState ) + ',', @OutboundDestinationState) >0)
		AND (@OutboundDestinationZip =',,' or CHARINDEX(',' + RTRIM( LastInZip3 ) + ',', @OutboundDestinationZip) >0)
		AND (@OutboundDestinationRegion1 =',,' or CHARINDEX(',' + RTRIM( LastInReg1 ) + ',', @OutboundDestinationRegion1) >0)
		AND (@OutboundDestinationRegion2 =',,' or CHARINDEX(',' + RTRIM( LastInReg2 ) + ',', @OutboundDestinationRegion2) >0)
		AND (@OutboundDestinationRegion3 =',,' or CHARINDEX(',' + RTRIM( LastInReg3 ) + ',', @OutboundDestinationRegion3) >0)
		AND (@OutboundDestinationRegion4 =',,' or CHARINDEX(',' + RTRIM( LastInReg4 ) + ',', @OutboundDestinationRegion4) >0)

	UNION

	Select *
--	Into #ResultsTable
	From #WorkingRTTable
	Where NOT LastOutCom is NULL
		AND (@TractorList =',,' or CHARINDEX(',' + RTRIM( Truck ) + ',', @TractorList) >0)
		AND (@TrcType1List =',,' or CHARINDEX(',' + RTRIM( (Select trc_type1 from tractorprofile TP where TP.trc_number = Truck) ) + ',', @TrcType1List) >0)
		AND (@TrcType2List =',,' or CHARINDEX(',' + RTRIM( (Select trc_type2 from tractorprofile TP where TP.trc_number = Truck) ) + ',', @TrcType2List) >0)
		AND (@TrcType3List =',,' or CHARINDEX(',' + RTRIM( (Select trc_type3 from tractorprofile TP where TP.trc_number = Truck) ) + ',', @TrcType3List) >0)
		AND (@TrcType4List =',,' or CHARINDEX(',' + RTRIM( (Select trc_type4 from tractorprofile TP where TP.trc_number = Truck) ) + ',', @TrcType4List) >0)
		AND (@OutboundDestinationCompany =',,' or CHARINDEX(',' + RTRIM( LastOutCom ) + ',', @OutboundDestinationCompany) >0)
		AND (@OutboundDestinationCity =',,' or CHARINDEX(',' + RTRIM( LastOutCity ) + ',', @OutboundDestinationCity) >0)
		AND (@OutboundDestinationState =',,' or CHARINDEX(',' + RTRIM( LastOutState ) + ',', @OutboundDestinationState) >0)
		AND (@OutboundDestinationZip =',,' or CHARINDEX(',' + RTRIM( LastOutZip3 ) + ',', @OutboundDestinationZip) >0)
		AND (@OutboundDestinationRegion1 =',,' or CHARINDEX(',' + RTRIM( LastOutReg1 ) + ',', @OutboundDestinationRegion1) >0)
		AND (@OutboundDestinationRegion2 =',,' or CHARINDEX(',' + RTRIM( LastOutReg2 ) + ',', @OutboundDestinationRegion2) >0)
		AND (@OutboundDestinationRegion3 =',,' or CHARINDEX(',' + RTRIM( LastOutReg3 ) + ',', @OutboundDestinationRegion3) >0)
		AND (@OutboundDestinationRegion4 =',,' or CHARINDEX(',' + RTRIM( LastOutReg4 ) + ',', @OutboundDestinationRegion4) >0)
	Order by Truck, RTEndDate

	
	If @Mode = 'RTTotalRevenuePerDay'
		begin
			SELECT @ThisCount = Sum(TotalRevRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = CASE WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN
									1 
								ELSE 
									DATEDIFF(day, @DateStart, @DateEnd) 
								END
		end

	Else If @Mode = 'RTTotalRevPerRTEstDays'
		begin
			SELECT @ThisCount = Sum(TotalRevRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = Sum(TimeRT)
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTTotalRevPerAllMile'
		begin
			SELECT @ThisCount = Sum(TotalRevRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = Sum(AllMilesRT)
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTTotalRevPerLDMile'
		begin
			SELECT @ThisCount = Sum(TotalRevRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = Sum(LoadMilesRT)
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTLHRevPerLDMile'
		begin
			SELECT @ThisCount = Sum(LHRevRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = Sum(LoadMilesRT)
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTTotalRevPerTruck'
		begin
			SELECT @ThisCount = Sum(TotalRevRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = Count(Distinct Truck)
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTTotalRevPerRT'
		begin
			SELECT @ThisCount = Sum(TotalRevRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = Count(Distinct Trip)
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTCostPerRT'
		begin
			SELECT @ThisCount = Sum(GrossPayRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = Count(Distinct Trip)
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTMarginPerRT'
		begin
			SELECT @ThisCount = Sum(TotalRevRT) - Sum(GrossPayRT)
			FROM #ResultsTable 

			SELECT @ThisTotal = Count(Distinct Trip)
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTMarginPerTotalRevenue'	-- Margin %
		begin
			SELECT @ThisCount = Sum(TotalRevRT) - Sum(GrossPayRT)
			FROM #ResultsTable 

			SELECT @ThisTotal = Sum(TotalRevRT)
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTAllMilesPerRT'
		begin
			SELECT @ThisCount = Sum(AllMilesRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = Count(Distinct Trip)
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTAllMilesPerRTEstDays'
		begin
			SELECT @ThisCount = Sum(AllMilesRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = Sum(TimeRT)
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTDHMilesPerRT'
		begin
			SELECT @ThisCount = Sum(DHMilesRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = Count(Distinct Trip)
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTDHMilesPerAllMiles' -- DeadHead %
		begin
			SELECT @ThisCount = Sum(DHMilesRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = Sum(AllMilesRT) 
			FROM #ResultsTable 
		end

	Else If @Mode = 'RTEstDaysPerRT'
		begin
			SELECT @ThisCount = Sum(TimeRT) 
			FROM #ResultsTable 

			SELECT @ThisTotal = Count(Distinct Trip)
			FROM #ResultsTable 
		end



	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 


	IF (@ShowDetail = 1) -- RT Info
		BEGIN
			SELECT *
			FROM #ResultsTable
			Order by RTEndDate,Truck
		END
	Else If (@ShowDetail = 2) -- RT Leg Detail
		BEGIN
			SELECT *
			FROM Metric_RTLegCache
			Where rt_EndLeg in (Select Trip From #ResultsTable)
				AND rt_DefName = @RTDefName
			Order by rt_Truck,rt_EndDate,rt_Seq desc
		END

	drop table #WorkingRTTable
	drop table #ResultsTable



	--Standard Initialization of the Metric
	--The following section of commented out code will
	--	insert the metric into the metric list and allow
	--  availability for edits within the ResultsNow Application
	/*

		EXEC MetricInitializeItem
			@sMetricCode = 'RoundTripTraditional',
			@nActive = 0,	-- 1=active, 0=inactive.
			@nSort = 900, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDECIMAL = 0,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 1,
			@sCaption = 'RT_TradCalcs',
			@sCaptionFull = 'Round Trip Traditional Metrics',
			@sPROCEDUREName = 'dbo.Metric_RoundTripTraditional',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NOCATEGORY'

	*/

GO
GRANT EXECUTE ON  [dbo].[Metric_RoundTripTraditional] TO [public]
GO
