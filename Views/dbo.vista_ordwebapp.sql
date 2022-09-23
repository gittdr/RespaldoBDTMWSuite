SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [dbo].[vista_ordwebapp]
AS
SELECT     dbo.orderheader.ord_billto AS cliente, 
RTRIM(dbo.orderheader.ord_number) AS orden, 
(select mpp_firstname+' '+mpp_lastname from manpowerprofile where mpp_id = dbo.orderheader.ord_driver1) AS operador, 
dbo.orderheader.ord_driver1 as drvid,

case when dbo.orderheader.ord_status = 'STD' then
(select  RTRIM((legheader_active.lgh_tractor)) from legheader_active
 where   dbo.orderheader.ord_hdrnumber = legheader_active.ord_hdrnumber and legheader_active.lgh_tractor <> 'UNKNOWN'
 and lgh_number = (select max(lgh_number) from legheader_Active where dbo.orderheader.ord_hdrnumber = legheader_active.ord_hdrnumber and legheader_active.lgh_tractor <> 'UNKNOWN')
 )
else
(select  RTRIM(max(legheader.lgh_tractor)) from legheader where   dbo.orderheader.ord_hdrnumber = legheader.ord_hdrnumber and legheader.lgh_tractor <> 'UNKNOWN')
end  AS tractor,  

case when dbo.orderheader.ord_status = 'STD' then
(select  RTRIM(max(legheader_active.lgh_primary_trailer)) from legheader_active where   dbo.orderheader.ord_hdrnumber = legheader_active.ord_hdrnumber
and lgh_number = (select max(lgh_number) from legheader_Active where dbo.orderheader.ord_hdrnumber = legheader_active.ord_hdrnumber and legheader_active.lgh_tractor <> 'UNKNOWN'))
else
(select RTRIM(max(lgh_primary_trailer)) from legheader where   dbo.orderheader.ord_hdrnumber = legheader.ord_hdrnumber) 
end AS remolque, 

case when dbo.orderheader.ord_status = 'STD' then
(select  RTRIM(max(legheader_active.lgh_primary_pup)) from legheader_active where   dbo.orderheader.ord_hdrnumber = legheader_active.ord_hdrnumber
and lgh_number = (select max(lgh_number) from legheader_Active where dbo.orderheader.ord_hdrnumber = legheader_active.ord_hdrnumber and legheader_active.lgh_tractor <> 'UNKNOWN'))
else
(select RTRIM(max(lgh_primary_pup)) from legheader where   dbo.orderheader.ord_hdrnumber = legheader.ord_hdrnumber) 
end AS remolque2, 

                      dbo.orderheader.ord_description AS descripcion, dbo.orderheader.ord_startdate AS inicio, 
                      dbo.orderheader.ord_completiondate AS completada,
                          (SELECT     cmp_name
                            FROM          dbo.company
                            WHERE      (dbo.orderheader.ord_originpoint = cmp_id)) AS origen,
                          (SELECT     cmp_name
                            FROM          dbo.company AS company_1
                            WHERE      (dbo.orderheader.ord_destpoint = cmp_id)) AS destino, 
							dbo.orderheader.ord_invoicestatus AS statusfactura, 


(select RTRIM(max(dbo.legheader.lgh_outstatus)) from legheader where   dbo.orderheader.ord_hdrnumber = legheader.ord_hdrnumber)
AS statusorden, 

                      RTRIM(dbo.orderheader.ord_refnum) AS referencia
FROM         dbo.orderheader 

--- INNER JOIN                      dbo.legheader ON dbo.orderheader.ord_hdrnumber = dbo.legheader.ord_hdrnumber
WHERE     (dbo.orderheader.ord_status  IN ('STD', 'CMP','PLN','DSP')) AND (YEAR(dbo.orderheader.ord_startdate) > 2011)



 ---AND (dbo.legheader.lgh_outstatus NOT IN ('MST', 'AVL', 'CAN', 'ICO', 'DSP'))








GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[43] 4[20] 2[26] 3) )"
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
         Begin Table = "orderheader"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 347
               Right = 270
            End
            DisplayFlags = 280
            TopColumn = 15
         End
         Begin Table = "legheader"
            Begin Extent = 
               Top = 8
               Left = 500
               Bottom = 340
               Right = 714
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
      Begin ColumnWidths = 13
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 2835
         Width = 1440
         Width = 3045
         Width = 3270
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_ordwebapp', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_ordwebapp', NULL, NULL
GO
