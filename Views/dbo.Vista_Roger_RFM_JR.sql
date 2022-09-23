SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Vista_Roger_RFM_JR]
AS
SELECT        dbo.tractorprofile.trc_number AS TRACTOR, dbo.tractorprofile.trc_status, dbo.tractoraccesories.tca_id AS FOLIO, dbo.tractoraccesories.tca_tractor, dbo.tractoraccesories.tca_dateaquired, dbo.tractoraccesories.tca_expire_date, 
                         A.name, B.name AS PROYECTO, DATEDIFF(day, GETDATE(), dbo.tractoraccesories.tca_expire_date) AS Dias, dbo.tractorprofile.trc_licnum
FROM            dbo.tractorprofile LEFT OUTER JOIN
                         dbo.tractoraccesories ON dbo.tractorprofile.trc_number = dbo.tractoraccesories.tca_tractor AND dbo.tractoraccesories.tca_type = 'RFM' INNER JOIN
                         dbo.labelfile AS B ON dbo.tractorprofile.trc_type3 = B.abbr CROSS JOIN
                         dbo.labelfile AS A
WHERE        (dbo.tractorprofile.trc_status <> 'OUT') AND (dbo.tractorprofile.trc_number <> 'UNKNOWN') AND (A.abbr = 'RFM') AND (A.labeldefinition = 'trcacc') AND (B.labeldefinition = 'TrcType3')
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
         Begin Table = "tractorprofile"
            Begin Extent = 
               Top = 6
               Left = 285
               Bottom = 136
               Right = 559
            End
            DisplayFlags = 280
            TopColumn = 23
         End
         Begin Table = "tractoraccesories"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 247
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 6
               Left = 861
               Bottom = 136
               Right = 1087
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "A"
            Begin Extent = 
               Top = 6
               Left = 597
               Bottom = 136
               Right = 823
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
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
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
     ', 'SCHEMA', N'dbo', 'VIEW', N'Vista_Roger_RFM_JR', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'    Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'Vista_Roger_RFM_JR', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Vista_Roger_RFM_JR', NULL, NULL
GO
