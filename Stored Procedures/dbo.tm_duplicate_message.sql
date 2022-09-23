SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_duplicate_message]	@CopyFromSN int,
						@SaveTos tinyint,
						@NewSN int OUT,
						@flags int = 0
AS
/* 05/12/99 MZ: Created for faster message duplication. */
-- 09/13/00 MZ: Added support for Position, NLCPosition, Ignition etc
-- 11/15/06 TD: Added BaseSN awareness, flags parameter and first 2 flags.  Defined flags are:
--					+1: Set copy status to Unsent
--					+2: Set copy status to Processing (ignored if +1 is also present).
--					+4: No Resultset.
--				
--				BaseSN marks the original as the BaseSN for the chain.  It is intended to allow status information to ripple back to
--					the original from Delivered copies of the message and triggered messages it caused.  Once Created, the BaseSN will
--					automatically be propogated into all copies.  It will also be propogated into Triggered messages created by
--					transaction.  Also, the Base copy of a message will always have a separate Error list id from all of its duplicates
--					so that the errors for the kids do not cross over.
--				Set copy status to Unsent forces the copy back to unsent status.  This is primarily meant for when the BaseSN is being
--					copied in a Login Outbox since that message could theoretically be updated to Sent status by earlier messages.
--				Set copy status to Processing forces the copy back to processing status.  This is primarily meant for when the BaseSN is
--					being copied by transaction's redirect message, since the message could theoretically be updated to Sent status by
--					earlier messages.
--				If either "set copy status" option is active and if there are any Delivery Errors on the original message (identified by the
--					tblErrorData.Source starting with "clsDelivery"), then a new error list will also be generated for the copy without
--					those errors.
SET NOCOUNT ON

DECLARE @OrigMsgSN int
DECLARE @BaseSN int
DECLARE @SetCopyToUnsent int
DECLARE @SetCopyToProcessingOrUnsent int
DECLARE @NewStatus int
DECLARE @NewErrListID int
DECLARE @OldErrListID int

SELECT @NewStatus=NULL

IF (@Flags & 2) = 2
	SELECT @SetCopyToProcessingOrUnsent = 1, @NewStatus = 2
ELSE
	SELECT @SetCopyToProcessingOrUnsent = 0

IF (@Flags & 1) = 1
	SELECT @SetCopyToUnsent = 1, @NewStatus = 1, @SetCopyToProcessingOrUnsent = 1
ELSE
	SELECT @SetCopyToUnsent = 0

-- If OrigMsgSN is null in the CopyFromSN message, then set the OrigMsgSN to its SN
SELECT @OrigMsgSN = OrigMsgSN, @BaseSN = BaseSN
FROM tblMessages (NOLOCK)
WHERE SN = @CopyFromSN
	
IF ISNULL(@OrigMsgSN, 0) = 0
	BEGIN
	UPDATE tblMessages 
	SET OrigMsgSN = @CopyFromSN 
    WHERE SN = @CopyFromSN
		
	SELECT @OrigMsgSN = @CopyFromSN
	END

-- Make copy of the message
INSERT INTO tblMessages (Type,
			 Status,
			 Priority,
			 FromName,
			 FromType,		--5

			 DTSent,
			 DTReceived,
			 DTRead,
			 DTAcknowledged,
			 DTTransferred,		--10

			 Folder,
			 Subject,
			 Contents,
			 DeliverTo,
			 DeliverToType,		--15

			 OrigMsgSN,
			 Receipt,
			 Position,
			 PositionZip,
			 NLCPosition,		--20

			 NLCPositionZip,
			 VehicleIgnition,
			 Latitude,
			 Longitude,
			 DTPosition, 		--25
			 
			 SpecialMsgSN,
			 ReplyFormID,
			 ReplyPriority,
			 ReplyMsgSN,
			 ReplyMsgPage,		--30
			 
			 BaseSN,
			 Odometer,
			 ToDrvSN,
			 ToTrcSN,
			 MaxDelayMins,		--35

			 FromDrvSN,
			 FromTrcSN,
			 ResubmitOf,
			 HistTrk,
			 HistDrv,		--40

			 HistDrv2,
			 DeliveryKey
			 )

SELECT  Type,
	ISNULL(@NewStatus, Status),
	Priority,
	FromName,
	FromType,		--5

	DTSent,
	CASE WHEN @SetCopyToProcessingOrUnsent = 1 THEN NULL ELSE DTReceived END,
	CASE WHEN @SetCopyToProcessingOrUnsent = 1 THEN NULL ELSE DTRead END,
	CASE WHEN @SetCopyToProcessingOrUnsent = 1 THEN NULL ELSE DTAcknowledged END,
	CASE WHEN @SetCopyToUnsent = 1 THEN NULL ELSE DTTransferred END,		--10

	Folder,
	Subject,
	Contents,
	DeliverTo,
	DeliverToType,		--15

	@OrigMsgSN,
	Receipt,
	Position,
	PositionZip,
	NLCPosition,		--20

	NLCPositionZip,
	VehicleIgnition,
	Latitude,
	Longitude,
	DTPosition,		--25
	
	SpecialMsgSN,
	ReplyFormID,
	ReplyPriority,
	ReplyMsgSN,
	ReplyMsgPage,		--30
	
	@BaseSN,
	Odometer,
	ToDrvSN,
	ToTrcSN,
	MaxDelayMins,		--35

	FromDrvSN,
	FromTrcSN,
	ResubmitOf,
	HistTrk,
	HistDrv,		--40

	HistDrv2,
	DeliveryKey
FROM tblMessages (NOLOCK)
WHERE SN = @CopyFromSN

SELECT @NewSN = @@IDENTITY	-- Get the SN of the new record

IF @SetCopyToProcessingOrUnsent = 0 AND @CopyFromSN <> isnull(@BaseSN, 0)
	-- Just copy all properties.
	INSERT INTO tblMsgProperties (MsgSN, PropSN, Value)
	SELECT @NewSN, PropSN, Value 
	FROM tblMsgProperties (NOLOCK)
	WHERE MsgSN = @CopyFromSN
ELSE
	BEGIN
	-- We may need to do something with any error list, so check for one.
	SELECT @OldErrListID = convert(int, tblmsgproperties.value) 
	from tblMsgProperties (NOLOCK)
	where msgsn = @CopyFromSN and propsn = 6
	
	IF ISNULL(@OldErrListID, 0) <> 0
		BEGIN
		-- There is an error list, initialize to say no actual change.
		SELECT @NewErrListID = @OldErrListID 
		
		-- Do we need to clear delivery errors?
		IF @SetCopyToProcessingOrUnsent = 1
			BEGIN
			-- We need to clear delivery errors.  So check for any.
			IF EXISTS (select * 
						from tblerrordata (NOLOCK)
						where tblErrorData.ErrListId = @OldErrListID AND tblerrordata.Source like 'clsDelivery%')
				BEGIN
				-- At least one Delivery error present, any Errors that DO need to be kept?
				IF EXISTS (SELECT * 
							FROM tblErrorData (NOLOCK)
							WHERE ErrListID = @OldErrListID AND NOT (Source Like 'clsDelivery%'))
					BEGIN
					-- There is also error info other than the delivery error.  Will need a whole new error list.
					EXEC tm_GetRSIdentity 'NxtErrLst', 1, 0, @NewErrListID out		-- Get a new error list id.
					INSERT INTO tblErrorData (VBError, Description, Source, Timestamp, ErrListID)	-- Copy the non Delivery Error Info
						SELECT VBError, Description, Source, Timestamp, @NewErrListID
						FROM tblErrorData (NOLOCK)
						WHERE ErrListID = @OldErrListID AND NOT (Source Like 'clsDelivery%')
					END
				ELSE 
					-- No non-delivery errors, so new list will be empty, so just say no error info at all.
					SET @NewErrListID = 0
				END
			-- ELSE -- Do Nothing.  No delivery errors, so can still let copy point at original error list.
			END
		
		IF @NewErrListID = @OldErrListID AND @CopyFromSN = isnull(@BaseSN, 0)
			BEGIN
			-- BaseSN must always have its own private Error List, so if we still haven't had to alter the list, then copy it for the child.
			EXEC tm_GetRSIdentity 'NxtErrLst', 1, 0, @NewErrListID out		-- Get a new error list id.
			INSERT INTO tblErrorData (VBError, Description, Source, Timestamp, ErrListID)	-- Copy the non Delivery Error Info
				SELECT VBError, Description, Source, Timestamp, @NewErrListID
				FROM tblErrorData (NOLOCK)
				WHERE ErrListID = @OldErrListID
			END
		
		IF ISNULL(@NewErrListID, 0) <> 0
			-- Child does still have an error list, so point to it.
			INSERT INTO tblMsgProperties (MsgSN, PropSN, Value) VALUES (@NewSN, 6, CONVERT(VARCHAR(20), @NewErrListID))
		END
	-- ELSE -- Do Nothing!  No error list means no special error list processing!
		
	-- Now copy all non-Error list properties for this message
	INSERT INTO tblMsgProperties (MsgSN, PropSN, Value)
	SELECT @NewSN, PropSN, Value 
	FROM tblMsgProperties (NOLOCK)
	WHERE MsgSN = @CopyFromSN AND PropSN <> 6
	END

-- Copy all To's into tblTo if SaveTos = 1
IF (@SaveTos = 1)
  INSERT INTO tblTo (Message, ToName, ToType, DTTransferred, IsCC)
  SELECT @NewSN, ToName, ToType, DTTransferred, IsCC 
  FROM tblTo (NOLOCK)
  WHERE Message = @CopyFromSN

-- Copy all Attachments for this message (actually only copies the reference).
IF (@Flags & 4) = 0
	SELECT @NewSN
INSERT INTO tblAttachments (Message, InsertionPt, DataSN, InLine, Path)
	SELECT @NewSN, InsertionPt, DataSN, InLine, Path 
	FROM tblAttachments (NOLOCK)
	WHERE Message = @CopyFromSN

GO
GRANT EXECUTE ON  [dbo].[tm_duplicate_message] TO [public]
GO
