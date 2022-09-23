SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tmail_InsertSignatureCapture_Data]
	@StopNumber varchar(20),
	@MSGSN varchar(20),
	@SignatureID varchar(20),
	@SignatureName varchar (100),
	@ReceiveDate varchar (30),
	@Vendor varchar(6) = 'PNET' --used to only be used by PNET, now D2link support exists

AS

	DECLARE @iStopNumber BIGINT
	DECLARE @iMSGSN BIGINT
	DECLARE @iSignatureID BIGINT
	DECLARE @dReceiveDate DATETIME

	IF ISNUMERIC(@StopNumber) = 0
	BEGIN
		RAISERROR ('Invalid Stop Number', 16, 1, @StopNumber)
		RETURN
	END
	ELSE
	BEGIN
		SET @iStopNumber = CONVERT(BIGINT,@StopNumber)
	END


	IF NOT EXISTS (SELECT NULL FROM stops (NOLOCK) WHERE stp_number = @iStopNumber)
	BEGIN
		RAISERROR ('Invalid Stop Number', 16, 1, @StopNumber)
		RETURN
	END
	
	IF ISNUMERIC(@MSGSN) = 0
	BEGIN
		RAISERROR ('Invalid Message SN', 16, 1, @MSGSN)
		RETURN
	END
	ELSE
	BEGIN
		SET @iMSGSN = CONVERT(BIGINT,@MSGSN)
	END
	
	IF ISNUMERIC(@SignatureID) = 0
	BEGIN
		IF(ISNULL(@SignatureName,'') = '')
		BEGIN
			RAISERROR ('Invalid Signature ID', 16, 1, @SignatureID)
			RETURN
		END
		ELSE	
			SET @iSignatureID = 0 
	END
	ELSE
	BEGIN
		SET @iSignatureID = CONVERT(BIGINT,@SignatureID)
		IF(EXISTS (SELECT SN FROM tblSignatureCaptureData WHERE signatureid = @iSignatureID))
		BEGIN
			RAISERROR ('Record for this Image ID Already Exists', 16, 1, @iSignatureID)
			RETURN
		END
	END
	
	IF ISDATE(@ReceiveDate) = 0
	BEGIN
		RAISERROR ('Invalid Receive Date', 16, 1, @ReceiveDate)
		RETURN
	END
	ELSE
	BEGIN
		SET @dReceiveDate = CONVERT(DATETIME,@ReceiveDate)
	END  
	


	INSERT INTO
	tblSignatureCaptureData (
		[stp_number] ,
		[msg_SN] ,
		[signatureid] ,
		[signaturename] ,
		[receiveddate] ,
		[vendor])
	VALUES(
		@iStopNumber,
		@iMSGSN,
		@iSignatureID,
		@SignatureName,
		@dReceiveDate,
		@Vendor
	)

GO
GRANT EXECUTE ON  [dbo].[tmail_InsertSignatureCapture_Data] TO [public]
GO
