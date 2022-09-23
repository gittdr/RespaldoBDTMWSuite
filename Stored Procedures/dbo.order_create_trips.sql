SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.order_create_trips    Script Date: 8/20/97 2:00:12 PM ******/
create procedure [dbo].[order_create_trips] (@user_id varchar(20), @batch_number int)

as

declare 
	@today_date	   datetime,
	@genesis	   datetime,
	@trailer	varchar(12),
	@refnum		varchar(30),
	@reftype	 varchar(6),
	@err_message   varchar(254),
	@drv1		 varchar(8),
	@drv2		 varchar(8),
	@trc		 varchar(8),
	@trl	 	varchar(13),
	@trl2	 	varchar(13),
	@error_type	 varchar(6), 
	@ord_type	 varchar(8),
	@ord_status	 varchar(3),
	@seq_number		int,
	@max_seq_number		int,
	@max_refseq_number	int,
	@stp_number		int,
	@max_stp_number		int,
	@ord_number		int,
	@max_ord_number		int,
	@mov_number		int,
	@pws_ordhdrnumber	int,
	@ord_cancelnumber	int,
	@ord_hdrnumber		int,
	@lgh_hdrnumber		int,
	@disp_seq		int,
	@disp_seq_check		int,
	@dest_city		int,
	@org_city		int,
	@dest_state	 varchar(6),
	@org_state	 varchar(6),
	@duplicate		int,
	@edictn			int,
	@shipper	 varchar(8),
	@rCounter		int,
	@stop_city		int,
	@data_validation_flag	int,
	@data_validation_count	int,
	@stop_company	 varchar(8),
	@stop_count		int,
	@ord_counter		int,
	@freight_number		int,
	@batch			int,
	@vtc_weight	      float,
	@vtc_weightunit	    char(6),
	@vtc_description   char(64),
	@vtc_volume	      float,
	@vtc_volumeunit	    char(6),
	@vtc_sequence		int,
	@vtc_rate	      money,
	@vtc_rateunit	    char(6),
	@vtc_charge	      money,
	@vtc_quantity	      float,
	@vtc_quantityunit   char(6),
	@note_number		int,
	@note_sequence	        int,
	@note_text	  char(255),
	@tc_sequence		int,
	@ts_sequence		int

SET NOCOUNT ON
-- CHECK FOR INVALID DRIVERS, TRACTORS, TRAILERS, AND COMPANIES 
-- EXEC clear_ineligible_orders @user_id, @batch_number

	SELECT @ord_cancelnumber = count(*)
	FROM tempordhdr
	WHERE (toh_ordtype = 'UPDATE' 
	OR    toh_ordtype ='CANCEL') 
	AND toh_tstampq = @batch_number
	IF @ord_cancelnumber > 0 	
	SELECT @rCounter = 0
	SET ROWCOUNT 1
	WHILE @rCounter < @ord_cancelnumber
	BEGIN
		SELECT	@ord_number = toh_ordernumber, 
			@ord_type = toh_ordtype, 
			@edictn = convert(int,toh_refnum)
		FROM tempordhdr
		WHERE toh_ordtype = 'CANCEL'  
		OR    toh_ordtype = 'UPDATE'
		AND toh_tstampq = @batch_number
		IF @ord_type = 'UPDATE'
			SELECT @err_message = 'Update detected, order:'+ convert(varchar(20), @ord_number)
		ELSE
		BEGIN
			SELECT @ord_status = ord_status 
			FROM orderheader 
			WHERE ord_refnum = convert(varchar(30),@edictn)
			AND ord_reftype = 'EDICT#'
			if @ord_status = 'AVL'
			BEGIN
				UPDATE orderheader 
				SET ord_status = 'CAN'  
				WHERE ord_refnum = convert(varchar(30),@edictn)
				AND ord_reftype = 'EDICT#'
				goto ord_cntinue
			END
			ELSE
				SELECT @err_message = 'Cancellation detected. Too late for order:'+ convert(varchar(20), @ord_number)
		END
		
		SELECT @error_type = @ord_type
		INSERT INTO tts_errorlog
		(err_batch, err_user_id, err_icon, err_message, err_date, err_item_number, err_type)
		VALUES (@batch_number, @user_id, 'E', @err_message, @today_date, convert(varchar(20), @ord_number), @error_type)

ord_cntinue:	-- in case we were able to cancel, no need for error log entry

		SELECT @rCounter = @rCounter + 1
	END
	SET ROWCOUNT 0
	SELECT @data_validation_flag = 0
	SELECT @today_date = getdate()
	SELECT @genesis = convert(datetime,'19500101')
	SELECT @ord_number = 0
	SELECT @ord_counter = 0

	SELECT @max_ord_number = count(*)
		FROM tempordhdr
		WHERE  	(toh_user = @user_id) 
		AND 	(toh_tstampq = @batch_number)
		AND 	(toh_error_flag IS NULL)	
		AND 	(toh_ordtype = 'ORIGINAL' )

	IF (@max_ord_number = 0)
	BEGIN
		IF @ord_cancelnumber = 0
		BEGIN
			SELECT @data_validation_flag = 1
			SELECT @err_message = 'No Valid Orders for batch number:'+ convert(varchar(20), @batch_number)
			SELECT @error_type = 'NODATA'
			goto error_exit
		END
		ELSE
			GOTO return_point		
	END

-- LOOP THROUGH EACH ORDER CREATING ORDERHEADER AND STOPS RECORDS

WHILE @ord_counter < @max_ord_number

BEGIN
	SELECT @ord_counter = @ord_counter + 1
	-- get the next order in the batch
	SET ROWCOUNT 1
	SELECT  @batch 	    = t.toh_tstampq,  
		@ord_number = t.toh_ordernumber,
		@org_city   = origin.cmp_city,
		@dest_city  = dest.cmp_city,
		@edictn     = t.toh_edicontrolid,
		@shipper    = t.toh_shipper
	FROM tempordhdr t, company origin, company dest
	WHERE (t.toh_ordernumber > @ord_number) 
	AND    (t.toh_user = @user_id) 
	AND    (t.toh_error_flag IS NULL)
	AND    (t.toh_shipper = origin.cmp_id)
	AND    (t.toh_consignee = dest.cmp_id)
	AND    (t.toh_tstampq = @batch_number)
	AND    (t.toh_ordtype = 'ORIGINAL')
	ORDER BY t.toh_ordernumber
	SET ROWCOUNT 0

	IF (@ord_number IS null)
	BEGIN
		SELECT @data_validation_flag = 1
		SELECT @err_message = 'No Valid Orders for batch number:'+ convert(varchar(20), @batch_number)
		SELECT @error_type = 'NODATA'
		goto error_exit
	END

	SELECT @rCounter = 0
	SELECT @error_type = 'DBERROR'
	SELECT @data_validation_flag = 0

	SELECT @org_state=cty_state
	FROM city
	WHERE cty_code=@org_city

	SELECT @dest_state=cty_state
	FROM city
	WHERE cty_code=@dest_city

	-- Each order should be enclosed in a transaction
	BEGIN  TRAN ORDER_CREATE

	-- uncomment the following line to display ord_hdrnumber
	-- select @pws_ordhdrnumber

	-- Went to using the order number from the download as the orderheader
	-- number to allow advances to match with the order #08/14/95

--MA** There is no need for the following check. 
--	SELECT @duplicate = count(*)
--	FROM   orderheader
--	WHERE  ord_hdrnumber = @pws_ordhdrnumber
--	-- check for duplicates in powersuite
--	IF @duplicate > 0
--	BEGIN
--		SELECT @data_validation_flag = 1
--		SELECT @err_message = 'Duplicate!!! Order#' 
--			+ Convert(varchar(12), @pws_ordhdrnumber) 
--			+ 'Has already been used as a internally generated'
--			+ ' ord_hdrnumber. Duplicates are not allowed in the ord_hdrnumber field of the orderheader table.'
--		goto error_exit
--	END  
-- MA* Added 4/11 for single value
	declare @ordnumfromref integer
	SELECT @ordnumfromref = ord_hdrnumber 
	FROM  referencenumber
	WHERE ref_type='EDICT#' 
	AND   ref_number=convert(varchar(30),@edictn) 
	AND   ref_table='orderheader'
	-- MA 04/07/97 Changed the column name to the new one 
	SET ROWCOUNT 1
	SELECT @duplicate = count(*)
	FROM   orderheader
	WHERE  ord_shipper = @shipper 
	AND    ord_hdrnumber= @ordnumfromref


	-- check for duplicates in powersuite
	IF @duplicate > 0
	BEGIN
		SELECT @data_validation_flag = 1
		SELECT @err_message = 'Duplicate!!! EDICT#' 
			+ Convert(varchar(12), @edictn) 
			+ ' Has already been received for this shipper: '
			+ @shipper
		goto error_exit
	END  
	SET ROWCOUNT 0

	-- check for at least two stops
	-- **MA This whole block is not needed
--	SELECT @stop_count=count(*)
--	FROM   tempstops
--	WHERE  toh_ordernumber = @ord_number
--	IF (@stop_count < 2)
--	BEGIN
--		SELECT @data_validation_flag = 1
--		SELECT @err_message = 'Less than 2 Stops found for order: toh_ordnumber='
--			+ convert(Char(20), @ord_number) 
--			+ 'Error creating order'
--		SELECT @error_type = 'BADDTA'
--		goto error_exit                                                
--	END

	
	-- check for at least one stop with PUP
	SELECT @stop_count=count(*)
	FROM   tempstops
	WHERE  toh_ordernumber = @ord_number and ts_type='PUP'

-- IF (@stop_count < 2)  **MA
	IF (@stop_count < 1)
	BEGIN
		SELECT @data_validation_flag = 1
		SELECT @err_message = 'Less than 1 Stops found with ts_type=PUP for order: toh_ordnumber='
			+ convert(Char(20), @ord_number) 
			+ 'Error creating order'
		SELECT @error_type = 'BADDTA'
		goto error_exit                                                
	END

	-- check for at least one stop with DRP
	SELECT @stop_count=count(*)
	FROM   tempstops
	WHERE  toh_ordernumber = @ord_number 
	AND    ts_type='DRP'
	AND    toh_tstampq = @batch_number

-- IF (@stop_count < 2)  **MA
	IF (@stop_count < 1)
	BEGIN
		SELECT @data_validation_flag = 1
		SELECT @err_message = 'Less than 1 Stops found with ts_type=DRP for order: toh_ordnumber='
			+ convert(Char(20), @ord_number) 
			+ 'Error creating order'
		SELECT @error_type = 'BADDTA'
		goto error_exit                                                
	END

	-- count stops for insert into orderheader
	SELECT @stop_count=count(*)
	FROM   tempstops
	WHERE  toh_ordernumber = @ord_number
	AND    toh_tstampq = @batch_number

	-- Get new mov number for the order
	EXEC @mov_number = getsystemnumber 'MOVNUM', ''     

	-- Get new ordernumber for the order
	EXEC @pws_ordhdrnumber = getsystemnumber 'ORDHDR', ''

--	*MA and VE * moved from below 4/25
	-- Get new legheadernumber for the order
	EXEC @lgh_hdrnumber = getsystemnumber 'LEGHDR', ''

	-- create orderheader record
	INSERT INTO orderheader
	       (ord_totalmiles,			-- 1
		ord_customer,			-- 2
		ord_company ,			-- 3
		ord_number,			-- 4
		ord_contact,			-- 5
		ord_bookdate,			-- 6
		ord_bookedby,			-- 7
		ord_status,			-- 8
		ord_originpoint,		-- 9
		ord_destpoint,			-- 10
		ord_invoicestatus,		-- 11
		ord_origincity,			-- 12
		ord_destcity,			-- 13
		ord_originstate,		-- 14
		ord_deststate,			-- 15
		ord_supplier,			-- 16
		ord_billto,			-- 17
		ord_startdate,			-- 18
		ord_completiondate,		-- 19
		ord_revtype1 ,			-- 20
		ord_revtype2 ,			-- 21
		ord_revtype3,			-- 22
		ord_revtype4 ,			-- 23
		ord_totalweight,		-- 24
		ord_totalpieces,		-- 25
		ord_totalcharge,		-- 26
		ord_currency ,			-- 27
		ord_currencydate,		-- 28
		ord_totalvolume,		-- 29
		ord_hdrnumber,			-- 30
		ord_shipper, 			-- 31
		ord_consignee,			-- 32
		ord_pu_at,			-- 33
		ord_dr_at,			-- 34
		ord_priority ,			-- 35
		mov_number,			-- 36
		ord_description,		-- 37
		ord_reftype,			-- 38
		ord_refnum,			-- 39
		tar_tariffitem,			-- 40
		ord_showshipper,		-- 41
		ord_showcons,			-- 42
		ord_subcompany,			-- 43
		ord_lowtemp,			-- 44
		ord_hitemp,			-- 45
		ord_quantity,			-- 46
		ord_rate,			-- 47
		ord_charge,			-- 48
		ord_rateunit,			-- 49
		trl_type1,			-- 50
		ord_driver1,			-- 51
		ord_driver2,			-- 52
		ord_tractor,			-- 53
		ord_trailer,			-- 54
		ord_length,			-- 55
		ord_width,			-- 56
		ord_height,			-- 57
		ord_lengthunit,			-- 58
		ord_widthunit,			-- 59
		ord_heightunit,			-- 60
		cmd_code,			-- 61
		ord_terms,			-- 62
		cht_itemcode,			-- 63
		ord_origin_earliestdate,	-- 64
		ord_origin_latestdate,		-- 65
		ord_odmetermiles,		-- 66
		ord_stopcount,			-- 67
		ord_dest_earliestdate,		-- 68
		ord_dest_latestdate,		-- 69
		ref_sid,			-- 70
		ref_pickup,			-- 71
		ord_cmdvalue,			-- 72
		ord_accessorial_chrg,		-- 73
		ord_availabledate,		-- 74
		ord_miscqty,			-- 75
		ord_tempunits,			-- 76
		ord_datetaken,			-- 77
		ord_totalweightunits,		-- 78
		ord_totalvolumeunits,		-- 79
		ord_totalcountunits,		-- 80
		ord_unit,	 		-- 81
		ord_rateby,			-- 82
		tar_tarriffnumber,		-- 83
		ord_remark)			-- 84
	SELECT	0,				-- 1
		'UNKNOWN',			-- 2
		isnull(toh_orderedby,'UNKNOWN'),	-- 3
		convert(char(12), @pws_ordhdrnumber),	-- 4
		toh_contact,			-- 5
		@today_date,			-- 6
		toh_user,			-- 7
		toh_status,			-- 8
		toh_shipper,			-- 9
		toh_consignee,			-- 10
		'PND',				-- 11
		@org_city,			-- 12
		@dest_city,			-- 13
		@org_state,			-- 14
		@dest_state,			-- 15
		'UNKNOWN',			-- 16
		isnull(toh_billto,'UNKNOWN'),	-- 17
		toh_shipdate,			-- 18
		toh_deldate ,			-- 19
		'UNK',				-- 20
		'UNK',				-- 21
		'UNK',				-- 22
		'UNK',				-- 23
		0,				-- 24
		0,				-- 25
		toh_charge,			-- 26
		'US$',				-- 27
		@today_date,			-- 28
		0,				-- 29
		@pws_ordhdrnumber,		-- 30
		toh_shipper,			-- 31
		toh_consignee,			-- 32
		'SHP',				-- 33
		'CNS',				-- 34
		'UNK',				-- 35
		@mov_number,			-- 36
		(SELECT ts_description			
		FROM tempstops
		WHERE toh_ordernumber= @ord_number
		AND ts_seq = 2),		-- 37 - MA & VH, to get one commodity name 5/9
		'EDICT#',			-- 38
		convert(varchar(20),@edictn),	-- 39
		'UNKNOWN',			-- 40
		'UNKNOWN',			-- 41
		'UNKNOWN',			-- 42
		'UNK',				-- 43
		0,				-- 44
		0,				-- 45
		0,				-- 46
		0,				-- 47
		0,				-- 48
		'UNK',				-- 49
		'UNK',				-- 50
		'UNKNOWN',			-- 51
		'UNKNOWN',			-- 52
		'UNKNOWN',			-- 53
		'UNKNOWN',			-- 54
		0,				-- 55
		0,				-- 56
		0,				-- 57
		'FET',				-- 58
		'FET',				-- 59
		'FET',				-- 60
		'UNKNOWN',			-- 61
		'UNK',				-- 62
		'UNK',				-- 63
		@genesis,			-- 64
		@today_date,			-- 65
		-1,				-- 66
		@stop_count,			-- 67
		@genesis,			-- 68
		@today_date,			-- 69
		Null,				-- 70
		Null,				-- 71
		0,				-- 72
		0,				-- 73
		@today_date,			-- 74
		0,				-- 75
		'Frnhgt',			-- 76
		@today_date,			-- 77
		'LBS',				-- 78
		'CUB',				-- 79
		'PCS',				-- 80
		'UNK',				-- 81
		'D',				-- 82
		'UNKNOWN',			-- 83
		'Order taken via Electronic Data Interchange'	-- 84
	FROM tempordhdr 
	WHERE	(toh_ordernumber = @ord_number
	AND      toh_tstampq = @batch_number)

	IF @@ERROR != 0
	BEGIN
		SELECT @err_message = '@err:' 
			+ convert(varchar(20), @@ERROR)
			+ 'order: toh_ordnumber='
			+ convert(Char(20), @ord_number)
			+ 'Error creating order'
		goto error_exit
	END


	-- VH and VJ and MA added 03/26/97 Put all reference numbers in referencenumber table
	SELECT @max_seq_number = max(tr_refsequence)
	FROM tempref		
	WHERE (toh_ordernumber = @ord_number
	AND    toh_tstampq = @batch_number
	AND    ts_sequence = 0)		-- when the stop number is 0 then the refnum is 
--	IF (@max_ord_number != null)	-- for the order header
	IF (@max_seq_number IS NOT null)
	SELECT @rCounter = 0
	-- LOOP THROUGH EACH SEQUENCE INBSERTING REFERENCE NUMBERS 
	WHILE @rCounter != @max_seq_number
	-- Begin while sequence loop
	BEGIN
		SELECT @rCounter = @rCounter + 1
		SELECT @error_type = 'DBERROR'
		-- Set rowcount to find only one record
		SET ROWCOUNT 1

		INSERT INTO referencenumber
		      ( ref_tablekey,
			ref_type,
			ref_number,
			ref_sequence,
			ref_table,
			ref_sid,
			ref_pickup)

		SELECT @pws_ordhdrnumber,
			r.tr_type,
			tr_refnum,
			@rCounter + 1,
			'orderheader',
			Null,
			Null
		FROM   tempref r
		WHERE  (r.toh_ordernumber = @ord_number
			AND     r.toh_tstampq = @batch_number
			AND	r.ts_sequence = 0
			AND	r.tr_refsequence = @rCounter) 

		IF @@ERROR != 0
		BEGIN
			SELECT @err_message = '@err:' 
				+ convert(varchar(10), @@ERROR) + 'order: toh_ordnumber='
				+ convert(Char(20), @ord_number) 
				+ 'Error creating reference# for orderheader'
			GOTO error_exit
		END 
	END

	-- Create Notes entries from the tempnotes table which is 
	-- NOT part of the POWER Suite Database - for orders
	DECLARE FDcursor CURSOR
	FOR  SELECT 
               	tn_notesequence, 
		tn_note
	FROM tempnotes
	WHERE toh_tstampq = @batch_number
	AND toh_ordernumber = @ord_number
	AND ts_sequence =  0
	OPEN FDcursor 
	FETCH FDcursor INTO
		@note_sequence,
		@note_text
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC @note_number = getsystemnumber 'NOTES',''
		INSERT INTO notes (
			not_number,
			not_text,
			not_type,
--			not_urgent,
			not_senton,
			not_sentby,
--			not_expires,
--			not_forwardedfrom,
			ntb_table,
			nre_tablekey,
			not_sequence)
		SELECT
			@note_number,
			@note_text,
			'E',
			GETDATE(),
			'EDI 204',
			'orderheader',
			convert(varchar(18), @ord_number),
			@note_sequence

		FETCH FDcursor INTO
			@note_sequence,
			@note_text
		if @@FETCH_STATUS = -2 
		BEGIN
			SELECT @err_message = '@err:' 
			+ convert(varchar(10), @@ERROR) + 'order: toh_ordnumber='
			+ convert(Char(20), @ord_number) 
			+ 'Error creating notes for stop'
			+ convert(Char(20), @stp_number)
			INSERT INTO tts_errorlog
			(err_batch, err_user_id, err_icon, err_message, err_date, err_item_number, err_type)
			VALUES (@batch_number, @user_id, 'E', @err_message, @today_date, convert(varchar(20), @ord_number), @error_type)
		END 
	END
	CLOSE FDcursor
	DEALLOCATE FDcursor

	SET ROWCOUNT 0
	SELECT @disp_seq_check = -1
	SELECT @seq_number = 0
	SELECT @max_seq_number = null

	SELECT @max_seq_number = max(ts_seq)
	FROM   tempstops
	WHERE  toh_ordernumber = @ord_number
	AND    toh_tstampq = @batch_number

	IF (@max_seq_number IS null)
	BEGIN
		SELECT @data_validation_flag = 1
		SELECT @err_message = 'No Stops found for order: toh_ordnumber='
			+ convert(Char(20), @ord_number) 
			+ 'Error creating order'
		SELECT @error_type = 'BADDTA'
		goto error_exit                                                
	END

	WHILE @seq_number != @max_seq_number
	BEGIN
		EXEC @stp_number = getsystemnumber 'STPNUM', ''

		--  Set rowcount to find only one record
		SET rowcount 1
		SELECT @seq_number = t.ts_seq,
			@disp_seq   = t.ts_dispatch_seq,
			@drv1       = t.ts_driver1,
			@drv2       = t.ts_driver2,
			@trc        = t.ts_trc_num,
			@trl        = t.ts_trl_num,
			@trl2       = t.ts_trl_num2,
			@stop_company  = isnull(t.ts_location,'UNKNOWN'),
			@stop_city  = t.ts_city
		FROM  tempstops t
		WHERE t.ts_seq > @seq_number 
		AND   t.toh_ordernumber = @ord_number
		AND   t.toh_tstampq = @batch_number
		ORDER BY t.ts_seq, t.ts_dispatch_seq

		-- test for valid stop company
		SELECT @data_validation_count = count(*)
		FROM company
		WHERE cmp_id =@stop_company

		IF @data_validation_count < 1
		BEGIN
			SELECT @data_validation_flag = 1
			SELECT @err_message = 'Invalid Company from tempstops, order: toh_ordnumber='
				+ convert(Char(20), @ord_number) + '  '
				+ @stop_company
				+ '    Error creating order'
			SELECT @error_type = 'BADDTA'
			goto error_exit
		END  


		SELECT @stop_city = isnull( @stop_city, (select cmp_city from company
			WHERE cmp_id = @stop_company))

		-- test for valid stop city
		SELECT @data_validation_count = count(*)
		FROM city
		WHERE cty_code=@stop_city

		IF @data_validation_count < 1
		BEGIN
			SELECT @data_validation_flag = 1
			SELECT @err_message = 'Invalid City from tempstops, order: toh_ordnumber='
				+ convert(Char(20), @ord_number) + '  '
				+ convert(Char(20), @stop_city)
				+ 'Error creating order'
			SELECT @error_type = 'BADDTA'
			goto error_exit
		END  


		-- Set defaults
		SELECT @reftype = 'REF#'
		SELECT @refnum = NULL

		-- Select First ref# For stop
		SELECT @refnum = tr_refnum,
			@reftype = tr_type
		FROM   tempref tr
		WHERE	tr.ts_sequence = @seq_number 
		AND	tr.toh_tstampq = @batch_number
		AND	tr.tr_refsequence = (select min(r.tr_refsequence)
				From tempref r
				WHERE	r.ts_sequence = @seq_number 
					AND r.toh_tstampq = @batch_number
					AND r.toh_ordernumber = @ord_number )   
					
--	*MA and VE * only one legheader number is required per order. Code moved to 
--	where order number is retrieved above.
		-- A change in the @disp_seq indicates the start of a new leg
		--IF ( @disp_seq <> @disp_seq_check )
		--BEGIN
		--	exec @lgh_hdrnumber = getsystemnumber 'LEGHDR', ''
		--	SELECT @disp_seq_check = @disp_seq
		--END

		SET rowcount 0

		INSERT INTO stops
			(ord_hdrnumber,		--1
			stp_number,		--2
			cmp_id,			--3
			stp_city,		--4
			stp_schdtearliest,	--5
			stp_origschdt,		--6
			stp_arrivaldate,	--7
			stp_departuredate,	--8
			stp_reasonlate,		--9
			stp_schdtlatest,	--10
			lgh_number,		--11
			stp_type,		--12
			stp_paylegpt,		--13
			stp_sequence,		--14
			stp_mfh_sequence,	--15
			stp_event,		--16
			stp_weight,		--17
			stp_weightunit,		--18
			stp_count,		--19
			stp_countunit,		--20
			stp_status,		--21
			cmp_name,		--22
			stp_reftype,		--23
			stp_refnum,		--24
			mov_number,		--25
			cmd_code,		--26
			mfh_number,		--27
			stp_lgh_sequence,	--28
			stp_ord_mileage,	--29
			stp_lgh_mileage,	--30
			stp_loadstatus,		--31
			stp_description, 	--32
			stp_screenmode)		--33
		select
			@pws_ordhdrnumber,			--1
			@stp_number,				--2
			isnull(t.ts_location,'UNKNOWN'),	--3
			isnull(@stop_city,0),			--4
			isnull(t.ts_earliest,@genesis),		--5
			t.ts_earliest,				--6
			isnull(t.ts_arrival,@today_date),	--7
			isnull(t.ts_departure,@today_date),	--8
			'UNK',					--9
			isnull(t.ts_latest,@today_date),	--10
			@lgh_hdrnumber,				--11
			t.ts_type,				--12
			'Y',					--13
			t.ts_seq,  				--14
			t.ts_seq,				--15
			t.ts_event,				--16
			isnull(t.ts_weight,0),			--17
			'LBS',					--18
			isnull(t.ts_count,0),			--19
			'PCS',					--20
			'OPN',					--21
			isnull( (SELECT cmp_name 
				FROM company
				WHERE cmp_id = t.ts_location), 
				'UNKNOWN'),			--22
			@reftype,				--23
			@refnum,				--24
			@mov_number,				--25
			'UNKNOWN',				--26
			0,					--27
			0,					--28
			0,					--29
			0,					--30
			'LD',					--31
			isnull(t.ts_description,'UNKNOWN'),	--32
			'COMMOD'				--33
		from tempstops	t
		where t.ts_seq = @seq_number 
		and   t.toh_ordernumber = @ord_number
		and   t.toh_tstampq = @batch_number
		IF @@ERROR != 0
		BEGIN
			SELECT @err_message  = '@err:' + convert(varchar(10), @@ERROR)
				+ 'order: toh_ordnumber='
				+ convert(Char(20), @ord_number) 
				+ 'Error creating stops'
			goto error_exit
		END
		-- Create FreightDetail entries for the Cargo
		DECLARE FDcursor CURSOR
		FOR  SELECT 
			tc_weight,
			tc_weightunit,
			tc_description,
			tc_volume,
			tc_volumeunit,
			tc_sequence,
			tc_rate,
			tc_rateunit,
			tc_charge,
			tc_quantity,
			tc_quantityunit              
		FROM tempcargos
		WHERE toh_tstampq = @batch_number
		AND toh_ordernumber = @ord_number
		AND ts_sequence =  @seq_number 
		OPEN FDcursor 
		FETCH FDcursor INTO
			@vtc_weight,
			@vtc_weightunit,
			@vtc_description,
			@vtc_volume,
			@vtc_volumeunit,
			@vtc_sequence,
			@vtc_rate,
			@vtc_rateunit,
			@vtc_charge,
			@vtc_quantity,
			@vtc_quantityunit

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC @freight_number = getsystemnumber 'FGTNUM',''
			INSERT INTO freightdetail (
			fgt_number,
			cmd_code,
			fgt_weight,
			fgt_weightunit,
			fgt_description,
			stp_number,
--			fgt_count,
--			fgt_countunit,
			fgt_volume,
			fgt_volumeunit,
--			fgt_lowtemp,
--			fgt_hitemp,
			fgt_sequence,
--			fgt_length,
--			fgt_lengthunit,
--			fgt_height,
--			fgt_heightunit,
--			fgt_width,
--			fgt_widthunit,
			fgt_reftype,
--			fgt_refnum,
			fgt_rate,
			fgt_rateunit,
			fgt_charge,
--			cht_itemcode,
--			cht_basisunit,
			fgt_quantity,
			fgt_unit)

			SELECT                      

			@freight_number,
			'UNKNOWN',
			@vtc_weight,
			@vtc_weightunit,
			@vtc_description,
			@stp_number,
			@vtc_volume,
			@vtc_volumeunit,
			@vtc_sequence,
			'REF',
			@vtc_rate,
			@vtc_rateunit,
			@vtc_charge,
			@vtc_quantity,
			@vtc_quantityunit

			-- Create Notes entries from the tempnotes table which is 
			-- NOT part of the POWER Suite Database - for cargos
			DECLARE FDNotecursor CURSOR
			FOR  SELECT 
                		tn_notesequence, 
				tn_note
			FROM tempnotes
			WHERE toh_tstampq = @batch_number
			AND toh_ordernumber = @ord_number
			AND ts_sequence =  @seq_number 
			AND tc_sequence = @vtc_sequence
			OPEN FDNotecursor
			FETCH FDNotecursor INTO
				@note_sequence,
				@note_text
	
			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC @note_number = getsystemnumber 'NOTES',''
				INSERT INTO notes (
					not_number,
					not_text,
					not_type,
--					not_urgent,
					not_senton,
					not_sentby,
--					not_expires,
--					not_forwardedfrom,
					ntb_table,
					nre_tablekey,
					not_sequence)
				SELECT 
					@note_number,
					@note_text,
					'E',
					GETDATE(),
					'EDI 204',
					'freightdetail',
					convert(varchar(18), @vtc_sequence),
					@note_sequence
	
				FETCH FDNotecursor INTO
					@note_sequence,
					@note_text

				if @@FETCH_STATUS = -2 
				BEGIN
					SELECT @err_message = '@err:' 
					+ convert(varchar(10), @@ERROR) + 'order: toh_ordnumber='
					+ convert(Char(20), @ord_number) 
					+ 'Error creating notes for stop'
					+ convert(Char(20), @stp_number)
					INSERT INTO tts_errorlog
					(err_batch, err_user_id, err_icon, err_message, err_date, err_item_number, err_type)
					VALUES (@batch_number, @user_id, 'E', @err_message, @today_date, convert(varchar(20), @ord_number), @error_type)
				END 
			END
			CLOSE FDNotecursor
			DEALLOCATE FDNotecursor

			FETCH FDcursor INTO
			@vtc_weight,
			@vtc_weightunit,
			@vtc_description,
			@vtc_volume,
			@vtc_volumeunit,
			@vtc_sequence,
			@vtc_rate,
			@vtc_rateunit,
			@vtc_charge,
			@vtc_quantity,
			@vtc_quantityunit

			if @@FETCH_STATUS = -2 
			BEGIN
				SELECT @err_message = '@err:' 
				+ convert(varchar(10), @@ERROR) + 'order: toh_ordnumber='
				+ convert(Char(20), @ord_number) 
				+ 'Error creating cargo# for stop'
				+ convert(Char(20), @stp_number)
				INSERT INTO tts_errorlog
				(err_batch, err_user_id, err_icon, err_message, err_date, err_item_number, err_type)
				VALUES (@batch_number, @user_id, 'E', @err_message, @today_date, convert(varchar(20), @ord_number), @error_type)
			END 			
		END
		CLOSE FDcursor
		DEALLOCATE FDcursor

		-- Create reference number records for the freightdetail table   
--		INSERT INTO referencenumber
--		       (ref_tablekey,
--			ref_type, 
--			ref_number,
--			ref_sequence, 
--			ref_table,
--			ref_sid,
--			ref_pickup)
--		SELECT 
--			fgt_number, 
--			tr.tr_type, 
--			tr.tr_refnum, 
--			tr.tr_refsequence, 
--			'stops',
--			Null,
--			Null
--		from tempref tr
--		where tr.ts_sequence = @seq_number 
--		and   tr.toh_tstampq = @batch_number
--		and   tr.toh_ordernumber = @ord_number 
--		and   tr.tc_sequence = 0
--		and   (tr.tr_type <> @reftype or tr.tr_refnum <> @refnum)

		-- Create Notes entries from the tempnotes table which is 
		-- NOT part of the POWER Suite Database - for stops
		DECLARE FDcursor CURSOR
		FOR  SELECT 
                	tn_notesequence, 
			tn_note
		FROM tempnotes
		WHERE toh_tstampq = @batch_number
		AND toh_ordernumber = @ord_number
		AND ts_sequence =  @seq_number 
		AND tc_sequence =  0
		OPEN FDcursor 
		FETCH FDcursor INTO
			@note_sequence,
			@note_text
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC @note_number = getsystemnumber 'NOTES',''
			INSERT INTO notes (
				not_number,
				not_text,
				not_type,
--				not_urgent,
				not_senton,
				not_sentby,
--				not_expires,
--				not_forwardedfrom,
				ntb_table,
				nre_tablekey,
				not_sequence)
			SELECT
				@note_number,
				@note_text,
				'E',
				GETDATE(),
				'EDI 204',
				'stops',
				convert(varchar(18), @stp_number),
				@note_sequence

			FETCH FDcursor INTO
				@note_sequence,
				@note_text

			if @@FETCH_STATUS = -2 
			BEGIN
				SELECT @err_message = '@err:' 
				+ convert(varchar(10), @@ERROR) + 'order: toh_ordnumber='
				+ convert(Char(20), @ord_number) 
				+ 'Error creating notes for stop'
				+ convert(Char(20), @stp_number)
				INSERT INTO tts_errorlog
				(err_batch, err_user_id, err_icon, err_message, err_date, err_item_number, err_type)
				VALUES (@batch_number, @user_id, 'E', @err_message, @today_date, convert(varchar(20), @ord_number), @error_type)
			END 
		END
		CLOSE FDcursor
		DEALLOCATE FDcursor

		-- Create remaining reference number records the  
		-- first REF# is handled by a trigger
		INSERT INTO referencenumber
		       (ref_tablekey,
			ref_type, 
			ref_number,
			ref_sequence, 
			ref_table,
			ref_sid,
			ref_pickup)
		select 
			@stp_number, 
			tr.tr_type, 
			tr.tr_refnum, 
			tr.tr_refsequence, 
			'stops',
			Null,
			Null
		from tempref tr
		where tr.ts_sequence = @seq_number 
		and   tr.toh_tstampq = @batch_number
		and   tr.toh_ordernumber = @ord_number 
		and   tr.tc_sequence = 0
		and   (tr.tr_type <> @reftype or tr.tr_refnum <> @refnum)

		IF @@ERROR != 0
		BEGIN
			SELECT @err_message = '@err:' 
				+ convert(varchar(10), @@ERROR) + 'order: toh_ordnumber='
				+ convert(Char(20), @ord_number) 
				+ 'Error creating reference# for stop'
			GOTO error_exit
		END 

		UPDATE event
		SET  evt_driver1 = @drv1,
			evt_driver2 = @drv2,
			evt_tractor = @trc,
			evt_trailer1 = @trl,
			evt_trailer2 = @trl2
		FROM event
		WHERE event.stp_number = @stp_number 
		AND   event.ord_hdrnumber = @pws_ordhdrnumber

		IF @@ERROR != 0
		BEGIN
				SELECT @err_message = '@err:' + convert(varchar(10), @@ERROR)
				+ 'order: toh_ordnumber='
				+ convert(Char(20), @ord_number)
				+ 'Error update event table stop'
			GOTO error_exit
		END   

		EXEC update_move @mov_number

		-- VH added 3/31/97 to update orderheader with info from first and last stops
		EXEC update_ord @pws_ordhdrnumber,'STD'

	END

	-- VH commented out 3/21 to allow stops to match to orderheader      
	--UPDATE stops
	--SET ord_hdrnumber = 0
	--WHERE stp_type in ('DRP', 'PUP')
	--AND   ord_hdrnumber = @pws_ordhdrnumber	 

error_exit: 

	IF ((@@ERROR != 0) OR (@data_validation_flag != 0))
	   BEGIN
		IF @error_type != 'NODATA' ROLLBACK TRAN ORDER_CREATE
		INSERT INTO tts_errorlog
		(err_batch, err_user_id, err_icon, err_message, err_date, err_item_number, err_type)
		VALUES (@batch_number, @user_id, 'E', @err_message, @today_date, convert(varchar(20), @ord_number), @error_type)
	   END 
	ELSE
	   BEGIN
		COMMIT TRAN ORDER_CREATE
		delete tempordhdr where toh_ordernumber = @ord_number
		delete tempstops where toh_ordernumber = @ord_number
		delete tempref where toh_ordernumber = @ord_number
		delete tempcargos where toh_ordernumber = @ord_number
		delete tempnotes where toh_ordernumber = @ord_number
	   END 

-- End while orders loop
END 

-- This is where we exit if the batch only has updates and/or cancellations (no ORIGINALs)
return_point:

return 1


GO
GRANT EXECUTE ON  [dbo].[order_create_trips] TO [public]
GO
