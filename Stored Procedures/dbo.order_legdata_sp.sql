SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[order_legdata_sp] (@ordnbr varchar(12), @ordortrip char(1))    
As  
/*  MODIFICATION LOG  used to leg information for an order or trip 
  
Created PTS 18410 DPETE  
  If an 'O' is passed and the order is split or cross docked, nothing is returned.

  
  
*/  
Declare @ordhdr int


  
Create Table #legdata (mov_number int null, 
lgh_number int null,
start_event varchar(6) null,
start_cmpid  varchar(8) null,
start_cmpname  varchar(100) null,
end_event varchar(6) null,
end_cmpid  varchar(8) null,
end_cmpname varchar(100) null,
start_city varchar(40) null,
end_city varchar(40) null,
start_date datetime null
)

Select @ordhdr = ord_hdrnumber From orderheader Where ord_number = @ordnbr
If @ordhdr Is Null Select @ordhdr = -9

/* cannot ask for order copy if order is split */
If @ordortrip = 'O' and (select count(distinct lgh_number) From stops where ord_hdrnumber = @ordhdr) > 1 
  Select @ordhdr = -9


Insert Into #legdata
Select Distinct 
mov_number,
lgh_number,
start_event = '', 
start_cmpid = '',
start_cmpname = '',
end_event = '',
end_cmpid = '',
end_cmpname = '',
start_city = '',
end_city = '',
start_date = '1-1-1950' 
From  Stops
Where stops.mov_number = (Select  mov_number From orderheader Where ord_hdrnumber = @ordhdr)
and (ord_hdrnumber = @ordhdr or ord_hdrnumber =  Case @ordortrip When 'T' Then 0 Else -9 End) 
 
If @@rowcount > 0
 Begin
  Update #legdata
  Set start_cmpid = cmp_id,
  start_cmpname = cmp_name,
  start_city = (cty_name + ', '+cty_state),
  start_event = stp_event,
  start_date = stp_arrivaldate
  From Stops,city 
  Where stops.lgh_number = #legdata.lgh_number
  and stops.stp_mfh_sequence = (Select Min(stp_mfh_sequence) From stops s2 Where s2.lgh_number = #legdata.lgh_number)
  and city.cty_code = stp_city

  Update #legdata
  Set end_cmpid = cmp_id,
  end_cmpname = cmp_name,
  end_city = (cty_name + ', '+cty_state),
  end_event = stp_event
  From Stops,city 
  Where stops.lgh_number = #legdata.lgh_number
  and stops.stp_mfh_sequence = (Select Max(stp_mfh_sequence) From stops s2 Where s2.lgh_number = #legdata.lgh_number)
  and city.cty_code = stp_city

  
 End



Select 
mov_number,
lgh_number,
start_event, 
start_cmpid,
start_cmpname ,
end_event,
end_cmpid,
end_cmpname ,
start_city ,
end_city,
start_date 
From #legdata
order by start_date
GO
GRANT EXECUTE ON  [dbo].[order_legdata_sp] TO [public]
GO
