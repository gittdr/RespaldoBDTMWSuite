SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[TMSCityMilesMatrix](@batchId int,@mileageBucket int)
as 
Begin
--Gets list of all TMS stop location Id's per batch for mileage processing
create table #tmsLocation(locId varchar(15), tmsLat decimal(12,5), tmsLong decimal(12,5))
insert #tmsLocation
SELECT     distinct s1.LocationId as locId, s1.LocationLat as tmsLat, s1.LocationLong as tmsLong
            FROM dbo.TMSOrder AS i 
                  LEFT OUTER JOIN dbo.TMSStops AS s1 ON s1.OrderId = i.OrderId AND s1.StopType = 'PUP' where OptBatch=@batchId 
            union 
            SELECT     distinct s2.LocationId, s2.LocationLat, s2.LocationLong
            FROM dbo.TMSOrder AS i 
                  LEFT OUTER JOIN dbo.TMSStops AS s2 ON s2.OrderId = i.OrderId AND s2.StopType = 'DRP' where OptBatch=@batchId 

--for City
--need to get City data from company record 
create table #TMWCity (locId varchar(15), city varchar(20))
insert #TMWCity
select cmp_id, (select left(cty_nmstct, NULLIF(charindex('/', cty_nmstct)-1,-1)) from city  where cty_code=c.cmp_city) from company c join #tmsLocation l on c.cmp_id = l.locId

select mt_type,mt_origintype, mt_origin,'PlaceHolder' as 'TMW originLat', 'PlaceHolder' as 'TMW originLong',
convert(int,tms_olocation.tmslat*100000) as 'TMS originLat', convert(int,tms_olocation.tmslong*100000) as 'TMS originLong', mt_destinationtype, 
  mt_destination, 'PlaceHolder' as 'TMW destinationLat', 'PlaceHolder' as 'TMW destinationLong',
  convert(int,tms_dlocation.tmslat*100000) as 'TMS destinationLat', convert(int,tms_dlocation.tmslong*100000) as 'TMS destinationLong',
  mt_miles, mt_hours, mt_updatedby, mt_updatedon, timestamp, 
  mt_verified, mt_old_miles, mt_source, mt_Authorized, mt_AuthorizedBy, mt_AuthorizedDate, mt_route, mt_identity, mt_haztype, mt_tolls_cost,
  mt_verified_date, mt_lastused
from mileagetable 
       join #TMWCity as olocation on mt_origin = olocation.city --and mt_origintype ='L'
       join #TMWCity as dlocation on mt_destination = dlocation.city --and mt_destinationtype ='L'
       join #tmsLocation as tms_olocation on olocation.locId=tms_olocation.locId
       join #tmsLocation as tms_dlocation on dlocation.locId = tms_dlocation.locId
      where mt_type = @mileageBucket and mt_origintype ='C' and mt_destinationtype ='C'

drop table #TMWCity
drop table #tmsLocation
End
GO
GRANT EXECUTE ON  [dbo].[TMSCityMilesMatrix] TO [public]
GO
