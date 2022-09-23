SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[estatGetLoadReqs_sp]
-- For a given commodity and event (LLD etc.):
--		Returns the default load requirements (ie requirements associated with that commodity and event) 
--      If company id is NOT supplied, returns the default load reqs that are not tied to any specific company  
--      If company id IS supplied, returns the above as well as requirements associated with that company  
	(
	@stoptype       varchar(32),  -- LLD, etc
	@compid 		varchar(32),
	@commodityid varchar(64)
	)
AS
SET NOCOUNT ON
declare @fgt_event varchar(32)  
set @fgt_event = (select fgt_event from eventcodetable where  abbr = @stoptype)
if @compid = '' or @compid = 'UNK' or @compid ='UNKNOWN'
begin
	select 
	'' company,  
	eventcodetable.name event,
	cmd_name commodity, -- @commodityid, 
	def_equip_type, l2.name name1, def_manditory, def_not, def_quantity, def_type, l1.name name2 
	from loadreqdefault, labelfile l1, labelfile l2,  commodity, eventcodetable  
	where (def_id = '' 
	or def_id = 'UNKNOWN' or def_id = 'UNK' or def_id is null) and (def_id_type = @fgt_event 
	or def_id_type = 'BOTH') and def_cmd_id = @commodityid and l1.abbr = def_type and l2.abbr = def_equip_type 
	and l2.labeldefinition = 'AssType' 
	and @commodityid = commodity.cmd_code 
	and (@stoptype = eventcodetable.abbr)
end
else
begin
	select 
	cmp_name company, -- @compid, 
	eventcodetable.name event,
	cmd_name commodity, -- @commodityid, 
	def_equip_type, l2.name name1, def_manditory, def_not, def_quantity, def_type, l1.name name2 
	from loadreqdefault, labelfile l1, labelfile l2, company, commodity, eventcodetable  
	where (def_id = @compid  or def_id = '' 
	or def_id = 'UNKNOWN' or def_id = 'UNK' or def_id is null) and (def_id_type = @fgt_event 
	or def_id_type = 'BOTH') and def_cmd_id = @commodityid and l1.abbr = def_type and l2.abbr = def_equip_type 
	and l2.labeldefinition = 'AssType' 
	and @compid = cmp_id 
	and @commodityid = commodity.cmd_code 
	and (@stoptype = eventcodetable.abbr)
	
end 

GO
GRANT EXECUTE ON  [dbo].[estatGetLoadReqs_sp] TO [public]
GO
