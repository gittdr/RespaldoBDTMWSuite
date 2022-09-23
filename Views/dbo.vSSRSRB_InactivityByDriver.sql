SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  View [dbo].[vSSRSRB_InactivityByDriver]
As

/**
 *
 * NAME:
 * dbo.vSSRSRB_InactivityByDriver
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Data for InActive Driver 
 *
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 PJK Revised 
 **/
Select  
	    LegHeader.mov_number as [Move Number],
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
	vSSRSRB_DriverProfile.*
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

	) as TempInactivity 
	  Left Join Assetassignment On TempInactivity.MaxAsgnNumber =Assetassignment.Asgn_number
      Left Join LegHeader On Assetassignment.lgh_number = LegHeader.lgh_number 
	  Left Join vSSRSRB_DriverProfile on [Driver ID] = mpp_id
where 
	DateDiff(day,Asgn_enddate,GETDATE()) > 0  or Asgn_enddate is NULL

GO
GRANT SELECT ON  [dbo].[vSSRSRB_InactivityByDriver] TO [public]
GO
