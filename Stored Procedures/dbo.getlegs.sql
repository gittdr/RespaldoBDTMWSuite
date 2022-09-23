SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Proc [dbo].[getlegs] @ord varchar(12), @lgh int,@mov int
/* MODIFICATION LOG

DPETE 2/5/4 created to dig up legs and their assets given an Order, leg,  or a mov number

*/
As
Create table #legs (
lgh_number int null
,evt_driver1 varchar(8) null
,evt_driver2 varchar(8) null
,evt_tractor varchar(8) Null
,evt_trailer1 varchar(13) Null
,evt_trailer2 varchar(13) Null
,startdate datetime null
,evt_carrier varchar(8) null
)

If Rtrim(@ord) > ''
  Begin
    Insert into #legs
    Select Distinct
      stops.lgh_number
     ,evt_driver1
     ,evt_driver2
     ,evt_tractor
     ,evt_trailer1
     ,evt_trailer2
     ,getdate()
     ,evt_carrier
     From stops,event
     Where stops.ord_hdrnumber = (Select ord_hdrnumber From orderheader where ord_number = @ord)
     and event.stp_number = stops.stp_number and evt_sequence = 1
     
  End
Else
  If @mov > 0
     Insert into #legs
     Select Distinct
      stops.lgh_number
     ,evt_driver1
     ,evt_driver2
     ,evt_tractor
     ,evt_trailer1
     ,evt_trailer2
     ,getdate()
     ,evt_carrier
     From stops,event
     Where stops.mov_number = @mov
     and event.stp_number = stops.stp_number and evt_sequence = 1
  Else  -- leg is provided
     Insert into #legs
     Select Distinct
     stops.lgh_number
     ,evt_driver1
     ,evt_driver2
     ,evt_tractor
     ,evt_trailer1
     ,evt_trailer2
     ,getdate()
     ,evt_carrier
     From stops,event
     Where stops.lgh_number = @lgh
     and event.stp_number = stops.stp_number and evt_sequence = 1   

Update #legs 
Set startdate = (Select Min(stp_arrivaldate)
From stops Where stops.lgh_number = #legs.lgh_number)

Select   
 lgh_number 
,evt_driver1 
,evt_driver2
,evt_tractor
,evt_trailer1
,evt_trailer2
,startdate
,evt_carrier 
From #legs
Order By startdate


GO
GRANT EXECUTE ON  [dbo].[getlegs] TO [public]
GO
