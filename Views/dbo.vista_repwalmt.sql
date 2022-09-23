SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vista_repwalmt]
AS
SELECT     dbo.vista_walgp.fechaaplic AS fechapago, dbo.vista_walgp.Masterbill, dbo.invoiceheader.ivh_invoicenumber, dbo.invoiceheader.ord_number, 
                      dbo.wf_archivos.serie + dbo.wf_archivos.folio AS foliotdr, dbo.invoiceheader.ivh_tractor AS unidad, dbo.invoiceheader.ivh_trailer AS caja, 
                      dbo.invoiceheader.ivh_destpoint AS destino, dbo.invoiceheader.ivh_revtype4 AS Capacidad, dbo.invoiceheader.ivh_deliverydate AS fechaviaje, 
                      dbo.vista_walgp.cliente, dbo.vista_walgp.monto AS montoaplicmaster, dbo.invoiceheader.ivh_totalcharge AS totalindividual
FROM         dbo.vista_walgp INNER JOIN
                      dbo.invoiceheader ON CAST(dbo.vista_walgp.Masterbill AS varchar) = CAST(dbo.invoiceheader.ivh_mbnumber AS varchar) INNER JOIN
                      dbo.wf_archivos ON dbo.vista_walgp.Masterbill = dbo.wf_archivos.master
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[20] 3) )"
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
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vista_walgp"
            Begin Extent = 
               Top = 49
               Left = 342
               Bottom = 157
               Right = 493
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "invoiceheader"
            Begin Extent = 
               Top = 11
               Left = 576
               Bottom = 226
               Right = 855
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "wf_archivos"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 189
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
      RowHeights = 225
      Begin ColumnWidths = 14
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 2565
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_repwalmt', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_repwalmt', NULL, NULL
GO
