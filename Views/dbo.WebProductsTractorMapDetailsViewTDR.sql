SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











CREATE VIEW [dbo].[WebProductsTractorMapDetailsViewTDR] as

SELECT  

 number = t.trc_number,

 referencia = isnull(ord.ord_refnum,'N.D'),

 origen =   scompany.cmp_name,

 
 elogist =  
          isnull(case  when cs.stp_number is not null  then  cast(cs.stp_mfh_sequence as varchar(2)) +'/' + 
	      + cast((select max(s.stp_sequence) from stops s (nolock) where lgh_number  = lgh.lgh_number)  as varchar(2)) 
	      + ' ' +( select name from eventcodetable (nolock) where abbr = cs.stp_event) + ' en. ' + (select cmp_name from company (nolock) where cmp_id = cs.cmp_id)
          when cs.stp_number is null and lgh.lgh_outstatus  in ('AVL','PLN','DSP') then 'Viaje planeado para iniciar el: ' + convert(nvarchar(MAX), lgh.lgh_startdate, 20)
          else 

		  isnull(cast( nse.ste_miles_out  as varchar(10)),'')  + ' Kms --- '  
		 +   (case when  (nse.ste_seconds_out/60)  < 60 then    isnull(cast(nse.ste_seconds_out/60 as varchar(10)),'')  + ' Minutos'
		  else isnull(cast((nse.ste_seconds_out/3600) as varchar(10)),'') + ' Hora(s)'   end) + ' Llegada: ' + cast( dateadd(n,(nse.ste_seconds_out/60),getdate()) as varchar(100))

          end,'Disponible'),


 proxevento =  isnull(isnull(( select name from eventcodetable (nolock) where abbr = ns.stp_event),ns.stp_event),''),


 proxdestino =  cast(ns.stp_mfh_sequence as varchar(2)) +'/'
	      + cast((select max(s.stp_mfh_sequence) from stops  s (nolock) where lgh_number = lgh.lgh_number ) as varchar(2)) 
+ isnull((select '['+isnull(cmp_id,'')+']        ' + isnull(cmp_name,'')  + ' | ' + isnull(cty_nmstct,'')  from company (nolock) where cmp_id = ns.cmp_id),''),
 
 proxcita=    isnull(cast(ns.stp_schdtlatest as varchar(120)),''),

 ontime =  case when getdate() > ns.stp_schdtearliest then 'Retraso' else 'En Tiempo' End,

 
 destino=  UPPER(ccompany.cmp_name) ,

 operador =    isnull((mpp.mpp_firstname +' '+ mpp.mpp_lastname),'N.D'),

 remolques =  replace(replace(isnull((lgh.lgh_primary_trailer),''),'UNKNOWN','') +' | '+ isnull((lgh.lgh_primary_pup ),''),'| UNKNOWN',''),

 checkcall =  (cast (t.trc_gps_date as varchar))  +  ' | ' +  cast (t.trc_gps_desc as varchar),

 googlemaps =  

				'https://www.google.com.mx/maps/dir/' + rtrim(replace(ecity.cty_name,'','+')) + ',+' + ( select  rtrim(replace(stc_state_desc,'','+'))  from statecountry where stc_state_c = ecity.cty_state)  +'./' +
				CAST((t.trc_gps_latitude) / 3600.00 AS varchar)  + ',-' +
				CAST((t.trc_gps_longitude)/ 3600.00 AS varchar) ,
				

 ord.ord_hdrnumber,

 ord_status,

 dbo.TractorColorAndDirection( lgh.lgh_number, dropeta.stp_number,ord.ord_billto, NextDrop.stp_arrivaldate, NextDrop.stp_schdtearliest, NextDrop.stp_schdtlatest ,  DATEADD(ss, dropeta.ste_seconds_out,dropeta.ste_updated)) as 'Icon1'  


FROM dbo.tractorprofile t WITH (NOLOCK) 
    JOIN legheader_active lgh WITH (NOLOCK) ON t.trc_number = lgh.lgh_tractor
  
    LEFT OUTER JOIN company  scompany WITH (NOLOCK) ON lgh.cmp_id_start = scompany.cmp_id 
    LEFT OUTER JOIN city scity WITH (NOLOCK)  ON lgh.lgh_startcity = scity.cty_code 
	LEFT OUTER JOIN city ecity WITH (NOLOCK)  ON lgh.lgh_endcity = ecity.cty_code 
    LEFT OUTER JOIN orderheader ord WITH (NOLOCK) ON lgh.ord_hdrnumber = ord.ord_hdrnumber
	  LEFT OUTER JOIN company  ccompany WITH (NOLOCK) ON ord.ord_consignee = ccompany.cmp_id  
    LEFT OUTER JOIN Stops_eta dropeta WITH (NOLOCK) ON lgh.next_drp_stp_number = dropeta.stp_number
    LEFT OUTER JOIN Stops_eta pickupeta WITH (NOLOCK) ON lgh.next_pup_stp_number = pickupeta.stp_number
    
--STOP ACTUAL
	LEFT OUTER JOIN (
        SELECT mov_number, lgh_number, [StopSequence] = MIN(stp_mfh_sequence)
        FROM stops WITH (NOLOCK)
        WHERE stp_departure_status = 'OPN' and stp_status = 'DNE'
        GROUP BY mov_number, lgh_number
        ) seq ON lgh.lgh_number = seq.lgh_number
    LEFT OUTER JOIN stops cs WITH (NOLOCK) ON seq.mov_number = cs.mov_number and seq.StopSequence = cs.stp_mfh_sequence

--PROXIMO STOP
	 LEFT OUTER JOIN (
        SELECT mov_number, lgh_number, [StopSequence] = MIN(stp_mfh_sequence)
        FROM stops WITH (NOLOCK)
        WHERE stp_departure_status = 'OPN' and  stp_status = 'OPN'
        GROUP BY mov_number, lgh_number
        ) sig ON lgh.lgh_number = sig.lgh_number
	LEFT OUTER JOIN stops ns WITH (NOLOCK) ON sig.mov_number = ns.mov_number and sig.StopSequence = ns.stp_mfh_sequence
	LEFT OUTER JOIN stops_eta nse WITH (NOLOCK) ON ns.stp_number = nse.stp_number



    LEFT OUTER JOIN manpowerprofile mpp WITH (NOLOCK) ON  lgh.lgh_driver1 = mpp.mpp_id 
    LEFT OUTER JOIN stops NextDrop WITH (NOLOCK) ON lgh.next_drp_stp_number = NextDrop.stp_number
    WHERE t.trc_status <> 'OUT' AND lgh.lgh_outstatus = 'STD'  and t.trc_number <> 'UNKNOWN'
	-- AND cs.stp_status <> 'DNE'  AND cs.stp_departure_status <> 'DNE'  










GO
