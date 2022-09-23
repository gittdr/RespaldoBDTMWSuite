SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Vista_expitations_jr]
AS
SELECT        dbo.expiration.exp_id AS operador, dbo.expiration.exp_code AS codigo, dbo.expiration.exp_expirationdate AS fechainicio, dbo.expiration.exp_compldate AS fechafin, 
                         dbo.expiration.exp_creatdate AS fechacreacion, dbo.expiration.exp_description AS descripcion, dbo.manpowerprofile.mpp_id, dbo.manpowerprofile.mpp_type3, dbo.manpowerprofile.mpp_status, 
                         dbo.manpowerprofile.mpp_lastfirst, DATEPART(week, dbo.expiration.exp_expirationdate) AS sem_inicio, DATEPART(month, dbo.expiration.exp_expirationdate) AS mes_inicio, DATEPART(year, 
                         dbo.expiration.exp_expirationdate) AS año_inicio, DATEPART(week, dbo.expiration.exp_compldate) AS sem_fin, DATEPART(month, dbo.expiration.exp_compldate) AS mes_fin, DATEPART(year, 
                         dbo.expiration.exp_compldate) AS año_fin, dbo.expiration.exp_completed, DATEDIFF(dd, dbo.expiration.exp_compldate, GETDATE()) AS dias
FROM            dbo.expiration INNER JOIN
                         dbo.manpowerprofile ON dbo.expiration.exp_id = dbo.manpowerprofile.mpp_id
WHERE        (dbo.expiration.exp_idtype = 'DRV') AND (dbo.manpowerprofile.mpp_status <> 'OUT') AND (dbo.expiration.exp_creatdate > CONVERT(DATETIME, '2015-01-01 00:00:00', 102))
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
         Begin Table = "expiration"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 281
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "manpowerprofile"
            Begin Extent = 
               Top = 6
               Left = 319
               Bottom = 254
               Right = 592
            End
            DisplayFlags = 280
            TopColumn = 44
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 18
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1500
         Width = 2955
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
', 'SCHEMA', N'dbo', 'VIEW', N'Vista_expitations_jr', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Vista_expitations_jr', NULL, NULL
GO
