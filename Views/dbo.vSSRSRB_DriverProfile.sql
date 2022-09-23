SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vSSRSRB_DriverProfile]

As

Select

TempMan2.*,
[Last Trip Tractor] = (select min(asgn_id) from AssetAssignment WITH (NOLOCK) where AssetAssignment.lgh_number = TempMan2.lgh_number and asgn_type = 'TRC'),
[Last Trip Final Destination] = (select min(lgh_endcty_nmstct) from legheader WITH (NOLOCK) where TempMan2.lgh_number = LegHeader.lgh_number ),
[Last Trip Final State] = (select min(lgh_endstate) from legheader WITH (NOLOCK) where TempMan2.lgh_number = LegHeader.lgh_number )


from

(

Select

TempMan1.*,
[lgh_number] = (select min(lgh_number) from AssetAssignment WITH (NOLOCK) where asgn_number = MaxAssignmentNumber),
[Last Trip Move Number] = (select min(mov_number) from AssetAssignment WITH (NOLOCK) where asgn_number = MaxAssignmentNumber),
[Last Trip Status] = (select min(asgn_status) from AssetAssignment WITH (NOLOCK) where asgn_number = MaxAssignmentNumber),
[Last Trip Assignment Date] = (select min(asgn_date) from AssetAssignment WITH (NOLOCK) where asgn_number = MaxAssignmentNumber),
[Last Accident Description] = (select max(cast(dra_description as varchar(255))) from driveraccident da WITH (NOLOCK) where [Last Accident Date] = da.dra_accidentdate and [Driver ID] = da.mpp_id),
[Last Accident Preventable] = (select max(dra_preventable) from driveraccident da WITH (NOLOCK) where [Last Accident Date] = da.dra_accidentdate and [Driver ID] = da.mpp_id),
[Last Accident Cost] = (select max(dra_cost) from driveraccident da WITH (NOLOCK) where [Last Accident Date] = da.dra_accidentdate and [Driver ID] = da.mpp_id),
[Last Accident Reference Number] = (select max(dra_filenumber) from driveraccident da WITH (NOLOCK) where [Last Accident Date] = da.dra_accidentdate and [Driver ID] = da.mpp_id),
[Miles Since Last Accident] =  Case When [Last Accident Date] Is Not Null Then
					(select sum(stp_lgh_mileage) from stops WITH (NOLOCK),legheader WITH (NOLOCK) where legheader.lgh_number = stops.lgh_number and stp_arrivaldate > [Last Accident Date] and legheader.lgh_driver1 = [Driver ID] and stp_status = 'DNE') 
			       Else
					Null
			       End
From

(

SELECT     mpp_id as 'Driver ID',
	   Case When mpp_terminationdt > GetDate() or mpp_terminationdt Is Null Then
		'Y'
	   Else
	        'N'
	   End as 'ActiveYN', 
	   [Last Accident Date] = (select max(dra_accidentdate) from driveraccident da WITH (NOLOCK) where manpowerprofile.mpp_id = da.mpp_id),
           mpp_type as 'Driver Type', 
           mpp_tractornumber as 'Tractor', 
           mpp_otherid as 'Other ID', 
           mpp_employedby as 'Employed By', 
           mpp_firstname as 'First Name', 
           mpp_middlename as 'Middle Name', 
           mpp_lastname as 'Last Name', 
           cast(IsNull(mpp_ssn,'') as char(10)) as 'Social Security Number',  
           mpp_address1 as 'Address1', 
           mpp_address2 as 'Address2', 
           IsNull((select cty_name from city WITH (NOLOCK) where mpp_city = cty_code),'') as 'City', 
           mpp_state as 'State', 
           mpp_zip as 'Zip Code', 
	       --Day
       (Cast(Floor(Cast([mpp_hiredate] as float))as smalldatetime)) as [Hire Date Only], 
             Cast(DatePart(dd,[mpp_hiredate]) as varchar(2)) as [Hire Day Only],
	Cast(DatePart(yyyy,[mpp_hiredate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[mpp_hiredate]) as varchar(2)) + '-' + Cast(DatePart(dd,[mpp_hiredate]) as varchar(2)) as [Hire Day],
       --Month
       Cast(DatePart(mm,[mpp_hiredate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[mpp_hiredate]) as varchar(4)) as [Hire Month],
       DatePart(mm,[mpp_hiredate]) as [Hire Month Only],
       --Year
       DatePart(yyyy,[mpp_hiredate]) as [Hire Year], 
           mpp_hiredate as 'Hire Date', 
           mpp_senioritydate as 'Seniority Date', 
           mpp_licensestate as 'License State', 
           mpp_licenseclass as 'License Class', 
           mpp_licensenumber as 'License Number', 
           mpp_dateofbirth as 'Date of Birth', 

	     (Cast(Floor(Cast([mpp_dateofbirth] as float))as datetime)) as [Date Of Birth Date Only], 
       Cast(DatePart(yyyy,[mpp_dateofbirth]) as varchar(4)) +  '-' + Cast(DatePart(mm,[mpp_dateofbirth]) as varchar(2)) + '-' + Cast(DatePart(dd,[mpp_dateofbirth]) as varchar(2)) as [Date Of Birth Day],
       Cast(DatePart(dd,[mpp_dateofbirth]) as varchar(2)) as [Date of Birth Day Only],
	--Month
       Cast(DatePart(mm,[mpp_dateofbirth]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[mpp_dateofbirth]) as varchar(4)) as [Date Of Birth Month],
       DatePart(mm,[mpp_dateofbirth]) as [Date Of Birth Month Only],
       --Year
       DatePart(yyyy,[mpp_dateofbirth]) as [Date Of Birth Year], 

           mpp_currentphone as 'Current Phone Number', 
           mpp_alternatephone as 'Alternate Phone Number',  
           mpp_homephone as 'Home Phone Number', 
           'DrvType1 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = mpp_type1 and labeldefinition = 'DrvType1'),''),
	   mpp_type1 as 'DrvType1', 
           'DrvType2 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = mpp_type2 and labeldefinition = 'DrvType2'),''),
	   mpp_type2 as 'DrvType2', 
           'DrvType3 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = mpp_type3 and labeldefinition = 'DrvType3'),''),
	   mpp_type3 as 'DrvType3', 
           'DrvType4 Name' = IsNull((select name from labelfile WITH (NOLOCK) where labelfile.abbr = mpp_type4 and labeldefinition = 'DrvType4'),''),
           mpp_type4 as 'DrvType4', 
           mpp_currency as 'Currency', 
           mpp_payto as 'PayTo', 
           mpp_singlemilerate as 'Single Mile Rate', 
           mpp_teammilerate as 'Team Mile Rate', 
           mpp_hourlyrate as 'Hourly Rate', 
           mpp_revenuerate as 'Revenue Rate', 
           mpp_teamleader as 'Team Leader', 
	   [Team Leader Name] =  (select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = mpp_teamleader  and labelfile.labeldefinition = 'TeamLeader'),
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
           IsNull((select cty_name from city WITH (NOLOCK) where  mpp_avl_city = cty_code),'') as 'Available City', 
           mpp_avl_status as 'Available Status', 
           mpp_pln_date as 'Planned Date', 
           mpp_pln_cmp_id as 'Planned Company ID', 
           IsNull((select cty_name from city WITH (NOLOCK) where mpp_pln_city  = cty_code),'') as 'Planned City',  
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
          (Cast(Floor(Cast(mpp_createdate as float))as smalldatetime)) as [Created Date Only], 
           mpp_quickentry as 'Quick Entry', 
           mpp_servicerule as 'Service Rule', 
           Cast(mpp_gps_desc as char(35)) as 'GPS Description', 
           mpp_gps_date as 'GPS Date', 
           mpp_gps_latitude as 'GPS Latitude', 
           mpp_gps_longitude as 'GPS Longitude', 
           mpp_travel_minutes as 'Travel Minutes', 
           mpp_mile_day7 as 'Mile Day 7', 
           mpp_home_latitude as 'Home Latitude', 
           mpp_home_longitude as 'Home Longitude', 
           mpp_last_log_date as 'Last Log Date', 
           (convert(int,(Substring([mpp_servicerule],charindex('/',[mpp_servicerule])+1,5)))  -
          (select sum(b.driving_hrs + b.on_duty_hrs) from log_driverlogs b WITH (NOLOCK) where manpowerprofile.mpp_id = b.mpp_id and b.log_date >= (mpp_last_log_date - ((convert(int,(Left([mpp_servicerule],charindex('/',[mpp_servicerule],1)-1))))-1)) and b.log_date <= mpp_last_log_date)) as [Hours1],
	   mpp_hours1 as 'Hours2', 
           mpp_hours2 as 'Hours3',  
           mpp_hours3 as 'Hours4', 
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
           IsNull((select cty_name from city WITH (NOLOCK) where mpp_prior_city   = cty_code),'') as 'Prior City',   
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
           mpp_estlog_datetime as 'Estimate Log Date Time',
	   'MaxAssignmentNumber'=
	(select 
		Max(asgn_number) 
	from assetassignment a WITH (NOLOCK)
	where 
		mpp_id=asgn_id
		AND
		asgn_type = 'DRV'
		and 
                (asgn_status = 'STD' or asgn_status='CMP')
	        and
		asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b WITH (NOLOCK)
		where
     			(b.asgn_type = 'DRV'
			and
                	(asgn_status = 'STD' or asgn_status='CMP') 
			and
			a.asgn_id = b.asgn_id))),
	mpp_branch as Branch,		  
	mpp_gp_class as [GP Class], 
	mpp_qualificationlist as [Qualification List],
	[Region1] = (select min(cty_region1) from city WITH (NOLOCK) where cty_code = mpp_avl_city),
	[Region2] = (select min(cty_region2) from city WITH (NOLOCK) where cty_code = mpp_avl_city),
	[Region3] = (select min(cty_region3) from city WITH (NOLOCK) where cty_code = mpp_avl_city),
	[Region4] = (select min(cty_region4) from city WITH (NOLOCK) where cty_code = mpp_avl_city),
	[Company Name] = (select name from labelfile WITH (NOLOCK) where abbr = mpp_company and labeldefinition = 'Company'),
        [Division Name] = (select name from labelfile WITH (NOLOCK) where abbr = mpp_division and labeldefinition = 'Division'), 
        [Terminal Name] = (select name from labelfile WITH (NOLOCK) where abbr = mpp_terminal and labeldefinition = 'Terminal'),
        [Fleet Name] = (select name from labelfile WITH (NOLOCK) where abbr = mpp_fleet and labeldefinition = 'Fleet'),
	1 as DriverCount



From manpowerprofile WITH (NOLOCK)

) as TempMan1

) as TempMan2




GO
GRANT SELECT ON  [dbo].[vSSRSRB_DriverProfile] TO [public]
GO
