SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[SSRS_RB_OilFieldReadings] (@s_date datetime, @e_date datetime)

as

/**
 * 
 * NAME:
 * dbo.SSRS_RB_OilFieldReadings 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Basic Data For Oil Field Readings
   
 * SAMPLE CALL:
 * EXEC SSRS_RB_OilFieldReadings '2012-08-01', '2013-09-30'
 *
 * PARAMETERS:
 * 
 *
 * REVISION HISTORY:
 * 01/22/2014 - new SP -MREED
 *

*/	

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

SET @e_date = DATEADD(d,1,@e_date)

SELECT
	 run_ticket 
	,UPPER(cmp.cmp_name) as cmp_name
	,ord.ord_startdate
	,ofr.inv_tankID
	,tnk.TankTranslation
	,ofr.ofr_topgaugemeasurement
	,convert(int, ofr.ofr_topgaugemeasurement / 12) as top_feet
	,convert(int, ofr.ofr_topgaugemeasurement % 12)as top_inches
	,convert(int, (ofr.ofr_topgaugemeasurement  - convert(dec(12,2), (convert(int, ofr.ofr_topgaugemeasurement / 12) * 12) + (convert(int, ofr.ofr_topgaugemeasurement % 12)))) * 4)  as top_qtr_inches	
	,ofr.ofr_bottomgaugemeasurement
	,convert(int, ofr.ofr_bottomgaugemeasurement / 12) as bot_feet
	,convert(int, ofr.ofr_bottomgaugemeasurement % 12)as bot_inches
	,convert(int, (ofr.ofr_bottomgaugemeasurement  - convert(dec(12,2), (convert(int, ofr.ofr_bottomgaugemeasurement / 12) * 12) + (convert(int, ofr.ofr_bottomgaugemeasurement % 12)))) * 4)  as bot_qtr_inches		
	,inv_temperature
	,inv_observedtemperature
	,ofr.ofr_bottomtemp 
	,inv_gravity
	,ofr_apigravity
	,fgt.fgt_volume
	,fgt_volume2
	,ofr.inv_bsw
	,ofr.ofr_BSWHeight
	,ofr.inv_value
	,ofr.inv_seal_off
	,ofr.inv_seal_offdate
	,ofr.inv_seal_on
	,ofr.inv_seal_ondate
	,ofr.ofr_meterstart
	,ofr.ofr_meterend
	,UPPER(d_cmp.cmp_id) as unloading_point
	,lgh.lgh_tractor 
	,(mpp.mpp_firstname + ' ' + mpp.mpp_lastname)as mpp_lastfirst
	,ISNULL(lgh.lgh_odometerend, 0)lgh_odometerend
	,ISNULL(lgh.lgh_odometerstart, 0)lgh_odometerstart

FROM oilfieldreadings ofr with (nolock)
	INNER JOIN company cmp with (nolock) ON ofr.cmp_id = cmp.cmp_id
	INNER JOIN orderheader ord with (nolock) ON ofr.ord_hdrnumber = ord.ord_hdrnumber
	INNER JOIN company d_cmp with (nolock) ON d_cmp.cmp_id = ord.ord_destpoint
	INNER JOIN Company_TankDetail tnk ON tnk.cmp_id = ofr.cmp_id AND tnk.cmp_tank_id = ofr.inv_tankid
	LEFT JOIN freightdetail fgt with (nolock) ON fgt.fgt_number = ofr.fgt_number
	LEFT JOIN (SELECT lgh_driver1, lgh_tractor, s.stp_number, l.lgh_odometerstart, l.lgh_odometerend FROM stops s with (nolock)
				INNER JOIN legheader l with (nolock) on s.lgh_number = l.lgh_number) as lgh ON lgh.stp_number = fgt.stp_number  
	LEFT JOIN manpowerprofile mpp with (nolock) ON mpp.mpp_id = lgh.lgh_driver1
WHERE ord.ord_startdate >= @s_date AND ord.ord_startdate < @e_date	

GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_OilFieldReadings] TO [public]
GO
