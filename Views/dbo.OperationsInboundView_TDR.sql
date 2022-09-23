SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


















--select * from [dbo].[OperationsInboundView_TDR]      


CREATE VIEW [dbo].[OperationsInboundView_TDR]      
AS      

	SELECT	result.lgh_number,        
			result.ord_hdrnumber,      
			result.ord_number,   
			result.Referencia,    
			result.OrderPriority,      
			result.StartDate,
			result.EndDate,
			result.DispStatus,
			result.InStatus,
			result.BookedBy,
			result.TotalMailStatus,
			result.BillTo,      
			result.OrderBy,
			result.Mileage,
			result.Shipper,
			result.Consignee,
			result.ConsigneeId,
			result.ConsigneeName,
			result.ConsigneeCity,
			result.ConsigneeState,
			result.ConsigneeRegion1,
			result.ConsigneeRegion2,      
			result.ConsigneeRegion3,
			result.ConsigneeRegion4,
			result.FinalId,
			result.FinalName,
			result.FinalCity,
			result.FinalState,
			result.FinalRegion1,
			result.FinalRegion2,
			result.FinalRegion3,
			result.FinalRegion4,
			result.FinalEarliest,
			result.FinalLatest,
			result.FinalArrival,
			result.FinalDeparture,
			result.OrdCnt,
			result.PupCnt,
			result.DrpCnt,
			result.DetStatus,
			result.TotalVol,
			result.Tractor,
			result.Driver1,
			result.Driver2,
			result.Trailer,
			result.Trailer2,
			result.Carrier,
			result.RevType1,
			result.RevType2,
			result.RevType3, 
			result.RevType4,
			result.LghType1,
			result.LghType2,
			result.LastUpdate,
			result.LastUpdateBy,
			result.ConsigneeLatitude,
			result.ConsigneeLongitude,
			result.FinalLatitude,
			result.FinalLongitude,
			result.Company,
			result.Terminal,
			result.Division,
			result.Fleet,
			result.TeamLeader,
			result.Domicile,
			result.DrvType1,
			result.DrvType2,
			result.DrvType3,
			result.DrvType4,
			result.mpp_qualificationlist,      
			result.DrvStatus,
			result.TrcType1,
			result.TrcType2,
			result.TrcType3,
			result.TrcType4,
			result.trc_accessorylist,      
			result.TrcStatus,
			result.TrlStatus,
			result.TrlType1,
			result.TrlType2,
			result.TrlType3,
			result.TrlType4,
			result.trl_accessorylist,    
			result.CarType1,
			result.CarType2,
			result.CarType3,
			result.CarType4,
			result.lgh_etaalert1,
			result.mpp_exp1_date,
			result.mpp_exp2_date,
			result.trc_exp1_date,
			result.trc_exp2_date,
			result.trl_exp1_date,
			result.trl_exp2_date,
			result.trc_avl_date,
			result.Driver1Name,
			result.Driver2ID,
			result.mpp_last_home,
			result.mpp_want_home,
			result.LghOtherStatus1,
			result.LghOtherStatus2,
			result.ReloadStatus,
      result.lgh_comment,
      result.lgh_trc_comment,

	  	  ----------------------------------------------------------------------------------------
		                                /*CAMPOS PERSONALIZADOS*/
		  -----------------------------------------------------------------------------------------
		  (select trc_gps_desc from tractorprofile where trc_number = result.tractor) 'gpsdesc',
		  
		  (select  (case when datediff(dd,trc_gps_date,getdate()) = 0  
           then '.'+ substring(convert(varchar(24),trc_gps_date,114),1,5)
		   when datediff(dd,trc_gps_date,getdate()) < 0  
           then substring(convert(varchar(24),trc_gps_date,1),0,6)  +' '  +  substring(convert(varchar(24),trc_gps_date,114),1,5) 
		   else '*'+substring(convert(varchar(24),trc_gps_date,1),0,6)  +' '  +  substring(convert(varchar(24),trc_gps_date,114),1,5) end)
          from tractorprofile (nolock)
          where trc_number = (result.tractor) and result.Tractor <> 'UNKNOWN')  'gpsdate',
		  
		  (select trc_gps_date from tractorprofile (nolock)
          where trc_number = (result.tractor))  'gpsdated',
		  
		  (select mpp_mile_day7 from manpowerprofile (nolock) where mpp_id = result.Driver1) as 'sevendays',
		  (SELECT count(*) from trlaccessories where ta_type = 'FM' and ta_trailer = result.Trailer and DateDiff(dd,ta_expire_date ,getdate() ) <= 0) as Fumigacion_rem1,
		  (SELECT count(*) from trlaccessories where ta_type = 'FM' and ta_trailer = result.Trailer2 and DateDiff(dd,ta_expire_date ,getdate() ) <= 0) as Fumigacion_rem2,

		  Elogist,
		  ProxCita,
		  Proxcomp,
		  Proxevent,
		  Actcomp,
		  Actdif,
		  ETAPC,
		  ETADif,
		  EstatusIcon,

		  TRCDispo = trc_avl_date, --  mppavldate
		  (select count(*)from tractoraccesories where  tca_tractor= result.Tractor and tca_type = 'SIS') as [6x2],
		  (select count(*)from tractoraccesories where  tca_tractor= result.Tractor and tca_type = 'PERFUL') as [pfull],
		  (select count(*)from tractoraccesories where  tca_tractor= result.Tractor and tca_type = 'PERMON') as [pmty],
		  (select count(*)from tractoraccesories where  tca_tractor= result.Tractor and tca_type = 'PMRYP') as [pmryp],
		  case result.HOSStatus 
		   when  1 then 'OFF'
		   when  2 then 'SB'
		   when  3 then 'D'
		   when  4 then 'ON'
		   else ' '
		   end as HOSStatus,
		  result.HrsDrv,
		  result.LastHOS,
		  0 as MtMiles

		  /*case when datediff(dd,result.trc_avl_date,getdate()) = 0  
          then '.'+ substring(convert(varchar(24),result.trc_avl_date,114),1,5)
		  when datediff(dd,result.trc_avl_date,getdate()) < 0  
		  then substring(convert(varchar(24),result.trc_avl_date,1),0,6)  +' '  +  substring(convert(varchar(24),result.trc_avl_date,114),1,5)
          else '*'+substring(convert(varchar(24),result.trc_avl_date,1),0,6)  +' '  +  substring(convert(varchar(24),result.trc_avl_date,114),1,5) end*/



          -----------------------------------------------------------------------------------------


	FROM	(
				SELECT lgh.lgh_number,        
					lgh.ord_hdrnumber,      
					RTRIM(oh.ord_number) + CASE WHEN isnull(lgh_split_flag,'N') = 'N' THEN '' ELSE '-' + lgh_split_flag END ord_number,     
					oh.ord_refnum 'Referencia',  

					case when ((select ect_billable from eventcodetable where ns.stp_event = abbr) = 'Y' and (oh.ord_priority = '1' )) then '!'
					when oh.ord_priority= 'UNK' then ' ' else  oh.ord_priority end 'OrderPriority',  
					    
					lgh_startdate 'StartDate',      
					lgh_enddate 'EndDate',      
					lgh.lgh_outstatus 'DispStatus',      
					lgh.lgh_instatus 'InStatus',      
					lgh.ord_bookedby 'BookedBy',      
					lgh_tm_status 'TotalMailStatus',      
					lgh.ord_billto 'BillTo',      
					lgh.ord_company 'OrderBy',      
					lgh.ord_totalmiles 'Mileage', 
					oh.ord_shipper 'Shipper',
					oh.ord_consignee 'Consignee',
					l_cmpid 'ConsigneeId',      
					l_cmpname 'ConsigneeName',      
					l_ctyname 'ConsigneeCity',      
					l_state 'ConsigneeState',      
					ccity.cty_region1 'ConsigneeRegion1',      
					ccity.cty_region2 'ConsigneeRegion2',      
					ccity.cty_region3 'ConsigneeRegion3',      
					ccity.cty_region4 'ConsigneeRegion4',      
					endcompany.cmp_id 'FinalId',      
					endcompany.cmp_name 'FinalName',      
					endcompany.cty_nmstct 'FinalCity',      
					endcompany.cmp_state 'FinalState',      
					endcity.cty_region1 'FinalRegion1',      
					endcity.cty_region2 'FinalRegion2',      
					endcity.cty_region3 'FinalRegion3',      
					endcity.cty_region4 'FinalRegion4',      
					stops.stp_schdtearliest 'FinalEarliest',      
					stops.stp_schdtlatest 'FinalLatest',      
					stops.stp_arrivaldate 'FinalArrival',      
					stops.stp_departuredate 'FinalDeparture',      
					(SELECT count(DISTINCT ord_hdrnumber) FROM stops WHERE stops.lgh_number = lgh.lgh_number AND ord_hdrnumber <> 0 ) 'OrdCnt',      
					(SELECT count(*) FROM stops WHERE stops.lgh_number = lgh.lgh_number AND stp_type = 'PUP') 'PupCnt',      
					(SELECT count(*) FROM stops WHERE stops.lgh_number = lgh.lgh_number AND stp_type = 'DRP') 'DrpCnt',
					(select top 1 stp_detstatus from stops (nolock) where stops.lgh_number = lgh.lgh_number order by stp_detstatus desc) as DetStatus,     
					lgh.ord_totalvolume 'TotalVol',      
					lgh_tractor 'Tractor', lgh_driver1 'Driver1',lgh_driver2 'Driver2', lgh_primary_trailer 'Trailer', lgh_primary_pup 'Trailer2',      
					lgh_carrier 'Carrier',      
					lgh_class1 'RevType1', lgh_class2 'RevType2', lgh_class3 'RevType3', lgh_class4 'RevType4',      
					lgh_type1 'LghType1',      
					lgh_type2 'LghType2',      
					lgh_updatedon 'LastUpdate',      
					lgh_updatedby 'LastUpdateBy',      
					isnull(ccompany.cmp_latseconds/3600.0, ccity.cty_latitude) 'ConsigneeLatitude',      
					isnull(ccompany.cmp_longseconds/3600.0, ccity.cty_longitude) 'ConsigneeLongitude',      
					isnull(endcompany.cmp_latseconds/3600.0, endcity.cty_latitude) 'FinalLatitude',      
					isnull(endcompany.cmp_longseconds/3600.0, endcity.cty_longitude) 'FinalLongitude',      
					trc.trc_company 'Company',      
					trc.trc_terminal 'Terminal',      
					trc.trc_division 'Division',      
					trc.trc_fleet 'Fleet',       
					mpp1.mpp_TeamLeader 'TeamLeader',       
					mpp1.mpp_domicile 'Domicile',       
					mpp1.mpp_type1 'DrvType1',      
					mpp1.mpp_type2 'DrvType2',      
					mpp1.mpp_type3 'DrvType3',      
					mpp1.mpp_type4 'DrvType4',      
					mpp1.mpp_qualificationlist,      
					mpp1.mpp_status 'DrvStatus',
					mpp1.mpp_hosstatus 'HOSStatus',
					mpp1.mpp_dailyhrsest as 'HrsDrv',
					mpp1.mpp_hosactivityupdateon as 'LastHOS',
					mpp1.mpp_pln_date as 'mppplndate',
					mpp1.mpp_avl_date as 'mppavldate',
					trc.trc_type1 'TrcType1',      
					trc.trc_type2 'TrcType2',      
					trc.trc_type3 'TrcType3',      
					trc.trc_type4 'TrcType4',      
					trc.trc_accessorylist,      
					trc.trc_status 'TrcStatus',
					trailerprofile.LoadEmpt 'TrlStatus',      
					trailerprofile.trl_type1 'TrlType1',      
					trailerprofile.trl_type2 'TrlType2',      
					trailerprofile.trl_type3 'TrlType3',      
					trailerprofile.trl_type4 'TrlType4',      
					trailerprofile.trl_accessorylist,    
					carrier.car_type1 'CarType1',      
					carrier.car_type2 'CarType2',      
					carrier.car_type3 'CarType3',      
					carrier.car_type4 'CarType4',  
					lgh.lgh_etaalert1,
					isnull(mpp1.mpp_exp1_date, '12/31/49') 'mpp_exp1_date',
					isnull(mpp1.mpp_exp2_date, '12/31/49') 'mpp_exp2_date',
					isnull(trc.trc_exp1_date, '12/31/49') 'trc_exp1_date',
					isnull(trc.trc_exp2_date, '12/31/49') 'trc_exp2_date',
					isnull(trailerprofile.trl_exp1_date, '12/31/49') 'trl_exp1_date',
					isnull(trailerprofile.trl_exp2_date, '12/31/49') 'trl_exp2_date',
					isnull(trc.trc_avl_date, '12/31/49') 'trc_avl_date',
					mpp1.mpp_lastfirst 'Driver1Name',
					mpp2.mpp_id as 'Driver2ID',
					isnull(mpp1.mpp_last_home, '12/31/49') 'mpp_last_home',
					isnull(mpp1.mpp_want_home, '12/31/49') 'mpp_want_home',
					ISNULL(lgh.lgh_other_status1, 'UNK') 'LghOtherStatus1',
					ISNULL(lgh.lgh_other_status2, 'UNK') 'LghOtherStatus2',
					trc.trc_reload_status 'ReloadStatus',
          lgh.lgh_comment,
          lgh.lgh_trc_comment,
		  (SELECT count(*) from trlaccessories where ta_type = 'FM' and ta_trailer = lgh_primary_trailer and DateDiff(dd,ta_expire_date ,getdate() ) <= 0) as Fumigacion_rem1,
		  (SELECT count(*) from trlaccessories where ta_type = 'FM' and ta_trailer = lgh_primary_pup and DateDiff(dd,ta_expire_date ,getdate() ) <= 0) as Fumigacion_rem2,

		Elogist =  
         replace(isnull(cast( nse.ste_miles_out  as varchar(10)),'')  + 'K - '  
		 +   (case when  isnull(cast( (nse.ste_seconds_out/60) as varchar(10)),'') < 60 then    isnull(cast(nse.ste_seconds_out/60 as varchar(10)),'')  + 'M'
		 else isnull(cast((nse.ste_seconds_out/3600) as varchar(10)),'') + 'H'   end),'K - M',''),
		   
		ProxCita = ns.stp_schdtlatest,


		  Etadif = round(cast(datediff(MINUTE,ns.stp_schdtlatest,dateadd(n,(nse.ste_seconds_out/60),getdate())) as float) /60 ,1) ,



		    Actdif =  
		    --Caso en stop
		    (case  when cs.stp_number is not null then
			 
			 abs(round(cast(datediff(MINUTE,cs.stp_arrivaldate,getdate()) as float) /60,1))

			--Caso por iniciar viaje
			 when cs.stp_number is null and lgh.lgh_outstatus  in ('AVL','PLN','DSP') then
			

		     abs(round(cast(datediff(MINUTE,trc.trc_pln_date,getdate()) as float) /60,1))

			 --Caso viaje terminado
			 when cs.stp_number is null and lgh.lgh_outstatus  in ('CMP') then
			

		     abs(round(cast(datediff(MINUTE,ps.stp_departuredate,getdate()) as float)/60,1))
            
			else
			--Caso conduciendo
			
			abs(round(cast(datediff(MINUTE,ps.stp_departuredate,getdate()) as float)/60,1))
          end),

		  EstatusIcon =  
		    --Caso en stop
		    (case  when cs.stp_number is not null then
			 cs.stp_event
			--Caso por iniciar viaje
			 when cs.stp_number is null and lgh.lgh_outstatus  in ('AVL','PLN') then
              '   ' + lgh.lgh_outstatus
			  when cs.stp_number is null and lgh.lgh_outstatus = 'CMP' then 'CMP'
			   when cs.stp_number is null and lgh.lgh_outstatus  in ('DSP') then
               lgh.lgh_outstatus
			else
			--Caso conduciendo
			'Drvng'
          end),



		  Proxcomp = cast(ns.stp_mfh_sequence as varchar(2)) +'/' + cast((select max(s.stp_mfh_sequence) from stops  s (nolock) where lgh_number = lgh.lgh_number ) as varchar(2))   +' ' +ns.cmp_id + '  -  ' +(select cmp_name from company (nolock) where cmp_id = ns.cmp_id),

		  Proxevent = ns.stp_event,


		  case when cs.stp_number is not null
		  then
		  cast(cs.stp_mfh_sequence as varchar(2)) +'/'
	      + cast((select max(s.stp_mfh_sequence) from stops  s (nolock) where lgh_number = lgh.lgh_number ) as varchar(2)) 
		  +' ' +cs.cmp_id+ '  -  ' +(select cmp_name from company (nolock) where cmp_id = cs.cmp_id)
		   
		  end as Actcomp,



		  dateadd(n,(nse.ste_seconds_out/60),getdate()) as ETAPC

				FROM legheader_active AS lgh 
					LEFT OUTER JOIN city AS ccity ON l_ctyname = ccity.cty_nmstct      
					LEFT OUTER JOIN company AS ccompany ON l_cmpid = ccompany.cmp_id      
					JOIN company AS endcompany ON endcompany.cmp_id  = cmp_id_end      
					JOIN city AS endcity ON endcity.cty_code = lgh_endcity      
					JOIN stops ON stp_number = stp_number_end      
					JOIN manpowerprofile mpp1 ON mpp1.mpp_id = lgh_driver1
					JOIN manpowerprofile mpp2 on mpp2.mpp_id = lgh_driver2
					JOIN TractorProfileRowRestrictedView trc ON trc_number = lgh_tractor      
					JOIN OperationsTrailerView_TDR trailerprofile ON  trailerprofile.trl_id = lgh_primary_trailer    
					JOIN carrier ON carrier.car_id = lgh_carrier     
					LEFT OUTER JOIN stops AS dstop ON next_drp_stp_number = dstop.stp_number      
					LEFT OUTER JOIN company AS dcompany ON dstop.cmp_id = dcompany.cmp_id 
					JOIN labelfile on abbr = lgh_outstatus and labeldefinition = 'DispStatus' and code >= 220
					INNER JOIN OrderHeaderRowRestrictedView oh on lgh.ord_hdrnumber = oh.ord_hdrnumber
					
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




				UNION

				SELECT lgh.lgh_number,        
					lgh.ord_hdrnumber,  
					NULL as 'Referencia',   
					NULL AS ord_number,       
					NULL AS OrderPriority,      
					lgh_startdate 'StartDate',      
					lgh_enddate 'EndDate',      
					lgh.lgh_outstatus 'DispStatus',      
					lgh.lgh_instatus 'InStatus',      
					lgh.ord_bookedby 'BookedBy',      
					lgh_tm_status 'TotalMailStatus',      
					lgh.ord_billto 'BillTo',      
					lgh.ord_company 'OrderBy',      
					lgh.ord_totalmiles 'Mileage', 
					''  'Shipper',
				    ''  'Consignee',   
					l_cmpid 'ConsigneeId',      
					l_cmpname 'ConsigneeName',      
					l_ctyname 'ConsigneeCity',      
					l_state 'ConsigneeState',      
					ccity.cty_region1 'ConsigneeRegion1',      
					ccity.cty_region2 'ConsigneeRegion2',      
					ccity.cty_region3 'ConsigneeRegion3',      
					ccity.cty_region4 'ConsigneeRegion4',      
					endcompany.cmp_id 'FinalId',      
					endcompany.cmp_name 'FinalName',      
					endcompany.cty_nmstct 'FinalCity',      
					endcompany.cmp_state 'FinalState',      
					endcity.cty_region1 'FinalRegion1',      
					endcity.cty_region2 'FinalRegion2',      
					endcity.cty_region3 'FinalRegion3',      
					endcity.cty_region4 'FinalRegion4',      
					stops.stp_schdtearliest 'FinalEarliest',      
					stops.stp_schdtlatest 'FinalLatest',      
					stops.stp_arrivaldate 'FinalArrival',      
					stops.stp_departuredate 'FinalDeparture',      
					(SELECT count(DISTINCT ord_hdrnumber) FROM stops WHERE stops.lgh_number = lgh.lgh_number AND ord_hdrnumber <> 0 ) 'OrdCnt',      
					(SELECT count(*) FROM stops WHERE stops.lgh_number = lgh.lgh_number AND stp_type = 'PUP') 'PupCnt',      
					(SELECT count(*) FROM stops WHERE stops.lgh_number = lgh.lgh_number AND stp_type = 'DRP') 'DrpCnt',
					(select top 1 stp_detstatus from stops (nolock) where stops.lgh_number = lgh.lgh_number order by stp_detstatus desc) as DetStatus,     
					lgh.ord_totalvolume 'TotalVol',      
					lgh_tractor 'Tractor', lgh_driver1 'Driver1',lgh_driver2 'Driver2', lgh_primary_trailer 'Trailer', lgh_primary_pup 'Trailer2',      
					lgh_carrier 'Carrier',      
					lgh_class1 'RevType1', lgh_class2 'RevType2', lgh_class3 'RevType3', lgh_class4 'RevType4',      
					lgh_type1 'LghType1',      
					lgh_type2 'LghType2',      
					lgh_updatedon 'LastUpdate',      
					lgh_updatedby 'LastUpdateBy',      
					isnull(ccompany.cmp_latseconds/3600.0, ccity.cty_latitude) 'ConsigneeLatitude',      
					isnull(ccompany.cmp_longseconds/3600.0, ccity.cty_longitude) 'ConsigneeLongitude',      
					isnull(endcompany.cmp_latseconds/3600.0, endcity.cty_latitude) 'FinalLatitude',      
					isnull(endcompany.cmp_longseconds/3600.0, endcity.cty_longitude) 'FinalLongitude',      
					trc.trc_company 'Company',      
					trc.trc_terminal 'Terminal',      
					trc.trc_division 'Division',      
					trc.trc_fleet 'Fleet',       
					mpp1.mpp_TeamLeader 'TeamLeader',       
					mpp1.mpp_domicile 'Domicile',       
					mpp1.mpp_type1 'DrvType1',      
					mpp1.mpp_type2 'DrvType2',      
					mpp1.mpp_type3 'DrvType3',      
					mpp1.mpp_type4 'DrvType4',      
					mpp1.mpp_qualificationlist,      
					mpp1.mpp_status 'DrvStatus',
					mpp1.mpp_hosstatus 'HOSStatus',
					mpp1.mpp_dailyhrsest as 'HrsDrv',
					mpp1.mpp_hosactivityupdateon as 'LastHOS',
				    mpp1.mpp_pln_date as 'mppplndate',
					mpp1.mpp_avl_date as 'mppavldate',
					trc.trc_type1 'TrcType1',      
					trc.trc_type2 'TrcType2',      
					trc.trc_type3 'TrcType3',      
					trc.trc_type4 'TrcType4',      
					trc.trc_accessorylist,      
					trc.trc_status 'TrcStatus',
					trailerprofile.LoadEmpt 'TrlStatus',      
					trailerprofile.trl_type1 'TrlType1',      
					trailerprofile.trl_type2 'TrlType2',      
					trailerprofile.trl_type3 'TrlType3',      
					trailerprofile.trl_type4 'TrlType4',      
					trailerprofile.trl_accessorylist,    
					carrier.car_type1 'CarType1',      
					carrier.car_type2 'CarType2',      
					carrier.car_type3 'CarType3',      
					carrier.car_type4 'CarType4',  
					lgh.lgh_etaalert1,
					isnull(mpp1.mpp_exp1_date, '12/31/49') 'mpp_exp1_date',
					isnull(mpp1.mpp_exp2_date, '12/31/49') 'mpp_exp2_date',
					isnull(trc.trc_exp1_date, '12/31/49') 'trc_exp1_date',
					isnull(trc.trc_exp2_date, '12/31/49') 'trc_exp2_date',
					isnull(trailerprofile.trl_exp1_date, '12/31/49') 'trl_exp1_date',
					isnull(trailerprofile.trl_exp2_date, '12/31/49') 'trl_exp2_date',
					isnull(trc.trc_pln_date, '12/31/49') 'trc_avl_date',
					mpp1.mpp_lastfirst 'Driver1Name',
					mpp2.mpp_id as 'Driver2ID',
					isnull(mpp1.mpp_last_home, '12/31/49') 'mpp_last_home',
					isnull(mpp1.mpp_want_home, '12/31/49') 'mpp_want_home',
					ISNULL(lgh.lgh_other_status1, 'UNK') 'LghOtherStatus1',
					ISNULL(lgh.lgh_other_status2, 'UNK') 'LghOtherStatus2',
					trc.trc_reload_status 'ReloadStatus',
          lgh.lgh_comment,
          lgh.lgh_trc_comment,
		  (SELECT count(*) from trlaccessories where ta_type = 'FM' and ta_trailer = lgh_primary_trailer and DateDiff(dd,ta_expire_date ,getdate() ) <= 0) as Fumigacion_rem1,
		  (SELECT count(*) from trlaccessories where ta_type = 'FM' and ta_trailer = lgh_primary_pup and DateDiff(dd,ta_expire_date ,getdate() ) <= 0) as Fumigacion_rem2,

		Elogist =  
         
		      replace(isnull(cast( nse.ste_miles_out  as varchar(10)),'')  + ' K - '  
		 +   (case when  isnull(cast( (nse.ste_seconds_out/60) as varchar(10)),'') < 60 then    isnull(cast(nse.ste_seconds_out/60 as varchar(10)),'')  + 'M'
		 else isnull(cast((nse.ste_seconds_out/3600) as varchar(10)),'') + 'H'   end),'K - M',''),



	      	ProxCita = ns.stp_schdtlatest,
			
			/*case when datediff(dd,ns.stp_schdtlatest,getdate()) = 0  
           then '.'+ substring(convert(varchar(24),ns.stp_schdtlatest,114),1,5)
		   when datediff(dd,ns.stp_schdtlatest,getdate()) < 0  
           then substring(convert(varchar(24),ns.stp_schdtlatest,1),0,6)  +' '  +  substring(convert(varchar(24),ns.stp_schdtlatest,114),1,5) 
           else '*' + substring(convert(varchar(24),ns.stp_schdtlatest,1),0,6)  +' '  +  substring(convert(varchar(24),ns.stp_schdtlatest,114),1,5) end,*/

	     	  
		  Etadif = round(cast(datediff(MINUTE,ns.stp_schdtlatest,dateadd(n,(nse.ste_seconds_out/60),getdate())) as float) /60 ,1) ,


		    Actdif =  
		    --Caso en stop
		    (case  when cs.stp_number is not null then
			 
			 abs(round(cast(datediff(MINUTE,cs.stp_arrivaldate,getdate()) as float) /60,1))

			--Caso por iniciar viaje
			 when cs.stp_number is null and lgh.lgh_outstatus  in ('AVL','PLN','DSP') then
			

		     abs(round(cast(datediff(MINUTE,trc.trc_pln_date,getdate()) as float) /60,1))

			 --Caso viaje terminado
			 when cs.stp_number is null and lgh.lgh_outstatus  in ('CMP') then
			

		     abs(round(cast(datediff(MINUTE,ps.stp_departuredate,getdate()) as float)/60,1))
            
			else
			--Caso conduciendo
			
			abs(round(cast(datediff(MINUTE,ps.stp_departuredate,getdate()) as float)/60,1))
          end),

		   EstatusIcon =  
		    --Caso en stop
		    (case  when cs.stp_number is not null then
			 cs.stp_event
			--Caso por iniciar viaje
			 when cs.stp_number is null and lgh.lgh_outstatus  in ('AVL','PLN') then
              '   ' + lgh.lgh_outstatus
			  when cs.stp_number is null and lgh.lgh_outstatus = 'CMP' then 'CMP'
			   when cs.stp_number is null and lgh.lgh_outstatus  in ('DSP') then
               lgh.lgh_outstatus
			else
			--Caso conduciendo
			'Drvng'
          end),



             Proxcomp = cast(ns.stp_mfh_sequence as varchar(2)) +'/' + cast((select max(s.stp_mfh_sequence) from stops  s (nolock) where lgh_number = lgh.lgh_number ) as varchar(2))   +' ' +ns.cmp_id +' ' +ns.cmp_id + '  -  ' +(select cmp_name from company (nolock) where cmp_id = ns.cmp_id),

		  Proxevent = ns.stp_event,


	
		    case when cs.stp_number is not null
		  then
		  cast(cs.stp_mfh_sequence as varchar(2)) +'/'
	      + cast((select max(s.stp_mfh_sequence) from stops  s (nolock) where lgh_number = lgh.lgh_number ) as varchar(2)) 
		  +' ' +cs.cmp_id +' ' +ns.cmp_id + '  -  ' +(select cmp_name from company (nolock) where cmp_id = cs.cmp_id)
		   
		  end as Actcomp,


		  dateadd(n,(nse.ste_seconds_out/60),getdate()) as ETAPC

				FROM legheader_active AS lgh
					LEFT OUTER JOIN city AS ccity ON l_ctyname = ccity.cty_nmstct      
					LEFT OUTER JOIN company AS ccompany ON l_cmpid = ccompany.cmp_id      
					JOIN company AS endcompany ON endcompany.cmp_id  = cmp_id_end      
					JOIN city AS endcity ON endcity.cty_code = lgh_endcity      
					JOIN stops ON stp_number = stp_number_end      
					JOIN manpowerprofile mpp1 ON mpp1.mpp_id = lgh_driver1
					JOIN manpowerprofile mpp2 on mpp2.mpp_id = lgh_driver2
					INNER JOIN TractorProfileRowRestrictedView trc ON trc_number = lgh_tractor
					JOIN OperationsTrailerView_TDR trailerprofile ON  trailerprofile.trl_id = lgh_primary_trailer         
					JOIN carrier ON carrier.car_id = lgh_carrier     
					LEFT OUTER JOIN stops AS dstop ON next_drp_stp_number = dstop.stp_number      
					LEFT OUTER JOIN company AS dcompany ON dstop.cmp_id = dcompany.cmp_id 
					JOIN labelfile on abbr = lgh_outstatus and labeldefinition = 'DispStatus' and code >= 220

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




				WHERE ISNULL(lgh.ord_hdrnumber, 0) = 0

			) result




		

































GO
