SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_SendLoginOutboxMsg]	@MessageSN int, @SentBox int, @XactCount int=-1
	-- @MessageSN is the message to send.  @SentBox is the outbox to put the message in after it is sent.  @XactCount is a purely
	--	optional opitimization parameter that may be set to save the system having to relook up this up when delivering messages
	--	to trucks or drivers.
AS

SET NOCOUNT ON 

DECLARE @WorkRec int, @ToText varchar(50), @ToType int, @NewToText varchar(50), @NewToType int, @ErrMessage varchar(200), @GroupFlag int, @GroupCabSN int, @RetVal int
DECLARE @NewSN int, @Successes int

CREATE TABLE #Destinations (SN int IDENTITY PRIMARY KEY, DeliverTo varchar(50) not null, DeliverToType int not null)
CREATE TABLE #NonMCDestinations (DeliverTo varchar(50), DeliverToType int)

UPDATE tblMessages SET BaseSN = @MessageSN WHERE SN = @MessageSN AND ISNULL(BaseSN, 0) <> @MessageSN

SELECT @WorkRec = MIN(SN) 
FROM tblTo (NOLOCK)
WHERE Message = @MessageSN
WHILE ISNULL(@WorkRec, 0)<> 0
	BEGIN
	SELECT @ToText = ToName, @ToType = ToType 
	FROM tblTo (NOLOCK)
	WHERE SN = @WorkRec
	IF ISNULL(@ToType, 0) = 0
		BEGIN
		EXEC tm_GetToType @ToText Out, @ToType out, 0
		if @ToType = 0 SELECT @ToType = 2
		IF EXISTS (SELECT * 
					FROM tblTo (NOLOCK) 
					WHERE Message = @MessageSN AND SN <> @WorkRec AND ToName = @ToText AND ToType = @ToType)
			BEGIN
			DELETE FROM tblTo WHERE Message = @MessageSN AND SN <> @WorkRec AND ToName = @ToText AND ToType = @ToType
			SELECT @ToType = 0
			END
		ELSE
			UPDATE tblTo SET ToType = @ToType, ToName = @ToText WHERE SN = @WorkRec
		END
	IF @ToType <> 0
		BEGIN
		SELECT @NewToType = @ToType, @NewToText = @ToText
		WHILE @ToType = 8
			BEGIN
			SELECT @NewToText = AddressName, @NewToType = AddressType 
			FROM tblAddresses (NOLOCK)
			INNER JOIN tblAddressBook (NOLOCK) ON tblAddresses.SN = tblAddressBook.DefaultAddress 
			WHERE tblAddressBook.Name = @ToText
			IF @NewToType = @ToType AND @NewToText = @ToText
				BEGIN
				-- Unhandled Deliver To Type
				SELECT @ErrMessage = 'Address for Alias ''~1'' has been deleted!'
				EXEC tm_t_sp @ErrMessage out, 10413, ''
				exec tm_sprint @ErrMessage out, @ToText, '', '', '', '', '', '', '', '', ''
				Exec tm_BounceMessage @MessageSN, 0, @ErrMessage, 'clsDelivery', 1	-- Fail, but don't bounce original (will try to process other tblTo records)
				SELECT @ToType = 0
				END
			SELECT @ToType = @NewToType, @ToText = @NewToText
			END
		END
	IF @ToType = 4
		BEGIN
		SELECT @GroupFlag = ISNULL(GroupFlag, 0), @GroupCabSN = DefaultCabUnit 
		FROM tblTrucks (NOLOCK) 
		WHERE TruckName = @ToText
		IF @GroupFlag <> 2
			BEGIN
				IF NOT EXISTS (SELECT * 
								FROM #Destinations 
								WHERE DeliverTo = @ToText AND DeliverToType = @ToType)
				INSERT #Destinations (DeliverTo, DeliverToType) VALUES (@ToText, @ToType)
			END
		ELSE
			BEGIN
			DELETE #NonMCDestinations
			INSERT #NonMCDestinations (DeliverTo, DeliverToType)
                    	select DISTINCT
				CASE	WHEN ISNULL(c.linkedaddrtype, 4) = 4 OR ISNULL(c.linkedaddrtype, 4) = 0 
						THEN ISNULL(t1.truckname, t2.truckname) 
					ELSE D.Name END,
				CASE    WHEN ISNULL(c.linkedaddrtype, 4) = 4 OR ISNULL(c.linkedaddrtype, 4) = 0 
						THEN 4
					ELSE c.linkedaddrtype END
                    		FROM tblcabunits c (NOLOCK)
                    		inner join tblcabunitgroups g (NOLOCK) on c.sn = g.membercabsn
                    		left outer join tbltrucks t1 (NOLOCK) on c.truck = t1.sn
                    		left outer join tbltrucks t2 (NOLOCK) on ISNULL(c.linkedaddrtype, 4) = 4 and c.linkedobjsn = t2.sn
                    		left outer join tbldrivers d (NOLOCK) on ISNULL(c.linkedaddrtype, 4) <> 4 AND c.linkedobjsn = d.sn
                    		where g.groupcabsn = @GroupCabSN
			
			INSERT #Destinations (DeliverTo, DeliverToType) 
			SELECT NonMC.DeliverTo, NonMC.DeliverToType 
			FROM #NonMCDestinations NonMC
			WHERE ISNULL(DeliverTo, '') <> '' AND
				DeliverToType in (4, 5) AND
				NOT EXISTS (SELECT * FROM #Destinations Test WHERE Test.DeliverTo = NonMc.DeliverTo AND Test.DeliverToType = NonMC.DeliverToType)
			END
		END
	ELSE IF @ToType <> 0
		BEGIN
		IF NOT EXISTS (SELECT * 
						FROM #Destinations 
						WHERE DeliverTo = @ToText AND DeliverToType = @ToType)
			INSERT #Destinations (DeliverTo, DeliverToType) VALUES (@ToText, @ToType)
		END
	SELECT @WorkRec = MIN(SN) 
	FROM tblTo (NOLOCK)
	WHERE Message = @MessageSN AND SN > @WorkRec
	END

SELECT @Successes = 0
SELECT @WorkRec = MIN(SN) FROM #Destinations
IF ISNULL(@WorkRec, 0) = 0
	BEGIN
	-- Unhandled Deliver To Type
	SELECT @ErrMessage = 'No valid addressees for message (only empty groups?)'
	EXEC tm_t_sp @ErrMessage out, 0, ''
	Exec tm_BounceMessage @MessageSN, 0, @ErrMessage, 'clsDelivery', 3	-- Fail and Bounce original.
	RETURN 1
	END
WHILE ISNULL(@WorkRec, 0) <> 0
	BEGIN
	SELECT @ToText = DeliverTo, @ToType = DeliverToType 
	FROM #Destinations 
	WHERE SN = @WorkRec
	
	exec dbo.tm_duplicate_message @MessageSN, 1, @NewSN OUT, 5
	exec @RetVal = dbo.tm_DeliverOneMessage @NewSN, 1, @ToText, @ToType, -1, -1, @XactCount, @MessageSN
	
	SELECT @Successes = @Successes + @RetVal
	
	SELECT @WorkRec = MIN(SN) 
	FROM #Destinations 
	WHERE SN > @WorkRec
	END
IF ISNULL(@Successes, 0) = 0
	BEGIN
	-- Unhandled Deliver To Type
	SELECT @ErrMessage = 'No valid addressees for message (all failed delivery)'
	EXEC tm_t_sp @ErrMessage out, 0, ''
	Exec tm_BounceMessage @MessageSN, 0, @ErrMessage, 'clsDelivery', 3	-- Fail and Bounce original.
	RETURN 1
	END
IF ISNULL(@SentBox, 0) <> 0
	UPDATE tblMessages SET Folder = @SentBox WHERE SN = @MessageSN
ELSE
	EXEC dbo.tm_KillMsg @MessageSN
RETURN 1

GO
GRANT EXECUTE ON  [dbo].[tm_SendLoginOutboxMsg] TO [public]
GO
