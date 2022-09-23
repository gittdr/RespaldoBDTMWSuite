SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_SendTractorMessageToCommInbox]	@MessageSN int,
						@ToTruckSN int,
						@ToDriverSN int,
						@DeliverToName varchar(50)
AS
-- This routine delivers a message addressed to a tractor to the comm inbox.  It will figure out what (if any) cabunits are available for
--	the specified Truck/Driver (preferring the truck), and will translate the DeliverTo information to the appropriate cabunits.  As
--	per TotalMail's legacy handling: the first Default found will just go to that default.  If no defaults are found, then will sEND
--	to all Truck cabunits.  If still nothing found, then will sEND to all Driver cabunits.  If still nothing, then will fail.  Note
--	that if there are multiple units available, then additional copies will be cut for each of them.

--RWolfe PTS76778 Add concept of a unit deicated to positions, thus can't get forms or text messages
--RWolfe PTS74873 With multiple Driver based systems existing, we now need to account for Truck delay messages

declare @WorkRecord int, @DeliverSN int, @CommInbox int, @WorkUnit varchar(50), @ErrMessage varchar(200), @CreateDate datetime
declare @OutboundDefaultHandling varchar(255), @DefaultUnit varchar(50), @DelayAllowed int, @FormSNText varchar(100), @WorkMessage int
DECLARE @SpecialMsgSN int, @DelayedMsgs int
DECLARE @MessageType INT, @DelaysEnabled INT 

SET NOCOUNT ON

create table #SENDTrcUnitList (UnitID varchar(50) not null)

SELECT @CommInbox = Inbox 
FROM tblServer (NOLOCK)
WHERE ServerCode = 'C'

SELECT @MessageType = tblMessages.TYPE FROM tblmessages WHERE SN = @MessageSN;

IF @MessageType = 5
BEGIN
	if exists (SELECT * 
					FROM tblCabUnits (NOLOCK)
					INNER JOIN tblTrucks (NOLOCK) ON tblCabUnits.SN = tblTrucks.DefaultCabUnit 
					WHERE tblTrucks.SN = @ToTruckSN)
		INSERT INTO #SENDTrcUnitList (UnitID) 
			SELECT DISTINCT tblCabUnits.UnitID 
			FROM tblCabUnits (NOLOCK) 
			INNER JOIN tblTrucks (NOLOCK) ON tblCabUnits.SN = tblTrucks.DefaultCabUnit 
			WHERE tblTrucks.SN = @ToTruckSN AND ISNULL(UnitID, '') <> ''
	ELSE if exists (SELECT * 
					FROM tblCabUnits (NOLOCK) 
					INNER JOIN tblDrivers (NOLOCK) 
					ON tblCabUnits.SN = tblDrivers.DefaultCabUnit 
					WHERE tblDrivers.SN = @ToDriverSN)
		INSERT INTO #SENDTrcUnitList (UnitID)
			SELECT DISTINCT tblCabUnits.UnitID 
			FROM tblCabUnits (NOLOCK)
			INNER JOIN tblDrivers (NOLOCK) ON tblCabUnits.SN = tblDrivers.DefaultCabUnit 
			WHERE tblDrivers.SN = @ToDriverSN AND ISNULL(UnitID, '') <> ''
	ELSE if exists (SELECT * 
					FROM tblCabUnits (NOLOCK) 
					INNER JOIN tblTrucks (NOLOCK) ON tblCabUnits.Truck = tblTrucks.SN 
					WHERE tblTrucks.SN = @ToTruckSN)
		INSERT INTO #SENDTrcUnitList (UnitID)
			SELECT DISTINCT tblCabUnits.UnitID 
			FROM tblCabUnits (NOLOCK) 
			WHERE tblCabUnits.Truck = @ToTruckSN AND ISNULL(UnitID, '') <> ''
	ELSE if exists (SELECT * 
					FROM tblCabUnits 
					INNER JOIN tblTrucks (NOLOCK) ON tblCabUnits.LinkedObjSN = tblTrucks.SN AND tblCabUnits.LinkedAddrType = 4 WHERE tblTrucks.SN = @ToTruckSN)
		INSERT INTO #SENDTrcUnitList (UnitID)
			SELECT DISTINCT tblCabUnits.UnitID 
			FROM tblCabUnits (NOLOCK) 
			WHERE tblCabUnits.LinkedObjSN = @ToTruckSN AND ISNULL(UnitID, '') <> '' AND tblCabUnits.LinkedAddrType = 4
	ELSE
		INSERT INTO #SENDTrcUnitList (UnitID)
			SELECT DISTINCT tblCabUnits.UnitID 
			FROM tblCabUnits (NOLOCK) 
			WHERE tblCabUnits.LinkedObjSN = @ToDriverSN AND ISNULL(UnitID, '') <> '' AND tblCabUnits.LinkedAddrType = 5	
END 
ELSE
BEGIN
	if exists (SELECT * 
					FROM tblCabUnits (NOLOCK)
					INNER JOIN tblTrucks (NOLOCK) ON tblCabUnits.SN = tblTrucks.DefaultCabUnit 
					WHERE tblTrucks.SN = @ToTruckSN AND tblCabUnits.PositionOnly = 0)
		INSERT INTO #SENDTrcUnitList (UnitID) 
			SELECT DISTINCT tblCabUnits.UnitID 
			FROM tblCabUnits (NOLOCK) 
			INNER JOIN tblTrucks (NOLOCK) ON tblCabUnits.SN = tblTrucks.DefaultCabUnit 
			WHERE tblTrucks.SN = @ToTruckSN AND ISNULL(UnitID, '') <> '' AND tblCabUnits.PositionOnly = 0
	ELSE if exists (SELECT * 
					FROM tblCabUnits (NOLOCK) 
					INNER JOIN tblDrivers (NOLOCK) 
					ON tblCabUnits.SN = tblDrivers.DefaultCabUnit 
					WHERE tblDrivers.SN = @ToDriverSN AND tblCabUnits.PositionOnly = 0)
		INSERT INTO #SENDTrcUnitList (UnitID)
			SELECT DISTINCT tblCabUnits.UnitID 
			FROM tblCabUnits (NOLOCK)
			INNER JOIN tblDrivers (NOLOCK) ON tblCabUnits.SN = tblDrivers.DefaultCabUnit 
			WHERE tblDrivers.SN = @ToDriverSN AND ISNULL(UnitID, '') <> '' AND tblCabUnits.PositionOnly = 0
	ELSE if exists (SELECT * 
					FROM tblCabUnits (NOLOCK) 
					INNER JOIN tblTrucks (NOLOCK) ON tblCabUnits.Truck = tblTrucks.SN 
					WHERE tblTrucks.SN = @ToTruckSN AND tblCabUnits.PositionOnly = 0)
		INSERT INTO #SENDTrcUnitList (UnitID)
			SELECT DISTINCT tblCabUnits.UnitID 
			FROM tblCabUnits (NOLOCK) 
			WHERE tblCabUnits.Truck = @ToTruckSN AND ISNULL(UnitID, '') <> '' AND tblCabUnits.PositionOnly = 0
	ELSE if exists (SELECT * 
					FROM tblCabUnits 
					INNER JOIN tblTrucks (NOLOCK) ON tblCabUnits.LinkedObjSN = tblTrucks.SN AND tblCabUnits.LinkedAddrType = 4 WHERE tblTrucks.SN = @ToTruckSN AND tblCabUnits.PositionOnly = 0)
		INSERT INTO #SENDTrcUnitList (UnitID) 
			SELECT DISTINCT tblCabUnits.UnitID 
			FROM tblCabUnits (NOLOCK) 
			WHERE tblCabUnits.LinkedObjSN = @ToTruckSN AND ISNULL(UnitID, '') <> '' AND tblCabUnits.LinkedAddrType = 4 AND tblCabUnits.PositionOnly = 0
	ELSE
		INSERT INTO #SENDTrcUnitList (UnitID)
			SELECT DISTINCT tblCabUnits.UnitID 
			FROM tblCabUnits (NOLOCK) 
			WHERE tblCabUnits.LinkedObjSN = @ToDriverSN AND ISNULL(UnitID, '') <> '' AND tblCabUnits.LinkedAddrType = 5	AND tblCabUnits.PositionOnly = 0
END


SELECT @defaultunit = min(UnitID) 
FROM #SENDTrcUnitList


IF @defaultunit is NULL 
	begin
	-- No cabunits found.  
	IF NOT EXISTS (SELECT * 
					FROM tblMessages M (NOLOCK) 
					INNER JOIN tblSpecialMessages S (NOLOCK) ON M.SpecialMsgSN = S.SN 
					WHERE M.SN = @MessageSN AND S.Class = 'TMXact.clsCheckRelationship')
		BEGIN
		-- This is not the Check relationship special message, setup its Delay information.
		SELECT @DelayAllowed = MaxDelayMins 
		FROM tblMessages (NOLOCK)
		WHERE SN = @MessageSN
		IF @DelayAllowed IS NULL
			BEGIN
			SELECT @FormSNText = Value 
			FROM tblMsgProperties (NOLOCK) 
			WHERE MsgSN = @MessageSN AND PropSN = 2
			IF ISNUMERIC(@FormSNText)<>0
				SELECT @DelayAllowed = MaxDelayMins 
				FROM tblForms (NOLOCK)
				WHERE SN = CONVERT(int, @FormSNText)
			IF Isnull(@DelayAllowed, 0) = 0
				SELECT @DelayAllowed = MaxDelayMins 
				FROM tblTrucks V
				WHERE SN = @ToTruckSN
			IF Isnull(@DelayAllowed, 0) = 0
				SELECT @DelayAllowed = ISNULL(text, 0)
				FROM tblRS(NOLOCK)
				WHERE keyCode = 'GDlyMsgInt'
			END
		-- Now delay it.
		UPDATE tblMessages SET Folder = Inbox, MaxDelayMins = @DelayAllowed FROM tblMessages, tblTrucks WHERE tblMessages.SN = @MessageSN AND tblTrucks.SN = @ToTruckSN
		END
	ELSE
		-- It is the Check message.  It has served its purpose, so kill it.
		exec tm_KillMsg @MessageSN

	SELECT @DelaysEnabled = ISNULL(text, 0) FROM tblRS(NOLOCK) WHERE keyCode = 'DlyMsgs'

	-- Now check IF any of the delayed messages have expired.
	SELECT @DelayedMsgs = 0
	SELECT @MessageSN  = MIN(tblMessages.SN) 
	FROM tblMessages (NOLOCK) 
	INNER JOIN tblTrucks ON Folder = Inbox 
	WHERE tblTrucks.SN = @ToTruckSN
	DECLARE @TimeDiff INT, @MinCumulative INT = 2147483647
	WHILE NOT (@MessageSN IS NULL)
		BEGIN
		SELECT @DelayAllowed = MaxDelayMins, @CreateDate = DTSent 
		FROM tblMessages (NOLOCK) 
		WHERE SN = @MessageSN
		SET @TimeDiff = datedIFf(mi, @CreateDate, GETDATE())
		IF @DelaysEnabled = 0 OR @TimeDiff > @DelayAllowed
			BEGIN
			-- Fail this message, it has expired.
			SELECT @ErrMessage = 'No MC Unit found for ~1.'
			EXEC tm_t_sp @ErrMessage out, 10414, ''
			exec tm_sprint @ErrMessage out, @DeliverToName, '', '', '', '', '', '', '', '', ''
			Exec tm_BounceMessage @MessageSN, 0, @ErrMessage, 'clsDelivery', 2	-- Bounce original.
			END
		ELSE      
			-- This one has not expired.  Keep a count of the delayed messages
			SELECT @DelayedMsgs= @DelayedMsgs + 1
			SET @MinCumulative = dbo.tm_IntMin(@TimeDiff, @MinCumulative)
		-- Now move to the next delayed message.
		SELECT @MessageSN  = MIN(tblMessages.SN) 
		FROM tblMessages (NOLOCK)
		INNER JOIN tblTrucks (NOLOCK) ON Folder = Inbox 
		WHERE tblTrucks.SN = @ToTruckSN AND tblMessages.SN > @MessageSN
		END
	IF @DelayedMsgs > 0
		-- There are still some delayed.  Setup another check for this driver in 5 minutes.
		UPDATE tblTrucks SET DelayedUntil = DATEADD(mi, dbo.tm_IntMin(@MinCumulative, 5), getdate()) WHERE SN = @ToTruckSN
	ELSE
		-- No delayed messages left.  Stop checking this driver.
		UPDATE tblTrucks SET DelayedUntil = NULL WHERE SN = @ToTruckSN AND DelayedUntil IS NOT NULL
	end
ELSE
	begin
	-- Got at least one cabunit.  Check for any delayed messages.
	SELECT @WorkMessage = MIN(tblMessages.SN) 
	FROM tblMessages (NOLOCK) 
	INNER JOIN tblTrucks (NOLOCK) ON tblMessages.Folder = tblTrucks.Inbox 
	WHERE tblTrucks.SN = @ToTruckSN
	IF @WorkMessage IS NULL SELECT @WorkMessage = @MessageSN

	WHILE NOT (@WorkMessage IS NULL)
		BEGIN

		SELECT @workunit = min(UnitID) 
		FROM #SENDTrcUnitList 
		WHERE UnitID > @defaultunit
		while not (@workunit is null)
			begin
			exec tm_Duplicate_Message @WorkMessage, 1, @DeliverSN out, 2
			update tblMessages SET Folder = @CommInbox, HistDrv = NULL, HistTrk = NULL, DeliverTo = @WorkUnit, DeliverToType = 6, ToTrcSN = @ToTruckSN 
			FROM tblMessages 
			WHERE SN = @DeliverSN
			
			SELECT @WorkUnit = min(UnitID) 
			FROM #SENDTrcUnitList 
			WHERE UnitID > @WorkUnit
			end
	
		update tblMessages SET Folder = @CommInbox, HistDrv = @ToDriverSN, HistTrk = @ToTruckSN, DeliverTo = @DefaultUnit, DeliverToType = 6, ToTrcSN = @ToTruckSN
		FROM tblMessages 
		WHERE SN = @WorkMessage

		IF @WorkMessage = @MessageSN
			SELECT @WorkMessage = NULL
		ELSE
			BEGIN
			SELECT @WorkMessage = MIN(tblMessages.SN) 
			FROM tblMessages (NOLOCK)
			INNER JOIN tblTrucks (NOLOCK) ON tblMessages.Folder = tblTrucks.Inbox 
			WHERE tblTrucks.SN = @ToTruckSN
			IF @WorkMessage IS NULL 
				BEGIN
				-- Have now sent all delayed messages.  Now look at the message that triggered it all.
				IF EXISTS (SELECT * 
								FROM tblMessages M (NOLOCK)
								INNER JOIN tblSpecialMessages S (NOLOCK) ON M.SpecialMsgSN = S.SN 
								WHERE M.SN = @MessageSN AND S.Class = 'TMXact.clsCheckRelationship')
					-- It is a check relationship special message.  Those exist just to trigger this process.  Delete it instead of sending it.
					exec tm_KillMsg @MessageSN
				ELSE
					-- Normal message, now process it.
					SELECT @WorkMessage = @MessageSN
				END
			END
		end
	UPDATE tblTrucks SET DelayedUntil = NULL WHERE SN = @ToTruckSN AND DelayedUntil IS NOT NULL
	end
SET NOCOUNT OFF
RETURN

GO
GRANT EXECUTE ON  [dbo].[tm_SendTractorMessageToCommInbox] TO [public]
GO
