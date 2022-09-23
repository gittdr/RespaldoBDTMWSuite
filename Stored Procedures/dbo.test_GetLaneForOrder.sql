SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[test_GetLaneForOrder] (
	@ordnum varchar(50)
) as

declare @legnum int

select
	@legnum=lga.lgh_number
from legheader_active as lga (NOLOCK)
inner join orderheader as ord (NOLOCK)
on ord.ord_hdrnumber = lga.ord_hdrnumber
where ord.ord_number=@ordnum

create table #templanes (laneid int, LaneName varchar(200), specificity int, Radius int)
insert #templanes 
select * from core_fncGetLanesForLeg (@legnum)
select
	@ordnum as OrderNum,
	tl.LaneId as Lane,
	tl.LaneName as LaneName
from #tempLanes as tl
drop table #templanes

GRANT  EXECUTE  ON [dbo].[test_GetLaneForOrder]  TO [public]
GO
