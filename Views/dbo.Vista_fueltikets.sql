SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Vista_fueltikets]
AS
SELECT     dbo.fuelticket.ftk_created_on, dbo.fuelticket.ftk_created_by, dbo.fuelticket.ftk_liters, dbo.fuelticket.ftk_cost, dbo.fuelticket.ord_hdrnumber, 
                      dbo.fuelticket.trc_id, dbo.fuelticket.ftk_printed_by, dbo.fuelticket.ftk_printed_on, dbo.fuelticket.drv_id, dbo.fuelticket.ftk_recycled, 
                      dbo.fuelticket.ftk_updated_by, dbo.fuelticket.ftk_ticket_number, dbo.fuelticket.ftk_canceled_by, dbo.fuelticket.ftk_canceled_on, 
                      dbo.fuelticket.ftk_reconciled_by, { fn WEEK(dbo.fuelticket.ftk_printed_on) } AS Semana, MONTH(dbo.fuelticket.ftk_printed_on) AS Mes, 
                      YEAR(dbo.fuelticket.ftk_printed_on) AS Año, dbo.fuelticket.ftk_invoice, dbo.fuelticket.ftk_cty_start, dbo.fuelticket.ftk_cty_end, 
                      dbo.city.cty_name AS Destino, city_1.cty_name AS Origen
FROM         dbo.fuelticket with (nolock)  INNER JOIN
                      dbo.city with (nolock)  ON dbo.fuelticket.ftk_cty_end = dbo.city.cty_code INNER JOIN
                      dbo.city city_1  with (nolock)  ON dbo.fuelticket.ftk_cty_start = city_1.cty_code
WHERE     (dbo.fuelticket.ftk_canceled_by IS NULL) AND (dbo.fuelticket.ftk_reconciled_by IS NULL) AND (NOT (dbo.fuelticket.ftk_printed_by IS NULL)) AND 
                      (dbo.fuelticket.ftk_invoice IS NULL)
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
         Begin Table = "fuelticket"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 208
               Right = 317
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "city"
            Begin Extent = 
               Top = 132
               Left = 588
               Bottom = 324
               Right = 786
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "city_1"
            Begin Extent = 
               Top = 6
               Left = 591
               Bottom = 114
               Right = 789
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
      Begin ColumnWidths = 24
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
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2115
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupB', 'SCHEMA', N'dbo', 'VIEW', N'Vista_fueltikets', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'y = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'Vista_fueltikets', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Vista_fueltikets', NULL, NULL
GO
