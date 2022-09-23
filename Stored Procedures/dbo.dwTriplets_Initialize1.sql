SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dwTriplets_Initialize1]
	(
		@Datasource varchar(32)
		,@StartDateCutoff datetime = '19500101'
	)

AS

set NOCOUNT ON

If @StartDateCutoff > '19500101'
	begin
		set @StartDateCutoff = DATEADD(d,-30,@StartDateCutoff)
	end

-- need to update Obsolete Triplets
select distinct mov_number 
into #TempMoves 
from stops stops with (NOLOCK)
where stops.stp_arrivaldate >= @StartDateCutoff

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
,L1.lgh_number
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

drop table #TempMoves

Set NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[dwTriplets_Initialize1] TO [public]
GO
