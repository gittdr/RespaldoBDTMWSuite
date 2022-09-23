SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vista_ant_y_gastos_parte1]
AS
SELECT pd.pyt_itemcode, pt.pyt_description, pd.asgn_id, pd.ord_hdrnumber, pd.mov_number, pd.pyd_description, pd.pyd_amount, pd.pyd_createdon, pd.pyh_payperiod, 
                  DATEPART(year, pd.pyh_payperiod) AS aniopago, DATEPART(month, pd.pyh_payperiod) AS mespago, DATEPART(week, pd.pyh_payperiod) AS semanapago, DATEPART(day, 
                  pd.pyh_payperiod) AS diapago, DATEPART(year, pd.pyd_createdon) AS aniocrea, DATEPART(month, pd.pyd_createdon) AS mescrea, DATEPART(week, pd.pyd_createdon) 
                  AS semanacrea, DATEPART(day, pd.pyd_createdon) AS diacre, pd.pyd_authcode, pd.pyd_createdby, pd.pyd_status, DATEDIFF(day, pd.pyd_createdon, pd.pyh_payperiod) 
                  AS difdias, dbo.legheader.lgh_tractor AS tractor,
                      (SELECT name
                       FROM      dbo.labelfile
                       WHERE   (abbr = dbo.legheader.lgh_class3) AND (labeldefinition = 'Revtype3')) AS proyecto, dbo.ttsusers.usr_fname, dbo.ttsusers.usr_lname, 
                  dbo.ttsusers.usr_type2 AS sucursal, CASE LEFT(pt.pyt_description, 1) WHEN '%' THEN 'Comprobacion' ELSE 'Anticipo' END AS Expr1, pd.pyd_remarks, 
                  dbo.orderheader.ord_billto, dbo.legheader.cmp_id_start, dbo.legheader.cmp_id_end
FROM     dbo.paydetail AS pd WITH (nolock) INNER JOIN
                  dbo.paytype AS pt WITH (nolock) ON pd.pyt_itemcode = pt.pyt_itemcode INNER JOIN
                  dbo.legheader WITH (nolock) ON pd.lgh_number = dbo.legheader.lgh_number INNER JOIN
                  dbo.orderheader ON pd.mov_number = dbo.orderheader.mov_number LEFT OUTER JOIN
                  dbo.ttsusers WITH (nolock) ON pd.pyd_createdby = dbo.ttsusers.usr_userid
WHERE  (pd.pyt_itemcode IN ('COMGRA', 'ANTOP', 'ANTTER', 'ANTMAN', 'COMAN', 'COMEST', 'COMTAL', 'COMGAS', 'COMMAN', 'COMFER', 'COMREP', 'COMTRA', 'COMENL', 'COMTEL', 
                  'COMHOS', 'COMFE', 'COMBUS', 'MENS', 'CASEFE', 'COMTAX', 'COMEFE', 'ASOFIJ', 'COMCOM', 'VALECO', 'COBEST', 'SINIES', 'LUCYM', 'DESCAN', 'CREF', 'LAVA', 'VALEEL', 
                  'CMELEC', 'COMPER', 'ECC', 'COMNFA', 'AC', 'AT', 'EM')) AND (pd.pyd_createdon > '01-01-2015') AND (pd.asgn_id <> 'PROVEEDO') AND (pd.pyd_createdby <> 'sa')
				   and dbo.orderheader.ord_status = 'CMP' 
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[51] 4[15] 2[9] 3) )"
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
         Begin Table = "pd"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 279
               Right = 354
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "pt"
            Begin Extent = 
               Top = 7
               Left = 402
               Bottom = 168
               Right = 694
            End
            DisplayFlags = 280
            TopColumn = 17
         End
         Begin Table = "legheader"
            Begin Extent = 
               Top = 0
               Left = 733
               Bottom = 276
               Right = 1048
            End
            DisplayFlags = 280
            TopColumn = 27
         End
         Begin Table = "orderheader"
            Begin Extent = 
               Top = 168
               Left = 402
               Bottom = 329
               Right = 727
            End
            DisplayFlags = 280
            TopColumn = 21
         End
         Begin Table = "ttsusers"
            Begin Extent = 
               Top = 142
               Left = 1283
               Bottom = 303
               Right = 1570
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
      Begin ColumnWidths = 30
         Width = 284
         Width = 1200
         Width = 2832
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Widt', 'SCHEMA', N'dbo', 'VIEW', N'vista_ant_y_gastos_parte1', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'h = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
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
         SortType = 960
         SortOrder = 996
         GroupBy = 1350
         Filter = 29928
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vista_ant_y_gastos_parte1', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_ant_y_gastos_parte1', NULL, NULL
GO
