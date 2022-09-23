SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[timken_orders_sp]
as
BEGIN
declare @ls_bol varchar(12),
	@li_tmpordnum int,
	@ls_yard1 varchar(12),
	@ls_yard2 varchar(12),
	@ls_yard3 varchar(12),
	@ls_notes varchar(254),
	@ls_user varchar(30),
	@ls_err varchar(254),
	@li_ordhdrnumber int,
	@ls_emailsendto varchar(254),
	@ls_emailcopyto varchar(254),
	@ls_wtunits varchar(6),
	@ls_countunits varchar(6),
	@ls_orderedby varchar(8),
	@ls_billto  varchar(8)


create table #bol (bol_number  varchar(12)) 

-- Read the constants from the interface constants table
 select @ls_emailsendto = ifc_value from interface_constants where ifc_tablename = 'misc' and ifc_columnname = 'timkenemailsendto'
 select @ls_emailcopyto = ifc_value from interface_constants where ifc_tablename = 'misc' and ifc_columnname = 'timkenemailcopyto'
 select @ls_wtunits = ifc_value from interface_constants where ifc_tablename = 'misc' and ifc_columnname = 'timkenweightunits'
 select @ls_countunits = ifc_value from interface_constants where ifc_tablename = 'misc' and ifc_columnname = 'timkencountunits'
 select @ls_orderedby = ifc_value from interface_constants where ifc_tablename = 'tempordhdr' and ifc_columnname = 'toh_orderedby'
 select @ls_billto = ifc_value from interface_constants where ifc_tablename = 'tempordhdr' and ifc_columnname = 'toh_billto'


select @ls_wtunits = IsNull(@ls_wtunits,'LBS')
select @ls_countunits = IsNull(@ls_countunits,'PCS')
select @ls_orderedby = IsNull(@ls_orderedby,'UNKNOWN')
select @ls_billto = IsNull(@ls_billto,'UNKNOWN')

   select @ls_bol = ''
   WHILE 1 = 1
   BEGIN
	next_order:	
	select @ls_bol =min(bol_number) from timken_orders 
	where  bol_number > @ls_bol and
	       ord_status in ('ORIGINAL','CANCEL')
 	
	If @ls_bol is null 
	   break	

	insert into #bol Select @ls_bol

	EXEC @li_tmpordnum = getsystemnumber 'TMKNORD', ''     

	BEGIN TRAN ORDER_INSERT
	
	Insert into tempordhdr(
	toh_ordernumber,
	toh_orderedby,
	toh_contact,
	toh_billto,     
	toh_shipper    ,
	toh_consignee  ,
	toh_user  ,     
	toh_tstampq ,   
	toh_comments,   
	toh_bookdate,
	toh_shipdate,
	toh_deldate,
	toh_ordtype,
	toh_edicontrolid,
	toh_status,
	toh_ord_terms,
	toh_inv_status)    
	(
	Select
	@li_tmpordnum,
	@ls_orderedby,
	ord_contact,
	@ls_billto,
	ord_shipper,
	ord_consignee,
	USER,
	1,
	ord_remarks,
	getdate(),
	ord_origin_earliestdate,
	ord_dest_latestdate,
	ord_status,
	@ls_bol,
	'AVL',
	ord_terms,
	ord_inv_status
	from timken_orders where bol_number = @ls_bol
	)

	If @@error > 0 
	begin
	    select @ls_err = 'Insert into tempordhdr failed'
	    goto error_handler				
	end

	Insert into tempstops(
	toh_ordernumber ,
	ts_seq         ,
	ts_location     ,
	ts_type          ,
	ts_earliest      ,
	ts_latest        ,
	ts_arrival,
	ts_event          ,
	toh_tstampq,
	ts_driver1,
	ts_driver2,
	ts_trc_num,
	ts_trl_num)
	(
	Select
	@li_tmpordnum,
	1,
	ord_shipper,	
	'PUP',
	ord_origin_earliestdate,
	ord_origin_latestdate,
	ord_origin_earliestdate,
	'LLD',
	1,
	'UNKNOWN',
	'UNKNOWN',
	'UNKNOWN',
	'UNKNOWN'
	from timken_orders where bol_number = @ls_bol)	

	If @@error > 0 
	begin
	    select @ls_err = 'Insert into tempstops for the Pickup Stop failed'
	    goto error_handler				
	end


 
	Insert into tempstops(
	toh_ordernumber ,
	ts_seq         ,
	ts_location     ,
	ts_type          ,
	ts_earliest      ,
	ts_latest        ,
	ts_arrival	,
	ts_event          ,
	toh_tstampq,
	ts_driver1,
	ts_driver2,
	ts_trc_num,
	ts_trl_num)
	(
	Select
	@li_tmpordnum,
	2,
	ord_consignee,	
	'DRP',
	ord_dest_earliestdate,
	ord_dest_latestdate,
	ord_dest_earliestdate,
	'LUL',
	1,
	'UNKNOWN',
	'UNKNOWN',
	'UNKNOWN',
	'UNKNOWN'
	from timken_orders where bol_number = @ls_bol)	

	If @@error > 0 
	begin
	    select @ls_err = 'Insert into tempstops for the Drop Stop failed'
	    goto error_handler				
	end



	insert into tempcargos
 	(
	toh_ordernumber,
	ts_sequence,
	tc_sequence,
	tc_weight,
	tc_weightunit,
	toh_tstampq,
	cmd_code,
	tc_count,
	tc_countunit
	)
	(
	select
	@li_tmpordnum,
	2,
	1,
	ord_totalweight,	
	@ls_wtunits,
	1,
	cmd_code,
	ord_totalpieces,
	@ls_countunits
	from timken_orders where bol_number = @ls_bol)	

	If @@error > 0 
	begin
	    select @ls_err = 'Insert into tempcargos  failed'
	    goto error_handler				
	end



	
	select  @ls_notes = ord_notes,
		@ls_yard1 = yard_number1,
		@ls_yard2 = yard_number2,
		@ls_yard3 = yard_number3
	from 	timken_orders
	where	bol_number = @ls_bol	

	
	If @ls_notes is not null
	insert into tempnotes
	(
	toh_ordernumber,
	ts_sequence    ,
	tc_sequence    ,
	tn_notesequence,
	tn_note     ,
	toh_tstampq )
	VALUES
	(
	@li_tmpordnum,
	0,
	0,
	1,	
	@ls_notes,
	1
	)	
	If @@error > 0 
	begin
	    select @ls_err = 'Insert into tempnotes failed'
	    goto error_handler				
	end



	if @ls_yard1 is not null
	insert into tempref(
	toh_ordernumber,
	ts_sequence,
	tr_type,
	tr_refnum,
	tr_refsequence,
	toh_tstampq)
	VALUES
	(
	@li_tmpordnum,
	0,
	'YARD1#',
	@ls_yard1,
	1,
	1
	)	

	If @@error > 0 
	begin
	    select @ls_err = 'Insert into tempref for yard1  failed'
	    goto error_handler				
	end



	if @ls_yard2 is not null
	insert into tempref(
	toh_ordernumber,
	ts_sequence,
	tr_type,
	tr_refnum,
	tr_refsequence,
	toh_tstampq)
	VALUES
	(
	@li_tmpordnum,
	0,
	'YARD2#',
	@ls_yard2,
	2,
	1
	)	
	If @@error > 0 
	begin
	    select @ls_err = 'Insert into tempref for yard2  failed'
	    goto error_handler				
	end



	
	if @ls_yard3 is not null
	insert into tempref(
	toh_ordernumber,
	ts_sequence,
	tr_type,
	tr_refnum,
	tr_refsequence,
	toh_tstampq)
	VALUES
	(	
	@li_tmpordnum,
	0,
	'YARD3#',
	@ls_yard3,
	3,
	1
	)	

	If @@error > 0 
	begin
	    select @ls_err = 'Insert into tempref for yard3  failed'
	    goto error_handler
	end				
	else 
	begin
		commit tran order_insert
		select @ls_user = USER	
		exec @li_ordhdrnumber = LTSL_ORDER_IMPORT @ls_user,1

		update timken_orders set ord_status = 'IMPORTED',
					 ord_hdrnumber = @li_ordhdrnumber 
		where bol_number = @ls_bol		

		goto next_order
	end



error_handler:
	    Rollback tran order_insert
	    select 'Import Failed for BL# ', @ls_bol,' Error Number:' ,@@error ,' Msg:',@ls_err


   END
	
	select '*****************Import Results**************'		
  	select 	bol_number ,
		ord_contact ,                   
		ord_shipper  ,                  
		ord_consignee ,                 
		ord_hdrnumber  ,                
		ord_status 
	 from 	timken_orders 
	where  	ord_status = 'IMPORTED' 


	if (select count(*) from #bol  ) > 0
	Begin
	   If @ls_emailsendto is not null	
	   BEGIN
	     create table ##result_text ( email_msg text)
	     Insert into ##result_text
      	     select 	'BL#:' + #bol.bol_number +
		' Shipper:' + ord_shipper +
		' Consignee:' + ord_consignee +                 
		' P*S Order#:' + convert(varchar(20),ord_hdrnumber)+
		' Status:' + ord_status 
	      from 	timken_orders,#bol 
	      where  	timken_orders.bol_number  = #bol.bol_number

		--PTS80582 
		execute master.dbo.xp_sendmail  @recipients = @ls_emailsendto, @copy_recipients = 	@ls_emailcopyto, 
		    @query = 'SELECT * from ##result_text',
		    @subject = 'Message From the Order Import',
		    @message = 'Results of the import:',
		    @attach_results = 'FALSE', 				     
		    @width = 500
		drop table ##result_text

	   END	
	End
	

END

GO
GRANT EXECUTE ON  [dbo].[timken_orders_sp] TO [public]
GO
