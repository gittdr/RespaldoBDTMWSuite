SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_get_update_status_from_sid]
	(@ref varchar(6),
	 @sid varchar(30), 
	 @trp_id varchar(20),
	 @ord_startdate datetime,
	 @max_update_status varchar(6),
	 @@ord_number varchar(12) OUTPUT, 
	 @@ord_hdrnumber int OUTPUT,
	 @@updateflag char(1) OUTPUT,
	 @@updatemsg varchar(50) OUTPUT,
	 @@ord_status varchar(6) OUTPUT)
as

/*******************************************************************************************************************  
  Object Description:
  dx_get_update_status_from_sid

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
  09/14/2016   David Wilks      100494       freight lines duplicating
********************************************************************************************************************/

declare @v_mov int, @v_ordstatus varchar(6), @v_ordinvstatus varchar(6), @v_orddispcode int, 
		@v_maxdispcode int, @v_includecancel varchar(6),@v_ordbookedby varchar(20)

declare @v_billto varchar(8), @etp_OverrideMaxUpdateStatus varchar(6), @ord_order_source varchar(6)

select @v_billto = etp_CompanyID, @etp_OverrideMaxUpdateStatus = IsNull(etp_OverrideMaxUpdateStatus, 'UNK')
	from edi_tender_partner where etp_partnerId = @trp_id
if @etp_OverrideMaxUpdateStatus <> 'UNK'
	set @max_update_status = @etp_OverrideMaxUpdateStatus 
	
declare @updateManualOrder int
exec @updateManualOrder = dx_GetUpdateManualOrderSetting

declare @EDIBookedByAccept varchar(30)
set @EDIBookedByAccept = 'N'
select @EDIBookedByAccept = gi_string1 from generalinfo where gi_name = 'EDIBookedByAccept'

select @v_includecancel = case isnull(@@updateflag,'') when 'C' then 'CAN' else 'XXX' end

select @ref = NULLIF(@ref,''), @@ord_number = '', @@ord_hdrnumber = 0, @@updateflag = 'N', @@updatemsg = ''

select top 1 @@ord_number = isnull(ord_number,'')
     , @@ord_hdrnumber = isnull(orderheader.ord_hdrnumber,0)
     , @v_mov = isnull(mov_number, 0)
     , @v_ordstatus = isnull(ord_status,'')
     , @v_ordinvstatus = isnull(ord_invoicestatus,'')
     , @v_ordbookedby = isnull(ord_bookedby,'')
	 , @ord_order_source = 'EDI'
  from orderheader
 inner join referencenumber
    on ref_tablekey = orderheader.ord_hdrnumber
   and ref_table = 'orderheader'
 where referencenumber.ref_number = @sid
   and referencenumber.ref_type = ISNULL(@ref,referencenumber.ref_type)
--   and referencenumber.ref_sid = 'Y'
   and ord_status not in (@v_includecancel,'FOR','REF')
--   and abs(datediff(mm, ord_startdate, @ord_startdate)) < 7
   and ((ord_order_source = 'EDI'
   and ord_editradingpartner = @trp_id))
 order by orderheader.ord_hdrnumber desc
 
select @@ord_status = isnull(@v_ordstatus,'')

if isnull(@v_mov, 0) = 0
begin
	select top 1 @@ord_number = isnull(ord_number,'')
	     , @@ord_hdrnumber = isnull(orderheader.ord_hdrnumber,0)
	     , @v_mov = isnull(mov_number, 0)
	     , @v_ordstatus = isnull(ord_status,'')
	     , @v_ordinvstatus = isnull(ord_invoicestatus,'')
	  from orderheader
	 inner join referencenumber
	    on ref_tablekey = orderheader.ord_hdrnumber
	   and ref_table = 'orderheader'
	 where referencenumber.ref_number = @sid
	   and referencenumber.ref_type = ISNULL(@ref,referencenumber.ref_type)
--	   and referencenumber.ref_sid = 'Y'
	   and ord_status not in ('CAN','FOR','REF')
	   and ((abs(datediff(mm, ord_startdate, @ord_startdate)) < 2
	   and orderheader.ord_editradingpartner is null)			--AROSS|NS88103
	   and (ord_billto = @v_billto and IsNull(@v_billto,'') > ''))	--67254
	 order by orderheader.ord_hdrnumber desc
	
	select @@ord_status = isnull(@v_ordstatus,'')
	
	if isnull(@v_mov, 0) = 0
		select @@updateflag = 'X'
		     , @@updatemsg = 'Active order cannot be found in TMWSuite'
	else
	begin	--PTS 67254
		if (select count(1) from edi_tender_partner where etp_partnerId = @trp_id and etp_CompanyID = @v_billto) > 0 
			AND @v_billto <> 'UNKNOWN'
			begin
				SELECT @@updatemsg = 'Existing order not created via EDI.Update Allowed.'
				IF @updateManualOrder = 1
				begin
					UPDATE orderheader    SET ord_editradingpartner = @trp_id, ord_order_source = 'EDI'
						WHERE ord_number = @@ord_number
					set @@updateflag = 'U'
					return 1
				end	
				else
					select @@updateflag = 'X'
					 ,@@updatemsg = 'Existing Order not created by LTSL.Update halted'
			end

				   
	end
end
else
begin
	if @@ord_status = 'CAN'
	begin
		select @@updateflag = 'Y'
		     , @@updatemsg = 'Order has been cancelled; acceptance will re-activate'
		return 1
	end
	
	if (select count(1) from orderheader where mov_number = @v_mov) > 1
	begin
		select @@updateflag = 'C'
		     , @@updatemsg = 'Order has been consolidated with other orders'
		return 1
	end

	if (select count(distinct mov_number) from stops WITH (NOLOCK) WHERE ord_hdrnumber = @@ord_hdrnumber) > 1
	begin
		select @@updateflag = 'C'
		     , @@updatemsg = 'Order has been cross-docked'
		return 1
	end

	if @v_ordbookedby not in('TMWDX','DX','IMPORT')  and @@updateflag <> 'X' and @EDIBookedByAccept <> 'Y' and IsNull(@ord_order_source,'') = 'EDI'
	begin
		select @@updateflag = 'Y'
			  ,@@updatemsg
			   = 'Order exists in TMW and update will be permitted.'
		return 1
	end
			  
	if @v_ordinvstatus = 'PPD'
		select @@updateflag = 'I'
		     , @@updatemsg = 'Order is already invoiced in TMWSuite'
	else
	begin
		if @v_ordstatus IN ('PLN','DSP')
		begin
			if (select top 1 lgh_outstatus from legheader where ord_hdrnumber = @@ord_hdrnumber order by lgh_number) = 'STD'
				select @v_ordstatus = 'STD'
		end
		select @v_maxdispcode = code
		  from labelfile
		 where labeldefinition = 'DispStatus'
	  	   and abbr = @max_update_status
		select @v_orddispcode = code
		  from labelfile
		 where labeldefinition = 'DispStatus'
		   and abbr = @v_ordstatus
		if @v_maxdispcode < @v_orddispcode
			select @@updatemsg = 'Order is not allowed to be automatically updated'
		else
			select @@updateflag = 'Y'
			     , @@updatemsg = 'Order exists in TMWSuite and can be updated'
	end
end

return 1

GO
GRANT EXECUTE ON  [dbo].[dx_get_update_status_from_sid] TO [public]
GO
