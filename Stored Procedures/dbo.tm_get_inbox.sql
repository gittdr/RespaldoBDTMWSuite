SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_get_inbox]	@LoginSN int,
					@LoginInboxSN int,
					@MaxMessages int
AS

SET NOCOUNT ON 

CREATE TABLE #T ( Inbox int ) 
CREATE TABLE #T2 ( DTSent datetime NULL, SN int ) 

-- If no login inbox was provided, go find it.
IF ISNULL(@LoginInboxSN, 0)=0
	SELECT @LoginInboxSN = Inbox 
	FROM tblLogin (NOLOCK)
	WHERE SN = @LoginSN

-- Get the full folder list into a temp table.
INSERT INTO #T SELECT InBox 
				FROM tblDispatchGroup (NOLOCK), tblDispatchLogins (NOLOCK) 
				WHERE tblDispatchLogins.LoginSN = @LoginSN 
				AND tblDispatchLogins.DispatchGroupSN = tblDispatchGroup.SN

INSERT INTO #T (InBox) VALUES (@LoginInboxSN)

-- Set Max Messages if present
IF ISNULL(@MaxMessages, 0)>0
	SET ROWCOUNT @MaxMessages

INSERT INTO #T2 SELECT DTSent, SN 
				FROM tblMessages (NOLOCK), #T
				WHERE Folder = #T.Inbox order by DTSENT Desc

-- Restore the rowcount.
SET ROWCOUNT 0

-- Go collect and return the data.
SELECT DISTINCT tblMsgPriority.Code AS Priority, tblMsgType.Code AS Type,
  CASE WHEN tblAttachments.SN > 0 THEN 1 ELSE 0 END AS Attachment,
  tblMessages.FromName AS ToFrom, tblMessages.Subject AS Subject,
  tblMessages.DTReceived AS SentReceived, DATALENGTH(tblMessages.Contents) AS Size,
  CONVERT(VARCHAR(255), tblMessages.Contents) AS Text,
  CONVERT(VARCHAR(255),tblMessages.Contents) AS Data, tblMessages.DTRead as DTRead,
  tblMessages.SN, tblMsgProperties.Value as ErrListID, tblMessages.Status AS Status 
FROM #T2  
INNER JOIN (tblMsgProperties (NOLOCK)
 RIGHT JOIN (tblMsgType (NOLOCK)
  RIGHT JOIN (tblMsgPriority (NOLOCK)
   RIGHT JOIN  (tblMessages (NOLOCK)
    LEFT JOIN tblAttachments (NOLOCK)
    ON tblMessages.SN = tblAttachments.Message)  
   ON tblMsgPriority.SN = tblMessages.Priority) 
  ON tblMsgType.SN = tblMessages.Type) 
 ON (tblMsgProperties.MsgSN = tblMessages.SN AND tblMsgProperties.PropSN = 6) ) 
ON #T2.SN = tblMessages.SN

GO
GRANT EXECUTE ON  [dbo].[tm_get_inbox] TO [public]
GO
