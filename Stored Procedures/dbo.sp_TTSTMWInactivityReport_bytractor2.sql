SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE                            procedure [dbo].[sp_TTSTMWInactivityReport_bytractor2](@searchdt datetime, @asgntype char(20),@assetstatuslist char(75),@inactivitybasedofflastloadedmove char(1))
as
--*************************************************************************
--Inactivity Report By Tractor Report is intended to show tractors 
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
SELECT @assetstatuslist= ',' + LTRIM(RTRIM(ISNULL(@assetstatuslist, ''))) + ','  
select 
	trc_number,
        trc_status,
        'MaxAsgnNumber'=
	(
	select 
		Max(asgn_number) 
	from assetassignment a
	where 
		trc_number=asgn_id
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
	TractorProfile
WHERE
	trc_number<>'UNKNOWN'	
	and
	trc_retiredate > GETDATE() 
	--<TTS!*!TMW><Begin><FeaturePack=Other>
       
       --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --And
       --(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + trc_branch + ',', @onlyBranches) > 0) 
       --)	
       --<TTS!*!TMW><End><FeaturePack=Euro>
Select 
	LegHeader.mov_number as Movement,
        trc_status,
        trc_number as AsgnID,
	IsNull(MaxAsgnNumber,-1) as MaxAsgnNumber,
        lgh_driver1 as Driver,
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
SET QUOTED_IDENTIFIER ON 


GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWInactivityReport_bytractor2] TO [public]
GO
