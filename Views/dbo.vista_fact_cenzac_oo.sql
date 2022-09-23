SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[vista_fact_cenzac_oo]
as

SELECT Orden,factura,tralixxmlfact,tralixpdffact FROM (
SELECT ROW_NUMBER() over (PARTITION BY Orden ORDER BY TheLetter DESC) rowxs, 
TheLetter,Orden,factura,tralixxmlfact,tralixpdffact
 FROM (
SELECT SUBSTRING(ivh_invoicenumber,1,1) TheLetter  , o.ord_hdrnumber as Orden, 
i.ivh_invoicenumber AS factura,
V.rutaxml as tralixxmlfact,
V.rutapdf as tralixpdffact
FROM dbo.VISTA_fe_generadas v 
INNER JOIN  dbo.invoiceheader i ON v.invoice= i.ivh_invoicenumber
INNER JOIN dbo.orderheader o ON  o.ord_number = v.orden 
--WHERE        (i.ivh_printdate  between DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) and DATEADD(ms,-50,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) ) 
--WHERE        (i.ivh_printdate  between dateadd(dd,-20,getdate()) and getdate()) 
WHERE i.ivh_printdate between '01/01/2019' and  '12/30/2019' and v.orden in (
'674408',
'674078',
'675582',
'673428',
'673429',
'675743',
'676726',
'674853',
'677358',
'679341',
'680017',
'680479',
'679339',
'679342',
'679918',
'680018',
'680022',
'681608',
'681609',
'681610',
'682178',
'683301',
'683304',
'683307',
'683299',
'683305',
'676725',
'672579',
'679917',
'680081',
'680480',
'681668',
'681669',
'681973',
'682177',
'683300',
'679948'
)
and ivh_billto in ('CENZAC') 
and i.ivh_invoicestatus='XFR'
) xh
) o WHERE rowxs = 1
GO
