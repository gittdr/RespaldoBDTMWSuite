SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[MobileTripsView_NoOnTime]
AS

/*******************************************************************************************************************  
  Object Description:
  This view provides a trip summary which allows search capabilities

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  06/28/2017   Chase Plante     WE-208658   Split view into its own file and added minutes away calculations
  10/09/2017   Chase Plante     WE-211090   Modified view to trim any string data
*******************************************************************************************************************/


SELECT DISTINCT 'TMWWF_MOBILE_TRIPS' AS 'TMWWF_MOBILE_TRIPS',
		leg.lgh_number 'LegNumber',  
		leg.ord_hdrnumber 'OrderHeaderNumber',
		LTRIM(L.abbr) AS 'Edi204Status',
		leg.lgh_204date 'Edi204Date', 
		leg.lgh_startdate 'StartDate', 
		leg.lgh_enddate 'EndDate', 
		LTRIM(leg.lgh_outstatus) 'DispStatus',
		leg.lgh_miles 'Mileage',
		LTRIM(ord.ord_billto) 'BillTo',
		LTRIM(ord.ord_revtype1) 'RevType1',
		LTRIM(ord.ord_revtype2) 'RevType2',
		LTRIM(ord.ord_revtype3) 'RevType3',
		LTRIM(ord.ord_revtype4) 'RevType4',
		LTRIM(pickupcompany.cmp_region1) 'ShipperRegion1',
		LTRIM(pickupcompany.cmp_region2) 'ShipperRegion2',
		LTRIM(pickupcompany.cmp_region3) 'ShipperRegion3',
		LTRIM(pickupcompany.cmp_region4) 'ShipperRegion4',
		LTRIM(dropcompany.cmp_region1) 'ConsigneeRegion1',
		LTRIM(dropcompany.cmp_region2) 'ConsigneeRegion2',
		LTRIM(dropcompany.cmp_region3) 'ConsigneeRegion3',
		LTRIM(dropcompany.cmp_region4) 'ConsigneeRegion4',
		LTRIM(startcompany.cmp_id) 'PickupId',
		LTRIM(RTRIM(startcompany.cmp_name))  'PickupName',
		LTRIM(startcity.cty_name) 'PickupCity',
		LTRIM(RTRIM(startcity.cty_state)) 'PickupState',
		LTRIM(endcompany.cmp_id) 'ConsigneeId',
		LTRIM(RTRIM(endcompany.cmp_name)) 'ConsigneeName',
		LTRIM(endcity.cty_name) 'ConsigneeCity',
		LTRIM(RTRIM(endcity.cty_state)) 'ConsigneeState',	
		ord.ord_totalvolume 'TotalVol',
		ord.ord_totalweight 'TotalWeight',
		dbo.tmw_legstopslate_fn(leg.lgh_number) 'Late Stops',
		leg.lgh_miles 'TotalMiles',
		leg.lgh_miles - COALESCE(mileage.MileageProgress, 0) 'RemainingMiles'
		, 'N/A' 'OnTimeStatus'
		, COALESCE(RTRIM(LTRIM(leg.lgh_carrier)),'UNKNOWN') 'Carrier' 
		, COALESCE(RTRIM(LTRIM(car.car_name)),'UNKNOWN') 'CarrierName' 
		, COALESCE(leg.lgh_driver1,'UNKNOWN') 'DriverId'
		, COALESCE(RTRIM(LTRIM(M.mpp_firstname)),'UNKNOWN') 'DriverFirstName'
		, COALESCE(RTRIM(LTRIM(M.mpp_lastname)),'UNKNOWN') 'DriverLastName'
		, COALESCE(RTRIM(LTRIM(leg.lgh_tractor)),'UNKNOWN') 'TractorId'
		, COALESCE(RTRIM(LTRIM(leg.lgh_primary_trailer)),'UNKNOWN') 'TrailerId'
		, COALESCE(RTRIM(LTRIM(pickupcompany.cmp_BookingTerminal)),'UNKNOWN')	'ShipperAcctMngr'
		, COALESCE(RTRIM(LTRIM(dropcompany.cmp_BookingTerminal)),'UNKNOWN')	'ConsigneeAcctMngr'
		, COALESCE(m.mpp_teamleader, 'UNK')	'TeamLeader'
FROM	legheader_active leg WITH(NOLOCK)
		LEFT OUTER JOIN city AS startcity WITH(NOLOCK) ON lgh_startcty_nmstct = startcity.cty_nmstct
		LEFT OUTER JOIN orderheader ord WITH(NOLOCK) ON leg.ord_hdrnumber = ord.ord_hdrnumber
		LEFT OUTER JOIN company AS startcompany WITH(NOLOCK) ON cmp_id_start = startcompany.cmp_id
		LEFT OUTER JOIN company AS endcompany WITH(NOLOCK) ON endcompany.cmp_id  = leg.cmp_id_end
		LEFT OUTER JOIN company As pickupcompany WITH(NOLOCK) ON pickupcompany.cmp_id = ord.ord_shipper
		LEFT OUTER JOIN company As dropcompany WITH(NOLOCK) ON ord.ord_consignee = dropcompany.cmp_id 
		LEFT OUTER JOIN city AS endcity WITH(NOLOCK) ON leg.lgh_endcity = endcity.cty_code 
		LEFT OUTER JOIN  labelfile L WITH(NOLOCK)ON leg.lgh_204status = name and L.labeldefinition = 'Lgh204Status'
		LEFT OUTER JOIN (select s.lgh_number, SUM(s.stp_lgh_mileage) 'MileageProgress' from stops s WITH(NOLOCK) where s.stp_departure_status = 'DNE' and s.stp_lgh_mileage > 0 group by s.lgh_number) as mileage on mileage.lgh_number = leg.lgh_number
		LEFT OUTER JOIN manpowerprofile M WITH(NOLOCK) ON leg.lgh_driver1 = M.mpp_id
		LEFT OUTER JOIN carrier car WITH(NOLOCK) ON leg.lgh_carrier = car.car_id	
WHERE	(ord.ord_status NOT IN ( 'CAN', 'PND', 'ICO', 'MST') OR leg.ord_hdrnumber = 0)
GO
GRANT SELECT ON  [dbo].[MobileTripsView_NoOnTime] TO [public]
GO
