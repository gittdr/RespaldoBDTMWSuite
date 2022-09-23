SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Store Procedure que executa PNF's
--Drop Proc  sp_ejecutaPNFS
--exec sp_ejecutaPNFS
Create procedure [dbo].[sp_ejecutaPNFS]
AS


delete tmw_vista_pnfs;


Insert tmw_vista_pnfs
(v_Orden_number,v_invoicestatus, v_orderstatus,  v_drvtype3, v_tractor, v_total_Rev, v_currency, v_revType2, 
v_revType4, v_delivery_date, v_difdias, v_diastranssup, v_dd)
SELECT     [Order Number], [Invoice Status], [Order Status], DrvType3, Tractor,  CASE WHEN Currency = 'US$' THEN [Total Revenue] *
                          (SELECT     cex_rate
                            FROM          currency_exchange
                            WHERE      (DAY(cex_date) =
                                                       (SELECT     fechamax = MAX(DAY(cex_date))
                                                         FROM          currency_exchange
                                                         WHERE      (MONTH(cex_date) = MONTH(GETDATE())) AND (YEAR(cex_date) = YEAR(GETDATE())))) AND (YEAR(cex_date) 
                                                   = YEAR(GETDATE())) AND (MONTH(cex_date) = MONTH(GETDATE()))) ELSE [Total Revenue] END AS [Total Revenue], 
                      Currency, [RevType2], [RevType4],  [Delivery Date], DATEDIFF([day], 
                      [Delivery Date], GETDATE()) AS DIFdias, ROUND(DATEDIFF([day], [Delivery Date], GETDATE()), - 1) AS diastranssup, CASE WHEN (DATEDIFF([day], 
                      [Delivery Date], GETDATE()) - ROUND(DATEDIFF([day], [Delivery Date], GETDATE()), - 1)) > 0 THEN ROUND(DATEDIFF([day], [Delivery Date], GETDATE()), 
                      - 1) + 10 ELSE ROUND(DATEDIFF([day], [Delivery Date], GETDATE()), - 1) END AS dd
FROM         dbo.vTTSTMW_OrderandInvoiceInformation
WHERE     ([Order Status] = 'CMP') AND ([Invoice Status] IN ('AVL', 'HLD', 'RTP', 'HLA'))
GO
