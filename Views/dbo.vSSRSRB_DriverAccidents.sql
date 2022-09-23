SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  view [dbo].[vSSRSRB_DriverAccidents]

As

/**
 *
 * NAME:
 * dbo.vSSRSRB_DriverAccidents
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Data for Driver Accident 
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Revised 
 **/

SELECT     driveraccident.mpp_id as 'Driver ID', 
           'DrvType1 Name' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = manpowerprofile.mpp_type1 and labelfile.labeldefinition = 'DrvType1'),''),
	       manpowerprofile.mpp_type1 as 'DrvType1', 
           'DrvType2 Name' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = manpowerprofile.mpp_type2 and labelfile.labeldefinition = 'DrvType2'),''),
	       manpowerprofile.mpp_type2 as 'DrvType2', 
           'DrvType3 Name' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = manpowerprofile.mpp_type3 and labelfile.labeldefinition = 'DrvType3'),''),
	       manpowerprofile.mpp_type3 as 'DrvType3', 
           'DrvType4 Name' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = manpowerprofile.mpp_type4 and labelfile.labeldefinition = 'DrvType4'),''),
           manpowerprofile.mpp_type4 as 'DrvType4', 
           Case When (Select manpowerprofile.mpp_terminationdt from manpowerprofile WITH (NOLOCK) where driveraccident.mpp_id = manpowerprofile.mpp_id) > GetDate() Then 
                 'Y' 
           Else 
                 'N' 
           End As 'ActiveYN',
       	   driveraccident.dra_accidentdate as 'Accident Date',  
           (Cast(Floor(Cast(driveraccident.[dra_accidentdate] as float))as smalldatetime)) as [Accident Date Only], 
           Cast(DatePart(yyyy,driveraccident.[dra_accidentdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,driveraccident.[dra_accidentdate]) as varchar(2)) + '-' + Cast(DatePart(dd,driveraccident.[dra_accidentdate]) as varchar(2)) as [Accident Day],
           Cast(DatePart(mm,driveraccident.[dra_accidentdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,driveraccident.[dra_accidentdate]) as varchar(4)) as [Accident Month],
           DatePart(mm,driveraccident.[dra_accidentdate]) as [Accident Month Only],
           DatePart(yyyy,driveraccident.[dra_accidentdate]) as [Accident Year],
	       driveraccident.dra_filenumber as 'File Number', 
           driveraccident.dra_points as 'Points', 
           driveraccident.dra_description as 'Description', 
           driveraccident.dra_preventable as 'Preventable', 
           driveraccident.dra_code as 'Driver Accident Code', 
           driveraccident.trc_number as 'Tractor', 
           driveraccident.dra_cost as 'Accident Cost', 
           driveraccident.trl_number as 'Trailer',
           manpowerprofile.mpp_type as 'Driver Type', 
           manpowerprofile.mpp_otherid as 'Other ID', 
           manpowerprofile.mpp_employedby as 'Employed By', 
           manpowerprofile.mpp_firstname as 'First Name', 
           manpowerprofile.mpp_middlename as 'Middle Name', 
           manpowerprofile.mpp_lastname as 'Last Name', 
           cast(IsNull(manpowerprofile.mpp_ssn,'') as char(10)) as 'Social Security Number',  
           manpowerprofile.mpp_address1 as 'Address1', 
           manpowerprofile.mpp_address2 as 'Address2', 
           IsNull((select city.cty_name from city WITH (NOLOCK) where manpowerprofile.mpp_city = city.cty_code),'') as 'City', 
           manpowerprofile.mpp_state as 'State', 
           manpowerprofile.mpp_zip as 'Zip Code', 
           manpowerprofile.mpp_hiredate as 'Hire Date', 
           manpowerprofile.mpp_senioritydate as 'Seniority Date', 
           manpowerprofile.mpp_licensestate as 'License State', 
           manpowerprofile.mpp_licenseclass as 'License Class', 
           manpowerprofile.mpp_licensenumber as 'License Number', 
           manpowerprofile.mpp_dateofbirth as 'Date of Birth', 
           manpowerprofile.mpp_currentphone as 'Current Phone Number', 
           manpowerprofile.mpp_alternatephone as 'Alternate Phone Number',  
           manpowerprofile.mpp_homephone as 'Home Phone Number', 
           manpowerprofile.mpp_currency as 'Currency', 
           manpowerprofile.mpp_payto as 'PayTo', 
           manpowerprofile.mpp_singlemilerate as 'Single Mile Rate', 
           manpowerprofile.mpp_teammilerate as 'Team Mile Rate', 
           manpowerprofile.mpp_hourlyrate as 'Hourly Rate', 
           manpowerprofile.mpp_revenuerate as 'Revenue Rate', 
           manpowerprofile.mpp_teamleader as 'Team Leader', 
           manpowerprofile.mpp_fleet as 'Fleet', 
           manpowerprofile.mpp_division as 'Division', 
           manpowerprofile.mpp_domicile as 'Domicile', 
           manpowerprofile.mpp_company as 'Company ID', 
           manpowerprofile.mpp_terminal as 'Terminal', 
           manpowerprofile.mpp_status as 'Driver Status', 
           manpowerprofile.mpp_emerphone as 'Emergency Phone Number', 
           manpowerprofile.mpp_emername as 'Emergency Contact Name', 
           manpowerprofile.mpp_voicemailbox as 'Voice Mail Box', 
           manpowerprofile.mpp_terminationdt as 'Termination Date', 
           manpowerprofile.mpp_avl_date as 'Available Date', 
           manpowerprofile.mpp_avl_cmp_id as 'Available Company ID', 
           IsNull((select city.cty_name from city WITH (NOLOCK) where  manpowerprofile.mpp_avl_city = city.cty_code),'') as 'Available City', 
           manpowerprofile.mpp_avl_status as 'Available Status', 
           manpowerprofile.mpp_pln_date as 'Planned Date', 
           manpowerprofile.mpp_pln_cmp_id as 'Planned Company ID', 
           IsNull((select city.cty_name from city WITH (NOLOCK) where manpowerprofile.mpp_pln_city  = city.cty_code),'') as 'Planned City',  
           manpowerprofile.mpp_pln_lgh as 'Planned LegHeader', 
           manpowerprofile.mpp_avl_lgh as 'Available LegHeader', 
           manpowerprofile.mpp_lastfirst as 'Driver Last First Name',  
           manpowerprofile.mpp_actg_type as 'Accounting Type',  
           manpowerprofile.mpp_last_home as 'Last Home', 
           manpowerprofile.mpp_want_home as 'Want Home',
           manpowerprofile.mpp_misc1 as 'Misc1', 
           manpowerprofile.mpp_misc2 as 'Misc2', 
           manpowerprofile.mpp_misc3 as 'Misc3', 
           manpowerprofile.mpp_misc4 as 'Misc4', 
           manpowerprofile.mpp_usecashcard as 'Use Cash Card', 
           cast(manpowerprofile.mpp_updatedby as varchar(255)) as 'Updated By',
           manpowerprofile.mpp_bmp_pathname as 'Bmp Path Name', 
           manpowerprofile.mpp_updateon as 'Updated On', 
           manpowerprofile.mpp_createdate as 'Created Date', 
           manpowerprofile.mpp_quickentry as 'Quick Entry', 
           manpowerprofile.mpp_servicerule as 'Service Rule', 
           manpowerprofile.mpp_gps_desc as 'GPS Description', 
           manpowerprofile.mpp_gps_date as 'GPS Date', 
           manpowerprofile.mpp_gps_latitude as 'GPS Latitude', 
           manpowerprofile.mpp_gps_longitude as 'GPS Longitude', 
           manpowerprofile.mpp_travel_minutes as 'Travel Minutes', 
           manpowerprofile.mpp_mile_day7 as 'Mile Day 7', 
           manpowerprofile.mpp_home_latitude as 'Home Latitude', 
           manpowerprofile.mpp_home_longitude as 'Home Longitude', 
           manpowerprofile.mpp_last_log_date as 'Last Log Date', 
           manpowerprofile.mpp_hours1 as 'Hours1', 
           manpowerprofile.mpp_hours2 as 'Hours2',  
           manpowerprofile.mpp_hours3 as 'Hours3' , 
           IsNull(manpowerprofile.mpp_home_city,'') as 'Home City', 
           manpowerprofile.mpp_exp1_date as 'Exp1 Date', 
           manpowerprofile.mpp_exp2_date as 'Exp2 Date', 
           manpowerprofile.mpp_next_event as 'Next Event', 
           manpowerprofile.mpp_next_cmp_id as 'Next Company ID', 
           manpowerprofile.mpp_next_city as 'Next City', 
           manpowerprofile.mpp_next_state as 'Next State', 
           manpowerprofile.mpp_next_region1 as 'Next Region 1', 
           manpowerprofile.mpp_next_region2 as 'Next Region 2', 
           manpowerprofile.mpp_next_region3 as 'Next Region 3', 
           manpowerprofile.mpp_next_region4 as 'Next Region 4' , 
           manpowerprofile.mpp_prior_event as 'Prior Event', 
           manpowerprofile.mpp_prior_cmp_id as 'Prior Company ID', 
           IsNull((select city.cty_name from city WITH (NOLOCK) where manpowerprofile.mpp_prior_city = city.cty_code),'') as 'Prior City',   
           manpowerprofile.mpp_prior_state as 'Prior State', 
           manpowerprofile.mpp_prior_region1 as 'Prior Region 1', 
           manpowerprofile.mpp_prior_region2 as 'Prior Region 2', 
           manpowerprofile.mpp_prior_region3 as 'Prior Region 3', 
           manpowerprofile.mpp_prior_region4 as 'Prior Region 4', 
           manpowerprofile.mpp_dailyhrsest as 'Daily Hours Estimate', 
           manpowerprofile.mpp_weeklyhrsest as 'Weekly Hours Estimate', 
           manpowerprofile.mpp_lastlog_cmp_id as 'Lost Log Company ID', 
	       manpowerprofile.mpp_lastlog_estdate as 'Last Log Estitimate Date' , 
           manpowerprofile.mpp_lastlog_cmp_name as 'Last Log Company Name', 
           manpowerprofile.mpp_estlog_datetime as 'Estimate Log Date Time'

FROM       dbo.driveraccident WITH (NOLOCK) Inner Join manpowerprofile WITH (NOLOCK) On manpowerprofile.mpp_id = driveraccident.mpp_id
             
GO
GRANT DELETE ON  [dbo].[vSSRSRB_DriverAccidents] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_DriverAccidents] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_DriverAccidents] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_DriverAccidents] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_DriverAccidents] TO [public]
GO
