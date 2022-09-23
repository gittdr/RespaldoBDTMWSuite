SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create proc [dbo].[validaterecruitcity_sp] (
@p_city varchar(40),
@p_state varchar(6),
@p_count int output,
@p_citycode int output)

as

set nocount on 

select @p_count = count(cty_code)
from city
where cty_name = ltrim(rtrim(@p_city))
and cty_state = @p_state 

if @p_count = 1
begin
	-- return values entered
	select @p_citycode = cty_code		
	from city 
	where cty_name = ltrim(rtrim(@p_city))
	and cty_state = @p_state
end
else
begin
	select @p_citycode = 0	
end

set nocount off

GO
GRANT EXECUTE ON  [dbo].[validaterecruitcity_sp] TO [public]
GO
