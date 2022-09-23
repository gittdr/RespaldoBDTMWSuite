SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Vista_Tarjetas_TDDE_JR]
AS
SELECT        dbo.manpowerprofile.mpp_id AS ID, dbo.manpowerprofile.mpp_lastfirst AS Nombre, dbo.manpowerprofile.mpp_status AS Estatus, dbo.driverdocument.drd_docnumber AS Documento, dbo.driverdocument.drd_default AS Activo, 
                         dbo.manpowerprofile.mpp_type3 AS proyecto, dbo.labelfile.name AS nombreproyecto, dbo.manpowerprofile.mpp_dateofbirth, dbo.manpowerprofile.mpp_licensenumber, dbo.manpowerprofile.mpp_address1, 
                         dbo.manpowerprofile.mpp_address2, dbo.manpowerprofile.mpp_zip, dbo.manpowerprofile.mpp_currentphone, dbo.manpowerprofile.mpp_homephone, dbo.manpowerprofile.mpp_alternatephone,
                             (SELECT        MAX(exp_expirationdate) AS Expr1
                               FROM            dbo.expiration
                               WHERE        (exp_id = dbo.manpowerprofile.mpp_id) AND (exp_code = 'LIC') AND (exp_completed = 'N')) AS fechaVencLic, dbo.manpowerprofile.mpp_hiredate AS fechacontratacion
FROM            dbo.manpowerprofile LEFT OUTER JOIN
                         dbo.driverdocument ON dbo.manpowerprofile.mpp_id = dbo.driverdocument.mpp_id AND dbo.driverdocument.drd_doctype = 'TDDE' INNER JOIN
                         dbo.labelfile ON dbo.manpowerprofile.mpp_type3 = dbo.labelfile.abbr
WHERE        (dbo.manpowerprofile.mpp_status <> 'OUT') AND (dbo.manpowerprofile.mpp_id <> 'UNKNOWN') AND (LEFT(dbo.manpowerprofile.mpp_id, 2) <> 'P-') AND (dbo.labelfile.labeldefinition = 'DrvType3')
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
         Begin Table = "manpowerprofile"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 310
               Right = 304
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "driverdocument"
            Begin Extent = 
               Top = 6
               Left = 350
               Bottom = 136
               Right = 559
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "labelfile"
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
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'Vista_Tarjetas_TDDE_JR', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Vista_Tarjetas_TDDE_JR', NULL, NULL
GO
