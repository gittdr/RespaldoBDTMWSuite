SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[rptFlowInboundDetail]    
 (@HoursNearExpiration float = 24,    
 @IncludeLocalYN Char(1) ='Y') -- Previously Local was included in regional always - now optional - 7/11/02 -dm    
as 
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/26/2007.01 ? PTS40189 - JGUO ? convert old style outer join syntax to ansi outer join syntax. Change nolock to new syntax
 *
 **/
   
--Drop Table #temp    
Declare @enddate datetime    
Set @enddate = (Select convert(Datetime, 4 + Floor(Convert(float,(Getdate())))))    
    
Select     
 lgh_number Leg#,    
 legheader.mov_number Move#,    
    
 lgh_driver1 Driver,    
 lgh_instatus InStatus,    
    
 lgh_outstatus OutStatus,    
    
    
 convert(varchar(8),lgh_enddate,1)     
 --+      
 --convert(varchar(5),lgh_enddate,8)     
 AvlForAssignmentDate,    
 City.cty_nmstct City,    
 lgh_endregion1 Region,    
    
 lgh_class2 NetWorkType,    
 manpowerProfile.mpp_type3 DriverType3,    
 LabMpp3.Name DriverType3Name,    
     
    
 convert(varchar(5),lgh_startdate,1) + ' ' +      
 convert(varchar(5),lgh_startdate,8) + ' '       
    
 LegStartDate,    
    
 mpp_hours1 Hrs1,    
 mpp_hours2 Hrs2,    
 mpp_hours3 Hrs3,    
 manpowerProfile.mpp_teamleader TeamLeader,     
 manpowerProfile.mpp_fleet Fleet,    
 mpp_lastfirst Name,                                     
 mpp_dailyhrsest  DailyHrsEst,                                          
 mpp_weeklyhrsest WeeklyHrsEst,      
 mpp_gps_desc     GPS,                                 
 mpp_gps_date     GPSDate,    
 convert(VaRchar(3),'') NetworkTypeFigureOut,    
 lgh_enddate  lgh_endateForSort,    
 mpp_exp1_date,    
 convert(DateTime,'12/31/2049') Completes_mpp_exp1_date,    
 Convert(varchar(8),'') mpp_exp1_code,    
 Convert(varchar(20),'') mpp_exp1_Name,    
 0 mpp_exp1_KEY,     
 --Trc_exp1_date,    
 abs(Datediff(hh, mpp_exp1_date, lgh_enddate) ) HrsDifTwixtExp,    
    
 mpp_exp2_date,    
 convert(DateTime,'12/31/2049') Completes_mpp_exp2_date,    
 Convert(varchar(8),'') mpp_exp2_code,    
 Convert(varchar(20),'') mpp_exp2_Name,    
 0 mpp_exp2_KEY,    
 LegMiles =ISNULL(    
    (Select sum(ISNULL(stp_lgh_mileage,0)) from stops with(nolock) where stops.lgh_number=Legheader.lgh_number)    
  ,0),    
 tractorprofile.trc_number    
    
     
    
Into #Temp    
From    
 Legheader with(nolock),  --pts40189 outer join conversion
 manpowerProfile with(nolock) LEFT OUTER JOIN labelfile LabMpp3 with(nolock) ON (manpowerProfile.mpp_type3 = LabMpp3.abbr and LabMpp3.labeldefinition='DrvType3'),    
 city with(nolock),    
 TractorProfile with(nolock)    
where    
 Legheader.lgh_active='Y'    
 and    
 Legheader.lgh_endcity=city.cty_code    
 and    
 --lgh_driver1<>'UNKNOWN'    
 --and    
 manpowerProfile.mpp_id=lgh_driver1    
 and     
 TractorProfile.trc_number=legheader.lgh_tractor    
 and     
 lgh_enddate<=@enddate     
 and    
 lgh_instatus not in ('PLN','DSP')    
 --and lgh_driver1='17320'    
order by lgh_driver1,lgh_startdate    
    
    
Update #Temp    
 Set NetworkTypeFigureOut ='(N)'    
Where NetWorkType='NET'    
--Select * from #TEMP    
Update #Temp    
 Set NetworkTypeFigureOut ='(N)'    
Where NetWorkType='TM'    
    
    
Update #Temp    
 Set NetworkTypeFigureOut ='(R)'    
Where NetWorkType='REG'    
    
IF @IncludeLocalYN ='N'    
BEGIN    
 DELETE #temp    
 WHERE NetWorkType='LOC'    
END    
Update #Temp    
 Set NetworkTypeFigureOut ='(R)'    
Where NetWorkType='LOC'    
    
Update #Temp    
 Set NetworkTypeFigureOut ='(W)'    
Where NetWorkType='WAS'    
    
    
Update #Temp    
 Set NetworkTypeFigureOut ='(R)'    
Where NetWorkType='NALR'    
    
    
    
Update #Temp    
 Set NetworkTypeFigureOut ='(Z)'    
Where NetWorkType='NAL'    
    
Update #Temp    
 Set NetworkTypeFigureOut ='(R)'    
Where NetWorkType='DED'    
    
    
--Missing from RevClass so take from DriverType3    
Update #Temp    
 Set NetworkTypeFigureOut ='(N)'    
--Where NetWorkType=''    
--AND       -- S-network            SN    
where    
DriverType3 IN ('SN','NNN','NALN') -- S-NoNalco Network    NNN    
      -- tM    
     --Team-NoNalco         TNN    
--  Flag as (N) if file maintenance shows drvr type 3 as SN,    
--NNN,NALN -John Van Langendon    
    
    
    
    
--Update #temp     
-- set NetworkTypeFigureOut='(N)'    
--where DriverType3    
    
Update #Temp    
 Set NetworkTypeFigureOut ='(R)'  --S-regional    
Where     
--NetWorkType=''    --S-dedicated    
--AND       --S-Ded Nalco Reg      NALR    
DriverType3 in ('SR' ,'SD','NALR',     
'NNL',      --S-NoNalco Local      NNL    
'NNR'      --S-NoNalco Regional   NNR    
,'SR','SL','DS','NNR','NNL','NALR','SS' --John Van Langendon 6/20/2002    
    
 )     
    
IF @IncludeLocalYN ='N'    
BEGIN    
 DELETE #temp    
 WHERE DriverType3 in ('NNL','SL')    
END    
    
    
    
Update #Temp    
 Set NetworkTypeFigureOut ='(W)'  --S- Waste Drv         WST    
Where NetWorkType=''    --S-NoNalco Waste      NNW    
AND       --S-Ded Nalco Reg      NALR    
DriverType3 in ('WST' ,'NNW'    
      --S-NoNalco Local      NNL    
      --S-NoNalco Regional   NNR    
 ) --SELECT * from labelfile where labeldefinition='DrvType3'    
    
Update #Temp    
 Set NetworkTypeFigureOut ='(Z)'      
Where NetWorkType=''        
AND           
DriverType3 in ('NALN') --S-Ded Nalco Net      NALN    
    
    
    
-- Set everything else to question mark    
Update #Temp    
 Set NetworkTypeFigureOut ='(?)'      
Where NetworkTypeFigureOut=''    
    
-- Find end date of Expiration    
Update #Temp    
Set mpp_exp1_KEY=    
 (    
  Select     
   Min(exp_Key)    
  From     
   Expiration  with(nolock)   
  where    
   exp_idtype='DRV'    
   AND    
   exp_id= #temp.Driver    
   and    
   exp_priority=1    
   and    
   exp_completed='N'    
   AND    
   exp_expirationdate=mpp_exp1_date    
    
  )    
 WHERE mpp_exp1_date is Not Null    
    
    
Update #Temp    
 Set Completes_mpp_exp1_date =    
  (    
  Select     
   exp_compldate    
  From     
   Expiration  with(nolock)    
  where    
   exp_key = mpp_exp1_KEY    
   --exp_idtype='DRV'    
   --AND    
   --exp_id= #temp.Driver    
   --and    
   --exp_priority=1    
   --and    
   --exp_completed='N'    
   --AND    
   --exp_expirationdate=mpp_exp1_date    
    
  )    
 WHERE --mpp_exp1_date is Not Null    
  mpp_exp1_KEY>0     
    
-- if 5 years off , then expirationCompleteDate is really bogus so use mpp_exp1_date    
--Update #Temp    
-- Set Completes_mpp_exp1_date =mpp_exp1_date    
-- WHERE    
--  mpp_exp1_KEY>0     
--  AND    
--  abs(Datediff(hh, mpp_exp1_date, Completes_mpp_exp1_date) )> (365 * 24 * 5)    
    
Update #Temp    
 Set mpp_exp1_code =exp_code    
 FROM    
  Expiration  with(nolock)    
 WHERE    
  mpp_exp1_KEY>0     
  and    
  mpp_exp1_key= exp_key    
Update #Temp    
 Set mpp_exp1_code =    
   (    
   Select exp_code    
   FROM Expiration with(nolock)    
   WHERE mpp_exp1_key=exp_key    
   )    
 WHERE    
  mpp_exp1_KEY>0     
    
Update #Temp    
 Set mpp_exp1_Name =    
   (    
   Select labelFile.name    
   FROM     
    Expiration  with(nolock),    
    Labelfile with(nolock)    
   WHERE     
    mpp_exp1_key=exp_key    
    and    
    labelfile.abbr=exp_code    
    and    
    labelfile.labeldefinition='DrvExp'    
   )    
 WHERE    
  mpp_exp1_KEY>0     
        
    
    
    
Update #temp    
 Set AvlForAssignmentDate=    
  --convert(varchar(8),mpp_exp1_date,1)     
  convert(varchar(8),Completes_mpp_exp1_date,1)     
 From     
  city with(nolock),    
  Expiration with(nolock)    
 where    
  Expiration.exp_key= mpp_exp1_KEY    
  --AND    
  --Expiration.exp_idtype='DRV'    
  --and    
  --Expiration.exp_id = Driver    
  --and    
  --exp_priority=1    
  --and    
  --exp_completed='N'    
  --AND    
  --exp_expirationdate=mpp_exp1_date    
  and    
  exp_city=cty_code     
  And     
  city.cty_region1=Region    
  AND     
  abs(Datediff(hh, mpp_exp1_date, lgh_endateForSort) )< @HoursNearExpiration    
  AND     
  mpp_exp1_date>lgh_endateForSort    
--=====================================================    
-- check expiration  type 9     
Update #Temp    
Set mpp_exp2_KEY=    
 (    
  Select     
   Min(exp_Key)    
  From     
   Expiration with(nolock)    
  where    
   exp_idtype='DRV'    
   AND    
   exp_id= #temp.Driver    
   and    
   exp_priority=9    
   and    
   exp_completed='N'    
   AND    
   exp_expirationdate=mpp_exp2_date    
    
  )    
 WHERE mpp_exp2_date is Not Null    
    
    
Update #Temp    
 Set Completes_mpp_exp2_date =    
  (    
  Select     
   exp_compldate    
  From     
   Expiration with(nolock)    
  where    
   exp_key = mpp_exp2_KEY    
   --exp_idtype='DRV'    
   --AND    
   --exp_id= #temp.Driver    
   --and    
   --exp_priority=1    
   --and    
   --exp_completed='N'    
   --AND    
   --exp_expirationdate=mpp_exp1_date    
    
  )    
 WHERE --mpp_exp1_date is Not Null    
  mpp_exp2_KEY>0     
    
-- if 5 years off , then expirationCompleteDate is really bogus so use mpp_exp1_date    
--Update #Temp    
-- Set Completes_mpp_exp1_date =mpp_exp1_date    
-- WHERE    
--  mpp_exp1_KEY>0     
--  AND    
--  abs(Datediff(hh, mpp_exp1_date, Completes_mpp_exp1_date) )> (365 * 24 * 5)    
    
Update #Temp    
 Set mpp_exp2_code =exp_code    
 FROM    
  Expiration with(nolock)    
 WHERE    
  mpp_exp2_KEY>0     
  and    
  mpp_exp2_key= exp_key    
Update #Temp    
 Set mpp_exp2_code =    
   (    
   Select exp_code    
   FROM Expiration with(nolock)    
   WHERE mpp_exp2_key=exp_key    
   )    
 WHERE    
  mpp_exp2_KEY>0     
    
Update #Temp    
 Set mpp_exp2_Name =    
   (    
   Select labelFile.name    
   FROM     
    Expiration with(nolock),    
    Labelfile with(nolock)    
   WHERE     
    mpp_exp2_key=exp_key    
    and    
    labelfile.abbr=exp_code    
    and    
    labelfile.labeldefinition='DrvExp'    
   )    
 WHERE    
  mpp_exp2_KEY>0     
        
    
--lect     
    
Update #temp    
 Set AvlForAssignmentDate=    
  --convert(varchar(8),mpp_exp1_date,1)     
  convert(varchar(8),Completes_mpp_exp2_date,1)     
 From     
  city with(nolock),    
  Expiration with(nolock)    
 where    
  Expiration.exp_key= mpp_exp2_KEY    
  --AND    
  --Expiration.exp_idtype='DRV'    
  --and    
  --Expiration.exp_id = Driver    
  --and    
  --exp_priority=1    
  --and    
  --exp_completed='N'    
  --AND    
  --exp_expirationdate=mpp_exp1_date    
  and    
  exp_city=cty_code     
  And     
  city.cty_region1=Region    
  AND     
  abs(Datediff(hh, mpp_exp2_date, lgh_endateForSort) )< @HoursNearExpiration    
  AND     
  (    
  mpp_exp2_date>lgh_endateForSort    
  or    
  Completes_mpp_exp2_date>lgh_endateForSort    
  )    
--  and    
--  (Completes_mpp_exp2_date >Completes_mpp_exp1_date-- Use expiration 2 if it is earlier than expiration #1    
--  OR    
--   mpp_exp1_KEY=0 or  mpp_exp1_KEY is NULL)     
      
    
    
Update #temp    
 Set AvlForAssignmentDate=    
  --convert(varchar(8),mpp_exp1_date,1)     
 Convert(varchar(8),    
  Convert(datetime,    
   Convert(int,    
    convert(datetime,AvlForAssignmentDate)    
   )    
   + 1    
  )    
 ,1)    
    
 where    
     
  (    
  convert(varchar(8),completes_mpp_exp2_date ) = AvlForAssignmentDate    
  and      
  convert(varchar(5),completes_mpp_exp2_date ,8) > '16:00'    
  )    
  OR    
  (    
  convert(varchar(8),completes_mpp_exp2_date ) <> AvlForAssignmentDate    
  and    
  convert(varchar(8),lgh_endateForSort,8 ) > '16:00'      
  )    
     
    
    
    
    
--=======================    
    
    
select     
 *     
from     
 #temp --where HrsDifTwixtExp<24    
WHERE    
 mpp_exp1_code not in ('OP','OTPR', 'SKLT') -- Out Processing and Sick long term    
 and     
 DriverType3 <>'SD'  --exclude dedicated sole    
    
    
 AND   -- exclude short trips if no real driver is planned    
  NOT    
  (    
  LegMiles <=100    
  AND    
  DRIVER='UNKNOWN'    
  )     
     
 order by Driver,lgh_endateForSort    
     
    
  
GO
GRANT EXECUTE ON  [dbo].[rptFlowInboundDetail] TO [public]
GO
