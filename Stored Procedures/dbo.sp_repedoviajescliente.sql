SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_repedoviajescliente] (@cliente varchar (12))

/*creado por Emolvera
fecha: 16/02/0215
version: 1.0

prueba 




exec sp_repedoviajescliente 'SAYER'


*/



as

begin

select 


 ReferenciaShipment =  isnull((select ord_refnum from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber),'NA')
,Orden = ord_hdrnumber
,Tractor = isnull(( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number),'NA')
,Remolques = isnull(replace(trl_id,'UNKNOWN','NA'),'NA')
,Evento  = case when stp_type  = 'PUP' then 'Carga'  when stp_type  ='DRP' then 'Descarga' else stp_type end
,Destino = (select cmp_name from company where stops.cmp_id = company.cmp_id)
,CiudadDestino  = (select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
,HoraCita =   'Entre: '  + cast(stp_schdtearliest as varchar(20)) + ' y ' + cast(stp_schdtlatest as varchar(20))
,HoraCitaLimite = stp_schdtlatest
,HoradeLlegada = case when stp_status = 'DNE'  then cast(stp_arrivaldate as varchar(30))  else ''  end
,TardeTemprano =   case when stp_arrivaldate <= stp_schdtlatest and stp_status = 'DNE' then 'Temprano' 
                        when stp_arrivaldate > stp_schdtlatest and stp_status = 'DNE'  then  'Tarde' 
						else '' end
,HoraSalida =  case when stp_status = 'DNE' then cast(stp_departuredate as varchar(30)) else '' end
--,HoraSalida =  case when stp_status = 'DNE' then stp_departuredate else null end


---,Operador = isnull((select mpp_firstname+' '+ mpp_lastname from manpowerprofile where mpp_id =(select lgh_driver1 from legheader where legheader.lgh_number = stops.lgh_number)),'NA') 


,StatusGeneral = case 
   when stp_status ='DNE' then 'Completado'
   when  (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) in ('STD','DSP')) then 'Transito ' +  (select isnull(cast(trc_gps_date as varchar),'') +' | ' + isnull(trc_gps_desc,'')  from tractorprofile where trc_number = ( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number))
   when  (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) = 'PLN') then 'Planeado'
   when  (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) = 'AVL') then 'Disponible' 
   when  (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) = 'PND') then 'Cofirmar orden'
   when  stp_status ='NON' then 'Disponible'  else  stp_status + (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber)   end

,GoogleMaps = isnull( 'http://maps.google.com.mx/maps?F=Q&source=s_q&hl=es&geocode=&q=' + CAST((select trc_gps_latitude from tractorprofile where trc_number = (select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number)) / 3600.00 AS varchar) 
                   + ',-' + CAST((select trc_gps_longitude from tractorprofile where trc_number = (select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number))/ 3600.00 AS varchar) + ' & z=13' ,'No disponible')

from stops 

where stops.ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_billto = @cliente and ord_status  not in ('CAN','MST','PND'))
and  datediff(dd,stp_arrivaldate,getdate()) <= 1
and ord_hdrnumber <> '0'
--and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) is not null
order by stp_arrivaldate desc
		  
END
GO
