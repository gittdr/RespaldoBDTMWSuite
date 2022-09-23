SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dwTriplets_Maintain0]
	(
		@Datasource varchar(32)
		,@LastTimestamp timestamp = NULL
		,@ThisTimestamp timestamp = NULL
	)

AS

set NOCOUNT ON

-- we keep a running history of Triplets information to support Orphan handling
-- therefore, no truncate table statement

create table #TempMoves0
	(
		mov_number int
	)

Insert into #TempMoves0 (mov_number)
	-- get move from any orders that have been modified
	select mov_number
	from orderheader OH with (NOLOCK) 
	Where OH.timestamp between @LastTimestamp AND @ThisTimestamp

Insert into #TempMoves0 (mov_number)
	-- get move from any legs that have been modified
	select mov_number
	from legheader LH with (NOLOCK) 
	Where LH.timestamp between @LastTimestamp AND @ThisTimestamp

Insert into #TempMoves0 (mov_number)
	-- get move from any stops that have been modified
	select mov_number
	from stops ST with (NOLOCK) 
	Where ST.timestamp between @LastTimestamp AND @ThisTimestamp

Insert into #TempMoves0 (mov_number)
	-- get move from any paydetails that have been modified (for Lane Analysis updating)
	select mov_number
	from paydetail PD with (NOLOCK) 
	Where PD.dw_timestamp between @LastTimestamp AND @ThisTimestamp
	AND ISNULL(PD.mov_number,0) <> 0

Insert into #TempMoves0 (mov_number)
	-- get move from any invoiceheaders that have been modified 
	select mov_number
	from invoiceheader IH with (NOLOCK) 
	Where IH.timestamp between @LastTimestamp AND @ThisTimestamp
	AND IsNull(IH.mov_number,0) <> 0

Insert into #TempMoves0 (mov_number)
	-- get move from any invoicedetails that have been modified (for Lane Analysis updating)
	select orderheader.mov_number
	from invoicedetail invoicedetail with (NOLOCK) join orderheader orderheader with (NOLOCK) on invoicedetail.ord_hdrnumber = orderheader.ord_hdrnumber
	Where invoicedetail.dw_timestamp between @LastTimestamp AND @ThisTimestamp

Insert into #TempMoves0 (mov_number)
	-- get move from any round trips that have been modified
	Select rt_move
	From dw_RTLegCache RTLC with (NOLOCK)
	Where RTLC.dw_timestamp between @LastTimestamp AND @ThisTimestamp

-- added for Energy content
If Exists (Select T0.name from sys.tables T0 where T0.name = 'OilFieldReadings')
BEGIN
	Insert into #TempMoves0 (mov_number)
		select OH.mov_number
		from orderheader OH with (NOLOCK) 
		Where EXISTS
			(
				Select T1.SN
				from OilFieldReadings T1 with (NOLOCK)
				where OH.ord_hdrnumber = T1.ord_hdrnumber
				AND T1.dw_timestamp between @LastTimestamp AND @ThisTimestamp
			)
END

Select distinct mov_number into #TempMoves from #TempMoves0

drop table #TempMoves0

-- new code here to make sure we capture ALL impacted Legs
-- this iterates thru the data identifying all the moves impacted
-- by these changes; set up this way to step thru all the branches
-- of a complex cross-dock situation

declare @NewMoves int
set @NewMoves = 1

While NOT @NewMoves = 0
begin

	select distinct ord_hdrnumber
	into #TheOrders
	from stops S2 with (NOLOCK) 
	where mov_number in 
		(
			Select mov_number from #TempMoves
		)
	AND ord_hdrnumber <> 0

	select distinct mov_number
	into #TheMoves
	from stops S2 with (NOLOCK) 
	where ord_hdrnumber in 
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

set @NewMoves = 1

-- follow the RT tree to get everything impacted

create table #TheRTStartLegs (rt_StartLeg int)
create table #TheMoves1 (mov_number int)

While NOT @NewMoves = 0
begin

	insert into #TheRTStartLegs (rt_StartLeg)
	select distinct rt_StartLeg
	from dw_RTLegCache S2 with (NOLOCK) 
	where rt_Move in 
		(
			Select mov_number from #TempMoves
		)

	insert into #TheMoves1 (mov_number)
	select distinct rt_Move as mov_number
	from dw_RTLegCache S2 with (NOLOCK) 
	where rt_StartLeg in 
		(
			Select rt_StartLeg from #TheRTStartLegs
		)

	Set @NewMoves = 
		(
			Select count(mov_number)
			From #TheMoves1
			Where NOT Exists (select mov_number from #TempMoves TM where TM.mov_number = #TheMoves1.mov_number)
		)

	Insert into #TempMoves (mov_number)
	Select mov_number
	From #TheMoves1
	Where NOT Exists (select mov_number from #TempMoves TM where TM.mov_number = #TheMoves1.mov_number)

	truncate table #TheRTStartLegs
	truncate table #TheMoves1
End

-- once we know all the MOVES impacted, we can ferret out the orphans & identify the Triplets
-- move orphan identification to the END of the process to make sure we pick up Orders that were BOOKED and CANCELLED between ETL Cycles

-- get the Triplets
-- 1. get ALL Move/Order Pairs
select distinct Datasource = @Datasource
,stops.mov_number
,stops.ord_hdrnumber
into #TempAllMovesOrders
from stops stops with (NOLOCK) 
left join orderheader orderheader with (NOLOCK) on stops.ord_hdrnumber = orderheader.ord_hdrnumber
where Exists (select mov_number from #TempMoves where stops.mov_number = #TempMoves.mov_number)
AND stops.ord_hdrnumber <> 0

-- 2. get ALL move/leg pairs 
select distinct Datasource = @Datasource
,stops.mov_number
,stops.lgh_number
into #TempAllMovesLegs
from stops stops with (NOLOCK)
where Exists (select mov_number from #TempMoves where stops.mov_number = #TempMoves.mov_number)

-- 3. assemble the move x leg x order triplets
Select Datasource = #TempAllMovesLegs.Datasource
,mov_number = #TempAllMovesLegs.mov_number
,lgh_number = #TempAllMovesLegs.lgh_number
,ord_hdrnumber = IsNull(#TempAllMovesOrders.ord_hdrnumber,-1*#TempAllMovesLegs.mov_number)
into #TempTripletList
from #TempAllMovesLegs left join #TempAllMovesOrders on #TempAllMovesLegs.mov_number = #TempAllMovesOrders.mov_number

-- 4. remove any Master Orders from the mix
delete from #TempTripletList where Exists 
	(
		select ord_hdrnumber 
		from orderheader OH with (NOLOCK) 
		where #TempTripletList.ord_hdrnumber = OH.ord_hdrnumber
		AND OH.ord_status = 'MST'
	)

Select Datasource
,mov_number
,lgh_number
,ord_hdrnumber
,Triplet_Status = 'Operational'
from #TempTripletList

-- cleanup
drop table #TempMoves
drop table #TempAllMovesOrders
drop table #TempAllMovesLegs
drop table #TempTripletList
drop table #TheRTStartLegs
drop table #TheMoves1

Set NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[dwTriplets_Maintain0] TO [public]
GO
