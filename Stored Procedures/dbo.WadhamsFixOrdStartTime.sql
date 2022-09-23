SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[WadhamsFixOrdStartTime]
      ( 
    @CustomerId VARCHAR(8),
       @StartDate DATETIME,
    @EndDate DATETIME,
    @FixIt CHAR(1)
      )

AS

--EXEC dbo.[WadhamsFixOrdStartTime] 'UNKNOWN','11/8/13','11/8/13', 'N'

CREATE TABLE #Orders
      (
   cmp_id varchar(8),
   ord_number varchar(12),
   ord_hdrnumber int,
   ord_startdate datetime,
   evt_startdate datetime
   )


if @CustomerId = '*'
begin

 INSERT INTO #Orders
  select o.ord_billto, o.ord_number, o.ord_hdrnumber, o.ord_startdate, e.evt_startdate
  from event e
  INNER JOIN stops WITH (NOLOCK) ON e.stp_number = stops.stp_number
  INNER JOIN city WITH (NOLOCK) ON city.cty_code = stops.stp_city
  INNER JOIN orderheaderltlinfo oltl WITH (NOLOCK) ON oltl.ord_hdrnumber = e.ord_hdrnumber
  INNER JOIN orderheader o WITH (NOLOCK) ON oltl.ord_hdrnumber = o.ord_hdrnumber
  INNER JOIN legheader lgh WITH (NOLOCK) ON lgh.lgh_number = stops.lgh_number
  where o.ord_bookdate >= @StartDate
  and o.ord_bookdate <= @EndDate
  and o.ord_startdate <> e.evt_startdate
  and e.evt_eventcode = 'LLD'
  and e.evt_status = 'DNE'

end
else
begin

 INSERT INTO #Orders
  select o.ord_billto, o.ord_number, o.ord_hdrnumber, o.ord_startdate, e.evt_startdate
  from event e
  INNER JOIN stops WITH (NOLOCK) ON e.stp_number = stops.stp_number
  INNER JOIN city WITH (NOLOCK) ON city.cty_code = stops.stp_city
  INNER JOIN orderheaderltlinfo oltl WITH (NOLOCK) ON oltl.ord_hdrnumber = e.ord_hdrnumber
  INNER JOIN orderheader o WITH (NOLOCK) ON oltl.ord_hdrnumber = o.ord_hdrnumber
  INNER JOIN legheader lgh WITH (NOLOCK) ON lgh.lgh_number = stops.lgh_number
  where o.ord_billto = @CustomerId
  and o.ord_bookdate >= @StartDate
  and o.ord_bookdate <= @EndDate
  and o.ord_startdate <> e.evt_startdate
  and e.evt_eventcode = 'LLD'
  and e.evt_status = 'DNE'

end


IF @FixIt = 'Y'
BEGIN
 update oh
 set ord_startdate = orders.new_startdate
 from orderheader as oh
 inner join (select ord_hdrnumber, min(evt_startdate) as new_startdate
    from #Orders
    group by ord_hdrnumber) orders on oh.ord_hdrnumber = orders.ord_hdrnumber
END

select * from #Orders order by cmp_id

return 0
GO
GRANT EXECUTE ON  [dbo].[WadhamsFixOrdStartTime] TO [public]
GO
