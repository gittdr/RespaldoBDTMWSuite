SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [dbo].[vista_eventoslog]
AS
SELECT     

	lugar = cmp_name + ' | ' +  (SELECT      rtrim( isnull( alk_city,'') )  FROM            dbo.city WITH (nolock)  WHERE        (dbo.stops.stp_city = cty_code))  + ' | ' + 
	 (SELECT rtrim(isnull(name,'')) from labelfile with (NOLOCK) where  (labeldefinition = 'state' and abbr =  (SELECT        cty_state  FROM            dbo.city AS city_1 WITH (nolock)  WHERE        (stp_city = cty_code)))), 

	orden =  CAST(ord_hdrnumber AS varchar), 
	referencia = (select ord_refnum from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber),
	eta = 'Entre: ' + cast(stp_schdtearliest as varchar) + ' y ' + cast(stp_schdtlatest as varchar) ,
	tipoevento = cast(stp_sequence as varchar)  +' - ' + (SELECT     name FROM          dbo.eventcodetable  WHERE      (abbr = dbo.stops.stp_event)),
	estatus =  case  when stp_Status = 'DNE' then 'Completado Llego:'+ cast(stp_arrivaldate as varchar) + ' / Salio: ' + cast(stp_departuredate as varchar)  when stp_Status = 'OPN' then 'No Completado' else stp_Status  end,
    calif =  case when stp_Status ='DNE' and stp_arrivaldate <= stp_schdtlatest   then 'OnTime' 
                  when stp_Status ='OPN' then '----' 
             else 'OffTime' end,
	ubicacion =
	
	 (select cast(max(ckc_date) as varchar) from vista_checkmaps where ckc_tractor in 
	(select ord_tractor from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber)
	and ckc_date = (select max(ckc_date) from vista_checkmaps where ckc_tractor in 
	(select ord_tractor from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber)))
	+' | '+
	
	 (select max(ckc_comment) from vista_checkmaps where ckc_tractor in 
	(select ord_tractor from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber)
	and ckc_date = (select max(ckc_date) from vista_checkmaps where ckc_tractor in 
	(select ord_tractor from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber))),

	mapa = (select max(map) from vista_checkmaps where ckc_tractor in 
	(select ord_tractor from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber)
	and ckc_date = (select max(ckc_date) from vista_checkmaps where ckc_tractor in 
	(select ord_tractor from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber))),
   seq = stp_sequence,

      RutaEta =  				'https://www.google.com.mx/maps/dir/' + 
   
   (SELECT        rtrim(isnull(replace(alk_city,' ','+'),''))   FROM            dbo.city WITH (nolock)  WHERE        (dbo.stops.stp_city = cty_code))
     + ',+' + 
  (SELECT  rtrim(isnull(replace(name,' ','+'),'')) from labelfile with (NOLOCK) where  (labeldefinition = 'state' and abbr =  (SELECT        cty_state  FROM            dbo.city AS city_1 WITH (nolock)  WHERE        (stp_city = cty_code))))
     +'./' +
			CAST((select trc_gps_latitude from tractorprofile where trc_number = (select lgh_tractor from legheader where stops.lgh_Number = legheader.lgh_number) ) / 3600.00 AS varchar)  + ',-' +
			CAST((select trc_gps_longitude from tractorprofile where trc_number = (select lgh_tractor from legheader where stops.lgh_Number = legheader.lgh_number))/ 3600.00 AS varchar) 



FROM         dbo.stops
where 
dbo.stops.stp_event not in ('90LLD')
and year(stp_schdtearliest) >= 2014
and (select ord_status from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber) in ('STD','DSP')








GO
