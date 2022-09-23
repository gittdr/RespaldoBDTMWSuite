SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






CREATE       View [dbo].[vTTSTMW_InactivityByTrailer]

As

Select 
	Top 100 percent
	LegHeader.mov_number as Movement,
	IsNull(MaxAsgnNumber,-1) as MaxAsgnNumber,
        lgh_driver1 as Driver,
        lgh_tractor as Tractor,
        
	[Origin Company] = 
					(
	SELECT      
		    cmp_name
		    
	FROM        event (NOLOCK), 
            	    Stops (NOLOCK)
		      
	Where   
             event.stp_number = stops.stp_number		       
	     and
	     event.evt_number = MinEventNumber
             
	),

		
	[Origin City State] = 
					(
	SELECT      
		    (select City.cty_name + ', '+ City.cty_state from City where stp_city = City.cty_code)
			

	FROM        event (NOLOCK), 
            	    Stops (NOLOCK)
            	    
		      
	Where   
             event.stp_number = stops.stp_number		       
	     and
	     event.evt_number = MinEventNumber
             
	),

        lgh_startdate as 'Segment Start Date',
	lgh_enddate as 'Segment End Date',
        
	[Destination Company] = 
					(
	SELECT      
		    cmp_name
		    
	FROM        event (NOLOCK), 
            	    Stops (NOLOCK)
		      
	Where   
             event.stp_number = stops.stp_number		       
	     and
	     event.evt_number = MaxEventNumber
             
	),
	  
	[Destination City State] = 
					(
	SELECT      
		    (select City.cty_name + ', '+ City.cty_state from City where stp_city = City.cty_code)
			

	FROM        event (NOLOCK), 
            	    Stops (NOLOCK)
            	    
		      
	Where   
             event.stp_number = stops.stp_number		       
	     and
	     event.evt_number = MaxEventNumber
             
	),


	[Assignment End Date] = 
					(
	SELECT      
		evt_enddate    
		
	FROM        event (NOLOCK), 
            	    Stops (NOLOCK)
            	    
		      
	Where   
             event.stp_number = stops.stp_number		       
	     and
	     event.evt_number = MaxEventNumber
             
	),
	IsNull(DateDiff(day,	(
	SELECT      
		evt_enddate    
		
	FROM        event (NOLOCK), 
            	    Stops (NOLOCK)
            	    
		      
	Where   
             event.stp_number = stops.stp_number		       
	     and
	     event.evt_number = MaxEventNumber
             
	),GETDATE()),0)  as DaysInactive,

	cast(trl_id as char(25)) as TRL,
    	Case When lgh_enddate Is Null Then
		'Y'
	Else
		'N'
	End as NeverTakenLoadYN,
    vTTSTMW_TrailerProfile.*
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
	TrailerProfile
WHERE
	trl_id<>'UNKNOWN'	
	and
	(trl_retiredate > GETDATE() or trl_retiredate Is Null)
	) 
         As TempInactivity Left Join Assetassignment On TempInactivity.MaxAsgnNumber =Assetassignment.Asgn_number
              	           Left Join LegHeader On Assetassignment.lgh_number = LegHeader.lgh_number 
			   Left Join vTTSTMW_TrailerProfile On TempInactivity.trl_id = [Trailer ID]
--where 
	---DateDiff(day,Asgn_enddate,GETDATE()) >= 0  or Asgn_enddate is NULL

order by DaysInactive desc
















GO
GRANT SELECT ON  [dbo].[vTTSTMW_InactivityByTrailer] TO [public]
GO
