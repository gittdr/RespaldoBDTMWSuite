SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE                                                                                                                        procedure [dbo].[sp_TTSTMWInactivityReport_bydriver2](@searchdt datetime, @asgntype char(20),@assetstatuslist char(75), @inactivitybasedofflastloadedmove char(1))
as
Declare @OnlyBranches as varchar(255)
SELECT @assetstatuslist= ',' + LTRIM(RTRIM(ISNULL(@assetstatuslist, ''))) + ','  
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
If (@inactivitybasedofflastloadedmove = 'N') 
Begin
select 
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
		asgn_type = @asgntype
		and 
		asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b 
		where
     			(b.asgn_type = @asgntype
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
	--<TTS!*!TMW><Begin><FeaturePack=Other>
       
       --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --And
       --(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + mpp_branch + ',', @onlyBranches) > 0) 
       --)	
       --<TTS!*!TMW><End><FeaturePack=Euro>
Select 
	LegHeader.mov_number as Movement,
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
        Asgn_enddate,
	IsNull(DateDiff(day,Asgn_enddate,GETDATE()),0)  as DaysInactive
From 
	#Temp Left Join Assetassignment On #temp.MaxAsgnNumber =Assetassignment.Asgn_number
              Left Join LegHeader On Assetassignment.lgh_number = LegHeader.lgh_number 
where 
	DateDiff(day,Asgn_enddate,GETDATE()) > 0  or Asgn_enddate is NULL
order by DaysInactive DESC
Drop table #temp
End
Else
Begin
--**************************************************************
--Get the most recent trip segments where the last live unload took place
--that are at a started or completed status
--The intention is to figure the # days inactive off
--the LUL departure date
--This portion is not used to figure current location
select 
	mpp_id,
	IsNull(mpp_firstname,'') + ' ' + IsNull(mpp_lastname,'') as DriverName,
	mpp_status as DriverStatus,
	'MaxAsgnNumber'=
	(
	select 
		Max(asgn_number) 
	from assetassignment a,legheader
	where 
		mpp_id=asgn_id
		AND
		asgn_type = @asgntype
		and
		(a.asgn_status='CMP' or a.asgn_status = 'STD')
		and
		a.lgh_number = legheader.lgh_number
		and
		legheader.ord_hdrnumber <> 0
		and		
		asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b,legheader
		where
     			(b.asgn_type = @asgntype
			 and
			 (b.asgn_status='CMP' or b.asgn_status = 'STD')
			 and
			 a.asgn_id = b.asgn_id
			 and 
			 b.lgh_number = legheader.lgh_number
			 and
			 legheader.ord_hdrnumber <> 0			
			)
		)
	)
into #workingtemp
From
	ManpowerProfile
WHERE
	MPP_id<>'UNKNOWN'	
	and
	mpp_terminationdt > GETDATE()
	--<TTS!*!TMW><Begin><FeaturePack=Other>
       
       --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --And
       --(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + mpp_branch + ',', @onlyBranches) > 0) 
       --)	
       --<TTS!*!TMW><End><FeaturePack=Euro>	 
Create table #FinalTemp
	(
	UnloadMovement int,
	AsgnID varchar(200),
	DriverStatus varchar(200),
	DriverName char(255),
	MaxAsgnNumber int,
	UnloadTractor varchar(200),
	UnloadTrailer varchar(200),
	--OriginCompany char(255),
	--origin_city_state char(255),
	--FromDate datetime,
	UnloadDate datetime,
	UnloadCompany char(255),
	unload_city_state char (255),
	stp_loadstatus char(3),
	stp_status varchar(6),
	stp_event char(6),
	lgh_number int,
	ord_hdrnumber int,
	stp_number int,
	stp_departure_status varchar(6)
	)
Create index idx_departdate on #FinalTemp(UnloadDate)
Create index idx_ordhdrnumber on #FinalTemp(ord_hdrnumber)
Create index idx_leghdrnumber on #FinalTemp(lgh_number)
Create index idx_loadstatus on #FinalTemp(stp_loadstatus)
Create index idx_stopstatus on #FinalTemp(stp_status)
Create index idx_asgnid on #FinalTemp(AsgnID)
Create index idx_departurestatus on #FinalTemp(stp_departure_status)
Insert into #FinalTemp
Select 
	LegHeader.mov_number as Movement,
	mpp_id as AsgnID,
	DriverStatus,
	DriverName,
	IsNull(MaxAsgnNumber,-1) as MaxAsgnNumber,
        lgh_tractor as Tractor,
        lgh_primary_trailer as Trailer,
        --'OriginCompany' = (select Top 1 Company.cmp_name from Company where legheader.cmp_id_start = Company.cmp_id), 
	--'origin_city_state' = (select City.cty_name + ', '+ City.cty_state from City where legheader.lgh_startcity = City.cty_code),
        --lgh_startdate as FromDate,
	stp_departuredate as UnloadDate,
	'UnloadCompany' = (select Top 1 Company.cmp_name from Company where stops.cmp_id = Company.cmp_id),        
	'unload_city_state' = (select City.cty_name + ', '+ City.cty_state from City where stops.stp_city = City.cty_code),
	stp_loadstatus,
	stp_status,
	stp_event,
	legheader.lgh_number,
	legheader.ord_hdrnumber,
	stops.stp_number,
	stops.stp_departure_status
       
From 
	#workingtemp Left Join Assetassignment On #workingtemp.MaxAsgnNumber =Assetassignment.Asgn_number
              	     Left Join LegHeader On Assetassignment.lgh_number = LegHeader.lgh_number 
	      	     Left Join Stops On LegHeader.lgh_number = Stops.lgh_number
Select 
	UnloadMovement,
        AsgnID,
	DriverName,
	MaxAsgnNumber,
        UnloadTractor,
        UnloadTrailer,
        --OriginCompany, 
	--origin_city_state,
        --FromDate,
	UnloadDate,
        UnloadCompany,
        unload_city_state,
	lgh_number,
        DriverStatus
        
	--Get the the Last Actual Departure Date that was Loaded
	--This way if a few deadhead legs are cut at the end of the trip we can use the last actualized
	--departure date that was loaded(LUL typically) to calculate the days ofincativity rather then the 
	--last actualized deadhead date which would show the driver maybe a day or two
	--'DepartureDate' = (Select Max(Cast(c.ToDate as datetime)) from #FinalTemp c where c.lgh_number = a.lgh_number 
		--	   and a.AsgnID = c.AsgnID and stp_loadstatus = 'LD' and stp_status = 'DNE')
	--ToDate
into #FinalInactivity
From 
	#FinalTemp a
	      
where 
	(MaxAsgnNumber = -1 and DriverStatus <> 'PLN')
	OR
	(
		a.DriverStatus <> 'PLN'
		And
		
          	Not 
		(a.DriverStatus = 'USE'
		--and
	  	--a.ord_hdrnumber<> 0
	  	and
	  	(a.stp_event <> 'LUL')
		)
		and 
		(a.stp_departure_status = 'DNE' and a.stp_loadstatus = 'LD')                                                                              
         	
		
		And
		a.stp_number = (Select Max(b.stp_number) from   #FinalTemp b                                                                              
							 where	b.DriverStatus <> 'PLN'
								And
								b.AsgnID = a.AsgnID
								And
          							Not 
								(b.DriverStatus = 'USE'
								and
	  							a.ord_hdrnumber<> 0
	  							and
	  							(b.stp_event <> 'LUL')
								)
								and 
								(b.stp_departure_status = 'DNE' and b.stp_loadstatus = 'LD')  
								And	  
								Cast(b.UnloadDate as datetime)  = 
												(Select Max(Cast(c.UnloadDate as datetime)) from  #FinalTemp c 
							        				 					where  c.DriverStatus <> 'PLN'
																	       And
																	       b.AsgnID = c.AsgnID
                                                                                             	        				       And
          																       Not 
																	       (c.DriverStatus = 'USE'
																	       --and
	  																       --a.ord_hdrnumber<> 0
	  																       and
	  																       (c.stp_event <> 'LUL')
																	        )
																	       and 
																	      (c.stp_departure_status = 'DNE' and c.stp_loadstatus = 'LD')            
												)          											    
                                                              	
				)
	)
--Sel-ect mpp_id,mpp_status
  -- from manpowerprofile Left Join #FinalInActivity On manpowerprofile.mpp_id = asgnid
       --where asgnid Is Null
	--and MPP_id<>'UNKNOWN'	
	--and
	--mpp_terminationdt > GETDATE() 
--**************************************************************
--Get the most recent trip segments
--so we can get the most recent or current location of the resource
--maybe a location that followed the Live Unload
select 
	mpp_id,
	IsNull(mpp_firstname,'') + ' ' + IsNull(mpp_lastname,'') as DriverName,
	mpp_status as DriverStatus,
	'MaxAsgnNumber'=
	(
	select 
		Max(asgn_number) 
	from assetassignment a
	where 
		mpp_id=a.asgn_id
		AND
		a.asgn_type = @asgntype
		and
		(a.asgn_status='CMP' or a.asgn_status = 'STD')
		and		
		a.asgn_enddate = 
		(select 
			max(b.asgn_enddate) 
		from 
			assetassignment b
		where
     			(b.asgn_type = @asgntype
			 and
			 (b.asgn_status='CMP' or b.asgn_status = 'STD')
			 and
			 a.asgn_id = b.asgn_id
			 )
		)
	)
into #workingtemp2
From
	ManpowerProfile
WHERE
	MPP_id<>'UNKNOWN'	
	and
	mpp_terminationdt > GETDATE() 
	--<TTS!*!TMW><Begin><FeaturePack=Other>
       
       --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --And
       --(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + mpp_branch + ',', @onlyBranches) > 0) 
       --)	
       --<TTS!*!TMW><End><FeaturePack=Euro>
--select * from #workingmostrecentactivity
Create table #FinalLastActivity
	(
	CurrMovement int,
	AsgnID varchar(255),
	DriverStatus varchar(255),
	DriverName char(255),
	MaxAsgnNumber int,
	CurrTractor varchar(200),
	CurrTrailer varchar(200),
	--CurrCompany char(255),
	--curr_city_state char(255),
	--FromDate datetime,
	CurrDate datetime,
	CurrCompany char(255),
	curr_city_state char (255),
	stp_loadstatus char(3),
	stp_status varchar(6),
	stp_event char(6),
	lgh_number int,
	ord_hdrnumber int,
	stp_number int
	)
Create index idx_departdate2 on #FinalLastActivity(CurrDate)
Create index idx_ordhdrnumber2 on #FinalLastActivity(ord_hdrnumber)
Create index idx_leghdrnumber2 on #FinalLastActivity(lgh_number)
Create index idx_loadstatus2 on #FinalLastActivity(stp_loadstatus)
Create index idx_stopstatus2 on #FinalLastActivity(stp_status)
Create index idx_asgnid2 on #FinalLastActivity(AsgnID)
Insert into #FinalLastActivity
Select 
	LegHeader.mov_number as Movement,
	mpp_id as AsgnID,
	DriverStatus,
	DriverName,
	IsNull(MaxAsgnNumber,-1) as MaxAsgnNumber,
        lgh_tractor as CurrTractor,
        lgh_primary_trailer as CurrTrailer,
        --'OriginCompany' = (select Top 1 Company.cmp_name from Company where legheader.cmp_id_start = Company.cmp_id), 
	--'origin_city_state' = (select City.cty_name + ', '+ City.cty_state from City where legheader.lgh_startcity = City.cty_code),
        --lgh_startdate as FromDate,
	stp_departuredate as CurrDate,
	'CurrCompany' = (select Top 1 Company.cmp_name from Company where stops.cmp_id = Company.cmp_id),        
	'curr_city_state' = (select City.cty_name + ', '+ City.cty_state from City where stops.stp_city = City.cty_code),
	stp_loadstatus,
	stp_status,
	stp_event,
	legheader.lgh_number,
	legheader.ord_hdrnumber,
	stops.stp_number
       
From 
	#workingtemp2 Left Join Assetassignment On #workingtemp2.MaxAsgnNumber = Assetassignment.Asgn_number
              	     Left Join LegHeader On Assetassignment.lgh_number = LegHeader.lgh_number 
	      	     Left Join Stops On LegHeader.lgh_number = Stops.lgh_number
Select 
	CurrMovement,
        AsgnID,
	DriverStatus,
	DriverName,
	MaxAsgnNumber,
        CurrTractor,
        CurrTrailer,
        --OriginCompany, 
	--origin_city_state,
        --FromDate,
	CurrDate,
        CurrCompany,
        curr_city_state,
	lgh_number
        
        
into #FinalMostRecentInactivity
From 
	#FinalLastActivity a
	      
where (a.stp_status = 'DNE') and a.stp_number = (Select Max(b.stp_number) from #FinalLastActivity b                                                                              
							where a.AsgnID = b.AsgnID
                                                              and 
							      b.stp_status = 'DNE' and Cast(b.CurrDate as datetime)  = 
														(Select Max(Cast(c.CurrDate as datetime)) from  #FinalLastActivity c 
							        						 where b.AsgnID = c.AsgnID
                                                                                             			 and 
														 c.stp_status = 'DNE'
														)
						)
Select 
	#FinalInactivity.AsgnID,
	#FinalMostRecentInactivity.CurrMovement,
        #FinalMostRecentInactivity.CurrTractor,
        #FinalMostRecentInactivity.CurrTrailer,
        --#FinalMostRecentInactivity.OriginCompany as CurrentMostRecentOriginCompany, 
	--#FinalMostRecentInactivity.origin_city_state as CurrentMostRecentOriginCityState,
        --#FinalMostRecentInactivity.FromDate as CurrentMostRecentFromDate,
	#FinalMostRecentInactivity.CurrDate, 
        #FinalMostRecentInactivity.CurrCompany,
        #FinalMostRecentInactivity.curr_city_state,
       -- #FinalMostRecentInactivity.ToDate as CurrentMostRecentTripEndDate,
	IsNull(DateDiff(day,#FinalInactivity.UnloadDate,GETDATE()),0) as DaysInactive,
	#FinalInactivity.DriverName,
	#FinalInactivity.MaxAsgnNumber,
	#FinalInactivity.UnloadMovement,
        #FinalInactivity.UnloadTractor,
        #FinalInactivity.UnloadTrailer,
        --#FinalInactivity.OriginCompany,  
	--#FinalInactivity.origin_city_state, 
        --#FinalInactivity.FromDate, 
	#FinalInactivity.UnloadDate,
        #FinalInactivity.UnloadCompany,
        #FinalInactivity.unload_city_state,
        #FinalInactivity.UnloadDate as Asgn_enddate,
	#FinalInactivity.DriverStatus	
From 
	#FinalInactivity Left Join #FinalMostRecentInactivity On #FinalInactivity.AsgnId = #FinalMostRecentInactivity.AsgnId
	  --#FinalMostRecentInactivity    
order by DaysInactive DESC                                                                                              
                       
 
End


GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWInactivityReport_bydriver2] TO [public]
GO
