SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROC [dbo].[SSRS_RB_MB_OperationOnly_01] 

(@reprintflag VARCHAR(10),@MasterBillId int,@billdate datetime,@taxacc varchar(6),@ivs_number int)
AS

select 
    isnull(ivh.ord_hdrnumber,-1) 'ord_hdrnumber'
	, ivh.ivh_invoicenumber  'Invoice Header Invoice Number'
	, ivh.ivh_hdrnumber 
	, ivh.ivh_billto 'Invoice Header Bill To'
	, bc.cmp_name 'Invoice Header Bill To Name'
	, bc.cmp_address1 'Invoice Header Bill To Add1'
	, bc.cmp_address2 'Invoice Header Bill To Add2'
	, bcty.cty_name 'Invoice Header Bill To City'
	, bcty.cty_state 'Invoice Header Bill To State'
	, bc.cmp_zip 'Invoice Header Bill To Zip'
	, ivh.ivh_shipper
	, shipcmp.cmp_name 'Invoice Header Shipper Name'
	, shipcmp.cmp_address1 'Invoice Header Shipper Add1'
	, shipcmp.cmp_address2 'Invoice Header Shipper Add2'
	, shipcty.cty_name 'Invoice Header Shipper City'
	, shipcty.cty_state 'Invoice Header Shipper State'
	, shipcmp.cmp_zip 'Invoice Header Shipper Zip'
	, ivh.ivh_consignee
	, concmp.cmp_name 'Invoice Header Consignee Name'
	, concmp.cmp_address1 'Invoice Header Consignee Add1'
	, concmp.cmp_address2 'Invoice Header Consignee Add2'
	, concty.cty_name 'Invoice Header Consignee City'
	, concty.cty_state 'Invoice Header Consignee State'
	, concmp.cmp_zip 'Invoice Header Consignee Zip'
	, ivh.ivh_totalcharge
	, ivh.ivh_shipdate
	, ivh.ivh_deliverydate
	, ivh.ivh_revtype1
    , IsNull(CASE  WHEN UPPER(@reprintflag) = 'REPRINT' THEN ISNULL(mb.MasterBillSystemControlId, mb.MasterBillId) ELSE @MasterBillId END, '') 'ivh_mbnumber'
    , IsNull(CASE  WHEN UPPER(@reprintflag) = 'REPRINT' THEN ivh.ivh_billdate WHEN @billdate = '01/01/1950' THEN ivh.ivh_billdate ELSE @billdate END, '') 'ivh_billdate'
	, ivd.ivd_quantity
	, IsNull(ivd.ivd_unit, '') 'ivd_unit' 
	, IsNull(ivd.ivd_rate, 0) 'ivd_rate'
	, IsNull(ivd.ivd_rateunit, '') 'ivd_rateunit'
	, ivd.ivd_charge
	, cht.cht_description
	, cht.cht_primary
	, cmd.cmd_name
	, IsNull(ivd_description, '') 'ivd_description'
	, ivd.ivd_type
	, ivd_sequence
	, IsNull(stp.stp_number, -1) 'stp_number'
	, ivh.ivh_charge
	, ivd.cht_basisunit
	, @taxacc 'tax_acc'
	, ivd.cht_itemcode
	, ref_po_v = isnull((select top 1 ref_number from referencenumber where referencenumber.ord_hdrnumber = ivh.ord_hdrnumber and ref_type = 'PO/V#'), '')
	, ref_ship_tick = isnull((select top 1 ref_number from referencenumber where referencenumber.ord_hdrnumber = ivh.ord_hdrnumber and ref_type = 'RFTKT'), '')
	, ref_bol = isnull((select top 1 ref_number from referencenumber where referencenumber.ord_hdrnumber = ivh.ord_hdrnumber and ref_type = 'LPBL'), '')
	, ivs.ivs_terms 'Invoice selection Terms'
	, ivs.ivs_logocompanyloc as 'Invoice Selection Company Location'
	, ivs.ivs_logocompanyname as 'Invoice Selection Company Name'
	, ivs.ivs_remittocompanyloc as 'Invoice Selection  RemitTo Location'
	, ivs.ivs_remittocompanyname as 'Invoice Selection RemitTo Name'
from MasterBill mb
    inner join MasterBillInvoice mbi on mb.MasterBillId = mbi.MasterBillId
        inner join InvoiceHeader ivh on mbi.ivh_hdrnumber = ivh.ivh_hdrnumber
            inner join InvoiceDetail ivd on ivh.ivh_hdrnumber = ivd.ivh_hdrnumber
	            left outer join stops stp on ivd.stp_number = stp.stp_number 
	            left outer join  commodity cmd on ivd.cmd_code = cmd.cmd_code
	        inner join company bc on bc.cmp_id = ivh.ivh_billto
	            inner join city bcty on bcty.cty_code = bc.cmp_city
	        inner join company shipcmp on shipcmp.cmp_id = ivh.ivh_shipper
	            inner join city shipcty on shipcty.cty_code = shipcmp.cmp_city
	        inner join company concmp on concmp.cmp_id = ivh.ivh_consignee
	            inner join city concty on concty.cty_code = concmp.cmp_city	
	        inner join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
	        left outer join orderheader ord on ivh.ord_hdrnumber = ord.ord_hdrnumber  
	        left outer join invoiceselection ivs on ivs.ivs_number = @ivs_number         
Where ISNULL(mb.MasterBillSystemControlId, mb.MasterBillId) = @MasterBillId
ORDER BY [Invoice Header Shipper City], [ord_hdrnumber], ivd_sequence



GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_MB_OperationOnly_01] TO [public]
GO
