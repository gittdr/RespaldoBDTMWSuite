SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- select * from vista_eta

CREATE VIEW [dbo].[vista_eta]
AS
SELECT     

	lugar = cmp_name + ' | ' +  (SELECT      rtrim( isnull( alk_city,'') )  FROM            dbo.city WITH (nolock)  WHERE        (dbo.stops.stp_city = cty_code))  + ' | ' + 
	 (SELECT rtrim(isnull(name,'')) from labelfile with (NOLOCK) where  (labeldefinition = 'state' and abbr =  (SELECT        cty_state  FROM            dbo.city AS city_1 WITH (nolock)  WHERE        (stp_city = cty_code)))), 

	orden =  CAST(ord_hdrnumber AS varchar), 
	eta = 'Entre: ' + cast(stp_schdtearliest as varchar) + ' y ' + cast(stp_schdtlatest as varchar) ,
	tipoevento = cast(stp_sequence as varchar)  +' - ' + (SELECT     name FROM          dbo.eventcodetable  WHERE      (abbr = dbo.stops.stp_event)),
	estatus =  case  when stp_Status = 'DNE' then 'Completado Llego:'+ cast(stp_arrivaldate as varchar) + ' / Salio: ' + cast(stp_departuredate as varchar)  when stp_Status = 'OPN' then 'No Completado' else stp_status end,  --NON, OPN
    calif =  case when stp_Status ='DNE' and stp_arrivaldate <= stp_schdtlatest   then 'OnTime' 
                  when stp_Status ='OPN' then '----' 
             else 'OffTime' end,
   seq = stp_sequence,
   RutaEta =  				'https://www.google.com.mx/maps/dir/' + 
   
   (SELECT       rtrim(isnull(replace(alk_city,' ','+'),''))  FROM            dbo.city WITH (nolock)  WHERE        (dbo.stops.stp_city = cty_code))
     + ',+' + 
  (SELECT   rtrim(isnull(replace(name,' ','+'),'')) from labelfile with (NOLOCK) where  (labeldefinition = 'state' and abbr =  (SELECT        cty_state  FROM            dbo.city AS city_1 WITH (nolock)  WHERE        (stp_city = cty_code))))
     +'./' +
			CAST((select trc_gps_latitude from tractorprofile where trc_number = (select lgh_tractor from legheader where stops.lgh_Number = legheader.lgh_number) ) / 3600.00 AS varchar)  + ',-' +
			CAST((select trc_gps_longitude from tractorprofile where trc_number = (select lgh_tractor from legheader where stops.lgh_Number = legheader.lgh_number))/ 3600.00 AS varchar), 
         case when (stp_number) = ( select stp_number from stops st where st.mov_number = stops.mov_number and st.stp_status <> 'DNE' and stp_mfh_sequence =
                   (select  min(stp_mfh_sequence) from stops st where st.mov_number = stops.mov_number and st.stp_status <> 'DNE' ) )
	  then
		  'ETA: ' + isnull(cast(stp_eta as varchar(20)),'')  + '---------------' + isnull(cast( stp_rpt_miles  as varchar(10)),'')  + ' Kms por recorrer----------------'  
		 +   (case when  isnull(cast(stp_est_drv_time as varchar(10)),'') < 60 then    isnull(cast(stp_est_drv_time as varchar(10)),'')  + ' Minutos de Manejo'
		 else isnull(cast(stp_est_drv_time/60 as varchar(10)),'') + ' Hora(s) de Manejo'   end)
		else '' end 
		as calceta


				




FROM         dbo.stops
where dbo.stops.stp_event in (select abbr from eventcodetable where ect_billable = 'Y' and abbr <> ('90LLD'))
and stp_schdtearliest >= 2014



--select dbo.stops.stp_event ,stp_status,*  from   dbo.stops where ord_hdrnumber = 183104









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
         Begin Table = "stops"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 347
               Right = 271
            End
            DisplayFlags = 280
            TopColumn = 23
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
         Width = 3795
         Width = 1440
         Width = 3810
         Width = 5580
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
', 'SCHEMA', N'dbo', 'VIEW', N'vista_eta', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'vista_eta', NULL, NULL
GO
