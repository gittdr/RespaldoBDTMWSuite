SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


        
        
CREATE proc [dbo].[SSRS_RB_RateHistoryByLane]        
 (@SearchType varchar(1),      
  @OriginCityName as varchar(200),        
--  @OriginST as varchar(10),        
  @OriginRadius as int,        
  @DestCityName as varchar(200),        
--  @DestST as varchar(10),        
  @DestRadius as int,        
  @StartDate as datetime,        
  @EndDate as datetime,      
  @Carrier as varchar(200),      
  @BillTo as varchar(200),    
  @LoadType as varchar(max)    
 -- @ReqEquip as varchar(max)
 )        
          
as          
        
-- SSRS_RB_RateHistoryByLane 'C','chicago,il',1275,'minneapolis,mn',1275,'2012-01-01','2014-09-30'  ,'',''  ,''    
      
-- SSRS_RateHistoryByLane 'Z','19711',75,'088250',75,'2010-01-01','2010-03-31','','C'      
        
set transaction isolation level read uncommitted        
        
declare @OriginCityCode as int        
declare @OriginCityLat as dec(12,4)        
declare @OriginCityLong as dec(12,4)        
declare @DestCityCode as int        
declare @DestCityLat as dec(12,4)        
declare @DestCityLong as dec(12,4)        
declare @LaneMiles as float        
        
        
set @OriginCityName  = replace(@OriginCityName,', ','')      
set @DestCityName  = replace(@DestCityName,', ','')      
      
      
      
set @LoadType = ',' + @LoadType + ','      
--set @ReqEquip = ',' + @ReqEquip + ','      
--select @OriginCityName        
      
      
if @SearchType = 'C'       
 begin        
  select top 1         
   @OriginCityCode = cty_code,        
   @OriginCityLat = cty_latitude,        
   @OriginCityLong = cty_longitude        
  from city where cty_nmstct like @OriginCityName + '%'      
          
  select top 1         
   @DestCityCode = cty_code,        
   @DestCityLat = cty_latitude,        
   @DestCityLong = cty_longitude        
  from city where cty_nmstct like @DestCityName + '%'      
 end      
else      
 begin        
  select top 1         
   @OriginCityCode = cty_code,        
   @OriginCityLat = cty_latitude,        
   @OriginCityLong = cty_longitude        
  from city where      
   cty_code = (select top 1 cmp_city from company where cmp_zip = @OriginCityName)      
          
  select top 1         
   @DestCityCode = cty_code,        
   @DestCityLat = cty_latitude,        
   @DestCityLong = cty_longitude        
  from city where      
   cty_code = (select top 1 cmp_city from company where cmp_zip = @DestCityName)      
 end      
      
        
        
        
set @LaneMiles =  (select MAX(mt_miles) from mileagetable         
where (mt_origintype = 'C' and mt_origin = rtrim(ltrim(CAST(@OriginCityCode as varchar(200))))        
    and        
    mt_destinationtype= 'C' and mt_destination = rtrim(ltrim(CAST(@DestCityCode as varchar(200)))))        
  or         
   (mt_origintype = 'C' and mt_origin =  rtrim(ltrim(CAST(@DestCityCode as varchar(200))))        
    and        
    mt_destinationtype = 'C' and mt_destination =  rtrim(ltrim(CAST(@OriginCityCode as varchar(200)))))        
   )        
        
        

declare @TempOriginCity table        
 (OriginCity int)        
         
declare @TempDestCity table        
 (DestCity int)        
        
        
insert into @TempOriginCity        
select         
 cty_code        
from city         
where cty_code > 0 and cty_latitude is not null         
   and cty_latitude between (@OriginCityLat + (@OriginRadius * -0.0145)) and (@OriginCityLat + (@OriginRadius * 0.0145))        
   and cty_longitude between (@OriginCityLong + (@OriginRadius * -0.0200)) and (@OriginCityLong + (@OriginRadius * 0.0200))         
   and dbo.[TMWSSRS_fnc_AirMilesBetweenCityCodes](@OriginCityCode,cty_code) < @DestRadius        
        
        
--select *         
--from city        
--where cty_code in (select * from @TempOriginCity)        
        
        
        
insert into @TempDestCity        
select         
 cty_code        
from city         
where cty_code > 0 and cty_latitude is not null         
   and cty_latitude between (@DestCityLat + (@DestRadius * -0.0145)) and (@DestCityLat + (@DestRadius * 0.0145))        
   and cty_longitude between (@DestCityLong + (@DestRadius * -0.0200)) and (@DestCityLong + (@DestRadius * 0.0200))         
   and dbo.[TMWSSRS_fnc_AirMilesBetweenCityCodes](@DestCityCode,cty_code) < @DestRadius        
--select * from @TempDestCity        
        
select           
 ivh.ivh_revtype1 'Load Type',    
 RevType2.label_extrastring1 'Req Equip',    
 (select count(0) from stops where stops.ord_hdrnumber = ivh.ord_hdrnumber) 'Stop Count',    
 isnull(@OriginCityCode,-100) as 'Origin Search',        
 isnull(@DestCityCode,-100) as 'Dest Search',        
 isnull(@LaneMiles,-100) as 'Lane Miles',        
 octy.cty_nmstct 'Origin City',      
 ivh.ivh_originzipcode,         
 dCty.cty_nmstct 'Dest City',      
 ivh.ivh_destzipcode,        
 ivh.ivh_deliverydate 'Delivery Date',        
 ivh.ivh_shipdate 'Ship Date',         
 ivh.ivh_totalmiles 'Billed Miles',        
 ivh.ivh_billto 'Bill To',        
 BillTo.cmp_name as 'Bill To Name',      
 ivh.ivh_totalcharge 'Total Rev',        
 ivh.ivh_charge 'Linehaul Rev',        
-- LoadedMiles.Miles 'Traveled Miles',        
-- OrderPay.Pay,         
 car.car_name 'Carrier',        
 substring(car.car_phone1,1,3) + '-' + substring(car.car_phone1,4,3) + '-' + substring(car.car_phone1,7,4) 'Carrier Phone',         
 dbo.[TMWSSRS_fnc_AirMilesBetweenCityCodes](@OriginCityCode,ivh.ivh_origincity) 'Distance from Search Orgin',        
 dbo.[TMWSSRS_fnc_AirMilesBetweenCityCodes](@DestCityCode,ivh.ivh_destcity) 'Distance from Search Destination',        
 ivh.ord_hdrnumber      
         
into #TempInvoice        
from invoiceheader ivh        
 inner join company BillTo on BillTo.cmp_id = ivh.ivh_billto      
 inner join city oCty on oCty.cty_code = ivh.ivh_origincity        
 inner join city dCty on dCty.cty_code = ivh.ivh_destcity        
 inner join carrier car on car.car_id = ivh.ivh_carrier        
 inner join @TempOriginCity TempOrginCity on TempOrginCity.OriginCity = ivh.ivh_origincity        
 inner join @TempDestCity TempDestCity on TempDestCity.DestCity = ivh.ivh_destcity         
 inner join labelfile RevType1 on RevType1.abbr = ivh.ivh_revtype1 and RevType1.labeldefinition = 'RevType1'    
 inner join labelfile RevType2 on RevType2.abbr = ivh.ivh_revtype2 and RevType2.labeldefinition = 'RevType2'    
 --inner join (select SUM(pyd_amount) 'Pay', ord_hdrnumber from paydetail pyd         
 --    where isnull(pyd.ord_hdrnumber,0) > 0         
 --    group by pyd.ord_hdrnumber) OrderPay on OrderPay.ord_hdrnumber = ivh.ord_hdrnumber        
 --inner join (select sum(stp_lgh_mileage) 'Miles', ord_hdrnumber from stops        
 --    where isnull(stops.ord_hdrnumber,0) > 0 and stops.stp_loadstatus = 'LD'         
 --    group by stops.ord_hdrnumber) LoadedMiles on LoadedMiles.ord_hdrnumber = ivh.ord_hdrnumber        
where ivh.ord_hdrnumber > 0 and  ivh.ivh_deliverydate between @StartDate and DATEADD(ss,86399,@EndDate)        
   and ivh.ivh_carrier <> 'UNKNOWN'        
   and (car.car_name like @Carrier + '%' or @Carrier = '')      
   and (BillTo.cmp_name like @BillTo + '%' or @BillTo = '')       
  -- and (charindex(',' + ivh.ivh_revtype1 + ',',@LoadType,1) > 0)    
 --  and (charindex(',' + RevType2.label_extrastring1 + ',',@ReqEquip,1) > 0)    
 --  and ivh.ivh_totalcharge > 150     
        
--select * from      #TempInvoice   
        
select        
 @OriginCityCode 'Origin Lookup Code',      
 @DestCityCode 'Dest Lookup Code',      
 ti.*,        
 OrderPay.Pay,    
 LHPay.Pay 'LH Pay',    
 AccPay.Pay 'Acc Pay',        
 LoadedMiles.Miles 'Traveled Miles',        
 case when LoadedMiles.Miles > 0 then        
   LHPay.Pay/LoadedMiles.Miles        
 else         
  0.00        
 end 'Pay per Mile',        
 case when LoadedMiles.Miles > 0 then        
   ti.[Total Rev]/LoadedMiles.Miles        
 else         
  0.00        
 end 'Rev per Mile'        
         
from #TempInvoice ti        
 inner join (select SUM(pyd_amount) 'Pay', ord_hdrnumber from paydetail pyd         
     where isnull(pyd.ord_hdrnumber,0) > 0         
     group by pyd.ord_hdrnumber) OrderPay on OrderPay.ord_hdrnumber = ti.ord_hdrnumber        
         
left join (select SUM(pyd_amount) 'Pay', ord_hdrnumber from paydetail pyd     
  inner join paytype pyt on pyt.pyt_itemcode = pyd.pyt_itemcode        
     where isnull(pyd.ord_hdrnumber,0) > 0  and (pyt.pyt_basis = 'LGH' or pyd.pyt_itemcode in ('FUELRE','FUELMI','BRKFUL'))    
     group by pyd.ord_hdrnumber) LHPay on LHPay.ord_hdrnumber = ti.ord_hdrnumber     
         
    
left join (select SUM(pyd_amount) 'Pay', ord_hdrnumber from paydetail pyd     
  inner join paytype pyt on pyt.pyt_itemcode = pyd.pyt_itemcode        
     where isnull(pyd.ord_hdrnumber,0) > 0  and (pyt.pyt_basis <> 'LGH' and pyd.pyt_itemcode not in ('FUELRE','FUELMI','BRKFUL'))    
     group by pyd.ord_hdrnumber) AccPay on AccPay.ord_hdrnumber = ti.ord_hdrnumber             
          
          
          
          
 inner join (select sum(stp_lgh_mileage) 'Miles', ord_hdrnumber from stops        
     where isnull(stops.ord_hdrnumber,0) > 0 and stops.stp_loadstatus = 'LD'         
     group by stops.ord_hdrnumber) LoadedMiles on LoadedMiles.ord_hdrnumber = ti.ord_hdrnumber        
        
--where OrderPay.Pay > 150         
        
--OrderPay.Pay,        
--inner join (select SUM(pyd_amount) 'Pay', ord_hdrnumber from paydetail pyd         
--       where isnull(pyd.ord_hdrnumber,0) > 0         
--       group by pyd.ord_hdrnumber) OrderPay on OrderPay.ord_hdrnumber = ivh.ord_hdrnumber 



GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_RateHistoryByLane] TO [public]
GO
