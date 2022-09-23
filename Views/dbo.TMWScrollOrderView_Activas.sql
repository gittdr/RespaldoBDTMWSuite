SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









--select * from [dbo].[TMWScrollOrderView_Activas]

CREATE view [dbo].[TMWScrollOrderView_Activas] AS

SELECT  

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
--DATOS REQUERIDOS NO TOCAR
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
DISTINCT orderheader.ord_number, 
	
	
	orderheader.ord_company as 'ord_company',
	company_a.cmp_id as 'origin_cmp_id', 
	company_a.cmp_name as 'origin_cmp_name', 
	company_b.cmp_id as 'dest_cmp_id', 
	company_b.cmp_name as 'dest_cmp_name', 
	company_c.cmp_id as 'orderby_cmp_id', 
	company_c.cmp_name as 'orderby_cmp_name', 
	company_c.cty_nmstct as 'orderby_cty_nmstct', 
	company_d.cmp_id as 'billto_cmp_id', 
	company_d.cmp_name as 'billto_cmp_name', 
	company_d.cty_nmstct as 'billto_cty_nmstct',
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
	(select name from labelfile where labeldefinition = 'OrdInvStatus' and abbr = orderheader.ord_invoicestatus) as 'ord_invoicestatus_name', 
	(CASE company_a.cty_nmstct WHEN 'UNKNOWN' THEN city_a.cty_nmstct ELSE company_a.cty_nmstct  END) as 'origin_cty_nmstct', 
	(CASE company_b.cty_nmstct WHEN 'UNKNOWN' THEN city_b.cty_nmstct ELSE company_b.cty_nmstct END) as 'dest_cyt_nmstct', 
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
	orderheader.ord_driver1, 
	orderheader.ord_driver2, 
	'ord_tractor' = lgh_tractor, 
	orderheader.ord_odmetermiles, 
	orderheader.ord_route, 
	orderheader.ord_route_effc_date, 
	orderheader.ord_route_exp_date, 
	company_a.cmp_primaryphone as 'origin_cmp_primaryphone', 
	company_b.cmp_primaryphone as 'dest_cmp_primaryphone', 
	company_d.cmp_primaryphone as 'billto_cmp_primaryphone', 
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
	leg.lgh_number as 'lgh_number',
 	company_d.cmp_state as 'billto_state',
	orderheader.ord_fromschedule as 'ord_fromschedule',
	orderheader.ord_BelongsTo as 'ord_belongsto',
	orderheader.rowsec_rsrv_id as 'ord_rowsec_rsrv_id',
	orderheader.ord_fromorder as 'ord_fromorder',
	orderheader.ord_datepromised

---------------------------------------------------------------------------------------------------------------------------------------------------------------

 ,origen =   (select cmp_name from company where cmp_id = ord_shipper)


 ,elogist  =  
 case 
 when orderheader.ord_status = 'STD' 
 then
                       isnull( (select ckc_comment + ' el '+ cast(ckc_date as varchar) from checkcall
                            where (ckc_updatedby  = 'TMWST' or ckc_updatedby  in (select usr_userid nolock from ttsusers))
                       and
					   ckc_tractor = orderheader.ord_tractor
					   and
					   ckc_number = (select max(ckc_number) from checkcall 
					         where (ckc_updatedby  = 'TMWST' or ckc_updatedby  in (select usr_userid nolock from ttsusers))
                       and
					   ckc_tractor = orderheader.ord_tractor
					   and
					   ckc_date between orderheader.ord_startdate and orderheader.ord_completiondate
					   )
					  ),'En transito' )
when orderheader.ord_status  in ('AVL','PLN','DSP')
then
'Viaje planeado para iniciar el: ' + cast(ord_startdate as varchar)

else 'En transito'
end



--Genera mas de un registro
 ,proxevento = ( select name from eventcodetable  where abbr = (select min(stp_event) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN')))
 

 
 ,proxdestino = (select cmp_name from company where cmp_id =
 (select min(cmp_id) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN')))



 ,proxcita= (select CONVERT(VARCHAR(7), min(stp_schdtlatest), 6)  + CONVERT(VARCHAR(5), min(stp_schdtlatest), 8)  from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN'))


 ,ontime =  (case when getdate() >

  (select  min(stp_schdtearliest) from stops  where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN'))
 then 'Retraso'
 else 'En Tiempo'
 End
 )


 ,icono =  (case when getdate() >

  (select  min(stp_schdtearliest) from stops  where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN'))
 then 'TRACTOR_RED'
 else 'TRACTOR_BLUE'
 End
 ),

 destino=  (select cmp_name from company where cmp_id = ord_consignee),

 operador = isnull((select mpp_firstname +' '+ mpp_lastname from manpowerprofile where mpp_id =lgh_driver1),'N.D') ,
 
 
 -- (select lgh_number from legheader lp where lp.lgh_instatus in ('STD','UNP')  and lp.ord_hdrnumber = orderheader.ord_hdrnumber), 
 --isnull((select mpp_firstname +' '+ mpp_lastname from manpowerprofile where mpp_id = lgh_driver1),'N.D'),

 --select lgh_outstatus, lgh_instatus, * from legheader where ord_hdrnumber = '303004'

 remolques =
 replace(replace(isnull((select  top 1 lgh_primary_trailer from legheader where legheader.ord_hdrnumber = orderheader.ord_hdrnumber ),''),'UNKNOWN','')
 +' | '+
isnull((select top 1 lgh_primary_pup from legheader where legheader.ord_hdrnumber =  orderheader.ord_hdrnumber ),''),'| UNKNOWN','')



 ,checkcall = 

   /*
'<b> Orden:' + CAST(orderheader.ord_hdrnumber AS VARCHAR(15)) + ' </b> <br>'+
'Proximo Destino: '  +  (select cmp_name from company where cmp_id =
   (select cmp_id from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
   and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN')))+'<br>'+
'Proximo Evento: ' + ( select name from eventcodetable  where abbr = (select stp_event from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
   and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN'))) + '<br>' +
'Proxima Cita: ' +  (select cast(stp_schdtlatest as varchar (25)) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN')) + '<br>' +
 'Origen: ' +  (select cmp_name from company where cmp_id = ord_shipper) +  '<br>'
 +
 'Destino: ' + (select cmp_name from company where cmp_id = ord_consignee) +  '<br>'+
  '______________________________________ <br>' +
 */


 
 'Operador: '+   isnull((select mpp_firstname +' '+ mpp_lastname from manpowerprofile where mpp_id =lgh_driver1),'N.D')  +  '<br>'+
 'Tracto: '+  lgh_tractor  +  '<br>'+
 'Remolques: '+  replace(replace(isnull((select  top 1 lgh_primary_trailer from legheader where legheader.ord_hdrnumber = orderheader.ord_hdrnumber ),''),'UNKNOWN','')
             +' | '+
             isnull((select top 1 lgh_primary_pup from legheader where legheader.ord_hdrnumber =  orderheader.ord_hdrnumber ),''),'| UNKNOWN','')+  '<br>'+
 'Ubicacion: '+ (select cast (trc_gps_date as varchar) from tractorprofile where trc_number = lgh_tractor)     
              +'|'+ (select cast (trc_gps_desc as varchar(100)) from tractorprofile where trc_number = ord_tractor) +'<br>'+
 'Estatus: '+  (case 
 when orderheader.ord_status = 'STD' 
 then
                       isnull( (select ckc_comment + ' el '+ cast(ckc_date as varchar) from checkcall
                            where (ckc_updatedby  = 'TMWST' or ckc_updatedby  in (select usr_userid nolock from ttsusers))
                       and
					   ckc_tractor = orderheader.ord_tractor
					   and
					   ckc_number = (select max(ckc_number) from checkcall 
					         where (ckc_updatedby  = 'TMWST' or ckc_updatedby  in (select usr_userid nolock from ttsusers))
                       and
					   ckc_tractor = orderheader.ord_tractor
					   and
					   ckc_date between orderheader.ord_startdate and orderheader.ord_completiondate
					   )
					  ),'En transito' )
when orderheader.ord_status  in ('AVL','PLN','DSP')
then
'Viaje planeado para iniciar el: ' + cast(ord_startdate as varchar)

else 'En transito'
end) 

--http://10.176.163.68:61/?tractor=' +lgh_tractor  + '

+ '</br> <a href="http://10.176.163.68:61/CheckcallsRoute.aspx?Tractor=' +lgh_tractor+  '&Orden=' + cast(orderheader.ord_hdrnumber as varchar(20))  +  '" target="_new">Ver recorrido en Google Maps</a>'
+'</br> <font size="1"> Orden: '+ cast(orderheader.ord_hdrnumber as varchar(20)) + '</font>'

 
  
  

 ,(select  (case when trc_gps_latitude >1000 then  (trc_gps_latitude/3600.0) else abs(trc_gps_latitude/1.0)    end)  from tractorprofile where trc_number = lgh_tractor) 'trc_gps_latitude'
 ,(select  (case when trc_gps_latitude >1000 then  (trc_gps_longitude/3600.0) else abs(trc_gps_longitude/1.0)  end) from tractorprofile where trc_number = lgh_tractor) 'trc_gps_longitude'

 
 ,datediff(mi,getdate(),(select cast (trc_gps_date as varchar) from tractorprofile where trc_number = lgh_tractor))  'gpslag'

 ,datediff(mi,getdate(),  (select  min(stp_schdtearliest) from stops  where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN')) ) 'stoplag'
 
 ,Escuderia = (select trc_teamleader from tractorprofile where trc_number = lgh_tractor)




FROM orderheader (nolock)
	join dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('orderheader', null) rsva ON (orderheader.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0) 
	join company company_a (nolock) on (orderheader.ord_originpoint = company_a.cmp_id)  
	join company company_b (nolock) on (orderheader.ord_destpoint = company_b.cmp_id)  
	join company company_c (nolock) on (orderheader.ord_company = company_c.cmp_id)  
	join company company_d (nolock) on (orderheader.ord_billto = company_d.cmp_id) 
	join city city_a (nolock) on (orderheader.ord_origincity = city_a.cty_code)  
	join city city_b (nolock) on (orderheader.ord_destcity = city_b.cty_code)
	left join legheader_active leg (nolock) on (orderheader.ord_hdrnumber = leg.ord_hdrnumber)
--	LEFT JOIN stops (nolock) ON orderheader.mov_number = stops.mov_number
--	LEFT JOIN freightdetail (nolock) ON stops.stp_number = freightdetail.stp_number


where ord_status in ('STD')
and leg.lgh_outstatus_name <> 'Completed'








GO
GRANT SELECT ON  [dbo].[TMWScrollOrderView_Activas] TO [public]
GO
