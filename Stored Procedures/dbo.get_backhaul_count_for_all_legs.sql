SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  procedure [dbo].[get_backhaul_count_for_all_legs] (@mile_radius int, @days_out tinyint)
as
begin
 
       declare @miles_as_meters int
       set @miles_as_meters = @mile_radius * 1609.344
       set @days_out = @days_out + 1
       create table #DISTINCT_START_CITIES (start_cty int primary key clustered)
       create table #DISTINCT_END_CITIES (end_cty int primary key clustered)  
 
       -- My active trips that I need to find a backhaul for / distinct cities to put into the Cartesian product
       insert into #DISTINCT_START_CITIES (start_cty)
       select lgh_startcity from legheader_active where lgh_startcity is not null
       and lgh_outstatus in ('AVL', 'STD', 'PLN', 'CMP')
       group by lgh_startcity order by lgh_startcity
 
       -- trips that could be potential back hauls / distinct cities to put into the Cartesian product
       insert into #DISTINCT_END_CITIES (end_cty)
       select lgh_endcity from legheader_active where lgh_endcity is not null
       and lgh_outstatus= 'AVL' --and lgh_startdate < (2 days)
       group by lgh_endcity order by lgh_endcity
 
       --CTE goes with stmt below
       ;WITH
       DISTINCT_CITY_COMBOS (start_cty, end_cty) AS
       (
              select start_cty, end_cty from 
              #DISTINCT_START_CITIES, #DISTINCT_END_CITIES
       )
       --Gets all possible returns for any leg, within 3 days and 20 miles.
       select las.lgh_number, count(*) as Possible_Returns from
       DISTINCT_CITY_COMBOS d 
       inner join city s with (INDEX(ix_city_citypoint)) on d.start_cty = s.cty_code --have to hard code index hint with spatial data in SQL 2008 & SQL 2008 R2 versions.
       inner join city e on d.end_cty = e.cty_code
       inner join legheader_active las on las.lgh_startcity = d.start_cty
       inner join legheader_active lae on lae.lgh_endcity = d.end_cty
       where s.citypoint.STDistance(e.citypoint) < @miles_as_meters
       --the lgh_enddate of the starting lgh is less than 3 days apart from the lgh_startdate of the next lgh.
       and las.lgh_enddate < lae.lgh_startdate
       and datediff(dd, las.lgh_enddate,lae.lgh_startdate) < @days_out 
       and las.lgh_number <> lae.lgh_number
       and las.lgh_outstatus in ('AVL', 'STD', 'PLN', 'CMP')
       and lae.lgh_outstatus = 'AVL'
       group by las.lgh_number
       order by las.lgh_number
end
GO
GRANT EXECUTE ON  [dbo].[get_backhaul_count_for_all_legs] TO [public]
GO
