SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [dbo].[vista_fact_werner_oo]
as

SELECT Orden,factura,referencia,inicio_del_viaje,Importe,#_remolque,fin_de_viaje,fecha_factura,tralixpdffact,imaging FROM (
SELECT ROW_NUMBER() over (PARTITION BY Orden ORDER BY TheLetter DESC) rowxs, 
TheLetter,Orden,factura,referencia,inicio_del_viaje,Importe,#_remolque,fin_de_viaje,fecha_factura,tralixpdffact,imaging
 FROM (
SELECT SUBSTRING(ivh_invoicenumber,1,1) TheLetter  , o.ord_number as Orden, 
replace(replace(replace(replace(replace(replace(((i.ivh_invoicenumber)),'A','TDRT'),'C','TDRT'),'E','TDRT'),'G','TDRT'),'H','TDRT'),'M','TDRT') AS factura,
replace(o.ord_refnum,'#','') as referencia,
format(i.ivh_shipdate,'yyyy-MM-dd') as inicio_del_viaje,
CAST((ROUND(i.ivh_totalcharge, 0, 0)) AS INT) as Importe,
replace(i.ivh_trailer,'WER,','') as #_remolque,
format(i.ivh_deliverydate,'yyyy-MM-dd') as fin_de_viaje,
format(i.ivh_billdate,'yyyy-MM-dd') as fecha_factura,
V.rutapdf as tralixpdffact,
(select  top 1 replace(imaging, '172.16.136.34', '10.176.167.171') from VISTA_fe_generadas where orden  =  o.ord_number) as imaging 
FROM dbo.VISTA_fe_generadas v 
INNER JOIN  dbo.invoiceheader i ON v.invoice= i.ivh_invoicenumber
INNER JOIN dbo.orderheader o ON  o.ord_number = v.orden 
--WHERE        (i.ivh_printdate  between DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) and DATEADD(ms,-50,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) ) 
--WHERE        (i.ivh_printdate  between dateadd(dd,-8,getdate()) and getdate()) 
WHERE i.ivh_printdate between '01/01/2019' and  '12/30/2025' and v.invoice in ( 
Select [Orden] from Pepe_OrdenesCargaPortales where Billto = 'WERNER')
and ivh_billto in ('WERNER') 
and i.ivh_invoicestatus='XFR'
) xh
) o WHERE rowxs = 1

GO
