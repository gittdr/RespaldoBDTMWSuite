SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE                          PROCEDURE [dbo].[sp_TTSTMWmileagesummary]
			(		@frmdt datetime,
					@tdt datetime
			)
			
As 
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
Create table #TempMileageSummary
	(
	TravelMiles int,
	LoadedMiles int,
	EmptyMiles int
	)
Insert into #TempMileageSummary Values (1,1,1)
Update  #TempMileageSummary
	Set TravelMiles=
		(select IsNull(sum(IsNull(stp_lgh_mileage,0)),0) as TravelMiles
		 from   stops,legheader
		 	
		 where  stp_arrivaldate between @frmdt and @tdt
                        and
                        stp_status = 'DNE'
			and
			legheader.lgh_number = stops.lgh_number
			--<TTS!*!TMW><Begin><FeaturePack=Other>
       
       			--<TTS!*!TMW><End><FeaturePack=Other>
       			--<TTS!*!TMW><Begin><FeaturePack=Euro>
       			--And
       			--(
			--(@onlyBranches = 'ALL')
			--Or
			--(@onlyBranches <> 'ALL' And CHARINDEX(',' + lgh_booked_revtype1 + ',', @onlyBranches) > 0) 
       			--)	
       			--<TTS!*!TMW><End><FeaturePack=Euro>
		)
Update  #TempMileageSummary
	Set LoadedMiles=
		(select IsNull(sum(IsNull(stp_lgh_mileage,0)),0) as LoadedMiles  
		 from   stops,legheader
		 where  stp_arrivaldate between @frmdt and @tdt
                        and
                        stp_status = 'DNE'
			and
			stp_loadstatus = 'LD'
			and
			legheader.lgh_number = stops.lgh_number
			--<TTS!*!TMW><Begin><FeaturePack=Other>
       
       			--<TTS!*!TMW><End><FeaturePack=Other>
       			--<TTS!*!TMW><Begin><FeaturePack=Euro>
       			--And
       			--(
			--(@onlyBranches = 'ALL')
			--Or
			--(@onlyBranches <> 'ALL' And CHARINDEX(',' + lgh_booked_revtype1 + ',', @onlyBranches) > 0) 
       			--)	
       			--<TTS!*!TMW><End><FeaturePack=Euro>
		)
Update  #TempMileageSummary
	Set EmptyMiles=
		(select IsNull(sum(IsNull(stp_lgh_mileage,0)),0) as EmptyMiles 
		 from   stops,legheader
		 where  stp_arrivaldate between @frmdt and @tdt
                        and
                        stp_status = 'DNE'
			and
                        stp_loadstatus <> 'LD'
			and
			legheader.lgh_number = stops.lgh_number
			--<TTS!*!TMW><Begin><FeaturePack=Other>
       
       			--<TTS!*!TMW><End><FeaturePack=Other>
       			--<TTS!*!TMW><Begin><FeaturePack=Euro>
       			--And
       			--(
			--(@onlyBranches = 'ALL')
			--Or
			--(@onlyBranches <> 'ALL' And CHARINDEX(',' + lgh_booked_revtype1 + ',', @onlyBranches) > 0) 
       			--)	
       			--<TTS!*!TMW><End><FeaturePack=Euro>
		)
		
select * from #TempMileageSummary  
       
Drop table #TempMileageSummary


GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWmileagesummary] TO [public]
GO
