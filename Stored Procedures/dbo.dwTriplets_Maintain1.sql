SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dwTriplets_Maintain1]
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
While NOT @NewMoves = 0
begin

	select distinct rt_StartLeg
	into #TheRTStartLegs
	from dw_RTLegCache S2 with (NOLOCK) 
	where rt_Move in 
		(
			Select mov_number from #TempMoves
		)

	select distinct rt_Move as mov_number
	into #TheMoves1
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

	drop table #TheRTStartLegs
	drop table #TheMoves1
End

-- include special code section for missing Empty Moves
Insert into #TempMoves (mov_number)
Select mov_number
from TMW_DWPrep.dbo.dwTriplets T0
where COALESCE(T0.ord_hdrnumber,0) < 1
AND T0.Triplet_Status = 'Operational'
AND NOT Exists
	(
		Select mov_number
		from stops T10
		where T0.mov_number = T10.mov_number
	)
;

-- non-orphan identification
select Datasource = @Datasource
,S1.mov_number
,L1.lgh_number						-- will be NULL if leg has been removed
,ord_hdrnumber = S2.ord_hdrnumber	
,ord_status = O1.ord_status			-- will be NULL if order has been removed
from stops S1 with (NOLOCK) 
inner join stops S2 with (NOLOCK) on S1.mov_number = S2.mov_number
left join legheader L1 with (NOLOCK) on S1.lgh_number = L1.lgh_number
-- join this on the S2 link because we need to break the S1.stp_number / S1.lgh_number dependence
left join orderheader O1 with (NOLOCK) on S2.ord_hdrnumber = O1.ord_hdrnumber
where Exists
	(
		Select T0.mov_number
		from #TempMoves T0
		where S1.mov_number = T0.mov_number
	)
AND S2.ord_hdrnumber <> 0
AND IsNull(O1.ord_status,'XXX') <> 'MST'

UNION

select Datasource = @Datasource
,S1.mov_number
,L1.lgh_number					-- will be NULL if leg has been removed
,ord_hdrnumber = -1 * S1.mov_number
,ord_status = 'MTMove'
from stops S1 with (NOLOCK) 
left join legheader L1 with (NOLOCK) on S1.lgh_number = L1.lgh_number
where Exists
	(
		Select T0.mov_number
		from #TempMoves T0
		where S1.mov_number = T0.mov_number
	)
AND NOT Exists
	(
		Select T10.stp_number
		from stops T10 with (NOLOCK)
		where S1.mov_number = T10.mov_number
		AND T10.ord_hdrnumber > 0
	)

UNION

select Datasource = @Datasource
,S1.mov_number
,L1.lgh_number							-- will be NULL if leg has been removed
,ord_hdrnumber = -1 * S1.mov_number
,ord_status = 'MTMove'
from #TempMoves S1
inner join TMW_DWPrep.dbo.dwTriplets T1 on S1.mov_number = T1.mov_number 
left join legheader L1 on T1.lgh_number = L1.lgh_number
where T1.Datasource = @Datasource
AND COALESCE(T1.ord_hdrnumber,0) < 1	-- empty move; no order
AND NOT Exists							-- gone; not in the stops table
	(
		Select T10.stp_number
		from stops T10 with (NOLOCK)
		where S1.mov_number = T10.mov_number
	)
;



-- cleanup
drop table #TempMoves

Set NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[dwTriplets_Maintain1] TO [public]
GO
