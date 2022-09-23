SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[create_orderholdfromrulenew_sp] (@ruleid integer, @deconsolidateflg as char(1), @errormsg varchar(255) out)
AS
  
/*  
* Created: PTS 62183 - DJM - This proc takes a Hold ID and finds any Orders that match the hold requirements.  
*                                  It creates order holds as required.  
*  
*   PTS ??? - Added flag to indicated that the Order should be de-consolidated from a trip  
*   PTS 69754 - DJM - Add the Terminal to the Items that can be restricted on.  
*   PTS 72984 - DJM - modified to set the ohld_inactive_notify field on the OrderHold record to indicate that the Dispatcher  
*       be notified of an Inactive hold applied.  
*   PTS 76589 - DJM - remove references to the OrderHoldDefintionView  
*			PTS 84925 - DJM - modify to work with GI setting to determine the RevType field to use.
*   from Mindy Curnutt 2/23/15
We added this index to, not sure that it helped, but it’s there.
CREATE NONCLUSTERED INDEX [dk_ord_startdate_hansen] ON [dbo].[orderheader] 
(
                [ord_startdate] ASC
)
INCLUDE ( [ord_status],
[ord_originpoint],
[ord_destpoint],
[ord_billto],
[ord_revtype1],
[ord_hdrnumber],
[ord_dest_latestdate]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO

*/  
  
declare @startdate as datetime,  
 @enddate as datetime,  
 @parmcount as integer,  
 @exception   AS varchar(30),  
 @authorization  varchar(30),    
 @cbcode    varchar(30),    
 @effective_comment varchar(1000),   
 @terminate_comment varchar(1000),  
 @minord    integer,  
 @ordmov    integer,  
 @makeparmvalue   varchar(30),  
 @modelparmvalue   varchar(30),  
 @yearparmvalue   varchar(30),  
 @ordholdcount   integer,  
 @hldterminal   varchar(6),  
 @originvalue   varchar(100),  
 @destvalue   varchar(100),  
 @vinlist   varchar(8000),  
 @vincnt					integer,
	@unitchgtype			varchar(20),
	@unitchgqty				varchar(100),
	@storagestdate			datetime,
	@terminalField			int
		

   
  
  
if not exists (select 1 from OrderHoldDefinition where hld_id = @ruleid)  
begin  
 select @errormsg = 'Invalid Order Hold Definition ID: ' + CAST(@ruleid as varchar(20)) + ' could not be found.'  
 Return  
end   
  
select @terminalField = isNull(gi_integer1,1) from generalinfo where gi_name = 'HoldTerminalField'
if @terminalField is null
	select @terminalField = 1

Declare @ordref table (  
 ord_hdrnumber  integer   not null,  
 ref_type   varchar(6)  null,  
 ref_number   varchar(30)  null,  
 ref_table   varchar(18)  null,  
 ref_tablekey  integer   null)  
    
declare @ordlist table(  
 ord_hdrnumber  integer,  
 ord_status   varchar(6),  
 ord_startdate  datetime,  
 ord_endate   datetime)  
  
select @startdate = hld_startdate,  
 @enddate = hld_enddate,  
 @exception = hld_exception,  
 @authorization = hld_authorization,    
 @cbcode = hld_cbcode,    
 @effective_comment = hld_effective_comment,   
 @terminate_comment = hld_terminate_comment,  
	@hldterminal = hld_terminal,
	@unitchgtype = hld_unit_chgtype,
	@unitchgqty = hld_units_charged,
	@storagestdate = hld_storage_startdate
from OrderHoldDefinition where hld_id = @ruleid  
  
  
--select @makeparmvalue = isNull(Max(op.hparm_value),'UNKNOWN') from OrderHoldparms op where op.hld_id = @ruleid and op.hparm_type = 'MAKE'  
select @makeparmvalue = Max(op.hparm_value) from OrderHoldparms op where op.hld_id = @ruleid and op.hparm_type = 'MAKE'  
select @modelparmvalue = isNull(Max(op.hparm_value),'UNKNOWN') from OrderHoldparms op where op.hld_id = @ruleid and op.hparm_type = 'MODEL'  
select @yearparmvalue = isNull(Max(op.hparm_value),'UNKNOWN') from OrderHoldparms op where op.hld_id = @ruleid and op.hparm_type = 'YEAR'  
  
select @originvalue = Max(op.hparm_value) from OrderHoldparms op where op.hld_id = @ruleid and op.hparm_type = 'O'  
select @destvalue = Max(op.hparm_value) from OrderHoldparms op where op.hld_id = @ruleid and op.hparm_type = 'D'  
  
--select @makeparmvalue = isNull(@makeparmvalue,'UNKNOWN')  
select @modelparmvalue = isNull(@modelparmvalue,'UNKNOWN')  
select @yearparmvalue = isNull(@yearparmvalue,'UNKNOWN')  
  
select @vincnt = count(hparm_value) from OrderHoldparms where hld_id = @ruleid and hparm_type = 'VIN'  
  
-- Verify that there are parameters for the Hold Definition record. Since a Definition  
-- without parms will aply to EVERY Order, we cannot apply a definition to ANY order if   
-- no parms are defined.  
select @parmcount = 0  
select @parmcount = COUNT(*) from OrderHoldparms where hld_id = @ruleid and hparm_value is not null  
if @parmcount = 0   
 Begin  
    
  select @errormsg = 'No Parameters defined: ' + CAST(@ruleid as varchar(20)) + ' requires parameters to Apply Holds.'  
  Return  
 end  
    
declare @status table (abbr varchar(6) primary key)  
insert @status (abbr)  
select abbr from labelfile with (nolock) where labeldefinition = 'DispStatus' and abbr not in ('MST','CAN','REF') and isNull(retired,'N') = 'N' and code < 301  
  
-- build a list of candidate orders based on the Orderheader Referencenumbers.  
if @vincnt = 0
                insert into @ordlist  
                select distinct ord_hdrnumber,  
                 ord_status,    
                 ord_startdate,  
                 ord_dest_latestdate  
                from orderheader o with (nolock) inner join @status s on o.ord_status = s.abbr  
                inner join OrderHoldDefinition (nolock) on OrderHoldDefinition.hld_id = @ruleid   
                where o.ord_startdate < @enddate  
                 and not exists (select 1 from OrderHold with (nolock) where OrderHold.ord_hdrnumber = o.ord_hdrnumber and OrderHold.hld_id = @ruleid)  
                 and (@vincnt = 0) -- OR exists (select top 1 from referencenumber r join OrderHoldparms op on r.ref_number = op.hparm_value where r.ref_type = 'VIN' and r.ref_tablekey = o.ord_hdrnumber and r.ref_table = 'orderheader' and op.hld_id = OrderHoldDefinition.hld_id))
                
                 and ord_originpoint = IsNull(@originvalue,ord_originpoint)  
                 and ord_destpoint = IsNull(@destvalue,ord_destpoint)  
                 and (case @terminalField
					when 1 then ord_revtype1
					when 2 then ord_revtype2
					when 3 then ord_revtype3
					when 4 then ord_revtype4
					end  = ISNULL(OrderHoldDefinition.hld_terminal,ord_revtype1) or isnull(OrderHoldDefinition.hld_terminal,'UNK') = 'UNK')  

                and ord_billto = ISNULL(@makeparmvalue,ord_billto)  
                 and @modelparmvalue = case when @modelparmvalue <> 'UNKNOWN' then isNull((select isNull(r.ref_number,'UNKNOWN') from referencenumber r with (nolock)   
                   where r.ref_table = 'orderheader'   
                                and r.ref_tablekey = o.ord_hdrnumber   
                                and r.ref_type = 'MODEL'),'UNKNOWN')  
                   else 'UNKNOWN'  
                   end   
                 and @yearparmvalue = case when @yearparmvalue <> 'UNKNOWN' then isNull((select isNull(r.ref_number,'UNKNOWN') from referencenumber r with (nolock)   
                   where r.ref_table = 'orderheader'   
                                and r.ref_tablekey = o.ord_hdrnumber   
                                and r.ref_type = 'YEAR'),'UNKNOWN')  
                   else 'UNKNOWN'  
                   end   
 else
                insert into @ordlist  
                select distinct o.ord_hdrnumber,  
                 ord_status,    
                 ord_startdate,  
                 ord_dest_latestdate  
                from orderheader o with (nolock) inner join @status s on o.ord_status = s.abbr  
                --left join OrderHoldDefinition (nolock) on OrderHoldDefinition.hld_id = @ruleid   
                inner join OrderHoldDefinition (nolock) on OrderHoldDefinition.hld_id = @ruleid  
                inner join referencenumber r with (nolock) on o.ord_hdrnumber = r.ref_tablekey and r.ref_table = 'orderheader'
                inner join OrderHoldparms op with (nolock) on r.ref_number = op.hparm_value and OrderHoldDefinition.hld_id = op.hld_id
                where o.ord_startdate < @enddate  
                 and not exists (select 1 from OrderHold with (nolock) where OrderHold.ord_hdrnumber = o.ord_hdrnumber and OrderHold.hld_id = @ruleid)  
                 --and exists (select top 1 ref_id from referencenumber r join OrderHoldparms op on r.ref_number = op.hparm_value where r.ref_type = 'VIN' and r.ref_tablekey = o.ord_hdrnumber and r.ref_table = 'orderheader' and op.hld_id = OrderHoldDefinition.hld_id)
                
                  and ord_originpoint = IsNull(@originvalue,ord_originpoint)  
                 and ord_destpoint = IsNull(@destvalue,ord_destpoint)  
                 and (case @terminalField
						when 1 then ord_revtype1
						when 2 then ord_revtype2
						when 3 then ord_revtype3
						when 4 then ord_revtype4
						end  = ISNULL(OrderHoldDefinition.hld_terminal,ord_revtype1) or isnull(OrderHoldDefinition.hld_terminal,'UNK') = 'UNK')  

                and ord_billto = ISNULL(@makeparmvalue,ord_billto)  
                 and @modelparmvalue = case when @modelparmvalue <> 'UNKNOWN' then isNull((select isNull(r.ref_number,'UNKNOWN') from referencenumber r with (nolock)   
                   where r.ref_table = 'orderheader'   
                                and r.ref_tablekey = o.ord_hdrnumber   
                                and r.ref_type = 'MODEL'),'UNKNOWN')  
                   else 'UNKNOWN'  
                   end   
                 and @yearparmvalue = case when @yearparmvalue <> 'UNKNOWN' then isNull((select isNull(r.ref_number,'UNKNOWN') from referencenumber r with (nolock)   
                   where r.ref_table = 'orderheader'   
                                and r.ref_tablekey = o.ord_hdrnumber   
                                and r.ref_type = 'YEAR'),'UNKNOWN')  
                   else 'UNKNOWN'  
                   end    
                   
  
-- Deconsolidated Orders from loads, if necessary  
--if exists (select 1 from generalinfo where gi_name = 'OrderHoldAutoDeconsolidate' and gi_string1 = 'Y')  
if @deconsolidateflg = 'Y'  
 begin  
  
  select @minord = min(ord_hdrnumber)  
  from @ordlist o  
  where o.ord_status in (select abbr from labelfile with (nolock) where labeldefinition = 'DispStatus' and code < 220)  
  
  While @minord > 0   
   begin  
        
    select @ordmov = mov_number from orderheader where ord_hdrnumber = @minord  
      
    exec DeconsolidateOrder_sp @minord, @ordmov, @errormsg  
     
    select @minord = isNull(min(ord_hdrnumber),0)  
    from @ordlist o  
    where o.ord_status in (select abbr from labelfile with (nolock) where labeldefinition = 'DispStatus' and code < 220)   
     and ord_hdrnumber > @minord  
  
   end  
 end  
  
  
/*  
* The remaining Orders in the Temp table require a Hold record for the passed Hold ID. Orders with a Planned (or Dispatched)  
*  status need the 'Active' flag off ('N') so that a Dispatcher can review if the Hold is required or not.  
*/  
Insert into OrderHold (hld_id,   
 ord_hdrnumber,   
 ohld_active,   
 ohld_startdate,   
 ohld_enddate,   
 ohld_exceptioncode,   
 ohld_authid,   
 ohld_cbcode,   
 ohld_effective_comment,   
 ohld_terminate_comment,   
 ohld_export_pending,   
 ohld_status,  
	ohld_inactive_notify, 
	ohld_unit_chgtype, 
	ohld_units_charged,
	ohld_storage_startdate)
select @ruleid,  
 o.ord_hdrnumber,  
 'Y',  
 @startdate ,  
 @enddate,  
 @exception,  
 @authorization,    
 @cbcode,    
 @effective_comment,   
 @terminate_comment,  
 'Y',  
 'CH',  
	'N',
	@unitchgtype,
	@unitchgqty,
	@storagestdate
from @ordlist o  
where o.ord_status in (select abbr from labelfile with (nolock) where labeldefinition = 'DispStatus' and code < 220)  
 and not exists (select 1 from OrderHold where orderhold.hld_id = @ruleid and orderhold.ord_hdrnumber = o.ord_hdrnumber)  
  
  
Insert into OrderHold (hld_id, ord_hdrnumber, ohld_active, ohld_startdate, ohld_enddate, ohld_exceptioncode,   
 ohld_authid,   
	ohld_cbcode, ohld_effective_comment, ohld_terminate_comment, ohld_export_pending, ohld_status,ohld_inactive_notify, 
	ohld_unit_chgtype, 
	ohld_units_charged,
	ohld_storage_startdate)
select @ruleid,  
 ord_hdrnumber,  
 'N',  
 @startdate ,  
 @enddate,  
 @exception,  
 @authorization,    
 @cbcode,    
 @effective_comment,   
 @terminate_comment,  
 'N',  
 'CH',  
	'Y',
	@unitchgtype,
	@unitchgqty,
	@storagestdate
from @ordlist o  
where o.ord_status in (select abbr from labelfile with (nolock) where labeldefinition = 'DispStatus' and code < 301 and code >= 220)  
 and not exists (select 1 from OrderHold where orderhold.hld_id = @ruleid and orderhold.ord_hdrnumber = o.ord_hdrnumber)  
  
  
select @ordholdcount = count(*) from OrderHold where hld_id = @ruleid  
select @errormsg = 'OrderHold records created: ' + isNull(CAST(@ordholdcount as varchar(20)),'Error')  
 

GO
GRANT EXECUTE ON  [dbo].[create_orderholdfromrulenew_sp] TO [public]
GO
