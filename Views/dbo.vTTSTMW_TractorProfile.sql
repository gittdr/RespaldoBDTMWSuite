SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
















--select * from vTTSTMW_TractorProfile

CREATE                View [dbo].[vTTSTMW_TractorProfile]

As

--Revision History
--1. Added Driver Types and Driver First Last Name,Driver Terminal Field For Driver 1
     --Ver 5.2 LBK

Select TempTractor.*,
       LastDriverCarrierOnTrip = (select Min(asgn_id) from assetassignment (NOLOCK) where asgn_type = 'DRV' and asgn_type = 'CAR' and lgh_number =  (select lgh_number from assetassignment (NOLOCK) where asgn_number = MaxAssignmentNumber))
	

From

(

SELECT     trc_number AS 'Tractor', 
	   'MaxAssignmentNumber'=
	   (select 
		Max(asgn_number) 
	from assetassignment a
	where 
		trc_number=asgn_id
		AND
		asgn_type In ('TRC')
		and 
                (asgn_status = 'STD' or asgn_status='CMP')
	        and
		asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b 
		where
     			(b.asgn_type In ('TRC')
			and
                	(asgn_status = 'STD' or asgn_status='CMP') 
			and
			a.asgn_id = b.asgn_id))),
	   Case When trc_retiredate > GetDate() or trc_retiredate Is Null Then
		'Y'
	   Else
	        'N'
	   End as 'ActiveYN',
	   trc_owner as 'Owner', 
           trc_make as 'Make', 
	   trc_model as 'Model', 
           trc_currenthub as 'Current Hub',
           trc_type1 AS 'TrcType1',
	   'TrcType1 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = trc_type1 and labeldefinition = 'TrcType1'),''),
	   trc_type2 AS 'TrcType2',
	   'TrcType2 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = trc_type2 and labeldefinition = 'TrcType2'),''),
	   trc_type3 as 'TrcType3',
           'TrcType3 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = trc_type3 and labeldefinition = 'TrcType3'),''),
           trc_type4 as 'TrcType4',
           'TrcType4 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = trc_type4 and labeldefinition = 'TrcType4'),''),
	   trc_year as 'Year', 
           trc_startdate as 'Start Date', 
           trc_retiredate as 'Retire Date', 
           trc_mpg as 'Miles Per Gallon', 
	   trc_fleet as 'Fleet', 
	   trc_division as 'Division', 
	   trc_company as 'Company', 
	   trc_terminal as 'Terminal', 
	   trc_dateacquired as 'Date Acquired', 
	   trc_origmileage as 'Original Mileage', 
	   trc_enginehrs as 'Engine Hours', 
	   trc_enginemake as 'Engine Make', 
	   trc_enginemodel as 'Engine Model',
	   trc_engineserial as 'Engine Serial', 
	   trc_serial as 'Serial', 
	   trc_licstate as 'License State', 
	   trc_licnum as 'License Number', 
	   trc_origcost as 'Original Cost', 
	   trc_opercostpermi as 'Operation Cost Per Mile', 
	   trc_grosswgt as 'Gross Weight', 
	   trc_axles as 'Axles', 
	   trc_warrantydays as 'Warranty Days', 
	   trc_commethod as 'Commethod', 
           trc_status as 'Tractor Status', 
	   trc_avl_date as 'Available Date', 
	   trc_avl_cmp_id as 'Available Company ID', 
	   (select cty_name from city (NOLOCK) where cty_code = trc_avl_city) as 'Available City',
	   trc_avl_status as 'Available Status', 
	   trc_pln_date as 'Planned Date', 
	   trc_pln_cmp_id as 'Planned Company ID', 
	   (select cty_name from city (NOLOCK) where cty_code = trc_pln_city) as 'Planned City',
	   trc_pln_lgh as 'Planned Legheader', 
	   trc_avl_lgh as 'Available Legheader', 
           trc_cur_mileage as 'Current Mileage', 
           trc_driver as 'Driver ID', 
	   (select mpp_lastfirst from manpowerprofile where trc_driver = mpp_id) as 'Driver Name', 
           'Driver Terminal' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_terminal and mpp_id = trc_driver and labeldefinition = 'Terminal'),''),
	   (select mpp_terminal from manpowerprofile where trc_driver = mpp_id) as 'Driver Terminal ID', 
	    'DrvType1 Name' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type1 and mpp_id = trc_driver and labeldefinition = 'DrvType1'),''),
	   (select mpp_type1 from manpowerprofile where trc_driver = mpp_id) as 'DrvType1', 
           'DrvType2 Name' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type2 and mpp_id = trc_driver and labeldefinition = 'DrvType2'),''),
	   (select mpp_type2 from manpowerprofile where trc_driver = mpp_id) as 'DrvType2', 
           'DrvType3 Name' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type3 and mpp_id = trc_driver and labeldefinition = 'DrvType3'),''),
	   (select mpp_type3 from manpowerprofile where trc_driver = mpp_id) as 'DrvType3', 
	   'DrvType4 Name' = IsNull((select name from labelfile (NOLOCK),manpowerprofile (NOLOCK) where labelfile.abbr = mpp_type4 and mpp_id = trc_driver and labeldefinition = 'DrvType4'),''),
           (select mpp_type4 from manpowerprofile where trc_driver = mpp_id) as 'DrvType4', 
	   trc_actg_type as 'Accounting Type', 
	   trc_driver2 as 'Driver2 ID', 
	   trc_misc1 as 'Misc1', 
	   trc_misc2 as 'Misc2', 
	   trc_misc3 as 'Misc3', 
	   trc_misc4 as 'Misc4', 
	   Left(trc_updatedby,255) as 'Updated By', 
           trc_turndown as 'Turn Down', 
           trc_phone as 'Phone Number', 
           trc_nextdestpref as 'Next Destination Preference', 
	   trc_mtcalltime as 'MT Call Time', 
	   trc_updatedon as 'Updated On', 
	   trc_tareweight as 'Tare Weight', 
	   trc_tareweight_uom as 'Tare Weight UOM', 
	   trc_bmpr_to_steer as 'BMPR To Steer', 
	   trc_bmpr_to_steer_uom as 'BMPR To Steer UOM',
           trc_steer_to_drive1 as 'Steer to Drive1', 
	   trc_steer_to_drive1_uom as 'Steer To Drive1 UOM', 
	   trc_drive1_to_drive2 as 'Drive1 To Drive2', 
           trc_drive1_to_drive2_uom as 'Drive1 To Drive2 UOM', 
           trc_drive2_to_rear as 'Drive2 To Rear', 
	   trc_drive2_to_rear_uom as 'Drive2 to Rear UOM', 
           trc_createdate as 'Created Date', 
	   trc_whltobase as 'Wheel To Base', 
	   trc_cabtoaxle as 'Cab To Axle', 
	   trc_bprtobkcab as 'BPR To BkCab', 
	   trc_frontaxlspc as 'Front Axle Spec', 
	   trc_rearaxlspc as 'Rear Axle Spec', 
	   trc_fifthwhltvl as 'Fifth Wheel Tvl', 
	   trc_dummy as 'Dummy', 
	   trc_ttltarewt as 'TTL Tare Weight', 
           trc_whltobase_uom as 'Wheel To Base UOM', 
	   trc_cabtoaxle_uom as 'Cab To Axle UOM', 
	   trc_bprtobkcab_uom as 'BPR To BkCab UOM', 
	   trc_rearaxlspc_uom as 'Rear Axle Spec UOM', 
	   trc_frontaxlspc_uom as 'Front Axle Spec UOM', 
	   trc_fifthwhltvl_uom as 'Fifth Wheel TVL UOM', 
	   trc_ttltarewt_uom as 'TTL Tare Weight UOM', 
           trc_fifthwheelht as 'Fifth Wheel Height', 
	   trc_fifthwheelht_uom as 'Fifth Wheel Height UOM',  
	   trc_quickentry as 'Quick Entry', 
	   --Deleted as of 5/6/2003 Ver 4.98 can be re added 2003 Ver
           --trc_gps_odometer as 'GPS Odometer', 
           trc_next_region4 as 'Next Region 4', 
	   trc_next_region2 as 'Next Region 2', 
	   trc_next_region1 as 'Next Region 1', 
	   trc_next_state as 'Next State', 
           (select cty_name from city (NOLOCK) where cty_code = trc_next_city) as 'Next City',
	   trc_next_cmp_id as 'Next Company ID', 
	   trc_next_event as 'Next Event', 
	   trc_prior_region4 as 'Prior Region 4', 
	   trc_prior_region3 as 'Prior Region 3', 
	   trc_prior_region2 as 'Prior Region 2', 
	   trc_prior_region1 as 'Prior Region 1', 
           trc_prior_state as 'Prior State', 
	   (select cty_name from city (NOLOCK) where cty_code = trc_prior_city) as 'Prior City',
	   trc_prior_cmp_id as 'Prior Company ID', 
	   trc_prior_event as 'Prior Event', 
	   trc_alert_date as 'Alert Date', 
	   trc_note_date as 'Note Date', 
	   trc_checkconflict as 'Check Conflict', 
	   trc_nextmainthub as 'Next Maintenance Hub',
	   trc_exp2_date as 'Exp2 Date', 
	   trc_exp1_date as 'Exp1 Date', 
	   trc_networks as 'Networks', 
           trc_gps_longitude as 'GPS Longitude', 
	   trc_gps_latitude as 'GPS Latitude', 
	   trc_gps_date as 'GPS Date', 
	   trc_gps_desc as 'GPS Desc', 
	   trc_trailer2 as 'Trailer 2', 
	   trc_trailer1 as 'Trailer 1', 
	   trc_tank_capacity as 'Tank Capacity', 
	   trc_gal_in_tank as 'Gallons In Tank', 
	   trc_thirdparty as 'Third Party', 
           trc_next_region3 as 'Next Region 3',
	    --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as Branch,
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --trc_branch as Branch,		
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	   
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [NewUsed],
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --trc_newused as [NewUsed],
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	 
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [Accessory List],
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --trc_accessorylist as [Accessory List],
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	 
	   --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [Conversion List],
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --trc_conversion_weight as [Conversion List],
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	 
           --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as [GP Class],
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --trc_gp_class as [GP Class],
	   --<TTS!*!TMW><End><FeaturePack=Euro>

	   [Company Name] = (select name from labelfile (NOLOCK) where abbr = trc_company and labeldefinition = 'Company'),
           [Division Name] = (select name from labelfile (NOLOCK) where abbr = trc_division and labeldefinition = 'Division'), 
           [Terminal Name] = (select name from labelfile (NOLOCK) where abbr = trc_terminal and labeldefinition = 'Terminal'),
           [Fleet Name] = (select name from labelfile (NOLOCK) where abbr = trc_fleet and labeldefinition = 'Fleet'),
	   1 as TractorCount




FROM       dbo.tractorprofile (NOLOCK) 


) as TempTractor















GO
GRANT SELECT ON  [dbo].[vTTSTMW_TractorProfile] TO [public]
GO
