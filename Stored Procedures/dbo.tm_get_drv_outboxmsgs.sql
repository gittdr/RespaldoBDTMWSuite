SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[tm_get_drv_outboxmsgs] 

AS

SET NOCOUNT ON

SELECT tblMessages.SN, tblDrivers.SN DriverSN, tblDrivers.KeepHistory, tblDrivers.CurrentTruck 
FROM tblMessages (NOLOCK) , tblDrivers (NOLOCK)
WHERE tblMessages.Folder = tblDrivers.Outbox AND tblMessages.DeliveryKey & 1 = 1 ORDER BY tblDrivers.SN

GO
GRANT EXECUTE ON  [dbo].[tm_get_drv_outboxmsgs] TO [public]
GO
