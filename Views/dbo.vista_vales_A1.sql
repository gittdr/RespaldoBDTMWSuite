SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vista_vales_A1]
AS
SELECT dbo.fuelticket.ftk_ticket_number, dbo.fuelticket.drv_id, dbo.fuelticket.ftk_created_on, dbo.fuelticket.ftk_created_by, dbo.fuelticket.trc_id, dbo.fuelticket.ftk_liters, 
                  dbo.fuelticket.ftk_cost, dbo.vale_complemento_A1.vale_id_motivo_A1, dbo.vale_complemento_motivo.motivo, dbo.vale_complemento_A1.vale_proyecto_A1, 
                  dbo.vale_complemento_A1.vale_observaciones_A1, dbo.orderheader.ord_billto, dbo.fuelticket.ftk_updated_by AS CreoVale
FROM     dbo.fuelticket INNER JOIN
                  dbo.vale_complemento_A1 ON dbo.fuelticket.ftk_ticket_number = dbo.vale_complemento_A1.num_vale_A1 INNER JOIN
                  dbo.vale_complemento_motivo ON dbo.vale_complemento_A1.vale_id_motivo_A1 = dbo.vale_complemento_motivo.id_motivo LEFT OUTER JOIN
                  dbo.orderheader ON dbo.fuelticket.mov_number = dbo.orderheader.mov_number
WHERE  (dbo.fuelticket.ftk_canceled_by IS NULL)
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
         Begin Table = "fuelticket"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 259
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "vale_complemento_A1"
            Begin Extent = 
               Top = 7
               Left = 307
               Bottom = 168
               Right = 553
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vale_complemento_motivo"
            Begin Extent = 
               Top = 7
               Left = 601
               Bottom = 124
               Right = 795
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "orderheader"
            Begin Extent = 
               Top = 7
               Left = 843
               Bottom = 168
               Right = 1168
            End
            DisplayFlags = 280
            TopColumn = 13
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 14
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356', 'SCHEMA', N'dbo', 'VIEW', N'vista_vales_A1', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vista_vales_A1', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_vales_A1', NULL, NULL
GO
