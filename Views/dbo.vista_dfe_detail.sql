SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE    VIEW [dbo].[vista_dfe_detail]
AS
SELECT     ivh_invoicenumber, 
	SUM(abs(ivd_quantity)) AS quantity, 
	ivd_unit, 
	descripcion, 
	SUM(ivd_rate) AS rate, 
	SUM(ivd_charge) AS charge, 
	ISNULL(MAX(tasa_iva), 0)  AS tasa_iva,
	 ISNULL(MAX(tasa_ret), 0) AS tasa_ret, 
	SUM(iva_monto) AS iva_monto, 
	SUM(ret_monto) AS ret_monto
	FROM         dbo.VISTA_TMW_detail
	GROUP BY ivh_invoicenumber, 
	ivd_unit, 
	descripcion




GO
