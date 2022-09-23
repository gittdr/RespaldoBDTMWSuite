SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[tm_get_Comms_with_inbox_msgs]
as

SET NOCOUNT ON

SELECT tblCabUnits.SN, tblCabUnits.Inbox 
FROM tblCabUnits (NOLOCK), tblMessages (NOLOCK)
WHERE tblCabUnits.Inbox = tblMessages.Folder

GO
GRANT EXECUTE ON  [dbo].[tm_get_Comms_with_inbox_msgs] TO [public]
GO
