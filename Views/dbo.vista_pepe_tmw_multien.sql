SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [dbo].[vista_pepe_tmw_multien]
as

SELECT Orden,factura,tralixpdffact,tralixxmlfact FROM (
SELECT ROW_NUMBER() over (PARTITION BY Orden ORDER BY TheLetter DESC) rowxs, 
TheLetter,Orden,factura,tralixpdffact,tralixxmlfact
 FROM (
SELECT SUBSTRING(ivh_invoicenumber,1,1) TheLetter  , o.ord_hdrnumber as Orden, 
i.ivh_invoicenumber AS factura,
V.rutapdf as tralixpdffact,
v.rutaxml as tralixxmlfact
FROM dbo.VISTA_fe_generadas v 
INNER JOIN  dbo.invoiceheader i ON v.invoice= i.ivh_invoicenumber
INNER JOIN dbo.orderheader o ON  o.ord_number = v.orden 
--WHERE        (i.ivh_printdate  between DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) and DATEADD(ms,-50,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) ) 
WHERE        (i.ivh_printdate  between dateadd(dd,-7,getdate()) and getdate()) 
--WHERE i.ivh_printdate between '01/01/2019' and  '12/30/2019' and v.orden in ( 
--676273)
and ivh_billto in ('MULTIEN') 
and i.ivh_invoicestatus='XFR'
) xh
) o WHERE rowxs = 1

GO
