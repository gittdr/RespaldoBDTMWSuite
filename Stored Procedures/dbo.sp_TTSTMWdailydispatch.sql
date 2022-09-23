SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




















CREATE                procedure [dbo].[sp_TTSTMWdailydispatch]
	(
	@revtype1 varchar(120),
	@revtype2 varchar(120),
        @revtype3 varchar(120),
        @revtype4 varchar(120),
	@mpptype1 varchar(120),
	@mpptype2 varchar(120),
        @mpptype3 varchar(120),
        @mpptype4 varchar(120)
	)
as 

--********************************************************************
--Daily Dispatch Report is intended to show current activity of 
--your resources that are active. (Currently this report is showing activity for
--drivers only). This will include all stops on the current Trip Segment
--and show if they are completed or open. 
--********************************************************************

--Revision History
--Added Branch Code Ver 5.4 LBK

Declare @OnlyBranches as varchar(255)

SELECT @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, ''))) + ','
SELECT @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, ''))) + ',' 
SELECT @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, ''))) + ','  

SELECT @mpptype1 = ',' + LTRIM(RTRIM(ISNULL(@mpptype1, ''))) + ',' 
SELECT @mpptype2 = ',' + LTRIM(RTRIM(ISNULL(@mpptype2, ''))) + ','
SELECT @mpptype3 = ',' + LTRIM(RTRIM(ISNULL(@mpptype3, ''))) + ',' 
SELECT @mpptype4 = ',' + LTRIM(RTRIM(ISNULL(@mpptype4, ''))) + ','  

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


/**Get the latest assigned trips legheader numbers for drivers that are Dispatched, Started, or Delivered*/
select lgh_number
into #worklist
from assetassignment a
where asgn_type = 'DRV' and (asgn_status='CMP' or asgn_status = 'STD') 
And asgn_enddate = (select max(b.asgn_enddate) from assetassignment b where
     (b.asgn_type = 'DRV' and a.asgn_id = b.asgn_id)
     and (b.asgn_status='CMP' or b.asgn_status = 'STD')) 
order by asgn_id 	


--Get legheader,order,stop,and event information for those driver trips

Select 
	
	EndSegmentCity.cty_nmstct Destination,
	
	legheader.lgh_driver1 DrvID,
--		convert(varchar(8),legheader.lgh_Enddate,1) + ' ' +
--		convert(varchar(5),legheader.lgh_Enddate,108) 
--	SegmentEndDt, 
	--convert(varchar(8),stops.stp_arrivaldate,1) + ' ' +
	--convert(varchar(5),stops.stp_arrivaldate,108) StopArrivalDt,
	stops.stp_arrivaldate StopArrivalDt,

	Stops.stp_status Status,


	stops.stp_event Event,
	StopCity.cty_nmstct StopCity,

	legheader.lgh_tractor Tractor,
	evt_trailer1 Trailer,
	legheader.mov_number MoveNum,
	lgh_class1 RevClass1,
	

	isNull(ord_remark,'') Remarks,



		(Case when legheader.lgh_driver2='UNKNOWN' Then ''
	 	else legheader.lgh_driver2
		end ) 
	Driver2,

	legheader.ord_hdrnumber OrdNum,
	convert(varchar(2),stops.stp_mfh_sequence) Seq,
	(case 
	when stops.cmp_id is Null then ''
	when stops.cmp_id='UNKNOWN' then ''	
	else cmp_id
	end)	CompanyID, 

	--stops.cmp_id,
	(Case 
	when cmp_name is null then ''
	when cmp_name='UNKNOWN' then ''
	else cmp_name
	end)	CompanyName ,
        lgh_class1,
        lgh_class2,
        lgh_class3,
        lgh_class4
	--CompanyName= (Select c.cmp_name from company c where C.cmp_id=stops.cmp_iD),

	
into #worklist2	
from 
	Legheader 
		  Inner Join #worklist On #worklist.lgh_number = legheader.lgh_number
		  Inner Join stops On Stops.lgh_number=legheader.lgh_number
		  Inner Join event On stops.stp_number=event.stp_number
		  Inner Join city EndSegmentCity On EndSegmentCity.cty_code = lgh_EndCity
		  Inner Join city StopCity On StopCity.cty_code=stops.stp_city
		  Inner Join orderheader On legheader.ord_hdrnumber = orderheader.ord_hdrnumber
		 
where 
legheader.lgh_driver1<> 'UNKNOWN'	
and
evt_sequence=1
order by 
Lgh_driver1,
legheader.mov_number,
stops.stp_mfh_sequence,
lgh_startdate
	
--Pull all current driver trips plus 
--any drivers that are active but are not assigned to any trips
--should mean that there isn't a dispatched legheader or 
--entry in assetassignment table for that driver or
--at least one that was never dispatched
Select
mpp_lastfirst Name,
IsNull(Destination,'No Assignment Found'),
mpp_id as DrvID,
StopArrivalDt,
Status,

Event,
StopCity,
Tractor,
Trailer,
MoveNum,
RevClass1,
convert(decimal(5,1),isNull(mpp_hours1,0.0)) HrsAvlToday,
convert(decimal(5,1),isNull(mpp_hours2,0.0)) HrsTomorrow,
convert(varchar(8),mpp_last_log_date,1) HrsLastUpdated,
Remarks,
Driver2,
OrdNum,
Seq,
CompanyID,
CompanyName
from #worklist2
	Right Join manpowerprofile On mpp_id=#worklist2.DrvID
Where
mpp_terminationdt > GETDATE() 
and 
(@mpptype1 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type1 + ',', @mpptype1) > 0)
and
(@mpptype2 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type2 + ',', @mpptype2) > 0) 
and
(@mpptype3 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type3 + ',', @mpptype3) > 0) 
and
(@mpptype4 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type4 + ',', @mpptype4) > 0) 
and
mpp_id<>'UNKNOWN'
and
(@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0) 
AND 
(@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0)
And
(@revtype3 = ',,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0)
And
(@revtype4 = ',,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0)
--<TTS!*!TMW><Begin><FeaturePack=Other>
       
--<TTS!*!TMW><End><FeaturePack=Other>
--<TTS!*!TMW><Begin><FeaturePack=Euro>
--And
--(
--(@onlyBranches = 'ALL')
--Or
--(@onlyBranches <> 'ALL' And CHARINDEX(',' + manpowerprofile.mpp_branch + ',', @onlyBranches) > 0) 
--)	
--<TTS!*!TMW><End><FeaturePack=Euro>





















GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWdailydispatch] TO [public]
GO
