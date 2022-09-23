SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[TMSLatLongMilesMatrix](@batchId int,@mileageBucket int)
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

--for latlongs
--need to get LL data from company record and convert format (W = negative, and multiply both by 100000)
--Decimal Degrees = Degrees + minutes/60 + seconds/3600
create table #TMWlatlong (locId varchar(15), tmwLat decimal(12,5), tmwLong decimal(12,5))
insert #TMWlatlong
select cmp_id, isnull((cmp_latseconds/3600.0), (select cty_latitude from city c1 where c1.cty_code=c.cmp_city)), isnull((cmp_longseconds/-3600.0),(select cty_longitude*-1.0 from city c1 where c1.cty_code=c.cmp_city)) from company c join #tmsLocation l on c.cmp_id = l.locId

create table #returnlookup (locId varchar(15), lat decimal(12,5), long decimal(12,5), convertedLat varchar(25), convertedLong varchar(25))
insert #returnlookup
select l.locId, l.tmwlat, l.tmwlong, (case when l.tmwlat>0 then convert(varchar(25),convert(decimal(12,4),l.tmwlat))+'N' else convert(varchar(25),convert(decimal(12,4),(l.tmwlat*-1.0)))+'S' end),
(case when l.tmwlong>0 then convert(varchar(25),convert(decimal(12,4),l.tmwlong))+'E' else convert(varchar(25),convert(decimal(12,4),(l.tmwlong*-1.0)))+'W' end)
 from #TMWlatlong l
 
select mt_type,mt_origintype, mt_origin,convert(int,olocation.lat*100000) as 'TMW originLat', convert(int,olocation.long*100000) as 'TMW originLong',
convert(int,round(olocation.lat,5)*100000) as 'TMS originLat', convert(int,round(olocation.long,5)*100000) as 'TMS originLong', mt_destinationtype, 
  mt_destination, convert(int,dlocation.lat*100000) as 'TMW destinationLat', convert(int,dlocation.long*100000) as 'TMW destinationLong',
  convert(int,round(dlocation.lat,5)*100000) as 'TMS destinationLat', convert(int,round(dlocation.long,5)*100000) as 'TMS destinationLong',
  mt_miles, mt_hours, mt_updatedby, mt_updatedon, timestamp, 
  mt_verified, mt_old_miles, mt_source, mt_Authorized, mt_AuthorizedBy, mt_AuthorizedDate, mt_route, mt_identity, mt_haztype, mt_tolls_cost,
  mt_verified_date, mt_lastused
from mileagetable 
       join #returnlookup as olocation on mt_origin = olocation.convertedLat+','+olocation.convertedLong --and mt_origintype ='L'
       join #returnlookup as dlocation on mt_destination = dlocation.convertedLat+','+dlocation.convertedLong --and mt_destinationtype ='L'
       where mt_type = @mileageBucket and mt_origintype ='L' and mt_destinationtype ='L'

drop table #returnlookup
drop table #TMWlatlong
drop table #tmsLocation
End
GO
GRANT EXECUTE ON  [dbo].[TMSLatLongMilesMatrix] TO [public]
GO
