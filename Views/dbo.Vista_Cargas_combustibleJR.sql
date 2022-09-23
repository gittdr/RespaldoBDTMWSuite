SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Vista_Cargas_combustibleJR]
AS
SELECT        pd.ord_hdrnumber, pd.mov_number, pur.fp_id, pur.fp_cardnumber, pur.fp_cac_id, pur.fp_purchcode, pur.fp_date, pur.fp_quantity, pur.fp_uom, pur.fp_fueltype, pur.fp_trc_trl, pur.fp_cost_per, pur.fp_amount, pur.trc_number, 
                         pur.mpp_id, pur.ts_code, pur.fp_vendorname, pur.fp_cityname, pur.fp_city, pur.fp_state, pur.fp_enteredby, pur.fp_status,
                             (SELECT        MAX(mpp_id + ' | ' + mpp_lastfirst) AS Expr1
                               FROM            dbo.manpowerprofile
                               WHERE        (mpp_tractornumber = pur.trc_number)) AS operador,
                             (SELECT        MAX(dbo.labelfile.name) AS Expr1
                               FROM            dbo.manpowerprofile AS manpowerprofile_1 INNER JOIN
                                                         dbo.labelfile ON manpowerprofile_1.mpp_type3 = dbo.labelfile.abbr
                               WHERE        (dbo.labelfile.labeldefinition = 'DrvType3') AND (manpowerprofile_1.mpp_tractornumber = pur.trc_number)) AS proyecto,
                             (SELECT        MAX(trc_gps_desc) AS Expr1
                               FROM            dbo.tractorprofile
                               WHERE        (trc_number = pur.trc_number)) AS Localidad
FROM            dbo.paydetail AS pd INNER JOIN
                         dbo.purchased_paydetail ON pd.pyd_number = dbo.purchased_paydetail.pp_paydetail INNER JOIN
                         dbo.fuelpurchased AS pur ON dbo.purchased_paydetail.pp_consecutivo = pur.fp_id
WHERE        (pd.asgn_type = 'TPR') AND (pd.asgn_id <> 'PROVEEDO') AND (pur.fp_date > DATEADD(dd, - 20, GETDATE()))
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
         Begin Table = "pd"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 296
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "purchased_paydetail"
            Begin Extent = 
               Top = 6
               Left = 334
               Bottom = 102
               Right = 543
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pur"
            Begin Extent = 
               Top = 6
               Left = 581
               Bottom = 136
               Right = 790
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
      Begin ColumnWidths = 11
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
', 'SCHEMA', N'dbo', 'VIEW', N'Vista_Cargas_combustibleJR', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Vista_Cargas_combustibleJR', NULL, NULL
GO
