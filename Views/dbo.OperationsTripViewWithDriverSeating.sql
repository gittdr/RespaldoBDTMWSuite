SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[OperationsTripViewWithDriverSeating]
AS   
SELECT	oh.ord_number AS OrderNumber, 
		lgh_outstatus AS DispStatus,
		lgh_startdate AS StartDate, 
		ISNULL(fc.cmp_id, '') AS OriginId, 
		ISNULL(fc.cmp_name, '') AS OriginName, 
		fcy.cty_nmstct AS OriginCity, 
		fcy.cty_state AS OriginState,
		lgh_enddate AS EndDate, 
		ISNULL(lc.cmp_id, '') AS FinalId, 
		ISNULL(lc.cmp_name, '') AS FinalName, 
		lcy.cty_nmstct AS FinalCity, 
		lcy.cty_state AS FinalState,
		(SELECT SUM(stp_lgh_mileage) FROM stops WHERE stops.lgh_number = la.lgh_number) AS Mileage, 
		la.ord_totalweight AS [Weight], 
		oh.ord_totalcharge AS Revenue,
		la.ord_stopcount AS StopCount, 
		la.lgh_driver1 AS Driver1Id, 
		la.evt_driver1_name AS Driver1Name, 
		lgh_tractor AS Tractor, 
		la.lgh_primary_trailer AS Trailer,
		la.lgh_carrier AS Carrier, 
		la.lgh_driver2 AS Driver2Id, 
		la.evt_driver2_name Driver2Name, 
		la.lgh_primary_pup AS Trailer2, 
		oh.trl_type1 AS TrailerType,
		la.cmd_code AS CmdCode, 
		la.fgt_description AS CmdDescription, 
		la.cmd_count AS CmdCount,  
		la.lgh_class1 AS RevType1, 
		la.lgh_class2 AS RevType2, 
		la.lgh_class3 AS RevType3, 
		la.lgh_class4 AS RevType4,
		ord_booked_revtype1 AS BookingTerminal, 
		lgh_booked_revtype1 AS ExecutingTerminal, 
		la.lgh_route AS RouteId,   
		lgh_number, 
		lgh_tm_status AS TotalMailStatus, 
		lgh_instatus AS InStatus, 
		oh.ord_bookedby AS BookedBy, 
		oh.ord_billto AS BillTo, 
		oh.ord_customer AS OrderBy,   
		pc.cmp_id AS PickupId, 
		pc.cmp_name AS PickupName, 
		pc.cty_nmstct AS PickupCity, 
		pc.cmp_state AS PickupState, 
		pc.cmp_region1 AS PickupRegion1, 
		pc.cmp_region2 AS PickupRegion2, 
		pc.cmp_region3 AS PickupRegion3, 
		pc.cmp_region4 AS PickupRegion4,   
		cc.cmp_id AS ConsigneeId, 
		cc.cmp_name AS ConsigneeName, 
		cc.cty_nmstct AS ConsigneeCity, 
		cc.cmp_state AS ConsigneeState, 
		cc.cmp_region1 AS ConsigneeRegion1, 
		cc.cmp_region2 AS ConsigneeRegion2, 
		cc.cmp_region3 AS ConsigneeRegion3, 
		cc.cmp_region4 AS ConsigneeRegion4,   
		lgh_type1 AS LghType1, 
		lgh_type2 AS LghType2, 
		mpp_teamleader AS TeamLeader,   
		oh.ord_status AS OrderStatus, 
		la.mov_number AS MoveNumber,
		ISNULL(ds_driver3, 'UNKNOWN') AS Driver   
  FROM legheader_active la LEFT OUTER JOIN orderheader AS oh ON (la.ord_hdrnumber = oh.ord_hdrnumber)   
                           JOIN company AS pc ON (oh.ord_shipper = pc.cmp_id)  
                           JOIN company AS cc ON (oh.ord_consignee = cc.cmp_id)  
                           JOIN company AS fc ON (la.cmp_id_start = fc.cmp_id)  
                           JOIN city AS fcy ON (la.lgh_startcity = fcy.cty_code)  
                           JOIN company AS lc ON (la.cmp_id_end = lc.cmp_id)  
                           JOIN city AS lcy ON (la.lgh_endcity = lcy.cty_code)
                           LEFT OUTER JOIN driverseating ON (lgh_tractor = ds_trc_id  and la.lgh_driver1 = ds_driver1 and la.lgh_driver2 = ds_driver2
															AND (ds_seated_dt <= la.lgh_startdate AND ds_unseated_dt >= la.lgh_startdate))
GO
GRANT SELECT ON  [dbo].[OperationsTripViewWithDriverSeating] TO [public]
GO
