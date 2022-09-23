SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE                                                  Procedure [dbo].[sp_TTSTMWResourceMileage]
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

SELECT @trltype1 = ',' + LTRIM(RTRIM(ISNULL(@trltype1, ''))) + ','
SELECT @trltype2 = ',' + LTRIM(RTRIM(ISNULL(@trltype2, ''))) + ','
SELECT @trltype3 = ',' + LTRIM(RTRIM(ISNULL(@trltype3, ''))) + ',' 
SELECT @trltype4 = ',' + LTRIM(RTRIM(ISNULL(@trltype4, ''))) + ',' 

SELECT @trctype1 = ',' + LTRIM(RTRIM(ISNULL(@trctype1, ''))) + ','
SELECT @trctype2 = ',' + LTRIM(RTRIM(ISNULL(@trctype2, ''))) + ','
SELECT @trctype3 = ',' + LTRIM(RTRIM(ISNULL(@trctype3, ''))) + ',' 
SELECT @trctype4 = ',' + LTRIM(RTRIM(ISNULL(@trctype4, ''))) + ',' 

SELECT @dispatchstatus = ',' + LTRIM(RTRIM(ISNULL(@dispatchstatus, ''))) + ',' 

If @resourcetype = 'driver' --driver *************************************
Begin			    --********************************************


   If @includeteamresource = 'N' --Just Driver1***************************
   Begin			 --********************************************

       --Group records by legheaders for the move
       --and restrict on any driver types or driver id's if they are given
       select legheader.lgh_driver1 as Resource,
       	      lgh_number,
              'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.lgh_number = legheader.lgh_number),
              'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.lgh_number = legheader.lgh_number and stops.stp_loadstatus = 'LD'),
              'EmptyMiles' = (Select IsNUll(sum(stp_lgh_mileage),0) from stops where  stops.lgh_number = legheader.lgh_number  and stops.stp_loadstatus <> 'LD')
       into #worklist
       from legheader
       where ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
             OR
             (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
             And 
             (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
	     And
             lgh_outstatus <> 'CAN'
             And
             (lgh_startdate between @frmdt and @tdt ) 
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
             (@trailer= ',,' OR CHARINDEX(',' + lgh_primary_trailer + ',', @trailer) > 0)
             And
             (@driver= ',,' OR CHARINDEX(',' + lgh_driver1 + ',', @driver) > 0)
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
        Group By legheader.lgh_driver1,lgh_number

	--Sum Miles and Group By Driver
        Select Resource,
             IsNull(mpp_firstname + ' ' + mpp_lastname,'') as DriverName,
             IsNull(mpp_lastname,'') as DriverLastName,
             Cast(Sum(IsNull(TravelMiles,0)) as float) as TravelMiles,
             Cast(Sum(IsNull(LoadedMiles,0)) as float) as LoadedMiles,
             Cast(Sum(IsNull(EmptyMiles,0)) as float) as EmptyMiles,
	 
             	        Case when Sum(IsNull(TravelMiles,0))=0 Then
	 			 Cast(0 as Float)
			Else	
			         Cast(Sum(IsNull(EmptyMiles,0)) as float)/Cast(Sum(IsNull(TravelMiles,0)) as float)
			End as PercentEmpty

             --IF(Sum(TravelMiles)=0,0,) as PercentEmpty)
        into #finaldriver
        from #worklist Left Join manpowerprofile on manpowerprofile.mpp_id = #worklist.Resource
        Group By Resource,mpp_firstname,mpp_lastname

	--Sort Table by sort picked by user
	Select IsNull(Resource,'') as Resource,
       	       IsNull(DriverName,'') as DriverName,
               TravelMiles,
               LoadedMiles,
               EmptyMiles,
               PercentEmpty
       from #finaldriver
       Order By
       	       case when @sortoption = 'Travel Miles-ASC' then TravelMiles end Asc,
               case when @sortoption = 'Travel Miles-DESC' then TravelMiles end Desc,
               case when @sortoption = 'Loaded Miles-ASC' then LoadedMiles end Asc,
               case when @sortoption = 'Loaded Miles-DESC' then LoadedMiles end Desc,
               case when @sortoption = 'Empty Miles-ASC' then EmptyMiles end Asc,
               case when @sortoption = 'Empty Miles-DESC' then EmptyMiles end Desc,
               case when @sortoption = 'Resource ID' then Resource end,
               case when @sortoption = 'Driver Last Name' then DriverLastName end,
               case when @sortoption = 'Percent Empty-ASC' then PercentEmpty end Asc,
               case when @sortoption = 'Percent Empty-DESC' then PercentEmpty end Desc

   End
   
   Else --Include Driver2*************************************************

   Begin--****************************************************************
        
        --First Get Driver 1 Miles
       select legheader.lgh_driver1 as Resource,
       	       lgh_number,
               'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.lgh_number = legheader.lgh_number),
               'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.lgh_number = legheader.lgh_number and stops.stp_loadstatus = 'LD'),
               'EmptyMiles' = (Select IsNUll(sum(stp_lgh_mileage),0) from stops where  stops.lgh_number = legheader.lgh_number  and stops.stp_loadstatus <> 'LD')
       into #teamdrivers
       from legheader
       where ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
             OR
             (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
             And 
             (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
	     And
             lgh_outstatus <> 'CAN'
             And
             (lgh_startdate between @frmdt and @tdt ) 
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
             (@trailer= ',,' OR CHARINDEX(',' + lgh_primary_trailer + ',', @trailer) > 0)
             And
	     (@driver= ',,' OR CHARINDEX(',' + lgh_driver1 + ',', @driver) > 0)
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
        Group By legheader.lgh_driver1,lgh_number

	Union


        --Get Driver2 Miles and exclude Unknowns
	select legheader.lgh_driver2 as Resource,
       	       lgh_number,
               'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.lgh_number = legheader.lgh_number),
               'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.lgh_number = legheader.lgh_number and stops.stp_loadstatus = 'LD'),
               'EmptyMiles' = (Select IsNUll(sum(stp_lgh_mileage),0) from stops where  stops.lgh_number = legheader.lgh_number  and stops.stp_loadstatus <> 'LD')
        from legheader
        where 
             ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
             OR
             (@DateType='End Date' and lgh_enddate between @frmdt and @tdt )) 
             And 
             (@dispatchstatus = ',,' OR CHARINDEX(',' + lgh_outstatus + ',', @dispatchstatus) > 0)             
	     And
             lgh_outstatus <> 'CAN'
             And
             (lgh_startdate between @frmdt and @tdt ) 
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
             (@trailer= ',,' OR CHARINDEX(',' + lgh_primary_trailer + ',', @trailer) > 0)
             And
             (@driver= ',,' OR CHARINDEX(',' + lgh_driver2 + ',', @driver) > 0)
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
             lgh_driver2 <> 'UNKNOWN'
	Group By legheader.lgh_driver2,lgh_number

	--Sum Miles and Group By Driver
        Select Resource,
             mpp_firstname + ' ' + mpp_lastname as DriverName,
             mpp_lastname as DriverLastName,
             Sum(TravelMiles) as TravelMiles,
             Sum(LoadedMiles) as LoadedMiles,
             Sum(EmptyMiles) as EmptyMiles,
             		Case when Sum(IsNull(TravelMiles,0))=0 Then
	 			 Cast(0 as Float)
			Else	
			         Cast(Sum(IsNull(EmptyMiles,0)) as float)/Cast(Sum(IsNull(TravelMiles,0)) as float)
			End as PercentEmpty
        into #finaldriver2
        from #teamdrivers Left Join manpowerprofile on manpowerprofile.mpp_id = #teamdrivers.Resource
        Group By Resource,mpp_firstname,mpp_lastname

	--Sort Table by sort picked by user
	Select Resource,
       	       DriverName,
               TravelMiles,
               LoadedMiles,
               EmptyMiles,
               PercentEmpty
        from #finaldriver2
        Order By
       	       case when @sortoption = 'Travel Miles-ASC' then TravelMiles end Asc,
               case when @sortoption = 'Travel Miles-DESC' then TravelMiles end Desc,
               case when @sortoption = 'Loaded Miles-ASC' then LoadedMiles end Asc,
               case when @sortoption = 'Loaded Miles-DESC' then LoadedMiles end Desc,
               case when @sortoption = 'Empty Miles-ASC' then EmptyMiles end Asc,
               case when @sortoption = 'Empty Miles-DESC' then EmptyMiles end Desc,
               case when @sortoption = 'Resource ID' then Resource end,
               case when @sortoption = 'Driver Last Name' then DriverLastName end,
     	       case when @sortoption = 'Percent Empty-ASC' then PercentEmpty end Asc,
               case when @sortoption = 'Percent Empty-DESC' then PercentEmpty end Desc
   End	

End

Else If @resourcetype = 'tractor' --tractor *************************************
Begin                             --********************************************

--Group records by legheaders for the move
--and restrict on any tractor types or tractor id's if any are given
select legheader.lgh_tractor as Resource,
       lgh_number,
       'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.lgh_number = legheader.lgh_number),
       'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.lgh_number = legheader.lgh_number and stops.stp_loadstatus = 'LD'),
       'EmptyMiles' = (Select IsNUll(sum(stp_lgh_mileage),0) from stops where  stops.lgh_number = legheader.lgh_number  and stops.stp_loadstatus <> 'LD')
into #worklist2
from legheader
where ((@DateType='Start Date' and lgh_startdate between @frmdt and @tdt )
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
      (@trailer = ',,' OR CHARINDEX(',' + lgh_primary_trailer + ',', @trailer) > 0)
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
Group By legheader.lgh_tractor,lgh_number

--Sum Miles and Group By Tractor
Select Resource,
       Sum(TravelMiles) as TravelMiles,
       Sum(LoadedMiles) as LoadedMiles,
       Sum(EmptyMiles) as EmptyMiles,
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

Else --trailer
Begin

    If @includeteamresource = 'N' --just trailer1 *************************************
    Begin	                  --********************************************

	select mainstops.stp_number,
       	       evt_trailer1 as Resource, 
       	       'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.stp_number = mainstops.stp_number),
       	       'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.stp_number = mainstops.stp_number and stops.stp_loadstatus = 'LD'),
       	       'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where  stops.stp_number = mainstops.stp_number and stops.stp_loadstatus <> 'LD')
	into   #worklist3
	from   legheader,stops mainstops,event
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
       	       'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.stp_number = mainstops.stp_number),
       	       'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.stp_number = mainstops.stp_number and stops.stp_loadstatus = 'LD'),
       	       'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where  stops.stp_number = mainstops.stp_number and stops.stp_loadstatus <> 'LD')
	into #worklist4
	from legheader,stops mainstops,event
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

	Union

	select mainstops.stp_number,
       	       evt_trailer2 as Resource, 
       	       'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.stp_number = mainstops.stp_number),
       	       'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where stops.stp_number = mainstops.stp_number and stops.stp_loadstatus = 'LD'),
       	       'EmptyMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops where  stops.stp_number = mainstops.stp_number and stops.stp_loadstatus <> 'LD')
	from legheader,stops mainstops,event
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
GRANT EXECUTE ON  [dbo].[sp_TTSTMWResourceMileage] TO [public]
GO
