SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Update_Msg_Status] @StatusCode varchar(5), @DateToUse varchar(30),  @TMExtID varchar(128)

AS
SET NOCOUNT ON 

DECLARE @StatusSN int
DECLARE @lMsgSN int
DECLARE @lOrigMsgSN int
DECLARE @lCommInbox int
DECLARE @lHistoryFolder int
DECLARE @dteDateToUse datetime

SELECT @lCommInbox = Inbox 
FROM tblServer (NOLOCK) 
WHERE ServerCode = 'C'

SELECT @lHistoryFolder = CONVERT(int, Text) 
FROM tblRS (NOLOCK) 
WHERE KeyCode = 'HISTORY'

SELECT @dteDateToUse = CONVERT(datetime, @DateToUse)

if ISNULL(@TMExtID, '') = ''
	BEGIN
	RAISERROR ('TotalMail Message External ID not passed in.', 16, 1)
	RETURN
	END
if ISNULL(@StatusCode, '') = ''
	BEGIN
	RAISERROR ('TotalMail status code not passed in.', 16, 1)
	RETURN
	END

--Get the Message SN for the external ID passed in
SELECT @lMsgSN = TMailObjSN 
FROM tblExternalIDs (NOLOCK) 
WHERE ExternalID = @TMExtID AND TmailObjType = 'MSG'
if ISNULL(@lMsgSN, 0) = 0
	BEGIN
	RAISERROR ('TotalMail Message not found for external id %s.', 16, 1, @TMExtID)
	RETURN
	END

SELECT @lOrigMsgSN = ISNULL(OrigMsgSN, 0) 
FROM tblMessages (NOLOCK) 
WHERE SN = @lMsgSN

--Legal Statuses:
--NEW
--PROC (Transmitted)
--CONFX
--ACK
--READ
--FAIL
--RSENT

SELECT @StatusSN = SN 
FROM tblMsgStatus (NOLOCK) 
WHERE Code = @StatusCode

if ISNULL(@StatusSN, 0) = 0
	BEGIN
	RAISERROR ('TotalMail status ''%s'' not found', 16, 1, @StatusCode)
	RETURN
	END

if @StatusCode = 'READ' 
	if @lOrigMsgSN > 0 
		UPDATE tblMessages SET Status = @StatusSN, DTRead = @dteDateToUse WHERE SN = @lMsgSN OR 
			(OrigMsgSN = @lOrigMsgSN AND Folder <> @lCommInbox AND Folder <> @lHistoryFolder)
	else
		UPDATE tblMessages SET Status = @StatusSN, DTRead = @dteDateToUse WHERE SN = @lMsgSN

else if @StatusCode = 'ACK' 
	if @lOrigMsgSN > 0 
		UPDATE tblMessages SET Status = @StatusSN, DTReceived = @dteDateToUse WHERE SN = @lMsgSN OR 
			(OrigMsgSN = @lOrigMsgSN AND Folder <> @lCommInbox AND Folder <> @lHistoryFolder)
	else
		UPDATE tblMessages SET Status = @StatusSN, DTReceived = @dteDateToUse WHERE SN = @lMsgSN
	
else if @StatusCode = 'PROC' 
	if @lOrigMsgSN > 0 
		UPDATE tblMessages SET Status = @StatusSN, DTTransferred = @dteDateToUse WHERE SN = @lMsgSN OR 
			(OrigMsgSN = @lOrigMsgSN AND Folder <> @lCommInbox AND Folder <> @lHistoryFolder)
	else
		UPDATE tblMessages SET Status = @StatusSN, DTTransferred = @dteDateToUse WHERE SN = @lMsgSN

else 
	if @lOrigMsgSN > 0 
		UPDATE tblMessages SET Status = @StatusSN WHERE SN = @lMsgSN OR 
			(OrigMsgSN = @lOrigMsgSN AND Folder <> @lCommInbox AND Folder <> @lHistoryFolder)
	else
		UPDATE tblMessages SET Status = @StatusSN WHERE SN = @lMsgSN


GO
GRANT EXECUTE ON  [dbo].[tm_Update_Msg_Status] TO [public]
GO
