SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[tm_get_Drvs_with_inbox_msgs]

AS

SET NOCOUNT ON

SELECT tblDrivers.SN, tblDrivers.InBox, tblDrivers.KeepHistory, tblDrivers.CurrentTruck
FROM tblDrivers (NOLOCK), tblMessages (NOLOCK)
WHERE tblDrivers.Inbox = tblMessages.Folder

GO
GRANT EXECUTE ON  [dbo].[tm_get_Drvs_with_inbox_msgs] TO [public]
GO
