SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- Receives a string for comparison and returns either info for ONE company or a list of companies
-- based on whether the string is to be matched exactly with company id or matched LIKE company id or name  
Create procedure [dbo].[estatGetCompInfo]   @type varchar(12), @compstring varchar(30)   
AS
-- 080109: modified the 'exact' branch so it doesn't cause estat service (GetCompanyLocations) errors.
--         and limit rows to 25
SET NOCOUNT ON

if @type = 'exact' -- returns info for 1 specific company whose id matches the string 
	select top 1 cmp_id, isnull(cmp_name,'') as cmp_name, isnull(cmp_address1,'') as cmp_address1,  cty_name, cty_state, isnull(cmp_zip,'') as cmp_zip 
  	from company, city where cmp_id = @compstring AND cmp_city = cty_code and cmp_active = 'Y'     
	order by cmp_name 
else
if @type = 'likenameorid' -- returns list of companies whose name OR id is LIKE the string, orders by name
begin
	select top 25 cmp_id, isnull(cmp_name,'') as cmp_name, isnull(cmp_address1,'') as cmp_address1, isnull(cmp_state,'') as cmp_state, cty_name, cty_state, isnull(cmp_zip,'') as cmp_zip 
  	from company, city where cmp_city = cty_code 	
	and cmp_active = 'Y' 
	and ((cmp_name like @compstring + '%') 
             or (cmp_id like @compstring + '%' ))        
	order by cmp_name 
end
else
if @type = 'likename' -- returns list of companies whose NAME is LIKE the string, orders by name 
begin
	select top 25 cmp_id, isnull(cmp_name,'') as cmp_name, isnull(cmp_address1,'') as cmp_address1, isnull(cmp_state,'') as cmp_state, cty_name, cty_state, isnull(cmp_zip,'') as cmp_zip 
  	from company, city where cmp_city = cty_code 
	and cmp_active = 'Y' 
	and (cmp_name like @compstring + '%' )
	order by cmp_name
end
else
if @type = 'likeid' -- returns list of companies whose ID is LIKE the string, orders by id
begin
	--select top 25 cmp_id, isnull(cmp_name,'') as cmp_name, isnull(cmp_address1,'') as cmp_address1, isnull(cmp_state,'') as cmp_state, cty_name, cty_state, isnull(cmp_zip,'') as cmp_zip 
	select cmp_id, isnull(cmp_name,'') as cmp_name, isnull(cmp_address1,'') as cmp_address1, isnull(cmp_state,'') as cmp_state, cty_name, cty_state, isnull(cmp_zip,'') as cmp_zip 
	--select distinct cmp_id, cmp_name, cmp_address1, cmp_state, cty_name, cty_state, cmp_zip -- ORIGINAL 
  	from company, city where cmp_city = cty_code 	
	and cmp_active = 'Y' 
	and (cmp_id like @compstring + '%' )        
	order by cmp_id 
end
GO
GRANT EXECUTE ON  [dbo].[estatGetCompInfo] TO [public]
GO
