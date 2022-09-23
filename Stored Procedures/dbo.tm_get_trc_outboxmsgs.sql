SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[tm_get_trc_outboxmsgs] 

AS

SET NOCOUNT ON 

SELECT tblMessages.SN, tblTrucks.SN DriverSN, tblTrucks.KeepHistory, tblTrucks.DefaultDriver DefaultDriver 
FROM tblMessages (NOLOCK), tblTrucks (NOLOCK)
WHERE tblMessages.Folder = tblTrucks.Outbox AND tblMessages.DeliveryKey & 2 = 2 ORDER BY tblTrucks.SN

GO
GRANT EXECUTE ON  [dbo].[tm_get_trc_outboxmsgs] TO [public]
GO
