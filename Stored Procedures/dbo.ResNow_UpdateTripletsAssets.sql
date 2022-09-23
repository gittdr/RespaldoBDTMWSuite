SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[ResNow_UpdateTripletsAssets] 
AS

Set NOCOUNT On

declare @ThisCycleTime datetime
declare @LastCycleTime datetime
declare @OldTimeStamp timestamp
declare @NewTimeStamp timestamp

set @ThisCycleTime = GetDate()
set @LastCycleTime = (select MAX(DateLastRefresh) from ResNow_TripletsLastRefresh (NOLOCK))
set @OldTimeStamp = (select MAX(rn_timestamp) from ResNow_TripletsLastRefresh (NOLOCK))

--set @TheTimeStamp = 0x000000000A0F9F17

-- update NOW so that next cycle has appropriate timestamp value to use
--Update ResNow_TripletsLastRefresh set DateLastRefresh = @ThisCycleTime
Insert into ResNow_TripletsLastRefresh (DateLastRefresh) Values(@ThisCycleTime)

set @NewTimeStamp = (select MAX(rn_timestamp) from ResNow_TripletsLastRefresh (NOLOCK))

-- update the Order Status Change table
exec ResNow_UpdateOrderStatus @PriorCycleTime = @LastCycleTime

--set @LastCycleTime = DateAdd(hh,-4,@LastCycleTime)

-- first of all, remove ALL legs that have been cancelled and no longer exist in the legheader table
select lgh_number
into #TempDeleteLegs
from ResNow_Triplets (NOLOCK)
Where NOT Exists (select lgh_number from legheader (NOLOCK) where legheader.lgh_number = ResNow_Triplets.lgh_number)

Delete from ResNow_Triplets where lgh_number in (select lgh_number from #TempDeleteLegs)

-- second of all, remove ALL orders that no longer qualify but consolidated so leg still exists in the legheader table
--select ord_hdrnumber
--into #TempDeleteOrders
--from ResNow_Triplets
--Where ord_hdrnumber > 0
--AND NOT Exists (select ord_hdrnumber from orderheader (NOLOCK) where orderheader.ord_hdrnumber = ResNow_Triplets.ord_hdrnumber ANd orderheader.ord_status in ('AVL','PLN','DSP','STD','CMP'))

--Delete from ResNow_Triplets where ord_hdrnumber in (select ord_hdrnumber from #TempDeleteOrders)

-- selects all moves impacted by activity since last data warehouse update
create table #TempMoves
	(
		mov_number int
	)

Insert into #TempMoves (mov_number)
	select legheader.mov_number
	from legheader (NOLOCK) 
	Where legheader.timestamp between @OldTimeStamp AND @NewTimeStamp

	UNION

	select stops.mov_number
	from stops (NOLOCK) 
	Where stops.timestamp between @OldTimeStamp AND @NewTimeStamp

	UNION

	select orderheader.mov_number
	from orderheader (NOLOCK)
	Where orderheader.timestamp between @OldTimeStamp AND @NewTimeStamp

	UNION
	
	select distinct IH.mov_number 
	from invoiceheader IH (NOLOCK) join invoicedetail ID (NOLOCK) on IH.ivh_hdrnumber = ID.ivh_hdrnumber
	where IH.timestamp between @OldTimeStamp AND @NewTimeStamp
	OR ID.dw_timestamp between @OldTimeStamp AND @NewTimeStamp

-- build out the web of order/move combinations to get all affected
	declare @NewMoves int
	set @NewMoves = 1

	While NOT @NewMoves = 0
	begin

		select distinct S2.ord_hdrnumber
		into #TheOrders
		from stops S2 (NOLOCK) 
		where S2.mov_number in 
			(
				Select mov_number from #TempMoves
			)
		AND S2.ord_hdrnumber <> 0

		select distinct S2.mov_number
		into #TheMoves
		from stops S2 (NOLOCK) 
		where S2.ord_hdrnumber in 
			(
				Select ord_hdrnumber from #TheOrders
			)

		Set @NewMoves = 
			(
				Select count(mov_number)
				From #TheMoves
				Where NOT Exists (select mov_number from #TempMoves TM where TM.mov_number = #TheMoves.mov_number)
			)

		Insert into #TempMoves (mov_number)
		Select mov_number
		From #TheMoves
		Where NOT Exists (select mov_number from #TempMoves TM where TM.mov_number = #TheMoves.mov_number)

		drop table #TheOrders
		drop table #TheMoves
	End

	-- final orphan handling
	select RT.ord_hdrnumber,RT.mov_number,RT.lgh_number
	into #TempDeleteTriplets
	from ResNow_Triplets RT (NOLOCK)
	where Exists (select * from #TempMoves where RT.mov_number = #TempMoves.mov_number)
	AND NOT Exists
		  (
				select S1.mov_number,L1.lgh_number,IsNull(O1.ord_hdrnumber,-1*S1.mov_number) as ord_hdrnumber
				from stops S1 (NOLOCK) join stops S2 (NOLOCK) on S1.mov_number = S2.mov_number
				join legheader L1 (NOLOCK) on S1.lgh_number = L1.lgh_number
				-- join this on the S2 link because we need to break the S1.stp_number / S1.lgh_number dependence
				left join orderheader O1 (NOLOCK) on S2.ord_hdrnumber = O1.ord_hdrnumber
				where IsNull(O1.ord_hdrnumber,-1*S1.mov_number) = RT.ord_hdrnumber
				AND S1.mov_number = RT.mov_number
				AND L1.lgh_number = RT.lgh_number
				AND IsNull(O1.ord_status,L1.lgh_outstatus) in ('AVL','PLN','DSP','STD','CMP')
		  )

	-- log the orphan entries
	--Insert into ResNow_Triplets_Orphans (ord_hdrnumber,mov_number,lgh_number,DateOrphaned)
	--select ord_hdrnumber,mov_number,lgh_number,GETDATE()
	--from #TempDeleteTriplets

	Delete from ResNow_Triplets 
	where Exists 
		(
			select *
			from #TempDeleteTriplets T1
			where T1.ord_hdrnumber = ResNow_Triplets.ord_hdrnumber
			AND T1.mov_number = ResNow_Triplets.mov_number
			AND T1.lgh_number = ResNow_Triplets.lgh_number
		)


	-- 1. get ALL move/order pairs
	select distinct stops.mov_number
	,stops.ord_hdrnumber
	,Convert(float,orderheader.ord_totalmiles) as ord_totalmiles
	,orderheader.ord_startdate
	,orderheader.ord_completiondate
	,orderheader.ord_bookdate
	into #TempAllMovesOrders
	from orderheader (NOLOCK) join stops (NOLOCK) on orderheader.ord_hdrnumber = stops.ord_hdrnumber
	where Exists (select * from #TempMoves where stops.mov_number = #TempMoves.mov_number)
	AND orderheader.ord_status in ('AVL','PLN','DSP','STD','CMP')

	-- 2. get ALL move/leg pairs 
	select legheader.mov_number
		,legheader.lgh_number
		,legheader.lgh_tractor
		,legheader.lgh_driver1
		,legheader.lgh_driver2
		,lgh_trailer1 = lgh_primary_trailer -- Convert(varchar(15),'')
		,lgh_trailer2 = lgh_primary_pup -- Convert(varchar(15),'')
		,legheader.lgh_startdate
		,legheader.lgh_enddate
		,legheader.lgh_createdon
		,Convert(float,sum(IsNull(stops.stp_lgh_mileage,0))) as LegTravelMiles
		,Convert(float,0.0) as LegLoadedMiles
		,Convert(float,0.0) as LegEmptyMiles
		,Convert(datetime,'19500101') as MoveStartDate
		,Convert(datetime,'19500101') as MoveEndDate
		,Convert(datetime,'19500101') as MoveCreateDate
	into #TempAllMovesLegs
	from legheader (NOLOCK) join stops (NOLOCK) on legheader.lgh_number = stops.lgh_number
	where legheader.mov_number in (select mov_number from #TempMoves)
	AND (legheader.ord_hdrnumber = 0 OR legheader.mov_number in (select mov_number from #TempAllMovesOrders))
	group by legheader.mov_number,legheader.lgh_number,legheader.lgh_tractor,legheader.lgh_driver1
		,legheader.lgh_driver2,lgh_primary_trailer,lgh_primary_pup,legheader.lgh_startdate
		,legheader.lgh_enddate,legheader.lgh_createdon

	--3. update #TempAllMovesLegs with remaining values
	-- Loaded Miles & Empty Miles
	Select #TempAllMovesLegs.lgh_number
	,Convert(float,sum(IsNull(stops.stp_lgh_mileage,0))) as Loaded
	into #TempLegLoadedMiles
	from #TempAllMovesLegs left join stops (NOLOCK) on #TempAllMovesLegs .lgh_number = stops.lgh_number AND stops.stp_loadstatus = 'LD'
	group by #TempAllMovesLegs.lgh_number

	Update #TempAllMovesLegs set LegLoadedMiles = Loaded
	,LegEmptyMiles = LegTravelMiles - Loaded
	from #TempLegLoadedMiles
	where #TempAllMovesLegs.lgh_number = #TempLegLoadedMiles.lgh_number

	-- Move Start and Move End dates
	Select #TempAllMovesLegs.mov_number
	,min(#TempAllMovesLegs.lgh_startdate) as MoveStart
	,max(#TempAllMovesLegs.lgh_enddate) as MoveEnd
	,min(#TempAllMovesLegs.lgh_createdon) as MoveCreate
	into #TempMoveTimes
	from #TempAllMovesLegs
	group by #TempAllMovesLegs.mov_number

	Update #TempAllMovesLegs set MoveStartDate = MoveStart
	,MoveEndDate = MoveEnd
	,MoveCreateDate = MoveCreate
	from #TempMoveTimes
	where #TempAllMovesLegs.mov_number = #TempMoveTimes.mov_number

	-- New Trailer Update Code *********************************************************************************************************************************
	SELECT t1.lgh_number, e.evt_trailer1, e.evt_trailer2, s.stp_type, s.stp_event
	INTO #TempAllMovesLegs_Helper
	FROM #TempAllMovesLegs t1 INNER JOIN stops s (NOLOCK) ON t1.lgh_number = s.lgh_number 
	INNER JOIN event E (NOLOCK) ON s.stp_number = E.stp_number 

	-- QUERY #2:  16,032 reads
	SELECT * INTO #TempAllMovesLegs_Helper2 FROM #TempAllMovesLegs_Helper 
	WHERE IsNull(NullIf(NullIf(NullIf(stp_type,'NONE'),'OTP'),'UNK'),stp_event) in ('PUP','DRP','HLT','DLT','XDL','XDU')  -- Additional minor performance benefit.

	-- QUERY #3:  REMOVED Query #3 when adding trailer2.

	-- QUERY #4:  7,796 reads
	CREATE INDEX idxTemp_TempAllMovesLegs_Helper2_For_Triplets ON #TempAllMovesLegs_Helper2 (lgh_number)

	-- QUERY #5:  820,946 reads
	UPDATE #TempAllMovesLegs SET lgh_trailer1 = ISNULL(#TempAllMovesLegs_Helper2.evt_trailer1, #TempAllMovesLegs.lgh_trailer1)
	FROM #TempAllMovesLegs_Helper2
	WHERE #TempAllMovesLegs.lgh_number = #TempAllMovesLegs_Helper2.lgh_number

	UPDATE #TempAllMovesLegs SET lgh_trailer2 = ISNULL(#TempAllMovesLegs_Helper2.evt_trailer2, #TempAllMovesLegs.lgh_trailer2)
	FROM #TempAllMovesLegs_Helper2
	WHERE #TempAllMovesLegs.lgh_number = #TempAllMovesLegs_Helper2.lgh_number

	-- Cleanup
	DROP TABLE #TempAllMovesLegs_Helper
	DROP TABLE #TempAllMovesLegs_Helper2

	-- OLD trailer update code	
	--Update #TempAllMovesLegs set lgh_trailer1 = 
	--	IsNull(	(
	--				Select Top 1 evt_trailer1
	--				from event E (NOLOCK) 
	--				Where E.stp_number in 
	--					(
	--						Select stp_number 
	--						from stops (NOLOCK) 
	--						where #TempAllMovesLegs.lgh_number = stops.lgh_number 
	--						AND (stp_type in ('PUP','DRP') or stp_event in ('HLT','DLT','XDU','XDL'))
	--					)
	--			),lgh_trailer1)

	--Update #TempAllMovesLegs set lgh_trailer2 = 
	--	IsNull(	(
	--				Select Top 1 evt_trailer2
	--				from event E (NOLOCK) 
	--				Where E.stp_number in 
	--					(
	--						Select stp_number 
	--						from stops (NOLOCK) 
	--						where #TempAllMovesLegs.lgh_number = stops.lgh_number 
	--						AND (stp_type in ('PUP','DRP') or stp_event in ('HLT','DLT','XDU','XDL'))
	--					)
	--			),lgh_trailer2)

	-- 4. get all move x leg x order combos
	Select #TempAllMovesLegs.mov_number
	,#TempAllMovesLegs.lgh_number
	,IsNull(#TempAllMovesOrders.ord_hdrnumber,-1*#TempAllMovesLegs.mov_number) as ord_hdrnumber
	,#TempAllMovesLegs.lgh_tractor
	,#TempAllMovesLegs.lgh_driver1
	,#TempAllMovesLegs.lgh_driver2
	,#TempAllMovesLegs.lgh_trailer1
	,#TempAllMovesLegs.lgh_trailer2
	,IsNull(#TempAllMovesOrders.ord_totalmiles,0) as ord_totalmiles
	,IsNull(#TempAllMovesOrders.ord_bookdate,#TempAllMovesLegs.MoveCreateDate) as ord_bookdate
	,IsNull(#TempAllMovesOrders.ord_startdate,#TempAllMovesLegs.MoveStartDate) as ord_startdate
	,IsNull(#TempAllMovesOrders.ord_completiondate,#TempAllMovesLegs.MoveEndDate) as ord_completiondate
	,#TempAllMovesLegs.lgh_startdate
	,#TempAllMovesLegs.lgh_enddate
	,#TempAllMovesLegs.LegTravelMiles
	,#TempAllMovesLegs.LegLoadedMiles
	,#TempAllMovesLegs.LegEmptyMiles
	,#TempAllMovesLegs.MoveStartDate
	,#TempAllMovesLegs.MoveEndDate
	,#TempAllMovesLegs.MoveCreateDate
	,Convert(float,0.0) as CountOfOrdersOnThisLeg
	,Convert(float,0.0) as CountOfLegsForThisOrder
	,Convert(float,0.0) as GrossLegMilesForOrder
	,Convert(float,0.0) as GrossLDLegMilesForOrder
	,Convert(float,0.0) as GrossBillMilesForLeg
	into #TempTripletList
	from #TempAllMovesLegs left join #TempAllMovesOrders on #TempAllMovesLegs.mov_number = #TempAllMovesOrders.mov_number

	Create Table #TempGrossLegMilesForOrder (ord_hdrnumber int, GrossLegMilesForOrder float)
	Create Table #TempGrossLDLegMilesForOrder (ord_hdrnumber int, GrossLDLegMilesForOrder float)

	-- get ALL Leg Travel Miles related to each Order
	Insert into #TempGrossLegMilesForOrder (ord_hdrnumber,GrossLegMilesForOrder)
	select ord_hdrnumber
	,sum(IsNull(LegTravelMiles,0)) as GrossLegMilesForOrder
	from #TempTripletList
	group by ord_hdrnumber

	update #TempTripletList set GrossLegMilesForOrder = #TempGrossLegMilesForOrder.GrossLegMilesForOrder
	from #TempGrossLegMilesForOrder
	where #TempTripletList.ord_hdrnumber = #TempGrossLegMilesForOrder.ord_hdrnumber

	Insert into #TempGrossLDLegMilesForOrder (ord_hdrnumber,GrossLDLegMilesForOrder)
	select ord_hdrnumber
	,sum(IsNull(LegLoadedMiles,0)) as GrossLDLegMilesForOrder
	from #TempTripletList
	group by ord_hdrnumber

	update #TempTripletList set GrossLDLegMilesForOrder = #TempGrossLDLegMilesForOrder.GrossLDLegMilesForOrder
	from #TempGrossLDLegMilesForOrder
	where #TempTripletList.ord_hdrnumber = #TempGrossLDLegMilesForOrder.ord_hdrnumber

	-- get ALL Order Bill Miles related to each Leg
	select lgh_number
	,sum(IsNull(ord_totalmiles,0)) as GrossBillMilesForLeg
	into #TempGrossBillMilesForLeg
	from #TempTripletList
	group by lgh_number

	update #TempTripletList set GrossBillMilesForLeg = #TempGrossBillMilesForLeg.GrossBillMilesForLeg
	from #TempGrossBillMilesForLeg
	where #TempTripletList.lgh_number = #TempGrossBillMilesForLeg.lgh_number

	-- get Count of Orders involved in each Leg
	Select lgh_number
	,count(ord_hdrnumber) as OrderCount
	into #TempOrderCountForLegs
	from #TempTripletList
	group by lgh_number

	update #TempTripletList set CountOfOrdersOnThisLeg = OrderCount
	from #TempOrderCountForLegs
	where #TempTripletList.lgh_number = #TempOrderCountForLegs.lgh_number

	-- get Count of Legs associated with each Order
	Select ord_hdrnumber
	,count(lgh_number) as LegCount
	into #TempLegCountForOrders
	from #TempTripletList
	group by ord_hdrnumber

	update #TempTripletList set CountOfLegsForThisOrder = LegCount
	from #TempLegCountForOrders
	where #TempTripletList.ord_hdrnumber = #TempLegCountForOrders.ord_hdrnumber

	-- delete existing triplets that are being refreshed
	--Delete from ResNow_Triplets 
	--Where Exists 
	--	(
	--		Select * 
	--		from #TempTripletList 
	--		where ResNow_Triplets.mov_number = #TempTripletList.mov_number
	--		AND ResNow_Triplets.lgh_number = #TempTripletList.lgh_number
	--		AND ResNow_Triplets.ord_hdrnumber = #TempTripletList.ord_hdrnumber
	--	)


	-- Update & Insert instead of Delete & Insert
	Update ResNow_Triplets set lgh_tractor = T1.lgh_tractor
	,lgh_driver1 = T1.lgh_driver1
	,lgh_driver2 = T1.lgh_driver2
	,lgh_trailer1 = T1.lgh_trailer1
	,lgh_trailer2 = T1.lgh_trailer2
	,ord_totalmiles = T1.ord_totalmiles
	,ord_bookdate = T1.ord_bookdate
	,ord_startdate = T1.ord_startdate
	,ord_completiondate = T1.ord_completiondate
	,lgh_startdate = T1.lgh_startdate
	,lgh_enddate = T1.lgh_enddate
	,LegTravelMiles = T1.LegTravelMiles
	,LegLoadedMiles = T1.LegLoadedMiles
	,LegEmptyMiles = T1.LegEmptyMiles
	,MoveStartDate = T1.MoveStartDate
	,MoveEndDate = T1.MoveEndDate
	,MoveCreateDate = T1.MoveCreateDate
	,CountOfOrdersOnThisLeg = T1.CountOfOrdersOnThisLeg
	,CountOfLegsForThisOrder = T1.CountOfLegsForThisOrder
	,GrossLegMilesForOrder = T1.GrossLegMilesForOrder
	,GrossLDLegMilesForOrder = T1.GrossLDLegMilesForOrder
	,GrossBillMilesForLeg = T1.GrossBillMilesForLeg
	,Date_Updated = @ThisCycleTime 
	from #TempTripletList T1
	where T1.ord_hdrnumber = ResNow_Triplets.ord_hdrnumber
	AND T1.mov_number = ResNow_Triplets.mov_number
	AND T1.lgh_number = ResNow_Triplets.lgh_number

Insert into ResNow_Triplets
	(
		mov_number,lgh_number,ord_hdrnumber,lgh_tractor,lgh_driver1,lgh_driver2,lgh_trailer1,lgh_trailer2
		,ord_totalmiles,ord_bookdate,ord_startdate,ord_completiondate,lgh_startdate,lgh_enddate
		,LegTravelMiles,LegLoadedMiles,LegEmptyMiles,MoveStartDate,MoveEndDate,MoveCreateDate
		,CountOfOrdersOnThisLeg,CountOfLegsForThisOrder,GrossLegMilesForOrder,GrossLDLegMilesForOrder
		,GrossBillMilesForLeg,Date_Updated
	)
		select T1.mov_number
		,T1.lgh_number
		,T1.ord_hdrnumber
		,T1.lgh_tractor
		,T1.lgh_driver1
		,T1.lgh_driver2
		,T1.lgh_trailer1
		,T1.lgh_trailer2
		,T1.ord_totalmiles
		,T1.ord_bookdate
		,T1.ord_startdate
		,T1.ord_completiondate
		,T1.lgh_startdate
		,T1.lgh_enddate
		,T1.LegTravelMiles
		,T1.LegLoadedMiles
		,T1.LegEmptyMiles
		,T1.MoveStartDate
		,T1.MoveEndDate
		,T1.MoveCreateDate
		,T1.CountOfOrdersOnThisLeg
		,T1.CountOfLegsForThisOrder
		,T1.GrossLegMilesForOrder
		,T1.GrossLDLegMilesForOrder
		,T1.GrossBillMilesForLeg
		,@ThisCycleTime 
		from #TempTripletList T1
		where NOT Exists
			(
				select sn 
				from ResNow_Triplets T2 (NOLOCK)
				where T2.ord_hdrnumber = T1.ord_hdrnumber
				AND T2.mov_number = T1.mov_number
				AND T2.lgh_number = T1.lgh_number
			)
		order by mov_number,lgh_startdate,ord_startdate

	-- clean up orphans
	Delete from ResNow_Triplets
	Where NOT Exists
		(
			Select lgh_number
			From LegHeader (NOLOCK)
			Where ResNow_Triplets.lgh_number = LegHeader.lgh_number
		)

	Delete from ResNow_Triplets
	Where ord_hdrnumber > 0
	AND NOT Exists
		(
			Select ord_hdrnumber
			From orderheader (NOLOCK)
			Where ResNow_Triplets.ord_hdrnumber = orderheader.ord_hdrnumber
			AND orderheader.ord_status in ('AVL','PLN','DSP','STD','CMP')
		)

  
	drop table #TempDeleteLegs
	drop table #TempMoves

	drop table #TempAllMovesOrders
	drop table #TempAllMovesLegs
	drop table #TempLegLoadedMiles
	drop table #TempMoveTimes

	drop table #TempGrossLegMilesForOrder
	drop table #TempGrossLDLegMilesForOrder
	drop table #TempGrossBillMilesForLeg

	drop table #TempOrderCountForLegs
	drop table #TempLegCountForOrders
	drop table #TempTripletList

-- select top 100 * from ResNow_Triplets where mov_number = 77420

-- ************************************** The Driver Update Here ******************************************
-- truncate existing extract table
truncate table ResNow_DriverCache_Extract

Insert into ResNow_DriverCache_Extract	
	(	driver_id,driver_directoryname,driver_type1,driver_type2,driver_type3,driver_type4
		,driver_company,driver_division,driver_terminal,driver_fleet,driver_branch,driver_domicile,driver_teamleader
		,driver_servicerule,driver_address1,driver_address2,driver_city,driver_state,driver_zip,driver_county
		,driver_country,driver_lastname,driver_firstname,driver_middlename,driver_dateofbirth,driver_hiredate
		,driver_senioritydate,driver_licensestate,driver_licenseclass,driver_licensenumber,driver_terminationdate
		,driver_DateStart,driver_DateEnd	)

select driver_id = mpp_id
	,driver_directoryname =	
		Case When IsNull(mpp_middlename,'') = '' Then
			IsNull(mpp_lastname,mpp_id) + ', ' + IsNull(mpp_firstname,mpp_id)
		Else
			IsNull(mpp_lastname,mpp_id) + ', ' + IsNull(mpp_firstname,mpp_id) + ' ' + mpp_middlename
		End
	,driver_type1 = mpp_type1
	,driver_type2 = mpp_type2
	,driver_type3 = mpp_type3
	,driver_type4 = mpp_type4
	,driver_company = mpp_company
	,driver_division = mpp_division
	,driver_terminal = mpp_terminal
	,driver_fleet = mpp_fleet
	,driver_branch	= IsNull(mpp_branch,'UNKNOWN')
	,driver_domicile = mpp_domicile
	,driver_teamleader = IsNull(mpp_teamleader,'UNK')
	,driver_servicerule = mpp_servicerule
	,driver_address1 = IsNull(mpp_address1,'')
	,driver_address2 = IsNull(mpp_address2,'')
	,driver_city = IsNull(cty_name,'')
	,driver_state = IsNull(mpp_state,'')
	,driver_zip = IsNull(mpp_zip,'')
	,driver_county = IsNull(cty_county,'')
	,driver_country = IsNull(cty_country,'')
	,driver_lastname = IsNull(mpp_lastname,mpp_id)
	,driver_firstname = IsNull(mpp_firstname,mpp_id)
	,driver_middlename = IsNull(mpp_middlename,'')
	,driver_dateofbirth = IsNull(mpp_dateofbirth,'1/1/1900')
	,driver_hiredate = IsNull(mpp_hiredate,'1/1/1900')
	,driver_senioritydate = IsNull(mpp_senioritydate,IsNull(mpp_hiredate,'1/1/1900'))
	,driver_licensestate = IsNull(mpp_licensestate,'')
	,driver_licenseclass = IsNull(mpp_licenseclass,'')
	,driver_licensenumber = IsNull(mpp_licensenumber,'')
	,driver_terminationdate = IsNull(mpp_terminationdt,'2049-12-31 23:59:59.000')
	,driver_DateStart = IsNull(mpp_updateon,ISNULL(mpp_createdate,'1950-01-01'))
	,driver_DateEnd = Convert(DateTime,'12/31/2049 23:59:59.000') 
From manpowerprofile MPP (NOLOCK) join city city (NOLOCK) on MPP.mpp_city = City.cty_code
Where MPP.timestamp between @OldTimeStamp AND @NewTimeStamp

-- delete out of sequence changes; shouldn't happen in live data 
Delete from ResNow_DriverCache_Extract where driver_DateStart < IsNull((Select max(driver_DateStart) from ResNow_DriverCache_Final (NOLOCK) where ResNow_DriverCache_Extract.Driver_ID = ResNow_DriverCache_Final.Driver_ID),'19500101')

Update ResNow_DriverCache_Extract set driver_DateStart = '19500101' 
where NOT exists 
	(
		select *
		from ResNow_DriverCache_Final (NOLOCK)
		where ResNow_DriverCache_Extract.driver_id = ResNow_DriverCache_Final.driver_id
	)


-- Step 1: SCD 2 changes required
select CDE.driver_id
into #DriverSCD2Changes
from ResNow_DriverCache_Extract CDE (NOLOCK)  
		left join ResNow_DriverCache_Final CDF (NOLOCK) on CDE.driver_id = CDF.driver_id
Where CDF.driver_active is NULL
	OR (CDF.driver_active = 1 
	AND (((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_directoryname') = 2 AND CDE.driver_directoryname <> CDF.driver_directoryname)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_type1') = 2 AND CDE.driver_type1 <> CDF.driver_type1)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_type2') = 2 AND CDE.driver_type2 <> CDF.driver_type2)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_type3') = 2 AND CDE.driver_type3 <> CDF.driver_type3)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_type4') = 2 AND CDE.driver_type4 <> CDF.driver_type4)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_company') = 2 AND CDE.driver_company <> CDF.driver_company)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_division') = 2 AND CDE.driver_division <> CDF.driver_division)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_terminal') = 2 AND CDE.driver_terminal <> CDF.driver_terminal)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_fleet') = 2 AND CDE.driver_fleet <> CDF.driver_fleet)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_branch') = 2 AND CDE.driver_branch <> CDF.driver_branch)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_domicile') = 2 AND CDE.driver_domicile <> CDF.driver_domicile)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_teamleader') = 2 AND CDE.driver_teamleader <> CDF.driver_teamleader)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_servicerule') = 2 AND CDE.driver_servicerule <> CDF.driver_servicerule)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_address1') = 2 AND CDE.driver_address1 <> CDF.driver_address1)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_address2') = 2 AND CDE.driver_address2 <> CDF.driver_address2)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_city') = 2 AND CDE.driver_city <> CDF.driver_city)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_state') = 2 AND CDE.driver_state <> CDF.driver_state)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_zip') = 2 AND CDE.driver_zip <> CDF.driver_zip)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_county') = 2 AND CDE.driver_county <> CDF.driver_county)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_country') = 2 AND CDE.driver_country <> CDF.driver_country)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_lastname') = 2 AND CDE.driver_lastname <> CDF.driver_lastname)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_firstname') = 2 AND CDE.driver_firstname <> CDF.driver_firstname)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_middlename') = 2 AND CDE.driver_middlename <> CDF.driver_middlename)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_dateofbirth') = 2 AND CDE.driver_dateofbirth <> CDF.driver_dateofbirth)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_hiredate') = 2 AND CDE.driver_hiredate <> CDF.driver_hiredate)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_senioritydate') = 2 AND CDE.driver_senioritydate <> CDF.driver_senioritydate)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_licensestate') = 2 AND CDE.driver_licensestate <> CDF.driver_licensestate)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_licenseclass') = 2 AND CDE.driver_licenseclass <> CDF.driver_licenseclass)
	OR ((Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_licensenumber') = 2 AND CDE.driver_licensenumber <> CDF.driver_licensenumber)))


-- Step 2: Update ResNow_DriverCache_Final SCD=1 fields where NOT driver_id in (Select driver_id from #DriverSCD2Changes)
Update ResNow_DriverCache_Final Set
	driver_directoryname = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_directoryname') <> 2 Then CDE.Driver_Directoryname Else ResNow_DriverCache_Final.driver_directoryname End
	,driver_type1 = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_type1') <> 2 Then CDE.driver_type1 Else ResNow_DriverCache_Final.driver_type1 End
	,driver_type2 = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_type2') <> 2 Then CDE.driver_type2 Else ResNow_DriverCache_Final.driver_type2 End
	,driver_type3 = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_type3') <> 2 Then CDE.driver_type3 Else ResNow_DriverCache_Final.driver_type3 End
	,driver_type4 = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_type4') <> 2 Then CDE.driver_type4 Else ResNow_DriverCache_Final.driver_type4 End
	,driver_company = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_company') <> 2 Then CDE.driver_company Else ResNow_DriverCache_Final.driver_company End
	,driver_division = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_division') <> 2 Then CDE.driver_division Else ResNow_DriverCache_Final.driver_division End
	,driver_terminal = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_terminal') <> 2 Then CDE.driver_terminal Else ResNow_DriverCache_Final.driver_terminal End
	,driver_fleet = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_fleet') <> 2 Then CDE.driver_fleet Else ResNow_DriverCache_Final.driver_fleet End
	,driver_branch = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_branch') <> 2 Then CDE.driver_branch Else ResNow_DriverCache_Final.driver_branch End
	,driver_domicile = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_domicile') <> 2 Then CDE.driver_domicile Else ResNow_DriverCache_Final.driver_domicile End
	,driver_teamleader = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_teamleader') <> 2 Then CDE.driver_teamleader Else ResNow_DriverCache_Final.driver_teamleader End
	,driver_servicerule = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_servicerule') <> 2 Then CDE.driver_servicerule Else ResNow_DriverCache_Final.driver_servicerule End
	,driver_address1 = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_address1') <> 2 Then CDE.driver_address1 Else ResNow_DriverCache_Final.driver_address1 End
	,driver_address2 = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_address2') <> 2 Then CDE.driver_address2 Else ResNow_DriverCache_Final.driver_address2 End
	,driver_city = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_city') <> 2 Then CDE.driver_city Else ResNow_DriverCache_Final.driver_city End
	,driver_state = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_state') <> 2 Then CDE.driver_state Else ResNow_DriverCache_Final.driver_state End
	,driver_zip = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_zip') <> 2 Then CDE.driver_zip Else ResNow_DriverCache_Final.driver_zip End
	,driver_county = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_county') <> 2 Then CDE.driver_county Else ResNow_DriverCache_Final.driver_county End
	,driver_country = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_country') <> 2 Then CDE.driver_country Else ResNow_DriverCache_Final.driver_country End
	,driver_lastname = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_lastname') <> 2 Then CDE.driver_lastname Else ResNow_DriverCache_Final.driver_lastname End
	,driver_firstname = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_firstname') <> 2 Then CDE.driver_firstname Else ResNow_DriverCache_Final.driver_firstname End
	,driver_middlename = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_middlename') <> 2 Then CDE.driver_middlename Else ResNow_DriverCache_Final.driver_middlename End
	,driver_dateofbirth = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_dateofbirth') <> 2 Then CDE.driver_dateofbirth Else ResNow_DriverCache_Final.driver_dateofbirth End
	,driver_hiredate = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_hiredate') <> 2 Then CDE.driver_hiredate Else ResNow_DriverCache_Final.driver_hiredate End
	,driver_senioritydate = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_senioritydate') <> 2 Then CDE.driver_senioritydate Else ResNow_DriverCache_Final.driver_senioritydate End
	,driver_licensestate = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_licensestate') <> 2 Then CDE.driver_licensestate Else ResNow_DriverCache_Final.driver_licensestate End
	,driver_licenseclass = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_licenseclass') <> 2 Then CDE.driver_licenseclass Else ResNow_DriverCache_Final.driver_licenseclass End
	,driver_licensenumber = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_licensenumber') <> 2 Then CDE.driver_licensenumber Else ResNow_DriverCache_Final.driver_licensenumber End
	,driver_terminationdate = Case When (Select SCD_Type From ResNow_MetaDriverCache (NOLOCK) Where Column_name = 'driver_terminationdate') <> 2 Then CDE.driver_terminationdate Else ResNow_DriverCache_Final.driver_terminationdate End
From ResNow_DriverCache_Extract CDE (NOLOCK) 
Where CDE.driver_id = ResNow_DriverCache_Final.driver_id


-- Step 3: Update ResNow_DriverCache_Final where SCD2 change has occurred
Update ResNow_DriverCache_Final set 
	driver_active = 0	-- make current row INACTIVE
	,driver_DateEnd = CDE.driver_DateStart  -- set row ending date; 'change date' is in DateStart column of extract table
From ResNow_DriverCache_Extract CDE (NOLOCK) 
Where ResNow_DriverCache_Final.driver_active = 1
AND CDE.driver_id = ResNow_DriverCache_Final.driver_id
AND ResNow_DriverCache_Final.driver_id in (Select driver_id from #DriverSCD2Changes)
	

-- Step 4: Insert into ResNow_DriverCache_Final where SCD2 change has occurred
Insert Into ResNow_DriverCache_Final 
	(	driver_id,driver_directoryname,driver_type1,driver_type2,driver_type3,driver_type4
		,driver_company,driver_division,driver_terminal,driver_fleet,driver_branch,driver_domicile,driver_teamleader
		,driver_servicerule,driver_address1,driver_address2,driver_city,driver_state,driver_zip,driver_county
		,driver_country,driver_lastname,driver_firstname,driver_middlename,driver_dateofbirth,driver_hiredate
		,driver_senioritydate,driver_licensestate,driver_licenseclass,driver_licensenumber,driver_terminationdate
		,driver_DateStart,driver_DateEnd,driver_active,driver_updated	)
Select driver_id
	,driver_directoryname
	,driver_type1
	,driver_type2
	,driver_type3
	,driver_type4
	,driver_company
	,driver_division
	,driver_terminal
	,driver_fleet
	,driver_branch
	,driver_domicile
	,driver_teamleader
	,driver_servicerule
	,driver_address1
	,driver_address2
	,driver_city
	,driver_state
	,driver_zip
	,driver_county
	,driver_country
	,driver_lastname
	,driver_firstname
	,driver_middlename
	,driver_dateofbirth
	,driver_hiredate
	,driver_senioritydate
	,driver_licensestate
	,driver_licenseclass
	,driver_licensenumber
	,driver_terminationdate
	,driver_DateStart -- this is when SCD2 change occurred; corresponds to DateEnd of previously active row
	,driver_DateEnd -- Armageddon
	,1
	,@ThisCycleTime
From ResNow_DriverCache_Extract (NOLOCK)
Where driver_id in (Select driver_id from #DriverSCD2Changes)

Drop table  #DriverSCD2Changes

-- ************************************** The Tractor Update Here ******************************************
-- Clear existing dimension extract table
truncate table ResNow_TractorCache_Extract

Insert into ResNow_TractorCache_Extract	
	(	
		tractor_id,tractor_seatedstatus,tractor_type1,tractor_type2,tractor_type3
		,tractor_type4,tractor_company,tractor_division,tractor_terminal,tractor_fleet,tractor_branch,tractor_owner
		,tractor_make,tractor_model,tractor_year,tractor_enginemake,tractor_enginemodel,tractor_fuelcapacity
		,tractor_grossweight,tractor_axlecount,tractor_tareweight,tractor_tareweightuom,tractor_originalcost
		,tractor_licensestate,tractor_licensecountry,tractor_licensenumber,tractor_startdate
		,tractor_dateacquired,tractor_retiredate,tractor_DateStart,tractor_DateEnd	
	)
Select
	tractor_id = trc_number
	,tractor_seatedstatus = 
		Case When IsNull(trc_driver,'UNKNOWN') = 'UNKNOWN' Then
			'Unseated'
		Else
			trc_driver
		End
	,tractor_type1 = trc_type1
	,tractor_type2 = trc_type2
	,tractor_type3 = trc_type3
	,tractor_type4 = trc_type4
	,tractor_company = trc_company
	,tractor_division = trc_division
	,tractor_terminal = trc_terminal
	,tractor_fleet = trc_fleet
	,tractor_branch	= IsNull(trc_branch,'UNKNOWN')
	,tractor_owner = trc_owner
	,tractor_make = IsNull(trc_make,'')
	,tractor_model = IsNull(trc_model,'')
	,tractor_year = IsNull(trc_year,'')
	,tractor_enginemake = IsNull(trc_enginemake,'')
	,tractor_enginemodel = IsNull(trc_enginemodel,'')
	,tractor_fuelcapacity = IsNull(trc_tank_capacity,'')
	,tractor_grossweight = IsNull(trc_grosswgt,'')
	,tractor_axlecount = IsNull(trc_axles,'')
	,tractor_tareweight = IsNull(trc_tareweight,'')
	,tractor_tareweightuom = IsNull(trc_tareweight_uom,'')
	,tractor_originalcost = IsNull(trc_origcost,'')
	,tractor_licensestate = IsNull(trc_licstate,'')
	,tractor_licensecountry = IsNull(trc_liccountry,'')
	,tractor_licensenumber = IsNull(trc_licnum,'')
	,tractor_startdate = IsNull(trc_startdate,'01/01/1950 00:00:00.000') 
	,tractor_dateacquired = IsNull(trc_dateacquired,trc_startdate)
	,tractor_retiredate = IsNull(trc_retiredate,'12/31/2049 23:59:59.000') 
	,tractor_DateStart = IsNull(trc_updatedon,ISNULL(trc_createdate,'1950-01-01'))
	,tractor_DateEnd = Convert(DateTime,'12/31/2049 23:59:59.000') 
From tractorprofile (NOLOCK)
Where tractorprofile.timestamp between @OldTimeStamp AND @NewTimeStamp

-- delete out of sequence changes; shouldn't happen in live data 
Delete from ResNow_TractorCache_Extract where tractor_DateStart < IsNull((Select max(tractor_DateStart) from ResNow_TractorCache_Final (NOLOCK) where ResNow_TractorCache_Extract.Tractor_ID = ResNow_TractorCache_Final.Tractor_ID),'19500101')

Update ResNow_TractorCache_Extract set tractor_DateStart = '19500101' 
where NOT exists 
	(
		select *
		from ResNow_TractorCache_Final (NOLOCK)
		where ResNow_TractorCache_Extract.tractor_id = ResNow_TractorCache_Final.tractor_id
	)


-- Step 1: SCD 2 changes required
select CDE.tractor_id
into #TractorSCD2Changes
from ResNow_TractorCache_Extract CDE (NOLOCK)
		left join ResNow_TractorCache_Final CDF (NOLOCK) on CDE.tractor_id = CDF.tractor_id
Where CDF.tractor_active is NULL
	OR (CDF.tractor_active = 1 
	AND (((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_seatedstatus') = 2 AND CDE.tractor_seatedstatus <> CDF.tractor_seatedstatus)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_type1') = 2 AND CDE.tractor_type1 <> CDF.tractor_type1)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_type2') = 2 AND CDE.tractor_type2 <> CDF.tractor_type2)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_type3') = 2 AND CDE.tractor_type3 <> CDF.tractor_type3)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_type4') = 2 AND CDE.tractor_type4 <> CDF.tractor_type4)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_company') = 2 AND CDE.tractor_company <> CDF.tractor_company)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_division') = 2 AND CDE.tractor_division <> CDF.tractor_division)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_terminal') = 2 AND CDE.tractor_terminal <> CDF.tractor_terminal)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_fleet') = 2 AND CDE.tractor_fleet <> CDF.tractor_fleet)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_branch') = 2 AND CDE.tractor_branch <> CDF.tractor_branch)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_owner') = 2 AND CDE.tractor_owner <> CDF.tractor_owner)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_make') = 2 AND CDE.tractor_make <> CDF.tractor_make)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_model') = 2 AND CDE.tractor_model <> CDF.tractor_model)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_year') = 2 AND CDE.tractor_year <> CDF.tractor_year)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_enginemake') = 2 AND CDE.tractor_enginemake <> CDF.tractor_enginemake)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_enginemodel') = 2 AND CDE.tractor_enginemodel <> CDF.tractor_enginemodel)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_fuelcapacity') = 2 AND CDE.tractor_fuelcapacity <> CDF.tractor_fuelcapacity)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_grossweight') = 2 AND CDE.tractor_grossweight <> CDF.tractor_grossweight)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_axlecount') = 2 AND CDE.tractor_axlecount <> CDF.tractor_axlecount)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_tareweight') = 2 AND CDE.tractor_tareweight <> CDF.tractor_tareweight)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_tareweightuom') = 2 AND CDE.tractor_tareweightuom <> CDF.tractor_tareweightuom)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_originalcost') = 2 AND CDE.tractor_originalcost <> CDF.tractor_originalcost)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_licensestate') = 2 AND CDE.tractor_licensestate <> CDF.tractor_licensestate)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_licensecountry') = 2 AND CDE.tractor_licensecountry <> CDF.tractor_licensecountry)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_licensenumber') = 2 AND CDE.tractor_licensenumber <> CDF.tractor_licensenumber)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_startdate') = 2 AND CDE.tractor_startdate <> CDF.tractor_startdate)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_dateacquired') = 2 AND CDE.tractor_dateacquired <> CDF.tractor_dateacquired)
	OR ((Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_retiredate') = 2 AND CDE.tractor_retiredate <> CDF.tractor_retiredate)))


-- Step 2: Update dwDriverDimension_Final SCD=1 fields where NOT driver_id in (Select driver_id from #DriverSCD2Changes)
Update ResNow_TractorCache_Final Set
	tractor_seatedstatus = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_seatedstatus') <> 2 Then CDE.tractor_seatedstatus Else ResNow_TractorCache_Final.tractor_seatedstatus End
	,tractor_type1 = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_type1') <> 2 Then CDE.tractor_type1 Else ResNow_TractorCache_Final.tractor_type1 End
	,tractor_type2 = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_type2') <> 2 Then CDE.tractor_type2 Else ResNow_TractorCache_Final.tractor_type2 End
	,tractor_type3 = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_type3') <> 2 Then CDE.tractor_type3 Else ResNow_TractorCache_Final.tractor_type3 End
	,tractor_type4 = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_type4') <> 2 Then CDE.tractor_type4 Else ResNow_TractorCache_Final.tractor_type4 End
	,tractor_company = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_company') <> 2 Then CDE.tractor_company Else ResNow_TractorCache_Final.tractor_company End
	,tractor_division = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_division') <> 2 Then CDE.tractor_division Else ResNow_TractorCache_Final.tractor_division End
	,tractor_terminal = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_terminal') <> 2 Then CDE.tractor_terminal Else ResNow_TractorCache_Final.tractor_terminal End
	,tractor_fleet = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_fleet') <> 2 Then CDE.tractor_fleet Else ResNow_TractorCache_Final.tractor_fleet End
	,tractor_branch = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_branch') <> 2 Then CDE.tractor_branch Else ResNow_TractorCache_Final.tractor_branch End
	,tractor_owner = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_owner') <> 2 Then CDE.tractor_owner Else ResNow_TractorCache_Final.tractor_owner End
	,tractor_make = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_make') <> 2 Then CDE.tractor_make Else ResNow_TractorCache_Final.tractor_make End
	,tractor_model = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_model') <> 2 Then CDE.tractor_model Else ResNow_TractorCache_Final.tractor_model End
	,tractor_year = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_year') <> 2 Then CDE.tractor_year Else ResNow_TractorCache_Final.tractor_year End
	,tractor_enginemake = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_enginemake') <> 2 Then CDE.tractor_enginemake Else ResNow_TractorCache_Final.tractor_enginemake End
	,tractor_enginemodel = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_enginemodel') <> 2 Then CDE.tractor_enginemodel Else ResNow_TractorCache_Final.tractor_enginemodel End
	,tractor_fuelcapacity = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_fuelcapacity') <> 2 Then CDE.tractor_fuelcapacity Else ResNow_TractorCache_Final.tractor_fuelcapacity End
	,tractor_grossweight = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_grossweight') <> 2 Then CDE.tractor_grossweight Else ResNow_TractorCache_Final.tractor_grossweight End
	,tractor_axlecount = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_axlecount') <> 2 Then CDE.tractor_axlecount Else ResNow_TractorCache_Final.tractor_axlecount End
	,tractor_tareweight = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_tareweight') <> 2 Then CDE.tractor_tareweight Else ResNow_TractorCache_Final.tractor_tareweight End
	,tractor_tareweightuom = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_tareweightuom') <> 2 Then CDE.tractor_tareweightuom Else ResNow_TractorCache_Final.tractor_tareweightuom End
	,tractor_originalcost = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_originalcost') <> 2 Then CDE.tractor_originalcost Else ResNow_TractorCache_Final.tractor_originalcost End
	,tractor_licensestate = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_licensestate') <> 2 Then CDE.tractor_licensestate Else ResNow_TractorCache_Final.tractor_licensestate End
	,tractor_licensecountry = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_licensecountry') <> 2 Then CDE.tractor_licensecountry Else ResNow_TractorCache_Final.tractor_licensecountry End
	,tractor_licensenumber = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_licensenumber') <> 2 Then CDE.tractor_licensenumber Else ResNow_TractorCache_Final.tractor_licensenumber End
	,tractor_startdate = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_startdate') <> 2 Then CDE.tractor_startdate Else ResNow_TractorCache_Final.tractor_startdate End
	,tractor_dateacquired = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_dateacquired') <> 2 Then CDE.tractor_dateacquired Else ResNow_TractorCache_Final.tractor_dateacquired End
	,tractor_retiredate = Case When (Select SCD_Type From ResNow_MetaTractorCache (NOLOCK) Where Column_name = 'tractor_retiredate') <> 2 Then CDE.tractor_retiredate Else ResNow_TractorCache_Final.tractor_retiredate End
From ResNow_TractorCache_Extract CDE (NOLOCK) 
Where CDE.tractor_id = ResNow_TractorCache_Final.tractor_id


-- Step 3: Update dwDriverDimension_Final where SCD2 change has occurred
Update ResNow_TractorCache_Final set 
	tractor_active = 0							-- make current row INACTIVE
	,tractor_DateEnd = CDE.tractor_DateStart	-- set row ending date; 'change date' is in DateStart column of extract table
From ResNow_TractorCache_Extract CDE (NOLOCK) 
Where ResNow_TractorCache_Final.tractor_active = 1
AND CDE.tractor_id = ResNow_TractorCache_Final.tractor_id
AND ResNow_TractorCache_Final.tractor_id in (Select tractor_id from #TractorSCD2Changes)
	

-- Step 4: Insert into dwDriverDimension_Final where SCD2 change has occurred
Insert Into ResNow_TractorCache_Final 
	(	
		tractor_id,tractor_seatedstatus,tractor_type1,tractor_type2,tractor_type3
		,tractor_type4,tractor_company,tractor_division,tractor_terminal,tractor_fleet,tractor_branch,tractor_owner
		,tractor_make,tractor_model,tractor_year,tractor_enginemake,tractor_enginemodel,tractor_fuelcapacity
		,tractor_grossweight,tractor_axlecount,tractor_tareweight,tractor_tareweightuom,tractor_originalcost
		,tractor_licensestate,tractor_licensecountry,tractor_licensenumber,tractor_startdate,tractor_dateacquired
		,tractor_retiredate,tractor_DateStart,tractor_DateEnd,tractor_active,tractor_updated
	)
Select tractor_id
	,tractor_seatedstatus
	,tractor_type1
	,tractor_type2
	,tractor_type3
	,tractor_type4
	,tractor_company
	,tractor_division
	,tractor_terminal
	,tractor_fleet
	,tractor_branch
	,tractor_owner
	,tractor_make
	,tractor_model
	,tractor_year
	,tractor_enginemake
	,tractor_enginemodel
	,tractor_fuelcapacity
	,tractor_grossweight
	,tractor_axlecount
	,tractor_tareweight
	,tractor_tareweightuom
	,tractor_originalcost
	,tractor_licensestate
	,tractor_licensecountry
	,tractor_licensenumber
	,tractor_startdate
	,tractor_dateacquired
	,tractor_retiredate
	,tractor_DateStart	-- this is when SCD2 change occurred; corresponds to DateEnd of previously active row
	,tractor_DateEnd	-- Armageddon
	,1
	,@ThisCycleTime
From ResNow_TractorCache_Extract (NOLOCK)
Where tractor_id in (Select tractor_id from #TractorSCD2Changes)

Drop table  #TractorSCD2Changes



-- ************************************** The Trailer Update Here ******************************************

-- Clear existing dimension extract table
truncate table ResNow_TrailerCache_Extract

-- Populate dimension table with fresh data
Insert into ResNow_TrailerCache_Extract	
	(	trailer_id,trailer_number,trailer_type1,trailer_type2,trailer_type3,trailer_type4
		,trailer_company,trailer_division,trailer_terminal,trailer_fleet,trailer_branch,trailer_owner
		,trailer_make,trailer_model,trailer_year,trailer_grossweight,trailer_tareweight,trailer_axles
		,trailer_height,trailer_length,trailer_width,trailer_licensestate,trailer_licensenumber
		,trailer_startdate,trailer_dateacquired,trailer_retiredate,trailer_DateStart,trailer_DateEnd	
	)
Select trailer_id = trl_id
	,trailer_number = IsNull(trl_number,trl_id)
	,trailer_type1 = trl_type1
	,trailer_type2 = trl_type2
	,trailer_type3 = trl_type3
	,trailer_type4 = trl_type4
	,trailer_company = trl_company
	,trailer_division = trl_division
	,trailer_terminal = trl_terminal
	,trailer_fleet = trl_fleet
	,trailer_branch	= IsNull(trl_branch,'UNKNOWN')
	,trailer_owner = trl_owner
	,trailer_make = IsNull(trl_make,'')
	,trailer_model = IsNull(trl_model,'')
	,trailer_year = IsNull(trl_year,'')
	,trailer_grossweight = trl_grosswgt
	,trailer_tareweight = trl_tareweight
	,trailer_axles = IsNull(trl_axles,'')
	,trailer_height = IsNull(trl_ht,'')
	,trailer_length = IsNull(trl_len,'')
	,trailer_width = IsNull(trl_wdth,'')
	,trailer_licensestate = IsNull(trl_licstate,'')
	,trailer_licensenumber = IsNull(trl_licnum,'')
	,trailer_startdate = IsNull(trl_startdate,trl_createdate)
	,trailer_dateacquired = IsNull(trl_dateacquired,IsNull(trl_startdate,trl_createdate))
	,trailer_retiredate = IsNull(trl_retiredate,'12/31/2049 23:59:59.000') 
	,trailer_DateStart = IsNull(trl_updateon,ISNULL(trl_createdate,'1950-01-01'))
	,trailer_DateEnd = Convert(DateTime,'12/31/2049 23:59:59.000') 
From trailerprofile trailerprofile (NOLOCK)
Where trailerprofile.timestamp between @OldTimeStamp AND @NewTimeStamp

-- delete out of sequence changes; shouldn't happen in live data 
Delete from ResNow_TrailerCache_Extract where trailer_DateStart < IsNull((Select max(trailer_DateStart) from ResNow_TrailerCache_Final (NOLOCK) where ResNow_TrailerCache_Extract.Trailer_ID = ResNow_TrailerCache_Final.Trailer_ID),'19500101')

Update ResNow_TrailerCache_Extract set trailer_DateStart = '19500101' 
where NOT exists 
	(
		select *
		from ResNow_TrailerCache_Final (NOLOCK)
		where ResNow_TrailerCache_Extract.trailer_id = ResNow_TrailerCache_Final.trailer_id
	)

-- Step 1: SCD 2 changes required
select CDE.trailer_id
into #TrailerSCD2Changes
from ResNow_TrailerCache_Extract CDE (NOLOCK) left join ResNow_TrailerCache_Final CDF (NOLOCK) on CDE.trailer_id = CDF.trailer_id
Where CDF.trailer_active is NULL
	OR (CDF.trailer_active = 1 
	AND (((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_number') = 2 AND CDE.trailer_number <> CDF.trailer_number)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_type1') = 2 AND CDE.trailer_type1 <> CDF.trailer_type1)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_type2') = 2 AND CDE.trailer_type2 <> CDF.trailer_type2)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_type3') = 2 AND CDE.trailer_type3 <> CDF.trailer_type3)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_type4') = 2 AND CDE.trailer_type4 <> CDF.trailer_type4)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_company') = 2 AND CDE.trailer_company <> CDF.trailer_company)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_division') = 2 AND CDE.trailer_division <> CDF.trailer_division)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_terminal') = 2 AND CDE.trailer_terminal <> CDF.trailer_terminal)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_fleet') = 2 AND CDE.trailer_fleet <> CDF.trailer_fleet)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_branch') = 2 AND CDE.trailer_branch <> CDF.trailer_branch)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_owner') = 2 AND CDE.trailer_owner <> CDF.trailer_owner)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_make') = 2 AND CDE.trailer_make <> CDF.trailer_make)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_model') = 2 AND CDE.trailer_model <> CDF.trailer_model)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_year') = 2 AND CDE.trailer_year <> CDF.trailer_year)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_grossweight') = 2 AND CDE.trailer_grossweight <> CDF.trailer_grossweight)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_tareweight') = 2 AND CDE.trailer_tareweight <> CDF.trailer_tareweight)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_axles') = 2 AND CDE.trailer_axles <> CDF.trailer_axles)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_height') = 2 AND CDE.trailer_height <> CDF.trailer_height)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_length') = 2 AND CDE.trailer_length <> CDF.trailer_length)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_width') = 2 AND CDE.trailer_width <> CDF.trailer_width)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_licensestate') = 2 AND CDE.trailer_licensestate <> CDF.trailer_licensestate)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_licensenumber') = 2 AND CDE.trailer_licensenumber <> CDF.trailer_licensenumber)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_startdate') = 2 AND CDE.trailer_startdate <> CDF.trailer_startdate)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_dateacquired') = 2 AND CDE.trailer_dateacquired <> CDF.trailer_dateacquired)
	OR ((Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_retiredate') = 2 AND CDE.trailer_retiredate <> CDF.trailer_retiredate)))


-- Step 2: Update ResNow_TrailerCache_Final SCD=1 fields where NOT trailer_id in (Select trailer_id from #TrailerSCD2Changes)
Update ResNow_TrailerCache_Final Set
	trailer_number = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_number') <> 2 Then CDE.trailer_number Else ResNow_TrailerCache_Final.trailer_number End
	,trailer_type1 = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_type1') <> 2 Then CDE.trailer_type1 Else ResNow_TrailerCache_Final.trailer_type1 End
	,trailer_type2 = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_type2') <> 2 Then CDE.trailer_type2 Else ResNow_TrailerCache_Final.trailer_type2 End
	,trailer_type3 = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_type3') <> 2 Then CDE.trailer_type3 Else ResNow_TrailerCache_Final.trailer_type3 End
	,trailer_type4 = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_type4') <> 2 Then CDE.trailer_type4 Else ResNow_TrailerCache_Final.trailer_type4 End
	,trailer_company = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_company') <> 2 Then CDE.trailer_company Else ResNow_TrailerCache_Final.trailer_company End
	,trailer_division = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_division') <> 2 Then CDE.trailer_division Else ResNow_TrailerCache_Final.trailer_division End
	,trailer_terminal = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_terminal') <> 2 Then CDE.trailer_terminal Else ResNow_TrailerCache_Final.trailer_terminal End
	,trailer_fleet = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_fleet') <> 2 Then CDE.trailer_fleet Else ResNow_TrailerCache_Final.trailer_fleet End
	,trailer_branch = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_branch') <> 2 Then CDE.trailer_branch Else ResNow_TrailerCache_Final.trailer_branch End
	,trailer_owner = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_owner') <> 2 Then CDE.trailer_owner Else ResNow_TrailerCache_Final.trailer_owner End
	,trailer_make = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_make') <> 2 Then CDE.trailer_make Else ResNow_TrailerCache_Final.trailer_make End
	,trailer_model = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_model') <> 2 Then CDE.trailer_model Else ResNow_TrailerCache_Final.trailer_model End
	,trailer_year = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_year') <> 2 Then CDE.trailer_year Else ResNow_TrailerCache_Final.trailer_year End
	,trailer_grossweight = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_grossweight') <> 2 Then CDE.trailer_grossweight Else ResNow_TrailerCache_Final.trailer_grossweight End
	,trailer_tareweight = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_tareweight') <> 2 Then CDE.trailer_tareweight Else ResNow_TrailerCache_Final.trailer_tareweight End
	,trailer_axles = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_axles') <> 2 Then CDE.trailer_axles Else ResNow_TrailerCache_Final.trailer_axles End
	,trailer_height = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_height') <> 2 Then CDE.trailer_height Else ResNow_TrailerCache_Final.trailer_height End
	,trailer_length = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_length') <> 2 Then CDE.trailer_length Else ResNow_TrailerCache_Final.trailer_length End
	,trailer_width = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_width') <> 2 Then CDE.trailer_width Else ResNow_TrailerCache_Final.trailer_width End
	,trailer_licensestate = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_licensestate') <> 2 Then CDE.trailer_licensestate Else ResNow_TrailerCache_Final.trailer_licensestate End
	,trailer_licensenumber = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_licensenumber') <> 2 Then CDE.trailer_licensenumber Else ResNow_TrailerCache_Final.trailer_licensenumber End
	,trailer_startdate = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_startdate') <> 2 Then CDE.trailer_startdate Else ResNow_TrailerCache_Final.trailer_startdate End
	,trailer_dateacquired = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_dateacquired') <> 2 Then CDE.trailer_dateacquired Else ResNow_TrailerCache_Final.trailer_dateacquired End
	,trailer_retiredate = Case When (Select SCD_Type From ResNow_MetaTrailerCache (NOLOCK) Where Column_name = 'trailer_retiredate') <> 2 Then CDE.trailer_retiredate Else ResNow_TrailerCache_Final.trailer_retiredate End
--	,trailer_DateStart = CDE.trailer_DateStart  -- DON'T update dates because this remains the current active row
--	,trailer_DateEnd = CDE.trailer_DateEnd		-- DON'T update dates because this remains the current active row
From ResNow_TrailerCache_Extract CDE (NOLOCK) 
Where CDE.trailer_id = ResNow_TrailerCache_Final.trailer_id


-- Step 3: Update ResNow_TrailerCache_Final where SCD2 change has occurred
Update ResNow_TrailerCache_Final set 
	trailer_active = 0							-- make current row INACTIVE
	,trailer_DateEnd = CDE.trailer_DateStart	-- set row ending date; 'change date' is in DateStart column of extract table
From ResNow_TrailerCache_Extract CDE (NOLOCK) 
Where ResNow_TrailerCache_Final.trailer_active = 1
AND CDE.trailer_id = ResNow_TrailerCache_Final.trailer_id
AND ResNow_TrailerCache_Final.trailer_id in (Select trailer_id from #TrailerSCD2Changes)
	

-- Step 4: Insert into ResNow_TrailerCache_Final where SCD2 change has occurred
Insert Into ResNow_TrailerCache_Final 
	(	
		trailer_id,trailer_number,trailer_type1,trailer_type2,trailer_type3,trailer_type4,trailer_company
		,trailer_division,trailer_terminal,trailer_fleet,trailer_branch,trailer_owner,trailer_make,trailer_model
		,trailer_year,trailer_grossweight,trailer_tareweight,trailer_axles,trailer_height,trailer_length
		,trailer_width,trailer_licensestate,trailer_licensenumber,trailer_startdate,trailer_dateacquired
		,trailer_retiredate,trailer_DateStart,trailer_DateEnd,trailer_active,trailer_updated
	)
Select trailer_id
	,trailer_number
	,trailer_type1
	,trailer_type2
	,trailer_type3
	,trailer_type4
	,trailer_company
	,trailer_division
	,trailer_terminal
	,trailer_fleet
	,trailer_branch
	,trailer_owner
	,trailer_make
	,trailer_model
	,trailer_year
	,trailer_grossweight
	,trailer_tareweight
	,trailer_axles
	,trailer_height
	,trailer_length
	,trailer_width
	,trailer_licensestate
	,trailer_licensenumber
	,trailer_startdate
	,trailer_dateacquired
	,trailer_retiredate
	,trailer_DateStart	-- this is when SCD2 change occurred; corresponds to DateEnd of previously active row
	,trailer_DateEnd	-- Armageddon
	,1
	,@ThisCycleTime
From ResNow_TrailerCache_Extract (NOLOCK)
Where trailer_id in (Select trailer_id from #TrailerSCD2Changes)

Drop table  #TrailerSCD2Changes

Set NOCOUNT Off

GO
GRANT EXECUTE ON  [dbo].[ResNow_UpdateTripletsAssets] TO [public]
GO
