SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vista_ventas3]
AS
SELECT CASE (dbo.orderheader.ord_revtype4) 
               WHEN 'SEN' THEN 'ABIERTO' WHEN 'ESP' THEN 'ESPECIALIZADO' WHEN 'FUL' THEN 'ESPECIALIZADO' WHEN 'DED' THEN 'DEDICADO' WHEN 'INT' THEN 'INTERNACIONAL'
                END AS Division, dbo.orderheader.ord_company, dbo.manpowerprofile.mpp_teamleader AS leader, dbo.orderheader.ord_totalcharge AS ventas, 
               dbo.orderheader.ord_status AS Status, CASE (dbo.orderheader.ord_revtype2) 
               WHEN 'MEX' THEN 'México' WHEN 'GUD' THEN 'Guadalajara' WHEN 'QRO' THEN 'Querétaro' WHEN 'MTE' THEN 'Monterrey' WHEN 'LAD' THEN 'Nuevo Laredo' END AS
                Terminal, DAY(dbo.orderheader.ord_startdate) AS dia, YEAR(dbo.orderheader.ord_startdate) AS anio, CASE MONTH(dbo.orderheader.ord_startdate) 
               WHEN 12 THEN 'Diciembre' WHEN 11 THEN 'Noviembre' WHEN 10 THEN 'Octubre' WHEN 9 THEN 'Septiembre' WHEN 8 THEN 'Agosto' WHEN 7 THEN 'Julio' WHEN 6 THEN
                'Junio' WHEN 5 THEN 'Mayo' WHEN 4 THEN 'Abril' WHEN 3 THEN 'Marzo' WHEN 2 THEN 'Febrero' WHEN 1 THEN 'Enero' ELSE ' ' END AS mes, 
               dbo.orderheader.ord_driver1, MONTH(dbo.orderheader.ord_startdate) AS mes1, dbo.orderheader.ord_totalweight, dbo.orderheader.ord_startdate, 
               CASE WHEN ORDERHEADER.ORD_Currency = 'US$' THEN dbo.legheader.lgh_ord_charge *
                   (SELECT cex_rate
                    FROM   currency_exchange
                    WHERE (DAY(cex_date) =
                                       (SELECT fechamax = MAX(DAY(cex_date))
                                        FROM   currency_exchange
                                        WHERE (MONTH(cex_date) = MONTH(GETDATE())) AND (YEAR(cex_date) = YEAR(GETDATE())))) AND (YEAR(cex_date) = YEAR(GETDATE())) AND 
                                   (MONTH(cex_date) = MONTH(GETDATE()))) ELSE dbo.legheader.lgh_ord_charge END AS LGH_ord_charge, dbo.orderheader.ord_revtype1, 
               dbo.orderheader.ord_revtype3, dbo.orderheader.ord_invoicestatus
FROM  dbo.legheader INNER JOIN
               dbo.manpowerprofile ON dbo.legheader.lgh_driver1 = dbo.manpowerprofile.mpp_id INNER JOIN
               dbo.orderheader ON dbo.legheader.ord_hdrnumber = dbo.orderheader.ord_hdrnumber
WHERE (YEAR(dbo.orderheader.ord_startdate) > 2011) AND (MONTH(dbo.orderheader.ord_startdate) = 3)
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[39] 4[5] 2[22] 3) )"
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
         Begin Table = "legheader"
            Begin Extent = 
               Top = 27
               Left = 337
               Bottom = 168
               Right = 590
            End
            DisplayFlags = 280
            TopColumn = 196
         End
         Begin Table = "manpowerprofile"
            Begin Extent = 
               Top = 18
               Left = 632
               Bottom = 159
               Right = 928
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "orderheader"
            Begin Extent = 
               Top = 21
               Left = 19
               Bottom = 196
               Right = 294
            End
            DisplayFlags = 280
            TopColumn = 210
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 18
         Width = 284
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
         Width = 2064
         Width = 1200
         Width = 1200
         Width = 984
         Width = 1200
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_ventas3', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_ventas3', NULL, NULL
GO
