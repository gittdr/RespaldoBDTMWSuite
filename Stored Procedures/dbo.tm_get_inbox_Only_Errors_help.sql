SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_get_inbox_Only_Errors_help]	
					@LoginSN INT,
					@LoginInboxSN INT,
					@MaxMessages INT
AS

/* 05/13/11 LB: PTS 55668 - Added DispatchGroupSN to the result set. */
/* 09/14/11 DWG: PTS 58974 - UNKNOWN Dispatch Group SN retrieved */
/* 09/14/11 DWG: PTS 58991 - Performance revisions */

SET NOCOUNT ON

	DECLARE @TH2 TABLE (SN INT, 
						DTSent DATETIME, 
						DrvSN INT,
						TrcSN INT,
						DispatchGroupSN INT
					)

	DECLARE @T TABLE (Inbox INT)

	DECLARE @AddressBy INT
	DECLARE @UNKNOWN_DispatchGroupSN int

	SELECT @AddressBy = CONVERT(int, Text) 
	FROM tblRs (NOLOCK)
	WHERE KeyCode = 'ADDRESSBY'	
	
	SELECT @UNKNOWN_DispatchGroupSN = SN 
	FROM tblDispatchGroup (NOLOCK)
	WHERE Name = ' UNKNOWN'
	
	-- If no login inbox was provided, go find it.
	IF ISNULL(@LoginInboxSN, 0)=0
		SELECT @LoginInboxSN = Inbox 
			FROM tblLogin  (NOLOCK) 
			WHERE SN = @LoginSN

	-- Get the full dispatch group inbox list for the Login into a temp table.
	INSERT INTO @T 
		SELECT InBox 
			FROM tblDispatchGroup (NOLOCK)
				JOIN tblDispatchLogins (NOLOCK) ON tblDispatchLogins.DispatchGroupSN = tblDispatchGroup.SN
			WHERE tblDispatchLogins.LoginSN = @LoginSN

	INSERT INTO @T (InBox) VALUES (@LoginInboxSN)
		
	INSERT INTO @TH2 (SN,
			DTSent,
			DrvSN,
			TrcSN,
			DispatchGroupSN)
		SELECT	tblMessages.SN,
			DTSent,

			CASE WHEN ISNULL(HIST.DriverSN,0) = 0 THEN  --if History Driver is not set then use the Message Driver SNs
					CASE WHEN ISNULL(ToDrvSN, 0) = 0 THEN FROMDrvSN ELSE ToDrvSN END 
				ELSE HIST.DriverSN END,

			CASE WHEN ISNULL(HIST.TruckSN,0) =0 THEN	--if History Truck is not set then use the Message Truck SNs
					CASE WHEN ISNULL(ToTrcSN, 0) = 0 THEN FROMTrcSN 
				ELSE ToTrcSN END ELSE HIST.TruckSN END,

			@UNKNOWN_DispatchGroupSN
		FROM dbo.tblMessages (NOLOCK)
			JOIN @T T ON tblmessages.Folder = T.Inbox 
			JOIN dbo.tblMsgProperties (NOLOCK) on tblMessages.SN = tblMsgProperties.MsgSN 
			LEFT JOIN tblHistory HIST (NOLOCK) ON HIST.MsgSN = tblMessages.SN
		WHERE tblMsgProperties.PropSN = 6 

	--Only show the dispatch group from the AddressBy
	IF @AddressBy = 0 --Driver
		UPDATE @TH2 
			SET DispatchGroupSN = ISNULL(CurrentDispatcher, @UNKNOWN_DispatchGroupSN)
				FROM tblDrivers
			WHERE tblDrivers.SN = DrvSN
	ELSE  --AddressBy Truck
		UPDATE @TH2 
			SET DispatchGroupSN = ISNULL(CurrentDispatcher, @UNKNOWN_DispatchGroupSN)
				FROM tblTrucks
				WHERE tblTrucks.SN = TrcSN

	IF ISNULL(@MaxMessages, 0) > 0 
		SET ROWCOUNT @MaxMessages

	SELECT TH2.SN, TH2.DispatchGroupSN
		FROM @TH2 TH2 
		ORDER BY TH2.DTSent DESC, TH2.SN DESC 

	SET ROWCOUNT 0
GO
GRANT EXECUTE ON  [dbo].[tm_get_inbox_Only_Errors_help] TO [public]
GO
