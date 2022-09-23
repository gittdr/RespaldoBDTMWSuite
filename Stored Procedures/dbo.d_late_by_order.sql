SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_late_by_order] @tol_early int, 
@tol_late int,
@cust char(8),
@fromdate datetime,
@todate datetime

as

declare @bob1 int, @bob2 int, @bob3 int

SELECT orderheader.ord_hdrnumber, 
orderheader.ord_number,   
orderheader.ord_company,   
orderheader.ord_shipper,   
orderheader.ord_consignee,   
orderheader.ord_startdate,   
orderheader.ord_completiondate,
@bob1 latestops,
@bob2 ontimestops,
@bob3 totalstops 

INTO #tt
from orderheader 
where ( orderheader.ord_company = @cust OR @cust = 'UNKNOWN' ) and
ord_startdate between @fromdate and @todate

update #tt
set latestops = ( select count (*) from stops
where stops.ord_hdrnumber = #tt.ord_hdrnumber and 
( stops.stp_arrivaldate < dateadd ( mi, -@tol_early,  stops.stp_schdtearliest ) OR 
stops.stp_arrivaldate > dateadd ( mi, -@tol_late, stops.stp_schdtlatest )))
update #tt
set ontimestops = ( select count (*) from stops
where stops.ord_hdrnumber = #tt.ord_hdrnumber and 
( stops.stp_arrivaldate >= stops.stp_schdtearliest and stops.stp_arrivaldate <= stops.stp_schdtlatest ))
update #tt
set totalstops = ( select count (*) from stops
where stops.ord_hdrnumber = #tt.ord_hdrnumber ) 

update #tt
set latestops = 0 where latestops IS null

update #tt
set ontimestops = 0 where ontimestops IS null

update #tt
set totalstops = 0 where totalstops IS null

select * from #tt




GO
GRANT EXECUTE ON  [dbo].[d_late_by_order] TO [public]
GO
