SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Vista_Rastreounidades]
AS
SELECT     TOP (100) PERCENT ord_tractor, ord_hdrnumber, ord_billto, ord_startdate, ord_originpoint, ord_destpoint, CASE WHEN ord_revtype4 IN ('ESP', 'DED') 
                      THEN 'Alta' ELSE 'Normal' END AS Prioridad, CASE WHEN ord_billto = 'ALMLIVER' AND
                          (SELECT     ckc_comment
                            FROM          checkcall
                            WHERE      ckc_tractor = ord_tractor AND ckc_number =
                                                       (SELECT     MAX(ckc_number)
                                                         FROM          checkcall
                                                         WHERE      ord_tractor = ckc_tractor)) IS NULL THEN '**SKY DEFENSE**' ELSE
                          (SELECT     ckc_comment
                            FROM          checkcall
                            WHERE      ckc_tractor = ord_tractor AND ckc_number =
                                                       (SELECT     MAX(ckc_number)
                                                         FROM          checkcall
                                                         WHERE      ord_tractor = ckc_tractor)) END AS Ubicacion,
                          (SELECT     ckc_date
                            FROM          dbo.checkcall
                            WHERE      (ckc_tractor = dbo.orderheader.ord_tractor) AND (ckc_number =
                                                       (SELECT     MAX(ckc_number) AS Expr1
                                                         FROM          dbo.checkcall AS checkcall_3
                                                         WHERE      (dbo.orderheader.ord_tractor = ckc_tractor)))) AS UltimaPosicion, DATEDIFF(mi,
                          (SELECT     ckc_date
                            FROM          dbo.checkcall AS checkcall_2
                            WHERE      (ckc_tractor = dbo.orderheader.ord_tractor) AND (ckc_number =
                                                       (SELECT     MAX(ckc_number) AS Expr1
                                                         FROM          dbo.checkcall AS checkcall_1
                                                         WHERE      (dbo.orderheader.ord_tractor = ckc_tractor)))), GETDATE()) AS MinSinAct,
                         (Select estatus from QSP.dbo.QFSVehicles  where displayname = ord_tractor) as Estado
FROM         dbo.orderheader
WHERE     (ord_status = 'STD') AND (ord_tractor <> 'UNKNOWN')
ORDER BY 'Prioridad', 'MinSinAct' DESC
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
         Begin Table = "orderheader"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 270
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
', 'SCHEMA', N'dbo', 'VIEW', N'Vista_Rastreounidades', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Vista_Rastreounidades', NULL, NULL
GO
