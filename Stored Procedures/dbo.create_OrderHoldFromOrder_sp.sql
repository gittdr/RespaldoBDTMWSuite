SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[create_OrderHoldFromOrder_sp] (@ordhdr integer, @errormsg varchar(255) out)
AS

/*
*	Created: PTS 62183 - DJM - This proc takes a Hold ID and finds any Orders that match the hold requirements.
*
*		PTS 72984 - DJM - modified to set the ohld_inactive_notify field on the OrderHold record to indicate that the Dispatcher
*							be notified of an Inactive hold applied.
*
*		PTS 84419 - DJM - Add the ohld_export_pending field to the SQL to create an active Orderhold record so that EDI knows to send
*							a notification that the Order was placed on Hold
*
*		PTS 84925 - DJM - modify to work with GI setting to determine the RevType field to use.
*/

declare @startdate as datetime,
@enddate			datetime,
@parmcount			integer,
@exception			varchar(30),
@authorization		varchar(30),		
@cbcode				varchar(30),		
@effective_comment	varchar(1000),	
@terminate_comment	varchar(1000),
@minord				integer,
@ordmov				integer,
@unitchgtype			varchar(20),
@unitchgqty				varchar(100),
@storagestdate			datetime,
@terminalField			int


Declare @ordref table (
ord_hdrnumber		integer			not null,
ref_type			varchar(6)		null,
ref_number			varchar(30)		null,
ref_table			varchar(18)		null,
ref_tablekey		integer			null)
	
Declare @holdlist table(hld_id		integer		not null,
	ord_hdrnumber		integer					null)



if not exists (select 1 from orderheader where ord_hdrnumber = @ordhdr)
begin
	select @errormsg = 'Invalid Order: ' + CAST(@ordhdr as varchar(20)) + ' could not be found.'
	Return
end 

if exists (select 1 from orderheader where ord_hdrnumber = @ordhdr and ord_status in (Select abbr from labelfile where labeldefinition = 'DispStatus' and code > 300))
begin
	select @errormsg = 'Invalid action for Order: ' + CAST(@ordhdr as varchar(20)) + '. The Order is in a status that does NOT allow a hold to be applied.'
	Return
end 

select @terminalField = isNull(gi_integer1,1) from generalinfo where gi_name = 'HoldTerminalField'


--	Check both the Orderheader andthe FreightDetail referencenumbers. The Orderheader is where EDI will probably put them,
--  at least in the beginning. The Freightdetail is where they really belong - so make it work either way.
insert into @ordref
select o.ord_hdrnumber,
	ref_type,
	r.ref_number,
	ref_table,
	o.ord_hdrnumber
from orderheader o join referencenumber r with (nolock) on o.ord_hdrnumber = r.ref_tablekey and r.ref_table = 'orderheader'
where o.ord_hdrnumber = @ordhdr

insert into @ordref
select o.ord_hdrnumber,
	ref_type,
	r.ref_number,
	ref_table,
	o.ord_hdrnumber
from orderheader o join stops s with (nolock) on o.ord_hdrnumber = s.ord_hdrnumber and o.ord_hdrnumber = @ordhdr
	join freightdetail f with (nolock) on s.stp_number = f.stp_number 
	join referencenumber r with (nolock) on f.fgt_number = r.ref_tablekey and r.ref_table = 'freightdetail'



---- populate the table with the Hold Defintions that could be applicable to the Order.
insert into @holdlist
select hld_id,
	@ordhdr
from OrderHoldDefinition oh, orderheader o
where o.ord_hdrnumber = @ordhdr 
	and o.ord_startdate < oh.hld_enddate
	--and (o.ord_revtype1 = ISNULL(oh.hld_terminal,o.ord_revtype1) or oh.hld_terminal = 'UNK')
	and (case @terminalField
		when 1 then ord_revtype1
		when 2 then ord_revtype2
		when 3 then ord_revtype3
		when 4 then ord_revtype4
		end = oh.hld_terminal or oh.hld_terminal = 'UNK')
	and exists (select 1 from OrderHoldparms where OrderHoldparms.hld_id = oh.hld_id)


-- Remove HoldDefinitions that do not have a matching VIN - if they have that requirement
delete from h
from @holdlist h join OrderHoldparms op on h.hld_id = op.hld_id 
where op.hparm_type = 'VIN' OR op.hparm_type = 'V'
	and not exists (select 1 from @ordref o1 where op.hparm_type = o1.ref_type and op.hparm_value = o1.ref_number)
	
---- Remove HoldDefinitions that do not have a matching destination requirement
delete from h
from @holdlist h join OrderHoldparms op on h.hld_id = op.hld_id 
where op.hparm_type = 'D'
	and not exists (select 1 from orderheader o where o.ord_hdrnumber = h.ord_hdrnumber and o.ord_consignee = op.hparm_value)
	
 -- Remove HoldDefinitions that do not have a matching Origin requirement
delete from @holdlist
from @holdlist h join OrderHoldparms op on h.hld_id = op.hld_id 
where op.hparm_type = 'O'
	and not exists (select 1 from orderheader o where o.ord_hdrnumber = h.ord_hdrnumber and o.ord_originpoint = op.hparm_value)

---- Remove HoldDefinitions that do not have a matching Make requirement
--delete from h
--from @holdlist h join OrderHoldparms op on h.hld_id = op.hld_id 
--where op.hparm_type = 'MAKE'
--	and not exists (select 1 from @ordref o where o.ord_hdrnumber = h.ord_hdrnumber and o.ref_type = op.hparm_type and o.ref_number = op.hparm_value)

delete from h
from @holdlist h join OrderHoldparms op on h.hld_id = op.hld_id 
where op.hparm_type = 'MAKE'
	and not exists (select 1 from orderheader o where o.ord_hdrnumber = h.ord_hdrnumber and o.ord_billto = op.hparm_value)

---- Remove HoldDefinitions that do not have a matching Model requirement
delete from h
from @holdlist h join OrderHoldparms op on h.hld_id = op.hld_id 
where op.hparm_type = 'MODEL'
	and not exists (select 1 from @ordref o where o.ord_hdrnumber = h.ord_hdrnumber and o.ref_type = op.hparm_type and o.ref_number = op.hparm_value)


---- Remove HoldDefinitions that do not have a matching Year requirement
delete from h
from @holdlist h join OrderHoldparms op on h.hld_id = op.hld_id 
where op.hparm_type = 'YEAR'
	and not exists (select 1 from @ordref o where o.ord_hdrnumber = h.ord_hdrnumber and o.ref_type = op.hparm_type and o.ref_number = op.hparm_value)


-- Deconsolidated Orders from loads, if necessary
if exists (select 1 from generalinfo where gi_name = 'OrderHoldAutoDeconsolidate' and gi_string1 = 'Y')
begin

	select @minord = min(h.ord_hdrnumber)
	from @holdlist h join orderheader o on h.ord_hdrnumber = o.ord_hdrnumber
	where o.ord_status in (select abbr from labelfile with (nolock) where labeldefinition = 'DispStatus' and code < 220)

	While @minord > 0 
		begin
			select @ordmov = mov_number from orderheader where ord_hdrnumber = @minord
			
			exec DeconsolidateOrder_sp @minord, @ordmov, @errormsg
		
			select @minord = min(h.ord_hdrnumber)
			from @holdlist h join orderheader o on h.ord_hdrnumber = o.ord_hdrnumber
			where o.ord_status in (select abbr from labelfile with (nolock) where labeldefinition = 'DispStatus' and code < 220)
				and o.ord_hdrnumber > @minord

		end
end



/*
*	The remaining Orders in the Temp table require a Hold record for the passed Hold ID. Orders with a Planned (or Dispatched)
*		status need the 'Active' flag off ('N') so that a Dispatcher can review if the Hold is required or not.
*/
Insert into OrderHold (hld_id,
	ord_hdrnumber, 
	ohld_active, 
	ohld_startdate, 
	ohld_enddate, 
	ohld_exceptioncode, 
	ohld_authcode, 
	ohld_cbcode, 
	ohld_effective_comment, 
	ohld_terminate_comment, 
	ohld_inactive_notify, 
	ohld_unit_chgtype, 
	ohld_units_charged,
	ohld_storage_startdate,
	ohld_export_pending)
select h.hld_id,
	h.ord_hdrnumber,
	'Y',
	od.hld_startdate ,	
	od.hld_enddate,
	isNull(od.hld_exception,''),
	isNull(od.hld_authorization,''),		
	isNull(od.hld_cbcode,''),		
	od.hld_effective_comment,	
	isNull(od.hld_terminate_comment,''),
	'N',
	od.hld_unit_chgtype,
	od.hld_units_charged,
	od.hld_storage_startdate,
	'Y'
from @holdlist h join OrderHoldDefinition od on h.hld_id = od.hld_id join orderheader o on h.ord_hdrnumber = o.ord_hdrnumber
where o.ord_status in (select abbr from labelfile with (nolock) where labeldefinition = 'DispStatus' and code < 220)

if @@ERROR > 0 
	select @errormsg = @@ERROR

Insert into OrderHold (hld_id, 
	ord_hdrnumber, 
	ohld_active, 
	ohld_startdate, 
	ohld_enddate, 
	ohld_exceptioncode, 
	ohld_authcode, 
	ohld_cbcode, 
	ohld_effective_comment, 
	ohld_terminate_comment,
	ohld_inactive_notify, 
	ohld_unit_chgtype, 
	ohld_units_charged,
	ohld_storage_startdate,
	ohld_export_pending)
select h.hld_id,
	h.ord_hdrnumber,
	'N',
	od.hld_startdate ,	
	od.hld_enddate,
	isNull(od.hld_exception,''),
	isNull(od.hld_authorization,''),		
	isNull(od.hld_cbcode,''),		
	od.hld_effective_comment,	
	isNull(od.hld_terminate_comment,''),
	'Y',
	od.hld_unit_chgtype,
	od.hld_units_charged,
	od.hld_storage_startdate,
	'N'
from @holdlist h join OrderHoldDefinition od on h.hld_id = od.hld_id join orderheader o on h.ord_hdrnumber = o.ord_hdrnumber
where o.ord_status in (select abbr from labelfile with (nolock) where labeldefinition = 'DispStatus' and code < 301 and code >= 220)

if @@ERROR > 0 
	select @errormsg = @@ERROR


GO
GRANT EXECUTE ON  [dbo].[create_OrderHoldFromOrder_sp] TO [public]
GO
