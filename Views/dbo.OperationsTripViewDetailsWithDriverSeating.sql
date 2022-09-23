SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
CREATE view [dbo].[OperationsTripViewDetailsWithDriverSeating]
as     
select rtrim(oh.ord_number)+ case when isnull(legheader.lgh_split_flag,'N') = 'N' then '' else '-' + legheader.lgh_split_flag end as OrderNumber, 
	la.lgh_outstatus as DispStatus,     
	la.lgh_startdate as StartDate, ISNULL(fc.cmp_id, '') as OriginId, ISNULL(fc.cmp_name, '') as OriginName, fcy.cty_nmstct as OriginCity, fcy.cty_state as OriginState,     
	la.lgh_enddate as EndDate, ISNULL(lc.cmp_id, '') as FinalId, ISNULL(lc.cmp_name, '') as FinalName, lcy.cty_nmstct as FinalCity, lcy.cty_state as FinalState,     
	(select sum(stp_lgh_mileage) from stops where stops.lgh_number = la.lgh_number) as Mileage, la.ord_totalweight as Weight, oh.ord_totalcharge as Revenue,     
	la.ord_stopcount StopCount, la.lgh_driver1 as Driver1, la.evt_driver1_name Driver1Name, la.lgh_tractor as Tractor, la.lgh_primary_trailer as Trailer1,     
	la.lgh_carrier as Carrier, la.lgh_driver2 as Driver2, la.evt_driver2_name Driver2Name, 
	IsNull(ds_driver3, 'UNKNOWN') as Driver3, la.lgh_primary_pup as Trailer2, oh.trl_type1 TrailerType,     
	la.cmd_code as CmdCode, la.fgt_description as CmdDescription, la.cmd_count as CmdCount,    
	la.lgh_class1 as RevType1, la.lgh_class2 as RevType2, la.lgh_class3 as RevType3, la.lgh_class4 as RevType4,     
	ord_booked_revtype1 as BookingTerminal, la.lgh_booked_revtype1 as ExecutingTerminal, la.lgh_route RouteId,     
	la.lgh_number, la.lgh_tm_status as TotalMailStatus, la.lgh_instatus as InStatus,     
	oh.ord_bookedby as BookedBy, oh.ord_billto as BillTo, oh.ord_customer as OrderBy,     
	pc.cmp_id as PickupId, pc.cmp_name as PickupName, pc.cty_nmstct as PickupCity, pc.cmp_state as PickupState, pc.cmp_region1 as PickupRegion1, 
	pc.cmp_region2 as PickupRegion2, pc.cmp_region3 as PickupRegion3, pc.cmp_region4 as PickupRegion4,   
	cc.cmp_id as ConsigneeId, cc.cmp_name as ConsigneeName, cc.cty_nmstct as ConsigneeCity, cc.cmp_state as ConsigneeState, cc.cmp_region1 as ConsigneeRegion1, 
	cc.cmp_region2 as ConsigneeRegion2, cc.cmp_region3 as ConsigneeRegion3, cc.cmp_region4 as ConsigneeRegion4,     
	la.lgh_type1 as LghType1, la.lgh_type2 as LghType2, la.mpp_teamleader as TeamLeader,     
	oh.ord_status as OrderStatus, la.mov_number as mov_number, legheader.lgh_etaalert1 as EtaStatus, legheader.lgh_etacomment as EtaComment, oh.ord_priority as 'Priority'    
  from legheader_active la join legheader on legheader.lgh_number = la.lgh_number    
       left outer join orderheader oh on (la.ord_hdrnumber = oh.ord_hdrnumber)     
       left outer join company pc on (oh.ord_shipper = pc.cmp_id)    
	   left outer join company cc on (oh.ord_consignee = cc.cmp_id)    
       join company fc on (la.cmp_id_start = fc.cmp_id)    
       join city fcy on (la.lgh_startcity = fcy.cty_code)    
       join company lc on (la.cmp_id_end = lc.cmp_id)    
       join city lcy on (la.lgh_endcity = lcy.cty_code)
       LEFT OUTER JOIN driverseating ON (la.lgh_tractor = ds_trc_id and la.lgh_driver1 = ds_driver1 and la.lgh_driver2 = ds_driver2
				  AND (ds_seated_dt <= la.lgh_startdate AND ds_unseated_dt >= la.lgh_startdate))
   WHERE la.lgh_outstatus <> 'CMP'
GO
GRANT SELECT ON  [dbo].[OperationsTripViewDetailsWithDriverSeating] TO [public]
GO
