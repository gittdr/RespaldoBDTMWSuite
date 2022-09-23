SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RptFlowOutboundDetail] --2002_09_13    
 (    
 @LowStartDate    as datetime,    
 @NumDaysOut  as Int,    
 @onlyStartRegions  as varchar(255),    
 @RestrictedLegStatuses  as varchar(255),    
 @onlyOrderStatuses   as varchar(255),    
 @onlyLoadTypes  as varchar(255) ,    
 @MBMinus1DysFrmEndDt int = 600,    
 @MBMinus2DysFrmEndDt int  =1300,    
 @MBMinus3DysFrmEndDt int  =9999,    
 @UDLgStrtDtFrmMBYN Char(1) ='Y')    
AS    
    
/* DM 5/8/02 on site    
    
    
-- 7/11/02 - DM EXCLUDE segments less than 50 miles    
    
    
select * from legheader where lgh_active='Y'    
To used as Open report    
Exec RptFlowOutboundDetail2002_09_13    
 @LowStartDate    ='9/13/02',    
 @NumDaysOut  =3,    
 @onlyStartRegions  ='',    
 @RestrictedLegStatuses  ='CMP,DSP,STD', --    
 @onlyOrderStatuses   ='', --    
 @onlyLoadTypes  ='',    
    
 @MBMinus1DysFrmEndDt =500,    
 @MBMinus2DysFrmEndDt =1300,    
 @MBMinus3DysFrmEndDt =9999,    
 @UDLgStrtDtFrmMBYN ='Y'    
    
--LegStartDateAdj    
    
To use as a regular     
Exec RptFlowOutboundDetail2002_09_13    
 @LowStartDate    ='5/6/02',    
 @NumDaysOut  =1,    
 @onlyStartRegions  ='',    
 @RestrictedLegStatuses  ='', --    
 @onlyOrderStatuses   ='', --    
 @onlyLoadTypes  =''    
    
*/    
    
Declare @EndStartDate datetime    
Set @LowStartDate = Convert(datetime,FLOOR(  convert(float,@LowStartDate)   ) )    
    
Set @EndStartDate = Convert(datetime,    convert(int,@LowStartDate)     + @NumDaysOut )    
    
Set @UDLgStrtDtFrmMBYN =Upper(isNull(@UDLgStrtDtFrmMBYN,'N'))    
    
--select   @LowStartDate     
--select   @EndStartDate    
--Select count(*) from legheader L ,orderheader    
--where L.lgh_startdate between @LowStartDate and @EndStartDate    
-- and    
-- orderheader.ord_hdrnumber= L.ord_hdrnumber    
-- and    
-- L.lgh_outstatus NOT IN ('CMP', 'CAN')    
    
    
    
set @onlyStartRegions = ','+ LTRIM(RTRIM(@onlyStartRegions)) + ','    
set @onlyOrderStatuses  = ','+ LTRIM(RTRIM(@onlyOrderStatuses)) + ','    
set @RestrictedLegStatuses= ','+ LTRIM(RTRIM(@RestrictedLegStatuses)) + ','    
set @onlyLoadTypes = ','+ @onlyLoadTypes + ','    
    
If @onlyorderstatuses = ',ALL,' set @onlyorderstatuses = ',,'    
If @onlyStartRegions = ',ALL,' set @onlyStartRegions = ',,'    
If @onlyLoadTypes = ',ALL,' set @onlyLoadTypes = ',,'    
    
If @onlyorderstatuses = ',UNK,' set @onlyorderstatuses = ',,'    
If @onlyStartRegions = ',UNK,' set @onlyStartRegions = ',,'    
If @onlyLoadTypes = ',UNK,' set @onlyLoadTypes = ',,'    
    
--set @RestrictedLegStatuses     
    
select     
 IsNull(ord_number,'None') OrderNumber,    
     
 Co.cty_region1   Region,    
    
    
    
    
  convert(datetime, convert(varchar(8),Convert(datetime,    
   FLOOR(convert(float,L.lgh_startdate))     
   ),1))    
    
 LegStartDate,    
     
 L.lgh_class2 NetType,    
 Ord_status OrderStatus,    
 Lgh_Outstatus LegStatus,    
 Ord_shipper ShipperID,    
 Co.cty_nmstct OriginCity,    
 CD.cty_nmstct DestCity,    
 LoadedMilesLeg=    
  (select sum(isNull(s2.stp_ord_mileage,0)) from stops s2(nolock) where s2.lgh_number=L.lgh_number),    
 TrvlMilesLeg=    
  (select sum(isNull(s2.stp_lgh_mileage,0)) from stops s2(nolock) where s2.lgh_number=L.lgh_number),    
 LoadedMilesOrder=    
  (select sum(isNull(s2.stp_ord_mileage,0)) from stops s2(nolock) where s2.mov_number=L.mov_number),    
    
    
 --L.lgh_startdate,    
 L.lgh_schdtearliest,    
 L.lgh_Enddate,    
 lgh_split_flag,    
 L.mov_number,    
 L.lgh_class2,    
 L.lgh_startdate,    
 convert(datetime, '19500101') LegStartDateAdj,    
 L.lgh_number    
    
INTO #TEMP    
    
    
    
from  legheader L(nolock),    
 city Co(nolock),    
 stops(nolock),    
 orderheader(nolock),    
 city Cd (nolock)   
    
where     
 --L.lgh_startdate between @LowStartDate and @EndStartDate    
    
-- KMM TEST    
 l.lgh_active = 'Y'     
 AND    
    
 L.lgh_schdtearliest between @LowStartDate and @EndStartDate    
 AND     
 L.lgh_startcity = Co.cty_code     
 AND    
 --L.lgh_outstatus NOT IN ('CMP', 'CAN')    
    
 lgh_outstatus<>'CAN'    
and    
 lgh_outstatus <> 'PLN'    
 and    
 stops.lgh_number= L.lgh_number    
 and    
 stops.stp_mfh_sequence =    
 (select max(stp_mfh_sequence) from stops(nolock) where stops.lgh_number=L.lgh_number)    
 AND    
 orderheader.ord_hdrnumber=L.ord_hdrnumber    
 and    
 CD.cty_code=L.lgh_endcity     
 AND    
 (@onlyOrderStatuses = ',,' OR CHARINDEX(Ord_status, @onlyOrderStatuses) > 0)     
 AND     
    
 (@onlyStartRegions = ',,' OR CHARINDEX(',' + co.cty_region1 + ',', @onlyStartRegions) >     
    
0)       
 and    
-- (@RestrictedLegStatuses ='' OR L.lgh_outstatus NOT IN (@RestrictedLegStatuses))       
 (@RestrictedLegStatuses = ',,' OR CHARINDEX(L.lgh_outstatus, @restrictedLegStatuses ) =     
    
0)     
/*    
UNION    
select     
 'None' OrderNumber,    
     
 Co.cty_region1   Region,    
    
    
    
    
  convert(varchar(8),Convert(datetime,    
   FLOOR(convert(float,L.lgh_startdate))     
   ),1)     
    
 LegStartDate,    
     
 L.lgh_class2 NetType,    
 IsNull(lgh_outstatus,'') OrderStatus,    
 Lgh_Outstatus LegStatus,    
 --IsNull(NONE,'') ShipperID,    
 'NONE' ShipperID,    
 Co.cty_nmstct OriginCity,    
 CD.cty_nmstct DestCity,    
 LoadedMilesLeg=    
  (select sum(isNull(s2.stp_ord_mileage,0)) from stops s2 where     
    
s2.lgh_number=L.lgh_number),    
 TrvlMilesLeg=    
  (select sum(isNull(s2.stp_lgh_mileage,0)) from stops s2 where     
    
s2.lgh_number=L.lgh_number),    
 LoadedMilesOrder=    
  (select sum(isNull(s2.stp_ord_mileage,0)) from stops s2 where     
    
s2.mov_number=L.mov_number),    
    
    
 L.lgh_startdate,    
 L.lgh_Enddate,    
 lgh_split_flag,    
 Mov_number    
    
    
    
    
    
    
from  legheader L,    
 city Co,    
 stops,    
 --orderheader,    
 city Cd    
    
where     
 L.lgh_startdate between @LowStartDate and @EndStartDate    
 AND     
 L.lgh_startcity = Co.cty_code     
 AND    
 --L.lgh_outstatus NOT IN ('CMP', 'CAN')    
    
 lgh_outstatus<>'CAN'    
 and    
 stops.lgh_number= L.lgh_number    
 and    
 stops.stp_mfh_sequence =    
 (select max(stp_mfh_sequence) from stops where stops.lgh_number=L.lgh_number)    
 AND    
 (L.ord_hdrnumber =0 or L.ord_hdrnumber is Null)    
 AND    
 --L.ord_hdrnumber *= orderheader.ord_hdrnumber --=L.ord_hdrnumber    
 --and    
 CD.cty_code=L.lgh_endcity     
 AND    
 (@onlyOrderStatuses = ',,' OR CHARINDEX(lgh_outstatus, @onlyOrderStatuses) > 0)     
 AND     
    
 (@onlyStartRegions = ',,' OR CHARINDEX(',' + co.cty_region1 + ',', @onlyStartRegions) >     
    
0)       
 and    
--@RestrictedLegStatuses ='' OR L.lgh_outstatus NOT IN (@RestrictedLegStatuses))       
    
-- (@RestrictedLegStatuses ='' OR L.lgh_outstatus NOT IN (@RestrictedLegStatuses))       
 (@RestrictedLegStatuses = ',,' OR CHARINDEX(L.lgh_outstatus, @restrictedLegStatuses ) =     
    
0)     
    
*/    
    
    
/*    
Group by  cty_region1,    
  Convert(datetime,    
   FLOOR(convert(float,L.lgh_startdate))     
  ),    
 L.lgh_class2    
*/    
Update #TEMP    
 Set NetType ='NET'    
 where TrvlMilesLeg>= 250    
 AND NetType <>'WAS'    
    
Update #TEMP    
 Set NetType ='REG'    
 where TrvlMilesLeg< 250    
 AND NetType <>'WAS'    
    
    
/*    
9/13/2002    
    
    
    
*/      
Update     
 #TEMP    
    
 Set LegStartDateAdj =    
    
  Convert(datetime,FLOOR(convert(float,Dateadd(d,-1, lgh_Enddate))))    
 Where    
  TrvlMilesLeg <=@MBMinus1DysFrmEndDt    
     
         
    
Update     
 #TEMP    
    
 Set LegStartDateAdj =    
    
  convert (datetime,FLOOR(convert(float,Dateadd(d,-2, lgh_Enddate))))    
 Where    
  TrvlMilesLeg >@MBMinus1DysFrmEndDt       
  AND    
  TrvlMilesLeg <=@MBMinus2DysFrmEndDt       
     
Update     
 #TEMP    
    
 Set LegStartDateAdj =    
    
  Convert(datetime,FLOOR(convert(float,Dateadd(d,-3, lgh_Enddate))))    
 Where    
  TrvlMilesLeg >@MBMinus2DysFrmEndDt       
  AND    
  TrvlMilesLeg <=@MBMinus3DysFrmEndDt       
     
-- Can make it earlier than CurrentStart!    
Update     
 #TEMP    
    
 Set LegStartDateAdj =convert(datetime,LegStartDate)    
 WhERE    
  Convert(dateTime,LegStartDateAdj)    
  <    
  Convert(dateTime,LegStartDate)    
    
    
If @UDLgStrtDtFrmMBYN='Y'    
BEGIN    
Update     
 #TEMP    
    
 Set LegStartDate =LegStartDateAdj    
    
END    
      
     
    
/*    
Select 'debug start'    
Select      
 LegStartDateAdj AdjStartDt,    
 LegStartDate,    
 TrvlMilesLeg TrvMiles,    
 convert(varchar(5),lgh_Enddate,1) + ' ' +convert(varchar(5),lgh_Enddate,8) RawLegEndDt,    
 convert(varchar(5),lgh_Startdate,1) + ' ' +convert(varchar(5),lgh_Startdate,8) RawLegStrtDt,    
 Left(OriginCity,15) OriginCity,                    
 left(DestCity,15) DestCity,     
 LoadedMilesLeg LdMiles,                     
 Region,     
 NetType,    
 OrderStatus,     
 LegStatus,     
    
    
 *    
From #Temp    
where TrvlMilesLeg>50    
-- 08/06/02 exclude DED- dedicated loads    
and    
lgh_class2 <>'DED'    
Select 'debug End'    
*/    
    
Select  * from #TEMP     
where  TrvlMilesLeg>50 and    
 lgh_class2 <> 'DED'    
    
    
    
GO
GRANT EXECUTE ON  [dbo].[RptFlowOutboundDetail] TO [public]
GO
