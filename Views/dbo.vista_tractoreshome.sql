SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vista_tractoreshome]
AS
SELECT     DAY(dbo.orderheader.ord_startdate) AS dia, MONTH(dbo.orderheader.ord_startdate) AS mes, YEAR(dbo.orderheader.ord_startdate) AS anio, 
                      dbo.orderheader.ord_tractor, dbo.orderheader.ord_trailer, dbo.orderheader.ord_originpoint, dbo.orderheader.ord_destpoint, 
                      dbo.orderheader.ord_status, dbo.tractorprofile.trc_gps_desc, dbo.tractorprofile.trc_gps_date, dbo.orderheader.ord_driver1, 
                      dbo.orderheader.ord_number, dbo.orderheader.ord_refnum
FROM         dbo.orderheader INNER JOIN
                      dbo.tractorprofile ON dbo.orderheader.ord_tractor = dbo.tractorprofile.trc_number
WHERE     (dbo.orderheader.ord_billto = 'HOMEDEP') AND (MONTH(dbo.orderheader.ord_startdate) = MONTH(GETDATE())) AND 
                      (YEAR(dbo.orderheader.ord_startdate) = YEAR(GETDATE()))
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[51] 4[10] 2[20] 3) )"
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
         Begin Table = "orderheader"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 307
               Right = 269
            End
            DisplayFlags = 280
            TopColumn = 89
         End
         Begin Table = "tractorprofile"
            Begin Extent = 
               Top = 6
               Left = 307
               Bottom = 284
               Right = 520
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
      RowHeights = 255
      Begin ColumnWidths = 14
         Width = 284
         Width = 360
         Width = 435
         Width = 510
         Width = 975
         Width = 900
         Width = 1440
         Width = 1440
         Width = 1230
         Width = 3555
         Width = 2370
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_tractoreshome', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_tractoreshome', NULL, NULL
GO
