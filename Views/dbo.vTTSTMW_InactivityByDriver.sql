SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE      View [dbo].[vTTSTMW_InactivityByDriver]

As

Select  Top 100 Percent
	LegHeader.mov_number as Movement,
        IsNull(MaxAsgnNumber,-1) as MaxAsgnNumber,
        lgh_tractor as [Tractor ID],
        lgh_primary_trailer as [Trailer ID],
        'Origin Company' = (select Top 1 Company.cmp_name from Company where legheader.cmp_id_start = Company.cmp_id), 
	'Origin City State' = (select City.cty_name + ', '+ City.cty_state from City where legheader.lgh_startcity = City.cty_code),
        lgh_startdate as 'Segment Start Date',
	lgh_enddate as 'Segment End Date',
        'Destination Company' = (select Top 1 Company.cmp_name from Company where legheader.cmp_id_end = Company.cmp_id),
        'Destination City State' = (select City.cty_name + ', '+ City.cty_state from City where legheader.lgh_endcity = City.cty_code),
        asgn_enddate as 'Assignment End Date',
	IsNull(DateDiff(day,Asgn_enddate,GETDATE()),0)  as DaysInactive,
	Case When lgh_enddate Is Null Then
		'Y'
	Else
		'N'
	End as NeverTakenLoadYN,
	vTTSTMW_DriverProfile.*
From 
	(select 
	mpp_id,
	IsNull(mpp_firstname,'') + ' ' + IsNull(mpp_lastname,'') as DriverName,
	'MaxAsgnNumber'=
	(
	select 
		Max(asgn_number) 
	from assetassignment a
	where 
		mpp_id=asgn_id
		AND
		asgn_type = 'DRV'
		and 
		asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b 
		where
     			(b.asgn_type = 'DRV'
			and 
			a.asgn_id = b.asgn_id)
		)

	)
	
From
	ManpowerProfile
WHERE
	MPP_id<>'UNKNOWN'	
	and
	mpp_terminationdt > GETDATE() 

	) as TempInactivity Left Join Assetassignment On TempInactivity.MaxAsgnNumber =Assetassignment.Asgn_number
             	 	    Left Join LegHeader On Assetassignment.lgh_number = LegHeader.lgh_number 
			    Left Join vTTSTMW_DriverProfile on [Driver ID] = mpp_id
where 
	DateDiff(day,Asgn_enddate,GETDATE()) > 0  or Asgn_enddate is NULL

order by DaysInactive DESC





GO
GRANT SELECT ON  [dbo].[vTTSTMW_InactivityByDriver] TO [public]
GO
