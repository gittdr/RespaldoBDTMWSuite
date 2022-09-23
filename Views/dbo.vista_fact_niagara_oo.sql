SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO















CREATE view [dbo].[vista_fact_niagara_oo]
as

SELECT Orden,factura,prindate,referencia,tralixxml,SUM(Num_lineas) Num_lineas FROM (
SELECT Orden,factura,prindate,referencia,tralixxml,Num_lineas FROM (
SELECT ROW_NUMBER() over (PARTITION BY Orden ORDER BY TheLetter DESC) rowxs, TheLetter,Orden,factura,prindate,referencia,tralixxml,Num_lineas FROM (
SELECT SUBSTRING(ivh_invoicenumber,1,1) TheLetter  , o.ord_hdrnumber as Orden, 
replace(replace(replace(replace(((i.ivh_invoicenumber)),'A',''),'C',''),'E',''),'G','') AS factura,
i.ivh_printdate AS prindate,
replace(o.ord_refnum,'#','') as referencia,
rutaxml as tralixxml,
ivd_quantity as Num_lineas
FROM dbo.VISTA_fe_generadas v 
INNER JOIN  dbo.invoiceheader i ON v.invoice= i.ivh_invoicenumber
INNER JOIN dbo.orderheader o ON  o.ord_number = v.orden 
INNER JOIN dbo.invoicedetail d ON d.ord_hdrnumber =  o.ord_number
WHERE        (i.ivh_printdate  between DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) and DATEADD(ms,-50,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) ) 
--WHERE        (i.ivh_printdate  between dateadd(dd,-2,getdate()) and getdate()) 
--WHERE i.ivh_printdate between '2019-01-19' and  '2019-12-21' and v.orden in (
--681238)
and ivh_billto in ('NIAGARA') 
and i.ivh_invoicestatus='XFR'
) xh
) o ) q
GROUP BY Orden,factura,prindate,referencia,tralixxml --WHERE rowxs = 1


GO
