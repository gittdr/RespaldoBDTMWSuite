SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











































CREATE view [dbo].[vista_fact_liver_import_oportunidad]
as

SELECT  i.ivh_invoicenumber AS Factura,
replace(replace(replace(replace(replace((v.rutaxml),'folio=A','folio='),'folio=B','folio='),'folio=C','folio='),'folio=D','folio='),'folio=E','folio=')as RutaXML, 
v.orden as Orden,
i.ivh_billto as Bill_to,
v.serie as Serie,
i.tar_tariffitem as Tipo,
i.ivh_printdate
FROM dbo.VISTA_fe_generadas v 
INNER JOIN  dbo.invoiceheader i ON v.invoice = i.ivh_invoicenumber 
INNER JOIN dbo.orderheader o ON  o.ord_number = v.orden 
WHERE        (i.ivh_printdate  between DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) and DATEADD(ms,-2,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) ) 
--WHERE        (i.ivh_printdate  between dateadd(dd,-4,getdate()) and getdate()) 
--WHERE i.ivh_printdate > '2019-12-10 18:16:17.383'
--WHERE i.ivh_printdate between '02/22/2019' and  '04/23/2019' and v.orden in (
--663838)
and ivh_billto in ('FACTUMLV','SETRALIV','SFERALIV','GLOBALIV','LIVERPOL','LIVERTIJ','LIVERDED') 
and i.tar_tariffitem IN ('IMPORTACIONE','SENCILLOS','FULL','SENCILLO','DEDICADO','REPARTOS')
and i.ivh_invoicestatus='XFR'
and v.serie='TDRL' 
GO
