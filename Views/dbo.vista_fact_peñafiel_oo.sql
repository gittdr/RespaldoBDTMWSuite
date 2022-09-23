SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view [dbo].[vista_fact_peñafiel_oo]
as 

SELECT  o.ord_hdrnumber as Orden, 
replace(replace(replace(replace(replace(replace((i.ivh_invoicenumber),'A',''),'B',''),'C',''),'D',''),'E',''),'F','') AS factura,
(select replace(replace(replace(replace(replace(replace(replace(MAX(rutaxml),'folio=A','folio='),'folio=B','folio='),'folio=C','folio='),'folio=D','folio='),'folio=E','folio='),'folio=F','folio='),'folio=J','folio=') from VISTA_fe_generadas where rutaxml LIKE '%folio=_%' and orden  =  o.ord_hdrnumber and serie='TDRT') as tralixxmlfact
FROM dbo.VISTA_fe_generadas v 
INNER JOIN  dbo.invoiceheader i ON v.invoice = i.ivh_invoicenumber 
INNER JOIN dbo.orderheader o ON  o.ord_number = v.orden 
--WHERE        (i.ivh_printdate  between DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) and DATEADD(ms,-50,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) ) 
WHERE        (i.ivh_printdate  between dateadd(dd,-6,getdate()) and getdate()) 
--WHERE i.ivh_printdate between '01/01/2019' and  '12/30/2019' and v.orden in ( 
--662689
--)
and ivh_billto in ('PEÑAFIEL') 
and i.ivh_invoicestatus='XFR'

GO
