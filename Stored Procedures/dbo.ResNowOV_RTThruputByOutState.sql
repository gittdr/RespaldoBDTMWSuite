SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[ResNowOV_RTThruputByOutState]
(
	@NumberOfValues int, -- when = 0 flags for ShowDetail
	-- ** ItemID determines how the pie pieces are defined **
	@ItemID varchar(255),  -- when = '' flags for showing Detail of "other" (last piece of pie)
	@DateStart datetime = NULL, 
	@DateEnd datetime = NULL,
	@Parameters varchar(255)= Null,
	@Refresh int = 0,
    @Mode varchar(64) = Null
)

AS 

 	Declare @RNTrial_Cache TABLE
		(		
			unique_number int,
			unique_date  datetime,
			[ItemID] varchar (50),
			[Count] Money
		)   

-- code to assemble the Round Trips for processing

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
	where rt_DefName = @Parameters
		AND rt_EndLeg in (select distinct rt_EndLeg from Metric_RTLegCache MRL (NOLOCK) where MRL.rt_DefName = @Parameters AND MRL.rt_LegType = 'E' AND MRL.rt_EndDate between @DateStart AND @DateEnd)
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
	where rt_DefName = @Parameters
		AND rt_EndLeg in (select distinct rt_EndLeg from Metric_RTLegCache MRL (NOLOCK) where MRL.rt_DefName = @Parameters AND MRL.rt_LegType = 'R' AND MRL.rt_EndDate between @DateStart AND @DateEnd)
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
	Where rt_DefName = @Parameters
		AND rt_Seq = (Select max(rt_Seq) from Metric_RTLegCache T1 where T1.rt_DefName = @Parameters AND T1.rt_EndLeg = Metric_RTLegCache.rt_EndLeg)

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
	Where rt_DefName = @Parameters
		AND rt_Seq = (Select min(rt_Seq) from Metric_RTLegCache T1 where T1.rt_DefName = @Parameters AND T1.rt_EndLeg = Metric_RTLegCache.rt_EndLeg)

	Select LastInState As State
	,TotalThruput = Sum(ThruputRT) 
	,TotalDays = Sum(TimeRT)
	,TotalTrips = Count(*)
	Into #ResultsTable1
	From #WorkingRTTable
	Where LastOutCom is NULL
	Group by LastInState

	Insert Into #ResultsTable1 (State,TotalThruput,TotalDays,TotalTrips)
		Select LastOutState as State
		,TotalThruput = Sum(ThruputRT) 
		,TotalDays = Sum(TimeRT)
		,TotalTrips = Count(*)
		From #WorkingRTTable
		Where NOT LastOutCom is NULL
		Group by LastOutState

	Select State
	,TotalThruput = Sum(TotalThruput)
	,TotalDays = Sum(TotalDays)
	,TotalTrips = Sum(TotalTrips)
	,DailyThruput = Sum(TotalThruput) / Sum(TotalDays)
	Into #ResultsTable
	From #ResultsTable1 
	Group by State


-- end of code to assemble Round Trips


	IF IsNull(@NumberOfValues,0) = 0  -- If TRUE, Show the Details
		/* START DETAIL SECTION */
		BEGIN
			IF IsNull(@ItemID, '') > ''   -- If ItemID GREATER THAN (i.e., NOT) Blank, Process Top N Pie Piece(s)
				BEGIN
					/* START EXISTING SLICE */
					/* SELECT CLAUSE, FROM CLAUSE, AND DATE CONDITION WILL MATCH OTHER SLICE QUERY BELOW */
					SELECT	*
					FROM #WorkingRTTable
					/* DATE RANGE CONDITION CHANGE FIELD NAME (lgh_enddate) WHERE APPROPRIATE */
					WHERE 	RTEndDate BETWEEN @DateStart AND @DateEnd
					/* CONDITION OF EXISTING SLICE. ONLY CHANGE FIELD NAME (lgh_tm_status) BELOW WHERE APPROPRIATE */
					AND 	((LastOutCom is NULL AND LastInState = @ItemID)
								OR
							(LastOutCom is NOT NULL AND LastOutState = @ItemID))
					/* END EXISTING SLICE */
				END 
			ELSE	-- If ItemID EQUALS (i.e., IS) Blank, Process "Other" Pie Piece
				BEGIN
					/* START OTHER SLICE */
					/* SELECT CLAUSE, FROM CLAUSE, AND DATE CONDITION WILL MATCH EXISTING SLICE QUERY ABOVE */
					SELECT	*
					FROM #WorkingRTTable
					/* DATE RANGE CONDITION CHANGE FIELD NAME (lgh_enddate) WHERE APPROPRIATE */
					WHERE 	RTEndDate BETWEEN @DateStart AND @DateEnd
					/* CONDITION OF OTHER SLICE. ONLY CHANGE FIRST FIELD NAME (lgh_tm_status) BELOW WHERE APPROPRIATE */
					AND ((LastOutCom is NULL AND LastInState NOT IN (SELECT ItemID FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode))
							OR
						(LastOutCom is NOT NULL AND LastOutState NOT IN (SELECT ItemID FROM RNTrial_Cache_TopValues (NOLOCK) WHERE ItemCategory = @Mode)))
					/* ORDER BY CLAUSE CHANGE FIELD NAME WHERE APPROPRIATE */
					ORDER BY RTEndDate 
					/* END OTHER SLICE */
				END
		/* END DETAIL SECTION */
		END
	ELSE IF @Refresh = 1	-- update the cached data
		BEGIN
			/* START UPDATE CACHE SECTION */
			/* POPULATE MEMORY TABLE */
			INSERT @RNTrial_Cache
				SELECT 	0, -- field not critical, record id for debugging purposes
						@DateStart, -- field not critical, date for debugging purposes
						[ItemID] = State,
						/* COUNT IS HOW THE VALUE OF THE SLICE IS MEASURED. HERE IT IS Sum of Thruput values */
						[Count] = TotalThruput
						/* FROM AND WHERE CLAUSE SHOULD MATCH DETAIL SECTION ABOVE */
				FROM   	#ResultsTable  (NOLOCK) 	
--				WHERE 	RTEndDate BETWEEN @DateStart AND @DateEnd

			/* BELOW IS BOILER PLATE */	
			SET ROWCOUNT @NumberOfValues	-- Establish Number of Pie Pieces

			/* BELOW IS BOILER PLATE EXCEPT FOR Item Description */
			INSERT INTO RNTrial_Cache_TopValues ([LastUpdate],[DateStart],[DateEnd],[ItemCategory],
						[ItemID],[ItemDescription], [Count], [Percentage])  
				SELECT 	[LastUpdate] = GETDATE(),
						[DateStart] = @DateStart,
						[DateEnd] = @DateEnd,
						[ItemCategory] = @Mode,
						[ItemID] = RNTC.[ItemID],
						/* Item description is specific to mode */
						[ItemDescription] = RNTC.[ItemID],
						/* Item description is specific to mode */
						[Count] = SUM(RNTC.[Count]),
						[Percentage] = CONVERT(decimal(24, 5) , 100 * SUM([Count]) / CONVERT(decimal(20, 5), (SELECT SUM(RNTC1.[Count]) FROM @RNTrial_Cache RNTC1)))
				FROM @RNTrial_Cache RNTC 
				GROUP BY RNTC.[ItemID]
				ORDER BY SUM(RNTC.[Count]) DESC

			/* BELOW IS BOILER PLATE */	
			SET ROWCOUNT 0
			/* END UPDATE CACHE SECTION */
		END
GO
GRANT EXECUTE ON  [dbo].[ResNowOV_RTThruputByOutState] TO [public]
GO
