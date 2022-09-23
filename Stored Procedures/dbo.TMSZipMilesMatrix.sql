SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[TMSZipMilesMatrix](@batchId int,@mileageBucket int)
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

--for Zips
--need to get Zip data from company record 
create table #TMWZip (locId varchar(15), zip varchar(20))
insert #TMWZip
select cmp_id, isnull(cmp_zip,(select cy.cty_zip from city cy where cy.cty_code=c.cmp_city)) from company c join #tmsLocation l on c.cmp_id = l.locId
 
select mt_type,mt_origintype, mt_origin,'PlaceHolder' as 'TMW originLat', 'PlaceHolder' as 'TMW originLong',
convert(int,tms_olocation.tmslat*100000) as 'TMS originLat', convert(int,tms_olocation.tmslong*100000) as 'TMS originLong', mt_destinationtype, 
  mt_destination, 'PlaceHolder' as 'TMW destinationLat', 'PlaceHolder' as 'TMW destinationLong',
  convert(int,tms_dlocation.tmslat*100000) as 'TMS destinationLat', convert(int,tms_dlocation.tmslong*100000) as 'TMS destinationLong',
  mt_miles, mt_hours, mt_updatedby, mt_updatedon, timestamp, 
  mt_verified, mt_old_miles, mt_source, mt_Authorized, mt_AuthorizedBy, mt_AuthorizedDate, mt_route, mt_identity, mt_haztype, mt_tolls_cost,
  mt_verified_date, mt_lastused
from mileagetable 
       join #TMWZip as olocation on mt_origin = olocation.zip --and mt_origintype ='L'
       join #TMWZip as dlocation on mt_destination = dlocation.zip --and mt_destinationtype ='L'
       join #tmsLocation as tms_olocation on olocation.locId=tms_olocation.locId
       join #tmsLocation as tms_dlocation on dlocation.locId = tms_dlocation.locId
      where mt_type = @mileageBucket and mt_origintype ='Z' and mt_destinationtype ='Z'

drop table #TMWZip
drop table #tmsLocation
End
GO
GRANT EXECUTE ON  [dbo].[TMSZipMilesMatrix] TO [public]
GO
