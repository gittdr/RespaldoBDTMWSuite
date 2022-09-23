SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Vista_Cajas_Rastreo]
AS
SELECT dbo.trlaccessories.ta_type, dbo.trlaccessories.ta_id, dbo.trlaccessories.ta_trailer, dbo.labelfile.name, dbo.trailerprofile.trl_number, dbo.trailerprofile.trl_make, 
                  dbo.trailerprofile.trl_model, dbo.trailerprofile.trl_branch, dbo.trailerprofile.trl_equipmenttype
FROM     dbo.trlaccessories INNER JOIN
                  dbo.labelfile ON dbo.trlaccessories.ta_type = dbo.labelfile.abbr LEFT OUTER JOIN
                  dbo.trailerprofile ON dbo.trlaccessories.ta_trailer = dbo.trailerprofile.trl_number
WHERE  (dbo.trlaccessories.ta_type IN ('RGP', 'NGP')) AND (dbo.labelfile.labeldefinition = 'TrlAcc')
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
         Begin Table = "trlaccessories"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 250
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "labelfile"
            Begin Extent = 
               Top = 7
               Left = 298
               Bottom = 168
               Right = 563
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "trailerprofile"
            Begin Extent = 
               Top = 216
               Left = 506
               Bottom = 497
               Right = 817
            End
            DisplayFlags = 280
            TopColumn = 171
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
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'Vista_Cajas_Rastreo', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Vista_Cajas_Rastreo', NULL, NULL
GO
