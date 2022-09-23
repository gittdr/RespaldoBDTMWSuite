SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_CheckDelayedMessages]	@XactCount int=-1
AS
-- This routine checks if any resourses have Delayed messages that are due for a recheck.  For each such driver found, it will queue up
--	a Check Relationship special message for that driver in the Transaction Inbox.  This message actually does nothing except cause 
--	Transact to reevaluate the driver/tractor relationship, then trigger tm_SendDriverMessageToCommInbox to use the results to
--	reevaluate the driver's delayed messages.  XactCount is a pure optimization parm which may be set to avoid having to look it up
--	each time this is called.
--
--		NOTE:
--      Stored proc tm_SendDriverMessageToCommInbox will set the DelayedUntil field
--      to NULL is there are no delayed messages left to process for the driver.
--  
DECLARE @DrvSN int, @DeliverTo varchar(50), @SpclMsgSN int, @FinalFolder INT, @TrvSN INT

SELECT @SpclMsgSN = SN from tblSpecialMessages (NOLOCK) WHERE Class = 'TMXact.clsCheckRelationship'
IF ISNULL(@SpclMsgSN, 0) = 0 RETURN

--Driver check
-- PTS 47103 - VMS
-- PTS 51804 - VMS - Reversed change made by PTS 47103
SELECT @DrvSN = min(SN) from tblDrivers (NOLOCK) WHERE DelayedUntil < GETDATE()
WHILE isnull(@DrvSN, '') <> ''
	BEGIN
	-- PTS 47103 - VMS
	-- PTS 51804 - VMS - Reversed change made by PTS 47103
	UPDATE tblDrivers SET DelayedUntil = NULL WHERE SN = @DrvSN

	SELECT @FinalFolder = Inbox FROM tblServer (NOLOCK) WHERE ServerCode = 'T'
	
	SELECT @DeliverTo = Name from tblDrivers (NOLOCK) WHERE SN = @DrvSN
	INSERT INTO tblMessages (Type, Status, Priority, FromType, DeliverToType, DTSent, Folder, Contents, FromName, Subject, DeliverTo, Receipt, Position, Latitude, Longitude, SpecialMsgSN, DeliveryKey)
		VALUES (7, 1, 3, 1, 5, GETDATE(), @FinalFolder, 'Check relationship:'+@DeliverTo, 'Admin', 'Check relationship:'+@DeliverTo, @DeliverTo, 1, 0, 0.0, 0.0, @SpclMsgSN, 0)
	-- PTS 47103 - VMS
	-- PTS 51804 - VMS - Reversed change made by PTS 47103
	SELECT @DrvSN = min(SN) from tblDrivers (NOLOCK) WHERE DelayedUntil < GETDATE() AND SN > @DrvSN

	END

SELECT @TrvSN = min(SN) from tbltrucks (NOLOCK) WHERE DelayedUntil < GETDATE()
--Truck check, added in 74873
WHILE isnull(@TrvSN, '') <> ''
	BEGIN

	UPDATE tbltrucks SET DelayedUntil = NULL WHERE SN = @TrvSN

	SELECT @FinalFolder = Inbox FROM tblServer (NOLOCK) WHERE ServerCode = 'T'

	SELECT @DeliverTo = TruckName from tbltrucks (NOLOCK) WHERE SN = @TrvSN
	INSERT INTO tblMessages (Type, Status, Priority, FromType, DeliverToType, DTSent, Folder, Contents, FromName, Subject, DeliverTo, Receipt, Position, Latitude, Longitude, SpecialMsgSN, DeliveryKey)
		VALUES (7, 1, 3, 1, 4, GETDATE(), @FinalFolder, 'Check relationship:'+@DeliverTo, 'Admin', 'Check relationship:'+@DeliverTo, @DeliverTo, 1, 0, 0.0, 0.0, @SpclMsgSN, 0)

	SELECT @TrvSN = min(SN) from tbltrucks (NOLOCK) WHERE DelayedUntil < GETDATE() AND SN > @TrvSN

	END
GO
GRANT EXECUTE ON  [dbo].[tm_CheckDelayedMessages] TO [public]
GO
