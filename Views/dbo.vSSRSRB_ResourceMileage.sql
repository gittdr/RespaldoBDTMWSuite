SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE view [dbo].[vSSRSRB_ResourceMileage]

AS 
/**
 *
 * NAME:
 * dbo.[vSSRSRB_ResourceMileage]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Mileage by resource
 
 *
**************************************************************************

Sample call


select * from [vSSRSRB_ResourceMileage]


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Mileage by resource
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR edited SSRS view version
 **/

SELECT
	Case When [Segment Total Miles] = 0 or [Segment Total Miles] Is Null 
		Then 0
	Else Convert(float,(IsNull([Segment Empty Miles],0)/convert(float,[Segment Total Miles])))
	End as [Percent Empty],
	TmpLghInfo.*
FROM
	(
	SELECT 
		lgh_outstatus as 'DispatchStatus',	             		
		lgh_driver1 as 'Driver_ID',
		mpp.mpp_lastfirst as 'Driver Name', 
		lgh.mpp_type1 'DrvType1', 
		lgh.mpp_type2 'DrvType2', 
		lgh.mpp_type3 'DrvType3', 
		lgh.mpp_type4 'DrvType4', 
		lgh.lgh_tractor as 'Tractor ID',
		lgh.trc_type1 'TrcType1',
		lgh.trc_type1 'TrcType2',
		lgh.trc_type1 'TrcType3',
		lgh.trc_type1 'TrcType4',			
		lgh.lgh_carrier as 'Carrier ID',
		car.car_name as 'Carrier_Name',
		lgh.mpp_fleet 'Fleet', 
		lgh_number	'Leg Header Number',
		lgh.mov_number 	'Move Number',      
		lgh.ord_hdrnumber as 'Order Header Number',			
		lgh_class1 as 'RevType1',
		lgh_class2 as 'RevType2',
		lgh_class3	'RevType3',
		lgh_class4	'RevType4',		
		lgh_startDate as 'Segment_Start_Date',	  
		(Cast(Floor(Cast(lgh_startDate as float))as smalldatetime)) AS 'Segment Start Date Only',
		lgh_EndDate as 'Segment End Date',	
		(Cast(Floor(Cast(lgh_EndDate as float))as smalldatetime)) AS 'Segment End Date Only',
		'Segment Empty Miles' = IsNull((select sum(stp_lgh_mileage) from stops WITH (NOLOCK) where stops.lgh_number = lgh.lgh_number and stp_loadstatus <> 'LD'),0),
		'Segment Loaded Miles' = IsNull((select sum(stp_lgh_mileage) from stops WITH (NOLOCK) where stops.lgh_number = lgh.lgh_number and stp_loadstatus = 'LD'),0),
		'Segment Total Miles' = IsNull((select sum(stp_lgh_mileage) from stops WITH (NOLOCK) where stops.lgh_number = lgh.lgh_number),0)
	FROM legheader lgh WITH (NOLOCK)
		INNER JOIN manpowerprofile mpp WITH (NOLOCK) on mpp.mpp_id = lgh.lgh_driver1 
		INNER JOIN tractorprofile trc WITH (NOLOCK) on trc.trc_number = lgh.lgh_tractor 
		INNER JOIN carrier car WITH (NOLOCK) on car.car_id = lgh.lgh_carrier
	) as TmpLghInfo		
		


GO
GRANT SELECT ON  [dbo].[vSSRSRB_ResourceMileage] TO [public]
GO
