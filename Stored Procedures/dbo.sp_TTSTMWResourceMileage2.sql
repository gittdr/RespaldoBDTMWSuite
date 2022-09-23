SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE                                                                Procedure [dbo].[sp_TTSTMWResourceMileage2]
				       (
					@resourcetype char(30),
					@frmdt datetime,
					@tdt datetime,
					@revtype1 varchar (120),
					@revtype2 varchar (120),
					@revtype3 varchar (120),
					@revtype4 varchar (120),
					@driver varchar (30),
					@tractor varchar (30),
					@drvtype1 varchar (120),
					@drvtype2 varchar (120),
					@drvtype3 varchar (120),
					@drvtype4 varchar (120),
					@trailer varchar (30),
					@trctype1 varchar (120),
					@trctype2 varchar (120),
					@trctype3 varchar (120),
					@trctype4 varchar (120),
					@trltype1 varchar (120),
					@trltype2 varchar (120),
					@trltype3 varchar (120),
					@trltype4 varchar (120),
					@DateType varchar (30),
					@sortoption varchar (50),
                                        @includeteamresource char (1),
                                        @dispatchstatus varchar (150)
					)
			         

As


--Author: Brent Keeton
--********************************************************************
--Purpose: Resource Mileage Report is intended to show total, loaded, and empty 
--miles, by resource for all moves regardless if an order is being 
--carried on the move
--*************************************************************************

--Revision History: 
--1. Tuesday September 30,2002 ver 3.2 Added feature to allow users
--to restrict by a list of 1 or more dispatch statuses
--By default Started and Completed are automatically selected
--which more then likely give them what they need(an accurate report of miles) 
--by not selecting anything from the list they will get all
--trip segments regardless of what the dispatch status is
--except Canceled Trip Segments 
--This report filters out Canceled Trip Segments regardless
--if they have selected from a list or not selected from the list
--2. Monday April 21, 2003 Ver 5.0 Added Resources without runs
--that are active to report
--Enhanced report to categorize carriers better LBK

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

SELECT @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, ''))) + ','
SELECT @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, ''))) + ',' 
SELECT @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, ''))) + ',' 

SELECT @driver= ',' + LTRIM(RTRIM(ISNULL(@driver, ''))) + ','    
SELECT @tractor = ',' + LTRIM(RTRIM(ISNULL(@tractor, ''))) + ','    
SELECT @trailer = ',' + LTRIM(RTRIM(ISNULL(@trailer, ''))) + ','  

SELECT @drvtype1 = ',' + LTRIM(RTRIM(ISNULL(@drvtype1, ''))) + ','
SELECT @drvtype2 = ',' + LTRIM(RTRIM(ISNULL(@drvtype2, ''))) + ','
SELECT @drvtype3 = ',' + LTRIM(RTRIM(ISNULL(@drvtype3, ''))) + ',' 
SELECT @drvtype4 = ',' + LTRIM(RTRIM(ISNULL(@drvtype4, ''))) + ',' 

--SELECT @cartype1 = ',' + LTRIM(RTRIM(ISNULL(@cartype1, ''))) + ','
--SELECT @cartype2 = ',' + LTRIM(RTRIM(ISNULL(@cartype2, ''))) + ','
--SELECT @cartype3 = ',' + LTRIM(RTRIM(ISNULL(@cartype3, ''))) + ','
--SELECT @cartype4 = ',' + LTRIM(RTRIM(ISNULL(@cartype4, ''))) + ','

SELECT @trltype1 = ',' + LTRIM(RTRIM(ISNULL(@trltype1, ''))) + ','
SELECT @trltype2 = ',' + LTRIM(RTRIM(ISNULL(@trltype2, ''))) + ','
SELECT @trltype3 = ',' + LTRIM(RTRIM(ISNULL(@trltype3, ''))) + ',' 
SELECT @trltype4 = ',' + LTRIM(RTRIM(ISNULL(@trltype4, ''))) + ',' 

SELECT @trctype1 = ',' + LTRIM(RTRIM(ISNULL(@trctype1, ''))) + ','
SELECT @trctype2 = ',' + LTRIM(RTRIM(ISNULL(@trctype2, ''))) + ','
SELECT @trctype3 = ',' + LTRIM(RTRIM(ISNULL(@trctype3, ''))) + ',' 
SELECT @trctype4 = ',' + LTRIM(RTRIM(ISNULL(@trctype4, ''))) + ',' 

SELECT @dispatchstatus = ',' + LTRIM(RTRIM(ISNULL(@dispatchstatus, ''))) + ',' 

If @resourcetype = 'driver/carrier' --driver/carriers *************************************
Begin			    --********************************************

       --Drivers
      select  IsNull(mpp_id,'') as Resource,
	       IsNull((mpp_lastfirst),mpp_id) as DriverName,
	       'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number),
               'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number and stops.stp_loadstatus = 'LD'),
               'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where  stops.lgh_number = legheader.lgh_number  and stops.stp_loadstatus <> 'LD')
       into #worklist
       from legheader (NOLOCK) Right Join manpowerprofile (NOLOCK) On manpowerprofile.mpp_id = lgh_driver1
            And
	    ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
              OR
             (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
             And 
             (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
	     And
             lgh_outstatus <> 'CAN'
         
       Where (mpp_terminationdt > GetDate()
	       Or
              mpp_terminationdt Is Null
               Or
              lgh_number Is Not Null
             )
	     And
             (@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0) 
             And
	     (@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0) 
             And
             (@revtype3 = ',,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0) 
             And
             (@revtype4 = ',,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0)
             And  
             (@driver= ',,' OR CHARINDEX(',' + mpp_id + ',', @driver) > 0)
	     And
	     (@tractor= ',,' OR CHARINDEX(',' + lgh_tractor + ',', @tractor) > 0)
             And
             (@trailer= ',,' OR CHARINDEX(',' + lgh_primary_trailer + ',', @trailer) > 0)
             And
             (@drvtype1 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type1 + ',', @drvtype1) > 0) 
             And
             (@drvtype2 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type2  + ',', @drvtype2) > 0) 
             And
             (@drvtype3 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type3  + ',', @drvtype3) > 0) 
             And
             (@drvtype4 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type4  + ',', @drvtype4) > 0)
             And
             (@trltype1 = ',,' OR CHARINDEX(',' + trl_type1 + ',', @trltype1) > 0) 
             And
             (@trltype2 = ',,' OR CHARINDEX(',' + trl_type2  + ',', @trltype2) > 0) 
             And
             (@trltype3 = ',,' OR CHARINDEX(',' + trl_type3  + ',', @trltype3) > 0) 
             And
             (@trltype4 = ',,' OR CHARINDEX(',' + trl_type4  + ',', @trltype4) > 0)
             And
             (@trctype1 = ',,' OR CHARINDEX(',' + trc_type1 + ',', @trctype1) > 0) 
             And
             (@trctype2 = ',,' OR CHARINDEX(',' + trc_type2 + ',', @trctype2) > 0) 
             And
             (@trctype3 = ',,' OR CHARINDEX(',' + trc_type3  + ',', @trctype3) > 0) 
             And
             (@trctype4 = ',,' OR CHARINDEX(',' + trc_type4  + ',', @trctype4) > 0)
	     And
             --Include only records that a carrier is not present
	     (lgh_carrier = 'UNK' or lgh_carrier = 'UNKNOWN' or lgh_carrier Is Null)      	   
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

    Union All
	
	SELECT 
	     
	      IsNull(car_id,'') as Resource,
	      IsNull((car_name),car_id) as DriverName,
	      'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number),
              'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number and stops.stp_loadstatus = 'LD'),
              'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where  stops.lgh_number = legheader.lgh_number  and stops.stp_loadstatus <> 'LD')
	      
       from  legheader (NOLOCK) Right Join carrier (NOLOCK) On car_id = lgh_carrier
             And
             ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
              OR
              (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
             And 
             (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
	     And
             lgh_outstatus <> 'CAN'
       where (car_terminationdt > GetDate()
	       Or
              car_terminationdt Is Null
               Or
              lgh_number Is Not Null
              )
 	     And
	     (@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0) 
             And
	     (@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0) 
             And
             (@revtype3 = ',,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0) 
             And
             (@revtype4 = ',,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0)
             And  
             (@driver= ',,' OR CHARINDEX(',' + lgh_driver1 + ',', @driver) > 0)
	     And
	     (@tractor= ',,' OR CHARINDEX(',' + lgh_tractor + ',', @tractor) > 0)
             And
             (@trailer= ',,' OR CHARINDEX(',' + lgh_primary_trailer + ',', @trailer) > 0)
             And
             (@drvtype1 = ',,' OR CHARINDEX(',' + mpp_type1 + ',', @drvtype1) > 0) 
             And
             (@drvtype2 = ',,' OR CHARINDEX(',' + mpp_type2  + ',', @drvtype2) > 0) 
             And
             (@drvtype3 = ',,' OR CHARINDEX(',' + mpp_type3  + ',', @drvtype3) > 0) 
             And
             (@drvtype4 = ',,' OR CHARINDEX(',' + mpp_type4  + ',', @drvtype4) > 0)
             And
             (@trltype1 = ',,' OR CHARINDEX(',' + trl_type1 + ',', @trltype1) > 0) 
             And
             (@trltype2 = ',,' OR CHARINDEX(',' + trl_type2  + ',', @trltype2) > 0) 
             And
             (@trltype3 = ',,' OR CHARINDEX(',' + trl_type3  + ',', @trltype3) > 0) 
             And
             (@trltype4 = ',,' OR CHARINDEX(',' + trl_type4  + ',', @trltype4) > 0)
             And
             (@trctype1 = ',,' OR CHARINDEX(',' + trc_type1 + ',', @trctype1) > 0) 
             And
             (@trctype2 = ',,' OR CHARINDEX(',' + trc_type2 + ',', @trctype2) > 0) 
             And
             (@trctype3 = ',,' OR CHARINDEX(',' + trc_type3  + ',', @trctype3) > 0) 
             And
             (@trctype4 = ',,' OR CHARINDEX(',' + trc_type4  + ',', @trctype4) > 0)	   
	     And 
	     --Ensuring that carrier records are picked up 
	     (car_id <> 'UNK' and car_id <> 'UNKNOWN' and car_id Is Not Null) 
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
         
        --Sum Miles and Group By Driver/Carrier
        Select IsNull(Resource,'') as Resource,
               IsNull(DriverName,'') as DriverName,
	       Cast(Sum(IsNull(TravelMiles,0)) as float) as TravelMiles,
               Cast(Sum(IsNull(LoadedMiles,0)) as float) as LoadedMiles,
               Cast(Sum(IsNull(EmptyMiles,0)) as float) as EmptyMiles,
	 
               Case when Sum(IsNull(TravelMiles,0))=0 Then
	 		Cast(0 as Float)
	       Else	
			Cast(Sum(IsNull(EmptyMiles,0)) as float)/Cast(Sum(IsNull(TravelMiles,0)) as float)
	       End as PercentEmpty
	into #finaldriver
	from #worklist
	Group By Resource,DriverName

	Select Resource as Resource,
       	       DriverName as DriverName,
               IsNull(TravelMiles,0) as TravelMiles,
               IsNull(LoadedMiles,0) as LoadedMiles,
               IsNull(EmptyMiles,0) as EmptyMiles,
               IsNull(PercentEmpty,0) as PercentEmpty
       from #finaldriver
       Order By
       	       case when @sortoption = 'Travel Miles-ASC' then TravelMiles end Asc,
               case when @sortoption = 'Travel Miles-DESC' then TravelMiles end Desc,
               case when @sortoption = 'Loaded Miles-ASC' then LoadedMiles end Asc,
               case when @sortoption = 'Loaded Miles-DESC' then LoadedMiles end Desc,
               case when @sortoption = 'Empty Miles-ASC' then EmptyMiles end Asc,
               case when @sortoption = 'Empty Miles-DESC' then EmptyMiles end Desc, 
               case when @sortoption = 'Resource ID' then Resource end,
               case when @sortoption = 'Driver Last Name' then DriverName end,
               case when @sortoption = 'Percent Empty-ASC' then PercentEmpty end Asc,
               case when @sortoption = 'Percent Empty-DESC' then PercentEmpty end Desc

   End
   

Else If @resourcetype = 'Driver Only'--Drivers Only*************************************************
 Begin	

   If @includeteamresource = 'N' --Just Driver1***************************
     Begin			 
       select  IsNull(mpp_id,'') as Resource,
	       IsNull((mpp_lastfirst),mpp_id) as DriverName,
	       'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number),
               'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number and stops.stp_loadstatus = 'LD'),
               'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where  stops.lgh_number = legheader.lgh_number  and stops.stp_loadstatus <> 'LD')
       into #justdriver
       from legheader (NOLOCK) Right Join manpowerprofile (NOLOCK) On manpowerprofile.mpp_id = lgh_driver1
            And
	    ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
              OR
             (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
             And 
             (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
	     And
             lgh_outstatus <> 'CAN'
         
       Where (mpp_terminationdt > GetDate()
	       Or
              mpp_terminationdt Is Null
               Or
              lgh_number Is Not Null
             )
	     And
             (@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0) 
             And
	     (@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0) 
             And
             (@revtype3 = ',,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0) 
             And
             (@revtype4 = ',,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0)
             And  
             (@driver= ',,' OR CHARINDEX(',' + mpp_id + ',', @driver) > 0)
	     And
	     (@tractor= ',,' OR CHARINDEX(',' + lgh_tractor + ',', @tractor) > 0)
             And
             (@trailer= ',,' OR CHARINDEX(',' + lgh_primary_trailer + ',', @trailer) > 0)
             And
             (@drvtype1 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type1 + ',', @drvtype1) > 0) 
             And
             (@drvtype2 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type2  + ',', @drvtype2) > 0) 
             And
             (@drvtype3 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type3  + ',', @drvtype3) > 0) 
             And
             (@drvtype4 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type4  + ',', @drvtype4) > 0)
             And
             (@trltype1 = ',,' OR CHARINDEX(',' + trl_type1 + ',', @trltype1) > 0) 
             And
             (@trltype2 = ',,' OR CHARINDEX(',' + trl_type2  + ',', @trltype2) > 0) 
             And
             (@trltype3 = ',,' OR CHARINDEX(',' + trl_type3  + ',', @trltype3) > 0) 
             And
             (@trltype4 = ',,' OR CHARINDEX(',' + trl_type4  + ',', @trltype4) > 0)
             And
             (@trctype1 = ',,' OR CHARINDEX(',' + trc_type1 + ',', @trctype1) > 0) 
             And
             (@trctype2 = ',,' OR CHARINDEX(',' + trc_type2 + ',', @trctype2) > 0) 
             And
             (@trctype3 = ',,' OR CHARINDEX(',' + trc_type3  + ',', @trctype3) > 0) 
             And
             (@trctype4 = ',,' OR CHARINDEX(',' + trc_type4  + ',', @trctype4) > 0)
	     And
             --Include only records that a carrier is not present
	     (lgh_carrier = 'UNK' or lgh_carrier = 'UNKNOWN' or lgh_carrier Is Null)      	   
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
	

	Select IsNull(Resource,'') as Resource,
               IsNull(DriverName,'') as DriverName,
	       Cast(Sum(IsNull(TravelMiles,0)) as float) as TravelMiles,
               Cast(Sum(IsNull(LoadedMiles,0)) as float) as LoadedMiles,
               Cast(Sum(IsNull(EmptyMiles,0)) as float) as EmptyMiles,
	 
               Case when Sum(IsNull(TravelMiles,0))=0 Then
	 		Cast(0 as Float)
	       Else	
			Cast(Sum(IsNull(EmptyMiles,0)) as float)/Cast(Sum(IsNull(TravelMiles,0)) as float)
	       End as PercentEmpty
	
        into   #finaljustdriver
	from   #justdriver
	Group By Resource,DriverName

	Select Resource as Resource,
       	       DriverName as DriverName,
               IsNull(TravelMiles,0) as TravelMiles,
               IsNull(LoadedMiles,0) as LoadedMiles,
               IsNull(EmptyMiles,0) as EmptyMiles,
               IsNull(PercentEmpty,0) as PercentEmpty
       from #finaljustdriver
       Order By
       	       case when @sortoption = 'Travel Miles-ASC' then TravelMiles end Asc,
               case when @sortoption = 'Travel Miles-DESC' then TravelMiles end Desc,
               case when @sortoption = 'Loaded Miles-ASC' then LoadedMiles end Asc,
               case when @sortoption = 'Loaded Miles-DESC' then LoadedMiles end Desc,
               case when @sortoption = 'Empty Miles-ASC' then EmptyMiles end Asc,
               case when @sortoption = 'Empty Miles-DESC' then EmptyMiles end Desc, 
               case when @sortoption = 'Resource ID' then Resource end,
               case when @sortoption = 'Driver Last Name' then DriverName end,
               case when @sortoption = 'Percent Empty-ASC' then PercentEmpty end Asc,
               case when @sortoption = 'Percent Empty-DESC' then PercentEmpty end Desc
   	End
    
  Else

     Begin--*********************************Driver 1 and Include Driver 2
 		 
      select  IsNull(mpp_id,'') as Resource,
	      IsNull((mpp_lastfirst),mpp_id) as DriverName,
	      'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number),
              'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number and stops.stp_loadstatus = 'LD'),
              'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where  stops.lgh_number = legheader.lgh_number  and stops.stp_loadstatus <> 'LD')
       
       into  #teamdrivers
       from  legheader (NOLOCK) Right Join manpowerprofile (NOLOCK) On manpowerprofile.mpp_id = lgh_driver1
       	     And
	     ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
               OR
             (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
             And 
             (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
	     And
             lgh_outstatus <> 'CAN'
         
       Where (mpp_terminationdt > GetDate()
	       Or
              mpp_terminationdt Is Null
               Or
              lgh_number Is Not Null
             )
	     And
             (@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0) 
             And
	     (@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0) 
             And
             (@revtype3 = ',,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0) 
             And
             (@revtype4 = ',,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0)
             And  
             (@driver= ',,' OR CHARINDEX(',' + mpp_id + ',', @driver) > 0)
	     And
	     (@tractor= ',,' OR CHARINDEX(',' + lgh_tractor + ',', @tractor) > 0)
             And
             (@trailer= ',,' OR CHARINDEX(',' + lgh_primary_trailer + ',', @trailer) > 0)
             And
             (@drvtype1 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type1 + ',', @drvtype1) > 0) 
             And
             (@drvtype2 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type2  + ',', @drvtype2) > 0) 
             And
             (@drvtype3 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type3  + ',', @drvtype3) > 0) 
             And
             (@drvtype4 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type4  + ',', @drvtype4) > 0)
             And
             (@trltype1 = ',,' OR CHARINDEX(',' + trl_type1 + ',', @trltype1) > 0) 
             And
             (@trltype2 = ',,' OR CHARINDEX(',' + trl_type2  + ',', @trltype2) > 0) 
             And
             (@trltype3 = ',,' OR CHARINDEX(',' + trl_type3  + ',', @trltype3) > 0) 
             And
             (@trltype4 = ',,' OR CHARINDEX(',' + trl_type4  + ',', @trltype4) > 0)
             And
             (@trctype1 = ',,' OR CHARINDEX(',' + trc_type1 + ',', @trctype1) > 0) 
             And
             (@trctype2 = ',,' OR CHARINDEX(',' + trc_type2 + ',', @trctype2) > 0) 
             And
             (@trctype3 = ',,' OR CHARINDEX(',' + trc_type3  + ',', @trctype3) > 0) 
             And
             (@trctype4 = ',,' OR CHARINDEX(',' + trc_type4  + ',', @trctype4) > 0)
	     And
             --Include only records that a carrier is not present
	     (lgh_carrier = 'UNK' or lgh_carrier = 'UNKNOWN' or lgh_carrier Is Null)      	   
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

    Union All

         select IsNull(mpp_id,'') as Resource,
	        IsNull((mpp_lastfirst),mpp_id) as DriverName,
	        'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number),
                'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number and stops.stp_loadstatus = 'LD'),
                'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where  stops.lgh_number = legheader.lgh_number  and stops.stp_loadstatus <> 'LD')
	     
         from   legheader (NOLOCK) Right Join manpowerprofile (NOLOCK) On mpp_id = lgh_driver2
                And
		((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
                  OR
                 (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
                And 
                (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
	        And
                lgh_outstatus <> 'CAN'
         
         Where  (mpp_terminationdt > GetDate()
	         Or
                 mpp_terminationdt Is Null
                 Or
                 lgh_number Is Not Null
                )
	        And
                (@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0) 
                And
	        (@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0) 
                And
                (@revtype3 = ',,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0) 
                And
                (@revtype4 = ',,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0)
                And  
                (@driver= ',,' OR CHARINDEX(',' + mpp_id + ',', @driver) > 0)
	        And
	        (@tractor= ',,' OR CHARINDEX(',' + lgh_tractor + ',', @tractor) > 0)
                And
                (@trailer= ',,' OR CHARINDEX(',' + lgh_primary_trailer + ',', @trailer) > 0)
                And
                (@drvtype1 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type1 + ',', @drvtype1) > 0) 
                And
                (@drvtype2 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type2  + ',', @drvtype2) > 0) 
                And
                (@drvtype3 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type3  + ',', @drvtype3) > 0) 
                And
                (@drvtype4 = ',,' OR CHARINDEX(',' + manpowerprofile.mpp_type4  + ',', @drvtype4) > 0)
                And
                (@trltype1 = ',,' OR CHARINDEX(',' + trl_type1 + ',', @trltype1) > 0) 
                And
                (@trltype2 = ',,' OR CHARINDEX(',' + trl_type2  + ',', @trltype2) > 0) 
                And
                (@trltype3 = ',,' OR CHARINDEX(',' + trl_type3  + ',', @trltype3) > 0) 
                And
                (@trltype4 = ',,' OR CHARINDEX(',' + trl_type4  + ',', @trltype4) > 0)
                And
                (@trctype1 = ',,' OR CHARINDEX(',' + trc_type1 + ',', @trctype1) > 0) 
                And
                (@trctype2 = ',,' OR CHARINDEX(',' + trc_type2 + ',', @trctype2) > 0) 
                And
                (@trctype3 = ',,' OR CHARINDEX(',' + trc_type3  + ',', @trctype3) > 0) 
                And
                (@trctype4 = ',,' OR CHARINDEX(',' + trc_type4  + ',', @trctype4) > 0)
       	        and 
                (lgh_driver2 <> 'UNKNOWN')	
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
	
        --Sum Miles and Group By Driver
        Select IsNull(Resource,'') as Resource,
               IsNull(DriverName,'') as DriverName,
	       Cast(Sum(IsNull(TravelMiles,0)) as float) as TravelMiles,
               Cast(Sum(IsNull(LoadedMiles,0)) as float) as LoadedMiles,
               Cast(Sum(IsNull(EmptyMiles,0)) as float) as EmptyMiles,
	 
               Case when Sum(IsNull(TravelMiles,0))=0 Then
	 		Cast(0 as Float)
	       Else	
			Cast(Sum(IsNull(EmptyMiles,0)) as float)/Cast(Sum(IsNull(TravelMiles,0)) as float)
	       End as PercentEmpty
	
        into   #finalteamdrivers
	from   #teamdrivers
	Group By Resource,DriverName

	Select Resource as Resource,
       	       DriverName as DriverName,
               IsNull(TravelMiles,0) as TravelMiles,
               IsNull(LoadedMiles,0) as LoadedMiles,
               IsNull(EmptyMiles,0) as EmptyMiles,
               IsNull(PercentEmpty,0) as PercentEmpty
       from #finalteamdrivers
       Order By
       	       case when @sortoption = 'Travel Miles-ASC' then TravelMiles end Asc,
               case when @sortoption = 'Travel Miles-DESC' then TravelMiles end Desc,
               case when @sortoption = 'Loaded Miles-ASC' then LoadedMiles end Asc,
               case when @sortoption = 'Loaded Miles-DESC' then LoadedMiles end Desc,
               case when @sortoption = 'Empty Miles-ASC' then EmptyMiles end Asc,
               case when @sortoption = 'Empty Miles-DESC' then EmptyMiles end Desc, 
               case when @sortoption = 'Resource ID' then Resource end,
               case when @sortoption = 'Driver Last Name' then DriverName end,
               case when @sortoption = 'Percent Empty-ASC' then PercentEmpty end Asc,
               case when @sortoption = 'Percent Empty-DESC' then PercentEmpty end Desc
     End

End
Else If @resourcetype = 'Carrier Only'
Begin                             
	SELECT 
	     
	      IsNull(car_id,'') as Resource,
	      IsNull((car_name),car_id) as DriverName,
	      'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number),
              'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number and stops.stp_loadstatus = 'LD'),
              'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where  stops.lgh_number = legheader.lgh_number  and stops.stp_loadstatus <> 'LD')
	      
       into #justcarrier
       from legheader (NOLOCK) Right Join carrier (NOLOCK) On car_id = lgh_carrier
            And
            ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
             OR
             (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
             And 
             (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
	     And
             lgh_outstatus <> 'CAN'
       where (car_terminationdt > GetDate()
	       Or
              car_terminationdt Is Null
               Or
              lgh_number Is Not Null
              )
 	     And
	     (@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0) 
             And
	     (@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0) 
             And
             (@revtype3 = ',,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0) 
             And
             (@revtype4 = ',,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0)
             And  
             (@driver= ',,' OR CHARINDEX(',' + lgh_driver1 + ',', @driver) > 0)
	     And
	     (@tractor= ',,' OR CHARINDEX(',' + lgh_tractor + ',', @tractor) > 0)
             And
             (@trailer= ',,' OR CHARINDEX(',' + lgh_primary_trailer + ',', @trailer) > 0)
             And
             (@drvtype1 = ',,' OR CHARINDEX(',' + mpp_type1 + ',', @drvtype1) > 0) 
             And
             (@drvtype2 = ',,' OR CHARINDEX(',' + mpp_type2  + ',', @drvtype2) > 0) 
             And
             (@drvtype3 = ',,' OR CHARINDEX(',' + mpp_type3  + ',', @drvtype3) > 0) 
             And
             (@drvtype4 = ',,' OR CHARINDEX(',' + mpp_type4  + ',', @drvtype4) > 0)
             And
             (@trltype1 = ',,' OR CHARINDEX(',' + trl_type1 + ',', @trltype1) > 0) 
             And
             (@trltype2 = ',,' OR CHARINDEX(',' + trl_type2  + ',', @trltype2) > 0) 
             And
             (@trltype3 = ',,' OR CHARINDEX(',' + trl_type3  + ',', @trltype3) > 0) 
             And
             (@trltype4 = ',,' OR CHARINDEX(',' + trl_type4  + ',', @trltype4) > 0)
             And
             (@trctype1 = ',,' OR CHARINDEX(',' + trc_type1 + ',', @trctype1) > 0) 
             And
             (@trctype2 = ',,' OR CHARINDEX(',' + trc_type2 + ',', @trctype2) > 0) 
             And
             (@trctype3 = ',,' OR CHARINDEX(',' + trc_type3  + ',', @trctype3) > 0) 
             And
             (@trctype4 = ',,' OR CHARINDEX(',' + trc_type4  + ',', @trctype4) > 0)	   
	     And 
	     --Ensuring that carrier records are picked up 
	     (car_id <> 'UNK' and car_id <> 'UNKNOWN' and car_id Is Not Null) 
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
 
	--Sum Miles and Group By Driver
        Select IsNull(Resource,'') as Resource,
               IsNull(DriverName,'') as DriverName,
	       Cast(Sum(IsNull(TravelMiles,0)) as float) as TravelMiles,
               Cast(Sum(IsNull(LoadedMiles,0)) as float) as LoadedMiles,
               Cast(Sum(IsNull(EmptyMiles,0)) as float) as EmptyMiles,
	 
               Case when Sum(IsNull(TravelMiles,0))=0 Then
	 		Cast(0 as Float)
	       Else	
			Cast(Sum(IsNull(EmptyMiles,0)) as float)/Cast(Sum(IsNull(TravelMiles,0)) as float)
	       End as PercentEmpty
	into #finaljustcarrier
	from #justcarrier
	Group By Resource,DriverName

	Select Resource as Resource,
       	       DriverName as DriverName,
               IsNull(TravelMiles,0) as TravelMiles,
               IsNull(LoadedMiles,0) as LoadedMiles,
               IsNull(EmptyMiles,0) as EmptyMiles,
               IsNull(PercentEmpty,0) as PercentEmpty
       from #finaljustcarrier
       Order By
       	       case when @sortoption = 'Travel Miles-ASC' then TravelMiles end Asc,
               case when @sortoption = 'Travel Miles-DESC' then TravelMiles end Desc,
               case when @sortoption = 'Loaded Miles-ASC' then LoadedMiles end Asc,
               case when @sortoption = 'Loaded Miles-DESC' then LoadedMiles end Desc,
               case when @sortoption = 'Empty Miles-ASC' then EmptyMiles end Asc,
               case when @sortoption = 'Empty Miles-DESC' then EmptyMiles end Desc, 
               case when @sortoption = 'Resource ID' then Resource end,
               case when @sortoption = 'Driver Last Name' then DriverName end,
               case when @sortoption = 'Percent Empty-ASC' then PercentEmpty end Asc,
               case when @sortoption = 'Percent Empty-DESC' then PercentEmpty end Desc


End

Else If @resourcetype = 'tractor' --tractor *************************************
Begin                             --********************************************

--Group records by legheaders for the move
--and restrict on any tractor types or tractor id's if any are given
select IsNull(trc_number,'') as Resource,
       'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number),
       'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.lgh_number = legheader.lgh_number and stops.stp_loadstatus = 'LD'),
       'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where  stops.lgh_number = legheader.lgh_number  and stops.stp_loadstatus <> 'LD')
into #worklist2 
from  legheader (NOLOCK) Right Join tractorprofile (NOLOCK) On trc_number = lgh_tractor 
      And
      ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
        OR
       (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
      And 
      (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
      And
      lgh_outstatus <> 'CAN'
--Restrict to tractors that are active or possibly inactive currently
--but had runs during that time period
Where (trc_retiredate > GetDate()
       Or
       trc_retiredate Is Null
       Or
       lgh_number Is Not Null
      )
      And
	     (@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0) 
             And
	     (@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0) 
             And
             (@revtype3 = ',,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0) 
             And
             (@revtype4 = ',,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0)
             And  
             (@driver= ',,' OR CHARINDEX(',' + lgh_driver1 + ',', @driver) > 0)
	     And
	     (@tractor= ',,' OR CHARINDEX(',' + trc_number + ',', @tractor) > 0)
             And
             (@trailer= ',,' OR CHARINDEX(',' + lgh_primary_trailer + ',', @trailer) > 0)
             And
             (@drvtype1 = ',,' OR CHARINDEX(',' + mpp_type1 + ',', @drvtype1) > 0) 
             And
             (@drvtype2 = ',,' OR CHARINDEX(',' + mpp_type2  + ',', @drvtype2) > 0) 
             And
             (@drvtype3 = ',,' OR CHARINDEX(',' + mpp_type3  + ',', @drvtype3) > 0) 
             And
             (@drvtype4 = ',,' OR CHARINDEX(',' + mpp_type4  + ',', @drvtype4) > 0)
             And
             (@trltype1 = ',,' OR CHARINDEX(',' + trl_type1 + ',', @trltype1) > 0) 
             And
             (@trltype2 = ',,' OR CHARINDEX(',' + trl_type2  + ',', @trltype2) > 0) 
             And
             (@trltype3 = ',,' OR CHARINDEX(',' + trl_type3  + ',', @trltype3) > 0) 
             And
             (@trltype4 = ',,' OR CHARINDEX(',' + trl_type4  + ',', @trltype4) > 0)
             And
             (@trctype1 = ',,' OR CHARINDEX(',' + tractorprofile.trc_type1 + ',', @trctype1) > 0) 
             And
             (@trctype2 = ',,' OR CHARINDEX(',' + tractorprofile.trc_type2 + ',', @trctype2) > 0) 
             And
             (@trctype3 = ',,' OR CHARINDEX(',' + tractorprofile.trc_type3  + ',', @trctype3) > 0) 
             And
             (@trctype4 = ',,' OR CHARINDEX(',' + tractorprofile.trc_type4  + ',', @trctype4) > 0)	   
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

--Sum Miles and Group By Tractor
Select Resource,
       Cast(Sum(IsNull(TravelMiles,0)) as float) as TravelMiles,
       Cast(Sum(IsNull(LoadedMiles,0)) as float) as LoadedMiles,
       Cast(Sum(IsNull(EmptyMiles,0)) as float) as EmptyMiles,
       Case when Sum(IsNull(TravelMiles,0))=0 Then
	 	 Cast(0 as Float)
       Else	
		 Cast(Sum(IsNull(EmptyMiles,0)) as float)/Cast(Sum(IsNull(TravelMiles,0)) as float)
       End as PercentEmpty
into #finaltractor
from #worklist2 
Group By Resource

--Sort Table by sort picked by user
Select Resource,
       TravelMiles,
       LoadedMiles,
       EmptyMiles,
       PercentEmpty
from #finaltractor
Order By
       case when @sortoption = 'Travel Miles-ASC' then TravelMiles end Asc,
       case when @sortoption = 'Travel Miles-DESC' then TravelMiles end Desc,
       case when @sortoption = 'Loaded Miles-ASC' then LoadedMiles end Asc,
       case when @sortoption = 'Loaded Miles-DESC' then LoadedMiles end Desc,
       case when @sortoption = 'Empty Miles-ASC' then EmptyMiles end Asc,
       case when @sortoption = 'Empty Miles-DESC' then EmptyMiles end Desc,
       case when @sortoption = 'Resource ID' then Resource end,
       case when @sortoption = 'Percent Empty-ASC' then PercentEmpty end Asc,
       case when @sortoption = 'Percent Empty-DESC' then PercentEmpty end Desc


End
Else --trailer *************************************
Begin

    If @includeteamresource = 'N' --just trailer1 *************************************
    Begin	                  --********************************************

	select mainstops.stp_number,
       	       evt_trailer1 as Resource, 
       	       'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.stp_number = mainstops.stp_number),
       	       'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.stp_number = mainstops.stp_number and stops.stp_loadstatus = 'LD'),
       	       'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where  stops.stp_number = mainstops.stp_number and stops.stp_loadstatus <> 'LD')
	into   #worklist3
	from   legheader (NOLOCK),stops mainstops (NOLOCK),event (NOLOCK)
	where  legheader.lgh_number = mainstops.lgh_number
      	       and 
               mainstops.stp_number = event.stp_number and evt_sequence = 1
               and
               ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
	       OR
               (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
               And 
      	       (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
               And
               lgh_outstatus <> 'CAN'
               And	
               (@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0) 
               And
               (@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0) 
               And
               (@revtype3 = ',,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0) 
               And
               (@revtype4 = ',,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0)
               And  
               (@tractor= ',,' OR CHARINDEX(',' + lgh_tractor + ',', @tractor) > 0)
               And
               (@driver = ',,' OR CHARINDEX(',' + lgh_driver1 + ',', @driver) > 0)
               And
      	       (@drvtype1 = ',,' OR CHARINDEX(',' + mpp_type1 + ',', @drvtype1) > 0) 
               And
               (@drvtype2 = ',,' OR CHARINDEX(',' + mpp_type2  + ',', @drvtype2) > 0) 
               And
               (@drvtype3 = ',,' OR CHARINDEX(',' + mpp_type3  + ',', @drvtype3) > 0) 
               And
               (@drvtype4 = ',,' OR CHARINDEX(',' + mpp_type4  + ',', @drvtype4) > 0)
               And
               (@trltype1 = ',,' OR CHARINDEX(',' + trl_type1 + ',', @trltype1) > 0) 
               And
               (@trltype2 = ',,' OR CHARINDEX(',' + trl_type2  + ',', @trltype2) > 0) 
               And
               (@trltype3 = ',,' OR CHARINDEX(',' + trl_type3  + ',', @trltype3) > 0) 
               And
               (@trltype4 = ',,' OR CHARINDEX(',' + trl_type4  + ',', @trltype4) > 0)
               And
               (@trctype1 = ',,' OR CHARINDEX(',' + trc_type1 + ',', @trctype1) > 0) 
               And
               (@trctype2 = ',,' OR CHARINDEX(',' + trc_type2 + ',', @trctype2) > 0) 
               And
               (@trctype3 = ',,' OR CHARINDEX(',' + trc_type3  + ',', @trctype3) > 0) 
               And
               (@trctype4 = ',,' OR CHARINDEX(',' + trc_type4  + ',', @trctype4) > 0)		
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

     --Sum Miles and Group By Trailer
     Select Resource,
            Sum(TravelMiles) as TravelMiles,
            Sum(LoadedMiles) as LoadedMiles,
            Sum(EmptyMiles) as EmptyMiles,
	    Case when Sum(IsNull(TravelMiles,0))=0 Then
	 		Cast(0 as Float)
	    Else	
			Cast(Sum(IsNull(EmptyMiles,0)) as float)/Cast(Sum(IsNull(TravelMiles,0)) as float)
	    End as PercentEmpty
     into #finaltrailer
     from #worklist3
     Group By Resource

    --Sort Table by sort picked by user
    Select Resource,
           TravelMiles,
           LoadedMiles,
           EmptyMiles,
           PercentEmpty
    from #finaltrailer
    Where 
	   (@trailer = ',,' OR CHARINDEX(',' + Resource + ',', @trailer) > 0)  
    Order By
           case when @sortoption = 'Travel Miles-ASC' then TravelMiles end Asc,
           case when @sortoption = 'Travel Miles-DESC' then TravelMiles end Desc,
           case when @sortoption = 'Loaded Miles-ASC' then LoadedMiles end Asc,
           case when @sortoption = 'Loaded Miles-DESC' then LoadedMiles end Desc,
           case when @sortoption = 'Empty Miles-ASC' then EmptyMiles end Asc,
           case when @sortoption = 'Empty Miles-DESC' then EmptyMiles end Desc,
           case when @sortoption = 'Resource ID' then Resource end,
           case when @sortoption = 'Percent Empty-ASC' then PercentEmpty end Asc,
           case when @sortoption = 'Percent Empty-DESC' then PercentEmpty end Desc	

    End

    Else --include trailer2 *********************************************
    Begin --*************************************************************               

	select mainstops.stp_number,
       	       evt_trailer1 as Resource, 
       	       'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.stp_number = mainstops.stp_number),
       	       'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.stp_number = mainstops.stp_number and stops.stp_loadstatus = 'LD'),
       	       'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where  stops.stp_number = mainstops.stp_number and stops.stp_loadstatus <> 'LD')
	into #worklist4
	from legheader (NOLOCK),stops mainstops (NOLOCK),event (NOLOCK)
	where legheader.lgh_number = mainstops.lgh_number
      	      and 
              mainstops.stp_number = event.stp_number and evt_sequence = 1
              and
              ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
	      OR
              (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
              And
              (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
              And
              lgh_outstatus <> 'CAN'
              And		
              (@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0) 
              And
              (@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0) 
              And
              (@revtype3 = ',,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0) 
              And
              (@revtype4 = ',,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0)
              And  
              (@tractor= ',,' OR CHARINDEX(',' + lgh_tractor + ',', @tractor) > 0)
              And
              (@driver = ',,' OR CHARINDEX(',' + lgh_driver1 + ',', @driver) > 0)
              And
      	      (@drvtype1 = ',,' OR CHARINDEX(',' + mpp_type1 + ',', @drvtype1) > 0) 
              And
              (@drvtype2 = ',,' OR CHARINDEX(',' + mpp_type2  + ',', @drvtype2) > 0) 
              And
              (@drvtype3 = ',,' OR CHARINDEX(',' + mpp_type3  + ',', @drvtype3) > 0) 
              And
              (@drvtype4 = ',,' OR CHARINDEX(',' + mpp_type4  + ',', @drvtype4) > 0)
              And
              (@trltype1 = ',,' OR CHARINDEX(',' + trl_type1 + ',', @trltype1) > 0) 
              And
              (@trltype2 = ',,' OR CHARINDEX(',' + trl_type2  + ',', @trltype2) > 0) 
              And
              (@trltype3 = ',,' OR CHARINDEX(',' + trl_type3  + ',', @trltype3) > 0) 
              And
              (@trltype4 = ',,' OR CHARINDEX(',' + trl_type4  + ',', @trltype4) > 0)
              And
              (@trctype1 = ',,' OR CHARINDEX(',' + trc_type1 + ',', @trctype1) > 0) 
              And
              (@trctype2 = ',,' OR CHARINDEX(',' + trc_type2 + ',', @trctype2) > 0) 
              And
              (@trctype3 = ',,' OR CHARINDEX(',' + trc_type3  + ',', @trctype3) > 0) 
              And
              (@trctype4 = ',,' OR CHARINDEX(',' + trc_type4  + ',', @trctype4) > 0)		
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

	Union

	select mainstops.stp_number,
       	       evt_trailer2 as Resource, 
       	       'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.stp_number = mainstops.stp_number),
       	       'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NOLOCK) where stops.stp_number = mainstops.stp_number and stops.stp_loadstatus = 'LD'),
       	       'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops  (NOLOCK) where  stops.stp_number = mainstops.stp_number and stops.stp_loadstatus <> 'LD')
	from legheader (NOLOCK),stops mainstops (NOLOCK),event (NOLOCK)
	where legheader.lgh_number = mainstops.lgh_number
      	      and 
              mainstops.stp_number = event.stp_number and evt_sequence = 1
              and
              ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
	      OR
              (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
              And
              (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
              And
              lgh_outstatus <> 'CAN'
              And	
              (@revtype1 = ',,' OR CHARINDEX(',' + lgh_class1 + ',', @revtype1) > 0) 
              And
             (@revtype2 = ',,' OR CHARINDEX(',' + lgh_class2 + ',', @revtype2) > 0) 
              And
             (@revtype3 = ',,' OR CHARINDEX(',' + lgh_class3 + ',', @revtype3) > 0) 
              And
             (@revtype4 = ',,' OR CHARINDEX(',' + lgh_class4 + ',', @revtype4) > 0)
              And  
             (@tractor= ',,' OR CHARINDEX(',' + lgh_tractor + ',', @tractor) > 0)
             And
             (@driver = ',,' OR CHARINDEX(',' + lgh_driver1 + ',', @driver) > 0)
             And
             (@drvtype1 = ',,' OR CHARINDEX(',' + mpp_type1 + ',', @drvtype1) > 0) 
             And
             (@drvtype2 = ',,' OR CHARINDEX(',' + mpp_type2  + ',', @drvtype2) > 0) 
             And
             (@drvtype3 = ',,' OR CHARINDEX(',' + mpp_type3  + ',', @drvtype3) > 0) 
             And
             (@drvtype4 = ',,' OR CHARINDEX(',' + mpp_type4  + ',', @drvtype4) > 0)
             And
             (@trltype1 = ',,' OR CHARINDEX(',' + trl_type1 + ',', @trltype1) > 0) 
             And
             (@trltype2 = ',,' OR CHARINDEX(',' + trl_type2  + ',', @trltype2) > 0) 
             And
             (@trltype3 = ',,' OR CHARINDEX(',' + trl_type3  + ',', @trltype3) > 0) 
             And
             (@trltype4 = ',,' OR CHARINDEX(',' + trl_type4  + ',', @trltype4) > 0)
             And

             (@trctype1 = ',,' OR CHARINDEX(',' + trc_type1 + ',', @trctype1) > 0) 
             And
            (@trctype2 = ',,' OR CHARINDEX(',' + trc_type2 + ',', @trctype2) > 0) 
             And
            (@trctype3 = ',,' OR CHARINDEX(',' + trc_type3  + ',', @trctype3) > 0) 
             And
            (@trctype4 = ',,' OR CHARINDEX(',' + trc_type4  + ',', @trctype4) > 0)		
	     And
	     evt_trailer2 <> 'UNKNOWN' --rid of stops that don't have trailer2
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

     --Sum Miles and Group By Trailer
     Select Resource,
            Sum(TravelMiles) as TravelMiles,
            Sum(LoadedMiles) as LoadedMiles,
            Sum(EmptyMiles) as EmptyMiles,
            Case when Sum(IsNull(TravelMiles,0))=0 Then
	 		Cast(0 as Float)
	    Else	
			Cast(Sum(IsNull(EmptyMiles,0)) as float)/Cast(Sum(IsNull(TravelMiles,0)) as float)
	    End as PercentEmpty
     into #finaltrailer2
     from #worklist4
     Group By Resource

    --Sort Table by sort picked by user
    Select Resource,
           TravelMiles,
           LoadedMiles,
           EmptyMiles,
           PercentEmpty
    from #finaltrailer2
    Where 
	   (@trailer = ',,' OR CHARINDEX(',' + Resource + ',', @trailer) > 0)  
    Order By
           case when @sortoption = 'Travel Miles-ASC' then TravelMiles end Asc,
           case when @sortoption = 'Travel Miles-DESC' then TravelMiles end Desc,
           case when @sortoption = 'Loaded Miles-ASC' then LoadedMiles end Asc,
           case when @sortoption = 'Loaded Miles-DESC' then LoadedMiles end Desc,
           case when @sortoption = 'Empty Miles-ASC' then EmptyMiles end Asc,
           case when @sortoption = 'Empty Miles-DESC' then EmptyMiles end Desc,
           case when @sortoption = 'Resource ID' then Resource end,
           case when @sortoption = 'Percent Empty-ASC' then PercentEmpty end Asc,
           case when @sortoption = 'Percent Empty-DESC' then PercentEmpty end Desc		

  End
End










GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWResourceMileage2] TO [public]
GO
