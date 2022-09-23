CREATE TABLE [dbo].[jws_import_order_weights]
(
[iow_id] [int] NOT NULL IDENTITY(1, 1),
[iow_masterordernumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iow_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iow_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iow_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iow_ticketnumber] [int] NULL,
[iow_weight] [int] NULL,
[iow_tareweight] [int] NULL,
[iow_deliverydate] [datetime] NULL,
[iow_message] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iow_terminal] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iow_updateby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iow_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[itut_jws_import_order_weights] ON [dbo].[jws_import_order_weights] FOR INSERT, UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/**
* 
* NAME:
*	dbo.itut_jws_import_order_weights
*
* TYPE:
*	[Trigger]
*
* DESCRIPTION:
*	This trigger takes imported order information and calls cloneorderwithoptions_aggregate stored procedure to
*	create a copy of the master order.  It then updates the weight information and completes the order.  If the
*	the order creation and update was successful, it will then delete the record from the table else it will
*	leave the record in the table and update the message column with the reason the data did not generate an
*	order.
*
* RETURNS:
*	None.
*
* RESULT SETS: 
*	None.
*
* PARAMETERS:
*	None.
*
* REFERENCES:
*	cloneorderwithoptions_aggregate
* 
* REVISION HISTORY:
*	2005/07/28.01	KWS		PTS 24618	Created
*   8/25/05			MS		PTS 29513   Since this has become a 2000 only trigger, the DB Mod
*										PTS24618 is no longer REQUIRED (and, in fact, causes
*										the build to blowup).  PTS24618.sql will be applied via
*										our base sql set.  In addition, this trigger was renamed
*										itut_jws_import_order_weights_2000 so as to have it pulled
*										into the _2000 only sql set.-MS
* JJF/RE hotfix 2007-01-09
* JJF hotfix 2007-03-08
* DPETE 41629 add arguments to cloneorder 
* 44064:  JSwindell 9-22-2008 add argument to cloneorder 
* 47383: SGB 05/05/09 added argument to cloneorder for PTS 43913
* 47383: SGB 06/01/09 added new column to #neworder to support cloneorder change
**/
DECLARE	@id					 	int,
		@user				 	varchar(255),
		@masterordernumber	 	varchar(12),
		@driver				 	varchar(8),
		@tractor			 	varchar(8),
		@trailer			 	varchar(13),
		@ticketnumber		 	int,
		@weight				 	money,
		@tareweight			 	money,
		@deliverydate		 	datetime,
		@message			 	varchar(1000),
		@revtype3			 	varchar(6),
		@revtype4			 	varchar(6),
		@lodate				 	datetime,
		@hidate				 	datetime,
		@ordnumber				varchar(12),
		@ordhdrnumber		 	integer,
		@extra_id			 	integer,
		@tab_id				 	integer,
		@col_id_ticket_number	integer,
		@col_id_master_order	integer,
		@col_id_tractor			integer,
		@col_id_driver			integer,
		@col_id_trailer			integer,
		@col_id_weight			integer,
		@col_id_tare_weight		integer,
		@col_id_delivery_date	integer,
		@col_id_processed_by	integer,
		@col_id_processed_date	integer,
		@seq					integer,
		@mfh_number				integer,
		@app					varchar(128),
		@cnt					integer,
		--PTS 36606 - JJF 3/9/2007 Handle the case where a BOL entry is already in place	
		@bol_seq		integer
		--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	

CREATE TABLE #neworder(
	ord_number 		VARCHAR(12),
	ord_startdate	DATETIME,
	ord_shipper		VARCHAR(8),
	shipper_name	VARCHAR(50),
	ord_consignee	VARCHAR(8),
	consignee_name	VARCHAR(50),
	ord_hdrnumber	INTEGER,
	ord_fromorder	VARCHAR(12),
	mov_number INTEGER)   --PTS 47383 cloneorder now returns move_number
		
SET @app = LTRIM(RTRIM(APP_NAME()))

EXEC gettmwuser @user OUTPUT

SELECT	@id = MIN(iow_id)
FROM	inserted

SELECT	@extra_id = EXTRA_ID
  FROM	extra_info_header 
 WHERE	TABLE_NAME = 'ord'

SELECT	@tab_id = TAB_ID
  FROM	extra_info_tab
 WHERE	EXTRA_ID = @extra_id AND
		TAB_NAME = 'JWS Ticket Information'

SELECT	@col_id_ticket_number = COL_ID
  FROM	extra_info_cols
 WHERE	EXTRA_ID = @extra_id AND
		TAB_ID = @tab_id AND
		COL_NAME = 'Ticket Number'

SELECT	@col_id_master_order = COL_ID
  FROM	extra_info_cols
 WHERE	EXTRA_ID = @extra_id AND
		TAB_ID = @tab_id AND
		COL_NAME = 'Master Order'

SELECT	@col_id_tractor = COL_ID
  FROM	extra_info_cols
 WHERE	EXTRA_ID = @extra_id AND
		TAB_ID = @tab_id AND
		COL_NAME = 'Tractor'

SELECT	@col_id_driver = COL_ID
  FROM	extra_info_cols
 WHERE	EXTRA_ID = @extra_id AND
		TAB_ID = @tab_id AND
		COL_NAME = 'Driver'

SELECT	@col_id_trailer = COL_ID
  FROM	extra_info_cols
 WHERE	EXTRA_ID = @extra_id AND
		TAB_ID = @tab_id AND
		COL_NAME = 'Trailer'

SELECT	@col_id_weight = COL_ID
  FROM	extra_info_cols
 WHERE	EXTRA_ID = @extra_id AND
		TAB_ID = @tab_id AND
		COL_NAME = 'Weight'

SELECT	@col_id_tare_weight = COL_ID
  FROM	extra_info_cols
 WHERE	EXTRA_ID = @extra_id AND
		TAB_ID = @tab_id AND
		COL_NAME = 'Tare Weight'

SELECT	@col_id_delivery_date = COL_ID
  FROM	extra_info_cols
 WHERE	EXTRA_ID = @extra_id AND
		TAB_ID = @tab_id AND
		COL_NAME = 'Delivery Date'

SELECT	@col_id_processed_by = COL_ID
  FROM	extra_info_cols
 WHERE	EXTRA_ID = @extra_id AND
		TAB_ID = @tab_id AND
		COL_NAME = 'Processed By'

SELECT	@col_id_processed_date = COL_ID
  FROM	extra_info_cols
 WHERE	EXTRA_ID = @extra_id AND
		TAB_ID = @tab_id AND
		COL_NAME = 'Processed Date'

WHILE ISNULL(@id, 0) > 0
BEGIN
	SELECT	@masterordernumber = ISNULL(iow_masterordernumber, 'UNKNOWN'),
			@driver = ISNULL(iow_driver, 'UNKNOWN'),
			@tractor = ISNULL(iow_tractor, 'UNKNOWN'),
			@trailer = ISNULL(iow_trailer, 'UNKNOWN'),
			@ticketnumber = ISNULL(iow_ticketnumber, 0),
			@weight = ISNULL(iow_weight, 0),
			@tareweight = ISNULL(iow_tareweight, 0),
			@deliverydate = ISNULL(iow_deliverydate, '01/01/1900'),
			@message = ISNULL(iow_message, '')
	FROM	inserted
	WHERE	iow_id = @id

	IF @app <> 'ORD' AND LEN(@message) > 0
	BEGIN
		SET @message = 'SKIP'
	END

	IF @masterordernumber = 'DELETE'
	BEGIN
		SET @message = 'DELETE'
	END
	ELSE IF @message <> 'SKIP'
	BEGIN
		SELECT	@masterordernumber = ISNULL(o.ord_number, 'UNKNOWN'),
				@driver = CASE ISNULL(iow_driver, 'UNKNOWN') WHEN 'UNKNOWN' THEN ISNULL(trc.trc_driver, 'UNKNOWN') ELSE ISNULL(m.mpp_id, 'UNKNOWN') END,
				@tractor = ISNULL(trc.trc_number, 'UNKNOWN'),
				@trailer = ISNULL(trl.trl_number, 'UNKNOWN'),
				@ticketnumber = ISNULL(iow_ticketnumber, 0),
				@weight = ISNULL(iow_weight, 0),
				@tareweight = ISNULL(iow_tareweight, 0),
				@deliverydate = ISNULL(iow_deliverydate, '01/01/1900'),
				@revtype3 = ISNULL(o.ord_revtype3, 'UNK'),
				@revtype4 = ISNULL(o.ord_revtype4, 'UNK')
		FROM	inserted
					LEFT OUTER JOIN orderheader o ON o.ord_number = iow_masterordernumber
					LEFT OUTER JOIN manpowerprofile m ON m.mpp_id = iow_driver
					LEFT OUTER JOIN tractorprofile trc ON trc.trc_number = iow_tractor
					LEFT OUTER JOIN trailerprofile trl ON trl.trl_number = iow_trailer
		WHERE	iow_id = @id

		SELECT	@revtype3 = ISNULL(@revtype3, 'UNK'), @revtype4 = ISNULL(@revtype4, 'UNK')
	
		SELECT	@lodate = CAST((CONVERT( VARCHAR(8), @deliverydate, 112) + ' 00:00:00') AS DATETIME),
				@hidate = CAST((CONVERT( VARCHAR(8), @deliverydate, 112) + ' 23:59:59') AS DATETIME)
	
		IF (@revtype3 = 'MATER' OR @revtype4 = 'MATER')
		BEGIN
			SET @message = ''
			SELECT	@message = @message + CASE WHEN (@revtype3 = 'MATER' AND @revtype4 <> 'MATER') OR (@revtype3 <> 'MATER' AND @revtype4 = 'MATER')THEN ', Invalid Material Only Master Order (Rev Types 3&4 must both be MATER)' ELSE ''END
			SELECT	@message = @message + CASE WHEN ISNULL(@ticketnumber, 0) <= 0 THEN ', Invalid Ticket Number' ELSE '' END
			SELECT	@message = @message + CASE WHEN ISNULL(@weight, 0) <= 0 THEN ', Invalid Gross Weight' ELSE '' END
			SELECT	@message = @message + CASE WHEN ISNULL(@tareweight, 0) <= 0 THEN ', Invalid Tare Weight' ELSE '' END
			SELECT	@message = @message + CASE ISNULL(@deliverydate, '19000101') WHEN '19000101' THEN ', Invalid Delivery Date' ELSE '' END

			IF @message = ''
			BEGIN
				SET @message = 'No Error'
			END
			ELSE
			BEGIN
				SET @message = RIGHT(@message, LEN(@message) - 2)
			END
--			SELECT	@message =	CASE WHEN (@revtype3 = 'MATER' AND @revtype4 <> 'MATER') OR (@revtype3 <> 'MATER' AND @revtype4 = 'MATER')THEN 'Invalid Material Only Master Order (Rev Types 3&4 must both be MATER)' ELSE
--								CASE WHEN ISNULL(@ticketnumber, 0) <= 0 THEN 'Invalid Ticket Number' ELSE
--								CASE WHEN ISNULL(@weight, 0) <= 0 THEN 'Invalid Gross Weight' ELSE
--								CASE WHEN ISNULL(@tareweight, 0) <= 0 THEN 'Invalid Tare Weight' ELSE
--								CASE ISNULL(@deliverydate, '19000101') WHEN '19000101' THEN 'Invalid Delivery Date' ELSE 'No Error'
--								END END END END END
		END
		ELSE
		BEGIN
			IF ISNULL(@trailer, 'UNKNOWN') = 'UNKNOWN'
			BEGIN
				IF ISNULL(@tractor, 'UNKNOWN') <> 'UNKNOWN'
				BEGIN
					SELECT	@cnt = COUNT(DISTINCT lgh_primary_trailer)
					  FROM	legheader
					 WHERE	lgh_tractor = @tractor AND
							(lgh_driver1 = @driver OR ISNULL(@driver, 'UNKNOWN') = 'UNKNOWN') AND
							lgh_startdate >= @deliverydate AND
							lgh_startdate < DATEADD(dd, 1, @deliverydate)

					IF @cnt = 1
					BEGIN
						SELECT	@trailer = ISNULL(MIN(lgh_primary_trailer), 'UNKNOWN')
						  FROM	legheader
						 WHERE	lgh_tractor = @tractor AND
								(lgh_driver1 = @driver OR ISNULL(@driver, 'UNKNOWN') = 'UNKNOWN') AND
								lgh_startdate >= @deliverydate AND
								lgh_startdate < DATEADD(dd, 1, @deliverydate)
					END
				END
			END
			SET @message = ''
			SELECT	@message = @message + CASE ISNULL(@masterordernumber, 'UNKNOWN') WHEN 'UNKNOWN' THEN ', Invalid Master Order Number' ELSE '' END
			SELECT	@message = @message + CASE ISNULL(@driver, 'UNKNOWN') WHEN 'UNKNOWN' THEN ', Invalid Driver' ELSE '' END
			SELECT	@message = @message + CASE ISNULL(@tractor, 'UNKNOWN') WHEN 'UNKNOWN' THEN ', Invalid Tractor' ELSE ''END
			SELECT	@message = @message + CASE ISNULL(@trailer, 'UNKNOWN') WHEN 'UNKNOWN' THEN ', Invalid Trailer' ELSE ''END
			SELECT	@message = @message + CASE WHEN ISNULL(@ticketnumber, 0) <= 0 THEN ', Invalid Ticket Number' ELSE ''END
			SELECT	@message = @message + CASE WHEN ISNULL(@weight, 0) <= 0 THEN ', Invalid Gross Weight' ELSE ''END
			SELECT	@message = @message + CASE WHEN ISNULL(@tareweight, 0) <= 0 THEN ', Invalid Tare Weight' ELSE ''END
			SELECT	@message = @message + CASE ISNULL(@deliverydate, '19000101') WHEN '19000101' THEN ', Invalid Delivery Date' ELSE ''END

			IF @message = ''
			BEGIN
				SET @message = 'No Error'
			END
			ELSE
			BEGIN
				SET @message = RIGHT(@message, LEN(@message) - 2)
			END
--			SELECT	@message =	CASE ISNULL(@masterordernumber, 'UNKNOWN') WHEN 'UNKNOWN' THEN 'Invalid Master Order Number' ELSE
--								CASE ISNULL(@driver, 'UNKNOWN') WHEN 'UNKNOWN' THEN 'Invalid Driver' ELSE
--								CASE ISNULL(@tractor, 'UNKNOWN') WHEN 'UNKNOWN' THEN 'Invalid Tractor' ELSE
--								CASE ISNULL(@trailer, 'UNKNOWN') WHEN 'UNKNOWN' THEN 'Invalid Trailer' ELSE
--								CASE WHEN ISNULL(@ticketnumber, 0) <= 0 THEN 'Invalid Ticket Number' ELSE
--								CASE WHEN ISNULL(@weight, 0) <= 0 THEN 'Invalid Gross Weight' ELSE
--								CASE WHEN ISNULL(@tareweight, 0) <= 0 THEN 'Invalid Tare Weight' ELSE
--								CASE ISNULL(@deliverydate, '19000101') WHEN '19000101' THEN 'Invalid Delivery Date' ELSE 'No Error'
--								END END END END END END END END
		END
	END
	
	IF @message = 'No Error'
	BEGIN
		DELETE	#neworder

		-- If we have a valid ticket number (BOL) check to see if it has been processed previously
		IF EXISTS(SELECT	* 
					FROM	extra_info_data
								INNER JOIN orderheader oh ON oh.ord_hdrnumber = TABLE_KEY
								INNER JOIN legheader lgh ON lgh.ord_hdrnumber = oh.ord_hdrnumber
				   WHERE	lgh.lgh_startdate >= @lodate AND
							lgh.lgh_startdate <= @hidate AND
							EXTRA_ID = @extra_id AND 
							TAB_ID = @tab_id AND
							COL_ID = @col_id_ticket_number AND
							COL_DATA = CAST(@ticketnumber AS VARCHAR(50)))
		BEGIN
			-- Record has already been imported delete record and continue looping
			SELECT	@ordhdrnumber = CAST(TABLE_KEY AS INTEGER)
			  FROM	extra_info_data
			 WHERE	EXTRA_ID = @extra_id AND 
					TAB_ID = @tab_id AND
					COL_ID = @col_id_ticket_number AND
					COL_DATA = CAST(@ticketnumber AS VARCHAR(50))

			INSERT INTO jws_audit
				(jwsa_deliverydate,
				 jwsa_master_order,
				 jwsa_ticketnumber,
				 ord_hdrnumber,
				 jwsa_tractor,
				 jwsa_driver,
				 jwsa_trailer,
				 jws_tareweight,
				 jws_weight,
				 jwsa_action,
				 jwsa_audit_user,
				 jwsa_audit_dttm)
			VALUES 
				(@deliverydate,
				 @masterordernumber,
				 @ticketnumber,
				 @ordhdrnumber,
				 NULL,
				 NULL,
				 NULL,
				 NULL,
				 NULL,
				 'Order Previously Updated',
				 @user,
				 getdate())

   			DELETE	jws_import_order_weights
   			 WHERE	iow_id = @id
		END
		ELSE
		BEGIN
			-- Use revtype3 and revtype4 to determine if this a material only order
			IF @revtype3 = 'MATER' AND @revtype4 = 'MATER'
			BEGIN
				-- Material only order copy master, place 'DONOTPAY' carrier on trip
				--PTS 40559 JJF- add needed parms
				--PTS 44064 JSwindell - add new parm
				--PTS 56991 JJF 20110511 - correct parm
				INSERT INTO #neworder EXEC cloneorderwithoptions_aggregate 1, @masterordernumber, @user, 'N', @deliverydate, 0, 0, 0, 'N',
										'CMP', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'N', 'N', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN',
										'UNKNOWN', 'UNKNOWN', 'DONOTPAY', 7, 'UNKNOWN', 'N', '', 'N', 'N', 'Y', -1, 'Y', '', '', 'N' ,'UNK', 'N','N'
	
				IF @@ERROR = 0
				BEGIN		
					-- Mark trip as paid			
					UPDATE	assetassignment
					   SET	pyd_status = 'PPD'
					  FROM	assetassignment aa
								INNER JOIN orderheader oh ON oh.mov_number = aa.mov_number
								INNER JOIN #neworder n on oh.ord_hdrnumber = oh.ord_hdrnumber
					 WHERE	aa.asgn_type = 'CAR' AND
							aa.asgn_id = 'DONOTPAY'

					SELECT	@seq = ref_sequence
					  FROM	referencenumber
								INNER JOIN #neworder ON #neworder.ord_hdrnumber = ref_tablekey
					 WHERE	ref_table = 'orderheader' AND
							ref_type = 'TRANS'
	
					--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
					SELECT	@bol_seq = MIN(ref_sequence)
					  FROM	referencenumber
								INNER JOIN #neworder ON #neworder.ord_hdrnumber = ref_tablekey
					 WHERE	ref_table = 'orderheader' AND
							ref_type = 'BOL'
					--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	

					--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
					--IF ISNULL(@seq, -1) = -1 
					IF ISNULL(@seq, -1) = -1 AND ISNULL(@bol_seq, -1) = -1
					--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
					BEGIN

						UPDATE	referencenumber
						   SET	ref_sequence = ref_sequence + 1
						  FROM	#neworder
						 WHERE	#neworder.ord_hdrnumber = ref_tablekey AND
								ref_table = 'orderheader'
					END
					--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
					--ELSE 
					ELSE IF ISNULL(@seq, -1) > 0
					--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
					BEGIN
						DELETE	referencenumber
						  FROM	#neworder
						 WHERE	#neworder.ord_hdrnumber = ref_tablekey AND
								ref_table = 'orderheader' AND
								ref_sequence = @seq

						UPDATE	referencenumber
						   SET	ref_sequence = CASE WHEN ref_sequence < ISNULL(@seq, -1) THEN ref_sequence + 1 ELSE ref_sequence END
						  FROM	#neworder
						 WHERE	#neworder.ord_hdrnumber = ref_tablekey AND
								ref_table = 'orderheader'
					END
		
					-- update weights
					UPDATE	orderheader
					   SET	ord_grossweight = @weight,
							ord_tareweight = @tareweight,
							ord_totalweight = @weight - @tareweight,
							ord_totalweightunits = 'LBS',
							ord_refnum = CONVERT(VARCHAR(30), @ticketnumber),
							ord_reftype = 'BOL',
							ord_bookedby = 'JWS AUDIT',
							ord_order_source = 'JWS'
					  FROM	#neworder n
					 WHERE	orderheader.ord_number = n.ord_number
		
					IF @@ERROR = 0
					BEGIN
						--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
						IF ISNULL(@bol_seq, -1) = -1 BEGIN
						--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
							INSERT INTO referencenumber 
										(ref_tablekey,
										ref_type,
										ref_number,
										ref_sequence,
										ord_hdrnumber,
										ref_table)
								SELECT	n.ord_hdrnumber,
										'BOL',
										@ticketnumber,
										1,
										n.ord_hdrnumber,
										'orderheader'
								  FROM	#neworder n
						--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
						END
						ELSE BEGIN
							UPDATE	referencenumber
							   SET	ref_number = @ticketnumber
							  FROM	#neworder
							 WHERE	#neworder.ord_hdrnumber = ref_tablekey AND
								ref_table = 'orderheader' AND
								ref_sequence = @bol_seq
						END
						--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
					END

					IF @@ERROR = 0
					BEGIN
						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
							SELECT	@extra_id, @tab_id, @col_id_ticket_number, CAST(@ticketnumber AS VARCHAR(50)), CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
							  FROM	#neworder

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
							SELECT	@extra_id, @tab_id, @col_id_master_order, @masterordernumber, CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
							  FROM	#neworder

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
							SELECT	@extra_id, @tab_id, @col_id_tractor, @tractor, CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
							  FROM	#neworder

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
							SELECT	@extra_id, @tab_id, @col_id_driver, @driver, CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
							  FROM	#neworder

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
							SELECT	@extra_id, @tab_id, @col_id_trailer, @trailer, CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
							  FROM	#neworder

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
							SELECT	@extra_id, @tab_id, @col_id_weight, CAST(@weight AS VARCHAR(50)), CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
							  FROM	#neworder

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
							SELECT	@extra_id, @tab_id, @col_id_tare_weight, CAST(@tareweight AS VARCHAR(50)), CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
							  FROM	#neworder

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
							SELECT	@extra_id, @tab_id, @col_id_delivery_date, CONVERT(VARCHAR(50), @deliverydate, 101), CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
							  FROM	#neworder

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
							SELECT	@extra_id, @tab_id, @col_id_processed_by, @user, CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
							  FROM	#neworder

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
							SELECT	@extra_id, @tab_id, @col_id_processed_date, CONVERT(VARCHAR(50), getdate(), 101) + ' ' + CONVERT(VARCHAR(50), getdate(), 108), CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
							  FROM	#neworder
					END
		
			   		IF @@ERROR = 0
					BEGIN
						INSERT INTO jws_audit
							(jwsa_deliverydate,
							 jwsa_master_order,
							 jwsa_ticketnumber,
							 ord_hdrnumber,
							 jwsa_tractor,
							 jwsa_driver,
							 jwsa_trailer,
							 jws_tareweight,
							 jws_weight,
							 jwsa_action,
							 jwsa_audit_user,
							 jwsa_audit_dttm)
							SELECT	@deliverydate,
							 		@masterordernumber,
							 		@ticketnumber,
									ord_hdrnumber,
									NULL,
									NULL,
									NULL,
									@tareweight,
									@weight,
									'Material Only Order Created',
									@user,
									getdate()
							  FROM	#neworder

			   			DELETE FROM jws_import_order_weights
			   			WHERE iow_id = @id
					END   
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT	*
							FROM	legheader lgh (NOLOCK)
										INNER JOIN orderheader oh ON oh.ord_hdrnumber = lgh.ord_hdrnumber
						   WHERE	lgh.lgh_driver1 = @driver AND
									lgh.lgh_tractor = @tractor AND
									lgh.lgh_primary_trailer = @trailer AND
									lgh.lgh_startdate >= @lodate AND
									lgh.lgh_startdate <= @hidate AND
									oh.ord_fromorder = @masterordernumber AND
									NOT EXISTS(SELECT	*
												 FROM	extra_info_data
												WHERE	EXTRA_ID = @extra_id AND
														TAB_ID = @tab_id AND
														COL_ID = @col_id_ticket_number AND
														TABLE_KEY = CAST(oh.ord_hdrnumber AS VARCHAR(50))))
				BEGIN
					SELECT	@mfh_number = MIN(lgh.mfh_number)
					  FROM	legheader lgh (NOLOCK)
								INNER JOIN orderheader oh ON oh.ord_hdrnumber = lgh.ord_hdrnumber
					 WHERE	lgh.lgh_driver1 = @driver AND
							lgh.lgh_tractor = @tractor AND
							lgh.lgh_primary_trailer = @trailer AND
							lgh.lgh_startdate >= @lodate AND
							lgh.lgh_startdate <= @hidate AND
							oh.ord_fromorder = @masterordernumber AND
							NOT EXISTS(SELECT	*
										 FROM	extra_info_data
										WHERE	EXTRA_ID = @extra_id AND
												TAB_ID = @tab_id AND
												COL_ID = @col_id_ticket_number AND
												TABLE_KEY = CAST(oh.ord_hdrnumber AS VARCHAR(50)))

					SELECT	@ordhdrnumber = MIN(oh.ord_hdrnumber)
					  FROM	legheader lgh (NOLOCK)
								INNER JOIN orderheader oh ON oh.ord_hdrnumber = lgh.ord_hdrnumber
					 --JJF/RE hotfix 2007-01-09
					 --WHERE	lgh.mfh_number = @mfh_number AND
				     WHERE (lgh.mfh_number = @mfh_number or @mfh_number is null) AND
							lgh.lgh_driver1 = @driver AND
							lgh.lgh_tractor = @tractor AND
							lgh.lgh_primary_trailer = @trailer AND
							lgh.lgh_startdate >= @lodate AND
							lgh.lgh_startdate <= @hidate AND
							oh.ord_fromorder = @masterordernumber AND
							NOT EXISTS(SELECT	*
										 FROM	extra_info_data
										WHERE	EXTRA_ID = @extra_id AND
												TAB_ID = @tab_id AND
												COL_ID = @col_id_ticket_number AND
												TABLE_KEY = CAST(oh.ord_hdrnumber AS VARCHAR(50)))

					SELECT	@seq = ref_sequence
					  FROM	referencenumber
					 WHERE	ref_table = 'orderheader' AND
							ref_type = 'TRANS' AND
							ref_tablekey = @ordhdrnumber

					--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
					SELECT	@bol_seq = MIN(ref_sequence)
					  FROM	referencenumber
					 WHERE	ref_table = 'orderheader' AND
							ref_type = 'BOL' AND
							ref_tablekey = @ordhdrnumber
					--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	

					--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
					--IF ISNULL(@seq, -1) = -1 
					IF ISNULL(@seq, -1) = -1 AND ISNULL(@bol_seq, -1) = -1
					--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
					BEGIN
						UPDATE	referencenumber
						   SET	ref_sequence = ref_sequence + 1
						 WHERE	ref_tablekey = @ordhdrnumber AND
								ref_table = 'orderheader'
					END  -- IF
					--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
					--ELSE 
					ELSE IF ISNULL(@seq, -1) > 0
					--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
					BEGIN
						DELETE	referencenumber
						 WHERE	ref_tablekey = @ordhdrnumber AND
								ref_table = 'orderheader' AND
								ref_sequence = @seq

						UPDATE	referencenumber
						   SET	ref_sequence = CASE WHEN ref_sequence < ISNULL(@seq, -1) THEN ref_sequence + 1 ELSE ref_sequence END
						 WHERE	ref_tablekey = @ordhdrnumber AND
								ref_table = 'orderheader'
					END  -- ELSE
		
					UPDATE	orderheader
					   SET	ord_grossweight = @weight,
							ord_tareweight = @tareweight,
							ord_totalweight = @weight - @tareweight,
							ord_totalweightunits = 'LBS',
							ord_refnum = CONVERT(VARCHAR(30), @ticketnumber),
							ord_reftype = 'BOL',
							ord_bookedby = 'JWS AUDIT',
							ord_order_source = 'JWS'
					 WHERE	orderheader.ord_hdrnumber = @ordhdrnumber
		
					IF @@ERROR = 0
					BEGIN
						--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
						IF ISNULL(@bol_seq, -1) = -1 BEGIN
						--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
							INSERT INTO referencenumber 
								(ref_tablekey,
								 ref_type,
								 ref_number,
								 ref_sequence,
								 ord_hdrnumber,
								 ref_table)
							VALUES
								(@ordhdrnumber,
								 'BOL',
								 @ticketnumber,
								 1,
								 @ordhdrnumber,
								 'orderheader')
						--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
						END
						ELSE BEGIN
							UPDATE	referencenumber
							   SET	ref_number = @ticketnumber
							 WHERE	ref_tablekey = @ordhdrnumber AND
								ref_table = 'orderheader' AND
								ref_sequence = @bol_seq
						END
						--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
					END  -- If @@ERROR
		
					IF @@ERROR = 0
					BEGIN
						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
						VALUES
							(@extra_id, @tab_id, @col_id_ticket_number, CAST(@ticketnumber AS VARCHAR(50)), CAST(@ordhdrnumber AS VARCHAR(50)), 1, @user, getdate(), NULL, NULL)

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
						VALUES
							(@extra_id, @tab_id, @col_id_master_order, @masterordernumber, CAST(@ordhdrnumber AS VARCHAR(50)), 1, @user, getdate(), NULL, NULL)

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
						VALUES
							(@extra_id, @tab_id, @col_id_tractor, @tractor, CAST(@ordhdrnumber AS VARCHAR(50)), 1, @user, getdate(), NULL, NULL)

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
						VALUES
							(@extra_id, @tab_id, @col_id_driver, @driver, CAST(@ordhdrnumber AS VARCHAR(50)), 1, @user, getdate(), NULL, NULL)

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
						VALUES
							(@extra_id, @tab_id, @col_id_trailer, @trailer, CAST(@ordhdrnumber AS VARCHAR(50)), 1, @user, getdate(), NULL, NULL)

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
						VALUES
							(@extra_id, @tab_id, @col_id_weight, CAST(@weight AS VARCHAR(50)), CAST(@ordhdrnumber AS VARCHAR(50)), 1, @user, getdate(), NULL, NULL)  

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
						VALUES
							(@extra_id, @tab_id, @col_id_tare_weight, CAST(@tareweight AS VARCHAR(50)), CAST(@ordhdrnumber AS VARCHAR(50)), 1, @user, getdate(), NULL, NULL)

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
						VALUES
							(@extra_id, @tab_id, @col_id_delivery_date, CONVERT(VARCHAR(50), @deliverydate, 101), CAST(@ordhdrnumber AS VARCHAR(50)), 1, @user, getdate(), NULL, NULL)

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
						VALUES
							(@extra_id, @tab_id, @col_id_processed_by, @user, CAST(@ordhdrnumber AS VARCHAR(50)), 1, @user, getdate(), NULL, NULL)

						INSERT INTO extra_info_data
							(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
						VALUES
							(@extra_id, @tab_id, @col_id_processed_date, CONVERT(VARCHAR(50), getdate(), 101) + ' ' + CONVERT(VARCHAR(50), getdate(), 108), CAST(@ordhdrnumber AS VARCHAR(50)), 1, @user, getdate(), NULL, NULL)
					END    -- If @@ERROR

			   		IF @@ERROR = 0
					BEGIN 
						INSERT INTO jws_audit
							(jwsa_deliverydate,
							 jwsa_master_order,
							 jwsa_ticketnumber,
							 ord_hdrnumber,
							 jwsa_tractor,
							 jwsa_driver,
							 jwsa_trailer,
							 jws_tareweight,
							 jws_weight,
							 jwsa_action,
							 jwsa_audit_user,
							 jwsa_audit_dttm)
							SELECT	@deliverydate,
							 		@masterordernumber,
							 		@ticketnumber,
									@ordhdrnumber,
									@tractor,
									@driver,
									@trailer,
									@tareweight,
									@weight,
									'Existing Order Updated',
									@user,
									getdate()

			   			DELETE FROM jws_import_order_weights
			   			WHERE iow_id = @id
					END   -- If @@ERROR
				END
				ELSE
				BEGIN  --1
					IF EXISTS(SELECT	*
								FROM	legheader lgh (NOLOCK)
											INNER JOIN orderheader oh ON oh.ord_hdrnumber = lgh.ord_hdrnumber
							   WHERE	lgh.lgh_driver1 = @driver AND
										lgh.lgh_tractor = @tractor AND
										lgh.lgh_primary_trailer <> @trailer AND
										lgh.lgh_startdate >= @lodate AND
										lgh.lgh_startdate <= @hidate AND
										--PTS nnnnn jjf 7/11/2006 - don't re-check if saving from order entry
										--oh.ord_fromorder = @masterordernumber)
										oh.ord_fromorder = @masterordernumber AND @app <> 'ORD')
										--END PTS nnnnn jjf 7/11/2006 - don't re-check if saving from order entry
					BEGIN --9
						SET @message = 'Invalid Trailer Possible' 

						INSERT INTO jws_audit
							(jwsa_deliverydate,
							 jwsa_master_order,
							 jwsa_ticketnumber,
							 ord_hdrnumber,
							 jwsa_tractor,
							 jwsa_driver,
							 jwsa_trailer,
							 jws_tareweight,
							 jws_weight,
							 jwsa_action,
							 jwsa_audit_user,
							 jwsa_audit_dttm)
						VALUES
							(@deliverydate,
							 @masterordernumber,
							 @ticketnumber,
							 NULL,
							 @tractor,
							 @driver,
							 @trailer,
							 @tareweight,
							 @weight,
							 'Error - ' + @message,
							 @user,
							 getdate())
				
						UPDATE	jws_import_order_weights
						   SET	iow_message = @message,
								iow_updateby = @user,
								iow_updatedate = getdate()
						 WHERE	iow_id = @id
					END --9
					ELSE
					BEGIN --8	
						--PTS 40559 JJF- add needed parms
						--PTS 44064 JSwindell - add new parm
						--PTS 56991 JJF 20110511 - correct parm
						INSERT INTO #neworder EXEC cloneorderwithoptions_aggregate 1, @masterordernumber, @user, 'N', @deliverydate, 0, 0, 0, 'N',
												'CMP', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'N', 'N', @driver, 'UNKNOWN', @tractor,
												@trailer, 'UNKNOWN', 'UNKNOWN', 7, 'UNKNOWN', 'N', '', 'N', 'N', 'Y', -1, 'Y', '', '', 'N','UNK', 'N','N'

						IF @@ERROR = 0
						BEGIN --2
							SELECT	@seq = ref_sequence
							  FROM	referencenumber
										INNER JOIN #neworder ON #neworder.ord_hdrnumber = ref_tablekey
							 WHERE	ref_table = 'orderheader' AND
									ref_type = 'TRANS'

							--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
							SELECT	@bol_seq = MIN(ref_sequence)
							  FROM	referencenumber
										INNER JOIN #neworder ON #neworder.ord_hdrnumber = ref_tablekey
							 WHERE	ref_table = 'orderheader' AND
									ref_type = 'BOL'
							--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	

							--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
							--IF ISNULL(@seq, -1) = -1 
							IF ISNULL(@seq, -1) = -1 AND ISNULL(@bol_seq, -1) = -1
							--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
							BEGIN --3
								UPDATE	referencenumber
								   SET	ref_sequence = ref_sequence + 1
								  FROM	#neworder
								 WHERE	#neworder.ord_hdrnumber = ref_tablekey AND
										ref_table = 'orderheader'
							END --3
							--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
							--ELSE 
							ELSE IF ISNULL(@seq, -1) > 0
							--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
							BEGIN --4
								DELETE	referencenumber
								  FROM	#neworder
								 WHERE	#neworder.ord_hdrnumber = ref_tablekey AND
										ref_table = 'orderheader' AND
										ref_sequence = @seq
		
								UPDATE	referencenumber
								   SET	ref_sequence = CASE WHEN ref_sequence < ISNULL(@seq, -1) THEN ref_sequence + 1 ELSE ref_sequence END
								  FROM	#neworder
								 WHERE	#neworder.ord_hdrnumber = ref_tablekey AND
										ref_table = 'orderheader'
							END --4
			
							-- update weights
							UPDATE	orderheader
							   SET	ord_grossweight = @weight,
									ord_tareweight = @tareweight,
									ord_totalweight = @weight - @tareweight,
									ord_totalweightunits = 'LBS',
									ord_refnum = CONVERT(VARCHAR(30), @ticketnumber),
									ord_reftype = 'BOL',
									ord_bookedby = 'JWS AUDIT',
									ord_order_source = 'JWS'
							  FROM	#neworder n
							 WHERE	orderheader.ord_number = n.ord_number
							
							IF @@ERROR = 0
							BEGIN --5
								--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
								IF ISNULL(@bol_seq, -1) = -1 BEGIN
								--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
									INSERT INTO referencenumber 
												(ref_tablekey,
												ref_type,
												ref_number,
												ref_sequence,
												ord_hdrnumber,
												ref_table)
									SELECT	n.ord_hdrnumber,
											'BOL',
											@ticketnumber,
											1,
											n.ord_hdrnumber,
											'orderheader'
									FROM	#neworder n
								--PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
								END
								ELSE BEGIN
									UPDATE	referencenumber
									   SET	ref_number = @ticketnumber
									  FROM	#neworder
									 WHERE	#neworder.ord_hdrnumber = ref_tablekey AND
										ref_table = 'orderheader' AND
										ref_sequence = @bol_seq
								END
							--END PTS 36606 - JJF 3/9/2007 - Handle the case where a BOL entry is already in place	
							END
								
							IF @@ERROR = 0
							BEGIN --6
								INSERT INTO extra_info_data
									(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
									SELECT	@extra_id, @tab_id, @col_id_ticket_number, CAST(@ticketnumber AS VARCHAR(50)), CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
									  FROM	#neworder
		
								INSERT INTO extra_info_data
									(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
									SELECT	@extra_id, @tab_id, @col_id_master_order, @masterordernumber, CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
									  FROM	#neworder
		
								INSERT INTO extra_info_data
									(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
									SELECT	@extra_id, @tab_id, @col_id_tractor, @tractor, CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
									  FROM	#neworder
		
								INSERT INTO extra_info_data
									(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
									SELECT	@extra_id, @tab_id, @col_id_driver, @driver, CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
									  FROM	#neworder
		
								INSERT INTO extra_info_data
									(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
									SELECT	@extra_id, @tab_id, @col_id_trailer, @trailer, CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
									  FROM	#neworder
		
								INSERT INTO extra_info_data
									(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
									SELECT	@extra_id, @tab_id, @col_id_weight, CAST(@weight AS VARCHAR(50)), CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
									  FROM	#neworder
		
								INSERT INTO extra_info_data
									(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
									SELECT	@extra_id, @tab_id, @col_id_tare_weight, CAST(@tareweight AS VARCHAR(50)), CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
									  FROM	#neworder
		
								INSERT INTO extra_info_data
									(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
									SELECT	@extra_id, @tab_id, @col_id_delivery_date, CONVERT(VARCHAR(50), @deliverydate, 101), CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
									  FROM	#neworder
		
								INSERT INTO extra_info_data
									(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
									SELECT	@extra_id, @tab_id, @col_id_processed_by, @user, CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
									  FROM	#neworder
		
								INSERT INTO extra_info_data
									(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, last_updateby, last_updatedate, col_datetime, col_number)
									SELECT	@extra_id, @tab_id, @col_id_processed_date, CONVERT(VARCHAR(50), getdate(), 101) + ' ' + CONVERT(VARCHAR(50), getdate(), 108), CAST(ord_hdrnumber AS VARCHAR(50)), 1, @user, getdate(),	NULL, NULL  
									  FROM	#neworder
							END --6

				   			IF @@ERROR = 0
				   			BEGIN --7
								INSERT INTO jws_audit
									(jwsa_deliverydate,
									 jwsa_master_order,
									 jwsa_ticketnumber,
									 ord_hdrnumber,
									 jwsa_tractor,
									 jwsa_driver,
									 jwsa_trailer,
									 jws_tareweight,
									 jws_weight,
									 jwsa_action,
									 jwsa_audit_user,
									 jwsa_audit_dttm)
									SELECT	@deliverydate,
								 			@masterordernumber,
								 			@ticketnumber,
											ord_hdrnumber,
											@tractor,
											@driver,
											@trailer,
											@tareweight,
											@weight,
											'New Order Created',
											@user,
											getdate()
									  FROM	#neworder
		
					   				DELETE FROM jws_import_order_weights
					   				WHERE iow_id = @id
							END  --7 
						END -- 2
					END --8
		    	END --1
			END
		END
	END
	ELSE
	BEGIN
		IF @message <> 'SKIP'
		BEGIN
			IF @message = 'DELETE'
			BEGIN
				INSERT INTO jws_audit
					(jwsa_deliverydate,
					 jwsa_master_order,
					 jwsa_ticketnumber,
					 ord_hdrnumber,
					 jwsa_tractor,
					 jwsa_driver,
					 jwsa_trailer,
					 jws_tareweight,
					 jws_weight,
					 jwsa_action,
					 jwsa_audit_user,
					 jwsa_audit_dttm)
					SELECT	@deliverydate,
				 			@masterordernumber,
				 			@ticketnumber,
							0,
							@tractor,
							@driver,
							@trailer,
							@tareweight,
							@weight,
							'JWS record deleted at users request.',
							@user,
							getdate()

	   				DELETE FROM jws_import_order_weights
	   				WHERE iow_id = @id
			END
			ELSE
			BEGIN
				INSERT INTO jws_audit
					(jwsa_deliverydate,
					 jwsa_master_order,
					 jwsa_ticketnumber,
					 ord_hdrnumber,
					 jwsa_tractor,
					 jwsa_driver,
					 jwsa_trailer,
					 jws_tareweight,
					 jws_weight,
					 jwsa_action,
					 jwsa_audit_user,
					 jwsa_audit_dttm)
				VALUES
					(@deliverydate,
					 @masterordernumber,
					 @ticketnumber,
					 NULL,
					 @tractor,
					 @driver,
					 @trailer,
					 @tareweight,
					 @weight,
					 'Error - ' + @message,
					 @user,
					 getdate())
		
				UPDATE	jws_import_order_weights
				   SET	iow_message = @message,
						iow_updateby = @user,
						iow_updatedate = getdate()
				 WHERE	iow_id = @id
			END
		END
	END
	
	SELECT	@id = MIN(iow_id)
	FROM	inserted
	WHERE	iow_id > @id
END


GO
ALTER TABLE [dbo].[jws_import_order_weights] ADD CONSTRAINT [pk_jws_import_order_weights] PRIMARY KEY CLUSTERED ([iow_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[jws_import_order_weights] TO [public]
GO
GRANT INSERT ON  [dbo].[jws_import_order_weights] TO [public]
GO
GRANT REFERENCES ON  [dbo].[jws_import_order_weights] TO [public]
GO
GRANT SELECT ON  [dbo].[jws_import_order_weights] TO [public]
GO
GRANT UPDATE ON  [dbo].[jws_import_order_weights] TO [public]
GO
