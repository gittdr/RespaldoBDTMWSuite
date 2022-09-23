SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[test_DumpRecData] (
	@ordnum varchar(50)
) as

declare @legnum int
declare @idOverride int

select
	@legnum=lga.lgh_number
from legheader_active as lga (NOLOCK)
inner join orderheader as ord (NOLOCK)
on ord.ord_hdrnumber = lga.ord_hdrnumber
where ord.ord_number=@ordnum

select
	@idOverride=idOverride
from ida_Override as io (NOLOCK)
where
	io.lgh_number=@legnum
order by io.idOverride

select
	io.idOverride as RecId,
	io.idCarrierRecommendation as Recommended,
	io.curValueRecommendation as Value,
	io.ValueErrorRecommendation as [Error],
	io.sComments as Comments
from ida_Override as io (NOLOCK)
where io.idOverride=@idOverride

select
	iod.idOverride as RecId,
	iod.rank as Rank,
	iod.powerid as [Power],
	sum(iod.curValue) as TotalValue
from ida_OverrideDetail as iod (NOLOCK)
where iod.idOverride=@idOverride
group by iod.idOverride, iod.rank, iod.powerid
order by iod.idOverride, iod.rank, iod.powerid

select
	iod.idOverride as RecId,
	iod.rank as Rank,
	iod.powerid as [Power],
	iod.sComponentName as Evaluator,
	iod.curValue as Value,
	iod.ValueError as [Error]
from ida_OverrideDetail as iod (NOLOCK)
where iod.idOverride=@idOverride
order by iod.idOverride, iod.rank, iod.idOverrideDetail

GRANT  EXECUTE  ON [dbo].[test_DumpRecData]  TO [public]
GO
