SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera Yanez
Fecha: 09/06/2014
Vewrsion 1:00

Parametros: Fecha inicial y Fecha final en la que empezaron las ordenes
Descripción: SP que arroja los datos requeridos para generar la caratula de Sigma
en base a las ordenes que ya estan en printed o en XFR, se pasan como parametros
las fecha de inicio y fin de la orden

Ejemplo 
exec sp_rptstatuskatoen 
*/



CREATE  proc [dbo].[sp_rptstatuskatoen]

 

as

BEGIN



--OPCION DESDE EL PUNTO DE VISTA DE STOPS---------------------------------------------------------------------------------------------------

select 

OrdenTDR = (select ord_hdrnumber from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber)
,ReferenciaShipment =  isnull((select ord_refnum from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber),'NA')
,Cliente = (select cmp_name from company where stops.cmp_id = company.cmp_id)
,DestinoFinal = (select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
,Caja = isnull(replace(trl_id,'UNKNOWN','NA'),'NA')
,Unidad = isnull(( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number),'NA')
,Operador = isnull((select mpp_firstname+' '+ mpp_lastname from manpowerprofile where mpp_id =(select lgh_driver1 from legheader where legheader.lgh_number = stops.lgh_number)),'NA') 
,HoradeLlegada = stp_arrivaldate
,Evento  = case when stp_type  = 'PUP' then 'Carga'  when stp_type  ='DRP' then 'Descarga' else stp_type end
,HoraSalida = stp_departuredate
,StatusGeneral = case 
   when stp_status ='DNE' then 'Completado'
   when  (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) = 'STD') then 'Transito ' +  (select isnull(cast(trc_gps_date as varchar),'') +' | ' + isnull(trc_gps_desc,'')  from tractorprofile where trc_number = ( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number))
   when  (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) = 'PLN') then 'Planeado'
   when  (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) = 'AVL') then 'Disponible' 
   when  (stp_status ='OPN'  and  (select ord_status from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber) = 'PND') then 'Cofirmar orden'
   when  stp_status ='NON' then 'Disponible'  else  stp_status  end

from stops 



where stops.ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_billto = 'KATNAT' and ord_status  not in ('CAN','MST'))
and  datediff(mm,stp_arrivaldate,getdate()) <= 1
and ord_hdrnumber <> '0'
--and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) is not null
order by OrdenTDR desc , stp_sequence asc

END

GO
