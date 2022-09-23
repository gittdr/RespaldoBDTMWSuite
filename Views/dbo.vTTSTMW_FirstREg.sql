SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/****** Object:  View vTTSTMW_FirstREg    Script Date: 10/06/09 1:26:14 PM *****
Obtiene el primer orden de cada master bill
 ,ivh_printdate*/
CREATE VIEW [dbo].[vTTSTMW_FirstREg]
AS
SELECT     (SELECT     MAX(ivh_billto) AS Expr1
                       FROM          dbo.invoiceheader  AS A
                       WHERE      (ivh_mbnumber = dbo.invoiceheader.ivh_mbnumber)) AS ivh_billto,
                          (SELECT     MAX(ord_number) AS Expr1
                            FROM          dbo.invoiceheader AS A
                            WHERE      (ivh_mbnumber = dbo.invoiceheader.ivh_mbnumber) AND (ivh_creditmemo = dbo.invoiceheader.ivh_creditmemo)) AS ord_number,
                          (SELECT     MAX(ivh_invoicenumber) AS Expr1
                            FROM          dbo.invoiceheader AS A
                            WHERE      (ivh_mbnumber = dbo.invoiceheader.ivh_mbnumber) AND (SUBSTRING(ivh_invoicenumber, 1, 1) <> 'T') AND 
                                                   (ivh_creditmemo = dbo.invoiceheader.ivh_creditmemo)) AS ivh_invoicenumber, ivh_mbnumber,
                          (SELECT     MAX(ivh_hdrnumber) AS Expr1
                            FROM          dbo.invoiceheader AS A
                            WHERE      (ivh_mbnumber = dbo.invoiceheader.ivh_mbnumber) AND (ivh_creditmemo = dbo.invoiceheader.ivh_creditmemo)) AS ivh_hdrnumber, 
                      ABS(SUM(ivh_totalcharge)) AS ivh_totalcharge, ABS(SUM(ivh_taxamount1)) AS ivh_taxamount1, ABS(SUM(ivh_taxamount2)) AS ivh_taxamount2, 
                      ABS(SUM(ivh_archarge)) AS monto_pesos, ivh_creditmemo

FROM         dbo.invoiceheader with (nolock)
WHERE     (ivh_invoicestatus = 'PRN') 
AND (SUBSTRING(ivh_invoicenumber, 1, 1) <> 'T') AND (ivh_mbnumber > 0) and ivh_creditmemo is not null
GROUP BY ivh_mbnumber, ivh_creditmemo



GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
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
         Configuration = "(H (1[56] 4[18] 2) )"
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
         Left = 0
      End
      Begin Tables = 
         Begin Table = "invoiceheader"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 263
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
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
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
', 'SCHEMA', N'dbo', 'VIEW', N'vTTSTMW_FirstREg', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vTTSTMW_FirstREg', NULL, NULL
GO
