SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/*
select * from [dbo].[OperationsTripViewDetails_TDR]
select * from [dbo].[OperationsTripViewStops_dispo]
*/

    
--71330,66418 
CREATE view [dbo].[OperationsTripViewDetails_TDR]
as     

select a.OrderNumber, 
	a.DispStatus, a.OrderHeaderNumber,   
	a.StartDate, ISNULL(fc.cmp_id, '') as OriginId, ISNULL(fc.cmp_name, '') as OriginName, fcy.cty_nmstct as OriginCity, fcy.cty_state as OriginState, fcy.cty_zip as OriginZip,     
	a.EndDate, ISNULL(lc.cmp_id, '') as FinalId, ISNULL(lc.cmp_name, '') as FinalName, lcy.cty_nmstct as FinalCity, lcy.cty_state as FinalState, lcy.cty_zip As FinalZip,   
	(select sum(stp_lgh_mileage) from stops (nolock) where stops.lgh_number = a.lgh_number) as Mileage, a.Weight, a.Revenue,     
	a.StopCount, a.Driver1, a.Driver1Name, a.Tractor, a.Trailer1,     
	a.Carrier, a.Driver2, a.Driver2Name, a.Trailer2, a.TrailerType,     
	a.CmdCode, a.CmdDescription, a.CmdCount,    
	a.RevType1, a.RevType1Name, a.RevType2, a.RevType2Name, a.RevType3, a.RevType3Name, a.RevType4, a.RevType4Name,
	a.BookingTerminal, a.ExecutingTerminal, a.RouteId,     
	a.lgh_number, a.TotalMailStatus, a.TotalMailStatusName, a.InStatus,     
	a.BookedBy, a.BillTo, a.OrderBy, a.RefNum,     
	pc.cmp_id as PickupId, pc.cmp_name as PickupName, pc.cty_nmstct as PickupCity, pc.cmp_state as PickupState, pc.cmp_zip as PickupZip,
	
	 pc.cmp_region1 as PickupRegion1, 
	pc.cmp_region2 as PickupRegion2, pc.cmp_region3 as PickupRegion3, pc.cmp_region4 as PickupRegion4,   
	cc.cmp_id as ConsigneeId, cc.cmp_name as ConsigneeName, cc.cty_nmstct as ConsigneeCity, cc.cmp_zip as ConsigneeZip, cc.cmp_state as ConsigneeState, cc.cmp_region1 as ConsigneeRegion1, 
	cc.cmp_region2 as ConsigneeRegion2, cc.cmp_region3 as ConsigneeRegion3, cc.cmp_region4 as ConsigneeRegion4,
	a.LghType1, 
	(select top 1 [name] from labelfile (nolock) where labeldefinition = 'LghType1' and abbr = a.LghType1) as LghType1Name, 
	a.LghType2, (select top 1 [name] from labelfile (nolock) where labeldefinition = 'LghType2' and abbr = a.lghtype2) as LghType2Name,
	a.TeamLeader, (select top 1 [name] from labelfile(nolock) where labeldefinition = 'TeamLeader' and abbr = a.TeamLeader) As TeamLeaderName,     
	a.OrderStatus, (select top 1 [name] from labelfile (nolock) where labeldefinition = 'DispStatus' and abbr = a.OrderStatus) as OrderStatusName, 
	a.mov_number, a.EtaStatus, a.EtaComment, a.[Priority],
     a.lgh_comment,
     a.lgh_trc_comment,
	(select dbo.GetMinutesAway(a.mov_number)) As MinutesAway,
	ord_totalcharge,
	ord_totalmiles
from	(
			select rtrim(oh.ord_number)+ case when isnull(legheader.lgh_split_flag,'N') = 'N' then '' else '-' + legheader.lgh_split_flag end as OrderNumber, 
				la.lgh_outstatus as DispStatus, oh.ord_hdrnumber As OrderHeaderNumber,   
				la.lgh_startdate as StartDate, 
				la.lgh_enddate as EndDate, 
				la.ord_totalweight as Weight, oh.ord_totalcharge as Revenue,     
				la.ord_stopcount StopCount, la.lgh_driver1 as Driver1, la.evt_driver1_name Driver1Name, la.lgh_tractor as Tractor, la.lgh_primary_trailer as Trailer1,     
				la.lgh_carrier as Carrier, la.lgh_driver2 as Driver2, la.evt_driver2_name Driver2Name, la.lgh_primary_pup as Trailer2, oh.trl_type1 TrailerType,     
				la.cmd_code as CmdCode, la.fgt_description as CmdDescription, la.cmd_count as CmdCount,    
				la.lgh_class1 as RevType1, la.lgh_class1_name as RevType1Name, la.lgh_class2 as RevType2, la.lgh_class2_name as RevType2Name, la.lgh_class3 as RevType3, la.lgh_class3_name as RevType3Name, la.lgh_class4 as RevType4, la.lgh_class4_name as RevType4Name,
				ord_booked_revtype1 as BookingTerminal, la.lgh_booked_revtype1 as ExecutingTerminal, la.lgh_route RouteId,     
				la.lgh_number, la.lgh_tm_status as TotalMailStatus, la.lgh_tm_statusname as TotalMailStatusName, la.lgh_instatus as InStatus,     
				oh.ord_bookedby as BookedBy, oh.ord_billto as BillTo,
				oh.ord_company as OrderBy, --- oh.ord_customer as OrderBy, ---> PTS# 66418
				oh.ord_refnum as RefNum,     
				la.lgh_type1 as LghType1, 
				la.lgh_type2 as LghType2, 
				la.mpp_teamleader as TeamLeader, 
				oh.ord_status as OrderStatus, 
				la.mov_number as mov_number, legheader.lgh_etaalert1 as EtaStatus, legheader.lgh_etacomment as EtaComment,
				oh.ord_priority as 'Priority', 
				oh.ord_shipper as ord_shipper,
				oh.ord_consignee as ord_consignee,
				la.cmp_id_start as cmp_id_start,
				la.lgh_startcity as lgh_startcity,
				la.cmp_id_end as cmp_id_end,
				la.lgh_endcity as lgh_endcity,
                la.lgh_comment as lgh_comment,
                la.lgh_trc_comment as lgh_trc_comment,
				oh.ord_totalcharge,
				oh.ord_totalmiles
			  from legheader_active la join legheader on legheader.lgh_number = la.lgh_number    
				   inner join  OrderHeaderRowRestrictedView oh on (la.ord_hdrnumber = oh.ord_hdrnumber)
			   WHERE la.lgh_outstatus <> 'CMP'

			union 

			select rtrim(oh.ord_number)+ case when isnull(legheader.lgh_split_flag,'N') = 'N' then '' else '-' + legheader.lgh_split_flag end as OrderNumber, 
				la.lgh_outstatus as DispStatus, oh.ord_hdrnumber As OrderHeaderNumber,   
				la.lgh_startdate as StartDate, 
				la.lgh_enddate as EndDate,   
				la.ord_totalweight as Weight, oh.ord_totalcharge as Revenue,     
				la.ord_stopcount StopCount, la.lgh_driver1 as Driver1, la.evt_driver1_name Driver1Name, la.lgh_tractor as Tractor, la.lgh_primary_trailer as Trailer1,     
				la.lgh_carrier as Carrier, la.lgh_driver2 as Driver2, la.evt_driver2_name Driver2Name, la.lgh_primary_pup as Trailer2, oh.trl_type1 TrailerType,     
				la.cmd_code as CmdCode, la.fgt_description as CmdDescription, la.cmd_count as CmdCount,    
				la.lgh_class1 as RevType1, la.lgh_class1_name as RevType1Name, la.lgh_class2 as RevType2, la.lgh_class2_name as RevType2Name, la.lgh_class3 as RevType3, la.lgh_class3_name as RevType3Name, la.lgh_class4 as RevType4, la.lgh_class4_name as RevType4Name,
				ord_booked_revtype1 as BookingTerminal, la.lgh_booked_revtype1 as ExecutingTerminal, la.lgh_route RouteId,     
				la.lgh_number, la.lgh_tm_status as TotalMailStatus, la.lgh_tm_statusname as TotalMailStatusName, la.lgh_instatus as InStatus,     
				oh.ord_bookedby as BookedBy, oh.ord_billto as BillTo,
				oh.ord_company as OrderBy, --- oh.ord_customer as OrderBy, ---> PTS# 66418
				oh.ord_refnum as RefNum,     
				la.lgh_type1 as LghType1, 
				la.lgh_type2 as LghType2, 
				la.mpp_teamleader as TeamLeader, 
				oh.ord_status as OrderStatus, 
				la.mov_number as mov_number, legheader.lgh_etaalert1 as EtaStatus,  legheader.lgh_etacomment as EtaComment,
				oh.ord_priority as 'Priority', 
				oh.ord_shipper as ord_shipper,
				oh.ord_consignee as ord_consignee,
				la.cmp_id_start as cmp_id_start,
				la.lgh_startcity as lgh_startcity,
				la.cmp_id_end as cmp_id_end,
				la.lgh_endcity as lgh_endcity,
				la.lgh_comment as lgh_comment,
                la.lgh_trc_comment as lgh_trc_comment,
				oh.ord_totalcharge,
				oh.ord_totalmiles
			  from legheader_active la join legheader on (legheader.lgh_number = la.lgh_number)
				   left outer join orderheader oh on (la.ord_hdrnumber = oh.ord_hdrnumber)     
			   WHERE	la.lgh_outstatus <> 'CMP'
						AND isnull(la.ord_hdrnumber, 0) = 0
						
		) a
		  -- left outer join company pc on (a.ord_shipper = pc.cmp_id)    
	  -- left outer join company cc on (a.ord_consignee = cc.cmp_id)   
		  left outer join company pc on (a.cmp_id_start = pc.cmp_id)    
	  left outer join company cc on (a.cmp_id_end = cc.cmp_id)    
	   join company fc on (a.cmp_id_start = fc.cmp_id)    
	   join city fcy on (a.lgh_startcity = fcy.cty_code)    
	   join company lc on (a.cmp_id_end = lc.cmp_id)    
	   join city lcy on (a.lgh_endcity = lcy.cty_code)
  






GO
