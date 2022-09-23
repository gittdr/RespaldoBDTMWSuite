SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[vista_invoicesperuser]

as

SELECT     ivh_billto, ivh_invoicestatus, ivh_user_id1, ivh_invoicenumber, ivh_billdate, YEAR(ivh_billdate) AS anio, MONTH(ivh_billdate) AS mes, DATEPART(ww, ivh_billdate) 
                      AS semana
FROM         invoiceheader
WHERE     (YEAR(ivh_billdate) > 2012) AND (ivh_invoicestatus NOT IN ('CAN', 'AVL', 'NTP', 'RTP')) AND (YEAR(ivh_billdate) <= YEAR(GETDATE()))
GO
