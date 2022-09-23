SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE view [dbo].[vista_fact_chrobinMEX_oo]
as
SELECT Orden,factura,referencia,tralixpdffact,tralixxmlfact,imaging FROM (
SELECT ROW_NUMBER() over (PARTITION BY Orden ORDER BY TheLetter DESC) rowxs, 
TheLetter,Orden,factura,referencia,tralixpdffact,tralixxmlfact,imaging
 FROM (
SELECT SUBSTRING(ivh_invoicenumber,1,1) TheLetter  , o.ord_number as Orden, 
(select replace(replace(replace(replace(replace(replace(MAX(invoice),'A',''),'B',''),'C',''),'D',''),'E',''),'F','') from VISTA_fe_generadas where orden  =  o.ord_number and serie='TDRT') as factura,
replace(o.ord_refnum,'#','') as referencia,
v.rutapdf as tralixpdffact,
v.rutaxml as tralixxmlfact,
(select  top 1 replace(imaging, '172.16.136.34', '10.176.167.171') from VISTA_fe_generadas where orden  =  o.ord_number) as imaging 
FROM dbo.VISTA_fe_generadas v 
INNER JOIN  dbo.invoiceheader i ON v.invoice= i.ivh_invoicenumber
INNER JOIN dbo.orderheader o ON  o.ord_number = v.orden 
--WHERE        (i.ivh_printdate  between DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) and DATEADD(ms,-50,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) ) 
--WHERE        (i.ivh_printdate  between dateadd(dd,-9,getdate()) and getdate()) 
WHERE i.ivh_printdate between '01/01/2019' and  '12/30/2020' and v.invoice in ( 
'A1129060 ',
'A1129061 ',
'A1129062 ',
'A1129063 ',
'A1129064 ',
'A1130720 ',
'A1130721 ',
'A1130722 ',
'A1129059')
 and ivh_billto in ('CHROBMEX') 
--and i.ivh_invoicestatus='XFR'
) xh
) o WHERE rowxs = 1

GO
