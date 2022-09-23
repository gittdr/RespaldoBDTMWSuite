SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO










--select * from vTTSTMW_InactivityByTractor



CREATE          View [dbo].[vTTSTMW_InactivityByTractor]

As

Select  Top 100 Percent
	LegHeader.mov_number as Movement,
        IsNull(MaxAsgnNumber,-1) as MaxAsgnNumber,
        case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End as [Driver],
	(select top 1 mpp_firstname from manpowerprofile (NOLOCK) where mpp_id = case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End) as 'Driver First Name', 
        (select top 1 mpp_lastname from manpowerprofile (NOLOCK) where mpp_id = case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End) as 'Driver Last Name', 
        (select top 1 mpp_address1 from manpowerprofile (NOLOCK) where mpp_id = case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End) as 'Driver Address1',   
	IsNull((select top 1 cty_name from city (NOLOCK),manpowerprofile (NOLOCK) where mpp_id =  case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End and mpp_city = cty_code),'') as 'Driver City', 
        (select top 1 mpp_state from manpowerprofile (NOLOCK) where mpp_id = case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End) as 'Driver State', 
        (select top 1 mpp_zip from manpowerprofile (NOLOCK) where mpp_id = case when lgh_driver1 Is Null Then trc_driver Else lgh_driver1 End) as 'Driver Zip Code', 
	mpp_teamleader as [Team Leader],
        lgh_primary_trailer as [Trailer ID],
        'Origin Company' = (select Top 1 Company.cmp_name from Company where legheader.cmp_id_start = Company.cmp_id), 
	'Origin City State' = (select City.cty_name + ', '+ City.cty_state from City where legheader.lgh_startcity = City.cty_code),
        lgh_startdate as 'Segment Start Date',
	lgh_enddate as 'Segment End Date',
        'Destination Company' = (select Top 1 Company.cmp_name from Company where legheader.cmp_id_end = Company.cmp_id),
        'Destination City State' = (select City.cty_name + ', '+ City.cty_state from City where legheader.lgh_endcity = City.cty_code),
        Asgn_enddate as 'Assignment End Date',
	IsNull(DateDiff(day,Asgn_enddate,GETDATE()),0)  as DaysInactive,
	Case When lgh_enddate Is Null Then
		'Y'
	Else
		'N'
	End as NeverTakenLoadYN,
	TotalMilesLast7Days = IsNull((select sum(stp_lgh_mileage) from stops (NOLOCK),legheader b (NOLOCK) where stops.lgh_number = b.lgh_number and [Tractor] = b.lgh_tractor and stp_arrivaldate >= DateAdd(d,-7,getdate()) and stp_status ='DNE'),0),
	TotalMilesLast30Days = IsNull((select sum(stp_lgh_mileage) from stops (NOLOCK),legheader b (NOLOCK) where stops.lgh_number = b.lgh_number and [Tractor] = b.lgh_tractor and stp_arrivaldate >= DateAdd(d,-30,getdate()) and stp_status ='DNE'),0),
	vTTSTMW_TractorProfile.*
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
			  Left Join vTTSTMW_TractorProfile On trc_number = Tractor
where 
	DateDiff(day,Asgn_enddate,GETDATE()) > 0  or Asgn_enddate is NULL

order by DaysInactive DESC



















GO
GRANT SELECT ON  [dbo].[vTTSTMW_InactivityByTractor] TO [public]
GO
