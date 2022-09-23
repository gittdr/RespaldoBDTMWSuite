SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[invoice_audit_report_sp](@ps_number varchar(20),@ps_retrieveby char(3))
as

/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/13/2007.01 ? PTS40188 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

begin
declare @ll_ord int,	
	@ll_inv int

if @ps_retrieveby = 'ALL'

 select 
	a.ivd_number,
	a.audit_sequence,
	a.audit_status,
	a.audit_user,
	a.audit_date,
	a.cht_itemcode,
	a.ivd_quantity,
	a.ivd_rate,
	a.ivd_charge,
	a.tar_number,
	a.ivh_hdrnumber,
	a.ord_hdrnumber,
	b.cht_description,
	c.tar_description,
	i.ivh_invoicenumber,
	o.ord_number,
	a.audit_app	
 --pts40188 jguo outer join conversion
 from  invoicedetailaudit a  LEFT OUTER JOIN  tariffheader c  ON  a.tar_number  = c.tar_number   
			LEFT OUTER JOIN  orderheader o  ON  a.ord_hdrnumber  = o.ord_hdrnumber   
			LEFT OUTER JOIN  invoiceheader i  ON  a.ivh_hdrnumber  = i.ivh_hdrnumber ,
	 chargetype b 
 where  a.cht_itemcode = b.cht_itemcode	

else if @ps_retrieveby = 'ORD'
begin
 select @ll_ord = ord_hdrnumber from orderheader where ord_number = @ps_number
 select 
	a.ivd_number,
	a.audit_sequence,
	a.audit_status,
	a.audit_user,
	a.audit_date,
	a.cht_itemcode,
	a.ivd_quantity,
	a.ivd_rate,
	a.ivd_charge,
	a.tar_number,
	a.ivh_hdrnumber,
	a.ord_hdrnumber,
	b.cht_description,
	c.tar_description,
	i.ivh_invoicenumber,
	o.ord_number,
	a.audit_app		
 --pts40188 jguo outer join conversion
 from invoicedetailaudit a  LEFT OUTER JOIN  tariffheader c  ON  a.tar_number  = c.tar_number   
			LEFT OUTER JOIN  orderheader o  ON  a.ord_hdrnumber  = o.ord_hdrnumber   
			LEFT OUTER JOIN  invoiceheader i  ON  a.ivh_hdrnumber  = i.ivh_hdrnumber ,
	  chargetype b 
 where  a.ord_hdrnumber = @ll_ord and
	a.cht_itemcode = b.cht_itemcode	 

end
else
 begin
  select @ll_inv = ivh_hdrnumber from invoiceheader where ivh_invoicenumber = @ps_number
  select 
	a.ivd_number,
	a.audit_sequence,
	a.audit_status,
	a.audit_user,
	a.audit_date,
	a.cht_itemcode,
	a.ivd_quantity,
	a.ivd_rate,
	a.ivd_charge,
	a.tar_number,
	a.ivh_hdrnumber,
	a.ord_hdrnumber,
	b.cht_description,
	c.tar_description,
	i.ivh_invoicenumber,
	o.ord_number,
	a.audit_app		
 --pts40188 jguo outer join conversion
 from  invoicedetailaudit a  LEFT OUTER JOIN  tariffheader c  ON  a.tar_number  = c.tar_number   
		LEFT OUTER JOIN  orderheader o  ON  a.ord_hdrnumber  = o.ord_hdrnumber   
		LEFT OUTER JOIN  invoiceheader i  ON  a.ivh_hdrnumber  = i.ivh_hdrnumber ,
	 chargetype b 
 where  a.ivh_hdrnumber = @ll_inv and
	a.cht_itemcode = b.cht_itemcode	

 end 


end
GO
GRANT EXECUTE ON  [dbo].[invoice_audit_report_sp] TO [public]
GO
