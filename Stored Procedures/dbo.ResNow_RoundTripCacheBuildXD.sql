SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ResNow_RoundTripCacheBuildXD]
(
	--Standard Parameters
	@RT_DefName varchar(255),
	@DateStart datetime, 
	@DateEnd datetime 
)
AS

/*
This stored procedure creates a cache table of round trip legs
create index rtstops on Stops (stp_departuredate,lgh_number,stp_type,stp_event,stp_mfh_sequence)
drop index rtstops on Stops

*/

	--Standard Setting
	SET NOCOUNT ON

	declare @HomeDefinitionMode varchar(10)   -- 'COMP','CITY','ZIP3','REG1','REG2','REG3','REG4'
	declare @HomeValue varchar(255)
	declare @BeginStopEvents varchar(255)	-- BMT,BBT,HLT  Events that are NOT of type PUP but would still be considered as a start
	declare @ReturnDefinitionMode varchar(10)-- 'COMP','CITY','ZIP3','REG1','REG2','REG3','REG4'
	declare @ReturnValue varchar(255)
	declare @EndStopEvents varchar(255)	-- EMT,EBT,DLT,DMT	Events that are NOT of type DRP but would still be considered as an end
	declare @MaxTimeFrameInDays int -- a 'timeout' value to stop processing if no RT
	declare @PeekAheadCompletionYN char(1)
	declare @DailyHours float 
	declare @AvgMPH float 
	declare @FuelRate float 
	declare @FuelCostInSettlementsParameter varchar(50) 	-- TrcAcctTypeList,TrcType1List,TrcType2List,TrcType3List,TrcType4List,TrcCompanyList,TrcDivisionList,TrcFleetList,TrcOwnerExcludedList
	declare @FuelInSettlementValue varchar(255)	-- appropriate value(s) to match up with label field selected above


	SET @HomeDefinitionMode = (Select rt_HomeDefinitionMode from Metric_RTDefinitions where rt_DefName = @RT_DefName)
	SET @HomeValue = (Select rt_HomeValue from Metric_RTDefinitions where rt_DefName = @RT_DefName)
	SET @BeginStopEvents = 
		Case When IsNull((Select rt_BeginStopEvents from Metric_RTDefinitions where rt_DefName = @RT_DefName),'') = '' then
			'HLT'
		Else
			(Select rt_BeginStopEvents from Metric_RTDefinitions where rt_DefName = @RT_DefName)
		End
	SET @ReturnDefinitionMode = (Select rt_ReturnDefinitionMode from Metric_RTDefinitions where rt_DefName = @RT_DefName)
	SET @ReturnValue = (Select rt_ReturnValue from Metric_RTDefinitions where rt_DefName = @RT_DefName)
	SET @EndStopEvents = 
		Case When IsNull((Select rt_EndStopEvents from Metric_RTDefinitions where rt_DefName = @RT_DefName),'') = '' then
			'DLT'
		Else
			(Select rt_EndStopEvents from Metric_RTDefinitions where rt_DefName = @RT_DefName)
		End
	SET @MaxTimeFrameInDays = 
		Case When IsNull((Select rt_MaxTimeFrameInDays from Metric_RTDefinitions where rt_DefName = @RT_DefName),0) = 0 then
			30
		Else
			(Select rt_MaxTimeFrameInDays from Metric_RTDefinitions where rt_DefName = @RT_DefName)
		End
	SET @PeekAheadCompletionYN = 
		Case When IsNull((Select rt_PeekAheadCompletionYN from Metric_RTDefinitions where rt_DefName = @RT_DefName),'') = '' then
			'Y'
		Else
			(Select rt_PeekAheadCompletionYN from Metric_RTDefinitions where rt_DefName = @RT_DefName)
		End
	SET @DailyHours = 
		Case When IsNull((Select rt_DailyHours from Metric_RTDefinitions where rt_DefName = @RT_DefName),0.0) = 0.0 then
			14.0
		Else
			(Select rt_DailyHours from Metric_RTDefinitions where rt_DefName = @RT_DefName)
		End
	SET @AvgMPH = 
		Case When IsNull((Select rt_AvgMPH from Metric_RTDefinitions where rt_DefName = @RT_DefName),0.0) = 0.0 then
			59.0
		Else
			(Select rt_AvgMPH from Metric_RTDefinitions where rt_DefName = @RT_DefName)
		End
	SET @FuelRate = IsNull((Select rt_FuelRate from Metric_RTDefinitions where rt_DefName = @RT_DefName),0.0)
	SET @FuelCostInSettlementsParameter = 
		Case When IsNull((Select rt_FuelCostInSettlementsParameter from Metric_RTDefinitions where rt_DefName = @RT_DefName),'') = '' then
			'TrcAcctTypeList'
		Else
			(Select rt_FuelCostInSettlementsParameter from Metric_RTDefinitions where rt_DefName = @RT_DefName)
		End
	SET @FuelInSettlementValue = 
		Case When IsNull((Select rt_FuelInSettlementValue from Metric_RTDefinitions where rt_DefName = @RT_DefName),'') = '' then
			'A'
		Else
			(Select rt_FuelInSettlementValue from Metric_RTDefinitions where rt_DefName = @RT_DefName)
		End

	-- local variables
	declare @Modal_StartLocation varchar(8)  -- will hold value of RT start
	declare @EndLegNumber int-- start leg
	declare @StartOfLegDate datetime -- start date of the leg being analyzed
	declare @RoundTripNumber int -- ID number for Round Trips
	declare @RTSeq int -- sequence number for sorting Round Trip legs into proper sequence
	declare @NextLegToCheck int --leg to check
	declare @Match int -- variable to hold Match calculation
	declare @SelfContainedRoundTrip int
	declare @RT_EndDate datetime -- variable to hold the ending date of the RT
	declare @EndLegSearchString varchar(30)

	-- local variables for data to be collected for metric & detail
	declare @Truck varchar(10) -- Truck

	-- initialize local variables
	set @EndLegNumber = 0
	set @RoundTripNumber = 1
	set @RTSeq = 1
	set @RT_EndDate = '1/1/1900'
	set @EndLegSearchString = ''

	--Standard List Parameter Initialization
	SET @HomeValue = ',' + ISNULL(@HomeValue,'') + ','
	SET @BeginStopEvents = ',' + ISNULL(@BeginStopEvents,'') + ','
	SET @ReturnValue = ',' + ISNULL(@ReturnValue,'') + ','
	SET @EndStopEvents = ',' + ISNULL(@EndStopEvents,'') + ','

	-- Custom Metric SQL here
	-- Create Tables to store intermediate data
	create table #t
		(	
			mov_number int
			,lgh_number int
			,lgh_tractor varchar(12)
			,lgh_startdate datetime
		)

	create table #RTDataLegs
		(	
			RoundTripID int
			,Truck varchar(10)
			,StartLeg int
			,MiddleLegs varchar(2000)
			,EndLeg int
		)

	create table #RTDataMoves
		(	
			RoundTripID int
			,Truck varchar(10)
			,StartMove int
			,MiddleMoves varchar(2000)
			,EndMove int
		)
	create table #RTripLegs
		(	
			truck varchar(10),
			StartLeg int,
			MiddleLegs varchar(8000),
			EndLeg int
		)

	create table #RTripMoves
		(	
			truck varchar(10),
			StartMove int,
			MiddleMoves varchar(8000),
			EndMove int
		)
	create table #rtrips2
		(
			RTEndLeg int,
			RTEndDate datetime,
			trip int,
			seq int,
			truck varchar(10),
			lgh int,
			RTLegType char(1)
		)


	--  set return variable
	if @HomeDefinitionMode = 'COMP'
		Begin
			SET @Modal_StartLocation = @HomeValue
		End

	if @HomeDefinitionMode = 'ZIP3'
		Begin
			SET @Modal_StartLocation = @HomeValue
		End

	if @HomeDefinitionMode = 'CITY'
		Begin
			SET @Modal_StartLocation = @HomeValue
		End

	if @HomeDefinitionMode = 'REG1'
		Begin
			SET @Modal_StartLocation = @HomeValue
		End

	if @HomeDefinitionMode = 'REG2'
		Begin
			SET @Modal_StartLocation = @HomeValue
		End

	if @HomeDefinitionMode = 'REG3'
		Begin
			SET @Modal_StartLocation = @HomeValue
		End

	if @HomeDefinitionMode = 'REG4'
		Begin
			SET @Modal_StartLocation = @HomeValue
		End


	--	using the following leg pools because need to use FIRST pickup event and
	--	LAST drop event on each leg.  only way to be sure is at stop level but rest
	--	of analysis is done at leg level.  use stops to create pool of legs then
	--	proceed to leg analysis.
	--	select pool of legs to process
	Select stops.mov_number
	,stops.lgh_number
	,lgh_startdate --= stp_arrivaldate
	,cmp_id_start = cmp_id
	,lgh_startcity = cast(stp_city as varchar)
	,lgh_startstate = stp_state
	,startzip = dbo.fnc_TMWRN_GetZip3(stp_city)
	,lgh_startregion1 = (select cty_region1 from city (NOLOCK) where cty_code = stp_city)
	,lgh_startregion2 = (select cty_region2 from city (NOLOCK) where cty_code = stp_city)
	,lgh_startregion3 = (select cty_region3 from city (NOLOCK) where cty_code = stp_city)
	,lgh_startregion4 = (select cty_region4 from city (NOLOCK) where cty_code = stp_city)
	into #TempLegListingPUP
	from stops (NOLOCK) join legheader (NOLOCK) on stops.lgh_number = legheader.lgh_number
	where lgh_enddate between (@DateStart - @MaxTimeFrameInDays) and @DateEnd 
	-- skip loads where tractor is UNKNOWN because unlikely to have brokered round trips
	AND lgh_tractor <> 'UNKNOWN'
	AND (
			stp_type = 'PUP'
				OR
			(@BeginStopEvents =',,' or CHARINDEX(',' + RTRIM( stp_event  ) + ',', @BeginStopEvents) > 0)
		)
	AND stp_mfh_sequence = (select min(stp_mfh_sequence)
							from stops S1 (NOLOCK)
							where S1.lgh_number = stops.lgh_number
							AND (
									S1.stp_type = 'PUP'
										OR
									(@BeginStopEvents =',,' or CHARINDEX(',' + RTRIM( S1.stp_event  ) + ',', @BeginStopEvents) > 0)
								))


	--	select pool of first outbound drop legs
	Select stops.mov_number
	,stops.lgh_number
	,cmp_id_end = cmp_id
	,lgh_endcity = cast(stp_city as varchar)
	,lgh_endstate = stp_state
	,endzip = dbo.fnc_TMWRN_GetZip3(stp_city)
	,lgh_endregion1 = (select cty_region1 from city (NOLOCK) where cty_code = stp_city)
	,lgh_endregion2 = (select cty_region2 from city (NOLOCK) where cty_code = stp_city)
	,lgh_endregion3 = (select cty_region3 from city (NOLOCK) where cty_code = stp_city)
	,lgh_endregion4 = (select cty_region4 from city (NOLOCK) where cty_code = stp_city)
	into #TempLegListingFODRP
	from stops (NOLOCK) join legheader (NOLOCK) on stops.lgh_number = legheader.lgh_number
	where lgh_enddate between (@DateStart - @MaxTimeFrameInDays) and @DateEnd 
	AND lgh_tractor <> 'UNKNOWN'
	AND (
			stp_type = 'DRP'
				OR
			(@EndStopEvents =',,' or CHARINDEX(',' + RTRIM( stp_event  ) + ',', @EndStopEvents) > 0)
		)
	AND stp_mfh_sequence = (select min(stp_mfh_sequence)
							from stops S1 (NOLOCK)
							where S1.lgh_number = stops.lgh_number
							AND (
									stp_type = 'DRP'
										OR
									(@EndStopEvents =',,' or CHARINDEX(',' + RTRIM( stp_event  ) + ',', @EndStopEvents) > 0)
								)
							AND S1.stp_mfh_sequence < (select max(stp_mfh_sequence)
														from stops S1 (NOLOCK)
														where S1.lgh_number = stops.lgh_number
														AND (
																stp_type = 'DRP'
																	OR
																(@EndStopEvents =',,' or CHARINDEX(',' + RTRIM( stp_event  ) + ',', @EndStopEvents) > 0)
															)))


	--	select pool of second outbound pick legs
	Select stops.mov_number
	,stops.lgh_number
	,cmp_id_start = cmp_id
	,lgh_startcity = cast(stp_city as varchar)
	,lgh_endstate = stp_state
	,startzip = dbo.fnc_TMWRN_GetZip3(stp_city)
	,lgh_startregion1 = (select cty_region1 from city (NOLOCK) where cty_code = stp_city)
	,lgh_startregion2 = (select cty_region2 from city (NOLOCK) where cty_code = stp_city)
	,lgh_startregion3 = (select cty_region3 from city (NOLOCK) where cty_code = stp_city)
	,lgh_startregion4 = (select cty_region4 from city (NOLOCK) where cty_code = stp_city)
	into #TempLegListingSOPUP
	from stops (NOLOCK) join legheader (NOLOCK) on stops.lgh_number = legheader.lgh_number
	where lgh_enddate between (@DateStart - @MaxTimeFrameInDays) and @DateEnd 
	AND lgh_tractor <> 'UNKNOWN'
	AND (
			stp_type = 'PUP'
				OR
			(@BeginStopEvents =',,' or CHARINDEX(',' + RTRIM( stp_event  ) + ',', @BeginStopEvents) > 0)
		)
	AND stp_mfh_sequence = (select min(stp_mfh_sequence)
							from stops S1 (NOLOCK)
							where S1.lgh_number = stops.lgh_number
							AND (
									stp_type = 'PUP'
										OR
									(@BeginStopEvents =',,' or CHARINDEX(',' + RTRIM( stp_event  ) + ',', @BeginStopEvents) > 0)
								)
							AND S1.stp_mfh_sequence > (select min(stp_mfh_sequence)
														from stops S1 (NOLOCK)
														where S1.lgh_number = stops.lgh_number
														AND (
																stp_type = 'DRP'
																	OR
																(@EndStopEvents =',,' or CHARINDEX(',' + RTRIM( stp_event  ) + ',', @EndStopEvents) > 0)
															)))

	--	select pool of possible RT completion legs
	Select stops.mov_number
	,stops.lgh_number
	,lgh_tractor 
	,trc_type1
	,trc_type2
	,trc_type3
	,trc_type4
	,lgh_enddate
	,cmp_id_end = cmp_id
	,lgh_endcity = cast(stp_city as varchar)
	,lgh_endstate = stp_state
	,endzip = dbo.fnc_TMWRN_GetZip3(stp_city)
	,lgh_endregion1 = (select cty_region1 from city (NOLOCK) where cty_code = stp_city)
	,lgh_endregion2 = (select cty_region2 from city (NOLOCK) where cty_code = stp_city)
	,lgh_endregion3 = (select cty_region3 from city (NOLOCK) where cty_code = stp_city)
	,lgh_endregion4 = (select cty_region4 from city (NOLOCK) where cty_code = stp_city)
	into #TempLegListingDRP
	from stops (NOLOCK) join legheader (NOLOCK) on stops.lgh_number = legheader.lgh_number
	where lgh_enddate between (@DateStart - @MaxTimeFrameInDays) and @DateEnd 
	-- DO need widened timeframe for this one even though this is very LAST leg of RT and MUST
	-- end within the specified timeframe to be considered; values are used in RT data population
	AND lgh_tractor <> 'UNKNOWN'
	AND (
			stp_type = 'DRP'
				OR
			(@EndStopEvents =',,' or CHARINDEX(',' + RTRIM( stp_event  ) + ',', @EndStopEvents) > 0)
		)
	AND stp_mfh_sequence = (select max(stp_mfh_sequence)
							from stops S1 (NOLOCK)
							where S1.lgh_number = stops.lgh_number
							AND (
									stp_type = 'DRP'
										OR
									(@EndStopEvents =',,' or CHARINDEX(',' + RTRIM( stp_event  ) + ',', @EndStopEvents) > 0)
								))
	Order by Convert(varchar,Cast(lgh_enddate as float),1) + '-' + cast(legheader.lgh_number as varchar)

	-- delete the most recent 7 days of cache data for this @RT_DefName because data can be unsettled for a while
	Delete from Metric_RTLegCache
	Where rt_DefName = @RT_DefName 
		AND rt_EndDate > DateAdd(d,-7,@DateEnd)

	-- begin processing
	while 1=1
		begin
			select 	@EndLegSearchString = min(Convert(varchar,Cast(lgh_enddate as float),1) + '-' + cast(lgh_number as varchar))
			from	#TempLegListingDRP (NOLOCK) 
			where lgh_enddate between @DateStart and @DateEnd
				AND ((
					(@ReturnDefinitionMode = 'COMP' AND CHARINDEX(',' + RTRIM( cmp_id_end ) + ',', @ReturnValue) >0)
						OR
					(@ReturnDefinitionMode = 'CITY' AND CHARINDEX(',' + RTRIM( lgh_endcity ) + ',', @ReturnValue) >0)
						OR
					(@ReturnDefinitionMode = 'ZIP3' AND CHARINDEX(',' + RTRIM( endzip ) + ',', @ReturnValue) >0)
						OR
					(@ReturnDefinitionMode = 'REG1' AND CHARINDEX(',' + RTRIM( lgh_endregion1 ) + ',', @ReturnValue) >0)
						OR
					(@ReturnDefinitionMode = 'REG2' AND CHARINDEX(',' + RTRIM( lgh_endregion2 ) + ',', @ReturnValue) >0)
						OR
					(@ReturnDefinitionMode = 'REG3' AND CHARINDEX(',' + RTRIM( lgh_endregion3 ) + ',', @ReturnValue) >0)
						OR
					(@ReturnDefinitionMode = 'REG4' AND CHARINDEX(',' + RTRIM( lgh_endregion4 ) + ',', @ReturnValue) >0)
				)

					OR
				(@PeekAheadCompletionYN = 'Y' AND (
-- this is tricky stuff; if @HomeValue = @ReturnValue then it is POSSIBLE to peek ahead and capture RT that is closed by deadhead link at start of NEXT leg
					(@HomeDefinitionMode = 'COMP' AND @HomeValue = @ReturnValue 
						AND CHARINDEX(',' + (Select cmp_id 
											from stops (NOLOCK) join legheader (NOLOCK) on stops.lgh_number = legheader.lgh_number 
											where stops.lgh_number = (select NextLeg 
																		from vw_TMWRN_PrevNextLegs (NOLOCK) 
																		where lgh_number = #TempLegListingDRP.lgh_number)
											AND stp_mfh_sequence = (select min(stp_mfh_sequence)
																	from stops S1 (NOLOCK)
																	where S1.lgh_number = stops.lgh_number
																	AND (
																			S1.stp_type = 'PUP'
																				OR
																			(@BeginStopEvents =',,' or CHARINDEX(',' + RTRIM( S1.stp_event  ) + ',', @BeginStopEvents) > 0)
																		))) + ',', @HomeValue) >0)

--					(@HomeDefinitionMode = 'COMP' AND @HomeValue = @ReturnValue AND CHARINDEX(',' + RTRIM( (Select cmp_id_rstart from legheader (NOLOCK) where lgh_number = (select NextLeg from vw_TMWRN_PrevNextLegs (NOLOCK) where lgh_number = #TempLegListingDRP.lgh_number)) ) + ',', @HomeValue) >0)
						OR
					(@HomeDefinitionMode = 'CITY' AND @HomeValue = @ReturnValue 
						AND CHARINDEX(',' + (Select lgh_startcity = cast(stp_city as varchar)
											from stops (NOLOCK) join legheader (NOLOCK) on stops.lgh_number = legheader.lgh_number 
											where stops.lgh_number = (select NextLeg 
																		from vw_TMWRN_PrevNextLegs (NOLOCK) 
																		where lgh_number = #TempLegListingDRP.lgh_number)
											AND stp_mfh_sequence = (select min(stp_mfh_sequence)
																	from stops S1 (NOLOCK)
																	where S1.lgh_number = stops.lgh_number
																	AND (
																			S1.stp_type = 'PUP'
																				OR
																			(@BeginStopEvents =',,' or CHARINDEX(',' + RTRIM( S1.stp_event  ) + ',', @BeginStopEvents) > 0)
																		))) + ',', @HomeValue) >0)


--					(@HomeDefinitionMode = 'CITY' AND @HomeValue = @ReturnValue AND CHARINDEX(',' + RTRIM( (Select cast(lgh_rstartcity as varchar) from legheader (NOLOCK) where lgh_number = (select NextLeg from vw_TMWRN_PrevNextLegs (NOLOCK) where lgh_number = #TempLegListingDRP.lgh_number)) ) + ',', @HomeValue) >0)
						OR
					(@HomeDefinitionMode = 'ZIP3' AND @HomeValue = @ReturnValue 
						AND CHARINDEX(',' + (Select startzip = dbo.fnc_TMWRN_GetZip3(stp_city)
											from stops (NOLOCK) join legheader (NOLOCK) on stops.lgh_number = legheader.lgh_number 
											where stops.lgh_number = (select NextLeg 
																		from vw_TMWRN_PrevNextLegs (NOLOCK) 
																		where lgh_number = #TempLegListingDRP.lgh_number)
											AND stp_mfh_sequence = (select min(stp_mfh_sequence)
																	from stops S1 (NOLOCK)
																	where S1.lgh_number = stops.lgh_number
																	AND (
																			S1.stp_type = 'PUP'
																				OR
																			(@BeginStopEvents =',,' or CHARINDEX(',' + RTRIM( S1.stp_event  ) + ',', @BeginStopEvents) > 0)
																		))) + ',', @HomeValue) >0)


--					(@HomeDefinitionMode = 'ZIP3' AND @HomeValue = @ReturnValue AND CHARINDEX(',' + RTRIM( (Select dbo.fnc_TMWRN_GetZip3(lgh_rstartcity) from legheader (NOLOCK) where lgh_number = (select NextLeg from vw_TMWRN_PrevNextLegs (NOLOCK) where lgh_number = #TempLegListingDRP.lgh_number)) ) + ',', @HomeValue) >0)
						OR
					(@HomeDefinitionMode = 'REG1' AND @HomeValue = @ReturnValue 
						AND CHARINDEX(',' + (Select lgh_startregion1 = (select cty_region1 from city (NOLOCK) where cty_code = stp_city) 
											from stops (NOLOCK) join legheader (NOLOCK) on stops.lgh_number = legheader.lgh_number 
											where stops.lgh_number = (select NextLeg 
																		from vw_TMWRN_PrevNextLegs (NOLOCK) 
																		where lgh_number = #TempLegListingDRP.lgh_number)
											AND stp_mfh_sequence = (select min(stp_mfh_sequence)
																	from stops S1 (NOLOCK)
																	where S1.lgh_number = stops.lgh_number
																	AND (
																			S1.stp_type = 'PUP'
																				OR
																			(@BeginStopEvents =',,' or CHARINDEX(',' + RTRIM( S1.stp_event  ) + ',', @BeginStopEvents) > 0)
																		))) + ',', @HomeValue) >0)

--					(@HomeDefinitionMode = 'REG1' AND @HomeValue = @ReturnValue AND CHARINDEX(',' + RTRIM( (Select lgh_rstartregion1 from legheader (NOLOCK) where lgh_number = (select NextLeg from vw_TMWRN_PrevNextLegs (NOLOCK) where lgh_number = #TempLegListingDRP.lgh_number)) ) + ',', @HomeValue) >0)
						OR
					(@HomeDefinitionMode = 'REG2' AND @HomeValue = @ReturnValue 
						AND CHARINDEX(',' + (Select lgh_startregion2 = (select cty_region2 from city (NOLOCK) where cty_code = stp_city) 
											from stops (NOLOCK) join legheader (NOLOCK) on stops.lgh_number = legheader.lgh_number 
											where stops.lgh_number = (select NextLeg 
																		from vw_TMWRN_PrevNextLegs (NOLOCK) 
																		where lgh_number = #TempLegListingDRP.lgh_number)
											AND stp_mfh_sequence = (select min(stp_mfh_sequence)
																	from stops S1 (NOLOCK)
																	where S1.lgh_number = stops.lgh_number
																	AND (
																			S1.stp_type = 'PUP'
																				OR
																			(@BeginStopEvents =',,' or CHARINDEX(',' + RTRIM( S1.stp_event  ) + ',', @BeginStopEvents) > 0)
																		))) + ',', @HomeValue) >0)

--					(@HomeDefinitionMode = 'REG2' AND @HomeValue = @ReturnValue AND CHARINDEX(',' + RTRIM( (Select lgh_rstartregion2 from legheader (NOLOCK) where lgh_number = (select NextLeg from vw_TMWRN_PrevNextLegs (NOLOCK) where lgh_number = #TempLegListingDRP.lgh_number)) ) + ',', @HomeValue) >0)
						OR
					(@HomeDefinitionMode = 'REG3' AND @HomeValue = @ReturnValue 
						AND CHARINDEX(',' + (Select lgh_startregion3 = (select cty_region3 from city (NOLOCK) where cty_code = stp_city) 
											from stops (NOLOCK) join legheader (NOLOCK) on stops.lgh_number = legheader.lgh_number 
											where stops.lgh_number = (select NextLeg 
																		from vw_TMWRN_PrevNextLegs (NOLOCK) 
																		where lgh_number = #TempLegListingDRP.lgh_number)
											AND stp_mfh_sequence = (select min(stp_mfh_sequence)
																	from stops S1 (NOLOCK)
																	where S1.lgh_number = stops.lgh_number
																	AND (
																			S1.stp_type = 'PUP'
																				OR
																			(@BeginStopEvents =',,' or CHARINDEX(',' + RTRIM( S1.stp_event  ) + ',', @BeginStopEvents) > 0)
																		))) + ',', @HomeValue) >0)

--					(@HomeDefinitionMode = 'REG3' AND @HomeValue = @ReturnValue AND CHARINDEX(',' + RTRIM( (Select lgh_rstartregion3 from legheader (NOLOCK) where lgh_number = (select NextLeg from vw_TMWRN_PrevNextLegs (NOLOCK) where lgh_number = #TempLegListingDRP.lgh_number)) ) + ',', @HomeValue) >0)
						OR
					(@HomeDefinitionMode = 'REG4' AND @HomeValue = @ReturnValue 
						AND CHARINDEX(',' + (Select lgh_startregion4 = (select cty_region4 from city (NOLOCK) where cty_code = stp_city) 
											from stops (NOLOCK) join legheader (NOLOCK) on stops.lgh_number = legheader.lgh_number 
											where stops.lgh_number = (select NextLeg 
																		from vw_TMWRN_PrevNextLegs (NOLOCK) 
																		where lgh_number = #TempLegListingDRP.lgh_number)
											AND stp_mfh_sequence = (select min(stp_mfh_sequence)
																	from stops S1 (NOLOCK)
																	where S1.lgh_number = stops.lgh_number
																	AND (
																			S1.stp_type = 'PUP'
																				OR
																			(@BeginStopEvents =',,' or CHARINDEX(',' + RTRIM( S1.stp_event  ) + ',', @BeginStopEvents) > 0)
																		))) + ',', @HomeValue) >0)

--					(@HomeDefinitionMode = 'REG4' AND @HomeValue = @ReturnValue AND CHARINDEX(',' + RTRIM( (Select lgh_rstartregion4 from legheader (NOLOCK) where lgh_number = (select NextLeg from vw_TMWRN_PrevNextLegs (NOLOCK) where lgh_number = #TempLegListingDRP.lgh_number)) ) + ',', @HomeValue) >0)
				)))
				AND Convert(varchar,Cast(lgh_enddate as float),1) + '-' + cast(lgh_number as varchar) > Convert(varchar,Cast(@RT_EndDate as float),1) + '-' + cast(@EndLegNumber as varchar)

	--	if (when) no Leg meets criteria, break outer loop (i.e., end stored proc)
			if @EndLegSearchString is NULL BREAK

	--	parse out the leg value
			SET @EndLegNumber = Convert(int,SubString(@EndLegSearchString,CharIndex('-',@EndLegSearchString)+1,10))

	--	initialize @SelfContainedRoundTrip to assume multi-leg roundtrip
			Set @SelfContainedRoundTrip = 0

	--	use appropriate HomeDefinitionMode and select Modal_StartingLocation, 
	--	Leg Start Date, and Truck
			if @HomeDefinitionMode = 'COMP'
				Begin
					select 	@StartOfLegDate = lgh_startdate,
					@RT_EndDate = lgh_enddate,
					@Truck = lgh_tractor
					from legheader (NOLOCK)
					where lgh_number = @EndLegNumber

					select @SelfContainedRoundTrip = Count(*)
					from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
					where	legheader.lgh_number = @EndLegNumber
					and (CHARINDEX(',' + RTRIM( legheader.cmp_id_start ) + ',', @Modal_StartLocation) > 0
							OR 
						CHARINDEX(',' + RTRIM( #TempLegListingPUP.cmp_id_start ) + ',', @Modal_StartLocation) > 0)
				End

			if @HomeDefinitionMode = 'CITY'
				Begin
					select 	@StartOfLegDate = lgh_startdate,
					@RT_EndDate = lgh_enddate,
					@Truck = lgh_tractor 
					from legheader (NOLOCK)
					where lgh_number = @EndLegNumber

					select @SelfContainedRoundTrip = Count(*)
					from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
					where	legheader.lgh_number = @EndLegNumber
					and (CHARINDEX(',' + RTRIM( cast(legheader.lgh_startcity as varchar) ) + ',', @Modal_StartLocation) > 0
							OR 
						CHARINDEX(',' + RTRIM( #TempLegListingPUP.lgh_startcity ) + ',', @Modal_StartLocation) > 0)
				End

			if @HomeDefinitionMode = 'ZIP3'
				Begin
					select 	@StartOfLegDate = lgh_startdate,
					@RT_EndDate = lgh_enddate,
					@Truck = lgh_tractor 
					from legheader (NOLOCK)
					where lgh_number = @EndLegNumber

					select @SelfContainedRoundTrip = Count(*)
					from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
					where	legheader.lgh_number = @EndLegNumber
					and (CHARINDEX(',' + RTRIM( dbo.fnc_TMWRN_GetZip3(legheader.lgh_startcity) ) + ',', @Modal_StartLocation) > 0
							OR 
						CHARINDEX(',' + RTRIM( #TempLegListingPUP.startzip ) + ',', @Modal_StartLocation) > 0)
				End

			if @HomeDefinitionMode = 'REG1'
				Begin
					select 	@StartOfLegDate = lgh_startdate,
					@RT_EndDate = lgh_enddate,
					@Truck = lgh_tractor
					from Legheader (NOLOCK)
					where lgh_number = @EndLegNumber

					select @SelfContainedRoundTrip = Count(*)
					from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
					where	legheader.lgh_number = @EndLegNumber
					and (CHARINDEX(',' + RTRIM( legheader.lgh_startregion1 ) + ',', @Modal_StartLocation) > 0
							OR 
						CHARINDEX(',' + RTRIM( #TempLegListingPUP.lgh_startregion1 ) + ',', @Modal_StartLocation) > 0)
				End

			if @HomeDefinitionMode = 'REG2'
				Begin
					select 	@StartOfLegDate = lgh_startdate,
					@RT_EndDate = lgh_enddate,
					@Truck = lgh_tractor 
					from Legheader (NOLOCK)
					where lgh_number = @EndLegNumber

					select @SelfContainedRoundTrip = Count(*)
					from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
					where	legheader.lgh_number = @EndLegNumber
					and (CHARINDEX(',' + RTRIM( legheader.lgh_startregion2 ) + ',', @Modal_StartLocation) > 0
							OR 
						CHARINDEX(',' + RTRIM( #TempLegListingPUP.lgh_startregion2 ) + ',', @Modal_StartLocation) > 0)
				End

			if @HomeDefinitionMode = 'REG3'
				Begin
					select 	@StartOfLegDate = lgh_startdate,
					@RT_EndDate = lgh_enddate,
					@Truck = lgh_tractor 
					from legheader (NOLOCK)
					where lgh_number = @EndLegNumber

					select @SelfContainedRoundTrip = Count(*)
					from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
					where	legheader.lgh_number = @EndLegNumber
					and (CHARINDEX(',' + RTRIM( legheader.lgh_startregion3 ) + ',', @Modal_StartLocation) > 0
							OR 
						CHARINDEX(',' + RTRIM( #TempLegListingPUP.lgh_startregion3 ) + ',', @Modal_StartLocation) > 0)
				End

			if @HomeDefinitionMode = 'REG4'
				Begin
					select 	@StartOfLegDate = lgh_startdate,
					@RT_EndDate = lgh_enddate,
					@Truck = lgh_tractor
					from legheader (NOLOCK)
					where lgh_number = @EndLegNumber

					select @SelfContainedRoundTrip = Count(*)
					from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
					where	legheader.lgh_number = @EndLegNumber
					and (CHARINDEX(',' + RTRIM( legheader.lgh_startregion4 ) + ',', @Modal_StartLocation) > 0
							OR 
						CHARINDEX(',' + RTRIM( #TempLegListingPUP.lgh_startregion4 ) + ',', @Modal_StartLocation) > 0)
				End

	--	write StartLegNumber,Truck and Leg Start Date to #t 
			insert into #t		
			select 	mov_number
			,lgh_number
			,@Truck
			,lgh_startdate
			from #TempLegListingPUP (NOLOCK)
			where lgh_number = @EndLegNumber

	--	write Truck, StartLeg, 2 blanks into #RTripLegs and #RTripMoves
	--	values written differ if self-contained round trip
			If @SelfContainedRoundTrip = 0
				insert into #RTripLegs
				select @Truck,'','',lgh_number
				from #t (NOLOCK)
			Else
				insert into #RTripLegs
				select @Truck,lgh_number,'',lgh_number
				from #t (NOLOCK)

			If @SelfContainedRoundTrip = 0
				insert into #RTripMoves
				select @Truck,'','',mov_number
				from #t (NOLOCK)
			Else
				insert into #RTripMoves
				select @Truck,mov_number,'',mov_number
				from #t (NOLOCK)

	--	write RoundtripID number, Truck, StartLeg and constant 'S' (for Start) to #rtrips2
	--	values written differ if self-contained round trip
			If @SelfContainedRoundTrip = 0
				insert into #rtrips2
				select @EndLegNumber,@RT_EndDate,@RoundTripNumber,@RTSeq,@Truck,lgh_number,'E'
				from #t (NOLOCK)
			Else
				insert into #rtrips2
				select @EndLegNumber,@RT_EndDate,@RoundTripNumber,@RTSeq,@Truck,lgh_number,'R'
				from #t (NOLOCK)

			select	@StartOfLegDate = lgh_startdate,
			@EndLegNumber = lgh_number
			from  #t (NOLOCK)

			select @Match = 0
			select @NextLegToCheck = 0

			select	@NextLegToCheck = prevleg
			from  vw_TMWRN_PrevNextLegs (NOLOCK)
			where 	lgh_number = @EndLegNumber
			and prevleg is not null



	-- inner loop to identify middle and end legs
			while 1=1  
				begin

	-- if @NextLegToCheck is already used in a round trip, break inner loop
					Select @Match = NULL
					Where Exists (Select * From #rtrips2 Where lgh = @NextLegToCheck)
						OR Exists (Select * From Metric_RTLegCache where rt_DefName = @RT_DefName AND rt_leg = @NextLegToCheck)

	-- if this is end of the line with no NextLeg, break inner loop
					If @NextLegToCheck = 0 Set @Match = NULL

	-- if this is self-contained round trip, break inner loop
					If @SelfContainedRoundTrip = 1 Set @Match = NULL

					if @Match is null BREAK

					set @RTSeq = @RTSeq + 1

	--	use appropriate @HomeDefinitionMode to see if NextLeg ends at Modal_StartLocation
	--	if so, @Match = 1 and RT is complete; if not, @Match = 0 and RT continues

					if @HomeDefinitionMode = 'COMP'	
						begin   
							select	@Match = count(*)
							from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
							where	legheader.lgh_number = @NextLegToCheck
							and (CHARINDEX(',' + RTRIM( legheader.cmp_id_start ) + ',', @Modal_StartLocation) > 0
									OR 
								CHARINDEX(',' + RTRIM( #TempLegListingPUP.cmp_id_start ) + ',', @Modal_StartLocation) > 0)
						end

					if @HomeDefinitionMode = 'CITY'	   
						Begin
							select	@Match = count(*)
							from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
							where	legheader.lgh_number = @NextLegToCheck
							and (CHARINDEX(',' + RTRIM( Cast(legheader.lgh_startcity as VarChar) ) + ',', @Modal_StartLocation) > 0
									OR 
								CHARINDEX(',' + RTRIM( #TempLegListingPUP.lgh_startcity ) + ',', @Modal_StartLocation) > 0)
						End

					if @HomeDefinitionMode = 'ZIP3'	   
						begin
							select	@Match = count(*)
							from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
							where	legheader.lgh_number = @NextLegToCheck
							and (CHARINDEX(',' + RTRIM( dbo.fnc_TMWRN_GetZip3(legheader.lgh_startcity) ) + ',', @Modal_StartLocation) > 0
									OR 
								CHARINDEX(',' + RTRIM( #TempLegListingPUP.startzip ) + ',', @Modal_StartLocation) > 0)
						End

					if @HomeDefinitionMode = 'REG1'
						Begin
							select	@Match = count(*)
							from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
							where	legheader.lgh_number = @NextLegToCheck
							and (CHARINDEX(',' + RTRIM( legheader.lgh_startregion1 ) + ',', @Modal_StartLocation) > 0
									OR 
								CHARINDEX(',' + RTRIM( #TempLegListingPUP.lgh_startregion1 ) + ',', @Modal_StartLocation) > 0)
						END

					if @HomeDefinitionMode = 'REG2'
						Begin
							select	@Match = count(*)
							from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
							where	legheader.lgh_number = @NextLegToCheck
							and (CHARINDEX(',' + RTRIM( legheader.lgh_startregion2 ) + ',', @Modal_StartLocation) > 0
									OR 
								CHARINDEX(',' + RTRIM( #TempLegListingPUP.lgh_startregion2 ) + ',', @Modal_StartLocation) > 0)
						End

					if @HomeDefinitionMode = 'REG3'
						Begin
							select	@Match = count(*)
							from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
							where	legheader.lgh_number = @NextLegToCheck
							and (CHARINDEX(',' + RTRIM( legheader.lgh_startregion3 ) + ',', @Modal_StartLocation) > 0
									OR 
								CHARINDEX(',' + RTRIM( #TempLegListingPUP.lgh_startregion3 ) + ',', @Modal_StartLocation) > 0)
						End

					if @HomeDefinitionMode = 'REG4'
						Begin
							select	@Match = count(*)
							from	legheader (NOLOCK) join #TempLegListingPUP (NOLOCK) on legheader.lgh_number = #TempLegListingPUP.lgh_number
							where	legheader.lgh_number = @NextLegToCheck
							and (CHARINDEX(',' + RTRIM( legheader.lgh_startregion4 ) + ',', @Modal_StartLocation) > 0
									OR 
								CHARINDEX(',' + RTRIM( #TempLegListingPUP.lgh_startregion4 ) + ',', @Modal_StartLocation) > 0)
						End

					if @Match = 0
						begin
							update	#RTripLegs
							set		MiddleLegs = ',' + convert(varchar,@NextLegToCheck) + MiddleLegs

							update	#RTripMoves
							set		MiddleMoves = ',' + (Select convert(varchar,mov_number) + MiddleMoves
															From legheader
															where lgh_number = @NextLegToCheck)
							insert into #rtrips2
							values (@EndLegNumber,@RT_EndDate,@RoundTripNumber,@RTSeq,@Truck,@NextLegToCheck,'M')

							select	@NextLegToCheck = prevleg
							from	vw_TMWRN_PrevNextLegs (NOLOCK)
							where	lgh_number = @NextLegToCheck
								
	--	if the NextLeg OF THE NextLeg is NULL then Get Out of logic b/c doesn't get home yet
							if isNull(@NextLegToCheck,-99) = -99
								begin
									set @Match = NULL
								end
						end

					if @Match > 0 
						begin
							insert into #rtrips2
							values (@EndLegNumber,@RT_EndDate,@RoundTripNumber,@RTSeq,@Truck,@NextLegToCheck,'S')

							update	#RTripLegs
							set	StartLeg = @NextLegToCheck

							update	#RTripMoves
							set		StartMove = (Select mov_number
												From legheader
												where lgh_number = @NextLegToCheck)

	--	reached the end of this RT so set @Match to NULL to break this loop
							select @Match = NULL	
						end

	--	if RT not complete yet but timeframe exceeds @MaxTimeFrameInDays set @Match to NULL to break this loop
					if (select datediff(dd,lgh_startdate,@StartOfLegDate) 
						from legheader (NOLOCK) where lgh_number = @NextLegToCheck) > @MaxTimeFrameInDays
						begin
							select @Match = NULL
						end --here
				end -- end middle/end legs loop

			insert into #RTDataLegs
			select	@RoundTripNumber, *
			from	#RTripLegs (NOLOCK)

			insert into #RTDataMoves
			select	@RoundTripNumber, *
			from	#RTripMoves (NOLOCK)

			select @RoundTripNumber = @RoundTripNumber + 1
			select @RTSeq = 1

			select	@Match = 0

			delete from #t
			delete from #RTripLegs
			delete from #RTripMoves
		END -- end outer loop

/*	
	select RoundTripID
	,Truck
	,StartLeg
	,MiddleLegs
	,EndLeg 
	from #RTDataLegs (NOLOCK)
	where EndLeg > 0
	order by Truck,RoundTripID

	select RoundTripID
	,Truck
	,StartMove
	,MiddleMoves
	,EndMove 
	from #RTDataMoves (NOLOCK)
	where EndMove > 0
	order by Truck,RoundTripID
*/

	-- create Leg Detail 
	select @RT_DefName as RTDefName
	,RTEndLeg
	,RTEndDate
	,Seq
	,Move = mov_number
	,Truck
	,LegStart = lgh_startdate
	,Leg = lgh
	,LegEnd = lgh_enddate
	,RTLegType
	,TimeForLeg = IsNull(dbo.fnc_TMWRN_GetEstLegTime(Legheader.lgh_number,@DailyHours,0.25,@AvgMPH,Default,Default),0)
	--	revenue
	,LHRevForLeg =  Round(IsNull(dbo.fnc_TMWRN_Revenue3('Leg',default,default,Legheader.mov_number,default,Legheader.lgh_number,default,default,'L',default,default,'N','N',default,default,'ALL',default,default,default),0),2)
	,ACCRevForLeg = Round(IsNull(dbo.fnc_TMWRN_Revenue3('Leg',default,default,Legheader.mov_number,default,Legheader.lgh_number,default,default,'A',default,default,'N','N',default,default,'ALL',default,default,default),0),2)
	,LoadMiles = IsNull(dbo.fnc_TMWRN_Miles('LegHeader','Travel','Miles',default,default,lgh_number,default,'LD',default,default,default),0)
	,DHMiles = IsNull(dbo.fnc_TMWRN_Miles('LegHeader','Travel','Miles',default,default,lgh_number,default,'MT',default,default,default),0)
	--	TVC
	,GrossPayForLeg = IsNull(dbo.fnc_TMWRN_Pay(default,default,default,default,default,lgh_number,default,default,NULL,1),0)
	,TollForLeg = IsNull(dbo.fnc_TMWRN_GetTollCharge('Leg',lgh_number),0)
	,EstFuelCostForLeg = dbo.fnc_TMWRN_GetEstFuelCost(lgh_number,@FuelRate,@FuelCostInSettlementsParameter,@FuelInSettlementValue)
	--	trip description
	,FirstCom = (select cmp_id_start from #TempLegListingPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstCity = (select lgh_startcity from #TempLegListingPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstState = (select lgh_startstate from #TempLegListingPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstZip3 = (select startzip from #TempLegListingPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstReg1 = (select lgh_startregion1 from #TempLegListingPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstReg2 = (select lgh_startregion2 from #TempLegListingPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstReg3 = (select lgh_startregion3 from #TempLegListingPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstReg4 = (select lgh_startregion4 from #TempLegListingPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstDRPCom = (select cmp_id_end from #TempLegListingFODRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstDRPCity = (select lgh_endcity from #TempLegListingFODRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstDRPState = (select lgh_endstate from #TempLegListingFODRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstDRPZip3 = (select endzip from #TempLegListingFODRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstDRPReg1 = (select lgh_endregion1 from #TempLegListingFODRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstDRPReg2 = (select lgh_endregion2 from #TempLegListingFODRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstDRPReg3 = (select lgh_endregion3 from #TempLegListingFODRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,FirstDRPReg4 = (select lgh_endregion4 from #TempLegListingFODRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,PUP2ndCom = (select cmp_id_start from #TempLegListingSOPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,PUP2ndCity = (select lgh_startcity from #TempLegListingSOPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,PUP2ndState = (select lgh_startstate from #TempLegListingSOPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,PUP2ndZip3 = (select startzip from #TempLegListingSOPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,PUP2ndReg1 = (select lgh_startregion1 from #TempLegListingSOPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,PUP2ndReg2 = (select lgh_startregion2 from #TempLegListingSOPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,PUP2ndReg3 = (select lgh_startregion3 from #TempLegListingSOPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,PUP2ndReg4 = (select lgh_startregion4 from #TempLegListingSOPUP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,LastCom = (select cmp_id_end from #TempLegListingDRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,LastCity = (select lgh_endcity from #TempLegListingDRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,LastState = (select lgh_endstate from #TempLegListingDRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,LastZip3 = (select endzip from #TempLegListingDRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,LastReg1 = (select lgh_endregion1 from #TempLegListingDRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,LastReg2 = (select lgh_endregion2 from #TempLegListingDRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,LastReg3 = (select lgh_endregion3 from #TempLegListingDRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	,LastReg4 = (select lgh_endregion4 from #TempLegListingDRP (NOLOCK) where lgh_number = #rtrips2.lgh)
	into #WorkingLegTable
	from #rtrips2 (NOLOCK) join legheader (NOLOCK) on lgh_number = lgh
	where Trip in (select Trip from #rtrips2 (NOLOCK) where RTLegType in ('S','R'))
	order by Truck,Trip,Seq desc

	-- Do Update where @RT_DefName + Leg already exist; do Insert where they do not
	Update Metric_RTLegCache 
		Set rt_DefName = RTDefName,
		rt_EndLeg = RTEndLeg,
		rt_EndDate = RTEndDate,
		rt_Seq = Seq,
		rt_Move = Move,
		rt_Truck = Truck,
		rt_LegStart = LegStart,
		rt_Leg = Leg,
		rt_LegEnd = LegEnd,
		rt_LegType = RTLegType,
		rt_TimeForLeg = TimeForLeg ,
		rt_LHRevForLeg = LHRevForLeg ,
		rt_ACCRevForLeg = ACCRevForLeg,
		rt_LoadMiles = LoadMiles,
		rt_DHMiles = DHMiles,
		rt_GrossPayForLeg = GrossPayForLeg,
		rt_TollForLeg = TollForLeg,
		rt_EstFuelCostForLeg = EstFuelCostForLeg,
		rt_FirstCom = FirstCom,
		rt_FirstCity = FirstCity,
		rt_FirstState = FirstState,
		rt_FirstZip3 = FirstZip3,
		rt_FirstReg1 = FirstReg1,
		rt_FirstReg2 = FirstReg2,
		rt_FirstReg3 = FirstReg3,
		rt_FirstReg4 = FirstReg4,
		rt_FirstDRPCom = FirstDRPCom,
		rt_FirstDRPCity = FirstDRPCity,
		rt_FirstDRPState = FirstDRPState,
		rt_FirstDRPZip3 = FirstDRPZip3,
		rt_FirstDRPReg1 = FirstDRPReg1,
		rt_FirstDRPReg2 = FirstDRPReg2,
		rt_FirstDRPReg3 = FirstDRPReg3,
		rt_FirstDRPReg4 = FirstDRPReg4,
		rt_PUP2ndCom = PUP2ndCom,
		rt_PUP2ndCity = PUP2ndCity,
		rt_PUP2ndState = PUP2ndState,
		rt_PUP2ndZip3 = PUP2ndZip3,
		rt_PUP2ndReg1 = PUP2ndReg1,
		rt_PUP2ndReg2 = PUP2ndReg2,
		rt_PUP2ndReg3 = PUP2ndReg3,
		rt_PUP2ndReg4 = PUP2ndReg4,
		rt_LastCom = LastCom,
		rt_LastCity = LastCity,
		rt_LastState = LastState,
		rt_LastZip3 = LastZip3,
		rt_LastReg1 = LastReg1,
		rt_LastReg2 = LastReg2,
		rt_LastReg3 = LastReg3,
		rt_LastReg4 = LastReg4
	from #WorkingLegTable left join Metric_RTLegCache on #WorkingLegTable.RTDefName + Cast(#WorkingLegTable.Leg as varchar) = Metric_RTLegCache.rt_DefName + cast(Metric_RTLegCache.rt_Leg as varchar)
	Where NOT (Metric_RTLegCache.rt_DefName + cast(Metric_RTLegCache.rt_Leg as varchar)) is NULL

	Insert into Metric_RTLegCache
		Select #WorkingLegTable.*
		from #WorkingLegTable left join Metric_RTLegCache on #WorkingLegTable.RTDefName + Cast(#WorkingLegTable.Leg as varchar) = Metric_RTLegCache.rt_DefName + cast(Metric_RTLegCache.rt_Leg as varchar)
		Where (Metric_RTLegCache.rt_DefName + cast(Metric_RTLegCache.rt_Leg as varchar)) is NULL

	drop table #t
	drop table #RTripLegs
	drop table #RTripMoves
	drop table #rtrips2
	drop table #RTDataLegs
	drop table #RTDataMoves
	drop table #TempLegListingPUP
	drop table #TempLegListingFODRP
	drop table #TempLegListingSOPUP
	drop table #TempLegListingDRP

	drop table #WorkingLegTable

GO
GRANT EXECUTE ON  [dbo].[ResNow_RoundTripCacheBuildXD] TO [public]
GO
