SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Vista_Liquidaciones_conceptos_JR]
AS
SELECT        CONVERT(varchar(12), dbo.payheader.pyh_payperiod, 110) AS fechapago, DATEPART(ww, dbo.payheader.pyh_payperiod) AS semana, DATEPART(mm, dbo.payheader.pyh_payperiod) AS mes, DATEPART(yyyy, 
                         dbo.payheader.pyh_payperiod) AS año, dbo.payheader.asgn_id AS IDOperador, dbo.payheader.pyh_pyhnumber AS NumLiquidacion, dbo.manpowerprofile.mpp_type3 AS Proyecto, 
                         dbo.manpowerprofile.mpp_status AS estatus,
                             (SELECT        name
                               FROM            dbo.labelfile
                               WHERE        (abbr = dbo.manpowerprofile.mpp_type3) AND (labeldefinition = 'DrvType3')) AS DrvOperador, CASE WHEN
                             (SELECT        IsNull(SUM(isnull(pyd_amount, 0)), 0)
                               FROM            paydetail
                               WHERE        pyh_number = payheader.pyh_pyhnumber AND pyt_itemcode NOT IN ('MN+')) < 0 THEN 0 ELSE
                             (SELECT        IsNull(SUM(isnull(pyd_amount, 0)), 0)
                               FROM            paydetail
                               WHERE        pyh_number = payheader.pyh_pyhnumber AND pyt_itemcode NOT IN ('MN+')) END AS Deposito,
                             (SELECT        ISNULL(SUM(ISNULL(pyd_amount, 0)), 0) * - 1 AS Expr1
                               FROM            dbo.paydetail
                               WHERE        (pyt_itemcode IN ('MN+')) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) AS Debe,
                             (SELECT        ISNULL(SUM(ISNULL(pyd_amount, 0)), 0) AS Expr1
                               FROM            dbo.paydetail AS paydetail_5
                               WHERE        (pyt_itemcode IN ('MN-')) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) AS DebePerPasados,
                             (SELECT        ISNULL(SUM(ISNULL(pyd_amount, 0)), 0) AS Expr1
                               FROM            dbo.paydetail AS paydetail_4
                               WHERE        (pyt_itemcode IN ('TDDE')) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) AS anticipoTDDE,
                             (SELECT        ISNULL(SUM(ISNULL(pyd_amount, 0)), 0) AS Expr1
                               FROM            dbo.paydetail AS paydetail_4
                               WHERE        (pyt_itemcode IN ('ANTTER', 'AT', 'ANTCEF', 'ANTCAS', 'ANTMAN', 'ANTNF', 'ANTOP', 'VIATIC', 'AC')) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) AS Anticipos,
                             (SELECT        ISNULL(SUM(ISNULL(pyd_amount, 0)), 0) AS Expr1
                               FROM            dbo.paydetail AS paydetail_4
                               WHERE        (pyt_itemcode IN ('TDDE', 'ANTTER', 'AT', 'ANTCEF', 'ANTCAS', 'ANTMAN', 'ANTNF', 'ANTOP')) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) AS AnticiposTotales,
                             (SELECT        ISNULL(SUM(ISNULL(pyd_amount, 0)), 0) AS Expr1
                               FROM            dbo.paydetail AS paydetail_3
                               WHERE        (pyd_pretax = 'Y') AND (pyd_amount > 0) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) AS Ingreso,
                             (SELECT        ISNULL(SUM(ISNULL(pyd_amount, 0)), 0) AS Expr1
                               FROM            dbo.paydetail AS paydetail_2
                               WHERE        (pyt_itemcode NOT IN ('MN-', 'TDDE', 'ANTTER', 'AT', 'ANTCEF', 'ANTCAS', 'ANTMAN', 'ANTNF', 'ANTOP', 'VIATIC', 'AC')) AND (pyd_amount < 0) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) 
                         AS Retencion,
                             (SELECT        ISNULL(SUM(ISNULL(pyd_amount, 0)), 0) AS Expr1
                               FROM            dbo.paydetail AS paydetail_3
                               WHERE        (pyd_pretax = 'Y') AND (pyd_amount > 0) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) -
                             (SELECT        ISNULL(SUM(ISNULL(- (1 * pyd_amount), 0)), 0) AS Expr1
                               FROM            dbo.paydetail AS paydetail_2
                               WHERE        (pyt_itemcode NOT IN ('MN-', 'TDDE', 'ANTTER', 'AT', 'ANTCEF', 'ANTCAS', 'ANTMAN', 'ANTNF', 'ANTOP')) AND (pyd_amount < 0) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) 
                         AS IngresoMenosRetenciones,
                             (SELECT        ISNULL(SUM(ISNULL(pyd_amount, 0)), 0) AS Expr1
                               FROM            dbo.paydetail AS paydetail_1
                               WHERE        (pyd_pretax = 'N') AND (pyd_amount > 0) AND (pyh_number = dbo.payheader.pyh_pyhnumber) AND (pyt_itemcode NOT IN ('MN+'))) AS Comprobaciones, ISNULL
                             ((SELECT        drd_default
                                 FROM            dbo.driverdocument
                                 WHERE        (drd_doctype = 'TDDE') AND (mpp_id = dbo.payheader.asgn_id)), 'N') AS TDDE,
                             (SELECT        ISNULL(SUM(ISNULL(- (1 * pyd_amount), 0)), 0) AS Expr1
                               FROM            dbo.paydetail AS paydetail_2
                               WHERE        (pyt_itemcode IN ('MN-', 'MN+')) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) AS LIQENCONTRA,
                             (SELECT        ISNULL(SUM(ISNULL(pyd_amount, 0)), 0) AS Expr1
                               FROM            dbo.paydetail AS paydetail_3
                               WHERE        (pyd_pretax = 'Y') AND (pyd_amount > 0) AND (pyh_number = dbo.payheader.pyh_pyhnumber)) AS PAGOXKMS
FROM            dbo.payheader INNER JOIN
                         dbo.manpowerprofile ON dbo.payheader.asgn_id = dbo.manpowerprofile.mpp_id
WHERE        (dbo.payheader.pyh_payperiod > '2016-01-01') AND (dbo.payheader.pyh_paystatus IN ('XFR', 'REL'))
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[10] 2[48] 3) )"
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
      Begin ColumnWidths = 22
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
         Width = 1500
         Width = 1500
         Width = 1500
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
', 'SCHEMA', N'dbo', 'VIEW', N'Vista_Liquidaciones_conceptos_JR', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Vista_Liquidaciones_conceptos_JR', NULL, NULL
GO
