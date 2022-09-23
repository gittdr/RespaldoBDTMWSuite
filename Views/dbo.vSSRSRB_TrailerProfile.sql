SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vSSRSRB_TrailerProfile]

As
/**
 *
 * NAME:
 * dbo.[vSSRSRB_TrailerProfile]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Trailer profile data
 
 *
**************************************************************************

Sample call


select * from [vSSRSRB_TrailerProfile]

**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Trailer profile data
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR Edited SSRS view version
 **/


SELECT     trl_number as 'Trailer ID',
           Case When trl_retiredate > GetDate() or trl_retiredate Is Null Then
		'Y'
	   Else
	        'N'
	   End as 'ActiveYN',  
           trl_owner as 'Owner', 
           trl_make as 'Make', 
           trl_model as 'Model', 
           trl_currenthub as 'Current Hub', 
           trl_type1 as 'TrlType1', 
           'TrlType1 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = trl_type1 and labeldefinition = 'TrlType1'),''),
           trl_type2 as 'TrlType2', 
           'TrlType2 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = trl_type2 and labeldefinition = 'TrlType2'),''),
           trl_type3 as 'TrlType3', 
           'TrlType3 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = trl_type3 and labeldefinition = 'TrlType3'),''),
           trl_type4 as 'TrlType4', 
           'TrlType4 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = trl_type4 and labeldefinition = 'TrlType4'),''),       
           trl_year as 'Year', 
           trl_startdate as 'Start Date', 
           (Cast(Floor(Cast(trl_startdate as float))as smalldatetime)) AS [Start Date Only],
           trl_retiredate as 'Retire Date', 
           (Cast(Floor(Cast( trl_retiredate as float))as smalldatetime)) AS [Retire Date Only],
           trl_mpg as 'Miles Per Gallon', 
           trl_company as 'Trailer Company', 
           'Trailer Company Name' = IsNull((select min(name) from labelfile WITH (NOLOCK) where labelfile.abbr = trl_company and labeldefinition = 'Company'),''), 
	   trl_fleet as 'Trailer Fleet',
	   'Trailer Fleet Name' = IsNull((select min(name) from labelfile WITH (NOLOCK) where labelfile.abbr = trl_fleet and labeldefinition = 'Fleet'),''), 
           trl_division as 'Trailer Division', 
           'Trailer Division Name' = IsNull((select min(name) from labelfile WITH (NOLOCK) where labelfile.abbr = trl_division and labeldefinition = 'Division'),''),
	   trl_terminal as 'Trailer Terminal', 
           'Trailer Terminal Name' = IsNull((select min(name) from labelfile WITH (NOLOCK) where labelfile.abbr = trl_terminal and labeldefinition = 'Terminal'),''),
	   cmp_id as 'Company ID', 
           (select cty_name from city WITH (NOLOCK) where city.cty_code = trailerprofile.cty_code) as 'City',
           trl_ilt as 'Ilt', 
           trl_mtwgt as 'MT Weight', 
	   trl_grosswgt as 'Gross Weight', 
           trl_axles as 'Axles', 
           trl_ht as 'Trailer Height',
           trl_len as 'Trailer Length', 
           trl_wdth as 'Trailer Width', 
           trl_licstate as 'License State', 
           trl_licnum as 'License Number', 
	   trl_status as 'Trailer Status', 
           trl_serial as 'Serial', 
           trl_dateacquired as 'Date Acquired', 
           (Cast(Floor(Cast(trl_dateacquired as float))as smalldatetime)) AS [Date Acquired Date Only],
           trl_origcost as 'Original Cost', 
           trl_opercostmile as 'Operation Cost Per Mile', 
           trl_sch_date as 'Scheduled Date', 
           (Cast(Floor(Cast(trl_sch_date  as float))as smalldatetime)) AS [Scheduled Date Only],
           trl_sch_cmp_id as 'Scheduled Company ID', 
           IsNull((select cty_name from city WITH (NOLOCK) where cty_code = trl_sch_city),'') as 'Scheduled City',
           trl_sch_status as 'Scheduled Status', 
           trl_avail_date as 'Available Date',
           (Cast(Floor(Cast(trl_avail_date as float))as smalldatetime)) AS [Available Date Only],
           trl_avail_cmp_id as 'Available Company ID', 
           IsNull((select cty_name from city WITH (NOLOCK) where cty_code = trl_avail_city),'') as 'Available City',
           trl_fix_record as 'Fix Record', 
           trl_last_stop as 'Last Stop', 
           trl_misc1 as 'Misc1', 
           trl_misc2 as 'Misc2', 
           trl_misc3 as 'Misc3', 
           trl_misc4 as 'Misc4',  
           trl_id as 'Trailer', 
           trl_cur_mileage as 'Current Mileage', 
           trl_bmp_pathname as 'BMP PathName',
           trl_actg_type as 'Accounting Type', 
           trl_ilt_scac as 'Ilt Scac',
           cast(trl_updatedby as varchar(255)) as 'Updated By', 
           trl_updateon as 'Updated On', 
           (Cast(Floor(Cast(trl_updateon as float))as smalldatetime)) AS [Updated On Date Only],
           trl_tareweight as 'Tare Weight', 
           trl_kp_to_axle1 as 'Kp To Axle1', 
           trl_axle1_to_axle2 as 'Axle1 To Axle2', 
           trl_axle2_to_axle3 as 'Axle2 To Axle3', 
           trl_axle3_to_axle4 as 'Axle3 To Axle4', 
           trl_comprt1_size_wet as 'Compartment1 Size Wet', 
           trl_comprt2_size_wet as 'Compartment2 Size Wet', 
           trl_comprt3_size_wet as 'Compartment3 Size Wet',  
           trl_comprt4_size_wet as 'Compartment4 Size Wet', 
           trl_comprt5_size_wet as 'Compartment5 Size Wet', 
           trl_comprt6_size_wet as 'Compartment6 Size Wet', 
           trl_comprt1_uom_wet as 'Compartment1 Uom Wet', 
           trl_comprt2_uom_wet as 'Compartment2 Uom Wet', 
           trl_comprt3_uom_wet as 'Compartment3 Uom Wet',  
           trl_comprt4_uom_wet as 'Compartment4 Uom Wet',  
           trl_comprt5_uom_wet as 'Compartment5 Uom Wet',  
           trl_comprt6_uom_wet as 'Compartment6 Uom Wet', 
           trl_comprt1_bulkhead as 'Compartment1 Bulkhead',  
           trl_comprt2_bulkhead as 'Compartment2 Bulkhead', 
           trl_comprt3_bulkhead as 'Compartment3 Bulkhead',
           trl_comprt4_bulkhead as 'Compartment4 Bulkhead', 
           trl_comprt5_bulkhead as 'Compartment5 Bulkhead',
           trl_tareweight_uom as 'Tareweight Uom',
           trl_kp_to_axle1_uom as 'Kp To Axle1 Uom',
           trl_axle1_to_axle2_uom as 'Axle1 To Axle2 Uom',
           trl_axle2_to_axle3_uom as 'Axle2 To Axle3 Uom', 
           trl_axle3_to_axle4_uom as 'Axle3 To Axle4 Uom', 
           trl_createdate as 'Created Date',
           (Cast(Floor(Cast(trl_createdate  as float))as smalldatetime)) AS [Created Date Only],
           trl_pupid as 'Pup ID',
           trl_axle4_to_axle5 as 'Axle4 To Axle5', 
           trl_axle4_to_axle5_uom as 'Axle4 To Axle5 Uom', 
           trl_lastaxle_to_rear as 'Last Axle To Rear', 
           trl_lastaxle_to_rear_uom as 'Last Axle To Rear Uom',   
           trl_nose_to_kp as 'Nose To Kp', 
           trl_nose_to_kp_uom as 'Nose To Kp Uom', 
           trl_total_no_of_compartments as 'Total Number of Compartments', 
           trl_total_trailer_size_wet as 'Total Trailer Size Wet', 
           trl_uom_wet as 'Uom Wet', 
           trl_total_trailer_size_dry as 'Total Trailer Size Dry', 
           trl_uom_dry as 'Uom Dry', 
           trl_comprt1_size_dry as 'Compartment1 Size Dry', 
           trl_comprt2_size_dry as 'Compartment2 Size Dry', 
           trl_comprt3_size_dry as 'Compartment3 Size Dry', 
           trl_comprt4_size_dry as 'Compartment4 Size Dry', 
           trl_comprt5_size_dry as 'Compartment5 Size Dry', 
           trl_comprt6_size_dry as 'Compartment6 Size Dry', 
           trl_comprt1_uom_dry as 'Compartment1 Uom Dry', 
           trl_comprt2_uom_dry as 'Compartment2 Uom Dry', 
           trl_comprt3_uom_dry as 'Compartment3 Uom Dry',
           trl_comprt4_uom_dry as 'Compartment4 Uom Dry',
           trl_comprt5_uom_dry as 'Compartment5 Uom Dry',
           trl_comprt6_uom_dry as 'Compartment6 Uom Dry',
           trl_bulkhead_comprt1_thick as 'Bulkhead Compartment1 Thick', 
           trl_bulkhead_comprt2_thick as 'Bulkhead Compartment2 Thick', 
           trl_bulkhead_comprt3_thick as 'Bulkhead Compartment3 Thick', 
           trl_bulkhead_comprt4_thick as 'Bulkhead Compartment4 Thick',  
           trl_bulkhead_comprt5_thick as 'Bulkhead Compartment5 Thick',  
           trl_bulkhead_comprt1_thick_uom as 'Bulkhead Compartment1 Thick Uom', 
           trl_bulkhead_comprt2_thick_uom as 'Bulkhead Compartment2 Thick Uom', 
           trl_bulkhead_comprt3_thick_uom as 'Bulkhead Compartment3 Thick Uom', 
           trl_bulkhead_comprt4_thick_uom as 'Bulkhead Compartment4 Thick Uom', 
           trl_bulkhead_comprt5_thick_uom as 'Bulkhead Compartment5 Thick Uom', 
           trl_quickentry as 'Quick Entry',
           trl_wash_status as 'Wash Status', 
           trl_manualupdate as 'Manual Update',
           trl_exp1_date as 'Expiration1 Date',
           (Cast(Floor(Cast(trl_exp1_date  as float))as smalldatetime)) AS [Expiration1 Date Only],
           trl_exp2_date as 'Expiration2 Date',
           (Cast(Floor(Cast(trl_exp2_date  as float))as smalldatetime)) AS [Expiration2 Date Only],
           trl_last_cmd as 'Last Cmd',
           trl_last_cmd_ord as 'Last Cmd Ord',
           trl_last_cmd_date as 'Last Cmd Date',
           (Cast(Floor(Cast(trl_last_cmd_date  as float))as smalldatetime)) AS [Last Cmd Date Only],
           trl_palletcount as 'Pallet Count',
           trl_customer_flag as 'Customer Flag',
           trl_billto_parent as 'Bill To Parent', 
           trl_booked_revtype1 as 'Booked RevType1',
           trl_next_event as 'Next Event',
           trl_next_cmp_id as 'Next Company ID',
           IsNull((select cty_name from city WITH (NOLOCK) where cty_code = trl_next_city),'') as 'Next City',
           trl_next_state as 'Next State',
           trl_next_region1 as 'Next Region 1',
           trl_next_region2 as 'Next Region 2',
           trl_next_region3 as 'Next Region 3',
           trl_next_region4 as 'Next Region 4',
           trl_prior_event as 'Prior Event',
           trl_prior_cmp_id as 'Prior Company ID', 
           IsNull((select cty_name from city WITH (NOLOCK) where cty_code = trl_prior_city),'') as 'Prior City',
           trl_prior_state as 'Prior State', 
           trl_prior_region1 as 'Prior Region 1', 
           trl_prior_region2 as 'Prior Region 2', 
           trl_prior_region4 as 'Prior Region 4', 
           trl_prior_region3 as 'Prior Region 3',
			trl_branch as Branch,
			trl_accessorylist as [Accessory List],	 
			trl_gp_class as [GP Class],
			trl_newused as [NewUsed]

FROM         dbo.trailerprofile WITH (NOLOCK) 



GO
GRANT SELECT ON  [dbo].[vSSRSRB_TrailerProfile] TO [public]
GO
