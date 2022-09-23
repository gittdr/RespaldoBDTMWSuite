SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE view [dbo].[vista_fact_proteak_oo]
as
SELECT  o.ord_hdrnumber as Orden, 
i.ivh_remark as Comentarios,
replace(o.ord_refnum,'#','') as referencia,
replace(replace(replace((i.ivh_invoicenumber),'A',''),'B',''),'C','') AS factura,
v.rutapdf as tralixpdffact,
v.rutaxml as tralixxmlfact,
(select  top 1 replace(imaging, '172.16.136.34', '10.176.167.171') from VISTA_fe_generadas where orden  =  o.ord_number) as imaging 
FROM dbo.VISTA_fe_generadas v 
INNER JOIN  dbo.invoiceheader i ON v.invoice = i.ivh_invoicenumber 
INNER JOIN dbo.orderheader o ON  o.ord_number = v.orden 
--WHERE        (i.ivh_printdate  between DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) and DATEADD(ms,-50,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) ) 
--WHERE        (i.ivh_printdate  between dateadd(dd,-1,getdate()) and getdate()) 
WHERE i.ivh_printdate between '01/01/2019' and  '12/30/2020' and v.invoice in ( 
--'A1127235',
--'A1127238',
--'A1127239',
--'A1127241',
--'B1127244',
--'A1127246',
--'A1127619',
'A1127625')
 and ivh_billto in ('PROTEAK') 
and i.ivh_invoicestatus='XFR'

GO
