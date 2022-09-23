SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Vista_Remolques_vencimientos_JR]
AS
SELECT        trl_number AS Trailer, trl_avail_date AS Fecha, DATEDIFF(dd, trl_avail_date, GETDATE()) AS DIFDIAS, DATEDIFF(dd, trl_avail_date, GETDATE()) AS DIAS,
                             (SELECT        name
                               FROM            dbo.labelfile WITH (nolock)
                               WHERE        (labeldefinition = 'Fleet') AND (abbr = dbo.trailerprofile.trl_fleet)) AS FLOTA,
                             (SELECT        name
                               FROM            dbo.labelfile AS labelfile_2 WITH (nolock)
                               WHERE        (labeldefinition = 'trlstatus') AND (abbr = dbo.trailerprofile.trl_status)) AS StatusTrailer, ISNULL
                             ((SELECT        MAX(exp_description) AS Expr1
                                 FROM            dbo.expiration
                                 WHERE        (exp_idtype = 'TRL') AND (exp_id = dbo.trailerprofile.trl_number) AND (exp_completed <> 'Y') AND (exp_code = dbo.trailerprofile.trl_status)), 'NA') AS StatusDesc, trl_avail_cmp_id AS Patio,
                             (SELECT        name
                               FROM            dbo.labelfile AS labelfile_1 WITH (nolock)
                               WHERE        (labeldefinition = 'RevType3') AND (abbr =
                                                             (SELECT        cmp_revtype3
                                                               FROM            dbo.company AS company_1 WITH (nolock)
                                                               WHERE        (cmp_id = dbo.trailerprofile.trl_avail_cmp_id)))) AS Proyecto,
                             (SELECT        name
                               FROM            dbo.labelfile AS labelfile_1 WITH (nolock)
                               WHERE        (labeldefinition = 'RevType3') AND (abbr = dbo.trailerprofile.trl_type3)) AS DescProyTrc, trl_type3 AS ProyTrc, trl_owner AS propietario
FROM            dbo.trailerprofile WITH (nolock)
WHERE        (trl_status NOT IN ('OUT')) AND (trl_number <> 'UNKNOWN')
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
         Begin Table = "trailerprofile"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 303
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
', 'SCHEMA', N'dbo', 'VIEW', N'Vista_Remolques_vencimientos_JR', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Vista_Remolques_vencimientos_JR', NULL, NULL
GO
