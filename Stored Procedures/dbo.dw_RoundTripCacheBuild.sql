SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Part 3

CREATE PROCEDURE [dbo].[dw_RoundTripCacheBuild]
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
	SET NOCOUNT OFF

	declare @HomeDefinitionMode varchar(10)   -- 'COMP','CITY','ZIP3','REG1','REG2','REG3','REG4'
	declare @HomeValue varchar(255)
	declare @BeginStopEvents varchar(255)	-- BMT,BBT,HLT  Events that are NOT of type PUP but would still be considered as a start
	declare @ReturnDefinitionMode varchar(10)-- 'COMP','CITY','ZIP3','REG1','REG2','REG3','REG4'
	declare @ReturnValue varchar(255)
	declare @EndStopEvents varchar(255)	-- EMT,EBT,DLT,DMT	Events that are NOT of type DRP but would still be considered as an end
	declare @MaxTimeFrameInDays int -- a 'timeout' value to stop processing if no RT
	declare @TrcType1List varchar(255)
	declare @TrcType2List varchar(255)
	declare @TrcType3List varchar(255)
	declare @TrcType4List varchar(255)
	declare @TrcCompanyList varchar(255)
	declare @TrcDivisionList varchar(255)
	declare @TrcTerminalList varchar(255)
	declare @TrcFleetList varchar(255)
	declare @ExcludeTrcList varchar(255)

	SET @HomeDefinitionMode = (Select rt_HomeDefinitionMode from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName)

	SET @HomeValue = (Select rt_HomeValueList from dw_RTDefinitions where rt_DefName = @RT_DefName)

	SET @BeginStopEvents = 
		Case When IsNull((Select rt_BeginStopEventsList from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName),'') = '' then
			'HLT'
		Else
			(Select rt_BeginStopEventsList from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName)
		End

	SET @ReturnDefinitionMode = (Select rt_ReturnDefinitionMode from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName)

	SET @ReturnValue = (Select rt_ReturnValueList from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName)

	SET @EndStopEvents = 
		Case When IsNull((Select rt_EndStopEventsList from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName),'') = '' then
			'DLT'
		Else
			(Select rt_EndStopEventsList from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName)
		End

	SET @MaxTimeFrameInDays = 
		Case When IsNull((Select rt_MaxTimeFrameInDays from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName),0) = 0 then
			30
		Else
			(Select rt_MaxTimeFrameInDays from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName)
		End

	SET @TrcType1List = IsNull((Select rt_TrcType1List from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName),'')
	SET @TrcType2List = IsNull((Select rt_TrcType2List from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName),'')
	SET @TrcType3List = IsNull((Select rt_TrcType3List from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName),'')
	SET @TrcType4List = IsNull((Select rt_TrcType4List from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName),'')
	SET @TrcCompanyList = IsNull((Select rt_TrcCompanyList from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName),'')
	SET @TrcDivisionList = IsNull((Select rt_TrcDivisionList from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName),'')
	SET @TrcTerminalList = IsNull((Select rt_TrcTerminalList from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName),'')
	SET @TrcFleetList = IsNull((Select rt_TrcFleetList from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName),'')
	SET @ExcludeTrcList = IsNull((Select rt_ExcludeTrcList from dw_RTDefinitions with (NOLOCK) where rt_DefName = @RT_DefName),'')

	SET @TrcType1List = ',' + ISNULL(@TrcType1List,'') + ','
	SET @TrcType2List = ',' + ISNULL(@TrcType2List,'') + ','
	SET @TrcType3List = ',' + ISNULL(@TrcType3List,'') + ','
	SET @TrcType4List = ',' + ISNULL(@TrcType4List,'') + ','
	SET @TrcCompanyList = ',' + ISNULL(@TrcCompanyList,'') + ','
	SET @TrcDivisionList = ',' + ISNULL(@TrcDivisionList,'') + ','
	SET @TrcTerminalList = ',' + ISNULL(@TrcTerminalList,'') + ','
	SET @TrcFleetList = ',' + ISNULL(@TrcFleetList,'') + ','
	SET @ExcludeTrcList = ',' + ISNULL(@ExcludeTrcList,'') + ','

	-- local variables
	declare @ThisTractor varchar(10)
	declare @RTStartDate datetime
	declare @StartLegNumber int
	declare @ThisLegNumber int
	declare @EndFlag char(1)
	declare @RoundTripNumber int -- ID number for Round Trips
	declare @RTSeq int -- sequence number for sorting Round Trip legs into proper sequence
	declare @SelfContainedRoundTrip char(1)
	declare @RTUpdatedDate datetime

	--Standard List Parameter Initialization
	SET @HomeValue = ',' + ISNULL(@HomeValue,'') + ','
	SET @BeginStopEvents = ',' + ISNULL(@BeginStopEvents,'') + ','
	SET @ReturnValue = ',' + ISNULL(@ReturnValue,'') + ','
	SET @EndStopEvents = ',' + ISNULL(@EndStopEvents,'') + ','

	-- initialize local variables
	set @RTUpdatedDate = GetDate()

	-- Custom Metric SQL here
	-- Create Tables to store intermediate data

	create table #RoundTripInfo
		(
			RTStartLeg int,
			RTStartDate datetime,
			RTNumber int,
			RTSequence int,
			Tractor varchar(10),
			Leg int,
			RTLegType char(1)
		)

	create table #TempLegListingSTART
		(
			mov_number int
			,lgh_number int
			,lgh_startdate datetime
			,lgh_enddate datetime
			,stp_arrivaldate datetime
			,lgh_tractor varchar (10)
			,NextLeg int
			,stp_mfh_sequence int

		)

	create table #TempLegListingEND
		(
			mov_number int
			,lgh_number int
			,lgh_startdate datetime
			,lgh_enddate datetime
			,stp_arrivaldate datetime
			,lgh_tractor varchar (10)
			,NextLeg int
			,stp_mfh_sequence int
			,QualifiesAsSelfContainedYN char(1)
		)

	create table #TempLegListingALL
		(
			mov_number int
			,lgh_number int
			,lgh_startdate datetime
			,lgh_enddate datetime
			,lgh_tractor varchar (10)
			,NextLeg int
		)

	--  set return variable
--		SET @Modal_StartLocation = @HomeValue

--print 'Variables initialized at:  ' + Convert(varchar,GetDate(),121)

-- INSERT INTO TMWRoundtripLog (dateandtime, comment) SELECT GETDATE(), 'END: parameter & variable initialization'

	--	using the following leg pools because need to use FIRST pickup event and
	--	LAST drop event on each leg.  only way to be sure is at stop level but rest
	--	of analysis is done at leg level.  use stops to create pool of legs then
	--	proceed to leg analysis.

-- INSERT INTO TMWRoundtripLog (dateandtime, comment) SELECT GETDATE(), 'START: tractor identification'

	-- identify tractors involved
	Select distinct lgh_tractor
	Into #TempTractorList
	From legheader with (NOLOCK)
--	where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
	where lgh_enddate between @DateStart and @DateEnd 
	AND lgh_tractor <> 'UNKNOWN'
	AND (@TrcType1List =',,' or CHARINDEX(',' + RTRIM(trc_type1) + ',', @TrcType1List) > 0)
	AND (@TrcType2List =',,' or CHARINDEX(',' + RTRIM(trc_type2) + ',', @TrcType2List) > 0)
	AND (@TrcType3List =',,' or CHARINDEX(',' + RTRIM(trc_type3) + ',', @TrcType3List) > 0)
	AND (@TrcType4List =',,' or CHARINDEX(',' + RTRIM(trc_type4) + ',', @TrcType4List) > 0)
	AND (@TrcCompanyList =',,' or CHARINDEX(',' + RTRIM(trc_company) + ',', @TrcCompanyList) > 0)
	AND (@TrcDivisionList =',,' or CHARINDEX(',' + RTRIM(trc_division) + ',', @TrcDivisionList) > 0)
	AND (@TrcTerminalList =',,' or CHARINDEX(',' + RTRIM(trc_terminal) + ',', @TrcTerminalList) > 0)
	AND (@TrcFleetList =',,' or CHARINDEX(',' + RTRIM(trc_fleet) + ',', @TrcFleetList) > 0)
	AND (@ExcludeTrcList =',,' or CHARINDEX(',' + RTRIM(lgh_tractor) + ',', @ExcludeTrcList) = 0)


-- select '203' as lgh_tractor into #TempTractorList

--print 'Tractors selected at:  ' + Convert(varchar,GetDate(),121)

-- INSERT INTO TMWRoundtripLog (dateandtime, comment) SELECT GETDATE(), 'END: tractor identification'

-- INSERT INTO TMWRoundtripLog (dateandtime, comment) SELECT GETDATE(), 'START: select pool of first outbound pickup legs'

	Insert into #TempLegListingALL (mov_number,lgh_number,lgh_startdate,lgh_enddate,lgh_tractor,NextLeg)
		Select distinct legheader.mov_number
		,legheader.lgh_number
		,legheader.lgh_startdate
		,lgh_enddate
		,lgh_tractor
		,NextLeg
		from legheader with (NOLOCK) join vw_TMWRN_PrevNextLegs with (NOLOCK) on legheader.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--		where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
		where lgh_enddate between @DateStart and @DateEnd 
		AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
		AND lgh_outstatus = 'CMP'

--print 'All Legs list complete at:  ' + Convert(varchar,GetDate(),121)

	--	select pool of first outbound pickup legs
	If @HomeDefinitionMode = 'COMP'
		Begin
			Insert into #TempLegListingSTART
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + S1.cmp_id  + ',', @HomeValue) > 0 
						AND (
								S1.stp_type = 'PUP'
									OR
								(@BeginStopEvents =',,' or CHARINDEX(',' + S1.stp_event  + ',', @BeginStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End
	Else If @HomeDefinitionMode = 'CITY'
		Begin
			Insert into #TempLegListingSTART
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + Cast(S1.stp_city as varchar) + ',', @HomeValue) > 0 
						AND (
								S1.stp_type = 'PUP'
									OR
								(@BeginStopEvents =',,' or CHARINDEX(',' + S1.stp_event  + ',', @BeginStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End
	Else If @HomeDefinitionMode = 'ZIP3'
		Begin
			Insert into #TempLegListingSTART
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + dbo.fnc_TMWRN_GetZip3(S1.stp_city) + ',', @HomeValue) > 0
						AND (
								S1.stp_type = 'PUP'
									OR
								(@BeginStopEvents =',,' or CHARINDEX(',' + S1.stp_event  + ',', @BeginStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End
	Else If @HomeDefinitionMode = 'REG1'
		Begin
			Insert into #TempLegListingSTART
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + (select cty_region1 from city with (NOLOCK) where cty_code = S1.stp_city) + ',', @HomeValue) > 0
						AND (
								S1.stp_type = 'PUP'
									OR
								(@BeginStopEvents =',,' or CHARINDEX(',' + S1.stp_event  + ',', @BeginStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End
	Else If @HomeDefinitionMode = 'REG2'
		Begin
			Insert into #TempLegListingSTART
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + (select cty_region2 from city with (NOLOCK) where cty_code = S1.stp_city) + ',', @HomeValue) > 0
						AND (
								S1.stp_type = 'PUP'
									OR
								(@BeginStopEvents =',,' or CHARINDEX(',' + S1.stp_event  + ',', @BeginStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End
	Else If @HomeDefinitionMode = 'REG3'
		Begin
			Insert into #TempLegListingSTART
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + (select cty_region3 from city with (NOLOCK) where cty_code = S1.stp_city) + ',', @HomeValue) > 0
						AND (
								S1.stp_type = 'PUP'
									OR
								(@BeginStopEvents =',,' or CHARINDEX(',' + S1.stp_event  + ',', @BeginStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End
	Else If @HomeDefinitionMode = 'REG4'
		Begin
			Insert into #TempLegListingSTART
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + (select cty_region4 from city with (NOLOCK) where cty_code = S1.stp_city) + ',', @HomeValue) > 0
						AND (
								S1.stp_type = 'PUP'
									OR
								(@BeginStopEvents =',,' or CHARINDEX(',' + S1.stp_event  + ',', @BeginStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End


--print 'Start Legs list complete at:  ' + Convert(varchar,GetDate(),121)

	--	select pool of possible RT completion legs
	If @ReturnDefinitionMode = 'COMP'
		Begin
			Insert into #TempLegListingEND
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				,QualifiesAsSelfContainedYN = 'N'
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + S1.cmp_id + ',', @ReturnValue) >0
						AND (
								stp_type = 'DRP'
									OR
								(@EndStopEvents =',,' or CHARINDEX(',' + stp_event  + ',', @EndStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End
	If @ReturnDefinitionMode = 'CITY'
		Begin
			Insert into #TempLegListingEND
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				,QualifiesAsSelfContainedYN = 'N'
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + cast(S1.stp_city as varchar) + ',', @ReturnValue) >0
						AND (
								stp_type = 'DRP'
									OR
								(@EndStopEvents =',,' or CHARINDEX(',' + stp_event  + ',', @EndStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End
	If @ReturnDefinitionMode = 'ZIP3'
		Begin
			Insert into #TempLegListingEND
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				,QualifiesAsSelfContainedYN = 'N'
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + dbo.fnc_TMWRN_GetZip3(S1.stp_city) + ',', @ReturnValue) >0
						AND (
								stp_type = 'DRP'
									OR
								(@EndStopEvents =',,' or CHARINDEX(',' + stp_event  + ',', @EndStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End
	If @ReturnDefinitionMode = 'REG1'
		Begin
			Insert into #TempLegListingEND
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				,QualifiesAsSelfContainedYN = 'N'
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + (select cty_region1 from city with (NOLOCK) where cty_code = S1.stp_city) + ',', @ReturnValue) >0
						AND (
								stp_type = 'DRP'
									OR
								(@EndStopEvents =',,' or CHARINDEX(',' + stp_event  + ',', @EndStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End
	If @ReturnDefinitionMode = 'REG2'
		Begin
			Insert into #TempLegListingEND
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				,QualifiesAsSelfContainedYN = 'N'
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + (select cty_region2 from city with (NOLOCK) where cty_code = S1.stp_city) + ',', @ReturnValue) >0
						AND (
								stp_type = 'DRP'
									OR
								(@EndStopEvents =',,' or CHARINDEX(',' + stp_event  + ',', @EndStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End
	If @ReturnDefinitionMode = 'REG3'
		Begin
			Insert into #TempLegListingEND
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				,QualifiesAsSelfContainedYN = 'N'
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + (select cty_region3 from city with (NOLOCK) where cty_code = S1.stp_city) + ',', @ReturnValue) >0
						AND (
								stp_type = 'DRP'
									OR
								(@EndStopEvents =',,' or CHARINDEX(',' + stp_event  + ',', @EndStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End
	If @ReturnDefinitionMode = 'REG4'
		Begin
			Insert into #TempLegListingEND
				Select distinct stops.mov_number
				,stops.lgh_number
				,legheader.lgh_startdate
				,lgh_enddate
				,stp_arrivaldate
				,lgh_tractor
				,NextLeg
				,stp_mfh_sequence
				,QualifiesAsSelfContainedYN = 'N'
				from stops with (NOLOCK) join legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number
						join vw_TMWRN_PrevNextLegs with (NOLOCK) on stops.lgh_number = vw_TMWRN_PrevNextLegs.lgh_number
--				where lgh_enddate between DateAdd(d,-@MaxTimeFrameInDays,@DateStart) and @DateEnd 
				where lgh_enddate between @DateStart and @DateEnd 
				AND lgh_tractor in (Select lgh_tractor from #TempTractorList)
				AND lgh_outstatus = 'CMP'
				AND stp_number = 
					(
						select top 1 stp_number
						from stops S1 with (NOLOCK)
						where S1.lgh_number = stops.lgh_number
						AND CHARINDEX(',' + (select cty_region4 from city with (NOLOCK) where cty_code = S1.stp_city) + ',', @ReturnValue) >0
						AND (
								stp_type = 'DRP'
									OR
								(@EndStopEvents =',,' or CHARINDEX(',' + stp_event  + ',', @EndStopEvents) > 0)
							)
						order by stp_arrivaldate desc
					)
		End

		Update #TempLegListingEND set QualifiesAsSelfContainedYN = 'Y'
			from #TempLegListingSTART
			where #TempLegListingEND.lgh_number = #TempLegListingSTART.lgh_number
			AND #TempLegListingEND.stp_mfh_sequence > #TempLegListingSTART.stp_mfh_sequence
			AND NOT Exists 
				(	
					Select stp_number
					from stops S2 with (NOLOCK)
					Where #TempLegListingSTART.lgh_number = S2.lgh_number
					AND S2.stp_mfh_sequence > #TempLegListingEND.stp_mfh_sequence
					AND (S2.stp_type in ('PUP','DRP') OR S2.stp_event in ('HLT','DLT'))
				)


--print 'End Legs list complete at:  ' + Convert(varchar,GetDate(),121)

-- begin processing ************************************************************************************************
-- *****************************************************************************************************************
	set @ThisTractor = 
		(
			Select top 1 lgh_tractor 
			from #TempTractorList 
			order by lgh_tractor
		)

	set @RTStartDate = '19500101 00:00:00.000'

	set @RoundTripNumber = 0

	while NOT @ThisTractor is NULL
		begin

			set @RoundTripNumber = @RoundTripNumber + 1
			set @RTSeq = 1

			-- select a round trip start leg
			set	@StartLegNumber = 
				(
					Select top 1 lgh_number
					from #TempLegListingSTART 
					where lgh_tractor = @ThisTractor
					AND stp_arrivaldate > @RTStartDate
					AND NOT Exists	(
										Select *
										From dw_RTLegCache
										Where dw_RTLegCache.rt_DefName <> @RT_DefName
										AND #TempLegListingSTART.lgh_number = dw_RTLegCache.rt_Leg
									)
					order by stp_arrivaldate
				)

			-- Following WHILE Loop is for every leg by THIS Tractor
			While NOT @StartLegNumber is NULL
				begin

					set @RTStartDate = 
						(
							select stp_arrivaldate 
							from #TempLegListingSTART 
							where lgh_number = @StartLegNumber
						)

					-- does this round trip END at some point within our @MaxTimeFrameInDays range?
					-- do normal evaluation first, ....
					Set @EndFlag = 
						IsNull(	(	Select top 1 'Y'
									From #TempLegListingEND
									Where #TempLegListingEND.lgh_tractor = @ThisTractor
									AND #TempLegListingEND.stp_arrivaldate > @RTStartDate
									AND #TempLegListingEND.stp_arrivaldate <= DateAdd(d,@MaxTimeFrameInDays,@RTStartDate)
								),IsNull(	(	Select top 1 'Y'
												From #TempLegListingSTART
												Where #TempLegListingSTART.lgh_tractor = @ThisTractor
												AND #TempLegListingSTART.stp_arrivaldate > @RTStartDate
												AND #TempLegListingSTART.stp_arrivaldate <= DateAdd(d,@MaxTimeFrameInDays,@RTStartDate)
											),'N'))

					-- .... then check timing for In Process round trips if normal has failed
					If (@EndFlag = 'N') AND (DateDiff(d,@RTStartDate,GetDate()) <= @MaxTimeFrameInDays)
						begin
							Set @EndFlag = 'Y'  -- actually, might NOT end but we want RT's in progress so we assume it does
						end

--					Set @EndFlag = 'Y'  -- actually, might NOT end but we want RT's in progress so we assume it does

					If @EndFlag = 'Y'
						Begin
--print 'rt start leg: ' + cast(@StartLegNumber as varchar)
							-- Is it a self-contained (single leg) round trip?
							set @SelfContainedRoundTrip =
								IsNull(	(	select QualifiesAsSelfContainedYN
											from #TempLegListingEND
											Where #TempLegListingEND.lgh_tractor = @ThisTractor
											AND #TempLegListingEND.lgh_number = @StartLegNumber
										),'N')

							-- now check to make sure NEXT leg is not start of new RT
							If @SelfContainedRoundTrip = 'N'
								begin
									If Exists	(	select lgh_number
													from #TempLegListingSTART
													where lgh_number = 
														(	select NextLeg
															from #TempLegListingSTART TLLS2
															where TLLS2.lgh_number = @StartLegNumber)
												)
										begin
											set @SelfContainedRoundTrip = 'Y'
										end
								end

							If @SelfContainedRoundTrip = 'N'
								begin
									Insert into #RoundTripInfo (	RTStartLeg,RTStartDate,RTNumber,RTSequence
																	,Tractor,Leg,RTLegType)
										select @StartLegNumber
											,@RTStartDate
											,@RoundTripNumber
											,@RTSeq
											,lgh_tractor
											,lgh_number
											,'S'
										from #TempLegListingSTART
										where #TempLegListingSTART.lgh_number = @StartLegNumber

									set @ThisLegNumber =
										(
											Select NextLeg
											From #TempLegListingALL
											Where #TempLegListingALL.lgh_number = @StartLegNumber
										) 

									While NOT @ThisLegNumber is NULL
										begin
											set @RTSeq = @RTSeq + 1
											
--print 'before the check: ' + cast(@ThisLegNumber as varchar)
											-- data quality issues require this step
											If Exists (	Select Leg 
														from #RoundTripInfo
														where #RoundTripInfo.Leg = @ThisLegNumber)
												begin
--print @ThisLegNumber
													set @ThisLegNumber = NULL
												end
											-- ends with this leg?
											Else If Exists (	Select lgh_number
																from #TempLegListingEND
																where #TempLegListingEND.lgh_number = @ThisLegNumber)
												begin
													Insert into #RoundTripInfo (	RTStartLeg,RTStartDate,RTNumber,RTSequence
																					,Tractor,Leg,RTLegType)
														select @StartLegNumber
															,@RTStartDate
															,@RoundTripNumber
															,@RTSeq
															,lgh_tractor
															,lgh_number
															,'E'
														from #TempLegListingALL
														where #TempLegListingALL.lgh_number = @ThisLegNumber

													set @ThisLegNumber = NULL
												end
											-- new RT STARTS with next leg?
											Else If Exists (	Select lgh_number
																from #TempLegListingSTART
																where #TempLegListingSTART.lgh_number = 
																	(	Select TLLA2.NextLeg
																		from #TempLegListingALL TLLA2
																		where TLLA2.lgh_number = @ThisLegNumber))
												begin
													Insert into #RoundTripInfo (	RTStartLeg,RTStartDate,RTNumber,RTSequence
																					,Tractor,Leg,RTLegType)
														select @StartLegNumber
															,@RTStartDate
															,@RoundTripNumber
															,@RTSeq
															,lgh_tractor
															,lgh_number
															,'E'
														from #TempLegListingALL
														where #TempLegListingALL.lgh_number = @ThisLegNumber

													set @ThisLegNumber = NULL
												end
											Else
											-- this is a middle leg
												begin
													Insert into #RoundTripInfo (	RTStartLeg,RTStartDate,RTNumber,RTSequence
																					,Tractor,Leg,RTLegType)
														select @StartLegNumber
															,@RTStartDate
															,@RoundTripNumber
															,@RTSeq
															,lgh_tractor
															,lgh_number
															,'M'
														from #TempLegListingALL
														where #TempLegListingALL.lgh_number = @ThisLegNumber

													set @ThisLegNumber =
														(
															Select NextLeg
															From #TempLegListingALL
															Where #TempLegListingALL.lgh_number = @ThisLegNumber
														) 
												end
										end -- of NOT @ThisLegNumber is NULL loop
								end  -- of @SelfContainedRoundTrip = 'N' clause
							Else	--	If @SelfContainedRoundTrip = 'Y'
								begin
									Insert into #RoundTripInfo (	RTStartLeg,RTStartDate,RTNumber,RTSequence
																	,Tractor,Leg,RTLegType)
										select @StartLegNumber
											,lgh_startdate
											,@RoundTripNumber
											,@RTSeq
											,lgh_tractor
											,lgh_number
											,'R'
										from #TempLegListingSTART
										where #TempLegListingSTART.lgh_number = @StartLegNumber
								end
						End -- of @EndFlag = 'Y' clause


					set	@StartLegNumber = 
						(
							Select top 1 lgh_number
							from #TempLegListingSTART 
							where lgh_tractor = @ThisTractor
							AND stp_arrivaldate > @RTStartDate
							AND NOT Exists	(
												Select *
												From dw_RTLegCache
												Where dw_RTLegCache.rt_DefName <> @RT_DefName
												AND #TempLegListingSTART.lgh_number = dw_RTLegCache.rt_Leg
											)
							order by stp_arrivaldate
						)

					set @RoundTripNumber = @RoundTripNumber + 1
					set @RTSeq = 1

				End  -- of NOT @StartLegNumber is NULL loop
			-- of WHILE Loop is for every leg by THIS Tractor

			set @ThisTractor = 
				(
					Select top 1 lgh_tractor 
					from #TempTractorList 
					where lgh_tractor > @ThisTractor
					order by lgh_tractor
				)

			set @RTStartDate = '19500101 00:00:00.000'

		End -- of NOT @ThisTractor is NULL loop

	-- create Leg Detail 
	select @RT_DefName as RTDefName
		,RTStartLeg
		,RTStartDate
		,RTSequence
		,Move = mov_number
		,Tractor
		,LegStart = lgh_startdate
		,Leg
		,LegEnd = lgh_enddate
		,RTLegType
	into #WorkingLegTable
	from #RoundTripInfo with (NOLOCK) join legheader with (NOLOCK) on lgh_number = Leg
--	where RTNumber in (select RTI.RTNumber from #RoundTripInfo RTI with (NOLOCK) where RTI.RTLegType in ('E','R'))
	order by Tractor,RTNumber,RTSequence desc


-- delete existing round trips if we have rebuilt them here
	select distinct rt_StartLeg
	into #TempRTtoDelete
	from dw_RTLegCache
	where rt_DefName = @RT_DefName
	AND rt_leg in
		(
			select Leg
			from #WorkingLegTable
		)

	Delete from dw_RTLegCache 
	where rt_DefName = @RT_DefName 
	AND rt_StartLeg in 
		(
			select rt_StartLeg 
			from #TempRTtoDelete
		)

	-- insert new rows
--print 'inserting new rows: ' + convert(varchar(25),@RTUpdatedDate,121)
	Insert into dw_RTLegCache (	rt_DefName,rt_StartLeg,rt_StartDate,rt_EndDate,rt_Seq,rt_Move,rt_Truck
								,rt_LegStart,rt_Leg,rt_LegEnd,rt_LegType,rt_Status,rt_DateUpdated )

		Select #WorkingLegTable.RTDefName
			,#WorkingLegTable.RTStartLeg
			,#WorkingLegTable.RTStartDate
			,Convert(DateTime,'20501231 00:00:00.000')
			,#WorkingLegTable.RTSequence
			,#WorkingLegTable.Move
			,#WorkingLegTable.Tractor
			,#WorkingLegTable.LegStart
			,#WorkingLegTable.Leg
			,#WorkingLegTable.LegEnd
			,#WorkingLegTable.RTLegType
			,'Complete'
			,@RTUpdatedDate
		from #WorkingLegTable 

	-- finalize RT ending dates
	select rt_StartLeg,max(rt_LegEnd) as MaxEnd
	into #TempRTEnds
	from dw_RTLegCache with (NOLOCK)
	group by rt_StartLeg

--  step for testing
--	select * 
--	from #TempRTEnds,dw_RTLegCache
--	where dw_RTLegCache.rt_StartLeg = #TempRTEnds.rt_StartLeg
--	AND dw_RTLegCache.rt_EndDate <> #TempRTEnds.MaxEnd

	Update dw_RTLegCache set rt_EndDate = MaxEnd
	from #TempRTEnds
	where dw_RTLegCache.rt_StartLeg = #TempRTEnds.rt_StartLeg
	AND dw_RTLegCache.rt_EndDate <> #TempRTEnds.MaxEnd


	-- finalize RT status
	select rt_StartLeg
	into #RTStarts
	from dw_RTLegCache
	where rt_LegType = 'S'

	select rt_StartLeg
	into #RTEnds
	from dw_RTLegCache
	where rt_LegType = 'E'

	Update dw_RTLegCache Set rt_Status = 'InProcess'
	where rt_DefName = @RT_DefName 
	AND rt_StartLeg in (Select rt_StartLeg from #RTStarts)
	AND NOT rt_StartLeg in (Select rt_StartLeg from #RTEnds)

	-- final delete of InProcess round trips that have timed out
	declare @Today datetime
	set @Today = Convert(datetime,Floor(Convert(float,GetDate())))

	Delete from dw_RTLegCache
	where rt_DefName = @RT_DefName 
	AND rt_status = 'InProcess'
	AND DateDiff(d,rt_StartDate,@Today) > @MaxTimeFrameInDays


--select * from #WorkingLegTable

drop table #TempTractorList
drop table #TempLegListingSTART
drop table #TempLegListingEND
drop table #TempLegListingALL
drop table #WorkingLegTable
drop table #RoundTripInfo
drop table #TempRTtoDelete
drop table #RTStarts
drop table #RTEnds

-- truncate table dw_RTLegCache
-- select * from dw_RTLegCache

-- Part 4
GO
GRANT EXECUTE ON  [dbo].[dw_RoundTripCacheBuild] TO [public]
GO
