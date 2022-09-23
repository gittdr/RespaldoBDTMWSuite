SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vista_evidencias]
AS
SELECT     dbo.vTTSTMW_OrderandInvoiceInformation.[Order Number], dbo.vTTSTMW_OrderandInvoiceInformation.[Invoice Status], 
                      dbo.vTTSTMW_OrderandInvoiceInformation.[Order Status], dbo.vTTSTMW_OrderandInvoiceInformation.DrvType3, 
                      dbo.vTTSTMW_OrderandInvoiceInformation.Tractor, dbo.vTTSTMW_OrderandInvoiceInformation.[Reference Number],  [Total Revenue],
                      
                       /*CASE WHEN Currency = 'US$' THEN [Total Revenue] *
                          (SELECT     cex_rate
                            FROM          currency_exchange
                            WHERE      (DAY(cex_date) =
                                                       (SELECT     fechamax = MAX(DAY(cex_date))
                                                         FROM          currency_exchange
                                                         WHERE      (MONTH(cex_date) = MONTH(GETDATE())) AND (YEAR(cex_date) = YEAR(GETDATE())))) AND (YEAR(cex_date) 
                                                   = YEAR(GETDATE())) AND (MONTH(cex_date) = MONTH(GETDATE()))) ELSE [Total Revenue] END AS [Total Revenue], */



                      dbo.vTTSTMW_OrderandInvoiceInformation.[Total Revenue] AS original, dbo.vTTSTMW_OrderandInvoiceInformation.Currency, 
                      dbo.vTTSTMW_OrderandInvoiceInformation.[RevType2 Name], dbo.vTTSTMW_OrderandInvoiceInformation.[RevType4 Name], 
                      dbo.vTTSTMW_OrderandInvoiceInformation.[PaperWork Received Date], dbo.vTTSTMW_OrderandInvoiceInformation.[Delivery Date], DATEDIFF([day], 
                      dbo.vTTSTMW_OrderandInvoiceInformation.[Delivery Date], GETDATE()) AS DIFdias, ROUND(DATEDIFF([day], 
                      dbo.vTTSTMW_OrderandInvoiceInformation.[Delivery Date], GETDATE()), - 1) AS diastranssup, CASE WHEN (DATEDIFF([day], [Delivery Date], 
                      GETDATE()) - ROUND(DATEDIFF([day], [Delivery Date], GETDATE()), - 1)) > 0 THEN ROUND(DATEDIFF([day], [Delivery Date], GETDATE()), - 1) 
                      + 10 ELSE ROUND(DATEDIFF([day], [Delivery Date], GETDATE()), - 1) END AS dd, dbo.vTTSTMW_OrderandInvoiceInformation.[Bill To ID], 
                      dbo.vTTSTMW_OrderandInvoiceInformation.[Driver Name], CASE WHEN DATEDIFF([day], [Delivery Date], GETDATE()) 
                      > 40 THEN '40  +' WHEN DATEDIFF([day], [Delivery Date], GETDATE()) BETWEEN 36 AND 40 THEN '36 A 40 ' WHEN DATEDIFF([day], [Delivery Date], 
                      GETDATE()) BETWEEN 31 AND 35 THEN '31 A 35 ' WHEN DATEDIFF([day], [Delivery Date], GETDATE()) BETWEEN 26 AND 
                      30 THEN '26 A 30' WHEN DATEDIFF([day], [Delivery Date], GETDATE()) BETWEEN 21 AND 25 THEN '21 a 25' WHEN DATEDIFF([day], [Delivery Date], 
                      GETDATE()) BETWEEN 15 AND 20 THEN '15 a 20' WHEN DATEDIFF([day], [Delivery Date], GETDATE()) BETWEEN 11 AND 
                      15 THEN '11 a 15' WHEN DATEDIFF([day], [Delivery Date], GETDATE()) BETWEEN 5 AND 10 THEN '05 a 10' WHEN DATEDIFF([day], [Delivery Date], 
                      GETDATE()) BETWEEN 0 AND 5 THEN '0 a 4' END AS rango, 'Orden:' + RTRIM(dbo.vTTSTMW_OrderandInvoiceInformation.[Order Number]) 
                      + ' Operador:' + RTRIM(dbo.vTTSTMW_OrderandInvoiceInformation.[Driver ID]) 
                      + ' Tractor: ' + RTRIM(dbo.vTTSTMW_OrderandInvoiceInformation.Tractor) 
                      + ' Entrega:' + CASE WHEN CAST(dbo.vTTSTMW_OrderandInvoiceInformation.[PaperWork Received Date] AS varchar) IS NULL 
                      THEN 'NA' ELSE CAST(dbo.vTTSTMW_OrderandInvoiceInformation.[PaperWork Received Date] AS varchar) END AS head, 
                      CASE dbo.paperwork.pw_received WHEN 'Y' THEN 1 WHEN 'N' THEN 0 END AS evval, 
                      CASE dbo.paperwork.pw_received WHEN 'Y' THEN 'Entregadas' WHEN 'N' THEN 'No entregadas' END AS status, CASE MONTH([Delivery Date]) 
                      WHEN 12 THEN 'Diciembre' WHEN 11 THEN 'Noviembre' WHEN 10 THEN 'Octubre' WHEN 9 THEN 'Septiembre' WHEN 8 THEN 'Agosto' WHEN 7 THEN
                       'Julio' WHEN 6 THEN 'Junio' WHEN 5 THEN 'Mayo' WHEN 4 THEN 'Abril' WHEN 3 THEN 'Marzo' WHEN 2 THEN 'Febrero' WHEN 1 THEN 'Enero' ELSE
                       ' ' END AS mes, YEAR(dbo.vTTSTMW_OrderandInvoiceInformation.[Delivery Date]) AS anio, dbo.paperwork.abbr
FROM         dbo.vTTSTMW_OrderandInvoiceInformation with (nolock)  INNER JOIN
                      dbo.paperwork with (nolock)  ON dbo.vTTSTMW_OrderandInvoiceInformation.[Order Header Number] = dbo.paperwork.ord_hdrnumber
WHERE     (dbo.vTTSTMW_OrderandInvoiceInformation.[Order Status] = 'CMP') AND (dbo.vTTSTMW_OrderandInvoiceInformation.[Invoice Status] IN ('AVL', 'HLD', 
                      'RTP', 'HLA')) AND (DATEDIFF([day], dbo.vTTSTMW_OrderandInvoiceInformation.[Delivery Date], GETDATE()) > 0) AND (dbo.paperwork.abbr NOT IN ('IN', 
                      'CP'))


GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[36] 4[4] 2[26] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = -1344
      End
      Begin Tables = 
         Begin Table = "vTTSTMW_OrderandInvoiceInformation"
            Begin Extent = 
               Top = 6
               Left = 1382
               Bottom = 213
               Right = 1671
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "paperwork"
            Begin Extent = 
               Top = 6
               Left = 1709
               Bottom = 213
               Right = 1984
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
      Begin ColumnWidths = 26
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vista_evidencias', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_evidencias', NULL, NULL
GO
