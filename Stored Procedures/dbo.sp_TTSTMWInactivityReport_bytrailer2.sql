SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE                      procedure [dbo].[sp_TTSTMWInactivityReport_bytrailer2](@searchdt datetime, @asgntype char(20),@assetstatuslist char(75),@inactivitybasedofflastloadedmove char(1))
as
--*************************************************************************
--Inactivity Report By Driver Report is intended to show trailers
--sitting idle or are in a inactive mode from a given date forward.
--*************************************************************************
Declare @OnlyBranches as varchar(255)
--<TTS!*!TMW><Begin><FeaturePack=Other>
--<TTS!*!TMW><End><FeaturePack=Other>
--<TTS!*!TMW><Begin><FeaturePack=Euro>
--Set @OnlyBranches = ',' + ISNULL( (Select usr_booking_terminal from ttsusers where usr_userid= user),'UNK') + ','
--If (Select count(*) from ttsusers where usr_userid= user and (usr_supervisor='Y' or usr_sysadmin='Y')) > 0 or user = 'dbo' 
--
--BEGIN
--
--Set @onlyBranches = 'ALL'
--
--END
--<TTS!*!TMW><End><FeaturePack=Euro>
select 
	trl_number,
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

into
#temp
From
	TrailerProfile
WHERE
	trl_number<>'UNKNOWN'	
	and
	trl_retiredate > GETDATE() 
	--<TTS!*!TMW><Begin><FeaturePack=Other>
       
       --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --And
       --(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + trl_branch + ',', @onlyBranches) > 0) 
       --)	
       --<TTS!*!TMW><End><FeaturePack=Euro>
Select 
	LegHeader.mov_number as Movement,
        trl_status,
        trl_number as AsgnID,
	IsNull(MaxAsgnNumber,-1) as MaxAsgnNumber,
        lgh_driver1 as Driver,
        lgh_tractor as Tractor,
	[OriginCompany] = 
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

		
	[origin_city_state] = 
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
	
	lgh_startdate as FromDate,
	[ToDate] = 
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
        
	[DestCompany] = 
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
	         


	[dest_city_state] = 
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


	[Asgn_enddate] = 
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
             
	),GETDATE()),0)  as DaysInactive

From 
	#Temp Left Join Assetassignment On #temp.MaxAsgnNumber =Assetassignment.Asgn_number
              Left Join LegHeader On Assetassignment.lgh_number = LegHeader.lgh_number 
where 
	DateDiff(day,Asgn_enddate,GETDATE()) > 0  or Asgn_enddate is NULL
order by DaysInactive DESC
Drop table #temp
SET QUOTED_IDENTIFIER ON 



GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWInactivityReport_bytrailer2] TO [public]
GO
