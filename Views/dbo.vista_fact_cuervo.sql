SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE  view [dbo].[vista_fact_cuervo]
as

SELECT Orden,factura,tralixpdffact,tralixxmlfact,imaging FROM (
SELECT Orden,factura,tralixpdffact,tralixxmlfact,imaging FROM (
SELECT ROW_NUMBER() over (PARTITION BY Orden ORDER BY TheLetter DESC) rowxs, TheLetter,Orden,factura,tralixpdffact,tralixxmlfact,imaging FROM (
SELECT SUBSTRING(ivh_invoicenumber,1,1) TheLetter  , o.ord_hdrnumber as Orden, 
replace(replace(replace(replace(((i.ivh_invoicenumber)),'A',''),'C',''),'E',''),'G','') AS factura,
rutapdf as tralixpdffact,
rutaxml as tralixxmlfact,
(select  top 1 replace(imaging, '172.16.136.34', '10.176.167.171') from VISTA_fe_generadas where orden  =  o.ord_number) as imaging 
FROM dbo.VISTA_fe_generadas v 
INNER JOIN  dbo.invoiceheader i ON v.invoice= i.ivh_invoicenumber
INNER JOIN dbo.orderheader o ON  o.ord_number = v.orden 
INNER JOIN dbo.invoicedetail d ON d.ord_hdrnumber =  o.ord_number
--WHERE        (i.ivh_printdate  between DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) and DATEADD(ms,-50,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) ) 
--WHERE        (i.ivh_printdate  between dateadd(dd,-6,getdate()) and getdate()) 
WHERE i.ivh_printdate between '01/30/2019' and  '09/30/2020' and v.invoice in (
'A1087759',
'A1087760',
'A1086983',
'A1087758')
and ivh_billto in ('CUERVO') 
--and i.ivh_invoicestatus='XFR'
) xh
) o ) q
GROUP BY Orden,factura,tralixpdffact,tralixxmlfact,imaging --WHERE rowxs = 1



GO
