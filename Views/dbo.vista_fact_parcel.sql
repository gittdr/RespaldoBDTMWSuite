SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[vista_fact_parcel]
as


SELECT Orden,Ruta,factura,monto,tralixpdffact,tralixxmlfact,tralixpdfNCT,tralixxmlNCT FROM (
SELECT ROW_NUMBER() over (PARTITION BY Orden ORDER BY TheLetter DESC) rowxs, 
TheLetter, Orden,Ruta,factura,monto,tralixpdffact,tralixxmlfact,tralixpdfNCT,tralixxmlNCT
 FROM (
SELECT SUBSTRING(ivh_invoicenumber,1,1) TheLetter  , o.ord_number as Orden, 
replace(o.ord_refnum,'#','') as Ruta,
i.ivh_invoicenumber AS factura,
CAST((ROUND(i.ivh_totalcharge, 0, 0)) AS INT) as monto,
V.rutapdf as tralixpdffact,
V.rutaxml as tralixxmlfact,
(select replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(MAX(rutapdf),'folio=A','folio='),'folio=B','folio='),'folio=C','folio='),'folio=D','folio='),'folio=E','folio='),'folio=F','folio='),'folio=J','folio='),'folio=G','folio='),'folio=H','folio='),'folio=K','folio='),'folio=L','folio='),'folio=Q','folio='),'folio=R','folio=') from VISTA_fe_generadas where rutapdf LIKE '%folio=_%' and orden  =  o.ord_number and serie='NCT') as tralixpdfNCT,
(select replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(MAX(rutaxml),'folio=A','folio='),'folio=B','folio='),'folio=C','folio='),'folio=D','folio='),'folio=E','folio='),'folio=F','folio='),'folio=J','folio='),'folio=G','folio='),'folio=H','folio='),'folio=K','folio='),'folio=L','folio='),'folio=Q','folio='),'folio=R','folio=') from VISTA_fe_generadas where rutaxml LIKE '%folio=_%' and orden  =  o.ord_number and serie='NCT') as tralixxmlNCT
FROM dbo.VISTA_fe_generadas v 
INNER JOIN  dbo.invoiceheader i ON v.invoice= i.ivh_invoicenumber
INNER JOIN dbo.orderheader o ON  o.ord_number = v.orden 
--WHERE        (i.ivh_printdate  between DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) and DATEADD(ms,-50,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) ) 
--WHERE        (i.ivh_printdate  between dateadd(dd,-10,getdate()) and getdate()) 
WHERE i.ivh_printdate between '01/01/2019' and  '12/30/2019' and v.orden in ( 

'695708',
'695450',
'700552',
'700890'

)
and ivh_billto in ('PARCEL') 
and i.ivh_invoicestatus='XFR'
) xh
) o WHERE rowxs = 1

GO
