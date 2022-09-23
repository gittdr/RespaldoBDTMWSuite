SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vista_tractorscompany]
AS
SELECT   
   trc_number AS Tractor, 
   trc_avl_date AS Fecha,
   DATEDIFF(dd, trc_avl_date, GETDATE()) AS DIFDIAS, 
   DATEDIFF(dd, trc_avl_date, GETDATE()) AS DIAS,
   (SELECT  name FROM   dbo.labelfile WITH (nolock) WHERE        (labeldefinition = 'Fleet') AND (abbr = dbo.tractorprofile.trc_fleet)) AS FLOTA,

   (SELECT  name FROM  dbo.labelfile AS labelfile_2 WITH (nolock)  WHERE (labeldefinition = 'trcstatus') AND (abbr = dbo.tractorprofile.trc_status)) AS StatusTractor, 

	case 
	when dbo.tractorprofile.trc_status = 'PLN'
	then 
	(select 'Segmento Planeado: ' + cast(max(lgh_number) as varchar(20)) from legheader where lgh_outstatus = 'PLN' and lgh_tractor = dbo.tractorprofile.trc_number)
	when dbo.tractorprofile.trc_status = 'USE'
	then 
	(select 'Segmento Iniciado: ' + cast(max(lgh_number) as varchar(20)) from legheader where lgh_outstatus = 'STD' and lgh_tractor = dbo.tractorprofile.trc_number)
	
	else
	ISNULL 
	((SELECT  MAX(exp_description) AS Expr1 FROM            dbo.expiration  WHERE        (exp_idtype = 'TRC') AND 
	(exp_id = dbo.tractorprofile.trc_number) AND (exp_completed <> 'Y') AND ( replace(exp_code,'SALV','INSHOP') = dbo.tractorprofile.trc_status)), 'NA')  end AS StatusDesc,
	
	trc_avl_cmp_id AS Patio,
	
	CASE WHEN trc_driver = 'UNKNOWN' THEN 'Unseated' ELSE 'Seated' END AS Asignacion,
	
	RTRIM(trc_gps_desc) + ' (' + RTRIM(trc_gps_date) AS Ultpos,
    
	(SELECT  rgh_name FROM  dbo.regionheader WITH (nolock)  WHERE        (rgh_id = (SELECT        cmp_region1    FROM            dbo.company  
	WHERE        (cmp_id = dbo.tractorprofile.trc_avl_cmp_id)))) AS Region,

    (SELECT mpp_id + ':' + mpp_firstname + ' ' + mpp_lastname AS Expr1  FROM  dbo.manpowerprofile  WHERE (mpp_id = dbo.tractorprofile.trc_driver)) AS Driver,

    (SELECT name  FROM  dbo.labelfile AS labelfile_1 WITH (nolock)  WHERE        (labeldefinition = 'RevType3') AND (abbr =
    (SELECT cmp_revtype3  FROM            dbo.company AS company_1 WITH (nolock) WHERE        (cmp_id = dbo.tractorprofile.trc_avl_cmp_id)))) AS Proyecto,

    (SELECT name  FROM   dbo.labelfile AS labelfile_1 WITH (nolock)  WHERE     
	(labeldefinition = 'RevType3') AND (abbr = dbo.tractorprofile.trc_type3)) AS DescProyTrc, trc_type3 AS ProyTrc, trc_owner AS propietario,

    (SELECT name  FROM            dbo.labelfile AS labelfile_3 WITH (nolock)  WHERE 
	(labeldefinition = 'TeamLeader') AND (abbr = dbo.tractorprofile.trc_teamleader)) AS lider

FROM            dbo.tractorprofile WITH (nolock)
WHERE        (trc_status NOT IN ('OUT')) AND (trc_number <> 'UNKNOWN') and trc_owner = 'TDR'


GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[3] 2[46] 3) )"
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
         Begin Table = "tractorprofile"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 148
               Right = 342
            End
            DisplayFlags = 280
            TopColumn = 172
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 17
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_tractorscompany', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_tractorscompany', NULL, NULL
GO
