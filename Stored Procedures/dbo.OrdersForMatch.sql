SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[OrdersForMatch] @seedOrder int ,@maxretrysetting int
as  
    create table #temp (
     ordernumber varchar(12), 
     orderheadernumber int, 
     movenumber int, 
     routeid varchar(15), 
     status varchar(6), 
     mastermatchpending char(1), 
     railschedulecascadepending char(1), 
     importexport char(1)
     ) 
   
 insert into #temp (
            ordernumber, 
            orderheadernumber, 
            movenumber, routeid, 
            status, 
            mastermatchpending, 
            railschedulecascadepending, 
            importexport
            ) 
  select ord_number, 
         ord_hdrnumber, 
         mov_number, 
         isnull(ord_route, ''), 
         isnull(ord_status, 'UNK'), 
         isnull(ord_mastermatchpending, 'N'), 
         isnull(ord_railschedulecascadepending, 'N'), 
         isnull(ord_importexport, 'N') 
    from orderheader with (index(dx_matching))
   where ord_hdrnumber = (select min (orderheader.ord_hdrnumber) 
                            from orderheader left outer join MOMRetryAttemptLogs on MOMRetryAttemptLogs.Ord_hdrnumber=orderheader.ord_hdrnumber 
                           where ((ord_status = 'PFP' and isnull(ord_mastermatchpending, 'N') = 'N' and isnull(ord_railschedulecascadepending, 'N') = 'N') 
                                  or 
                                  (ord_status in ('PFP', 'PND', 'CBR', 'AVL', 'PLN', 'DSP', 'STD') and (ord_mastermatchpending = 'Y' or ord_railschedulecascadepending = 'Y'))
                                or
                                        (ord_status = ('CMP') and ord_railschedulecascadepending = 'Y')

                                 )
                             and orderheader.ord_hdrnumber > @seedorder 
                              and ISNULL(MOMRetryAttemptLogs.currentRuncount,0)<@maxretrysetting+1
                         ) 
                              
 select ordernumber, 
        orderheadernumber, 
        movenumber, 
        routeid, 
        status, 
        mastermatchpending, 
        railschedulecascadepending, 
        importexport 
   from #temp
GO
GRANT EXECUTE ON  [dbo].[OrdersForMatch] TO [public]
GO
GRANT REFERENCES ON  [dbo].[OrdersForMatch] TO [public]
GO
