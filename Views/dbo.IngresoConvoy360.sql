SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- SELECT * FROM IngresoConvoy360
-- Ingreso Convoy 360 BillTo TDRQUERE

CREATE VIEW [dbo].[IngresoConvoy360]
AS
SELECT ord_billto AS Cliente
	,o.ord_hdrnumber AS Orden
	,o.ord_completiondate AS Fecha
	,datediff(day, o.ord_completiondate, getdate()) AS billlag
	,o.ord_invoicestatus AS Estatus
	,isnull((
			SELECT max(ivh_hdrnumber)
			FROM invoiceheader i
			WHERE i.ord_hdrnumber = o.ord_hdrnumber
				AND i.ivh_invoicestatus NOT IN ('CAN')
			), 0) AS Factura
	,isnull((
			SELECT max(ivh_mbnumber)
			FROM invoiceheader i
			WHERE i.ord_hdrnumber = o.ord_hdrnumber
				AND i.ivh_invoicestatus NOT IN ('CAN')
			), 0) AS Masterb
	,isnull((
			SELECT max(ivh_ref_number)
			FROM invoiceheader i
			WHERE i.ord_hdrnumber = o.ord_hdrnumber
				AND i.ivh_invoicestatus NOT IN ('CAN')
			), ord_refnum) AS RefFactura
	,isnull((
			SELECT max(i.ivh_invoicestatus)
			FROM invoiceheader i
			WHERE i.ord_hdrnumber = o.ord_hdrnumber
				AND i.ivh_invoicestatus NOT IN ('CAN')
			), 'AVL') AS EstatusFactura
	,isnull((
			SELECT TOP 1 CASE 
					WHEN (ivh_currency) = 'US$'
						THEN (
								SELECT max(cex_rate)
								FROM currency_exchange
								WHERE cex_from_curr = ivh_currency
									AND cex_date = (
										SELECT max(cex_date)
										FROM currency_exchange
										WHERE cex_from_curr = ivh_currency
										)
								) * ivh_charge
					ELSE (ivh_charge)
					END AS rate
			FROM invoiceheader i
			WHERE i.ord_hdrnumber = o.ord_hdrnumber
				AND i.ivh_invoicestatus NOT IN ('CAN')
			), CASE 
			WHEN (o.ord_currency) = 'US$'
				THEN o.ord_totalcharge * (
						SELECT max(cex_rate)
						FROM currency_exchange
						WHERE cex_from_curr = o.ord_currency
							AND cex_date = (
								SELECT max(cex_date)
								FROM currency_exchange
								WHERE cex_from_curr = o.ord_currency
								)
						)
			ELSE o.ord_totalcharge
			END) AS MontoFactura
	,'' AS [evidencias]
	,CASE 
		WHEN ord_refnum IS NULL
			THEN 1
		ELSE 0
		END AS FaltanReferencias
	,0 AS FaltanEvidencias
	,0 AS Nocalc
	,ord_description
FROM orderheader o
WHERE ord_status = 'CMP'
	AND o.ord_hdrnumber NOT IN (
		SELECT ord_hdrnumber
		FROM invoiceheader
		WHERE ivh_invoicestatus IN (
				'XFR'
				,'NTP'
				,'PPD'
				,'MFE'
				)
		)
	AND ord_invoicestatus NOT IN (
		'XIN'
		,'MFE'
		,'AMC'
		)
	AND (
		(
			SELECT DISTINCT count(not_viewlevel)
			FROM notes
			WHERE ntb_table = 'orderheader'
				AND not_type = 'EVI'
				AND nre_tablekey = o.ord_hdrnumber
			) = 0
		OR (
			SELECT DISTINCT count(not_viewlevel)
			FROM notes
			WHERE ntb_table = 'orderheader'
				AND not_type = 'EVI'
				AND nre_tablekey = o.ord_hdrnumber
			) = 2
		)
		AND ord_billto = 'TDRQUERE'
--ORDER BY billlag DESC
GO
