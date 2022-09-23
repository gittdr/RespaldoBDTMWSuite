SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_FastKillFolder] ( @Folder int, @LeaveRootFolder int )

AS

DECLARE @Work int

SET NOCOUNT ON 

CREATE TABLE #MsgsToKill (SN Int PRIMARY KEY) 
CREATE TABLE #MsgsToKill2 (SN Int PRIMARY KEY)
CREATE TABLE #OrigMsgsToKill (OrigMsgSN Int PRIMARY KEY) 
CREATE TABLE #ErrDatasToKill (ErrDataID Int PRIMARY KEY) 
CREATE TABLE #AttachDatasToKill (DataSN Int PRIMARY KEY) 

-- Recurse into subfolders.
SELECT @Work = ISNULL( Min(SN), 0) 
FROM tblFolders (NOLOCK) 
WHERE Parent = @Folder
WHILE @Work > 0
BEGIN
	EXECUTE dbo.tm_FastKillFolder @Work, 0

	SELECT @Work = ISNULL( Min(SN), 0) 
	FROM tblFolders (NOLOCK)
	WHERE Parent = @Folder
END

-- Get a separate list of messages to kill to isolate tblMessages to reduce locking.
INSERT INTO #MsgsToKill (SN)
	SELECT SN 
	FROM tblMessages (NOLOCK)
	WHERE Folder = @Folder
IF @@ROWCOUNT = 0 RETURN
-- Nothing to delete, so just exit.

-- Build a similar list of OrigMsgSNs to kill.  Hint required because on small folders
--   SQL often decides on other plans, then these plans will grind to a halt when tried
--   on larger folders.
INSERT INTO #OrigMsgsToKill (OrigMsgSN)
	SELECT Distinct OrigMsgSN 
	FROM tblMessages msg1 (NOLOCK)
	WHERE msg1.Folder = @Folder
	AND ISNULL(msg1.OrigMsgSN, -1) <> -1

DELETE #OrigMsgsToKill FROM tblMessages 
	WHERE #OrigMsgsToKill.OrigMsgSN = tblMessages.OrigMsgSN
	AND tblMessages.Folder <> @Folder

-- Build a list of ErrorDatas to kill.
INSERT INTO #ErrDatasToKill (ErrDataID)
	SELECT Distinct CONVERT(int,prop1.Value) 
	FROM tblMsgProperties prop1 (NOLOCK)
	INNER JOIN #msgstokill msg1 ON prop1.MsgSN = msg1.SN and prop1.PropSN = 6 

DELETE #ErrDatasToKill 
	FROM tblMsgProperties prop2 
	WHERE prop2.value = CONVERT(varchar(20), #ErrDatasToKill.ErrDataID)
	AND prop2.PropSN = 6 
	AND prop2.MsgSN NOT IN (SELECT SN FROM #msgstokill)

-- Finally, build a list of Attachments to kill.
INSERT INTO #AttachDatasToKill (DataSN)
	SELECT Distinct att1.DataSN 
	FROM tblAttachments att1 (NOLOCK)
	INNER JOIN #msgstokill msg1 ON att1.Message = msg1.SN
	WHERE NOT EXISTS
		(SELECT att2.Message 
		FROM tblAttachments att2 (NOLOCK)
		WHERE att2.DataSN = att1.DataSN
		AND att2.Message NOT IN (SELECT SN FROM #msgstokill))

SET ROWCOUNT 1000

-- Prep done: Time to start the actual deletions:
-- First remove any History references to isolate the messages.
WHILE 1=1
	BEGIN
	DELETE tblHistory FROM #msgstokill 
		WHERE tblHistory.MsgSN = #msgstokill.SN
	IF @@ROWCOUNT = 0 BREAK
	END
		
-- Now kill single copy data for messages.
WHILE 1=1
	BEGIN
	DELETE tblMsgShareData FROM #OrigMsgsToKill 
		WHERE tblMsgShareData.OrigMsgSN = #OrigMsgsToKill.OrigMsgSN
	IF @@ROWCOUNT = 0 BREAK
	END
	
-- Delete the attachment datas for this message that no other messages use.
WHILE 1=1
	BEGIN
	DELETE tblAttachmentData FROM #AttachDatasToKill
		WHERE tblAttachmentData.SN = #AttachDatasToKill.DataSN
	IF @@ROWCOUNT = 0 BREAK
	END

-- Delete from tblAttachments
WHILE 1=1
	BEGIN
	DELETE tblAttachments FROM #msgstokill 
		WHERE tblAttachments.Message = #msgstokill.SN
	IF @@ROWCOUNT = 0 BREAK
	END

-- Delete the errordata if this is the last message referencing it.
WHILE 1=1
	BEGIN
	DELETE tblErrorData FROM #ErrDatasToKill
		WHERE tblErrorData.ErrListID = #ErrDatasToKill.ErrDataID
	IF @@ROWCOUNT = 0 BREAK
	END

-- Now kill the Message Properties.
WHILE 1=1
	BEGIN
	DELETE tblMsgProperties FROM #msgstokill 
		WHERE tblMsgProperties.MsgSN = #msgstokill.SN
	IF @@ROWCOUNT = 0 BREAK
	END

-- Now the addressees' entries.
WHILE 1=1
	BEGIN
	DELETE tblTo FROM #msgstokill 
		WHERE tblTo.Message = #msgstokill.SN
	IF @@ROWCOUNT = 0 BREAK
	END

-- PTS32033 DMA 07/12/2006
-- Now the tblExternalIDs table
WHILE 1=1
	BEGIN
	DELETE tblExternalIDs FROM #msgstokill 
		WHERE tblExternalIDs.TMailObjSN = #msgstokill.SN
			AND tblExternalIDs.TmailObjType = 'MSG'				
	IF @@ROWCOUNT = 0 BREAK
	END

SET ROWCOUNT 0

-- And finally, the message itself.
WHILE 1=1
	BEGIN
	SET ROWCOUNT 0
	DELETE FROM #msgstokill2
	SET ROWCOUNT 1000
	INSERT INTO #msgstokill2 (sn) select sn from #msgstokill
	SET ROWCOUNT 0
	DELETE FROM tblMessages FROM #msgstokill2 
		WHERE tblMessages.SN = #msgstokill2.SN
	DELETE FROM #msgstokill from #msgstokill2 where #msgstokill.sn = #msgstokill2.sn
	IF (SELECT COUNT(*) FROM #msgstokill) = 0 BREAK
	END

SET ROWCOUNT 0

IF ISNULL(@LeaveRootFolder, 0) = 0
	DELETE FROM tblFolders WHERE SN = @Folder

GO
GRANT EXECUTE ON  [dbo].[tm_FastKillFolder] TO [public]
GO
