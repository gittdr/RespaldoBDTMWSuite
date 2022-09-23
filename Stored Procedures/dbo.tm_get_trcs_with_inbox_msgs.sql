SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[tm_get_trcs_with_inbox_msgs]

AS

SET NOCOUNT ON


SELECT tblTrucks.SN, Inbox, KeepHistory, DefaultDriver 
FROM tblMessages (NOLOCK), tblTrucks (NOLOCK)
WHERE tblTrucks.Inbox = tblMessages.Folder

GO
GRANT EXECUTE ON  [dbo].[tm_get_trcs_with_inbox_msgs] TO [public]
GO
