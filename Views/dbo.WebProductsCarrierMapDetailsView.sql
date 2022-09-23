SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--select * from WebProductsCarrierMapDetailsView


CREATE VIEW [dbo].[WebProductsCarrierMapDetailsView] as

SELECT  



 number = 

 (Select distinct lha.lgh_carrier
                FROM stops s (nolock)
               JOIN legheader_active lha on s.lgh_number = lha.lgh_number or s.ord_hdrnumber = lha.ord_hdrnumber 
               WHERE lha.lgh_outstatus = 'STD' 
              AND s.ord_hdrnumber = (orderheader.ord_hdrnumber ))

 
 
 ,

 referencia = isnull(ord_refnum,'N.D'),

 origen =   (select cmp_name from company where cmp_id = ord_shipper),


 elogist  =  
 case 
 when (case when ord_status = 'PLN' and (select  count(*) from legheader li where li.mov_number = mov_number and lgh_outstatus = 'STD' )  > 0
	  then 'STD' 
	  when ord_status = 'PLN' and (select  count(*) from legheader li where li.mov_number = mov_number and lgh_outstatus = 'STD' )  = 0
	  then 'PLN'
	  when ord_status = 'DSP' then 'STD'
	  else ord_status end)   = 'STD' 
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
end,



 proxevento = isnull(( select name from eventcodetable  where abbr = (select stp_event from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN'))),''),
 
 proxdestino = isnull((select cmp_name from company where cmp_id =
  (select cmp_id from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN'))),''),
 
 proxcita=isnull((select stp_schdtlatest from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN')),''),

 ontime =  (case when getdate() >

  (select  stp_schdtearliest from stops  where stops.ord_hdrnumber = orderheader.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = orderheader.ord_hdrnumber and stp_status = 'OPN'))
 then 'Retraso'
 else 'En Tiempo'
 End
 ),

 destino=  (select cmp_name from company where cmp_id = ord_consignee),

 operador =   
 isnull((select mpp_firstname +' '+ mpp_lastname from manpowerprofile where mpp_id =ord_Driver1),'N.D'),


 remolques =
 replace(replace(isnull((select  top 1 lgh_primary_trailer from legheader where legheader.ord_hdrnumber = orderheader.ord_hdrnumber ),''),'UNKNOWN','')
 +' | '+
isnull((select top 1 lgh_primary_pup from legheader where legheader.ord_hdrnumber =  orderheader.ord_hdrnumber ),''),'| UNKNOWN',''),




 checkcall = 
 
    (select cast(max(ckc_date) as varchar(30)) from checkcall (nolock) where ckc_lghnumber= (select max(lgh_number) from legheader_active (nolock) where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)) +
 ' | ' +   
 (select isnull(max(ckc_comment),'Carrier sin GPS')  from checkcall ck (nolock) 
	where
	ckc_date = (select max(ckc_date) from checkcall (nolock) where ckc_lghnumber= (select max(lgh_number) from legheader_active (nolock) where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber)))
 ,

 googlemaps =  



				'https://www.google.com.mx/maps/dir/' + ( select rtrim(replace(cty_name,'','+')) from city where cty_code = ord_destcity) + ',+' + ( select  rtrim(replace(stc_state_desc,'','+'))  from statecountry where stc_state_c = ord_deststate)  +'./' +
				CAST((select max(ckc_longseconds) from checkcall (nolock) where ckc_lghnumber= (select max(lgh_number) from legheader_active (nolock) where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber))/ 3600.00 AS varchar)  + ',-' +
				CAST((select max(ckc_latseconds) from checkcall (nolock) where ckc_lghnumber= (select max(lgh_number) from legheader_active (nolock) where legheader_active.ord_hdrnumber = orderheader.ord_hdrnumber))/ 3600.00 AS varchar) ,
				
				
				--+'/@' +
	            --CAST((select trc_gps_latitude from tractorprofile where trc_number = ord_tractor) / 3600.00 AS varchar)  + ',' +
				--CAST((select trc_gps_longitude from tractorprofile where trc_number = ord_tractor)/ 3600.00 AS varchar)  ,

			
			/*
				 'http://maps.google.com.mx/maps?F=Q&source=s_q&hl=es&geocode=&q=' + CAST((select trc_gps_latitude from tractorprofile where trc_number = ord_tractor) / 3600.00 AS varchar) 
                   + ',-' + CAST((select trc_gps_longitude from tractorprofile where trc_number = ord_tractor)/ 3600.00 AS varchar) + ' & z=13' ,*/




 ord_hdrnumber,
 ord_status





FROM         dbo.orderheader (nolock)

  where (select RTRIM(max(dbo.legheader.lgh_outstatus)) from legheader where   dbo.orderheader.ord_hdrnumber = legheader.ord_hdrnumber) = 'STD'
and

 (Select distinct lha.lgh_carrier
                FROM stops s (nolock)
               JOIN legheader_active lha on s.lgh_number = lha.lgh_number or s.ord_hdrnumber = lha.ord_hdrnumber 
               WHERE lha.lgh_outstatus = 'STD' 
              AND s.ord_hdrnumber = (orderheader.ord_hdrnumber )) <> 'UNKNOWN'




GO
GRANT SELECT ON  [dbo].[WebProductsCarrierMapDetailsView] TO [public]
GO
