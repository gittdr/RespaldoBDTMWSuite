SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










CREATE  view [dbo].[TMWScrollOrderView_TDRDScroll] AS


SELECT 

/*******************************************************************************************CAMPOS REQUERIDOS POR OPERATIONS NO TOCAR********************************************************************************************************************/

 ord.ord_number , 
 replace(cast(lgh.ord_hdrnumber as varchar(20)) +'-'+lgh.lgh_split_flag,'-N','')  as 'orderdisplay', 
  ord.ord_company  as 'ord_company',
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
 '' as 'ord_status_name', 
 ord.ord_startdate, 
 ord.ord_completiondate, 
 ord.ord_originstate, 
 ord.ord_deststate , 
 ord.ord_revtype1 as 'ord_revtype1', 
 (select name from labelfile (nolock) where labeldefinition = 'RevType1' and abbr = ord.ord_revtype1) as 'ord_revtype1_name',
 ord.ord_revtype2 as 'ord_revtype2', 
 (select name from labelfile (nolock) where labeldefinition = 'RevType2' and abbr = ord.ord_revtype2) as 'ord_revtype2_name',
 ord.ord_revtype3 as 'ord_revtype3', 
 (select name from labelfile (nolock)  where labeldefinition = 'RevType3' and abbr = ord.ord_revtype3) as 'ord_revtype3_name', 
 ord.ord_revtype4 as 'ord_revtype4', 
 (select name from labelfile (nolock) where labeldefinition = 'RevType4' and abbr = ord.ord_revtype4)+'-'+
 (select name from labelfile (nolock) where labeldefinition = 'RevType2' and abbr = ord.ord_revtype2) 
 as 'ord_revtype4_name', 
 ord.mov_number, 
 ord.ord_charge, 
 ord.ord_totalcharge, 
 ord.ord_accessorial_chrg, 

 	case when ((select ect_billable from eventcodetable where ns.stp_event = abbr) = 'Y' and (ord.ord_priority = '1' )) then '!'
					when ord.ord_priority like '%UNK%' then ' ' else  ord.ord_priority end 'Ord_Priority',  

 ord_originregion1 = lgh_startregion1, 
 ord.ord_destregion1, 
 ord.ord_reftype, 
 ord.ord_refnum, 
 ord.ord_status as 'ord_status', 
 ord.ord_invoicestatus as 'ord_invoicestatus', 
 '' as 'ord_invoicestatus_name', 
 '' as 'origin_cty_nmstct', 
 ecity.cty_nmstct as 'dest_cyt_nmstct', 
 ord.ord_origincity,
 ord.ord_destcity,
 ord.cmd_code as 'cmd_code',
 ord.ord_description, 
 ord.ord_remark, 
 ord.ord_hdrnumber, 
 lgh.lgh_primary_trailer   'ord_trailer', 
 trlstatus = '' ,


 --ord.ord_bookdate,
substring(convert(varchar(24),(ord.ord_bookdate),1),0,6)  +' '  +  substring(convert(varchar(24),(ord.ord_bookdate) ,114),1,5)  as 'ord_bookdate',
 ord.ord_bookedby, 
 ord.ord_booked_revtype1, 
 ord.ord_entryport, 
 ord.ord_exitport, 
 ord_driver1 = 
 mpp.mpp_ID + '     |   ' +  mpp.mpp_firstname+' '+mpp.mpp_lastname + '   |    Movil:' + isnull(mpp.mpp_currentphone,'')+ ' / Casa: '+ isnull(mpp.mpp_homephone,'') ,

 ord.ord_driver2, 

 ord_tractor = case when lgh.lgh_carrier <>  'UNKNOWN'
 then ord_carrier
 else
 replace( (t.trc_number +  '   | TAGIAVE: '+  isnull(t.trc_misc1,'') +'    | Placas: '+ t.trc_licnum  ),'UNKNOWN','') end, 
 
 lgh.lgh_tractor as 'tractor',
 ord.ord_odmetermiles, 
 ord.ord_route, 
 ord.ord_route_effc_date, 
 ord.ord_route_exp_date, 
 '' as 'origin_cmp_primaryphone', 
 ''  as 'dest_cmp_primaryphone', 
 ''  as 'billto_cmp_primaryphone', 
 ord.ord_totalmiles, 
 ord.ord_carrier, 
 ISNULL(ord.ord_trailer2, '') as 'ord_trailer2', 
 ord.ord_chassis as 'ord_chassis', 
 ord.ord_chassis2 as 'ord_chassis2', 
 ord.ord_origin_earliestdate as 'origin_earliest', 
 ord.ord_origin_latestdate as 'origin_latest', 
 ord.ord_dest_earliestdate as 'dest_earliest', 
 ord.ord_dest_latestdate as 'dest_latest',
 ord.ord_schedulebatch as 'schedule_batch',
 ord.ord_shipper as 'ord_shipper',
 ord.ord_consignee as 'ord_consignee',
 ord.ord_billto as 'ord_billto',
 ord.ord_dest_zip as 'ord_dest_zip',
 ord.ord_origin_zip as 'ord_origin_zip',
 ord.ord_order_source as 'ord_order_source',
 ord.ord_originregion2 as 'ord_originregion2',
 ord.ord_originregion3 as 'ord_originregion3',
 ord.ord_originregion4 as 'ord_originregion4',
 ord.ord_destregion2 as 'ord_destregion2',
 ord.ord_destregion3 as 'ord_destregion3',
 ord.ord_destregion4 as 'ord_destregion4',
 ord.ord_schedulebatch as 'ord_schedulebatch',
 ord.ord_origin_earliestdate as 'ord_origin_earliestdate',
 ''  as 'billto_state',
 ord.ord_fromschedule as 'ord_fromschedule',
 ord.ord_BelongsTo as 'ord_belongsto',
 ord.rowsec_rsrv_id as 'ord_rowsec_rsrv_id',
 ord.ord_fromorder as 'ord_fromorder',
 ord.ord_datepromised,



 /*******************************************************************************************CAMPOS PERSONALIZADOS********************************************************************************************************************/


 --------SECCION GPS TRACTOR -------------------------------------------------------------------------------------------------------

 trc_gps_latitude=  (case when t.trc_gps_latitude >1000 then  (t.trc_gps_latitude/3600.0) else abs(t.trc_gps_latitude/1.0) end) ,

 trc_gps_longitude= (case when t.trc_gps_latitude >1000 then  (t.trc_gps_longitude/3600.0) else abs(t.trc_gps_longitude/1.0) end) ,

 trc_gps_desc= isnull(trc_gps_desc,''),

 trc_gps_date= isnull(trc_gps_date,''),

 fechagpstxt =  

 case when datediff(dd,t.trc_gps_date,getdate()) = 0  
 then  substring(convert(varchar(24),t.trc_gps_date,114),1,5)
 else +'.'+substring(convert(varchar(24),t.trc_gps_date,1),0,6)  +' '  +  substring(convert(varchar(24),t.trc_gps_date,114),1,5)
 end,

 gpslag= datediff(mi,getdate(), cast (t.trc_gps_date as varchar) )  ,


 estatusgps = case 
		 when  (t.trc_lastpos_nearctynme)  like '%ZBC/%' 
		  then'BAJCOVER'


		 when  t.trc_lastpos_nearctynme  <> '' 
		 
		 and    (datediff(mi,cast (t.trc_gps_date as varchar),getdate() ))   > 15

		 then 'SEG'


		  when t.trc_lastpos_nearctynme  = ''
		 
		 and

		  (datediff(mi,cast (t.trc_gps_date as varchar),getdate() ))  > 15
		 

		  then 'NOSEG'
	
		 else
		    'OK'
		 end,



 ---------ESTATUS DE LA ORDEN---------------------------------------------------------------------------------------------------------
  Statusorden =
  case 


 when lgh.lgh_outstatus = 'AVL'  then '    1.AVL'
 when lgh.lgh_outstatus  = 'PLN'  then '   2.PLN'

 when lgh.lgh_outstatus  = 'DSP' then '    3.DSP'
 when lgh.lgh_outstatus = 'CAN' then '     5.CAN'


 when  
 
--cuando el ultimo sitio registrado en el tractoprofile 
 
  t.trc_lastpos_nearctynme = '['+ cs.cmp_id + ']'
 

--es igual al sitio del stop actual

	
		  then '    4.SIT'

		     when lgh.lgh_outstatus  = 'STD' then '    4.STD'


else ord.ord_status 
end,
t.trc_lastpos_nearctynme,

-------------------------------------------------------------
	
Segmento = lgh.Lgh_number,

Ordennumber = ord.ord_hdrnumber,

Cliente = ord.ord_billto,

Destino = lgh.cmp_id_start,

SitioActual =  t.trc_lastpos_nearctynme,
		 
filterbillto = ord.ord_billto,

CiudadOrigen =  '['+isnull(scompany.cmp_id,'')+']',

CiudadDestino = '['+isnull(ccompany.cmp_id,'')+']',

Remolque = lgh.lgh_primary_trailer + '            |   Placas: '+ isnull((select max(trl_licnum) from trailerprofile (nolock) where trl_number = lgh.lgh_primary_trailer),''),

Escuderia = t.trc_teamleader,

lgh_number = lgh.lgh_number,


InicioOrdenDt = isnull(lgh.lgh_startdate,''),

InicioOrden = isnull( substring(convert(varchar(24),(lgh.lgh_startdate ),1),0,6)  +' '  +  substring(convert(varchar(24),(lgh.lgh_startdate) ,114),1,5) ,''),
		
FinOrdendt = isnull(lgh.lgh_enddate,''),

FinOrden = isnull( substring(convert(varchar(24),(lgh.lgh_enddate ),1),0,6)  +' '  +  substring(convert(varchar(24),(lgh.lgh_enddate) ,114),1,5),''),

proxevento =  ns.stp_event,


ProxDestino =  

cast(ns.stp_mfh_sequence as varchar(2)) +'/'
	      + cast((select max(s.stp_mfh_sequence) from stops  s (nolock) where lgh_number = lgh.lgh_number ) as varchar(2)) 
+ isnull((select '['+isnull(cmp_id,'')+']        ' + isnull(cmp_name,'')  + ' | ' + isnull(cty_nmstct,'')  from company (nolock) where cmp_id = ns.cmp_id),''),


ProxCiudadDestino =  isnull((select cty_nmstct  from company (nolock) where cmp_id = ns.cmp_id),''),

proxcita =  ns.stp_schdtlatest,
 
--considerar si sera arrivaldate o schdt latest
proxCitadt=    (ns.stp_schdtlatest),


Actcomp =  case when cs.stp_number is not null
		  then
		  cast(cs.stp_mfh_sequence as varchar(2)) +'/'
	      + cast((select max(s.stp_mfh_sequence) from stops  s (nolock) where lgh_number = lgh.lgh_number ) as varchar(2)) 
		  +' ' +cs.cmp_id
		   
		  end ,

EstatusIcon =  
		    --Caso en stop
		    (case  when cs.stp_number is not null then
			 cs.stp_event
			--Caso por iniciar viaje
			 when cs.stp_number is null and lgh.lgh_outstatus  in ('AVL','PLN','DSP') then
              '   ' + lgh.lgh_outstatus
			  when ord_status = 'CMP' then 'CMP'
			  when ord_status = 'CAN' then 'CAN'
			  when cs.stp_number is null and lgh.lgh_outstatus = 'CMP' then 'CMP'
			else
			--Caso conduciendo
			'Drvng'
          end),



-----ETA-----------------------------

Elogist =  
         replace(isnull(cast( nse.ste_miles_out  as varchar(10)),'')  + 'K - '  
		 +   (case when  isnull(cast( (nse.ste_seconds_out/60) as varchar(10)),'') < 60 then    isnull(cast(nse.ste_seconds_out/60 as varchar(10)),'')  + 'M'
		 else isnull(cast((nse.ste_seconds_out/3600) as varchar(10)),'') + 'H'   end),'K - M',''),


		  Etadif = round(cast(datediff(MINUTE,ns.stp_schdtearliest,dateadd(n,(nse.ste_seconds_out/60),getdate())) as float) /60 ,1) ,


		     Actdif =  
		    --Caso en stop
		    (case  when cs.stp_number is not null then
			 
			 abs(round(cast(datediff(MINUTE,cs.stp_arrivaldate,getdate()) as float) /60,1))

			--Caso por iniciar viaje
			 when cs.stp_number is null and lgh.lgh_outstatus  in ('AVL','PLN','DSP') then
			

		     abs(round(cast(datediff(MINUTE,t.trc_pln_date,getdate()) as float) /60,1))

			 --Caso viaje terminado
			 when cs.stp_number is null and lgh.lgh_outstatus  in ('CMP') then
			

		     abs(round(cast(datediff(MINUTE,ps.stp_departuredate,getdate()) as float)/60,1))
            
			else
			--Caso conduciendo
			
			abs(round(cast(datediff(MINUTE,ps.stp_departuredate,getdate()) as float)/60,1))
          end)	   ,
		 

		 ETAORDER = 	case when ((select ect_billable from eventcodetable where ns.stp_event = abbr) = 'Y' and (ord.ord_priority = '1' ))  and
		 round(cast(datediff(MINUTE,ns.stp_schdtearliest,dateadd(n,(nse.ste_seconds_out/60),getdate())) as float) /60 ,1) >0
		  then '999999999999'  + round(cast(datediff(MINUTE,ns.stp_schdtearliest,dateadd(n,(nse.ste_seconds_out/60),getdate())) as float) /60 ,1)
		   
		    when ((select ect_billable from eventcodetable where ns.stp_event = abbr) = 'Y' and (ord.ord_priority = '3' )) and
		 round(cast(datediff(MINUTE,ns.stp_schdtearliest,dateadd(n,(nse.ste_seconds_out/60),getdate())) as float) /60 ,1) >0
		  then '99999999998'  + round(cast(datediff(MINUTE,ns.stp_schdtearliest,dateadd(n,(nse.ste_seconds_out/60),getdate())) as float) /60 ,1) 
		  
		  when ((select ect_billable from eventcodetable where ns.stp_event = abbr) = 'Y' and (ord.ord_priority = '3' )) and
		 round(cast(datediff(MINUTE,ns.stp_schdtearliest,dateadd(n,(nse.ste_seconds_out/60),getdate())) as float) /60 ,1) >0
		  then '99999999997'  + round(cast(datediff(MINUTE,ns.stp_schdtearliest,dateadd(n,(nse.ste_seconds_out/60),getdate())) as float) /60 ,1) 
		  when ((select ect_billable from eventcodetable where ns.stp_event = abbr) = 'Y' and (ord.ord_priority = '5' )) and
		 round(cast(datediff(MINUTE,ns.stp_schdtearliest,dateadd(n,(nse.ste_seconds_out/60),getdate())) as float) /60 ,1) >0
		  then '9999999996'  + round(cast(datediff(MINUTE,ns.stp_schdtearliest,dateadd(n,(nse.ste_seconds_out/60),getdate())) as float) /60 ,1) 

					 else   round(cast(datediff(MINUTE,ns.stp_schdtearliest,dateadd(n,(nse.ste_seconds_out/60),getdate())) as float) /60 ,1) end ,  



	


-------SECCION GPS REMOLQUE -------------------------------------------------------------------------------------------------------


GPSDescRemolque = trl.[GPS Description],

 GPSDateRemolque = trl.FechaGPS,

 GPSLoad = trl.LoadEmpt

/*************************************************************************************************CLAUSULADO DEL FROM Y JOINS********************************************************************************************************************/


FROM 
    orderheader ord WITH (NOLOCK)
	LEFT OUTER JOIN legheader_active lgh WITH (NOLOCK) ON lgh.ord_hdrnumber = ord.ord_hdrnumber
	JOIN dbo.tractorprofile t WITH (NOLOCK) ON t.trc_number = lgh.lgh_tractor
	JOIN OperationsTrailerView_TDR trl WITH (NOLOCK)  ON  trl.trl_id = lgh_primary_trailer    
  
    

	LEFT OUTER JOIN company  ccompany WITH (NOLOCK) ON ord.ord_consignee = ccompany.cmp_id  
    LEFT OUTER JOIN company  scompany WITH (NOLOCK) ON ord.ord_shipper = scompany.cmp_id 

	   
	   
	LEFT OUTER JOIN city scity WITH (NOLOCK)  ON  ccompany.cmp_city = scity.cty_code 
	LEFT OUTER JOIN city ecity WITH (NOLOCK)  ON scompany.cmp_city = ecity.cty_code


    LEFT OUTER JOIN Stops_eta dropeta WITH (NOLOCK) ON lgh.next_drp_stp_number = dropeta.stp_number
    LEFT OUTER JOIN Stops_eta pickupeta WITH (NOLOCK) ON lgh.next_pup_stp_number = pickupeta.stp_number
    


    LEFT OUTER JOIN manpowerprofile mpp WITH (NOLOCK) ON  lgh.lgh_driver1 = mpp.mpp_id 
    LEFT OUTER JOIN stops NextDrop WITH (NOLOCK) ON lgh.next_drp_stp_number = NextDrop.stp_number


		--STOP ACTUAL
	               LEFT OUTER JOIN (
                   SELECT mov_number, lgh_number, [StopSequence] = MIN(stp_mfh_sequence)
                   FROM stops WITH (NOLOCK)
                   WHERE stp_departure_status = 'OPN' and stp_status = 'DNE'
                  GROUP BY mov_number, lgh_number
                  ) seq ON lgh.lgh_number = seq.lgh_number
                   LEFT OUTER JOIN stops cs WITH (NOLOCK) ON seq.mov_number = cs.mov_number and seq.StopSequence = cs.stp_mfh_sequence

				    --STOP PREVIO
				    LEFT OUTER JOIN (
                   SELECT mov_number, lgh_number, [StopSequence] = MAX(stp_mfh_sequence)
                   FROM stops WITH (NOLOCK)
                   WHERE stp_departure_status = 'DNE' and stp_status = 'DNE'
                  GROUP BY mov_number, lgh_number
                  ) prev ON lgh.lgh_number = prev.lgh_number
                   LEFT OUTER JOIN stops ps WITH (NOLOCK) ON prev.mov_number = ps.mov_number and prev.StopSequence = ps.stp_mfh_sequence
				   
				   	--PROXIMO STOP
						 LEFT OUTER JOIN (
							SELECT mov_number, lgh_number, [StopSequence] = MIN(stp_mfh_sequence)
							FROM stops WITH (NOLOCK)
							WHERE stp_departure_status = 'OPN' and  stp_status = 'OPN'
							GROUP BY mov_number, lgh_number
							) sig ON lgh.lgh_number = sig.lgh_number
						LEFT OUTER JOIN stops ns WITH (NOLOCK) ON sig.mov_number = ns.mov_number and sig.StopSequence = ns.stp_mfh_sequence
						LEFT OUTER JOIN stops_eta nse WITH (NOLOCK) ON ns.stp_number = nse.stp_number


		


    WHERE t.trc_status <> 'OUT'
	and t.trc_number <> 'UNKNOWN'
	
	










GO
