SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_EDI_OrderState_Update]
	@p_OrderHeaderNumber INT,
	@p_NextCode TINYINT,
	@p_OrderStatus as VARCHAR(3)
AS

DECLARE @now DATETIME
SET @now = getdate()
	
DECLARE @v_NextCodeCount INT, @v_OrdNumber VARCHAR(12), @v_OrdPurpose VARCHAR(1), @v_RetCode int
DECLARE @CurrentEDICode TINYINT
DECLARE @trp_id varchar(30), @ord_invoicestatus varchar(6),
		@NewBookedBy varchar(20),
		@NewBookDate datetime


SELECT @v_OrdNumber = ord_number, @v_OrdPurpose = ord_edipurpose, @CurrentEDICode = ord_edistate, @trp_id = ord_editradingpartner,
		@ord_invoicestatus = ord_invoicestatus, @NewBookedBy = ord_bookedby, @NewBookDate = ord_bookdate 
  FROM orderheader
 WHERE ord_hdrnumber = @p_OrderHeaderNumber
 
IF (SELECT UPPER(LEFT(gi_string1, 1)) FROM generalinfo WHERE gi_name = 'EDIBookedByAccept') = 'Y'
	Begin
		exec gettmwuser @NewBookedBy output
		set @NewBookDate = @now
	end
IF ISNULL(@v_OrdNumber,'') = '' RETURN 0

-- PTS 68653 DMA 06/10/2013
declare @AllowReject990AfterAccept int
exec @AllowReject990AfterAccept = dx_GetLTSL2TradingPartnerSetting 'AllowReject990AfterAccept', @trp_id

IF @p_NextCode = 20 AND @CurrentEDICode IN (20,21,30,31) RETURN 0
IF @p_NextCode = 30 AND @CurrentEDICode IN (20,21,30,31) AND @AllowReject990AfterAccept = 0 RETURN 0
if @p_NextCode = 30 AND @CurrentEDICode IN (30,31) AND @AllowReject990AfterAccept = 1 RETURN 0

-- End PTS 68653

DECLARE @p_HostName VARCHAR(10), @p_Command as VARCHAR(40),
	@p_dx_ordernumber varchar(30)		

SELECT @p_HostName = LEFT(HOST_NAME(), 10), @p_Command = 'Set to ' + esc_description FROM dbo.edi_orderstate WHERE esc_code = @p_NextCode		

SELECT @p_dx_ordernumber = MAX(dx_ordernumber) FROM dx_History WHERE dx_orderhdrnumber = @p_OrderHeaderNumber

--EXEC dx_History_Update 'EDI_OrderState_Update', @p_Command, null, 1, @p_dx_ordernumber
EXEC dx_History_Update @p_HostName, 'DX EDI DECISION', @p_Command, 1, @p_dx_ordernumber

IF @v_OrdPurpose = 'C'
BEGIN
	SELECT @v_RetCode = 0
	IF @p_OrderStatus = 'AVL'
		EXEC @v_RetCode = dx_cancel_order_number @v_OrdNumber, 'N'
	UPDATE orderheader
	   --SET ord_edistate = case @p_OrderStatus when 'AVL' then '20' else '30' end, ord_ediuseraction = null
	   --FMM 12/19/2007: never mark a declined cancellation with an EDI state of '30', that prevents updating
	   SET ord_edistate = case @p_OrderStatus when 'AVL' then 36 else 38 end, ord_ediuseraction = null,
			ord_bookedby = @NewBookedBy,
			ord_bookdate = @NewBookDate
	 WHERE ord_hdrnumber = @p_OrderHeaderNumber
END
ELSE
BEGIN
	DECLARE @mov_number VARCHAR(50),
		@ord_status VARCHAR(6),
		@old_status_code INT,
		@new_status_code INT,
		@pending_code INT,
		@stp_number INT,
		@inv_status varchar(6),
		@inv_when varchar(6),
		@run_update_move BIT,
		@DoNotInvoice varchar(100),
		@retcode int

	SELECT	@stp_number = 0, @run_update_move = 1
	
	SELECT  @mov_number=mov_number, @ord_status=ord_status  FROM  orderheader  WHERE     ord_hdrnumber = @p_OrderHeaderNumber

	SELECT  @old_status_code = code FROM labelfile WHERE labeldefinition = 'DispStatus' and abbr = @ord_status

	SELECT	@new_status_code = code FROM labelfile WHERE labeldefinition = 'DispStatus' and abbr = @p_OrderStatus

	IF (SELECT UPPER(LEFT(gi_string1, 1)) FROM generalinfo WHERE gi_name = 'DisplayPendingOrders') = 'Y'
		SELECT	@pending_code = code FROM labelfile WHERE labeldefinition = 'DispStatus' and abbr = 'PND'
	ELSE
		SELECT	@pending_code = code FROM labelfile WHERE labeldefinition = 'DispStatus' and abbr = 'AVL'

	
	DECLARE	@stops TABLE (StopNum INT)
	INSERT INTO @stops (StopNum)
	SELECT stp_number FROM stops WHERE mov_number = @mov_number
	select @inv_when = ''
	SELECT  @inv_when = ISNULL(gi_string1,'') FROM generalinfo WHERE gi_name = 'LTSL_Invoice_When'
	 
	select @DoNotInvoice = '0'
	
	SELECT @DoNotInvoice = isNull(dx_xrefkey,'0')
	FROM   dx_xref
	WHERE dx_entityname = 'DoNotInvoice'
 	and dx_entitytype = 'TPSettings'
 	and dx_importid = 'dx_204'
	and dx_trpid = @trp_id

	if @ord_status = 'CAN' and @inv_when <> ('XIN') and @DoNotInvoice <> '1'
		set @ord_invoicestatus = 'PND'
 
 		--first update stops and event table
		IF @old_status_code < @pending_code and @new_status_code >= @pending_code
		BEGIN
			WHILE 1=1
			BEGIN
				SELECT @stp_number = MIN(StopNum) FROM @stops WHERE StopNum > @stp_number
				If @stp_number IS NULL BREAK
				UPDATE stops
				   SET stp_status = 'OPN', stp_departure_status = 'OPN'
				 WHERE stp_number = @stp_number and (stp_status <> 'OPN' or stp_departure_status <> 'OPN')
				UPDATE event
				   SET evt_departure_status = 'OPN'
				 WHERE stp_number = @stp_number AND evt_sequence = 1 and evt_departure_status <> 'OPN'
			END
		END
		ELSE
		BEGIN
			IF @old_status_code >= @pending_code and @new_status_code < @pending_code
				IF NOT @ord_status IN ('STD','CMP')
					WHILE 1=1
					BEGIN
						SELECT @stp_number = MIN(StopNum) FROM @stops WHERE StopNum > @stp_number
						IF @stp_number IS NULL BREAK
						UPDATE stops
						   SET stp_status = 'NON', stp_departure_status = 'NON'
						 WHERE stp_number = @stp_number and (stp_status <> 'NON' or stp_departure_status <> 'NON')
						UPDATE event
						   SET evt_departure_status = 'NON'
						 WHERE stp_number = @stp_number AND evt_sequence = 1 and evt_departure_status <> 'NON'
					END
			ELSE
				IF @ord_status = 'AVL'
					WHILE 1=1
						BEGIN
							SELECT @stp_number = MIN(StopNum) FROM @stops WHERE StopNum > @stp_number 
							If @stp_number IS NULL BREAK
							UPDATE stops
								SET stp_status = 'OPN', stp_departure_status = 'OPN'
								WHERE stp_number = @stp_number and stp_status = 'NON'
							UPDATE event
								SET evt_departure_status = 'OPN'
								WHERE stp_number = @stp_number AND evt_sequence = 1 and evt_departure_status = 'NON'
						END
		END

		--now update orderheader and legheader
		IF @old_status_code < @pending_code and @new_status_code >= @pending_code
		BEGIN
			UPDATE orderheader
			   SET ord_status = @p_OrderStatus, ord_edistate = @p_NextCode, ord_ediuseraction = NULL
				 , ord_invoicestatus = @ord_invoicestatus,
				 ord_bookedby = @NewBookedBy,
				 ord_bookdate = @NewBookDate
			 WHERE ord_hdrnumber = @p_OrderHeaderNumber and (ord_status <> @p_OrderStatus or ord_edistate <> @p_NextCode or ord_ediuseraction is not NULL
				 or ord_invoicestatus <> @ord_invoicestatus or ord_bookedby <> @NewBookedBy or ord_bookdate <> @NewBookDate)
			UPDATE legheader
			   SET lgh_outstatus = @p_OrderStatus
			 WHERE ord_hdrnumber = @p_OrderHeaderNumber and (lgh_outstatus <> @p_OrderStatus)
		END
		ELSE
		BEGIN
			IF @old_status_code >= @pending_code and @new_status_code < @pending_code
			BEGIN
				IF @ord_status IN ('STD','CMP')
				BEGIN
					SELECT @p_NextCode = 39, @run_update_move = 0
					UPDATE orderheader
					   SET ord_edistate = @p_NextCode, ord_ediuseraction = NULL,
							 ord_bookedby = @NewBookedBy,
							 ord_bookdate = @NewBookDate
					 WHERE ord_hdrnumber = @p_OrderHeaderNumber and (ord_edistate <> @p_NextCode or ord_ediuseraction is not NULL or
							 ord_bookedby <> @NewBookedBy or ord_bookdate <> @NewBookDate)
				END
				ELSE
				BEGIN
					UPDATE orderheader
					   SET ord_status = @p_OrderStatus, ord_edistate = @p_NextCode, ord_ediuseraction = NULL,
						 ord_bookedby = @NewBookedBy,
						 ord_bookdate = @NewBookDate
					 WHERE ord_hdrnumber = @p_OrderHeaderNumber  and (ord_status <> @p_OrderStatus or ord_edistate <> @p_NextCode 
													or ord_ediuseraction is not NULL or ord_bookedby <> @NewBookedBy or ord_bookdate <> @NewBookDate)
					UPDATE legheader
					   SET lgh_outstatus = @p_OrderStatus, lgh_carrier = 'UNKNOWN'
					 WHERE ord_hdrnumber = @p_OrderHeaderNumber and (lgh_outstatus <> @p_OrderStatus or lgh_carrier <> 'UNKNOWN')
				END
			END
			ELSE
			BEGIN
				IF @ord_status IN ('PLN','DSP') AND @p_OrderStatus = 'AVL' AND @p_NextCode = 20
				BEGIN
					SELECT @run_update_move = 0
					UPDATE orderheader
					   SET ord_edistate = @p_NextCode, ord_ediuseraction = NULL,
						 ord_bookedby = @NewBookedBy,
						 ord_bookdate = @NewBookDate
					 WHERE ord_hdrnumber = @p_OrderHeaderNumber and (ord_edistate <> @p_NextCode or ord_ediuseraction is not NULL or
						 ord_bookedby <> @NewBookedBy or ord_bookdate <> @NewBookDate)
				END
				ELSE
				BEGIN
					IF @ord_status IN ('PND','AVL','PLN','DSP')
					BEGIN
						UPDATE orderheader
						   SET ord_status = @p_OrderStatus, ord_edistate = @p_NextCode, ord_ediuseraction = NULL,
							 ord_bookedby = @NewBookedBy,
							 ord_bookdate = @NewBookDate
						 WHERE ord_hdrnumber = @p_OrderHeaderNumber and (ord_status <> @p_OrderStatus or ord_edistate <> @p_NextCode or ord_ediuseraction is not NULL
																		or ord_bookedby <> @NewBookedBy or ord_bookdate <> @NewBookDate)
						UPDATE legheader
						   SET lgh_outstatus = @p_OrderStatus
						 WHERE ord_hdrnumber = @p_OrderHeaderNumber and (lgh_outstatus <> @p_OrderStatus)
					END
					ELSE
					BEGIN
						SELECT @run_update_move = 0
						UPDATE orderheader
						   SET ord_edistate = @p_NextCode, ord_ediuseraction = NULL
						 WHERE ord_hdrnumber = @p_OrderHeaderNumber and (ord_edistate <> @p_NextCode or ord_ediuseraction is not NULL)
					END
				END
			END
		END

	IF (SELECT COUNT(1) FROM dx_lookup
		WHERE dx_importid = 'dx_204' and dx_lookuptable = 'LtslSettings' 
		and dx_lookuprawdatavalue = 'EnableOrderHolds' and dx_lookuptranslatedvalue = '1') = 1     
			 BEGIN
		     EXEC @retcode = dx_enableorderholds @p_OrderHeaderNumber
		     IF @retcode = 0 AND @run_update_move = 1
		        BEGIN
					IF RTRIM(ISNULL(@inv_when,'')) = '' SELECT @inv_when = 'CMP'
					EXEC update_ord @mov_number, @inv_when
					EXEC update_move_light @mov_number
				END
			END
	ELSE
		IF @run_update_move = 1
		BEGIN
			IF RTRIM(ISNULL(@inv_when,'')) = '' SELECT @inv_when = 'CMP'
	
			EXEC update_ord @mov_number, @inv_when
			EXEC update_move_light @mov_number
		END
	
	IF @p_NextCode <> '41'
		UPDATE dx_archive_header 
		SET dx_accepted = 1 
		WHERE dx_orderhdrnumber = @p_OrderHeaderNumber
		AND IsNull(dx_accepted,0) <> 1 
		AND dx_importid = 'dx_204'


	IF @p_NextCode NOT IN (12,22,32,39)
		EXEC dx_EDICreateUpdate204 @p_OrderHeaderNumber

RETURN 1
END



GO
GRANT EXECUTE ON  [dbo].[dx_EDI_OrderState_Update] TO [public]
GO
