SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE View [dbo].[vSSRSRB_InactivityByTractor]

As
/**
 *
 * NAME:
 * dbo.[vSSRSRB_InactivityByTractor]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Tractor and it's last activity data
 
 *
**************************************************************************

Sample call


select * from [vSSRSRB_InactivityByTractor]


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Tractor last activity data
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created [vSSRSRB_InactivityByTractor]
 **/
Select  
	LegHeader.mov_number as [Move Number],
        IsNull(MaxAsgnNumber,-1) as MaxAsgnNumber,
        case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End as [Driver1 ID],
	(select top 1 mpp_firstname from manpowerprofile WITH (NOLOCK) where mpp_id = case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End) as 'Driver First Name', 
        (select top 1 mpp_lastname from manpowerprofile WITH (NOLOCK) where mpp_id = case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End) as 'Driver Last Name', 
        (select top 1 mpp_address1 from manpowerprofile WITH (NOLOCK) where mpp_id = case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End) as 'Driver Address1',   
	IsNull((select top 1 cty_name from city WITH (NOLOCK),manpowerprofile WITH (NOLOCK) where mpp_id =  case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End and mpp_city = cty_code),'') as 'Driver City', 
        (select top 1 mpp_state from manpowerprofile WITH (NOLOCK) where mpp_id = case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End) as 'Driver State', 
        (select top 1 mpp_zip from manpowerprofile WITH (NOLOCK) where mpp_id = case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End) as 'Driver Zip Code', 
	mpp_teamleader as [Team Leader],
        lgh_primary_trailer as [Trailer ID],
        'Origin Company' = (select Top 1 Company.cmp_name from Company where legheader.cmp_id_start = Company.cmp_id), 
	'Origin City State' = (select City.cty_name + ', '+ City.cty_state from City where legheader.lgh_startcity = City.cty_code),
        lgh_startdate as 'Segment Start Date',
		(Cast(Floor(Cast(lgh_startdate as float))as smalldatetime)) AS [Segment Start Date Only],
		lgh_enddate as 'Segment End Date',
		(Cast(Floor(Cast(lgh_enddate as float))as smalldatetime)) AS [Segment End Date Only],
        'Destination Company' = (select Top 1 Company.cmp_name from Company where legheader.cmp_id_end = Company.cmp_id),
        'Destination City State' = (select City.cty_name + ', '+ City.cty_state from City where legheader.lgh_endcity = City.cty_code),
        Asgn_enddate as 'Assignment End Date',
        (Cast(Floor(Cast(Asgn_enddate  as float))as smalldatetime)) AS [Assignment End Date Only],
	IsNull(DateDiff(day,Asgn_enddate,GETDATE()),0)  as DaysInactive,
	Case When lgh_enddate Is Null Then
		'Y'
	Else
		'N'
	End as NeverTakenLoadYN,
	TotalMilesLast7Days = IsNull((select sum(stp_lgh_mileage) from stops WITH (NOLOCK),legheader b WITH (NOLOCK) where stops.lgh_number = b.lgh_number and [Tractor] = b.lgh_tractor and stp_arrivaldate >= DateAdd(d,-7,getdate()) and stp_status ='DNE'),0),
	TotalMilesLast30Days = IsNull((select sum(stp_lgh_mileage) from stops WITH (NOLOCK),legheader b WITH (NOLOCK) where stops.lgh_number = b.lgh_number and [Tractor] = b.lgh_tractor and stp_arrivaldate >= DateAdd(d,-30,getdate()) and stp_status ='DNE'),0),
	vSSRSRB_TractorProfile.*
From 
	(select 
	trc_number,
        trc_status,
	trc_driver,
	--trc_division as Division,
	--trc_terminal as Terminal,
	--trc_startdate as [Start Date],
        'MaxAsgnNumber'=
	(
	select 
		Max(asgn_number) 
	from assetassignment a
	where 
		trc_number=asgn_id
		AND
		asgn_type = 'TRC'
		and 
		asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b 
		where
     			(b.asgn_type = 'TRC'
			and 
			a.asgn_id = b.asgn_id)
		)

	)

From
	TractorProfile
WHERE
	trc_number<>'UNKNOWN'	
	and
	trc_retiredate > GETDATE()  
	) 
        As TempInactivity Left Join Assetassignment On TempInactivity.MaxAsgnNumber =Assetassignment.Asgn_number
              	          Left Join LegHeader On Assetassignment.lgh_number = LegHeader.lgh_number 
			  Left Join vSSRSRB_TractorProfile On trc_number = Tractor
where 
	DateDiff(day,Asgn_enddate,GETDATE()) > 0  or Asgn_enddate is NULL



GO
GRANT SELECT ON  [dbo].[vSSRSRB_InactivityByTractor] TO [public]
GO
