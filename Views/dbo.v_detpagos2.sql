SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[v_detpagos2]
AS
SELECT     dbo.vTTSTMW_PayDetails.DrvType3 AS proyecto, dbo.vTTSTMW_PayDetails.[Pay Period Date Only], 
                      dbo.vTTSTMW_PayDetails.[Pay Type Description] + '|' + SUBSTRING(dbo.vTTSTMW_PayDetails.GLCode, 5, 8) AS [Pay Type Description], 
                      RTRIM(dbo.vTTSTMW_PayDetails.[Resource ID]) + ' | ' + dbo.vTTSTMW_PayDetails.[Pay To Name] AS driver, dbo.vTTSTMW_PayDetails.Amount, 
                      dbo.vTTSTMW_PayDetails.[Work Period Date], SUBSTRING(dbo.vTTSTMW_PayDetails.GLCode, 5, 2) AS ccont, CASE SUBSTRING(GLCode, 5, 2) 
                      WHEN '52' THEN 'Driver Salaries, Wages & Benefits' WHEN '51' THEN 'Non-Driver Salaries, Wages & Benefits' WHEN '54' THEN 'Fuel & Fuel Taxes' WHEN
                       '55' THEN 'Tolls' WHEN '53' THEN 'Operating Supplies % Maintenance' WHEN '56' THEN 'General Supplies' WHEN '57' THEN 'Taxes and Licenses' WHEN
                       '58' THEN 'Insurance & Claims' WHEN '61' THEN 'Rents - Revenue Equipment' WHEN '63' THEN 'Brokered Freight' WHEN '64' THEN 'Comunication & Utilies'
                       WHEN '66' THEN 'Other' WHEN '11' THEN 'Advances' ELSE 'Other' END AS acclaf, dbo.tractorprofile.trc_type1
FROM         dbo.vTTSTMW_PayDetails INNER JOIN
                      dbo.tractorprofile ON dbo.vTTSTMW_PayDetails.TrcType1 = dbo.tractorprofile.trc_type1
WHERE     (dbo.vTTSTMW_PayDetails.[Pay Period Date Only] > '01/01/2011')
GO
DECLARE @xp tinyint
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DefaultView', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[13] 3) )"
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
      ActivePaneConfig = 8
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vTTSTMW_PayDetails"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 232
               Right = 324
            End
            DisplayFlags = 280
            TopColumn = 13
         End
         Begin Table = "tractorprofile"
            Begin Extent = 
               Top = 35
               Left = 437
               Bottom = 150
               Right = 651
            End
            DisplayFlags = 280
            TopColumn = 4
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      PaneHidden = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 225
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
', 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Filter', NULL, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_OrderBy', NULL, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', NULL, NULL
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_OrderByOn', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', NULL, NULL
GO
DECLARE @xp tinyint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_Orientation', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=10000
EXEC sp_addextendedproperty N'MS_TableMaxRecords', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', NULL, NULL
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'acclaf'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'acclaf'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'acclaf'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'Amount'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'Amount'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'Amount'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'ccont'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'ccont'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'ccont'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'driver'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'driver'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'driver'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'Pay Period Date Only'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'Pay Period Date Only'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'Pay Period Date Only'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'Pay Type Description'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'Pay Type Description'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'Pay Type Description'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'proyecto'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'proyecto'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'proyecto'
GO
DECLARE @xp bit
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnHidden', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'Work Period Date'
GO
DECLARE @xp smallint
SELECT @xp=0
EXEC sp_addextendedproperty N'MS_ColumnOrder', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'Work Period Date'
GO
DECLARE @xp smallint
SELECT @xp=-1
EXEC sp_addextendedproperty N'MS_ColumnWidth', @xp, 'SCHEMA', N'dbo', 'VIEW', N'v_detpagos2', 'COLUMN', N'Work Period Date'
GO
