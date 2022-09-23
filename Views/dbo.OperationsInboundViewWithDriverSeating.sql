SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[OperationsInboundViewWithDriverSeating]      
AS      
SELECT leg.lgh_number,        
	leg.ord_hdrnumber,      
	rtrim((SELECT ord_number FROM orderheader WHERE ord_hdrnumber = leg.ord_hdrnumber))+ CASE WHEN isnull(lgh_split_flag,'N') = 'N' THEN '' ELSE '-' + lgh_split_flag END ord_number,       
	(SELECT ord_priority FROM orderheader WHERE ord_hdrnumber = leg.ord_hdrnumber) AS OrderPriority,      
	lgh_startdate 'StartDate',      
	lgh_enddate 'EndDate',      
	leg.lgh_outstatus 'DispStatus',      
	leg.lgh_instatus 'InStatus',      
	ord_bookedby 'BookedBy',      
	lgh_tm_status 'TotalMailStatus',      
	ord_billto 'BillTo',      
	ord_company 'OrderBy',      
	ord_totalmiles 'Mileage',      
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
	ord_totalvolume AS 'TotalVol',      
	lgh_tractor AS 'Tractor', 
	lgh_driver1 AS 'Driver1',
	lgh_driver2 AS 'Driver2', 
	ds_driver3 AS 'Driver3', 
	lgh_primary_trailer AS 'Trailer', 
	lgh_primary_pup AS 'Trailer2',      
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
	tractorprofile.trc_company 'Company',      
	tractorprofile.trc_terminal 'Terminal',      
	tractorprofile.trc_division 'Division',      
	tractorprofile.trc_fleet 'Fleet',       
	manpowerprofile.mpp_TeamLeader 'TeamLeader',       
	manpowerprofile.mpp_domicile 'Domicile',       
	manpowerprofile.mpp_type1 'DrvType1',      
	manpowerprofile.mpp_type2 'DrvType2',      
	manpowerprofile.mpp_type3 'DrvType3',      
	manpowerprofile.mpp_type4 'DrvType4',      
	manpowerprofile.mpp_qualificationlist,      
	tractorprofile.trc_type1 'TrcType1',      
	tractorprofile.trc_type2 'TrcType2',      
	tractorprofile.trc_type3 'TrcType3',      
	tractorprofile.trc_type4 'TrcType4',      
	tractorprofile.trc_accessorylist,      
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
	leg.lgh_etaalert1   
FROM legheader_active AS leg 
	LEFT OUTER JOIN city AS ccity ON l_ctyname = ccity.cty_nmstct      
	LEFT OUTER JOIN company AS ccompany ON l_cmpid = ccompany.cmp_id      
	JOIN company AS endcompany ON endcompany.cmp_id  = cmp_id_end      
	JOIN city AS endcity ON endcity.cty_code = lgh_endcity      
	JOIN stops ON stp_number = stp_number_end      
	JOIN manpowerprofile ON mpp_id = lgh_driver1
	JOIN tractorprofile ON trc_number = lgh_tractor      
	JOIN trailerprofile ON trailerprofile.trl_id = lgh_primary_trailer      
	JOIN carrier ON carrier.car_id = lgh_carrier     
	LEFT OUTER JOIN stops AS dstop ON next_drp_stp_number = dstop.stp_number      
	LEFT OUTER JOIN company AS dcompany ON dstop.cmp_id = dcompany.cmp_id 
	JOIN labelfile on abbr = lgh_outstatus and labeldefinition = 'DispStatus' and code >= 220
	LEFT OUTER JOIN driverseating ON (leg.lgh_tractor = ds_trc_id and leg.lgh_driver1 = ds_driver1 and leg.lgh_driver2 = ds_driver2
									  AND (ds_seated_dt <= leg.lgh_startdate AND ds_unseated_dt >= leg.lgh_startdate))
GO
GRANT SELECT ON  [dbo].[OperationsInboundViewWithDriverSeating] TO [public]
GO
