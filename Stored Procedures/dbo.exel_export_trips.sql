SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.exel_export_trips    Script Date: 6/1/99 11:55:01 AM ******/
create proc [dbo].[exel_export_trips] (@from_date 		datetime,
											 @to_date			datetime,
											 @status				varchar(6),
											 @order_by			varchar(8),
											 @company			varchar(6),/*yes varchar(6)*/
											 @batch_number		int) as


declare	@dd 					varchar(10),
			@returnstring		varchar(254),
			@records				int,
			@orders				int

/* CLEAR TABLE */
delete trip_export

/* IF NO BATCH NUMBER WAS PASSED IN CREATE ONE*/
if (@batch_number <= 0 ) EXEC @batch_number = getsystemnumber "BATCHQ", ""

/* SELECT ALL ORDERS THAT WHERE COMLETED BETWEEN THE INPUT DATES */
INSERT INTO trip_export
         ( systemnum,   
           rt_num,   
           rt_date,   
           ord_origin_earliestdate,   
           dealer_num,   
           dealer_name,   
           cmp_othertype1,   
           stp_sequence,   
           pl_arr_tm,   
           act_arr_tm,   
           pl_dpt_tm,   
           act_dpt_tm,   
           arr_abbr,   
           arr_name,   
           arr_code,   
           dpt_abbr,   
           dpt_name,   
           dpt_code,   
           ord_revtype3,   
           unld_tol,   
           arr_tol,   
           checkcall,   
           special,   
           del,   
           ord_hdrnumber,   
           ord_number,   
           ord_status,   
           stp_number,   
           stp_event,   
           ord_revtype2,   
           ord_revtype4,   
           stp_refnumber,   
           stp_reftype,   
           exp_batch_number )  

select orderheader.ord_subcompany ,
      orderheader.ord_revtype1,
		orderheader.ord_bookdate,
		orderheader.ord_origin_earliestdate,
		stops.cmp_id,
		company.cmp_name,
		company.cmp_othertype1,   
		stops.stp_sequence,
		stops.stp_schdtearliest,
		stops.stp_arrivaldate,
		stops.stp_schdtlatest,
		stops.stp_departuredate, 
		stops.stp_reasonlate,  /* ARRIVAL EXCEPTION */
      labelfile.name,   
      labelfile.code,   
      null, /* dpt_abbr */   
      null, /* dpt_name */
      null, /* dpt_code	*/	
 		orderheader.ord_revtype3,
		"0",
		"0",
		"F", /* checkcall */
		"F", /* special */
		"F", /* del */
		orderheader.ord_hdrnumber,
		orderheader.ord_number,
		orderheader.ord_status,
		stops.stp_number,
		stops.stp_event,
		orderheader.ord_revtype2,
		orderheader.ord_revtype4,
		stops.stp_refnum,
		stops.stp_reftype,
		@batch_number
from orderheader, stops, company, labelfile
where orderheader.ord_hdrnumber = stops.ord_hdrnumber and
		orderheader.ord_status like @status and
		orderheader.ord_bookdate between @from_date and @to_date and
		@company in ("UNK",orderheader.ord_subcompany) and
		@order_by in ("UNKNOWN", orderheader.ord_company) and
		company.cmp_id =* stops.cmp_id  and
		stops.stp_reasonlate *= labelfile.abbr and
		labelfile.labeldefinition = "ReasonLate"

/* IF NO TRIPS WERE EXPORTED DROP OUT */	
if ((select count(*) from trip_export where exp_batch_number = @batch_number ) = 0)
	BEGIN
  	select @returnstring = 'There were no orders completed for down loading on days ' + rtrim(convert(char, @from_date, 1)) + " thru " + rtrim(convert(char,@to_date,1)) + ". Batch# :" + rtrim(convert(char, @batch_number)) + " On: " + rtrim(convert(char,Getdate(),1))  
	INSERT INTO tts_errorlog  
         ( err_batch,   
           err_user_id,   
           err_message,   
           err_date,   
           err_number,   
           err_title,   
           err_response,   
           err_sequence,   
           err_icon,   
           err_item_number,   
           err_type )  
  VALUES ( @batch_number,   
           user_name(),   
           @returnstring,
           getdate(),   
           0,   
           'Daily Trip Download',   
           null,   
           0,
			  'I',   
           "0",   
           "TRPEXP" ) 

	goTO ERROREND
	END


/* LOOK FOR CHECK CALL EVENTS ASSOCOTED WITH THE STOPS */
update trip_export
	set checkcall = "T"
from trip_export,event 
where trip_export.stp_number = event.stp_number and
	((select count(*)
		from event
		where trip_export.stp_number = event.stp_number and
				event.evt_eventcode  = "CHK") > 0 ) and
	( trip_export.exp_batch_number = @batch_number )

/* ADD STOPS THAT WHERE DELETED USING THE trip_modification_log */
INSERT INTO trip_export
         ( systemnum,   
           rt_num,   
           rt_date,   
           ord_origin_earliestdate,   
           dealer_num,   
           dealer_name,   
           cmp_othertype1,   
           stp_sequence,   
           pl_arr_tm,   
           act_arr_tm,   
           pl_dpt_tm,   
           act_dpt_tm,   
           arr_abbr,   
           arr_name,   
           arr_code,   
           dpt_abbr,   
           dpt_name,   
           dpt_code,   
           ord_revtype3,   
           unld_tol,   
           arr_tol,   
           checkcall,   
           special,   
           del,   
           ord_hdrnumber,   
           ord_number,   
           ord_status,   
           stp_number,   
           stp_event,   
           ord_revtype2,   
           ord_revtype4,   
           stp_refnumber,   
           stp_reftype,   
           exp_batch_number )  


select orderheader.ord_subcompany ,
      orderheader.ord_revtype1,
		orderheader.ord_bookdate,
		orderheader.ord_origin_earliestdate,
		trip.cmp_id,
		company.cmp_name,
		company.cmp_othertype1,   
		trip.stp_sequence,
		trip.stp_schdtearliest,
		trip.stp_arrivaldate,
		trip.stp_schdtlatest,
		trip.stp_departuredate, 
		null,  /* ARRIVAL EXCEPTION */
      null,   
      null,   
      null, /* dpt_abbr */   
      null, /* dpt_name */
      null, /* dpt_code	*/	
 		orderheader.ord_revtype3,
		"0",
		"0",
		"F", /* checkcall */
		"F", /* special */
		"T", /* NOTE: DELETE FLAG SET TO TRUE */ 
		orderheader.ord_hdrnumber,
		orderheader.ord_number,
		orderheader.ord_status,
		trip.stp_number,
		trip.stp_event,
		orderheader.ord_revtype2,
		orderheader.ord_revtype4,
		trip.stp_refnum,
		trip.stp_reftype,
		@batch_number
from orderheader, trip_modification_log trip, company
where orderheader.ord_hdrnumber = trip.ord_hdrnumber and
		trip.tml_event = "DELETE" and
		company.cmp_id =* trip.cmp_id and
		orderheader.ord_hdrnumber in (select distinct trip_export.ord_hdrnumber
												from trip_export)
		

/* SET SPECIAL FLAG TO TRUE FOR STOPS THAT WERE ADDED. USE THE trip_modification_log
 	TO IDENTIFY WHICH ONES */
update trip_export
	set 	special = "T", 
			arr_abbr = null,   
         arr_name= null,      
         arr_code= null,      
         dpt_abbr= null,      
         dpt_name= null,      
         dpt_code= null    			
from trip_export, trip_modification_log  
 WHERE ( trip_modification_log.stp_number = trip_export.stp_number ) AND  
       ( trip_modification_log.tml_event = "ADD" ) and
		 ( exp_batch_number = @batch_number )
		


select @orders = count(distinct ord_number) from trip_export where exp_batch_number = @batch_number 
select @records = count(*) from trip_export where exp_batch_number = @batch_number 
select @returnstring = "There were " + rtrim(convert(char, @orders)) + " orders in " + rtrim(convert(char, @records)) + " records processed for down loading scheduled between " + rtrim(convert(char,@from_date,1)) + " thru " + rtrim(convert(char,@to_date,1)) + ". Batch# " + rtrim(convert(char, @batch_number)) + " On " + rtrim(convert(char,Getdate(),1))
INSERT INTO tts_errorlog  
        ( err_batch,   
          err_user_id,   
          err_message,   
          err_date,   
          err_number,   
          err_title,   
          err_response,   
          err_sequence,   
          err_icon,   
          err_item_number,   
          err_type )  
 			 
	VALUES ( @batch_number,   
          user_name(),   
          @returnstring,
          getdate(),   
          0,   
          'Daily Trip Download',   
          null,   
          0,
			'I',   
          "0",   
          "TRPEXP") 



ERROREND:
return @batch_number



GO
GRANT EXECUTE ON  [dbo].[exel_export_trips] TO [public]
GO
