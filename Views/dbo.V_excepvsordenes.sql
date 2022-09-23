SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[V_excepvsordenes]
AS
SELECT     CAST(dbo.serviceexception.sxn_ord_hdrnumber AS varchar) AS Orden, dbo.orderheader.ord_tractor, 
                      CASE dbo.serviceexception.sxn_cmp_id WHEN 'PURINA' THEN 'NESTLE' WHEN 'JUMEXAPO' THEN 'C.ELORO' ELSE dbo.serviceexception.sxn_cmp_id END AS Cliente,
                       dbo.serviceexception.sxn_createdby AS [Creado por], dbo.serviceexception.sxn_expdate AS Fecha, dbo.serviceexception.sxn_expcode AS Código, 
                      dbo.serviceexception.sxn_asgn_id AS [Asignado a], dbo.serviceexception.sxn_description AS [Descripción Falla], 
                      dbo.serviceexception.sxn_action_description AS [Acción Inmediata], dbo.serviceexception.sxn_late AS [Tarde a], 
                      dbo.serviceexception.sxn_action_received_desc AS [Acción Correctiva], { fn MONTHNAME(dbo.serviceexception.sxn_expdate) } AS Mes, DATEPART(dd, 
                      dbo.serviceexception.sxn_expdate) AS Día, YEAR(dbo.serviceexception.sxn_expdate) AS Año, dbo.manpowerprofile.mpp_teamleader AS Lider, 1 AS Excepcion, 
                      0 AS Ordenes, 
                      CASE dbo.serviceexception.sxn_expcode WHEN 'OP' THEN 'Operaciones' WHEN 'DP' THEN 'Operaciones' WHEN 'FSL' THEN 'Operaciones' WHEN 'FDIS' THEN 'Operaciones'
                       WHEN 'LL' THEN 'Mantenimiento' WHEN 'CEQU' THEN 'Mantenimiento' WHEN 'FM' THEN 'Mantenimiento' WHEN 'FSC' THEN 'CEMS' WHEN 'DDES' THEN 'SAC' WHEN
                       'ESAC' THEN 'SAC' WHEN 'CU' THEN 'Externo' WHEN 'SIN' THEN 'Externo' WHEN 'CL' THEN 'Externo' WHEN 'LADB' THEN 'LAD' WHEN 'LADA' THEN 'LAD' WHEN 'LADP'
                       THEN 'LAD' WHEN 'SC' THEN 'Externo' ELSE 'Otros' END AS Arearesp, DATEPART(ww, dbo.serviceexception.sxn_expdate) AS semana, 
                      dbo.orderheader.ord_revtype2 AS terminal, 
                      CASE orderheader.ord_revtype4 WHEN 'FUL' THEN 'ESPECIALIZADO' WHEN 'SEN' THEN 'ABIERTO' WHEN 'INT' THEN 'ABIERTO' WHEN 'DED' THEN 'DEDICADO' WHEN
                       'ESP' THEN 'ESPECIALIZADO' ELSE orderheader.ord_revtype4 END AS proyecto, 
                      CASE dbo.serviceexception.sxn_expcode WHEN 'OP' THEN 'Problema operador' WHEN 'DP' THEN 'Error en Despacho' WHEN 'FSL' THEN 'Falta seguimiento líder' WHEN
                       'FDIS' THEN 'Falta de disponibilidad' WHEN 'LL' THEN 'Llantas' WHEN 'CEQU' THEN 'Control de equipo' WHEN 'FM' THEN 'Falla mecánica' WHEN 'FSC' THEN 'Falta seguimiento CEMS'
                       WHEN 'DDES' THEN 'Depósito a destiempo' WHEN 'ESAC' THEN 'Error en orden SAC' WHEN 'CU' THEN 'Custodia' WHEN 'SIN' THEN 'Siniestro' WHEN 'CL' THEN 'Clima'
                       WHEN 'SC' THEN 'Cierre Carretero' ELSE dbo.serviceexception.sxn_expcode END AS Codigo2, 
                      CASE ord_revtype2 WHEN 'GUD' THEN 'GUADALAJARA' WHEN 'MEX' THEN 'MÉXICO' WHEN 'MTE' THEN 'MONTERREY' WHEN 'QRO' THEN 'QUERÉTARO' WHEN 'LAD'
                       THEN 'NUEVO LAREDO' END AS Terminal1
FROM         dbo.manpowerprofile INNER JOIN
                      dbo.orderheader ON dbo.manpowerprofile.mpp_id = dbo.orderheader.ord_driver1 INNER JOIN
                      dbo.serviceexception ON dbo.orderheader.ord_hdrnumber = dbo.serviceexception.sxn_ord_hdrnumber
WHERE     (dbo.serviceexception.sxn_expdate > CONVERT(DATETIME, '2011-08-01 00:00:00', 102)) AND (dbo.serviceexception.sxn_expcode <> 'LT')
UNION
SELECT     CAST(orderheader_1.ord_number AS varchar) AS Orden, orderheader_1.ord_tractor, orderheader_1.ord_billto AS Cliente, ' ' AS [Creado por], 
                      orderheader_1.ord_completiondate AS Fecha, '' AS Código, '' AS [Asignado a], '' AS [Descripción Falla], '' AS [Acción Inmediata], '' AS [Tarde a], '' AS [Acción Correctiva],
                       { fn MONTHNAME(orderheader_1.ord_completiondate) } AS Mes, DATEPART(dd, orderheader_1.ord_completiondate) AS Día, YEAR(orderheader_1.ord_completiondate) 
                      AS Año, manpowerprofile_1.mpp_teamleader AS Lider, 0 AS Excepcion, 1 AS Ordenes, 'Ejecutadas' AS Arearesp, DATEPART(ww, orderheader_1.ord_completiondate) 
                      AS semana, orderheader_1.ord_revtype2 AS terminal, 
                      CASE orderheader_1.ord_revtype4 WHEN 'FUL' THEN 'ESPECIALIZADO' WHEN 'SEN' THEN 'ABIERTO' WHEN 'INT' THEN 'ABIERTO' WHEN 'DED' THEN 'DEDICADO' WHEN
                       'ESP' THEN 'ESPECIALIZADO' ELSE orderheader_1.ord_revtype4 END AS proyecto, '' AS Codigo2, 
                      CASE ord_revtype2 WHEN 'GUD' THEN 'GUADALAJARA' WHEN 'MEX' THEN 'MÉXICO' WHEN 'MTE' THEN 'MONTERREY' WHEN 'QRO' THEN 'QUERÉTARO' WHEN 'LAD'
                       THEN 'NUEVO LAREDO' END AS Terminal1
FROM         dbo.orderheader AS orderheader_1 INNER JOIN
                      dbo.manpowerprofile AS manpowerprofile_1 ON orderheader_1.ord_driver1 = manpowerprofile_1.mpp_id
WHERE     (orderheader_1.ord_completiondate > CONVERT(DATETIME, '2011-08-01 00:00:00', 102))
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
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[18] 2[23] 3) )"
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
      ActivePaneConfig = 3
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = -192
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
      Begin ColumnWidths = 24
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
         Width = 1950
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1890
         Width = 1440
         Width = 930
         Width = 1350
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 5
         Column = 5460
         Alias = 1905
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
', 'SCHEMA', N'dbo', 'VIEW', N'V_excepvsordenes', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'V_excepvsordenes', NULL, NULL
GO
