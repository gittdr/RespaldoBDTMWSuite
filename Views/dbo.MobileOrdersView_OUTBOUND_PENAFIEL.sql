SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE view [dbo].[MobileOrdersView_OUTBOUND_PENAFIEL]
AS

/*******************************************************************************************************************  
SELECT * FROM MobileOrdersView_PENAFIEL
*******************************************************************************************************************/

WITH GI AS 
(
  SELECT TOP 1 
          COALESCE(gi_string1, 'PUPDRP') Setting
    FROM  generalinfo WITH(NOLOCK)
   WHERE  gi_name = 'PlnWrkshtLateWarnMode'
),
DIFFS AS
(
  SELECT  MIN(CASE WHEN stp_arrivaldate > GETDATE() AND stp_type = 'PUP' THEN DATEDIFF(minute, GETDATE(), stp_arrivaldate) ELSE 3000000 END) PUPDiff,
          MIN(CASE WHEN stp_departuredate > GETDATE() AND stp_type = 'DRP' THEN DATEDIFF(minute, GETDATE(), stp_departuredate) ELSE 3000000 END) DRPDiff,
          MIN(CASE WHEN stp_arrivaldate > GETDATE() THEN DATEDIFF(minute, GETDATE(), stp_arrivaldate) ELSE 3000000 END) ArrivalDiff,
          MIN(CASE WHEN stp_departuredate > GETDATE()THEN DATEDIFF(minute, GETDATE(), stp_departuredate) ELSE 3000000 END) DepartureDiff,
          MIN(CASE WHEN stp_schdtearliest > GETDATE() THEN DATEDIFF(minute, GETDATE(), stp_schdtearliest) ELSE 3000000 END) EarliestDiff,
          MIN(CASE WHEN stp_schdtlatest > GETDATE() THEN DATEDIFF(minute, GETDATE(), stp_schdtlatest) ELSE 3000000 END) LatestDiff,
          ord_hdrnumber
    FROM  stops WITH(NOLOCK)
  GROUP BY ord_hdrnumber
),
PlnWrkshtLateWarnMode AS
(
   SELECT  CASE 
            WHEN Setting = 'PUPDRP' AND PUPDiff < DRPDiff THEN PUPDiff 
            WHEN Setting = 'PUPDRP' THEN DRPDiff 
            WHEN Setting = 'EVENT' AND ArrivalDiff < DepartureDiff THEN ArrivalDiff
            WHEN Setting = 'EVENT' THEN DepartureDiff 
            WHEN Setting = 'ARRIVALDEPARTURE' AND ArrivalDiff < DepartureDiff AND ArrivalDiff < EarliestDiff AND ArrivalDiff < LatestDiff THEN ArrivalDiff
            WHEN Setting = 'ARRIVALDEPARTURE' AND DepartureDiff < ArrivalDiff AND DepartureDiff < EarliestDiff AND DepartureDiff < LatestDiff THEN DepartureDiff
            WHEN Setting = 'ARRIVALDEPARTURE' AND EarliestDiff < ArrivalDiff AND EarliestDiff < DepartureDiff AND EarliestDiff < LatestDiff THEN EarliestDiff
            WHEN Setting = 'ARRIVALDEPARTURE' AND LatestDiff < ArrivalDiff AND LatestDiff < EarliestDiff AND LatestDiff < EarliestDiff THEN LatestDiff
            ELSE 3000000
          END MinutesAway
          , OH.ord_hdrnumber
    FROM  orderheader OH WITH(NOLOCK)
            INNER JOIN GI ON 1=1
            INNER JOIN DIFFS ON DIFFS.ord_hdrnumber = OH.ord_hdrnumber
)
SELECT  DISTINCT 'TMWWF_MOBILE_ORDERS' as 'TMWWF_MOBILE_ORDERS',
		ord.ord_number,
		ord.ord_hdrnumber,
		LTRIM(ord.ord_billto) 'BillToID',
		LTRIM(RTRIM(B.cmp_name)) 'BillTo', 
		LTRIM(scompany.cmp_id) 'ShipperID',
		LTRIM(RTRIM(scompany.cmp_name)) 'ShipperName',
		LTRIM(scity.cty_name) 'ShipperCity',
		LTRIM(RTRIM(scity.cty_state)) 'ShipperState',
		LTRIM(ccompany.cmp_id) 'ConsigneeID',
		LTRIM(RTRIM(ccompany.cmp_name)) 'ConsigneeName',
		LTRIM(ccity.cty_name) 'ConsigneeCity',
		LTRIM(RTRIM(ccity.cty_state)) 'ConsigneeState',
		ord.ord_startdate 'StartDate', 
		ord.ord_completiondate 'EndDate',
		LTRIM(RTRIM(ord.ord_status)) 'Status',
		ord.ord_totalmiles 'Distance',
		ord.ord_totalmiles - COALESCE(mileage.MileageProgress, 0) 'DistanceRemaining',
	    FechaGPS =  cast(trc_gps_date as varchar(120)),
		Ubicacion =  trc_gps_desc,

		MinutesAway.MinutesAway 'MinutesAway',
		CASE 
			WHEN ord.ord_status = 'CMP' THEN 'Complete'
			WHEN ord.ord_status ='AVL' THEN 'Unplanned'
			WHEN MinutesAway.MinutesAway >= 120 THEN 'Late'
			WHEN (MinutesAway.MinutesAway > 0 AND MinutesAway.MinutesAway < 120) THEN 'At Risk'
			ELSE 'On Time'
		END 'OnTimeStatus'	
		, COALESCE(A.CarrierId,'UNKNOWN') 'CarrierId'
		, RTRIM(LTRIM(COALESCE(car.car_name,'UNKNOWN'))) 'CarrierName' 
		, COALESCE(A.DriverId,'UNKNOWN') 'DriverId'
		, RTRIM(LTRIM(COALESCE(M.mpp_firstname,'UNKNOWN'))) 'DriverFirstName'
		, RTRIM(LTRIM(COALESCE(M.mpp_lastname,'UNKNOWN'))) 'DriverLastName'
		, COALESCE(A.TractorId,'UNKNOWN') 'TractorId'
		, COALESCE(A.TrailerId,'UNKNOWN') 'TrailerId'
		
		
from	orderheader ord WITH(NOLOCK)
		INNER JOIN city as scity WITH(NOLOCK) on ord.ord_origincity = scity.cty_code
		INNER JOIN company as scompany WITH(NOLOCK) on ord.ord_originpoint = scompany.cmp_id
		INNER JOIN city as ccity WITH(NOLOCK) on ord.ord_destcity = ccity.cty_code
		INNER JOIN company as ccompany WITH(NOLOCK) on ord_destpoint = ccompany.cmp_id
		INNER JOIN tractorprofile  WITH(NOLOCK) on ord_tractor = tractorprofile.trc_number
		INNER JOIN PlnWrkshtLateWarnMode as MinutesAway WITH(NOLOCK) ON MinutesAway.ord_hdrnumber = ord.ord_hdrnumber
		LEFT OUTER JOIN company B WITH(NOLOCK) ON ord.ord_billto = B.cmp_id
		LEFT OUTER JOIN (select s.ord_hdrnumber, SUM(s.stp_ord_mileage) 'MileageProgress' from stops s WITH(NOLOCK) where s.stp_departure_status = 'DNE' and s.stp_ord_mileage > 0 group by s.ord_hdrnumber) as mileage on mileage.ord_hdrnumber = ord.ord_hdrnumber
		LEFT OUTER JOIN
		(
		SELECT  O.ord_hdrnumber
				, DriverId = MAX(CASE WHEN A.asgn_type = 'DRV' THEN A.asgn_id ELSE NULL END)
				, CarrierId = MAX(CASE WHEN A.asgn_type = 'CAR' THEN A.asgn_id ELSE NULL END)
				, TractorId = MAX(CASE WHEN A.asgn_type = 'TRC' THEN A.asgn_id ELSE NULL END)
				, TrailerId = MAX(CASE WHEN A.asgn_type = 'TRL' THEN A.asgn_id ELSE NULL END)
		FROM	assetassignment A WITH(NOLOCK) INNER JOIN
				legheader L WITH(NOLOCK) ON A.lgh_number = L.lgh_number INNER JOIN
				orderheader O WITH(NOLOCK) on L.mov_number = O.mov_number
		GROUP BY O.ord_hdrnumber
		) A ON ord.ord_hdrnumber = A.ord_hdrnumber
		LEFT OUTER JOIN manpowerprofile M WITH(NOLOCK) ON A.DriverId = M.mpp_id
		LEFT OUTER JOIN carrier car WITH(NOLOCK) ON A.CarrierId = car.car_id	

WHERE	ord.ord_status not in ( 'CAN', 'PND', 'ICO', 'MST','CMP')
AND ord.ord_hdrnumber in (SELECT ord_hdrnumber FROM legheader WHERE lgh_outstatus in ('AVL','PLN','STD')) 
--AND lgh_startregion1 in ('MX','PB'))
AND ord.ord_revtype3 = 'PEÑ'
--AND ord.ord_revtype4 = 'INT'


GO
