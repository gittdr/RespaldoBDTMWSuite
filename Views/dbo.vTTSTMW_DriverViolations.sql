SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO














CREATE            view [dbo].[vTTSTMW_DriverViolations]

As

--Revision History
--1. Fixed Home City Field to not join to city profile table to get
--   city name
--   After further investigation the field was indeed a varchar field
--   not a city code field. deleted the subquery and it worked 
--   Ver 5.4 LBK
--2. Forced SSN to be 10 characters
--   Ver 5.4 LBK

SELECT     driverlogviolation.mpp_id as 'Driver ID', 
           'DrvType1 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = mpp_type1 and labeldefinition = 'DrvType1'),''),
	   mpp_type1 as 'DrvType1', 
           'DrvType2 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = mpp_type2 and labeldefinition = 'DrvType2'),''),
	   mpp_type2 as 'DrvType2', 
           'DrvType3 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = mpp_type3 and labeldefinition = 'DrvType3'),''),
	   mpp_type3 as 'DrvType3', 
           'DrvType4 Name' = IsNull((select name from labelfile (NOLOCK) where labelfile.abbr = mpp_type4 and labeldefinition = 'DrvType4'),''),
           mpp_type4 as 'DrvType4', 
           Case When mpp_terminationdt > GetDate() Then 
                 'Y' 
           Else 
                 'N' 
           End As 'ActiveYN',
     	   [drl_month] as 'Month', 
	   [drl_year] as 'Year', 
	   [drl_mph] as 'MPH', 
	   [drl_hr10] as 'HR10', 
	   [drl_hr15] as 'HR15', 
	   [drl_hr70] as 'HR70', 
	   [drl_comments] as 'Comments' ,
	   mpp_type as 'Driver Type', 
           mpp_otherid as 'Other ID', 
           mpp_employedby as 'Employed By', 
           mpp_firstname as 'First Name', 
           mpp_middlename as 'Middle Name', 
           mpp_lastname as 'Last Name', 
           cast(IsNull(mpp_ssn,'') as char(10)) as 'Social Security Number',  
           mpp_address1 as 'Address1', 
           mpp_address2 as 'Address2', 
           IsNull((select cty_name from city (NOLOCK) where mpp_city = cty_code),'') as 'City', 
           mpp_state as 'State', 
           mpp_zip as 'Zip Code', 
           mpp_hiredate as 'Hire Date', 
           mpp_senioritydate as 'Seniority Date', 
           mpp_licensestate as 'License State', 
           mpp_licenseclass as 'License Class', 
           mpp_licensenumber as 'License Number', 
           mpp_dateofbirth as 'Date of Birth', 
           mpp_currentphone as 'Current Phone Number', 
           mpp_alternatephone as 'Alternate Phone Number',  
           mpp_homephone as 'Home Phone Number', 
           mpp_currency as 'Currency', 
           mpp_payto as 'PayTo', 
           mpp_singlemilerate as 'Single Mile Rate', 
           mpp_teammilerate as 'Team Mile Rate', 
           mpp_hourlyrate as 'Hourly Rate', 
           mpp_revenuerate as 'Revenue Rate', 
           mpp_teamleader as 'Team Leader', 
           mpp_fleet as 'Fleet', 
           mpp_division as 'Division', 
           mpp_domicile as 'Domicile', 
           mpp_company as 'Company ID', 
           mpp_terminal as 'Terminal', 
           mpp_status as 'Driver Status', 
           mpp_emerphone as 'Emergency Phone Number', 
           mpp_emername as 'Emergency Contact Name', 
           mpp_voicemailbox as 'Voice Mail Box', 
           mpp_terminationdt as 'Termination Date', 
           mpp_avl_date as 'Available Date', 
           mpp_avl_cmp_id as 'Available Company ID', 
           IsNull((select cty_name from city (NOLOCK) where  mpp_avl_city = cty_code),'') as 'Available City', 
           mpp_avl_status as 'Available Status', 
           mpp_pln_date as 'Planned Date', 
           mpp_pln_cmp_id as 'Planned Company ID', 
           IsNull((select cty_name from city (NOLOCK) where mpp_pln_city  = cty_code),'') as 'Planned City',  
           mpp_pln_lgh as 'Planned LegHeader', 
           mpp_avl_lgh as 'Available LegHeader', 
           mpp_lastfirst as 'Driver Last First Name',  
      mpp_actg_type as 'Accounting Type',  
           mpp_last_home as 'Last Home', 
           mpp_want_home as 'Want Home',
           mpp_misc1 as 'Misc1', 
           mpp_misc2 as 'Misc2', 
           mpp_misc3 as 'Misc3', 
           mpp_misc4 as 'Misc4', 
           mpp_usecashcard as 'Use Cash Card', 
           cast(mpp_updatedby as varchar(255)) as 'Updated By',
           mpp_bmp_pathname as 'Bmp Path Name', 
           mpp_updateon as 'Updated On', 
           mpp_createdate as 'Created Date', 
           mpp_quickentry as 'Quick Entry', 
           mpp_servicerule as 'Service Rule', 
           mpp_gps_desc as 'GPS Description', 
           mpp_gps_date as 'GPS Date', 
           mpp_gps_latitude as 'GPS Latitude', 
           mpp_gps_longitude as 'GPS Longitude', 
           mpp_travel_minutes as 'Travel Minutes', 
           mpp_mile_day7 as 'Mile Day 7', 
           mpp_home_latitude as 'Home Latitude', 
           mpp_home_longitude as 'Home Longitude', 
           mpp_last_log_date as 'Last Log Date', 
           mpp_hours1 as 'Hours1', 
           mpp_hours2 as 'Hours2',  
           mpp_hours3 as 'Hours3' , 
           IsNull(mpp_home_city,'') as 'Home City', 
           mpp_exp1_date as 'Exp1 Date', 
           mpp_exp2_date as 'Exp2 Date', 
           mpp_next_event as 'Next Event', 
           mpp_next_cmp_id as 'Next Company ID', 
           mpp_next_city as 'Next City', 
           mpp_next_state as 'Next State', 
           mpp_next_region1 as 'Next Region 1', 
           mpp_next_region2 as 'Next Region 2', 
           mpp_next_region3 as 'Next Region 3', 
           mpp_next_region4 as 'Next Region 4' , 
           mpp_prior_event as 'Prior Event', 
           mpp_prior_cmp_id as 'Prior Company ID', 
           IsNull((select cty_name from city (NOLOCK) where mpp_prior_city   = cty_code),'') as 'Prior City',   
           mpp_prior_state as 'Prior State', 
           mpp_prior_region1 as 'Prior Region 1', 
           mpp_prior_region2 as 'Prior Region 2', 
           mpp_prior_region3 as 'Prior Region 3', 
           mpp_prior_region4 as 'Prior Region 4', 
           mpp_dailyhrsest as 'Daily Hours Estimate', 
           mpp_weeklyhrsest as 'Weekly Hours Estimate', 
           mpp_lastlog_cmp_id as 'Lost Log Company ID', 
	   mpp_lastlog_estdate as 'Last Log Estitimate Date' , 
           mpp_lastlog_cmp_name as 'Last Log Company Name', 
           --Deleted as of 5/6/2003 Ver 4.98 can be re added 2003 Ver
           --because field is only being utilized for Total Mail users only
           --mpp_gps_odometer as 'Miles Per Gallon Odomoter', 
           mpp_estlog_datetime as 'Estimate Log Date Time',
	    --<TTS!*!TMW><Begin><FeaturePack=Other>
	   '' as Branch,
	   --<TTS!*!TMW><End><FeaturePack=Other>
	   --<TTS!*!TMW><Begin><FeaturePack=Euro>
	   --mpp_branch as Branch,		
	   --<TTS!*!TMW><End><FeaturePack=Euro>
	   
           --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [Country],
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --mpp_country as [Country],
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	   --<TTS!*!TMW><Begin><FeaturePack=Other> 
	   '' as [GP Class], 
	   --<TTS!*!TMW><End><FeaturePack=Other> 
	   --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	   --mpp_gp_class as [GP Class], 
	   --<TTS!*!TMW><End><FeaturePack=Euro> 
  
	  --<TTS!*!TMW><Begin><FeaturePack=Other> 
	  '' as [Qualification List] 
	  --<TTS!*!TMW><End><FeaturePack=Other> 
	  --<TTS!*!TMW><Begin><FeaturePack=Euro> 
	  --mpp_qualificationlist as [Qualification List]
	  --<TTS!*!TMW><End><FeaturePack=Euro> 

FROM         dbo.driverlogviolation (NOLOCK) Inner Join manpowerprofile (NOLOCK) On manpowerprofile.mpp_id = driverlogviolation.mpp_id
             













GO
GRANT SELECT ON  [dbo].[vTTSTMW_DriverViolations] TO [public]
GO
