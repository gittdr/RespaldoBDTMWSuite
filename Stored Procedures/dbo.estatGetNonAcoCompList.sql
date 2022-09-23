SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatGetNonAcoCompList]  @chars varchar(64), @login varchar(132)
AS
-- Returns the list of companies that are NOT in a given user's ACO list
-- exec estatGetNonAcoCompList  '', 'admin'  -- All non-aco companies
-- exec estatGetNonAcoCompList  'j', 'admin' -- non-aco companies whose id or name start with 'j' 
SET NOCOUNT ON

select b.cmp_id, b.cmp_name, b.cmp_address1, cmp_state, c.cty_name 
from company b, city c 
where (b.cmp_name like (@chars + '%' ) or b.cmp_id like (@chars + '%' )) 
and b.cmp_city = c.cty_code 
and b.cmp_id not in (select cmp_id from ESTATACOLIST d where d.login = @login) 
and cmp_active = 'Y' -- 35879	
order by cmp_name 
GO
GRANT EXECUTE ON  [dbo].[estatGetNonAcoCompList] TO [public]
GO
