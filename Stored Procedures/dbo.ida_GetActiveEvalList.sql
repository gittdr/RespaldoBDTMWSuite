SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[ida_GetActiveEvalList]
as

select
	sEvalName,
	sCategory,
	sFileName,
	sClassName,
	iOrder,
	iDisplayOrder
from ida_IDAEval (NOLOCK)
where fEnabled > 0
order by iOrder

GO
GRANT EXECUTE ON  [dbo].[ida_GetActiveEvalList] TO [public]
GO
