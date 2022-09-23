SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[getroutes_sp] (@p_type varchar(15),@p_key int )

AS

/**
 * 
 * NAME:
 * getorderroutes_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: NONE
 *
 * RESULT SETS: \
 * rth_id    route ID
 * rth_name  route name
 * (order by) priority = number of stops where route was defined as a specific company location
 *           as opposed to a generic city or zip.  Places routes with more company locations nearer top
 *
 * PARAMETERS: @p_type	varchar(15) 'O' for order (billing)  Routes 'L' for leg (settlements) routes
 *
 * REVISION HISTORY:
 * 10/06/2006.01 ? PTS33644 - DPETE ? Created Procedure
 *
 **/
SET NOCOUNT ON



DECLARE @stops TABLE (
tstp_id int identity NOT NULL
,cmp_id varchar(8) NULL
,city int NULL
,zip varchar(10) NULL
)

Create Table #routes  (
rth_id int  NULL
,rtd_id int NULL
,cmp_id varchar(8)
,cty_code int
,rtd_zip varchar(10)
,rtd_sequence smallint NULL
,priority tinyint NULL
)
create index dk_rthid on #routes(rth_id)

Declare @v_PayRouteType varchar(20),@v_movnumber int, @v_Stopcount smallint, @v_next smallint, @v_nextcmpid varchar(8)
Declare @v_nextcity int, @v_nextzip varchar(10)
Declare @v_laststop varchar(8),@v_lastcity int,@v_lastzip varchar(10)



If @p_type = 'O'
  BEGIN
    insert into @stops(cmp_id,city,zip)
    select stops.cmp_id
     , cty_code = case stops.cmp_id when 'UNKNOWN' then stp_city else cmp_city end
     , cmp_zip = case stops.cmp_id when 'UNKNOWN' then isnull(stp_zipcode,'') else  isnull(stp_zipcode,'') end
    from stops
    join company on stops.cmp_id = company.cmp_id
    where ord_hdrnumber = @p_key
    and stp_event <> 'XDU' and stp_event <> 'XDL'
    order by stp_arrivaldate

  END
 -- route rating for pay is limited to trips where there are no consolidation
else
  BEGIN
    Select @v_movnumber = mov_number from legheader where lgh_number = @p_key

    If (Select Count(Distinct ord_hdrnumber) From stops 
               where mov_number = @v_movnumber and ord_hdrnumber > 0)  > 1
    RETURN  -- NO RESULT SET IF CONSOLIDATED TRIP (for pay route)

    Select @v_PayRouteType = Upper(Isnull(gi_string1,''))
      From generalinfo Where gi_name = 'PayRouteType'

    Select  @v_PayRouteType = Isnull(@v_PayRouteType,'BILLSTOPSONMOVE')

    if @v_PayRouteType = 'BILLSTOPSONMOVE' 
   
     insert into @stops(cmp_id,city,zip)
     Select stops.cmp_id
     , cty_code = case stops.cmp_id when 'UNKNOWN' then stp_city else cmp_city end
     , cmp_zip = case stops.cmp_id when 'UNKNOWN' then isnull(stp_zipcode,'') else  isnull(stp_zipcode,'') end
        from stops 
        join company on stops.cmp_id = company.cmp_id
        join eventcodetable on stp_event = abbr
        where ord_hdrnumber > 0
        and lgh_number in (Select distinct lgh_number from legheader where mov_number = @v_movnumber)
        and ect_billable = 'Y'
        order by stp_mfh_sequence

    if @v_PayRouteType = 'BILLSTOPSONLEG' 
   
     insert into @stops(cmp_id,city,zip)
     Select stops.cmp_id
     , cty_code = case stops.cmp_id when 'UNKNOWN' then stp_city else cmp_city end
     , cmp_zip = case stops.cmp_id when 'UNKNOWN' then isnull(stp_zipcode,'') else  isnull(stp_zipcode,'') end
        from stops 
        join company on stops.cmp_id = company.cmp_id
        join eventcodetable on stp_event = abbr
        where ord_hdrnumber > 0
        and lgh_number = @p_key
        and ect_billable = 'Y'
        order by stp_mfh_sequence

    if @v_PayRouteType = 'ALLSTOPSONMOVE' 
   
     insert into @stops(cmp_id,city,zip)
     Select stops.cmp_id
     , cty_code = case stops.cmp_id when 'UNKNOWN' then stp_city else cmp_city end
     , cmp_zip = case stops.cmp_id when 'UNKNOWN' then isnull(stp_zipcode,'') else  isnull(stp_zipcode,'') end
     from stops 
     join company on stops.cmp_id = company.cmp_id
     where lgh_number in (Select distinct lgh_number from legheader where mov_number = @v_movnumber)
     order by stp_mfh_sequence

    if @v_PayRouteType = 'ALLSTOPSONLEG' 
   
     insert into @stops(cmp_id,city,zip)
     Select stops.cmp_id
     , cty_code = case stops.cmp_id when 'UNKNOWN' then stp_city else cmp_city end
     , cmp_zip = case stops.cmp_id when 'UNKNOWN' then isnull(stp_zipcode,'') else  isnull(stp_zipcode,'') end
     from stops 
     join company on stops.cmp_id = company.cmp_id 
     where lgh_number = @p_key
     order by stp_mfh_sequence
        
  END

Select @v_Stopcount = count(*) from @stops

select @v_laststop =  cmp_id
      ,@v_lastcity =  city
      ,@v_lastzip =   zip
 from @stops
where  tstp_id = @v_stopcount


if  @v_Stopcount > 0
  BEGIN
    select @V_laststop = cmp_id,
           @v_lastcity = city,
           @v_lastzip =  zip
    from @stops where  tstp_id = @v_stopcount

     -- build table of all routes with the same number of stops and end at the last location on stops)
    Insert into #routes(rth_id ,rtd_id,cmp_id ,cty_code ,rtd_zip,rtd_sequence ,priority)
    Select rth_id,rtd_id,cmp_id,cty_code,isnull(rtd_zip,''),rtd_sequence, 
           priority = case cmp_id when 'UNKNOWN' then 0 else 1 end 
    from routedetail rtd1
    where rth_id in  (select rth_id from routedetail rtd2 
                      where rtd2.rtd_sequence = @v_stopcount  
                      and rtd2.cmp_id = Case rtd2.cmp_id when 'UNKNOWN' then 'UNKNOWN' else @v_laststop end
                      and rtd2.cty_code = Case rtd2.cty_code when 0 then 0 else  @v_lastcity end
                      and rtd2.rtd_zip = Case rtd2.rtd_zip when 'UNKNOWN' then 'UNKNOWN' else  @v_lastzip end)
    and not exists (select 1 from routedetail rtd3 where rtd3.rth_id = rtd1.rth_id and rtd3.rtd_sequence > @v_stopcount)
--#select '#stops',* from @stops
    Select @v_next = 1
    /* remove from the routes when the next stop location in the route does not match the route entry in the same position */
    While @v_next < @v_stopcount
      BEGIN
        select @v_nextcmpid = cmp_id,@v_nextcity = city, @v_nextzip = zip from @stops where tstp_id = @v_next
--#select '#B4',@v_next,@v_nextcmpid,@v_nextcity,@v_nextzip
--#select '&B4',* from #routes order by rth_id,rtd_sequence
--#select '?',* from #routes where rtd_sequence = @v_next and cmp_id <> @v_nextcmpid and cmp_id <> 'UNKNOWN'
         /* remove if next stop company does not match the route company for the stop sequence*/
        delete from #routes where rth_id in 
         (select rth_id from #routes rtd2
          where rtd_sequence = @v_next
          and cmp_id <>  @v_nextcmpid 
          and cmp_id <> 'UNKNOWN') 

--#select '&cmp',* from #routes order by rth_id,rtd_sequence
        /* remove if next stop city does not match the route city for the stop sequence*/
        delete from #routes where rth_id in 
         (select rth_id from #routes rtd2
          where rtd_sequence = @v_next
          and cty_code  <>  @v_nextcity
          and cty_code > 0 )

--#select '&city',* from #routes order by rth_id,rtd_sequence
       /* remove if next stop zip does not match the route zip for the stop sequence*/
        delete from #routes where rth_id in 
         (select rth_id from #routes rtd2
          where rtd_sequence = @v_next
          and rtd_zip  <>  @v_nextzip 
          and rtd_zip <> 'UNKNOWN')
--#select '&zip',* from #routes order by rth_id,rtd_sequence
        select @v_next = @v_next + 1
      
      END
         

  END

select routeheader.rth_id,routeheader.rth_name,sum(priority)
from #routes 
join  routeheader on #routes.rth_id = routeheader.rth_id  
group by  routeheader.rth_id,routeheader.rth_name
order by sum(priority) Desc

drop table #routes

/*
select ord_number from orderheader where ord_shipper = 'minop'

select stops.ord_hdrnumber,cmp_id from stops join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
where stops.ord_hdrnumber > 0 and ord_shipper = 'minop'
and ord_consignee = 'carsup' order by stops.ord_hdrnumber,stp_arrivaldate 
--tol det cant  2917 3749       3524X  5244X

select * from routedetail  order by rth_id,rtd_sequence
where rth_id = 5 order by rtd_sequence
select * from routeheader where rth_id = 7
exec getroutes_sp 'O',672
select * from routedetail where rth_id = 1
select stops.cmp_id,stp_city,stp_zipcode from stops where ord_hdrnumber = 672 order by stp_mfh_sequence
exec getroutes_sp 'O',649
exec getroutes_sp 'O',699  -- no

*/
GO
GRANT EXECUTE ON  [dbo].[getroutes_sp] TO [public]
GO
