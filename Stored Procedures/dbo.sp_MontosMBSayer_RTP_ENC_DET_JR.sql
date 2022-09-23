SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para revisar los monto de las facturas de sayer detalle encabezado
--DROP PROCEDURE sp_MontosMBSayer_RTP_ENC_DET_JR
--GO

-- exec sp_MontosMBSayer_RTP_ENC_DET_JR

CREATE PROCEDURE [dbo].[sp_MontosMBSayer_RTP_ENC_DET_JR] 
AS


SET NOCOUNT ON
DECLARE @ld_Total_encabezado	Dec(10,2),
		@ld_Subtotal_encabezado Dec(10,2),
		@ld_Iva_encabezado		Dec(10,2),
		@ld_Ret_encabezado		Dec(10,2),
		@ld_Total_detalle		Dec(10,2), 
		@ld_Subtotal_detalle	Dec(10,2),
		@ld_Casetas_detalle		Dec(10,2),
		@ld_Iva_detalle			Dec(10,2),
		@ld_Ret_detalle			Dec(10,2)

DECLARE @TTResultados TABLE(
		Total_encabezado	Dec(10,2) null,
		Subtotal_encabezado Dec(10,2) null,
		Iva_encabezado		Dec(10,2) null,
		Ret_encabezado		Dec(10,2) null,
		Total_detalle		Dec(10,2) null,
		Subtotal_detalle	Dec(10,2) null,
		Casetas_detalle		Dec(10,2) null,
		Iva_detalle			Dec(10,2) null,
		Ret_detalle			Dec(10,2) null)


--total encabezado
select @ld_Total_encabezado		= sum(ivh_totalcharge) from invoiceheader where ivh_billto = 'SAYER' and ivh_mbstatus = 'RTP'

-- subtotal encabezado
select @ld_Subtotal_encabezado	= sum(ivh_charge) from invoiceheader where ivh_billto = 'SAYER' and ivh_mbstatus = 'RTP'

-- iva encabezado
select @ld_Iva_encabezado		= sum(ivh_taxamount1) from invoiceheader where ivh_billto = 'SAYER' and ivh_mbstatus = 'RTP'

-- retencion encabezado
select @ld_Ret_encabezado		= sum(ivh_taxamount2) from invoiceheader where ivh_billto = 'SAYER' and ivh_mbstatus = 'RTP'





-- total detalle
select @ld_Total_detalle = sum(ivd_charge) from invoicedetail where ivh_hdrnumber in (
select right(ivh_invoicenumber,6) from invoiceheader where ivh_billto = 'SAYER' and ivh_mbstatus = 'RTP'  )

-- subtotal detalle
select @ld_Subtotal_detalle = sum(ivd_charge) from invoicedetail where ivh_hdrnumber in (
select right(ivh_invoicenumber,6) from invoiceheader where ivh_billto = 'SAYER' and ivh_mbstatus = 'RTP'  )
and cht_itemcode not in( 'TOLL','CAS','GST', 'PST')


-- iva detalle
select @ld_Iva_detalle = sum(ivd_charge) from invoicedetail where ivh_hdrnumber in (
select right(ivh_invoicenumber,6) from invoiceheader where ivh_billto = 'SAYER' and ivh_mbstatus = 'RTP'  )
and cht_itemcode in( 'GST')

-- retención detalle
select @ld_Ret_detalle = sum(ivd_charge) from invoicedetail where ivh_hdrnumber in (
select right(ivh_invoicenumber,6) from invoiceheader where ivh_billto = 'SAYER' and ivh_mbstatus = 'RTP'  )
and cht_itemcode in( 'PST')


-- casetas detalle
select @ld_Casetas_detalle = sum(ivd_charge) from invoicedetail where ivh_hdrnumber in (
select right(ivh_invoicenumber,6) from invoiceheader where ivh_billto = 'SAYER' and ivh_mbstatus = 'RTP'  )
and cht_itemcode in( 'TOLL','CAS')


Insert @TTResultados (Total_encabezado, Subtotal_encabezado, Iva_encabezado, Ret_encabezado, Total_detalle, Subtotal_detalle, Casetas_detalle	, Iva_detalle, Ret_detalle)
values(@ld_Total_encabezado, @ld_Subtotal_encabezado, @ld_Iva_encabezado, @ld_Ret_encabezado, @ld_Total_detalle, @ld_Subtotal_detalle, @ld_Casetas_detalle, @ld_Iva_detalle, @ld_Ret_detalle   )



select * from @TTResultados
GO
