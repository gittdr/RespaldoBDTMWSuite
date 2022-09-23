SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [dbo].[OperationsInboundView_TDRsimple]      
AS      

	SELECT	result.lgh_number,        
			result.ord_hdrnumber,      
			result.ord_number,       
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
	        result.kms7dias,
			result.TipoLicencia,
	        result.gpsdesc,
	        result.gpsdated,
            result.gpsdate
		  


	FROM	(
				SELECT leg.lgh_number,        
					leg.ord_hdrnumber,      
					RTRIM(oh.ord_number) + CASE WHEN isnull(lgh_split_flag,'N') = 'N' THEN '' ELSE '-' + lgh_split_flag END ord_number,       
					oh.ord_priority AS OrderPriority,      
					lgh_startdate 'StartDate',      
					lgh_enddate 'EndDate',      
					leg.lgh_outstatus 'DispStatus',      
					leg.lgh_instatus 'InStatus',      
					leg.ord_bookedby 'BookedBy',      
					lgh_tm_status 'TotalMailStatus',      
					leg.ord_billto 'BillTo',      
					leg.ord_company 'OrderBy',      
					leg.ord_totalmiles 'Mileage',      
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
					(SELECT count(DISTINCT ord_hdrnumber) FROM stops WHERE stops.lgh_number = leg.lgh_number AND ord_hdrnumber <> 0 ) 'OrdCnt',      
					(SELECT count(*) FROM stops WHERE stops.lgh_number = leg.lgh_number AND stp_type = 'PUP') 'PupCnt',      
					(SELECT count(*) FROM stops WHERE stops.lgh_number = leg.lgh_number AND stp_type = 'DRP') 'DrpCnt',
					(select top 1 stp_detstatus from stops (nolock) where stops.lgh_number = leg.lgh_number order by stp_detstatus desc) as DetStatus,     
					leg.ord_totalvolume 'TotalVol',      
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
				    mpp1.mpp_mile_day7 as 'kms7dias', 
					mpp1.mpp_licenseclass AS 'TipoLicencia',
					trc.trc_type1 'TrcType1',      
					trc.trc_type2 'TrcType2',      
					trc.trc_type3 'TrcType3',      
					trc.trc_type4 'TrcType4',      
					trc.trc_accessorylist,      
					trc.trc_status 'TrcStatus',
                    trc.trc_gps_desc  'gpsdesc',
					trc.trc_gps_date  'gpsdated',

					case when datediff(dd,trc.trc_gps_date,getdate()) = 0  
                    then '.'+ substring(convert(varchar(24),trc.trc_gps_date,114),1,5)
		            when datediff(dd,trc.trc_gps_date,getdate()) < 0  
                    then substring(convert(varchar(24),trc.trc_gps_date,1),0,6)  +' '  +  substring(convert(varchar(24),trc.trc_gps_date,114),1,5) 
		            else '*'+substring(convert(varchar(24),trc.trc_gps_date,1),0,6)  +' '  +  substring(convert(varchar(24),trc.trc_gps_date,114),1,5) end as 'gpsdate',
		  

					trailerprofile.trl_status 'TrlStatus',      
					trailerprofile.trl_type1 'TrlType1',      
					trailerprofile.trl_type2 'TrlType2',      
					trailerprofile.trl_type3 'TrlType3',      
					trailerprofile.trl_type4 'TrlType4',      
					trailerprofile.trl_accessorylist,    
					carrier.car_type1 'CarType1',      
					carrier.car_type2 'CarType2',      
					carrier.car_type3 'CarType3',      
					carrier.car_type4 'CarType4',  
					leg.lgh_etaalert1,
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
					ISNULL(leg.lgh_other_status1, 'UNK') 'LghOtherStatus1',
					ISNULL(leg.lgh_other_status2, 'UNK') 'LghOtherStatus2',
					trc.trc_reload_status 'ReloadStatus',
          leg.lgh_comment,
          leg.lgh_trc_comment
				FROM legheader_active AS leg 
					LEFT OUTER JOIN city AS ccity ON l_ctyname = ccity.cty_nmstct      
					LEFT OUTER JOIN company AS ccompany ON l_cmpid = ccompany.cmp_id      
					JOIN company AS endcompany ON endcompany.cmp_id  = cmp_id_end      
					JOIN city AS endcity ON endcity.cty_code = lgh_endcity      
					JOIN stops ON stp_number = stp_number_end      
					JOIN manpowerprofile mpp1 ON mpp1.mpp_id = lgh_driver1
					JOIN manpowerprofile mpp2 on mpp2.mpp_id = lgh_driver2
					JOIN TractorProfileRowRestrictedView trc ON trc_number = lgh_tractor      
					JOIN trailerprofile ON trailerprofile.trl_id = lgh_primary_trailer      
					JOIN carrier ON carrier.car_id = lgh_carrier     
					LEFT OUTER JOIN stops AS dstop ON next_drp_stp_number = dstop.stp_number      
					LEFT OUTER JOIN company AS dcompany ON dstop.cmp_id = dcompany.cmp_id 
					JOIN labelfile on abbr = lgh_outstatus and labeldefinition = 'DispStatus' and code >= 220
					INNER JOIN OrderHeaderRowRestrictedView oh on leg.ord_hdrnumber = oh.ord_hdrnumber
					WHERE trc.trc_status IN ('AVL','PLN','STD','DSP','USE') AND mpp1.mpp_status IN ('AVL','PLN','STD','DSP','USE')
					AND trailerprofile.trl_status IN ('AVL','PLN','STD','DSP','USE')


					--select distinct  trc_status from tractorprofile

				UNION

				SELECT leg.lgh_number,        
					leg.ord_hdrnumber,      
					NULL AS ord_number,       
					NULL AS OrderPriority,      
					lgh_startdate 'StartDate',      
					lgh_enddate 'EndDate',      
					leg.lgh_outstatus 'DispStatus',      
					leg.lgh_instatus 'InStatus',      
					leg.ord_bookedby 'BookedBy',      
					lgh_tm_status 'TotalMailStatus',      
					leg.ord_billto 'BillTo',      
					leg.ord_company 'OrderBy',      
					leg.ord_totalmiles 'Mileage',      
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
					(SELECT count(DISTINCT ord_hdrnumber) FROM stops WHERE stops.lgh_number = leg.lgh_number AND ord_hdrnumber <> 0 ) 'OrdCnt',      
					(SELECT count(*) FROM stops WHERE stops.lgh_number = leg.lgh_number AND stp_type = 'PUP') 'PupCnt',      
					(SELECT count(*) FROM stops WHERE stops.lgh_number = leg.lgh_number AND stp_type = 'DRP') 'DrpCnt',
					(select top 1 stp_detstatus from stops (nolock) where stops.lgh_number = leg.lgh_number order by stp_detstatus desc) as DetStatus,     
					leg.ord_totalvolume 'TotalVol',      
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
					mpp1.mpp_mile_day7 as 'kms7dias', 
					mpp1.mpp_licenseclass AS 'TipoLicencia',
					trc.trc_type1 'TrcType1',      
					trc.trc_type2 'TrcType2',      
					trc.trc_type3 'TrcType3',      
					trc.trc_type4 'TrcType4',      
					trc.trc_accessorylist,      
					trc.trc_status 'TrcStatus',

					trc.trc_gps_desc  'gpsdesc',
					trc.trc_gps_date  'gpsdated',

					case when datediff(dd,trc.trc_gps_date,getdate()) = 0  
                    then '.'+ substring(convert(varchar(24),trc.trc_gps_date,114),1,5)
		            when datediff(dd,trc.trc_gps_date,getdate()) < 0  
                    then substring(convert(varchar(24),trc.trc_gps_date,1),0,6)  +' '  +  substring(convert(varchar(24),trc.trc_gps_date,114),1,5) 
		            else '*'+substring(convert(varchar(24),trc.trc_gps_date,1),0,6)  +' '  +  substring(convert(varchar(24),trc.trc_gps_date,114),1,5) end as 'gpsdate',
		  
					trailerprofile.trl_status 'TrlStatus',      
					trailerprofile.trl_type1 'TrlType1',      
					trailerprofile.trl_type2 'TrlType2',      
					trailerprofile.trl_type3 'TrlType3',      
					trailerprofile.trl_type4 'TrlType4',      
					trailerprofile.trl_accessorylist,    
					carrier.car_type1 'CarType1',      
					carrier.car_type2 'CarType2',      
					carrier.car_type3 'CarType3',      
					carrier.car_type4 'CarType4',  
					leg.lgh_etaalert1,
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
					ISNULL(leg.lgh_other_status1, 'UNK') 'LghOtherStatus1',
					ISNULL(leg.lgh_other_status2, 'UNK') 'LghOtherStatus2',
					trc.trc_reload_status 'ReloadStatus',
          leg.lgh_comment,
          leg.lgh_trc_comment
				FROM legheader_active AS leg 
					LEFT OUTER JOIN city AS ccity ON l_ctyname = ccity.cty_nmstct      
					LEFT OUTER JOIN company AS ccompany ON l_cmpid = ccompany.cmp_id      
					JOIN company AS endcompany ON endcompany.cmp_id  = cmp_id_end      
					JOIN city AS endcity ON endcity.cty_code = lgh_endcity      
					JOIN stops ON stp_number = stp_number_end      
					JOIN manpowerprofile mpp1 ON mpp1.mpp_id = lgh_driver1
					JOIN manpowerprofile mpp2 on mpp2.mpp_id = lgh_driver2
					INNER JOIN TractorProfileRowRestrictedView trc ON trc_number = lgh_tractor
					JOIN trailerprofile ON trailerprofile.trl_id = lgh_primary_trailer      
					JOIN carrier ON carrier.car_id = lgh_carrier     
					LEFT OUTER JOIN stops AS dstop ON next_drp_stp_number = dstop.stp_number      
					LEFT OUTER JOIN company AS dcompany ON dstop.cmp_id = dcompany.cmp_id 
					JOIN labelfile on abbr = lgh_outstatus and labeldefinition = 'DispStatus' and code >= 220
				WHERE ISNULL(leg.ord_hdrnumber, 0) = 0
				AND trc.trc_status IN ('AVL','PLN','STD','DSP','USE') AND mpp1.mpp_status IN ('AVL','PLN','STD','DSP','USE')
					AND trailerprofile.trl_status IN ('AVL','PLN','STD','DSP','USE')
			) result
		




GO
