SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vista_Estanciasclientes]
AS
SELECT     dbo.paydetail.pyd_amount, 'driver: ' + RTRIM(dbo.paydetail.asgn_id) + ' concepto: ' + dbo.paydetail.pyd_description AS head, 
                      dbo.paydetail.ord_hdrnumber, dbo.orderheader.ord_billto, dbo.orderheader.ord_startdate, dbo.orderheader.ord_status, 
                      CASE MONTH(dbo.orderheader.ord_startdate) 
                      WHEN 12 THEN 'Diciembre' WHEN 11 THEN 'Noviembre' WHEN 10 THEN 'Octubre' WHEN 9 THEN 'Septiembre' WHEN 8 THEN 'Agosto' WHEN 7 THEN
                       'Julio' WHEN 6 THEN 'Junio' WHEN 5 THEN 'Mayo' WHEN 4 THEN 'Abril' WHEN 3 THEN 'Marzo' WHEN 2 THEN 'Febrero' WHEN 1 THEN 'Enero' ELSE
                       ' ' END AS MES, DAY(dbo.orderheader.ord_startdate) AS DIA, YEAR(dbo.orderheader.ord_startdate) AS anio
FROM         dbo.paydetail INNER JOIN
                      dbo.orderheader ON CAST(dbo.paydetail.ord_hdrnumber AS varchar) = CAST(dbo.orderheader.ord_number AS vaRCHAR)
WHERE     (dbo.paydetail.pyt_itemcode = 'COBEST') AND (YEAR(dbo.orderheader.ord_startdate) >= 2011) AND (dbo.orderheader.ord_status NOT IN ('CAN'))
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
         Begin Table = "paydetail"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 333
               Right = 249
            End
            DisplayFlags = 280
            TopColumn = 37
         End
         Begin Table = "orderheader"
            Begin Extent = 
               Top = 6
               Left = 287
               Bottom = 349
               Right = 519
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
      RowHeights = 225
      Begin ColumnWidths = 10
         Width = 284
         Width = 1200
         Width = 5325
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 3090
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_Estanciasclientes', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_Estanciasclientes', NULL, NULL
GO
