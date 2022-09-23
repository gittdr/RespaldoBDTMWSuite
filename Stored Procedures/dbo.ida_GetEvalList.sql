SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[ida_GetEvalList]
as

select
	idIDAEval,
	sClassName,
	sEvalName,
	sCategory,
	iOrder,
	iDisplayOrder,
	fEnabled
from ida_IDAEval (NOLOCK)
order by iOrder

GO
GRANT EXECUTE ON  [dbo].[ida_GetEvalList] TO [public]
GO
