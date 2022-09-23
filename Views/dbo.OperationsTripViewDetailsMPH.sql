SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

    
CREATE view [dbo].[OperationsTripViewDetailsMPH]
as     
select rtrim(oh.ord_number)+ case when isnull(legheader.lgh_split_flag,'N') = 'N' then '' else '-' + legheader.lgh_split_flag end as OrderNumber, 
	la.lgh_outstatus as DispStatus, oh.ord_hdrnumber As OrderHeaderNumber,   
	la.lgh_startdate as StartDate, ISNULL(fc.cmp_id, '') as OriginId, ISNULL(fc.cmp_name, '') as OriginName, fcy.cty_nmstct as OriginCity, fcy.cty_state as OriginState, fcy.cty_zip as OriginZip,     
	la.lgh_enddate as EndDate, ISNULL(lc.cmp_id, '') as FinalId, ISNULL(lc.cmp_name, '') as FinalName, lcy.cty_nmstct as FinalCity, lcy.cty_state as FinalState, lcy.cty_zip As FinalZip,   
	(select sum(stp_lgh_mileage) from stops (nolock) where stops.lgh_number = la.lgh_number) as Mileage, la.ord_totalweight as Weight, oh.ord_totalcharge as Revenue,     
	la.ord_stopcount StopCount, la.lgh_driver1 as Driver1, la.evt_driver1_name Driver1Name, la.lgh_tractor as Tractor, la.lgh_primary_trailer as Trailer1,     
	la.lgh_carrier as Carrier, la.lgh_driver2 as Driver2, la.evt_driver2_name Driver2Name, la.lgh_primary_pup as Trailer2, oh.trl_type1 TrailerType,     
	la.cmd_code as CmdCode, la.fgt_description as CmdDescription, la.cmd_count as CmdCount,    
	la.lgh_class1 as RevType1, la.lgh_class1_name as RevType1Name, la.lgh_class2 as RevType2, la.lgh_class2_name as RevType2Name, la.lgh_class3 as RevType3, la.lgh_class3_name as RevType3Name, la.lgh_class4 as RevType4, la.lgh_class4_name as RevType4Name,
	ord_booked_revtype1 as BookingTerminal, la.lgh_booked_revtype1 as ExecutingTerminal, la.lgh_route RouteId,     
	la.lgh_number, la.lgh_tm_status as TotalMailStatus, la.lgh_tm_statusname as TotalMailStatusName, la.lgh_instatus as InStatus,     
	oh.ord_bookedby as BookedBy, oh.ord_billto as BillTo, oh.ord_customer as OrderBy, oh.ord_refnum as RefNum,     
	pc.cmp_id as PickupId, pc.cmp_name as PickupName, pc.cty_nmstct as PickupCity, pc.cmp_state as PickupState, pc.cmp_zip as PickupZip, pc.cmp_region1 as PickupRegion1, 
	pc.cmp_region2 as PickupRegion2, pc.cmp_region3 as PickupRegion3, pc.cmp_region4 as PickupRegion4,   
	cc.cmp_id as ConsigneeId, cc.cmp_name as ConsigneeName, cc.cty_nmstct as ConsigneeCity, cc.cmp_zip as ConsigneeZip, cc.cmp_state as ConsigneeState, cc.cmp_region1 as ConsigneeRegion1, 
	cc.cmp_region2 as ConsigneeRegion2, cc.cmp_region3 as ConsigneeRegion3, cc.cmp_region4 as ConsigneeRegion4,     
	la.lgh_type1 as LghType1, (select top 1 [name] from labelfile (nolock) where labeldefinition = 'LghType1' and abbr = la.lgh_type1) as LghType1Name, la.lgh_type2 as LghType2, (select top 1 [name] from labelfile (nolock) where labeldefinition = 'LghType2' and abbr = la.lgh_type2) as LghType2Name,
	la.mpp_teamleader as TeamLeader, (select top 1 [name] from labelfile(nolock) where labeldefinition = 'TeamLeader' and abbr = la.mpp_teamleader) As TeamLeaderName,     
	oh.ord_status as OrderStatus, (select top 1 [name] from labelfile (nolock) where labeldefinition = 'DispStatus' and abbr = oh.ord_status) as OrderStatusName, la.mov_number as mov_number, legheader.lgh_etaalert1 as EtaStatus, legheader.lgh_etacomment as EtaComment, oh.ord_priority as 'Priority',
	
	CASE  la.lgh_outstatus
		WHEN 'STD' THEN  tractorprofile.trc_gps_latitude
		ELSE 0 
	END AS GpsLatitude,
	
	CASE  la.lgh_outstatus
		WHEN 'STD' THEN tractorprofile.trc_gps_longitude
		ELSE 0 
	END AS GpsLongitude,
  
	CASE  la.lgh_outstatus
		WHEN 'STD' THEN  tractorprofile.trc_gps_date
		ELSE  '1/1/1950 00:00'
	END AS GpsLastUpdate ,
	
	CASE  la.lgh_outstatus
		WHEN 'STD' THEN  tractorprofile.trc_gps_desc
		ELSE  ''
	END AS GpsDesc ,
	
	CASE  la.lgh_outstatus
		WHEN 'STD' THEN  tractorprofile.trc_gps_date
		ELSE  ''
	END AS GpsDate 
	

  from legheader_active la join legheader (nolock) on legheader.lgh_number = la.lgh_number    
       left outer join orderheader oh (nolock) on (la.ord_hdrnumber = oh.ord_hdrnumber)     
       left outer join company pc (nolock) on (oh.ord_shipper = pc.cmp_id)    
	   left outer join company cc (nolock) on (oh.ord_consignee = cc.cmp_id)    
                           join company fc (nolock) on (la.cmp_id_start = fc.cmp_id)    
                           join city fcy (nolock) on (la.lgh_startcity = fcy.cty_code)    
                           join company lc (nolock) on (la.cmp_id_end = lc.cmp_id)    
                           join city lcy (nolock) on (la.lgh_endcity = lcy.cty_code)
						   join tractorprofile (nolock) on tractorprofile.trc_number = la.lgh_tractor
   WHERE la.lgh_outstatus <> 'CMP'


GO
GRANT SELECT ON  [dbo].[OperationsTripViewDetailsMPH] TO [public]
GO
