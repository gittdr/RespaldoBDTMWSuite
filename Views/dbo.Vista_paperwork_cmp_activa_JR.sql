SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[Vista_paperwork_cmp_activa_JR]
AS
SELECT       
 isnull(Bdt.cmp_id,company.cmp_id) AS Billto,
 isnull(Bdt.bdt_doctype,'') AS Documento,
 isnull(lab.name,'') AS Nombre,
 isnull(CASE bdt_required_for_application WHEN 'B' THEN 'Fact y Liq' WHEN 'I' THEN 'Facturacion' ELSE 'Liquidaciones' END,'') AS RequeridoPor, 
                         dbo.company.cmp_name, 
						 isnull(dbo.company.cmp_reftype_unique,'') AS TipoRef,

                             (SELECT        name
                               FROM            dbo.labelfile
                               WHERE        (labeldefinition = 'ReferenceNumbers') AND (abbr = dbo.company.cmp_reftype_unique)) AS NombreRef
FROM            BillDoctypesincnoev AS Bdt INNER JOIN
                         dbo.company ON Bdt.cmp_id = dbo.company.cmp_id  
						 LEFT OUTER JOIN
                         dbo.labelfile AS lab ON lab.abbr = Bdt.bdt_doctype AND lab.labeldefinition = 'Paperwork' AND ISNULL(lab.retired, 'N') <> 'Y'-- AND Bdt.bdt_inv_required = 'Y'
WHERE        (dbo.company.cmp_active = 'Y')  and (dbo.company.cmp_billto = 'Y')


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
         Begin Table = "Bdt"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 278
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "company"
            Begin Extent = 
               Top = 6
               Left = 580
               Bottom = 238
               Right = 864
            End
            DisplayFlags = 280
            TopColumn = 14
         End
         Begin Table = "lab"
            Begin Extent = 
               Top = 6
               Left = 316
               Bottom = 136
               Right = 542
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
', 'SCHEMA', N'dbo', 'VIEW', N'Vista_paperwork_cmp_activa_JR', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Vista_paperwork_cmp_activa_JR', NULL, NULL
GO
