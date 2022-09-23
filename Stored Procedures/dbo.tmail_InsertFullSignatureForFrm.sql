SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tmail_InsertFullSignatureForFrm]
	@Vendor varchar(6), --"PNET" or "D2link" currently
	@ReceiveDate varchar (30),
	@MSGSN varchar(22),
	@ImageAsText varchar(max),
	@ImageAsData varchar(max),
	@StopNumber varchar(22),
	@SignatureID varchar(20),
	@SignatureName varchar (100)
	
/*
NAME:
dbo.tmail_InsertFullSignatureForFrm

TYPE:
Stored Procedure

DESCRIPTION:
Wrapper for use by forms for tmail_InsertFullSignature

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
rwolfe	2016/03/03	init 

*/
AS
Declare @rMSGSN as INT, @rImageAsData as varbinary(max), @rStopNumber as INT

set @ReceiveDate = isnull(@ReceiveDate, '')
set @MSGSN = isnull(@MSGSN, '')
if @MSGSN = ''
Begin
  set @MSGSN = '0'
end
set @ImageAsText = isnull(@ImageAsText, '')
set @ImageAsData = isnull(@ImageAsData, '')
if @ImageAsData = ''
Begin
  set @rImageAsData = 0
end
Else
Begin
  set @rImageAsData = Cast(@ImageAsData AS varbinary(max))
End
set @StopNumber = isnull(@StopNumber, '')
if @StopNumber = ''
BEGIN
  set @StopNumber = '0'
END
set @SignatureID = isnull(@SignatureID, '')
set @SignatureName = isnull(@SignatureName, '')

set @rMSGSN = CAST(@MSGSN As INT)

set @rStopNumber = CAST(@StopNumber As INT)

Exec tmail_InsertFullSignature @Vendor, @ReceiveDate, @rMSGSN, @ImageAsText, @rImageAsData, @rStopNumber, @SignatureID, @SignatureName

SELECT 'IgnoreNoResults' --View errors looking for results otherwise

GO
GRANT EXECUTE ON  [dbo].[tmail_InsertFullSignatureForFrm] TO [public]
GO
