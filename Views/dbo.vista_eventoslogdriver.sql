SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[vista_eventoslogdriver]
AS
SELECT     

	lugar = cmp_name, 
	orden =  CAST(ord_hdrnumber AS varchar), 
	referencia = (select ord_refnum from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber),
	eta = 'Entre: ' + cast(stp_schdtearliest as varchar) + ' y ' + cast(stp_schdtlatest as varchar) ,
	tipoevento = cast(stp_sequence as varchar)  +' - ' + (SELECT     name FROM          dbo.eventcodetable  WHERE      (abbr = dbo.stops.stp_event)),
	estatus =  case  when stp_Status = 'DNE' then 'Completado Llego:'+ cast(stp_arrivaldate as varchar) + ' / Salio: ' + cast(stp_departuredate as varchar)  when stp_Status = 'OPN' then 'No Completado' else stp_Status  end,
    calif =  case when stp_Status ='DNE' and stp_arrivaldate <= stp_schdtlatest   then 'OnTime' 
                  when stp_Status ='OPN' then '----' 
             else 'OffTime' end,
	ubicacion =
	
	 (select cast(ckc_date as varchar) from vista_checkmaps where ckc_tractor in 
	(select ord_tractor from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber)
	and ckc_date = (select max(ckc_date) from vista_checkmaps where ckc_tractor in 
	(select ord_tractor from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber)))
	+' | '+
	
	 (select ckc_comment from vista_checkmaps where ckc_tractor in 
	(select ord_tractor from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber)
	and ckc_date = (select max(ckc_date) from vista_checkmaps where ckc_tractor in 
	(select ord_tractor from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber))),

	mapa = (select map from vista_checkmaps where ckc_tractor in 
	(select ord_tractor from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber)
	and ckc_date = (select max(ckc_date) from vista_checkmaps where ckc_tractor in 
	(select ord_tractor from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber))),
   seq = stp_sequence,
   operador = (select ord_driver1 from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber) 


FROM         dbo.stops
where 
dbo.stops.stp_event not in ('90LLD')
and year(stp_schdtearliest) >= 2014
and (select ord_status from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber) in ('STD','DSP')






GO
