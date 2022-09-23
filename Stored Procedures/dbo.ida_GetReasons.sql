SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









create proc [dbo].[ida_GetReasons] as

select
	code as Code,
	[name] as Reason
from labelfile (NOLOCK)
where
	labeldefinition='IDAReason'
	and
	(
		retired is null
		or
		not retired like 'Y%'
	)
order by abbr








GO
GRANT EXECUTE ON  [dbo].[ida_GetReasons] TO [public]
GO
