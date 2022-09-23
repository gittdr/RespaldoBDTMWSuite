SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_KillMsgAndHistory] ( @MsgToDel int )
AS

/**
 * 
 * NAME:
 * dbo.tm_KillMsgAndHistory
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Deletes a message and its history from TotalMail. This is exactly like
 * tm_KillMsg which already exists. The only difference is the addition of
 * history deletion.
 *
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * none.
 *
 * 
 * REVISION HISTORY:
 * 09.11.2015 – PTS85567 - Abdullah Binghunaiem – Initial Creation
 *
 **/

DECLARE @BaseMsg As INT


-- Hardcoded the fact that the Error Information PropSN is 6

-- Delete the tblMsgShareData entry if this was the last message referencing it

SET NOCOUNT ON

SELECT @BaseMsg = (SELECT BaseSN FROM tblMessages WHERE SN = @MsgToDel)

DELETE tblMsgShareData WHERE tblMsgShareData.OrigMsgSN IN (
	SELECT msg1.OrigMsgSN
		FROM tblMessages msg1 (NOLOCK)
		WHERE msg1.SN IN (@MsgToDel, @BaseMsg)
		AND NOT EXISTS
			(SELECT msg2.SN
			FROM tblMessages msg2
			WHERE msg2.OrigMsgSN = msg1.OrigMsgSN
				AND msg2.SN <> @MsgToDel))

-- Delete the attachment datas for this message that no other messages use.
DELETE tblAttachmentData WHERE tblAttachmentData.SN IN (
	SELECT att1.DataSN 
		FROM tblAttachments att1 (NOLOCK)
		WHERE att1.Message IN (@MsgToDel, @BaseMsg)
		AND NOT EXISTS
			(SELECT att2.SN 
			FROM tblAttachments att2 (NOLOCK)
			WHERE att2.DataSN = att1.DataSN
				AND att2.Message <> @MsgToDel))

-- Delete from tblAttachments
DELETE tblAttachments WHERE Message IN (@MsgToDel, @BaseMsg)


-- Delete the errordata if this is the last message referencing it.
DELETE tblErrorData WHERE tblErrorData.ErrListID IN (
	SELECT CONVERT(int,prop1.Value)
		FROM tblMsgProperties prop1(NOLOCK)
		WHERE prop1.MsgSN IN (@MsgToDel, @BaseMsg)
		AND PropSN = 6
		AND NOT EXISTS
			(SELECT prop2.MsgSN
			FROM tblMsgProperties prop2 (NOLOCK)
			WHERE prop2.Value = prop1.Value
				AND prop2.MsgSN <> @MsgToDel
				AND PropSN = 6))	

-- Now kill the Message Properties.
DELETE tblMsgProperties
	WHERE MsgSN IN (@MsgToDel, @BaseMsg)

-- Then any History reference.
DELETE tblHistory
	WHERE MsgSN IN (@MsgToDel, @BaseMsg)

-- Now the addressees' entries.
DELETE FROM tblTo 
	WHERE Message IN (@MsgToDel, @BaseMsg)

-- And finally, the message itself.
DELETE FROM tblMessages
	WHERE SN IN (@MsgToDel, @BaseMsg)
GO
GRANT EXECUTE ON  [dbo].[tm_KillMsgAndHistory] TO [public]
GO
