SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


























--sp_TTSTMWTrailerLocator2 '','','','','','','','','',''

CREATE                    procedure [dbo].[sp_TTSTMWTrailerLocator2](
				   @trltype1 varchar(120),
				   @trltype2 varchar(120),
				   @trltype3 varchar(120),
				   @trltype4 varchar(120),
				   @trlstatus varchar(120),
				   @loadstatus varchar(120),
  				   @destcomp varchar(30),
				   @deststate varchar(30),
				   @currcomp varchar(30),
				   @currstate varchar(30))

as

--*************************************************************************
--Trailer Locator Report 
--shows the current location(last actualized stop) 
--of a trailer on a trip
--as well as the origin and destination
--*************************************************************************

--Revision History
--1. Added Branch Code Ver 5.4 LBK 

Declare @OnlyBranches as varchar(255)
Declare @loadrestrict as varchar(50)
SELECT @trltype1 = ',' + LTRIM(RTRIM(ISNULL(@trltype1, ''))) + ','
SELECT @trltype2 = ',' + LTRIM(RTRIM(ISNULL(@trltype2, ''))) + ','
SELECT @trltype3 = ',' + LTRIM(RTRIM(ISNULL(@trltype3, ''))) + ',' 
SELECT @trltype4 = ',' + LTRIM(RTRIM(ISNULL(@trltype4, ''))) + ','

SELECT @trlstatus = ',' + LTRIM(RTRIM(ISNULL(@trlstatus, ''))) + ',' 

SELECT @loadstatus = ',' + LTRIM(RTRIM(ISNULL(@loadstatus, ''))) + ',' 

SELECT @destcomp = ',' + LTRIM(RTRIM(ISNULL(@destcomp, ''))) + ',' 

SELECT @deststate = ',' + LTRIM(RTRIM(ISNULL(@deststate, ''))) + ','

SELECT @currcomp = ',' + LTRIM(RTRIM(ISNULL(@currcomp, ''))) + ','

SELECT @currstate = ',' + LTRIM(RTRIM(ISNULL(@currstate, ''))) + ','

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


--Get the last acualized event#
--based on the highest Assignment End Date
select last_dne_evt_number as EventNumber,IsNull(asgn_id,' ') as Trailer,asgn_enddate as AssgnEndDate,asgn_type,lgh_number,asgn_status,evt_number as MinEventNumber,last_evt_number
into #temptable
from assetassignment a
where asgn_type = 'TRL' and (asgn_status='CMP' or asgn_status = 'STD') 
And asgn_enddate = (select max(b.asgn_enddate) from assetassignment b where
     (b.asgn_type = 'TRL' and a.asgn_id = b.asgn_id)
     and (b.asgn_status='CMP' or b.asgn_status = 'STD') and (b.last_dne_evt_number is Not Null
   or b.last_dne_evt_number <> 0)
     ) 
--order by asgn_id 

Union

select last_dne_evt_number as EventNumber,IsNull(asgn_id,' ') as Trailer,asgn_enddate as AssgnEndDate,asgn_type,lgh_number,asgn_status,evt_number as MinEventNumber,last_evt_number
--into #temptable
from assetassignment a
where asgn_type = 'TRL' and (asgn_status = 'PLN') 
And asgn_enddate > (select max(b.asgn_enddate) from assetassignment b where
     (b.asgn_type = 'TRL' and a.asgn_id = b.asgn_id)
     and (b.asgn_status='CMP' or b.asgn_status = 'STD') and (b.last_dne_evt_number is Not Null
   or b.last_dne_evt_number <> 0)
     ) 
--order by asgn_id 


--Get's the highest event# if there is two dates that are the same for the trailer
--this will be rare in most cases
select EventNumber,Trailer,AssgnEndDate,asgn_type,lgh_number,asgn_status,MinEventNumber,last_evt_number
 into #worklist
 from #temptable a
   where EventNumber = ( select max(b.EventNumber) from #temptable b where a.Trailer= b.Trailer and b.asgn_type = 'TRL' and (b.asgn_status = 'CMP' or b.asgn_status = 'STD'))
 
Union

select EventNumber,Trailer,AssgnEndDate,asgn_type,lgh_number,asgn_status,MinEventNumber,last_evt_number
 --into #worklist
 from #temptable a
   where (a.asgn_status = 'PLN')

--select * from #worklist

/** Get stop,lgh_hdr,trailerprofile info for each resource
including any trailers that don't have an assignment 
but are active **/
SELECT trailerprofile.trl_id as [trl_number], 
stops.stp_loadstatus AS [loadstatus], 

event.evt_driver1 AS [driver1], 
IsNull(company.cmp_name,'No Trailer Assignments Found') AS [current_company], 
city.cty_name AS [current_city], 
city.cty_state AS [current_state], 
stops.stp_arrivaldate AS [stp_arrivaldate],
stops.stp_departuredate as [stp_departuredate],
event.evt_eventcode AS [last_event], 
event.evt_startdate As [evt_startdate], 
event.evt_enddate As [evt_enddate],
event.evt_number,

[origin_company] = 
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


[origin_city] = (
	SELECT      
		    (select City.cty_name from City (NOLOCK) where stp_city = City.cty_code)
			

	FROM        event (NOLOCK), 
            	    Stops (NOLOCK)
            	    
		      
	Where   
             event.stp_number = stops.stp_number		       
	     and
	     event.evt_number = MinEventNumber
             
	),


[origin_state] = (
	SELECT      
		    stp_state
			

	FROM        event (NOLOCK), 
            	    Stops (NOLOCK)
            	    
		      
	Where   
             event.stp_number = stops.stp_number		       
	     and
	     event.evt_number = MinEventNumber
             
	), 
legheader.mov_number AS [mov_number], 

[dest_company] = 
					(
	SELECT      
		    cmp_name
		    
	FROM        event (NOLOCK), 
            	    Stops (NOLOCK)
		      
	Where   
             event.stp_number = stops.stp_number		       
	     and
	     event.evt_number = last_evt_number
             
	),


[dest_city] = 
					(
	SELECT      
		    (select City.cty_name from City (NOLOCK) where stp_city = City.cty_code)
			

	FROM        event (NOLOCK), 
            	    Stops (NOLOCK)
            	    
		      
	Where   
             event.stp_number = stops.stp_number		       
	     and
	     event.evt_number = last_evt_number
             
	),

[dest_state] = (
	SELECT      
		    stp_state
			

	FROM        event (NOLOCK), 
            	    Stops (NOLOCK)
            	    
		      
	Where   
             event.stp_number = stops.stp_number		       
	     and
	     event.evt_number = last_evt_number
             
	),

legheader.lgh_enddate_arrival AS [schdarrive_date], 
Case When asgn_status = 'PLN' then
	asgn_status
Else
	trailerprofile.trl_status
End as trl_status,
datediff(day,event.evt_enddate,getdate()) as [Days Since Last Move]
FROM ((((((((#worklist INNER JOIN legheader ON #worklist.lgh_number = legheader.lgh_number)
		       Left  JOIN event On #worklist.EventNumber = event.evt_number) 
		       Left JOIN stops On event.stp_number = stops.stp_number)		       
		       Left JOIN city ON stops.stp_city = city.cty_code) 
		       Left JOIN company ON stops.cmp_id = company.cmp_id) 
		       Left JOIN company AS company_1 ON legheader.cmp_id_start = company_1.cmp_id) 
		       Left JOIN company AS company_2 ON legheader.cmp_id_end = company_2.cmp_id) 
		       Left JOIN city AS city_1 ON legheader.lgh_startcity = city_1.cty_code) 
		       Left JOIN city AS city_2 ON legheader.lgh_endcity = city_2.cty_code 
		       Right JOIN trailerprofile ON #worklist.Trailer = trailerprofile.trl_id
Where 
      (trailerprofile.trl_retiredate > GetDate() or trailerprofile.trl_retiredate Is Null)
      and (@trltype1 = ',,' OR CHARINDEX(',' + trailerprofile.trl_type1 + ',', @trltype1) > 0)
      and (@trltype2 = ',,' OR CHARINDEX(',' + trailerprofile.trl_type2 + ',', @trltype2) > 0)
      and (@trltype3 = ',,' OR CHARINDEX(',' + trailerprofile.trl_type3 + ',', @trltype3) > 0)
      and (@trltype4 = ',,' OR CHARINDEX(',' + trailerprofile.trl_type4 + ',', @trltype4) > 0)
      and (@trlstatus  = ',,' OR CHARINDEX(',' + trl_status + ',', @trlstatus) > 0) 
      and (@destcomp=  ',,' OR CHARINDEX(',' + legheader.cmp_id_end + ',', @destcomp) > 0)
      and (@deststate=  ',,' OR CHARINDEX(',' + legheader.lgh_endstate + ',', @deststate) > 0)
      and (@currcomp=  ',,' OR CHARINDEX(',' + stops.cmp_id + ',', @currcomp) > 0)
      and (@currstate=  ',,' OR CHARINDEX(',' + stops.stp_state + ',', @currstate) > 0)
      and (@loadstatus=  ',,' OR CHARINDEX(',' + stops.stp_loadstatus + ',', @loadstatus) > 0)  
      --<TTS!*!TMW><Begin><FeaturePack=Other>
       
      --<TTS!*!TMW><End><FeaturePack=Other>
      --<TTS!*!TMW><Begin><FeaturePack=Euro>
      --And
      --(
      --(@onlyBranches = 'ALL')
      --Or
      --(@onlyBranches <> 'ALL' And CHARINDEX(',' + trailerprofile.trl_branch + ',', @onlyBranches) > 0) 
      --)	
      --<TTS!*!TMW><End><FeaturePack=Euro>

Order by trailerprofile.trl_id,lgh_enddate_arrival
























































GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWTrailerLocator2] TO [public]
GO
