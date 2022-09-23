SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[ida_GetSPLCandState] (
	@cty_code int
) as

select
	cty_SPLC, cty_state 
from city (nolock)
where
	cty_code = @cty_code

GO
GRANT EXECUTE ON  [dbo].[ida_GetSPLCandState] TO [public]
GO
