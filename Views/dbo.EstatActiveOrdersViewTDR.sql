SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






















CREATE view [dbo].[EstatActiveOrdersViewTDR]
as


SELECT


--NO TOCAR NECESARIOS PARA LA VISTA---------------------------------------------------


    'TMWWF_ESTAT_ACTIVE' as 'TMWWF_ESTAT_ACTIVE',                                                                                                                             ----0
	
	 ord_hdrnumber,                                                                                                                                               ----1
     ord_number,                                                                                                                                                  ----2
 
/************************************************************************************************************************************************************/
     DispStatus  ,                            ----3
/*************************************************************************************************************************************************************/ 
	 OrderBy 'OrderByID',                                                                                                                                      ----4
	 StartDate 'StartDate',
	 Enddate 'EndDate',         	 
     (select cmp_name from company (nolock) where cmp_id = billto) 'BillTo', 
	 (select cmp_name from company (nolock) where cmp_id = orderby) 'OrderBy',
     
	  '' 'PickupID',
      '' 'PickupName',
      '' 'PickupCity',
      '' 'PickupState',

      ConsigneeId 'ConsigneeID',
      UPPER(ConsigneeName) 'ConsigneeName',
      consigneecity 'ConsigneeCity',
      ConsigneeState 'ConsigneeState', 

	  RevType1 'RevType1', 
	  Revtype2 'RevType2',
	  Revtype3 'RevType3', 
	  Revtype4 'RevType4',
      billto 'BillToID',
   
---------------------------------------------------------------------------------------
     case when billto='pilgrims' then   isnull((select max(ref_number) from referencenumber ref where  ref.ref_table = 'orderheader' and  ref.ref_type = 'SID' and ref.ref_tablekey = Op.ord_hdrnumber),'Fuera SDS')  else Referencia end as Referencia,
	 case when (estatusicon  = 'Drvng' and Proxevent not in ('IDMT','EMT')) then 'En transito' 
	 when estatusicon = 'LLD' then 'Cargando' 
	 when estatusicon = 'LUL' then 'Descargando' 
	 when estatusicon = 'IDMT' then 'Final'
	 when estatusicon = 'EMT' then 'Final'
	 when estatusicon = 'HPL' then 'Gancha Caja PC'
	 when (EstatusIcon = 'Drvng' and Proxevent = 'IDMT') then 'Regreso'
	 when (EstatusIcon = 'Drvng' and Proxevent  ='EMT') then 'Regreso'
	 else  estatusicon end as estatusicon,    --- (select name from eventcodetable where abbr = estatusicon) end as estatusicon,
	 Actcomp,
	 Actdif,

     gpsdesc  'UbicacionGPS',
	 gpsdated=	 cast(day( gpsdated) as varchar(20)) +'/'+ cast( month( gpsdated) as varchar(20)) + ' ' + cast(datepart(hour, gpsdated) as varchar(20)) +':'+
				case when len((cast(datepart(MINUTE, gpsdated) as varchar(20)))) = 1 then '0'+ cast(datepart(MINUTE, gpsdated) as varchar(20)) else cast(datepart(MINUTE, gpsdated) as varchar(20))  end,
	 ProxCita =
	 cast(day(ProxCita) as varchar(20)) +'/'+ cast( month(ProxCita) as varchar(20)) + ' ' + cast(datepart(hour,ProxCita) as varchar(20)) +':'+
				case when len((cast(datepart(MINUTE,ProxCita) as varchar(20)))) = 1 then '0'+ cast(datepart(MINUTE,ProxCita) as varchar(20)) else cast(datepart(MINUTE,ProxCita) as varchar(20))  end,


	   case  when (Proxevent) = 'LUL' then 'Descarga'
	       when (Proxevent) = 'IDMT' then 'Final'
	        when (Proxevent) = 'LLD' then 'Carga'
			 when (Proxevent) = 'EMT' then 'Final'
	  end as  Proxevent,
	  
	  --(select name from eventcodetable where abbr = Proxevent) as  Proxevent,
	 Proxcomp,
	 Elogist,
	 ETAPC =	 cast(day( ETAPC) as varchar(20)) +'/'+ cast( month( ETAPC) as varchar(20)) + ' ' + cast(datepart(hour, ETAPC) as varchar(20)) +':'+
				case when len((cast(datepart(MINUTE, ETAPC) as varchar(20)))) = 1 then '0'+ cast(datepart(MINUTE, ETAPC) as varchar(20)) else cast(datepart(MINUTE, ETAPC) as varchar(20))  end,
	ETADif as ETADif,
	 TRCDispo,
	 Tractor,
	 (select max(trc_licnum) from tractorprofile (nolock) where trc_number = Tractor) as PlacasTractor,
	 Trailer,
	 (select max(trl_licnum) from trailerprofile (nolock) where trl_number = Trailer) as PlacasTrailer,
	
	-- Skyguardian = '<a href="http://telematics.skyguardian.us" target="_blank"> Rastreo  </a>',
	 
	 DispStatus  'EstadoViaje',
	 OrdenGrid = ProxCita,
	case when billto='pilgrims' then '<a href="https://69.20.92.116:8090/BitacoraPilgrims.aspx?lgh_header=' +cast (lgh_number as varchar(20))+'"  target="_blank">'
	+ isnull((select max(ref_number) from referencenumber ref where  ref.ref_table = 'orderheader' and  ref.ref_type = 'LPID' and ref.ref_tablekey = Op.ord_hdrnumber),Referencia)  
	+'   </a>'  
	 when billto = 'inovador' then 
	 
	 isnull((select 'Próximo Operador '+ evt_tractor+'-'+evt_trailer1+'-'+(select mpp_lastfirst from manpowerprofile (nolock) where mpp_id = evt_driver1)+'-'+cast(format(stops.stp_schdtearliest,'yyyy-MM-dd HH:mm') as varchar)+'|' 
from event (nolock) inner join stops (nolock) on event.stp_number = stops.stp_number
	 where event.ord_hdrnumber = op.ord_hdrnumber
	 and stops.stp_status <> 'CMP' and event.evt_tractor <> op.Tractor FOR XML PATH ('')),Referencia)
	else Referencia end as leg

	   	 
    from [OperationsInboundView_TDR] op
	-- WHERE DispStatus <> 'CMP'

	














GO
