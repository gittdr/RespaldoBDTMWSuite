SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vista_legdriver_src]
AS
SELECT     ISNULL(dbo.manpowerprofile.mpp_id, '') AS Resource, ISNULL(dbo.manpowerprofile.mpp_lastfirst, dbo.manpowerprofile.mpp_id) AS DriverName,
                          (SELECT     IsNull(SUM(stp_lgh_mileage), 0)
                            FROM          stops(NOLOCK)
                            WHERE      stops.lgh_number = legheader.lgh_number) AS TravelMiles,
                          (SELECT     IsNull(SUM(stp_lgh_mileage), 0)
                            FROM          stops(NOLOCK)
                            WHERE      stops.lgh_number = legheader.lgh_number AND stops.stp_loadstatus = 'LD') AS LoadedMiles,
                          (SELECT     IsNull(SUM(stp_lgh_mileage), 0)
                            FROM          stops(NOLOCK)
                            WHERE      stops.lgh_number = legheader.lgh_number AND stops.stp_loadstatus <> 'LD') AS EmptyMiles, dbo.legheader.lgh_startdate, 
                      dbo.legheader.lgh_enddate, DAY(dbo.legheader.lgh_enddate) AS dia, YEAR(dbo.legheader.lgh_enddate) AS anio, 
                      CASE MONTH(dbo.legheader.lgh_enddate) 
                      WHEN 12 THEN 'Diciembre' WHEN 11 THEN 'Noviembre' WHEN 10 THEN 'Octubre' WHEN 9 THEN 'Septiembre' WHEN 8 THEN 'Agosto' WHEN 7 THEN
                       'Julio' WHEN 6 THEN 'Junio' WHEN 5 THEN 'Mayo' WHEN 4 THEN 'Abril' WHEN 3 THEN 'Marzo' WHEN 2 THEN 'Febrero' WHEN 1 THEN 'Enero' ELSE
                       ' ' END AS mes, CASE YEAR(dbo.legheader.lgh_enddate) WHEN 2012 THEN DATEPART(ww, dbo.legheader.lgh_enddate) ELSE DATEPART(ww, 
                      dbo.legheader.lgh_enddate) - 1 END AS semana, dbo.manpowerprofile.mpp_type1 AS equip, dbo.manpowerprofile.mpp_type2 AS drvtype, 
                      dbo.manpowerprofile.mpp_type3 AS proj, dbo.manpowerprofile.mpp_type4 AS div, dbo.manpowerprofile.mpp_tractornumber, 
                      'ORDER: ' + RTRIM(dbo.orderheader.ord_number) 
                      + ' DRV:' + dbo.manpowerprofile.mpp_id + ' TRUCK:' + dbo.manpowerprofile.mpp_tractornumber + ' LEADER:' + dbo.manpowerprofile.mpp_teamleader +
                       ' BILLTO:' + dbo.orderheader.ord_billto AS drvtr, dbo.manpowerprofile.mpp_status, dbo.legheader.lgh_linehaul, 
                      dbo.legheader.lgh_ord_charge AS lgh_ord_chg_org, dbo.legheader.lgh_miles, CASE WHEN dbo.legheader.lgh_miles > 0 AND 
                      dbo.legheader.lgh_linehaul > 0 THEN (dbo.legheader.lgh_linehaul / dbo.legheader.lgh_miles) END AS RevTot, dbo.legheader.ord_hdrnumber, 
                      dbo.orderheader.ord_revtype2, dbo.orderheader.ord_rate, dbo.orderheader.ord_currency, 
                      CASE WHEN ORDERHEADER.ORD_Currency = 'US$' THEN dbo.legheader.lgh_ord_charge *
                          (SELECT     cex_rate
                            FROM          currency_exchange
                            WHERE      (DAY(cex_date) =
                                                       (SELECT     fechamax = MAX(DAY(cex_date))
                                                         FROM          currency_exchange
                                                         WHERE      (MONTH(cex_date) = MONTH(GETDATE())) AND (YEAR(cex_date) = YEAR(GETDATE())))) AND (YEAR(cex_date) 
                                                   = YEAR(GETDATE())) AND (MONTH(cex_date) = MONTH(GETDATE()))) ELSE dbo.legheader.lgh_ord_charge END AS LGH_ord_charge, 
                      dbo.manpowerprofile.mpp_teamleader, dbo.orderheader.ord_status, dbo.orderheader.ord_tractor, dbo.tractorprofile.trc_fleet, dbo.vista_flotas.name, 
                      dbo.orderheader.ord_billto, CASE
                          ((SELECT     IsNull(SUM(stp_lgh_mileage), 0)
                              FROM         stops(NOLOCK)
                              WHERE     stops.lgh_number = legheader.lgh_number)) WHEN 0 THEN 0 ELSE dbo.legheader.lgh_ord_charge /
                          ((SELECT     IsNull(SUM(stp_lgh_mileage), 0)
                              FROM         stops(NOLOCK)
                              WHERE     stops.lgh_number = legheader.lgh_number)) END AS costokm
FROM         dbo.tractorprofile INNER JOIN
                      dbo.orderheader ON dbo.tractorprofile.trc_number = dbo.orderheader.ord_tractor LEFT OUTER JOIN
                      dbo.vista_flotas ON dbo.tractorprofile.trc_fleet = dbo.vista_flotas.ame RIGHT OUTER JOIN
                      dbo.legheader WITH (NOLOCK) RIGHT OUTER JOIN
                      dbo.manpowerprofile WITH (NOLOCK) ON dbo.manpowerprofile.mpp_id = dbo.legheader.lgh_driver1 AND YEAR(dbo.legheader.lgh_startdate) 
                      >= 2010 AND dbo.legheader.lgh_outstatus <> 'CAN' AND dbo.manpowerprofile.mpp_id <> 'UNKNOWN' ON RTRIM(dbo.orderheader.ord_hdrnumber) 
                      = RTRIM(dbo.legheader.ord_hdrnumber)
WHERE     (dbo.manpowerprofile.mpp_terminationdt > GETDATE() OR
                      dbo.manpowerprofile.mpp_terminationdt IS NULL) AND (dbo.legheader.lgh_carrier = 'UNK' OR
                      dbo.legheader.lgh_carrier = 'UNKNOWN' OR
                      dbo.legheader.lgh_carrier IS NULL) OR
                      (dbo.legheader.lgh_carrier = 'UNK' OR
                      dbo.legheader.lgh_carrier = 'UNKNOWN' OR
                      dbo.legheader.lgh_carrier IS NULL) AND (dbo.legheader.lgh_number IS NOT NULL) AND (dbo.orderheader.ord_number IS NOT NULL) AND 
                      (dbo.orderheader.ord_number <> '')

GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[47] 4[7] 2[30] 3) )"
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
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 35
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 14175
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_legdriver_src', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_legdriver_src', NULL, NULL
GO
