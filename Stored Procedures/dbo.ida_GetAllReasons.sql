SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









create proc [dbo].[ida_GetAllReasons] as

select
	abbr as Abbr,
	code as Code,
	[name] as Reason,
	cast
	(	case when
			(retired is null or not retired like 'Y%')
		then
			0
		else
			1
		end
	as bit) as fRetired
from labelfile (NOLOCK)
where
	labeldefinition='IDAReason'
order by retired, abbr






GO
GRANT EXECUTE ON  [dbo].[ida_GetAllReasons] TO [public]
GO
