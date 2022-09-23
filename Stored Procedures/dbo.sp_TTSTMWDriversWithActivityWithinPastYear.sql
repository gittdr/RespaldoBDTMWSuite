SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO











































































































































CREATE          procedure [dbo].[sp_TTSTMWDriversWithActivityWithinPastYear]

as

Declare @asgntype as char(20)

Select @asgntype = 'DRV'

select 
	mpp_id,
	IsNull(mpp_firstname,'') + ' ' + IsNull(mpp_lastname,'') as DriverName,
        mpp_hiredate as HireDate,
	'MaxAsgnNumber'=
	(
	select 
		Max(asgn_number) 
	from assetassignment a
	where 
		mpp_id=asgn_id
		AND
		asgn_type = @asgntype
		and 
		(a.asgn_status='CMP' or a.asgn_status = 'STD')
		and
		asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b 
		where
     			(b.asgn_type = @asgntype
			and
			(b.asgn_status='CMP' or b.asgn_status = 'STD')
			and 
			a.asgn_id = b.asgn_id)
		)

	)
into
#temp

From
	ManpowerProfile
WHERE
	MPP_id<>'UNKNOWN'	
	and
	mpp_terminationdt > GETDATE() 
	

Select 
	LegHeader.mov_number as LastMovementNumber,
        mpp_id as AsgnID,
	DriverName,
	IsNull(MaxAsgnNumber,-1) as MaxAsgnNumber,
        lgh_tractor as Tractor,
        lgh_primary_trailer as Trailer,
        'OriginCompany' = (select Top 1 Company.cmp_name from Company where legheader.cmp_id_start = Company.cmp_id), 
	'origin_city_state' = (select City.cty_name + ', '+ City.cty_state from City where legheader.lgh_startcity = City.cty_code),
        lgh_startdate as FromDate,
	lgh_enddate as ToDate,
        'DestCompany' = (select Top 1 Company.cmp_name from Company where legheader.cmp_id_end = Company.cmp_id),
        'dest_city_state' = (select City.cty_name + ', '+ City.cty_state from City where legheader.lgh_endcity = City.cty_code),
        Asgn_enddate as LastTripEndDate,
	IsNull(DateDiff(day,Asgn_enddate,GETDATE()),0)  as DaysInactive,
	HireDate
From 
	#Temp Left Join Assetassignment On #temp.MaxAsgnNumber =Assetassignment.Asgn_number
              Left Join LegHeader On Assetassignment.lgh_number = LegHeader.lgh_number 
where 
	DateDiff(day,Asgn_enddate,GETDATE()) <= 365  

order by DaysInactive DESC

Drop table #temp
















GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWDriversWithActivityWithinPastYear] TO [public]
GO
