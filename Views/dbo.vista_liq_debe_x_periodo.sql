SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vista_liq_debe_x_periodo]
AS
SELECT        TOP (100) PERCENT CONVERT(varchar(12), dbo.payheader.pyh_payperiod, 110) AS fechapago, DATEPART(ww, dbo.payheader.pyh_payperiod) AS semana, DATEPART(mm, dbo.payheader.pyh_payperiod) AS mes,
                          DATEPART(yyyy, dbo.payheader.pyh_payperiod) AS año,
                             (SELECT        ISNULL(SUM(ISNULL(pyd_amount, 0)), 0) AS Expr1
                               FROM            dbo.paydetail
                               WHERE        (pyt_itemcode IN ('MN+')) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) AS Debe
FROM            dbo.payheader INNER JOIN
                         dbo.manpowerprofile ON dbo.payheader.asgn_id = dbo.manpowerprofile.mpp_id
WHERE        (dbo.payheader.pyh_payperiod > CONVERT(DATETIME, '2014-01-01 00:00:00', 102)) AND (dbo.payheader.pyh_paystatus IN ('XFR', 'REL')) AND
                             ((SELECT        ISNULL(SUM(ISNULL(pyd_amount, 0)), 0) AS Expr1
                                 FROM            dbo.paydetail AS paydetail_6
                                 WHERE        (pyt_itemcode IN ('MN+')) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) <> 0)
ORDER BY fechapago
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
         Begin Table = "payheader"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 248
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "manpowerprofile"
            Begin Extent = 
               Top = 6
               Left = 286
               Bottom = 136
               Right = 560
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_liq_debe_x_periodo', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_liq_debe_x_periodo', NULL, NULL
GO
