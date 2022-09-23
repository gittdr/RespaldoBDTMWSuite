SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatAddtoAcoList] @login Varchar(132), @acocompid Varchar(50) 
-- Adds a specific company to an estat user's aco list
-- exec estatAddtoAcoList 'admin', '11'
AS
SET NOCOUNT ON
declare @retcode int
select @retcode = 0 
if exists (select cmp_id from company where cmp_id = @acocompid)
begin
	if not exists (select cmp_id from ESTATACOLIST where login = @login and cmp_id = @acocompid)
	begin
		-- insert estataco select @usercompid, @acocompid, cmp_name, cmp_address1, cmp_city, cmp_state from company where @acocompid = cmp_id 
		insert ESTATACOLIST select @login, @acocompid 
            end
	else select @retcode = 2 -- entry already in the estataco table
end
else select @retcode = 1  --compay does not exists in db
select @retcode as retcode
GO
GRANT EXECUTE ON  [dbo].[estatAddtoAcoList] TO [public]
GO
