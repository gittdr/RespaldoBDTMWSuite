SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_DlvOutboundTruckMsgs]

AS

/***********************************************************
	This proc will move messages from all tractors'
	inboxes to the comm inbox, and is called by DlvUI.exe

	NOTE: This assumes that the tblTrucks.DefaultDriver is 
		  correct as this is the drivers history the message
		  will be sent to.
************************************************************/
SET NOCOUNT ON

DECLARE @MCTDeliverToType int,
		@CommInbox int,
		@NewStatusSN int

DECLARE @t1 AS table(MsgSN int, ExistingHistDrv int, NewHistDrv INT, HistTrk int, DeliverTo varchar(50))

-- Get MobileComm address type
SELECT @MCTDeliverToType = SN
FROM tblAddressTypes (NOLOCK)
WHERE AddressType = 'C'

-- Get the Comm Inbox
SELECT @CommInbox = Inbox
FROM tblServer (NOLOCK)
WHERE ServerCode = 'C'

-- Get the SN of the NEW message status
SELECT @NewStatusSN = SN
FROM tblMsgStatus (NOLOCK)
WHERE Code = 'new'
--WHERE Code = 'prep'

INSERT INTO @t1 (MsgSN, NewHistDrv, HistTrk, DeliverTo, ExistingHistDrv) 
SELECT tblMessages.SN, tblTrucks.DefaultDriver, tblTrucks.SN, tblCabUnits.UnitID, tblMessages.ToDrvSN
FROM tblMessages (nolock)
INNER JOIN tblTrucks (nolock) ON tblMessages.Folder = tblTrucks.Inbox
INNER JOIN tblCabUnits (nolock) ON tblTrucks.DefaultCabUnit = tblCabUnits.SN
WHERE (tblCabUnits.Type <> 1 OR LEFT(tblCabUnits.UnitID,5) <> 'NONMC') -- PTS14323 - exclude msg to empty non-mobilecomm group

UPDATE tblMessages 
SET	Folder = @CommInbox, 
	Status = CONVERT(int, @NewStatusSN), 
	HistDrv = ISNULL(t.ExistingHistDrv, t.NewHistDrv), 
	HistTrk = t.HistTrk, 
	DeliverTo = t.DeliverTo, 
	DeliverToType = @MCTDeliverToType
FROM @t1 t
WHERE tblMessages.SN = t.MsgSN AND ISNULL(tblMessages.MaxDelayMins, 0) = 0

GO
GRANT EXECUTE ON  [dbo].[tm_DlvOutboundTruckMsgs] TO [public]
GO
