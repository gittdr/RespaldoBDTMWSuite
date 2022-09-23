SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 3661 - Tax not defaulting when destination is changed

CREATE PROC [dbo].[get_statecode_from_cmpcode_sp] (@CmpId	VarChar(12))
As

declare @cmp_city int, @cmp_state varchar(6)

select @cmp_state = cmp_state, @cmp_city = cmp_city
from company where cmp_id = @CmpId

if isnull(@cmp_state,'XX') = 'XX'  /*to handle the fact that state is populated with XX*/
	select @cmp_state = cty_state 
	from city
	where (city.cty_code = @cmp_city)

select @cmp_state


GO
GRANT EXECUTE ON  [dbo].[get_statecode_from_cmpcode_sp] TO [public]
GO
