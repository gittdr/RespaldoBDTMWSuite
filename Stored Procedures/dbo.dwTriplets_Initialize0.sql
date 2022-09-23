SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dwTriplets_Initialize0]
	(
		@Datasource varchar(32)
		,@StartDateCutoff datetime = '19500101'
	)

AS

set NOCOUNT ON

-- Preload the dwTriplets table

If @StartDateCutoff > '19500101'
	begin
		set @StartDateCutoff = DATEADD(d,-30,@StartDateCutoff)
	end

-- 1. get ALL Move/Order Pairs
select distinct stops.mov_number
,stops.ord_hdrnumber
into #TempAllMovesOrders
from stops stops with (NOLOCK)
--inner join legheader legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number	-- use this to pre-screen obsolete triplets
left join orderheader orderheader with (NOLOCK) on stops.ord_hdrnumber = orderheader.ord_hdrnumber
where IsNull(orderheader.ord_startdate,stops.stp_arrivaldate) >= @StartDateCutoff
AND stops.ord_hdrnumber <> 0
--where orderheader.ord_status <> 'MST'	-- delete these later if necessary

-- 2. get ALL move/leg pairs 
select distinct stops.mov_number
,stops.lgh_number
into #TempAllMovesLegs
from stops stops with (NOLOCK)
--inner join legheader legheader with (NOLOCK) on stops.lgh_number = legheader.lgh_number	-- use this to pre-screen obsolete triplets
where stops.stp_arrivaldate >= @StartDateCutoff

-- 3. get all move x leg x order triplets
Select mov_number = #TempAllMovesLegs.mov_number
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

-- add to the dwTriplets table
--insert into dwTriplets (Datasource,mov_number,lgh_number,ord_hdrnumber,Triplet_Status)
select @Datasource
,mov_number
,lgh_number
,ord_hdrnumber
,'Operational'
from #TempTripletList

drop table #TempAllMovesOrders
drop table #TempAllMovesLegs
drop table #TempTripletList

Set NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[dwTriplets_Initialize0] TO [public]
GO
