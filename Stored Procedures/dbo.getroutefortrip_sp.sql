SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE 	PROCEDURE [dbo].[getroutefortrip_sp] @mov int, @leg int
AS 
/*
Created 3/30/05 DPETE 27483
PTS 33122 5/18/06 DPETE fix slow join to stop table
PTS40260 DPETE 4/19/08 recode Pauls into main source
*/
create table #legs (lgh_number int null)
If @mov > 0
 insert into #legs
 select distinct lgh_number from stops where mov_number = @mov
else
 insert into #legs
 Select lgh_number = @leg



Declare @orders varchar(100),@next varchar(15)
Select @next = ''


Select @next = Min(ord_number)
From #legs
     Join stops on #legs.lgh_number = stops.lgh_number
     Join Orderheader on orderheader.ord_hdrnumber = stops.ord_hdrnumber
Where stops.ord_hdrnumber > 0

While @next is not NULL
 BEGIN
   Select @orders = Rtrim(@next)+', '
   
   Select @next = Min(ord_number)
   From  #legs
    Join stops on #legs.lgh_number = stops.lgh_number
   Join Orderheader on orderheader.ord_hdrnumber = stops.ord_hdrnumber
   Where stops.ord_hdrnumber > 0
   And ord_number > @next
 END

If datalength(@orders) > 4 Select @orders = Left(@orders, datalength(@orders) - 2)
   

Select stp_event
,cmp_id
,stp_arrivaldate
,rd_state
,rd_direction
,rd_route
,rd_distance
,rd_time
,rd_interchange
,rd_cumdist
,rd_cumtime
,@orders
,miletableroute = ''
,rd_sequence
From #legs
     Join stops on #legs.lgh_number = stops.lgh_number
     JOIN mileagetable on mileagetable.mt_identity = stp_lgh_mileage_mtid
     LEFT OUTER JOIN routingdirections on routingdirections.mt_identity = mileagetable.mt_identity and stops.stp_mfh_sequence <> 1
Where   routingdirections.rd_distance > 0
And (cast(mt_route as varchar(10)) = '' or mt_route is null)

--Order by stp_arrivaldate,routingdirections.mt_identity,rd_sequence

UNION

select stp_event
,cmp_id
,stp_arrivaldate
,''
, ''
,''
, 0.0
, 0.0
, ''
, 0.0
,0.0
,@orders
,Miletableroute = cast(mt_route as varchar(1000))
,rd_sequence = 1
From #legs
 Join stops on #legs.lgh_number = stops.lgh_number
 JOIN mileagetable on mileagetable.mt_identity = stp_lgh_mileage_mtid
Where  len(cast(mt_route as varchar(1000))) > 0
Order by stp_arrivaldate,rd_sequence



GO
GRANT EXECUTE ON  [dbo].[getroutefortrip_sp] TO [public]
GO
