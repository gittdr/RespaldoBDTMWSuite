SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[conceptos] AS SELECT d.ivh_invoicenumber AS invoicenumberD, h.ivh_invoicenumber AS invoicenumberH, d.ivd_quantity, d.ivd_unit, d.descripcion, 
		CAST (d.ivd_charge AS NUMERIC(28,2)) AS importe, CAST (d.ivd_rate AS NUMERIC(28,2)) AS vUnitario, CASE ISNUMERIC(CAST (tasa_iva AS VARCHAR(255)))
																											WHEN 0 THEN 0
																											WHEN 1 THEN tasa_iva
																											END AS tasa_iva, 
		CASE ISNUMERIC(CAST (iva_monto AS VARCHAR (255)))
		WHEN 0 THEN 0
		WHEN 1 THEN iva_monto
		END AS iva_monto,  CAST (d.ivd_charge AS NUMERIC(28,2)) + CAST(d.iva_monto AS NUMERIC(28,2)) AS total, CASE ISNUMERIC( CAST (tasa_ret AS VARCHAR (255)))
																												WHEN 0 THEN 0
																												WHEN 1 THEN tasa_ret
																												END AS tasa_ret, 
		CASE ISNUMERIC( CAST (ret_monto AS VARCHAR(255)))
		WHEN 0 THEN 0
		WHEN 1 THEN ret_monto
		END AS ret_monto
FROM dbo.vTTSTMW_detail AS d, dbo.vTTSTMW_Header AS h
--wf..wfacturas as w WITH( NOLOCK )

WHERE d.ivh_invoicenumber = h.ivh_invoicenumber and
--h.ivh_invoicenumber != w.llave_comprobante
h.referencia_factura  = '' 

GO
