SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE      view [dbo].[vSSRSRB_InactivityByCarrier]

As
/**
 *
 * NAME:
 * dbo.[vSSRSRB_InactivityByCarrier]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Inactivity by Carrier View, lists time since a carriers last activity
 
 *
**************************************************************************

Sample call


select * from [vSSRSRB_InactivityByCarrier]


**************************************************************************
 * RETURNS:
 * Resultset
 *
 * RESULT SETS:
 * INactivity by Carrier
 *
 * PARAMETERS:
 * 0n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created view
 **/


Select 
	LegHeader.mov_number as [Move Number],
        car_id as 'Carrier ID',
	[Carrier Name],
	car_iccnum as 'MC Number',
	IsNull(MaxAsgnNumber,-1) as MaxAsgnNumber,
	IsNull(LoadCount, -1) as LoadCount,
        lgh_tractor as Tractor,
        lgh_primary_trailer as Trailer,
        'OriginCompany Name' = (select Top 1 Company.cmp_name from Company where legheader.cmp_id_start = Company.cmp_id), 
	'origin_city_state' = (select City.cty_name + ', '+ City.cty_state from City where legheader.lgh_startcity = City.cty_code),
        lgh_startdate as FromDate,
        (Cast(Floor(Cast(lgh_startdate as float))as smalldatetime)) AS [FromDate Only],
	lgh_enddate as ToDate,
	(Cast(Floor(Cast(lgh_enddate as float))as smalldatetime)) AS [ToDate Only],
        'Destination Company Name' = (select Top 1 Company.cmp_name from Company where legheader.cmp_id_end = Company.cmp_id),
        'dest_city_state' = (select City.cty_name + ', '+ City.cty_state from City where legheader.lgh_endcity = City.cty_code),
        Asgn_enddate as [Assignment End Date],
       	(Cast(Floor(Cast(Asgn_enddate as float))as smalldatetime)) AS [Assignment End Date Only],
	IsNull(DateDiff(day,Asgn_enddate,GETDATE()),0)  as DaysInactive,
	lgh_class1 as 'RevType1',
        lgh_class2 as 'RevType2',
	lgh_class3 as 'RevType3',
	lgh_class4 as 'RevType4',
	CarType1,
	CarType2,
	CarType3,
	CarType4
From 
	--#Temp 



(

select 
	car_id,
	car_iccnum,
	car_type1 as [CarType1],
	car_type2 as [CarType2],
	car_type3 as [CarType3],
	car_type4 as [CarType4],
	IsNull(car_name,'') as 'Carrier Name',
	'MaxAsgnNumber'=
	(
	select 
		Max(asgn_number) 
	from assetassignment a
	where 
		car_id=asgn_id
		AND
		asgn_type = 'CAR'
		and 
		asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b 
		where
     			(b.asgn_type = 'CAR'
			and 
			a.asgn_id = b.asgn_id)
		)

	),
	'LoadCount'=
	(
	select 
		count( distinct asgn_number) 
	from assetassignment a
	where 
		car_id=asgn_id
		AND
		asgn_type = 'CAR'
		

	)

From
	Carrier
WHERE
	car_id<>'UNKNOWN'	
	and
	car_status = 'Act' 

) as TempInactivity Left Join Assetassignment On TempInactivity.MaxAsgnNumber =Assetassignment.Asgn_number
                    Left Join LegHeader On Assetassignment.lgh_number = LegHeader.lgh_number 

where 
	DateDiff(day,Asgn_enddate,GETDATE()) > 0  or Asgn_enddate is NULL

GO
GRANT SELECT ON  [dbo].[vSSRSRB_InactivityByCarrier] TO [public]
GO
