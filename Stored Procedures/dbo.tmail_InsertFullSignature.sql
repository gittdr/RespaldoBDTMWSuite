SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tmail_InsertFullSignature]
	@Vendor varchar(6), --"PNET" or "D2link" currently
	@ReceiveDate varchar (30),
	@MSGSN int,
	@ImageAsText varchar(max) = '',
	@ImageAsData varbinary(max) = 0,
	@StopNumber int = 0,
	@SignatureID varchar(20) = '',
	@SignatureName varchar (100) = ''
	
/*
NAME:
dbo.tmail_InsertFullSignature

TYPE:
Stored Procedure

DESCRIPTION:
inserts records into tblSignatureCaptureData and tblSignatureCaptureimage

Prams:
@Vendor: "PNET" or "D2link", vendor signature originates from 
@ReceiveDate
@MSGSN tblmessages.SN of original msg.  
@ImageAsText Image to fill as Text.  If missing will use @ImageAsData
@ImageAsData Image to fill as Text.  If missing will use @ImageAsText
@StopNumber 
@SignatureID: vendor signature id
@SignatureName: Text name of Signature

Change Log: 
rwolfe	2015/12/04	init 

*/
AS
	IF ISDATE(@ReceiveDate) = 0
	BEGIN
		RAISERROR ('Invalid Receive Date', 16, 1, @ReceiveDate)
		RETURN
	END

	IF isnull(@vendor,'') = ''
	BEGIN
		RAISERROR ('Invalid Vendor', 16, 1, @vendor)
		RETURN
	END

	IF (Not isnull(@ImageAsText,'') = '') AND (Not isnull(@ImageAsData, 0) = 0)
	BEGIN
		RAISERROR ('Invalid Image', 16, 1, @vendor)
		RETURN
	END

	declare @sn int, @image varbinary(max) = null

	if (Not isnull(@ImageAsText,'') = '')
		set @image = cast(@ImageAsText as varbinary(max))
	Else if (Not isnull(@ImageAsData, 0) = 0)
		set @image = @ImageAsData


	INSERT INTO tblSignatureCaptureData (
		[stp_number] ,
		[msg_SN] ,
		[signatureid] ,
		[signaturename] ,
		[receiveddate] ,
		[vendor]) 
	VALUES(
		@StopNumber,
		@MSGSN,
		@SignatureID,
		@SignatureName,
		@ReceiveDate,
		@Vendor)

if NOT (@Vendor = 'PNET' AND (@image = '' or @image = 0) )
BEGIN
	set @sn = scope_identity()

	INSERT INTO tblSignatureCaptureImage (SCD_SN, signatureimage)
	values (@sn, @image)
END
GO
GRANT EXECUTE ON  [dbo].[tmail_InsertFullSignature] TO [public]
GO
