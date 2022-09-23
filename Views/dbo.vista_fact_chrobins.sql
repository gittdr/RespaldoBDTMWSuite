SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

















CREATE view [dbo].[vista_fact_chrobins]
as
SELECT  o.ord_hdrnumber as Cliente, 
replace(i.ivh_ref_number,'#','') as referencia,
replace(replace(replace(replace(replace(replace((i.ivh_invoicenumber),'',''),'',''),'',''),'',''),'',''),'','') AS factura,
ivh_totalcharge as monto,
isnull((select sum(ivd_charge) from invoicedetail d where cht_itemcode ='ACXRUS'  and d.ivh_hdrnumber  = i.ivh_hdrnumber),0) as fuel,
v.rutapdf as tralixpdf,
(select replace(imaging, '172.16.136.34', '10.176.167.171') from VISTA_fe_generadas where invoice  =  i.ivh_invoicenumber) as imaging
FROM dbo.VISTA_fe_generadas v 
INNER JOIN  dbo.invoiceheader i ON v.invoice = i.ivh_invoicenumber 
INNER JOIN dbo.orderheader o ON  o.ord_number = v.orden 
--WHERE        (i.ivh_printdate  between DATEADD(dd,DATEDIFF(dd,1,GETDATE()),0) and DATEADD(ms,-3,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) ) 
--WHERE        (i.ivh_printdate  between dateadd(dd,-9,getdate()) and getdate()) 
WHERE i.ivh_printdate between '01/01/2019' and  '12/30/2020' and v.invoice in (
'C1122739')
and ivh_billto in ('CHROBINS') 
and i.ivh_invoicestatus='XFR'


GO
