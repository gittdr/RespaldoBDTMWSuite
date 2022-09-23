SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE View [dbo].[vSSRSRB_InactivityByTrailer]
AS

/*************************************************************************
 *
 * NAME:
 * dbo.[vSSRSRB_InactivityByTrailer]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View bASed on the old vttstmw_InactivityByTrailer
 
 *
**************************************************************************

Sample call


SELECT * FROM [vSSRSRB_InactivityByTrailer]

**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 * Recordset (view)
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 DW created view
 ***********************************************************/

Select LegHeader.mov_number as [Move Number],
	   IsNull(MaxAsgnNumber,-1) as MaxAsgnNumber,
       lgh_driver1 as Driver,
       lgh_tractor as Tractor,
	   [Origin Company] = 
					(
					SELECT  cmp_name
					FROM event WITH (NOLOCK) 
					JOIN Stops WITH (NOLOCK)
					ON event.stp_number = stops.stp_number		       
					and event.evt_number = MinEventNumber
					),
	  [Origin City State] = 
					(
					SELECT      
					(select City.cty_name + ', '+ City.cty_state from City where stp_city = City.cty_code)
					FROM event WITH (NOLOCK)
            	    JOIN Stops WITH (NOLOCK)
            			ON event.stp_number = stops.stp_number		       
					and event.evt_number = MinEventNumber
					),
	  lgh_startdate as 'Segment Start Date',
	  (Cast(Floor(Cast(lgh_startdate as float))as smalldatetime)) AS 'Segment Start Date Only',
	  lgh_enddate as 'Segment End Date',
	  (Cast(Floor(Cast(lgh_enddate as float))as smalldatetime)) AS 'Segment End Date Only',     
	  [Destination Company] = 
					(
					SELECT cmp_name
					FROM event (NOLOCK)
            	    JOIN Stops (NOLOCK)
						ON event.stp_number = stops.stp_number		       
						and event.evt_number = MaxEventNumber
					),
	  [Destination City State] = 
					(
					SELECT (select City.cty_name + ', '+ City.cty_state from City where stp_city = City.cty_code)
					FROM event (NOLOCK) 
            	    JOIN Stops (NOLOCK)
            			ON event.stp_number = stops.stp_number		       
						and event.evt_number = MaxEventNumber
             
					),
	  [Assignment End Date] = 
					(
					SELECT evt_enddate    
					FROM event (NOLOCK) 
            	    JOIN Stops (NOLOCK)
            			ON event.stp_number = stops.stp_number		       
						and event.evt_number = MaxEventNumber
					),
	  [Assignment End Date Only] = 
					(
					SELECT (Cast(Floor(Cast(evt_enddate as float))as smalldatetime))    
					FROM event (NOLOCK) 
            	    JOIN Stops (NOLOCK)
            			ON event.stp_number = stops.stp_number		       
						and event.evt_number = MaxEventNumber
					),
	  IsNull(DateDiff(day,	
					(
					SELECT evt_enddate    
					FROM event WITH (NOLOCK) 
            	    JOIN Stops WITH (NOLOCK)
						ON event.stp_number = stops.stp_number		       
						and event.evt_number = MaxEventNumber
					),GETDATE()),0)  as DaysInactive,
	 cast(trl_id as char(25)) as TRL,
     Case When lgh_enddate Is Null Then 'Y'
		  Else 'N'
		  End as NeverTakenLoadYN,
    vSSRSRB_TrailerProfile.*
From 
	(select 
        trl_type1 as TrlType1,
        trl_type2 as TrlType2,
        trl_type3 as TrlType3,
        trl_type4 as TrlType4,
	trl_id,
    trl_status,
	'MaxAsgnNumber'=
	(  select 
		Max(asgn_number) 
	from assetassignment c
	where 
		trl_id=asgn_id
		AND
		asgn_type = 'TRL'
		and 
		last_dne_evt_number = 
	(
	select 
		Max(last_dne_evt_number) 
	from assetassignment a
	where 
		trl_id=asgn_id
		AND
		asgn_type = 'TRL'
		and 
		asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b 
		where
     			(b.asgn_type = 'TRL'
			and 
			a.asgn_id = b.asgn_id)
		)
        )

	),

	'MaxEventNumber'=
	(
	select 
		Max(last_dne_evt_number) 
	from assetassignment a
	where 
		trl_id=asgn_id
		AND
		asgn_type = 'TRL'
		and 
		asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b 
		where
     			(b.asgn_type = 'TRL'
			and 
			a.asgn_id = b.asgn_id)
		)

	),

	'MinEventNumber'=
	(  select 
		Min(evt_number) 
	from assetassignment c
	where 
		trl_id=asgn_id
		AND
		asgn_type = 'TRL'
		and 
		last_dne_evt_number = 
	(
	select 
		Max(last_dne_evt_number) 
	from assetassignment a
	where 
		trl_id=asgn_id
		AND
		asgn_type = 'TRL'
		and 
		asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b 
		where
     			(b.asgn_type = 'TRL'
			and 
			a.asgn_id = b.asgn_id)
		)
        )
	)
From
	TrailerProfile WITH (NOLOCK) 
WHERE
	trl_id<>'UNKNOWN'	
	and
	(trl_retiredate > GETDATE() or trl_retiredate Is Null)
	) 
    As TempInactivity 
Left Join Assetassignment WITH (NOLOCK)  On TempInactivity.MaxAsgnNumber =Assetassignment.Asgn_number
Left Join LegHeader WITH (NOLOCK) On Assetassignment.lgh_number = LegHeader.lgh_number 
Left Join vSSRSRB_TrailerProfile WITH (NOLOCK) On TempInactivity.trl_id = [Trailer ID]

GO
GRANT SELECT ON  [dbo].[vSSRSRB_InactivityByTrailer] TO [public]
GO
