SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [dbo].[vista_fact_palacio_oo]
as
SELECT Orden,factura,contrarecibo,tralixxmlfact FROM (
SELECT ROW_NUMBER() over (PARTITION BY Orden ORDER BY TheLetter DESC) rowxs, 
TheLetter,Orden,factura,contrarecibo,tralixxmlfact
 FROM (
SELECT SUBSTRING(ivh_invoicenumber,1,1) TheLetter  , o.ord_hdrnumber as Orden, 
(select replace(replace(replace(replace(MAX(invoice),'A',''),'B',''),'C',''),'D','') from VISTA_fe_generadas where orden  =  o.ord_hdrnumber and serie='TDRT') as factura,

--replace(replace(replace(replace(replace(replace((i.ivh_invoicenumber),'A',''),'B',''),'C',''),'D',''),'E',''),'F','') AS factura,
(select not_text  from notes where not_viewlevel='E' and nre_tablekey = o.ord_number) as contrarecibo,
(select replace(replace(replace(replace(replace(replace(replace(MAX(rutaxml),'folio=A','folio='),'folio=B','folio='),'folio=C','folio='),'folio=D','folio='),'folio=E','folio='),'folio=F','folio='),'folio=J','folio=') from VISTA_fe_generadas where rutaxml LIKE '%folio=_%' and orden  =  o.ord_hdrnumber and serie='TDRT') as tralixxmlfact
FROM dbo.VISTA_fe_generadas v 
INNER JOIN  dbo.invoiceheader i ON v.invoice= i.ivh_invoicenumber
INNER JOIN dbo.orderheader o ON  o.ord_number = v.orden 
--WHERE        (i.ivh_printdate  between DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0) and DATEADD(ms,-50,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),1)) ) 
--WHERE        (i.ivh_printdate  between dateadd(dd,-10,getdate()) and getdate()) 
WHERE i.ivh_printdate between '01/01/2019' and  '12/30/2019' and v.orden in ( 
624562,
622973,
622710,
624830,
620625,
622711
)
and ivh_billto in ('PALACIO') 
and i.ivh_invoicestatus='XFR'
) xh
) o WHERE rowxs = 1

GO
