SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[master_schedule_legdata_sp] (@mr_name varchar(30))    
As  
/*  MODIFICATION LOG  used to leg information for a master route  
  
Created PTS 18410 DPETE  


  
  
*/  

Create Table #legdata ( 
mov_number int null,
mr_leg int null,
start_event varchar(6) null,
start_cmpid  varchar(8) null,
start_cmpname  varchar(100) null,
end_event varchar(6) null,
end_cmpid  varchar(8) null,
end_cmpname varchar(100) null,
start_city varchar(40) null,
end_city varchar(40) null,
start_date datetime null,
Start_stp_number int null,
end_stp_number int NULL
)

Insert Into #legdata
Select Distinct
mov_number = 0,
IsNull(mr_leg,1),
start_event = '', 
start_cmpid = '',
start_cmpname = '',
end_event = '',
end_cmpid = '',
end_cmpname = '',
start_city = '',
end_city = '',
start_date = '1-1-1950' ,
Start_stp_number = 0,
end_stp_number = 0
From master_Routes
Where mr_name = @mr_name


Update #legdata
Set start_stp_number = stp_number,
start_date = mr_arrival
From master_routes
Where mr_name = @mr_name
and mr_sequence = (Select Min(mr_sequence) from master_routes m2 where m2.mr_name = @mr_name and
    IsNull(m2.mr_leg,1) = #legdata.mr_leg)



Update #legdata
Set end_stp_number = stp_number
From master_routes
Where mr_name = @mr_name
and mr_sequence = (Select Max(mr_sequence) from master_routes m2 where m2.mr_name = @mr_name and
    IsNull(m2.mr_leg ,1) = #legdata.mr_leg)


Update #legdata
Set start_cmpid = cmp_id,
start_cmpname = cmp_name,
start_city = (cty_name + ', '+cty_state),
start_event = stp_event
From Stops,city 
Where stops.stp_number = #legdata.start_stp_number
and city.cty_code = stp_city

Update #legdata
Set end_cmpid = cmp_id,
end_cmpname = cmp_name,
end_city = (cty_name + ', '+cty_state),
end_event = stp_event
From Stops,city 
Where stops.stp_number = #legdata.end_stp_number
and city.cty_code = stp_city




Select
mov_number,
mr_leg,
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
GRANT EXECUTE ON  [dbo].[master_schedule_legdata_sp] TO [public]
GO
