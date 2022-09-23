SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/*
select * from EstatHistoricalOrdersViewTDR where billto = 'NIAGARA'
*/


create view [dbo].[EstatHistoricalOrdersViewTDR_audit_pilgrims] as 
select
 'TMWWF_ESTAT_HISTORICAL' as 'TMWWF_ESTAT_HISTORICAL',
 ord.ord_number,
 (select cmp_name from company where cmp_id = ord.ord_billto) 'BillTo', 
 ord.ord_billto 'BillToID',
    (select cmp_name from company where cmp_id = ord.ord_company) 'OrderBy',
    ord.ord_company 'OrderByID',  
 
 ord.ord_status 'DispStatus', 
 scompany.cmp_id 'PickupID',
 scompany.cmp_name 'PickupName',
 scity.cty_name 'PickupCity',
 scity.cty_state 'PickupState',
 ccompany.cmp_id 'ConsigneeID',
 ccompany.cmp_name 'ConsigneeName',
 ccity.cty_name 'ConsigneeCity',
 ccity.cty_state 'ConsigneeState',
 ord.ord_revtype1 'RevType1', ord.ord_revtype2 'RevType2', ord.ord_revtype3 'RevType3', ord.ord_revtype4 'RevType4',  
 ord.ord_hdrnumber,
 ord.ord_startdate 'StartDate', 
 ord.ord_completiondate 'EndDate',

 -------------------------------------------------------------------------------------------------------------------------------

 Referencia = ord_refnum,

 
 podsto =  

isnull(STUFF((SELECT '; ' + DocTypeName 

          FROM AllPaperworkView

          where OrderNumber = ord.ord_hdrnumber 

          and Required = 'Yes' and Received = 'No'

          FOR XML PATH('')), 1, 1, ''), 'OK'),
Estatus =
       
  
     case
	 when ord_invoicestatus = 'PPD' then  'Proceso'
     when ord_invoicestatus = 'AVL' then  'Proceso'
	 when ord_invoicestatus = 'XIN' then  'Auditoria' 
	 when ord_status        = 'CAN' then  'Cancelado' 
	 else ord_invoicestatus
	 end, 
	
	case when ord.ord_billto='pilgrims' then '<a href="https://69.20.92.116:8090/BitacoraPilgrims.aspx?lgh_header=' +cast ((select min(lgh_number) from legheader (nolock) where legheader.ord_hdrnumber = ord.ord_hdrnumber)as varchar(20))+'"  target="_blank">'
	+ isnull((select max(ref_number) from referencenumber ref where  ref.ref_table = 'orderheader' and  ref.ref_type = 'LPID' and ref.ref_tablekey = ord.ord_hdrnumber),ord.ord_refnum)  +'   </a>'  else ord.ord_refnum end as leg,

	 case when ord.ord_billto='pilgrims' then   isnull((select max(ref_number) from referencenumber ref where  ref.ref_table = 'orderheader' and  ref.ref_type = 'SID' and ref.ref_tablekey = Ord.ord_hdrnumber),'Fuera SDS')  else '' end as Ruta,

	 '<a href=" https://69.20.92.116:8090/RevisionEvidencias.aspx?ord_header=' +cast (( ord.ord_hdrnumber)as varchar(20))+'"  target="_blank">'+
	 
	 'Revision' +'   </a>'  as revisar,



	 ord_completiondate as FechaTermino,
	 ord_completiondate as FechaOrden


  
	   
	
from orderheader as ord
  left join invoiceheader i on ord.ord_hdrnumber = i.ord_hdrnumber
  join city as scity on ord.ord_origincity = scity.cty_code
  join company as scompany on ord.ord_originpoint = scompany.cmp_id
  join city as ccity on ord.ord_destcity = ccity.cty_code
  join company as ccompany on ord_destpoint = ccompany.cmp_id
  where ord.ord_status = 'CMP' and  year(ord_completiondate) >= 2018 
  and ord.ord_hdrnumber not in (select ord_hdrnumber from invoiceheader where ivh_invoicestatus  ='XFR')
  and ord_invoicestatus in ('XIN')
  and ord_billto in ('PILGRIMS')









GO
