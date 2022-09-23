SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vista_Ventas]
AS
SELECT CASE (dbo.orderheader.ord_revtype4) 
               WHEN 'SEN' THEN 'ABIERTO' WHEN 'ESP' THEN 'ESPECIALIZADO' WHEN 'FUL' THEN 'ESPECIALIZADO' WHEN 'DED' THEN 'DEDICADO' WHEN 'INT' THEN 'INTERNACIONAL'
                END AS Division, ord_company, ord_totalcharge AS ventas, ord_status AS Status, CASE (dbo.orderheader.ord_revtype2) 
               WHEN 'MEX' THEN 'México' WHEN 'GUD' THEN 'Guadalajara' WHEN 'QRO' THEN 'Querétaro' WHEN 'MTE' THEN 'Monterrey' WHEN 'LAD' THEN 'Nuevo Laredo' END AS
                Terminal, DAY(ord_completiondate) AS dia, YEAR(ord_completiondate) AS anio, CASE MONTH(ord_completiondate) 
               WHEN 12 THEN 'Diciembre' WHEN 11 THEN 'Noviembre' WHEN 10 THEN 'Octubre' WHEN 9 THEN 'Septiembre' WHEN 8 THEN 'Agosto' WHEN 7 THEN 'Julio' WHEN 6 THEN
                'Junio' WHEN 5 THEN 'Mayo' WHEN 4 THEN 'Abril' WHEN 3 THEN 'Marzo' WHEN 2 THEN 'Febrero' WHEN 1 THEN 'Enero' ELSE ' ' END AS mes, ord_driver1, 
               MONTH(ord_completiondate) AS mes1, ord_totalweight, ord_completiondate AS fecha
FROM  dbo.orderheader
WHERE (ord_revtype2 NOT IN ('MX', '', 'UNK')) AND (ord_status IN ('STD', 'CMP', 'PLN', 'AVL'))
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[20] 4[12] 2[40] 3) )"
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
               Bottom = 293
               Right = 274
            End
            DisplayFlags = 280
            TopColumn = 56
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 13
         Width = 284
         Width = 2088
         Width = 2112
         Width = 1188
         Width = 1440
         Width = 1440
         Width = 1716
         Width = 1440
         Width = 1440
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_Ventas', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_Ventas', NULL, NULL
GO
