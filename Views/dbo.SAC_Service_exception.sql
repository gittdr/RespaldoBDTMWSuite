SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[SAC_Service_exception]
AS
SELECT      TOP 100 PERCENT dbo.serviceexception.sxn_ord_hdrnumber AS Orden, dbo.serviceexception.sxn_cmp_id AS Cliente, 
                        dbo.serviceexception.sxn_createdby AS [Creado por], dbo.serviceexception.sxn_expdate AS Fecha, dbo.serviceexception.sxn_expcode AS Código, 
                        dbo.serviceexception.sxn_asgn_id AS [Asignado a], dbo.serviceexception.sxn_description AS [Descripción Falla], 
                        dbo.serviceexception.sxn_action_description AS [Acción Inmediata], dbo.serviceexception.sxn_late AS [Tarde a], 
                        dbo.serviceexception.sxn_action_received_desc AS [Acción Correctiva], dbo.manpowerprofile.mpp_teamleader AS Lider, 
                        { fn MONTHNAME(dbo.serviceexception.sxn_expdate) } AS Mes, DATEPART(dd, dbo.serviceexception.sxn_expdate) AS Día, DATEPART(ww, 
                        dbo.serviceexception.sxn_expdate) - 1 AS Semana, DATEPART(yyyy, dbo.serviceexception.sxn_expdate) AS Año
FROM          dbo.manpowerprofile INNER JOIN
                        dbo.orderheader ON dbo.manpowerprofile.mpp_id = dbo.orderheader.ord_driver1 INNER JOIN
                        dbo.serviceexception ON dbo.orderheader.ord_hdrnumber = dbo.serviceexception.sxn_ord_hdrnumber
WHERE      (dbo.serviceexception.sxn_expdate > CONVERT(DATETIME, '2011-08-01 00:00:00', 102))
ORDER BY dbo.serviceexception.sxn_expdate, dbo.serviceexception.sxn_expcode
GO
DECLARE @xp tinyint
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DefaultView', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', NULL, NULL
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
         Configuration = "(H (1[50] 4[25] 3) )"
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
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1[75] 4) )"
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
      ActivePaneConfig = 8
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
               Left = 554
               Bottom = 343
               Right = 803
            End
            DisplayFlags = 280
            TopColumn = 120
         End
         Begin Table = "orderheader"
            Begin Extent = 
               Top = 6
               Left = 284
               Bottom = 329
               Right = 516
            End
            DisplayFlags = 280
            TopColumn = 57
         End
         Begin Table = "serviceexception"
            Begin Extent = 
               Top = 0
               Left = 47
               Bottom = 388
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 3
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      PaneHidden = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
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
', 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Filter', NULL, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', NULL, NULL
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_FilterOnLoad', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', NULL, NULL
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_HideNewField', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_OrderBy', NULL, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', NULL, NULL
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_OrderByOn', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', NULL, NULL
GO
DECLARE @xp bit
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_OrderByOnLoad', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', NULL, NULL
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_Orientation', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=10000
EXEC sp_addextendedproperty N'MS_TableMaxRecords', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', NULL, NULL
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TotalsRow', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Acción Correctiva'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Acción Correctiva'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Acción Correctiva'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Acción Correctiva'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Acción Correctiva'
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Acción Inmediata'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Acción Inmediata'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Acción Inmediata'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Acción Inmediata'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Acción Inmediata'
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Asignado a'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Asignado a'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Asignado a'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Asignado a'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Asignado a'
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Cliente'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Cliente'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Cliente'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Cliente'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Cliente'
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Código'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Código'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Código'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Código'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Código'
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Creado por'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Creado por'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Creado por'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Creado por'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Creado por'
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Descripción Falla'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Descripción Falla'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Descripción Falla'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Descripción Falla'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Descripción Falla'
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Día'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Día'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Día'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Día'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Día'
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Fecha'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Fecha'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Fecha'
GO
DECLARE @xp smallint
SELECT @xp=3105
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Fecha'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Fecha'
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Lider'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Lider'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Lider'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Lider'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Lider'
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Mes'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Mes'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Mes'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Mes'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Mes'
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Orden'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Orden'
GO
DECLARE @xp smallint
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Orden'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Orden'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Orden'
GO
DECLARE @xp int
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_AggregateType', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Tarde a'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Tarde a'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Tarde a'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Tarde a'
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_TextAlign', @xp, 'SCHEMA', N'dbo', 'VIEW', N'SAC_Service_exception', 'COLUMN', N'Tarde a'
GO
