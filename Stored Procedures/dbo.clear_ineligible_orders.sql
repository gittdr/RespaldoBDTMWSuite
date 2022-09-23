SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.clear_ineligible_orders    Script Date: 6/1/99 11:54:07 AM ******/
create procedure [dbo].[clear_ineligible_orders] ( @user_id    varchar(20),
										     				 @batch_number int)
as

/**************************************************************************************
*							DELETE INELEGIBLE ORDERS
*  CREATE SORTED TEMP TABLES FROM ORIGINAL TABLES - THIS IS DONE
*	TO CLEAR OUT ORDERS AND STOPS AND ORDERHEADERS WHOSE 
*	(TS_location OR Toh_shipper OR toh_consignee THAT DO NOT HAVE A RECORDS IN 
*	THE COMPANYTABLE
*	
*	THIS USED BE PART OF SP_ORDERCREATE, BUT DUE TO POWER BUILDER RESTRICTIONS
*	YOU CANNOT PROCESS TEMP TABLES AND RUN TRANSACTIONS EFFECTIVLY IN THE SAME SP
**************************************************************************************/

declare @today_date datetime


select @today_date = getdate()
/** SELECT ORDERS AND NEEDED COMPANY VALUES. THE ONES WITHOUT OUT THE COMPANYS
	 IN THE COMPANY TABLE WILL HAVE NULL VALUES IN THE CITY CODE FIELDS ***/
SELECT
		t.toh_ordernumber,
		s.ts_seq,	
		s.ts_location,
		c.cmp_city location_city,
		t.toh_shipper,
		origin.cmp_city org_city,
		t.toh_consignee,
		dest.cmp_city	 dest_city,
		t.mov_number
	into #tt
from tempstops s, tempordhdr t, company origin, company dest, company c	
where (t.toh_ordernumber = s.toh_ordernumber) and
		(t.toh_user = @user_id and t.toh_tstampq = @batch_number) and			
		(s.ts_location *= c.cmp_id ) and
		(t.toh_shipper  *= origin.cmp_id) and
		(t.toh_consignee *= dest.cmp_id)



/*** CREATE LIST OF INVALID ORDERS - ORDERS WITHOUT COMPANYS IN COMPANY TABLE ***/
select * into #dd
from tempordhdr
where toh_ordernumber in(select distinct 
									toh_ordernumber
									from #tt	
									where	(location_city is null or org_city is null or dest_city is null))
	

insert into tts_errorlog
	(err_batch, err_user_id, err_icon, err_message, err_date,err_number,err_item_number,err_type)
select distinct 
		@batch_number ,
		@user_id ,
		'E' ,
		"ERROR!!! Move: " + convert ( varchar(20) , mov_number ) + 
			". Either Company " + ts_location + "/city: " + convert(varchar(5), location_city)+ 
			" from the tempstops table or Shipper " +
			+ toh_shipper+ "/city: " + convert ( varchar(5),org_city) + 
			" or Consignee " + toh_consignee + "/city: " + convert ( varchar(5),dest_city) + 
			" are not in the company table." , 
		@today_date, 
		toh_ordernumber,
		convert ( varchar(20) , toh_ordernumber ),
		"CMPINV" 
from #tt
where	toh_ordernumber in (select toh_ordernumber 
								  from #dd)	
insert into tts_errorlog
	(err_batch, err_user_id, err_icon, err_message, err_date,err_number, err_item_number,err_type)
select  
		@batch_number ,
		@user_id ,
		'E' ,
		"ERROR!!! Move: " +  convert ( varchar(20) , t.mov_number ) +
		 " Invalid Driver ID: " + t.ts_driver1,
		@today_date, 
		t.toh_ordernumber,
		t.ts_driver1,
		"DRVINV" 
from tempstops t,tempordhdr o
where (t.toh_ordernumber = o.toh_ordernumber) and
		(o.toh_user = @user_id and o.toh_tstampq = @batch_number) and	
		(t.ts_driver1 not in (select mpp_id 
									from manpowerprofile))
	
insert into tts_errorlog
	(err_batch, err_user_id, err_icon, err_message, err_date,err_number, err_item_number,err_type)
select  
		@batch_number ,
		@user_id ,
		'E' ,
		"ERROR!!! Move: " +  convert ( varchar(20) , t.mov_number ) +
		 " Invalid Driver ID: " + t.ts_driver2,
		@today_date, 
		t.toh_ordernumber,
		t.ts_driver2,
		"DRVINV" 
from tempstops t,tempordhdr o
where (t.toh_ordernumber = o.toh_ordernumber) and
		(o.toh_user = @user_id and o.toh_tstampq = @batch_number) and	
		(t.ts_driver2 not in (select mpp_id 
									from manpowerprofile))

insert into tts_errorlog
	(err_batch, err_user_id, err_icon, err_message, err_date, err_number, err_item_number,err_type)
select  
		@batch_number ,
		@user_id ,
		'E' ,
		"ERROR!!! Move: " +  convert ( varchar(20) , t.mov_number ) +
		 " Invalid Tractor ID: " + ts_trc_num,
		@today_date, 
		t.toh_ordernumber,
		t.ts_trc_num,
		"TRCINV" 
from tempstops t,tempordhdr o
where (t.toh_ordernumber = o.toh_ordernumber) and
		(o.toh_user = @user_id and o.toh_tstampq = @batch_number) and	
		(ts_trc_num not in (select trc_number 
									from tractorprofile))

insert into tts_errorlog
	(err_batch, err_user_id, err_icon, err_message, err_date, err_number, err_item_number,err_type)
select  
		@batch_number ,
		@user_id ,
		'E' ,
		"ERROR!!! Move: " +  convert ( varchar(20) , t.mov_number ) +
		 " Invalid Trailer ID: " + t.ts_trl_num,
		@today_date, 
		t.toh_ordernumber,
		t.ts_trl_num,
		"TRLINV" 
from tempstops t,tempordhdr o
	where (t.toh_ordernumber = o.toh_ordernumber) and
		(o.toh_user = @user_id and o.toh_tstampq = @batch_number) and	 
		(t.ts_trl_num not in (select trl_number 
									from trailerprofile))

update tempordhdr
set toh_error_flag = "T"
from tempordhdr
where toh_ordernumber in (select distinct err_number 
			  from tts_errorlog
			  where (err_user_id = @user_id and err_batch = @batch_number))



RETURN



GO
GRANT EXECUTE ON  [dbo].[clear_ineligible_orders] TO [public]
GO
