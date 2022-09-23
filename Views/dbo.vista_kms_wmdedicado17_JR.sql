SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vista_kms_wmdedicado17_JR]
AS
SELECT        dbo.orderheader.ord_number, dbo.orderheader.ord_startdate AS fechainicio, DATEPART(week, dbo.orderheader.ord_startdate) AS sem_ini, DATEPART(month, dbo.orderheader.ord_startdate) AS mes_ini, DATEPART(year, 
                         dbo.orderheader.ord_startdate) AS año_ini, dbo.orderheader.ord_bookdate AS fechabook, DATEPART(week, dbo.orderheader.ord_bookdate) AS sem_book, DATEPART(month, dbo.orderheader.ord_bookdate) AS mes_book, 
                         DATEPART(year, dbo.orderheader.ord_bookdate) AS año_book, dbo.orderheader.ord_status, dbo.legheader.lgh_driver1, dbo.legheader.lgh_tractor, dbo.tractorprofile.trc_licnum, dbo.legheader.lgh_primary_trailer, 
                         dbo.orderheader.ord_totalmiles, dbo.legheader.lgh_miles, dbo.orderheader.ord_refnum, dbo.orderheader.ord_billto
FROM            dbo.legheader INNER JOIN
                         dbo.tractorprofile ON dbo.legheader.lgh_tractor = dbo.tractorprofile.trc_number INNER JOIN
                         dbo.orderheader ON dbo.legheader.mov_number = dbo.orderheader.mov_number
WHERE        (dbo.orderheader.ord_revtype3 = 'WTEP') AND (NOT (dbo.orderheader.ord_status IN ('MST', 'CAN')))
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
         Begin Table = "legheader"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 303
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tractorprofile"
            Begin Extent = 
               Top = 6
               Left = 341
               Bottom = 136
               Right = 615
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "orderheader"
            Begin Extent = 
               Top = 6
               Left = 653
               Bottom = 136
               Right = 925
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
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_kms_wmdedicado17_JR', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_kms_wmdedicado17_JR', NULL, NULL
GO
