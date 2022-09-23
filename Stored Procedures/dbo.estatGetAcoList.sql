SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatGetAcoList]  @chars varchar(64), @login varchar(132),  @count char(5), 
@sortby varchar(4) 
/*
 exec estatGetAcoList '', 'admin', '', ''    -- return all, sort by name
 exec estatGetAcoList '0', 'admin', '', ''  -- return only those with ids starting with '0', sort by name
 exec estatGetAcoList '01', 'admin', '', ''  -- return only those with ids starting with '0', sort by name
 exec estatGetAcoList '', 'admin', '', 'id' -- return all, sort by id
*/
AS
SET NOCOUNT ON

if @count = 'count'  -- return count of aco companies only
begin
	select count(*) acocount from ESTATACOLIST where login = @login
end
else
begin
if @sortby =  'id'  -- 2/15/07:
	select a.cmp_id, b.cmp_name, b.cmp_address1, cty_state, cty_name
	from ESTATACOLIST a, company b, city c 
	--where (a.aco_name like (@chars + '%' )  or a.cmp_id like (@chars + '%')  )
	where ( a.cmp_id like (@chars + '%')  )
	 and a.login = @login and a.cmp_id = b.cmp_id and b.cmp_city = cty_code 	
	order by a.cmp_id
            -- end 2/15/07
else  -- original: sort by name
	select a.cmp_id, b.cmp_name, b.cmp_address1, cty_state, cty_name
	from ESTATACOLIST a, company b, city c 
	where (b.cmp_name like (@chars + '%' )  or a.cmp_id like (@chars + '%')  ) and a.login = @login and a.cmp_id = b.cmp_id and b.cmp_city = cty_code 	
	order by b.cmp_name
end
GO
GRANT EXECUTE ON  [dbo].[estatGetAcoList] TO [public]
GO
