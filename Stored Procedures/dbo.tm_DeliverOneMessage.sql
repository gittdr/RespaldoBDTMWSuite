SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_DeliverOneMessage]	@MessageSN int,
						@PreTransactionMode int,
						@DeliverToName varchar(50)='',
						@DeliverToType int=0,
						@ToTruckSN int=-1,
						@ToDriverSN int=-1,
						@XactCount int=-1,
						@BaseSN int=-1
AS
-- This routine delivers the message to the appropriate destination.  The first 4 optional parameters override their equivalents on the 
--	message when used.  If they are not supplied, then the routine will instead look at the message for these.  Any that are supplied
--	will update the message (note: for @ToTruckSN and @ToDriverSN, 0 and NULL both mean to save that there is no matching item of that 
--	type, while the default -1 means to use the value from tblMessages, if any).  The @XactCount optional parameter is a straight
--	optimization parameter, and if supplied it simply saves the routine having to look this up every time it needs it.
-- This routine will fail if either the DeliverTo or DeliverToType are not specified at all.

SET NOCOUNT ON

declare @dbDeliverToName varchar(50), 
		@dbDeliverToType int, 
		@dbToTruckSN int, 
		@dbToDriverSN int, 
		@FinalFolderText varchar(50), 
		@dbBaseSN int
declare @FinalFolder int, 
		@ErrMessage varchar(200), 
		@DeliverToTypeText varchar(50), 
		@FinalTransact int, 
		@RetVal int, 
		@XactCode VARCHAR(4)

-- If any values are needed, retrieve them from the DB
if ISNULL(@DeliverToType, 0) = 0 OR ISNULL(@DeliverToName, '') = '' OR isnull(@ToTruckSN, 0) < 0 OR isnull(@ToDriverSN, 0) < 0 OR ISNULL(@BaseSN, 0) < 0
SELECT	@dbDeliverToName = DeliverTo, 
	@dbDeliverToType = DeliverToType, 
	@dbToTruckSN = ToTrcSN, 
	@dbToDriverSN = ToDrvSN, 
	@dbBaseSN = BaseSN 
	FROM tblMessages WHERE SN = @MessageSN

-- Update any skipped parameters
if ISNULL(@DeliverToType, 0) = 0 OR ISNULL(@DeliverToName, '') = '' select @DeliverToType = @dbDeliverToType, @DeliverToName = @dbDeliverToName
if isnull(@ToTruckSN, 0) < 0 select @ToTruckSN = @dbToTruckSN 
if isnull(@ToDriverSN, 0) < 0 select @ToDriverSN = @dbToDriverSN 
if isnull(@BaseSN, 0) < 0 SELECT @BaseSN = @dbBaseSN

-- Delivery process is mostly determined by DeliverToType
IF ISNULL(@DeliverToType, 0) = 1
	BEGIN
	-- Logins: messages go directly to their inbox.
	SELECT @FinalFolder = Inbox 
	FROM tblLogin (NOLOCK)
	WHERE LoginName = @DeliverToName
	IF EXISTS (SELECT * FROM tblFolders (NOLOCK) WHERE SN = @FinalFolder)
		BEGIN
		UPDATE tblMessages SET 
			Status = 4, 
			Folder = @FinalFolder, 
			DTReceived = GETDATE(), 
			DeliverTo = @DeliverToName,
			DeliverToType = @DeliverToType
			WHERE SN = @MessageSN
		IF ISNULL(@BaseSN, 0) <> 0 AND ISNULL(@BaseSN, @MessageSN) <> 0
			UPDATE tblMessages SET 
				Status = 4
				WHERE SN = @BaseSN AND Status < 4
		UPDATE tblLogin SET LastTMDlvry = GETDATE() FROM tblLogin WHERE Inbox = @FinalFolder
		RETURN 1
		END
	END
ELSE IF ISNULL(@DeliverToType, 0) = 2
	BEGIN
	-- MAPI: messages go directly to the MAPI inbox.
	SELECT @FinalFolder = Inbox FROM tblServer (NOLOCK) WHERE ServerCode = 'M'
	IF EXISTS (SELECT * FROM tblFolders (NOLOCK) WHERE  SN = @FinalFolder)
		BEGIN
		UPDATE tblMessages SET 
			Folder = @FinalFolder, 
			DeliverTo = @DeliverToName,
			DeliverToType = @DeliverToType
			WHERE SN = @MessageSN
		RETURN 1
		END
	END
ELSE IF ISNULL(@DeliverToType, 0) = 3
	BEGIN
	-- DispatchGroups: messages go directly to their inbox.
	SELECT @FinalFolder = Inbox FROM tblDispatchGroup (NOLOCK) WHERE Name = @DeliverToName
	IF EXISTS (SELECT * FROM tblFolders (NOLOCK) WHERE SN = @FinalFolder)
		BEGIN
		UPDATE tblMessages SET 
			Status = 4, 
			Folder = @FinalFolder, 
			DTReceived = GETDATE(), 
			DeliverTo = @DeliverToName,
			DeliverToType = @DeliverToType
			WHERE SN = @MessageSN
		IF ISNULL(@BaseSN, 0) <> 0 AND ISNULL(@BaseSN, @MessageSN) <> 0
			UPDATE tblMessages SET 
				Status = 4
				WHERE SN = @BaseSN AND Status < 4
		UPDATE tblLogin
			SET LastTMDlvry = GetDate()
			FROM tblLogin 
				INNER JOIN tblDispatchLogins ON tblDispatchLogins.LoginSN = tblLogin.SN
				INNER JOIN tblDispatchGroup ON tblDispatchGroup.SN = tblDispatchLogins.DispatchGroupSN
	                WHERE tblDispatchGroup.Inbox = @FinalFolder
		RETURN 1
		END
	END
ELSE IF ISNULL(@DeliverToType, 0) = 4 
	BEGIN
	-- Tractors: messages go to Transaction Inbox if @PreTransactionMode, or through a more complex stored proc if not.
	IF ISNULL(@ToTruckSN, 0) <= 0
		SELECT @ToTruckSN = SN 
		FROM tblTrucks (NOLOCK)
		WHERE TruckName = @DeliverToName
	IF @PreTransactionMode = 0
		BEGIN
		EXEC @RetVal = tm_SendTractorMessageToCommInbox @MessageSN, @ToTruckSN, @ToDriverSN, @DeliverToName
		RETURN @RetVal
		END
	ELSE
		BEGIN
			SELECT @FinalFolder = Inbox 
			FROM tblServer (NOLOCK) 
			WHERE ServerCode = 'T'

		IF EXISTS (SELECT * FROM tblFolders (NOLOCK) WHERE SN = @FinalFolder)
			BEGIN
			UPDATE tblMessages SET 
				Folder = @FinalFolder, 
				DeliverTo = @DeliverToName,
				DeliverToType = @DeliverToType
				WHERE SN = @MessageSN
			RETURN 1
			END
		END
	END
ELSE IF ISNULL(@DeliverToType, 0) = 5 
	BEGIN
	-- Drivers: messages go to Transaction Inbox if @PreTransactionMode, or through a much more complex stored proc if not.
	IF ISNULL(@ToDriverSN, 0) <= 0
		SELECT @ToDriverSN = SN 
		FROM tblDrivers (NOLOCK)
		WHERE Name = @DeliverToName
	IF @PreTransactionMode = 0
		BEGIN
		EXEC @RetVal = tm_SendDriverMessageToCommInbox @MessageSN, @ToTruckSN, @ToDriverSN, @DeliverToName
		RETURN @RetVal
		END
	ELSE
		BEGIN
			SELECT @FinalFolder = Inbox 
			FROM tblServer (NOLOCK)
			WHERE ServerCode = 'T'

		IF EXISTS (SELECT * FROM tblFolders V WHERE SN = @FinalFolder)
			BEGIN
			UPDATE tblMessages SET 
				Folder = @FinalFolder, 
				DeliverTo = @DeliverToName,
				DeliverToType = @DeliverToType
				WHERE SN = @MessageSN
			RETURN 1
			END
		END
	END
ELSE IF ISNULL(@DeliverToType, 0) = 6 
	BEGIN
	-- CabUnits: Go straight to Comm Inbox
	SELECT @FinalFolder = Inbox 
	FROM tblServer (NOLOCK)
	WHERE ServerCode = 'C'
	IF EXISTS (SELECT * FROM tblFolders (NOLOCK)WHERE SN = @FinalFolder)
		BEGIN
		UPDATE tblMessages SET 
			Folder = @FinalFolder, 
			DeliverTo = @DeliverToName,
			DeliverToType = @DeliverToType
			WHERE SN = @MessageSN
		RETURN 1
		END
	END
ELSE
	BEGIN
	-- Unhandled Deliver To Type
	SELECT @ErrMessage = 'Bad DeliverTo info: ~1/~2', @DeliverToTypeText = CONVERT(varchar(20), @DeliverToType)
	EXEC tm_t_sp @ErrMessage out, 0, ''
	exec tm_sprint @ErrMessage out, @DeliverToName, @DeliverToType, '', '', '', '', '', '', '', ''
	Exec tm_BounceMessage @MessageSN, 0, @ErrMessage, 'clsDelivery', 2	-- Bounce original.
	RETURN 0
	END

-- All successful deliveries will have returned by this point.  So if we get here, something has gone wrong.
SELECT 	@ErrMessage = 'Bad DeliverTo info: ~1/~2 (Final Folder: ~3)',
	@DeliverToTypeText = CONVERT(varchar(20), @DeliverToType),
	@FinalFolderText =case when @FinalFolder is null then 'null' else convert(varchar(20), @FinalFolder) end
EXEC tm_t_sp @ErrMessage out, 0, ''
exec tm_sprint @ErrMessage out, @DeliverToName, @DeliverToType, @FinalFolderText, '', '', '', '', '', '', ''
Exec tm_BounceMessage @MessageSN, 0, @ErrMessage, 'clsDelivery', 2	-- Bounce original.
RETURN 0
GO
GRANT EXECUTE ON  [dbo].[tm_DeliverOneMessage] TO [public]
GO
