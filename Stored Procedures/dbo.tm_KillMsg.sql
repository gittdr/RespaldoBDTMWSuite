SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[tm_KillMsg] ( @MsgToDel int )

AS



-- Hardcoded the fact that the Error Information PropSN is 6

-- Delete the tblMsgShareData entry if this was the last message referencing it

SET NOCOUNT ON


DELETE tblMsgShareData WHERE tblMsgShareData.OrigMsgSN IN (
	SELECT msg1.OrigMsgSN
		FROM tblMessages msg1 (NOLOCK)
		WHERE msg1.SN = @MsgToDel
		AND NOT EXISTS
			(SELECT msg2.SN
			FROM tblMessages msg2
			WHERE msg2.OrigMsgSN = msg1.OrigMsgSN
				AND msg2.SN <> @MsgToDel))

-- Delete the attachment datas for this message that no other messages use.
DELETE tblAttachmentData WHERE tblAttachmentData.SN IN (
	SELECT att1.DataSN 
		FROM tblAttachments att1 (NOLOCK)
		WHERE att1.Message = @MsgToDel
		AND NOT EXISTS
			(SELECT att2.SN 
			FROM tblAttachments att2 (NOLOCK)
			WHERE att2.DataSN = att1.DataSN
				AND att2.Message <> @MsgToDel))

-- Delete from tblAttachments
DELETE tblAttachments WHERE Message = @MsgToDel


-- Delete the errordata if this is the last message referencing it.
DELETE tblErrorData WHERE tblErrorData.ErrListID IN (
	SELECT CONVERT(int,prop1.Value)
		FROM tblMsgProperties prop1(NOLOCK)
		WHERE prop1.MsgSN = @MsgToDel
		AND PropSN = 6
		AND NOT EXISTS
			(SELECT prop2.MsgSN
			FROM tblMsgProperties prop2 (NOLOCK)
			WHERE prop2.Value = prop1.Value
				AND prop2.MsgSN <> @MsgToDel
				AND PropSN = 6))	

-- Now kill the Message Properties.
DELETE tblMsgProperties
	WHERE MsgSN = @MsgToDel

-- Then any History reference.
DELETE tblHistory
	WHERE MsgSN = @MsgToDel

-- Now the addressees' entries.
DELETE FROM tblTo 
	WHERE Message = @MsgToDel

-- And finally, the message itself.
DELETE FROM tblMessages
	WHERE SN = @MsgToDel
GO
GRANT EXECUTE ON  [dbo].[tm_KillMsg] TO [public]
GO
