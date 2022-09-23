SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--select * from TMWScrollOrderView_monitoreosac

CREATE view [dbo].[TMWScrollOrderView_monitoreosac] AS

SELECT 
 orderheader.ord_number, 
 case when (select count(lgh_number) from legheader (nolock) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber) > 1
 then '*' + orderheader.ord_number else orderheader.ord_number end  as 'orderdisplay', 
 orderheader.ord_company as 'ord_company',
 '' as 'origin_cmp_id', 
 '' as 'origin_cmp_name', 
 '' as 'dest_cmp_id', 
 '' as 'dest_cmp_name', 
 '' as 'orderby_cmp_id', 
 ''  as 'orderby_cmp_name', 
 ''  as 'orderby_cty_nmstct', 
 '' as 'billto_cmp_id', 
 ''  as 'billto_cmp_name', 
 ''  as 'billto_cty_nmstct',
 (select name from labelfile where labeldefinition = 'DispStatus' and abbr = orderheader.ord_status) as 'ord_status_name', 
 orderheader.ord_startdate, 
 orderheader.ord_completiondate, 
 orderheader.ord_originstate, 
 orderheader.ord_deststate, 
 orderheader.ord_revtype1 as 'ord_revtype1', 
 (select name from labelfile where labeldefinition = 'RevType1' and abbr = orderheader.ord_revtype1) as 'ord_revtype1_name',
 orderheader.ord_revtype2 as 'ord_revtype2', 
 (select name from labelfile where labeldefinition = 'RevType2' and abbr = orderheader.ord_revtype2) as 'ord_revtype2_name',
 orderheader.ord_revtype3 as 'ord_revtype3', 
 (select name from labelfile where labeldefinition = 'RevType3' and abbr = orderheader.ord_revtype3) as 'ord_revtype3_name', 
 orderheader.ord_revtype4 as 'ord_revtype4', 
 (select name from labelfile where labeldefinition = 'RevType4' and abbr = orderheader.ord_revtype4) as 'ord_revtype4_name', 
 orderheader.mov_number, 
 orderheader.ord_charge, 
 orderheader.ord_totalcharge, 
 orderheader.ord_accessorial_chrg, 
 orderheader.ord_priority, 
 orderheader.ord_originregion1, 
 orderheader.ord_destregion1, 
 orderheader.ord_reftype, 
 orderheader.ord_refnum, 
 orderheader.ord_status as 'ord_status', 
 orderheader.ord_invoicestatus as 'ord_invoicestatus', 
 '' as 'ord_invoicestatus_name', 
 '' as 'origin_cty_nmstct', 
 '' as 'dest_cyt_nmstct', 
 orderheader.ord_origincity,
 orderheader.ord_destcity,
 orderheader.cmd_code as 'cmd_code',
 orderheader.ord_description, 
 orderheader.ord_remark, 
 orderheader.ord_hdrnumber, 
 orderheader.ord_trailer, 
 orderheader.ord_bookdate, 
 orderheader.ord_bookedby, 
 orderheader.ord_booked_revtype1, 
 orderheader.ord_entryport, 
 orderheader.ord_exitport, 
ord_driver1 = 
case when ord_carrier <>  'UNKNOWN'
then '            _'
else
(select mpp_ID + '     |   ' +  mpp_firstname+' '+mpp_lastname + '   |    Movil:' + isnull(mpp_currentphone,'')+ ' / Casa: '+ isnull(mpp_homephone,'') 
 from manpowerprofile (nolock) where mpp_id = 
  replace((select lgh_driver1  from legheader_active (nolock)  where 
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber))),'UNKNOWN','')) end,

 orderheader.ord_driver2, 

 ord_tractor = case when ord_carrier <>  'UNKNOWN'
 then ord_carrier
 else
 replace(replace( (select trc_number +  '| TAGIAVE: '+  isnull(trc_misc1,'') from tractorprofile where trc_number = (select lgh_tractor from legheader_active (nolock)  where 
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)))),'UNKNOWN',''),'| TAGIAVE:','') end, 
 tractor = 
 (select lgh_tractor from legheader_active (nolock)  where 
		  legheader_active.lgh_number   = (select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)),

 orderheader.ord_odmetermiles, 
 orderheader.ord_route, 
 orderheader.ord_route_effc_date, 
 orderheader.ord_route_exp_date, 
 '' as 'origin_cmp_primaryphone', 
 ''  as 'dest_cmp_primaryphone', 
 ''  as 'billto_cmp_primaryphone', 
 orderheader.ord_totalmiles, 
 orderheader.ord_carrier, 
 ISNULL(orderheader.ord_trailer2, '') as 'ord_trailer2', 
 orderheader.ord_chassis as 'ord_chassis', 
 orderheader.ord_chassis2 as 'ord_chassis2', 
 orderheader.ord_origin_earliestdate as 'origin_earliest', 
 orderheader.ord_origin_latestdate as 'origin_latest', 
 orderheader.ord_dest_earliestdate as 'dest_earliest', 
 orderheader.ord_dest_latestdate as 'dest_latest',
 orderheader.ord_schedulebatch as 'schedule_batch',
 orderheader.ord_shipper as 'ord_shipper',
 orderheader.ord_consignee as 'ord_consignee',
 orderheader.ord_billto as 'ord_billto',
 orderheader.ord_dest_zip as 'ord_dest_zip',
 orderheader.ord_origin_zip as 'ord_origin_zip',
 orderheader.ord_order_source as 'ord_order_source',
 orderheader.ord_originregion2 as 'ord_originregion2',
 orderheader.ord_originregion3 as 'ord_originregion3',
 orderheader.ord_originregion4 as 'ord_originregion4',
 orderheader.ord_destregion2 as 'ord_destregion2',
 orderheader.ord_destregion3 as 'ord_destregion3',
 orderheader.ord_destregion4 as 'ord_destregion4',
 orderheader.ord_schedulebatch as 'ord_schedulebatch',
 orderheader.ord_origin_earliestdate as 'ord_origin_earliestdate',
 ''  as 'billto_state',
 orderheader.ord_fromschedule as 'ord_fromschedule',
 orderheader.ord_BelongsTo as 'ord_belongsto',
 orderheader.rowsec_rsrv_id as 'ord_rowsec_rsrv_id',
 orderheader.ord_fromorder as 'ord_fromorder',
 orderheader.ord_datepromised,
 -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 trc_gps_latitude= (select  (case when trc_gps_latitude >1000 then  (trc_gps_latitude/3600.0) else abs(trc_gps_latitude/1.0) end) from tractorprofile (nolock)
 where trc_number = (select lgh_tractor  from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)))),

 trc_gps_longitude= (select  (case when trc_gps_latitude >1000 then  (trc_gps_longitude/3600.0) else abs(trc_gps_longitude/1.0) end) from tractorprofile (nolock)
 where trc_number = (select lgh_tractor from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)))),

 trc_gps_desc= (select  isnull(trc_gps_desc,'') from tractorprofile (nolock)
 where trc_number = (select lgh_tractor  from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)))),

 trc_gps_date= (select  isnull(trc_gps_date,'') from tractorprofile (nolock)
 where trc_number = (select lgh_Tractor  from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)))),

fechagpstxt =  

(select  (case when datediff(dd,trc_gps_date,getdate()) = 0  
 then  substring(convert(varchar(24),trc_gps_date,114),1,5)
 else +'.'+substring(convert(varchar(24),trc_gps_date,1),0,6)  +' '  +  substring(convert(varchar(24),trc_gps_date,114),1,5)
 end
 )
from tractorprofile (nolock)
where trc_number = (select lgh_tractor from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)))),



 gpslag= (select   datediff(mi,getdate(), cast (trc_gps_date as varchar) )  from tractorprofile (nolock)
 where trc_number = (select lgh_tractor from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)))),

 
 Statusorden = 

  case 


 when  orderheader.ord_status  = 'AVL'  then '1.AVL'
  when orderheader.ord_status  = 'PLN'  then '2.PLN'

 when orderheader.ord_status  = 'DSP' then '3.DSP'
 when orderheader.ord_status  = 'CAN' then '5.CAN'


 when  
 
--cuando el ultimo sitio registrado en el tractoprofile 
 
 (select  ( trc_lastpos_nearctynme) from tractorprofile (nolock)
 where trc_number = (select lgh_tractor  from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber))))
 
 = 
--es igual al sitio del stop actual
 isnull(
		
         (select  +'[' + rtrim(max(cmp_id)) + ']'  from  stops (nolock) 
		where stops.mov_number = orderheader.mov_number and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number =  orderheader.mov_number   and stp_status = 'OPN'))
	,'')
	
		  then '4.SIT'

		     when orderheader.ord_status  = 'STD' then '4.STD'


else orderheader.ord_status 
end,



Cliente = orderheader.ord_billto

,Destino =orderheader.ord_Consignee 

,CiudadOrigen =

		   isnull((select '['+isnull(cmp_id,'')+']        ' + isnull(cmp_name,'')  + ' | ' + isnull(cty_nmstct,'')  from company (nolock) 
		   where cmp_id  
		   = orderheader.ord_shipper),'')


,CiudadDestino =

isnull((select '['+isnull(cmp_id,'')+']        ' + isnull(cmp_name,'')  + ' | ' + isnull(cty_nmstct,'')  from company (nolock)
		    where cmp_id =orderheader.ord_consignee),' ')

,Remolque =

isnull((select lgh_primary_trailer  from legheader_active (nolock)  where 
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber ))),'')
		  

,Escuderia = 

(select  (select  trc_teamleader  from tractorprofile (nolock)
 where trc_number = (select lgh_TRACTOR  from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)))))



,lgh_number = 
isnull( (select cast(max(lgh_number) as varchar(20))  from legheader_active (nolock)  where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber),'')


,InicioOrdenDt = isnull(orderheader.ord_startdate,'')



,InicioOrden = isnull( substring(convert(varchar(24),(orderheader.ord_startdate ),1),0,6)  +' '  +  substring(convert(varchar(24),(orderheader.ord_startdate) ,114),1,5) ,'')
		
  
,FinOrdendt = isnull(orderheader.ord_completiondate,'')

,FinOrden = isnull( substring(convert(varchar(24),(ord_completiondate ),1),0,6)  +' '  +  substring(convert(varchar(24),(ord_completiondate) ,114),1,5),'')



,ProxEvento =  
isnull( (select name from eventcodetable  (nolock) where abbr = (select max(stp_event)  from  stops (nolock) where stops.mov_number
		 = orderheader.mov_number
		  and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number =  orderheader.mov_number   and stp_status = 'OPN')
		 )),'')	


,ProxCita = 
--considerar si sera arrivaldate o schdt latest

isnull(

		 (select 
		 substring(convert(varchar(24),max(stp_arrivaldate),1),0,6)  +' '  +  substring(convert(varchar(24),max(stp_arrivaldate),114),1,5)
		 
		  from  stops (nolock) where stops.mov_number = orderheader.mov_number 
		   and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number =  orderheader.mov_number   and stp_status = 'OPN') 
		   ),'')

 	
	
,ProxCitadt = 
--considerar si sera arrivaldate o schdt latest


isnull( (select 
		 max(stp_arrivaldate)
		 
		  from  stops (nolock) where stops.mov_number = orderheader.mov_number
		   and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number =  orderheader.mov_number  and stp_status = 'OPN')
		  ),'')
		 



,ProxDestino = 

isnull(
(select cast(max(stp_mfh_sequence)  as varchar(2) )+'/'   from  stops (nolock) 
		where stops.mov_number = orderheader.mov_number  
		 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number = orderheader.mov_number  and stp_status = 'OPN'))
	
	
			  +  		
		(select cast(count(stp_mfh_sequence)  as varchar(2) ) from  stops (nolock) 
		where stops.mov_number
		 = orderheader.mov_number)

			  +' ' +

		(select '['+isnull(cmp_id,'')+']        ' + isnull(cmp_name,'')  + ' | ' + isnull(cty_nmstct,'')  from company
		 (nolock) where cmp_id = (select max(cmp_id)  from  stops (nolock) 
		where stops.mov_number = orderheader.mov_number
		 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number =  orderheader.mov_number   and stp_status = 'OPN')
		)),'')


,ProxCiudadDestino = 
isnull((select cty_nmstct from company (nolock) where cmp_id = (select max(cmp_id)  from  stops (nolock) 
		where stops.mov_number =  orderheader.mov_number 
		 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number =  orderheader.mov_number   and stp_status = 'OPN')
		)),'')



		
,Calceta = 
isnull((select
		 
		 isnull(cast( stp_rpt_miles  as varchar(10)),'')  + ' Kms        ----------------'  
		 +   (case when  isnull(cast(stp_est_drv_time as varchar(10)),'') < 60 then    isnull(cast(stp_est_drv_time as varchar(10)),'')  + ' Minutos de Manejo'
		 else isnull(cast(stp_est_drv_time/60 as varchar(10)),'') + ' Hora(s) de Manejo'   end) + '---------------' + 'ETA: ' + isnull(cast(stp_eta as varchar(20)),'')  
		
		 
		from  stops (nolock) 
		where stops.mov_number = orderheader.mov_number 
		 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number =  orderheader.mov_number   and stp_status = 'OPN')
		),'')
		 

,etatime =  isnull( (select stp_eta	from  stops (nolock) 	where stops.mov_number =  orderheader.mov_number 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops  (nolock) where stops.mov_number =  orderheader.mov_number  and stp_status = 'OPN')
),'')

		
,SitioActual = 
(select  ( trc_lastpos_nearctynme) from tractorprofile (nolock)
 where trc_number = (select lgh_tractor  from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber))))


,estatusgps = case 
		 when  (select  ( trc_lastpos_nearctynme) from tractorprofile (nolock)
         where trc_number = (select lgh_tractor  from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)))) like '%ZBC/%' 
		  then'BAJCOVER'


		 when (select  ( trc_lastpos_nearctynme) from tractorprofile (nolock)
         where trc_number = (select lgh_tractor  from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)))) <> '' 
		 
		 and  

		 (select   (datediff(mi,cast (trc_gps_date as varchar),getdate() ))  from tractorprofile (nolock)
          where trc_number = (select lgh_tractor from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber))))> 15

		  then 'SEG'


		  when (select  ( trc_lastpos_nearctynme) from tractorprofile (nolock)
           where trc_number = (select lgh_tractor  from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)))) = ''
		 
		 and

		 (select   (datediff(mi,cast (trc_gps_date as varchar),getdate() ))  from tractorprofile (nolock)
          where trc_number = (select lgh_tractor from legheader_active (nolock)  where lgh_tractor <> 'UNKNOWN' and
		  legheader_active.lgh_number   = ((select max(lgh_number)  from legheader_active where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber))))> 15
		 

		  then 'NOSEG'
	
		 else
		    'OK'
		 end



FROM orderheader (nolock) 
 where orderheader.ord_status not in ('MST','CMP','CAN')

GO
GRANT SELECT ON  [dbo].[TMWScrollOrderView_monitoreosac] TO [public]
GO
