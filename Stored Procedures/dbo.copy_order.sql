SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[copy_order] 
	@ord 			int,
	@disp_date 		datetime,
	@sched_date		datetime,
	@drv 			char(8),
	@trc 			char(8),
	@trl 			char(13),
	@car 			char (8),
	@user_id 		char (20),
	@batch_number 		int,
	@view_id 		char ( 6 ),
	@allowdup		char ( 1 )
AS

/* Program:	copy_order					*/
/* Descr:	Used by scheduling to copy Master Orders	*/
/* History:	??/??/?? ???	Created??			*/
/* 		09/17/96 TB	Commented out redundant COMMIT	*/
/*		01/15/97 Jude	uncommented commit for 2nd begin tran(update_move proc */
/*		11/11/97 PG	PTS #3285 PG */
/****** Object:  Stored Procedure dbo.copy_order    Script Date: 9/17/96 4:35:21 PM ******/

DECLARE
	@min			int,
	@sysnum			int,
	@neword			int,
	@newordnum		char ( 12 ),
	@newstpnum		int,
	@oldstpnum		int,
	@newmov			int,
	@newlgh			int,
	@status			char ( 6 ),
	@diff			int, 
	@timediff		int,
	@oldordnum		char ( 12 ),
	@rc1name		char ( 18 ),
	@rc1value		char ( 18 ),
	@err_mess		varchar ( 255 ),
	@ordstat		char ( 6 ),
	@err_icon		char ( 1 ),
	@dups			int,
	@err_number		int,
	@err_type		char ( 6 ),
	@err_basemess		varchar ( 255 ),
	@lastlgh		int,
	@refnum			varchar ( 30 ),
	@tblkey			char ( 18 ),
	@newtblkey		char ( 18 ),
	@newordchar		varchar ( 20 )
	
SELECT 	@diff = DATEDIFF ( dy, ord_startdate, @disp_date ),
	@oldordnum = ord_number,
	@rc1name = userlabelname,
	@rc1value = name
FROM 	orderheader, labelfile
WHERE 	ord_hdrnumber = @ord AND
	labeldefinition = 'RevType1' AND
	abbr = ord_revtype1

SELECT 	@refnum = RTRIM ( @oldordnum ) + ' ' + CONVERT ( char ( 8 ), @sched_date, 1 )

EXEC @neword = getsystemnumber 'ORDHDR', '' 

SELECT 	@dups = COUNT (*) 
FROM 	referencenumber, orderheader, labelfile
WHERE 	ref_type = 'COPYFM' AND
	ref_number = @refnum AND
	orderheader.ord_hdrnumber = CONVERT ( int, ref_tablekey ) AND
	ord_status = abbr AND
	labeldefinition = 'DispStatus' AND
	code between 200 and 400

IF @allowdup = 'N' AND @dups > 0
BEGIN
	SELECT 	@err_basemess = 'for View: ' + @view_id + 
		'  Master Order: ' + LTRIM ( RTRIM ( @oldordnum ) ) + 
		'  ' +  LTRIM ( RTRIM (@rc1name ) ) + ':  ' +  LTRIM ( RTRIM ( @rc1value ) ) + 
		' Date: ' + CONVERT ( char ( 8 ), @sched_date, 1 )
	
	SELECT 	@err_mess = 'No Duplicate record written  ' + @err_basemess,
		@err_number = 200,
		@err_icon = 'I'
	SELECT @newordchar = CONVERT ( varchar (20), @neword )
	INSERT INTO tts_errorlog ( 
		err_batch, 
		err_user_id, 
		err_icon, 
		err_message, 
		err_date, 
		err_item_number, 
		err_number,
		err_type )
	VALUES (
		@batch_number, 
		@user_id, 
		@err_icon, 
		@err_mess, 
		GETDATE ( ), 
		@newordchar,
		@err_number,
		@err_type )    
	RETURN
END

EXEC @newmov = getsystemnumber 'MOVNUM', '' 
EXEC @newlgh = getsystemnumber 'LEGHDR', '' 

IF ( SELECT DATEPART ( hh, @disp_date ) ) = 0 AND ( SELECT DATEPART ( mi, @disp_date ) ) = 0 
	SELECT @timediff = 0
ELSE
	SELECT @timediff = ( DATEPART ( mi, @disp_date ) + 60 * DATEPART ( hh, @disp_date ) ) - 
			   ( DATEPART ( mi, ord_startdate ) + 
			   60 * DATEPART ( hh, ord_startdate ) ) 
	FROM orderheader
	WHERE ord_hdrnumber = @ord

IF @car = 'UNKNOWN ' AND ( @drv = 'UNKNOWN' OR @trc = 'UNKNOWN' ) 
	SELECT @ordstat = 'AVL' 
ELSE IF @allowdup = 'Y' AND @dups > 0
	SELECT @ordstat = 'PLN'
ELSE 
BEGIN
	IF @disp_date < @sched_date
		SELECT @ordstat = 'PLN'
	ELSE IF @sched_date = @disp_date
		SELECT @ordstat = 'STD'
	ELSE
		SELECT @ordstat = 'STD'
END

IF @ordstat = 'STD' 
BEGIN
	EXEC cur_activity 'DRV', @drv, @lastlgh OUT
	IF ( SELECT lgh_outstatus FROM legheader WHERE lgh_number = @lastlgh ) <> 'CMP'
		SELECT @ordstat = 'PLN'
END

IF @ordstat = 'STD' 
BEGIN
	EXEC cur_activity 'TRC', @trc, @lastlgh OUT
	IF ( SELECT lgh_outstatus FROM legheader WHERE lgh_number = @lastlgh ) <> 'CMP'
		SELECT @ordstat = 'PLN'
END

/*  First, insert all rows for the source order into temp tables */
/*  Then, update syscontrol numbers on all primary and foreign keys */
/*  Then, insert back into transaction tables */

/*  Create the TEMP tables */
/*  Use views to avoid timestamp problems */

/*  STOPS */
/*  Select stops for order into temp table */
SELECT 	*
INTO 	#tempstops
FROM 	v_stops
WHERE 	ord_hdrnumber = @ord

/*  ORDERHEADER */
SELECT 	*
INTO 	#tempord
FROM 	v_orderheader
WHERE 	ord_hdrnumber = @ord

/* Now, reset the syscontrol numbers */
EXEC  	make_ordnum @neword, @newordnum OUT
UPDATE 	#tempord
SET 	ord_hdrnumber = @neword,
	ord_number = @newordnum,
	mov_number = @newmov,
	ord_bookdate = @sched_date,
	ord_status = @ordstat

/* LOAD REQUIREMENTS */
SELECT 	*
INTO 	#templrq
FROM 	v_loadrequirement
WHERE 	ord_hdrnumber = @ord

/* Now, reset the syscontrol numbers */
UPDATE 	#templrq
SET 	ord_hdrnumber = @neword

/* ACCESSORIAL CHARGES */
SELECT 	*
INTO 	#tempivd
FROM 	v_invoicedetail
WHERE 	ord_hdrnumber = @ord

/* Now, reset the syscontrol numbers */
SELECT @min = 0
WHILE 1=1
BEGIN
	SELECT 	@min = MIN ( ivd_number ) 
	FROM 	#tempivd
	WHERE 	ivd_number > @min AND
		ord_hdrnumber =  @ord
	IF @min IS NULL
		BREAK
	EXEC 	@sysnum = getsystemnumber 'INVDET', ''  
	UPDATE 	#tempivd
	SET 	ivd_number = @sysnum,
		ord_hdrnumber = @neword 
	WHERE 	ivd_number = @min AND
		ord_hdrnumber = @ord
END

/* REFERENCE NUMBERS FOR ORDER HEADER, EXCEPT FIRST ONE WHICH GETS INSERTED BY TRIGGER  */
SELECT 	v_referencenumber.*
INTO 	#temphdrref
FROM 	v_referencenumber
WHERE 	v_referencenumber.ref_table = 'orderheader' AND
	v_referencenumber.ref_tablekey = @ord AND
	ref_sequence > 1

/* Now, reset the syscontrol numbers */
UPDATE 	#temphdrref
SET 	ref_tablekey = @neword

/* NOTES */
SELECT 	@tblkey = CONVERT ( CHAR ( 18 ), @ord )
SELECT 	@newtblkey = CONVERT ( CHAR ( 18 ), @neword )

SELECT 	v_notes.*
INTO 	#tempnotes
FROM 	v_notes
WHERE 	v_notes.ntb_table = 'orderheader' AND
	v_notes.nre_tablekey = @tblkey 

/* Now, reset the syscontrol numbers */
SELECT 	@min = 0
WHILE 2=2
BEGIN
	SELECT 	@min = MIN ( not_number ) 
	FROM 	#tempnotes
	WHERE 	not_number > @min AND
		nre_tablekey = @tblkey 
	IF @min IS NULL
		BREAK
	EXEC 	@sysnum = getsystemnumber 'NOTES', '' 
	UPDATE 	#tempnotes
	SET 	not_number = @sysnum,
		nre_tablekey = @newtblkey
	WHERE 	not_number = @min
END

/* EVENTS, EXCEPT FIRST ONE WHICH GETS INSERTED BY STOP TRIGGER */
SELECT 	v_event.*
INTO 	#tempevt
FROM 	v_event, v_stops
WHERE 	v_event.stp_number = v_stops.stp_number AND
	v_stops.ord_hdrnumber = @ord AND
	evt_sequence > 1

/* REFERENCE NUMBERS EXCEPT FIRST ONE WHICH GETS INSERTED BY STOP TRIGGER */
SELECT 	v_referencenumber.*
INTO 	#tempstopref
FROM 	v_referencenumber, v_stops
WHERE 	v_referencenumber.ref_table = 'stops' AND
	v_referencenumber.ref_tablekey = v_stops.stp_number AND
	v_stops.ord_hdrnumber = @ord AND
	ref_sequence > 1

/* FREIGHT DETAIL EXCEPT FIRST ONE WHICH GETS INSERTED BY STOP TRIGGER */
SELECT 	v_freightdetail.*
INTO 	#tempfgt
FROM 	v_freightdetail, v_stops
WHERE 	v_freightdetail.stp_number = v_stops.stp_number AND
	v_stops.ord_hdrnumber = @ord AND
	fgt_sequence > 1

/*  Now, loop through temp table and reset syscontrol numbers */
SELECT @oldstpnum = 0
WHILE 3=3
BEGIN
	SELECT 	@oldstpnum = MIN ( stp_number ) 
	FROM 	#tempstops 
	WHERE 	stp_number > @oldstpnum AND
		ord_hdrnumber = @ord
	IF @oldstpnum IS NULL
		BREAK

	EXEC 	@newstpnum = getsystemnumber 'STPNUM', '' 
	
	IF @ordstat = 'STD'
	BEGIN
		IF ( SELECT stp_sequence FROM #tempstops WHERE stp_number = @oldstpnum ) = 1
			SELECT @status = 'DNE'
		ELSE
			SELECT @status = 'OPN'
	END
	ELSE
		SELECT @status = 'OPN'

	UPDATE 	#tempstops
	SET 	stp_number = @newstpnum,
		ord_hdrnumber = @neword,
		mov_number = @newmov,
		lgh_number = @newlgh,
		stp_status = @status,
		stp_schdtearliest = DATEADD ( dy, @diff, stp_schdtearliest ),
		stp_schdtlatest = DATEADD ( dy, @diff, stp_schdtlatest ),
		stp_arrivaldate =DATEADD ( dy, @diff, stp_arrivaldate ),
		stp_departuredate = DATEADD ( dy, @diff, stp_departuredate )
	WHERE 	stp_number = @oldstpnum

	IF @timediff > 0 
	BEGIN
		UPDATE 	#tempstops
		SET 	stp_schdtearliest = DATEADD ( mi, @timediff, stp_schdtearliest ),
			stp_schdtlatest = DATEADD ( mi, @timediff, stp_schdtlatest ),
			stp_arrivaldate =DATEADD ( mi, @timediff, stp_arrivaldate ),
			stp_departuredate = DATEADD ( mi, @timediff, stp_departuredate )
		WHERE 	stp_number = @newstpnum
	END

		/* events loop inside stops loop */
	SELECT @min = 0
	WHILE 4=4
	BEGIN
		SELECT 	@min = MIN ( evt_number ) 
		FROM 	#tempevt
		WHERE 	evt_number > @min AND
			stp_number = @oldstpnum
		IF @min IS NULL
			BREAK

		EXEC 	@sysnum = getsystemnumber 'EVTNUM', '' 
		
		UPDATE 	#tempevt
		SET 	stp_number = @newstpnum,
			evt_number = @sysnum,
			ord_hdrnumber = @neword,
			evt_startdate = DATEADD ( dy, @diff, evt_startdate ),
			evt_enddate = DATEADD ( dy, @diff, evt_enddate ),
			evt_earlydate = DATEADD ( dy, @diff, evt_earlydate ),
			evt_latedate = DATEADD ( dy, @diff, evt_latedate ),
			evt_status = 'OPN' 
		WHERE 	evt_number = @min

		IF @timediff > 0
		BEGIN
			UPDATE 	#tempevt
			SET 	evt_startdate = DATEADD ( mi, @timediff, evt_startdate ),
				evt_enddate = DATEADD ( mi, @timediff, evt_enddate ),
				evt_earlydate = DATEADD ( mi, @timediff, evt_earlydate ),
				evt_latedate = DATEADD ( mi, @timediff, evt_latedate )
			WHERE 	evt_number = @sysnum
		END
	END

	/* ref# inside stops loop */
	UPDATE 	#tempstopref
	SET 	ref_tablekey = @newstpnum
	WHERE 	ref_tablekey = @oldstpnum AND
		ref_table = 'stops'

	/* frgt inside stops loop */
	SELECT @min = 0
	WHILE 	5=5
	BEGIN
		SELECT 	@min = MIN ( fgt_number ) 
		FROM 	#tempfgt
		WHERE 	fgt_number > @min AND
			stp_number = @oldstpnum
		IF @min IS NULL
			BREAK

		EXEC 	@sysnum = getsystemnumber 'FGTNUM', '' 
		UPDATE 	#tempfgt
		SET 	stp_number = @newstpnum,
			fgt_number = @sysnum
		WHERE 	fgt_number = @min
	END		
END
	
/* Must do stops first, so stops trigger won't log inserted stops into inserted/deleted stops log table */
BEGIN TRAN 
SELECT 	@min = 0
WHILE 	6=6
BEGIN
	SELECT 	@min = MIN ( stp_number ) 
	FROM 	#tempstops
	WHERE 	stp_number > @min
	IF @min IS NULL
		BREAK
	INSERT 	v_stops
	SELECT 	* FROM 	#tempstops WHERE stp_number = @min
END

INSERT 	v_orderheader
SELECT 	* FROM #tempord

/* Must delete the ones that were created in the orderheader insert trigger */
DELETE 	loadrequirement
WHERE 	ord_hdrnumber = @neword

/*  Now insert the ones from the master order */
INSERT 	v_loadrequirement
SELECT 	* FROM #templrq 

INSERT 	v_notes
SELECT 	* FROM #tempnotes

INSERT 	v_invoicedetail
SELECT 	* FROM #tempivd

SELECT @min = 0
WHILE 	7=7
BEGIN
	SELECT 	@min = MIN ( evt_number ) 
	FROM 	#tempevt
	WHERE 	evt_number > @min
	IF @min IS NULL
		BREAK
	INSERT 	v_event
	SELECT 	* FROM #tempevt WHERE evt_number = @min
END

INSERT v_referencenumber
SELECT * FROM #temphdrref

INSERT v_referencenumber
SELECT * FROM #tempstopref

INSERT v_freightdetail
SELECT * FROM #tempfgt

/* Now set the assignment on the events */
UPDATE 	event
SET 	evt_driver1 = @drv,
	evt_tractor = @trc,
	evt_trailer1 = @trl,
	evt_carrier = @car
FROM 	stops
WHERE 	stops.stp_number = event.stp_number AND
	stops.ord_hdrnumber = @neword

SELECT @refnum = RTRIM ( @oldordnum ) + ' ' + CONVERT ( char ( 8 ), @sched_date, 1 )
/* Entry in reference number table to refer target order back to source */
INSERT INTO referencenumber (
	ref_tablekey,
	ref_type,
	ref_number,
	ref_sequence,
	ord_hdrnumber,
	ref_table )
VALUES ( @neword,
	'COPYFM',
	@refnum,
	999,
	@neword,
	'orderheader' )
COMMIT TRAN

EXEC update_move @newmov
EXEC update_ord @newmov, 'STD'

/* Insert successful transaction into log */

SELECT @err_basemess = 'for View: ' + @view_id + 
		'  Master Order: ' + LTRIM ( RTRIM ( @oldordnum ) ) + 
		'  ' +  LTRIM ( RTRIM (@rc1name ) ) + ':  ' +  LTRIM ( RTRIM ( @rc1value ) ) + 
		' Order: ' +  LTRIM ( RTRIM ( @newordnum ) ) + 
		' Date: ' + CONVERT ( char ( 8 ), @sched_date, 1 )

IF @ordstat = 'AVL'
	SELECT 	@err_icon = 'E',
		@err_mess = 'No Resources Assigned ' + @err_basemess,
		@err_number = 100
ELSE
	SELECT 	@err_icon = 'I',
		@err_mess = 'Route Succesfully Scheduled ' + @err_basemess,
		@err_number = 0

INSERT INTO tts_errorlog ( 
		err_batch, 
		err_user_id, 
		err_icon, 
		err_message, 
		err_date, 
		err_item_number, 
		err_number,
		err_type )
	VALUES (
		@batch_number, 
		@user_id, 
		@err_icon, 
		@err_mess, 
		GETDATE ( ), 
		@newordchar,
		@err_number,
		@err_type )    

IF @dups > 0 
BEGIN
	SELECT 	@err_mess = 'Duplicate ' + @err_basemess,
		@err_number = 200
	INSERT INTO tts_errorlog ( 
		err_batch, 
		err_user_id, 
		err_icon, 
		err_message, 
		err_date, 
		err_item_number, 
		err_number,
		err_type )
	VALUES (
		@batch_number, 
		@user_id, 
		@err_icon, 
		@err_mess, 
		GETDATE ( ), 
		@newordchar,
		@err_number,
		@err_type )    
END
return
GO
GRANT EXECUTE ON  [dbo].[copy_order] TO [public]
GO
