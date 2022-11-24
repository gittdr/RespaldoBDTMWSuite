SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [dbo].[Vista_gratificaciones_Roger_Junio]
AS
SELECT        TOP (100) PERCENT COUNT(*) AS veces, SUM(pd.pyd_amount) AS monto,  dbo.orderheader.ord_tractor as Tractor, Codigos_comprobacion.descripcion, pd.pyd_description,DATEPART(year, pd.pyd_createdon) AS añocrea, DATEPART(month, pd.pyd_createdon) AS mescrea, 
                         dbo.orderheader.ord_hdrnumber AS NoOrden, dbo.orderheader.ord_completiondate AS fechaorden, pd.asgn_id AS Operador,
                             (SELECT        SUM(lgh_miles) AS Expr1
                               FROM            dbo.legheader
                           WHERE        (ord_hdrnumber = dbo.orderheader.ord_hdrnumber)) AS Kms,
                             (SELECT        name
                               FROM            dbo.labelfile
                               WHERE        (labeldefinition = 'RevType3') AND (abbr = dbo.orderheader.ord_revtype3)) AS proyOrden
							   ,Codigos_comprobacion.[TipoAtribucion],pd.pyd_createdon 
							   ,(Select max([proyecto]) from [dbo].[TractorProyHistory] tph where tph.[trc_number] = dbo.orderheader.ord_tractor and tph.[fecha] = cast(pd.pyd_createdon as date)) as proye,
							    pd.pyh_payperiod as fechapago,
							   orderheader.ord_revtype4 as EC,
							   (select cty_name from city where cty_code =  pd.lgh_startcity) as ciudad
FROM            dbo.paydetail AS pd WITH (nolock) 
						 INNER JOIN dbo.Codigos_comprobacion AS Codigos_comprobacion ON ISNULL(pd.pyd_tprsplit_number, 50) = Codigos_comprobacion.id_codigo 
						 LEFT OUTER JOIN dbo.paytype AS pt WITH (nolock) ON pd.pyt_itemcode = pt.pyt_itemcode 
						 INNER JOIN dbo.orderheader ON pd.mov_number = dbo.orderheader.mov_number
WHERE        (pd.pyt_itemcode IN ('COMGRA')) AND (pd.pyd_createdon > '01-01-2020') AND (pd.asgn_id <> 'PROVEEDO') AND (pd.pyd_createdby <> 'sa')
GROUP BY DATEPART(year, pd.pyd_createdon), DATEPART(month, pd.pyd_createdon),  dbo.orderheader.ord_tractor,Codigos_comprobacion.descripcion,pd.pyd_description ,dbo.orderheader.ord_revtype3, dbo.orderheader.ord_hdrnumber, pd.asgn_id, 
                         dbo.orderheader.ord_completiondate,Codigos_comprobacion.[TipoAtribucion],pd.pyd_createdon ,
						 pd.pyh_payperiod ,
							   orderheader.ord_revtype4 , pd.lgh_startcity
						 ORDER BY añocrea desc, mescrea desc
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
         Begin Table = "Codigos_comprobacion"
            Begin Extent = 
               Top = 6
               Left = 334
               Bottom = 102
               Right = 543
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pt"
            Begin Extent = 
               Top = 6
               Left = 581
               Bottom = 136
               Right = 830
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "orderheader"
            Begin Extent = 
               Top = 6
               Left = 868
               Bottom = 136
               Right = 1140
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
      Begin ColumnWidths = 12
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
      En', 'SCHEMA', N'dbo', 'VIEW', N'Vista_gratificaciones_Roger_Junio', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'd
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'Vista_gratificaciones_Roger_Junio', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Vista_gratificaciones_Roger_Junio', NULL, NULL
GO
