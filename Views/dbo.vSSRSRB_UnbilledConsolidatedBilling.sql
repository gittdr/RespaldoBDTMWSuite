SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[vSSRSRB_UnbilledConsolidatedBilling]


as 
/**
 *
 * NAME:
 * dbo.vSSRSRB_UnbilledConsolidatedBilling
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Unbilled view 
 
 *
**************************************************************************

Sample call


select * from vSSRSRB_UnbilledConsolidatedBilling


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Unbilled items
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created SSRS version of this view
 **/




select 
      ord.ord_hdrnumber as 'Order Header Number', 
      ord.mov_number as 'Move Number',
      ord.ord_shipper as 'Shipper',
      shpcmp.cmp_name as 'Shipper Name',
      ord.ord_consignee as 'Consignee',
      shpcmp.cmp_name as 'Consignee Name',
      ord.ord_startdate as 'Ship Date',
      dateadd(dd,0,datediff(dd,0,ord.ord_startdate)) as 'Ship Date Only',
      ord.ord_completiondate as 'Delivery Date',
      dateadd(dd,0,datediff(dd,0,ord.ord_completiondate)) as 'Delivery Date Only',
      ord.ord_totalcharge 'Revenue',
      'AVL' as 'InvoiceStatus', 
      'NI' as 'Invoice Number',
      ord.ord_billto as 'Bill To ID', 
      'Bill To' = (select Top 1 Company.cmp_name from Company (NOLOCK) where ord.ord_billto = Company.cmp_id), 
      ord.ord_revtype1 as 'RevType1',
      'RevType1 Name' = IsNull((select name from labelfile (NOLOCK)where labelfile.abbr = ord.ord_revtype1 and labeldefinition = 'RevType1'),''),
      ord.ord_revtype2 as 'RevType2',
      'RevType2 Name' = IsNull((select name from labelfile  (NOLOCK)where labelfile.abbr = ord.ord_revtype2 and labeldefinition = 'RevType2'),''),
      ord.ord_revtype3 as 'RevType3',
      'RevType3 Name' = IsNull((select name from labelfile  (NOLOCK)where labelfile.abbr = ord.ord_revtype3 and labeldefinition = 'RevType3'),''),
      ord.ord_revtype4 as 'RevType4',
      'RevType4 Name' = IsNull((select name from labelfile  (NOLOCK) where labelfile.abbr = ord.ord_revtype4 and labeldefinition = 'RevType4'),'')

from orderheader ord with(nolock) 
      inner join company shpcmp  with(nolock) on shpcmp.cmp_id = ord.ord_shipper
      inner join company concmp with(nolock)  on concmp.cmp_id = ord.ord_consignee
      
      
where 
      ord_status = 'CMP' and 
      ord_hdrnumber not in (
                                          select stp.ord_hdrnumber from invoicedetail ivd with(nolock) 
                                                left join stops stp  with(nolock) on stp.stp_number = ivd.stp_number
                                          where stp.ord_hdrnumber > 0
                                      ) 
      

union

select 
      stp.ord_hdrnumber as 'Order Header Number', 
      ivh.mov_number as 'Move Number',
      ivh.ivh_shipper as 'Shipper',
      shpcmp.cmp_name as 'Shipper Name',
      ivh.ivh_consignee as 'Consignee',
      shpcmp.cmp_name as 'Consignee Name',
      ivh.ivh_shipdate as 'Ship Date',
      dateadd(dd,0,datediff(dd,0,ivh.ivh_shipdate)) as 'Ship Date Only',
      ivh.ivh_deliverydate as 'Delivery Date',
      dateadd(dd,0,datediff(dd,0,ivh.ivh_deliverydate)) as 'Delivery Date Only',
      ivh.ivh_totalcharge 'Revenue',
      ivh.ivh_invoicestatus as 'InvoiceStatus', 
      ivh.ivh_invoicenumber as 'Invoice Number',      
      ivh_billto as 'Bill To ID',
      'BillTo' = (select Top 1 Company.cmp_name from Company  with(nolock)  where ivh.ivh_billto = Company.cmp_id), 
      ivh_revtype1 as 'RevType1',
      'RevType1 Name' = IsNull((select name from labelfile  with(nolock) where labelfile.abbr = ivh_revtype1 and labeldefinition = 'RevType1'),''),
      ivh_revtype2 as 'RevType2',
      'RevType2 Name' = IsNull((select name from labelfile   with(nolock) where labelfile.abbr = ivh_revtype2 and labeldefinition = 'RevType2'),''),
      ivh_revtype3 as 'RevType3',
      'RevType3 Name' = IsNull((select name from labelfile with(nolock)  where labelfile.abbr = ivh_revtype3 and labeldefinition = 'RevType3'),''),
      ivh_revtype4 as 'RevType4',
      'RevType4 Name' = IsNull((select name from labelfile   with(nolock)  where labelfile.abbr = ivh_revtype4 and labeldefinition = 'RevType4'),'')

from invoiceheader ivh with(nolock) 
      inner join invoicedetail ivd  with(nolock) on ivd.ivh_hdrnumber = ivh.ivh_hdrnumber 
      left join stops stp  with(nolock) on stp.stp_number = ivd.stp_number
      inner join company shpcmp  with(nolock) on shpcmp.cmp_id = ivh.ivh_shipper
      inner join company concmp  with(nolock) on concmp.cmp_id = ivh.ivh_consignee
      
where stp.ord_hdrnumber > 0 and ivh.ivh_invoicestatus <> 'XFR'


GO
GRANT SELECT ON  [dbo].[vSSRSRB_UnbilledConsolidatedBilling] TO [public]
GO
