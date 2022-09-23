SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para revisar los monto de las facturas de sayer
--DROP PROCEDURE sp_RevisaMontosMBSayer_RTP
--GO

-- exec sp_RevisaMontosMBSayer_RTP

create PROCEDURE [dbo].[sp_RevisaMontosMBSayer_RTP] 
AS


SET NOCOUNT ON

select distinct(ID.cht_itemcode) as Codigo, CT.cht_description as Descripción, sum(ID.ivd_charge) as Monto from invoicedetail ID, chargetype CT where ID.ivh_hdrnumber in (
select right(ivh_invoicenumber,6) from invoiceheader where ivh_billto = 'SAYER' and ivh_mbstatus = 'RTP' )  and ID.ivd_charge <> 0
and ID.cht_itemcode = CT.cht_itemcode
group by ID.cht_itemcode, CT.cht_description
order by 2






GO
