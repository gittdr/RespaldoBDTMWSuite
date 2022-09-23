SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[tm_get_Logins_with_outbox_msgs]

AS

SET NOCOUNT ON

SELECT tblLogin.SN, tblLogin.OutBox,tblLogin.Inbox, tblLogin.Sent, tblLogin.Deleted
FROM tblLogin (NOLOCK), TblMessages(NOLOCK)
WHERE tblLogin.Outbox = tblMessages.Folder

GO
GRANT EXECUTE ON  [dbo].[tm_get_Logins_with_outbox_msgs] TO [public]
GO
