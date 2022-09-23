SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_get_outboxset_help]	
					@FolderSN int,
					@MaxMessages int

AS
/* 10/2/01 TD: Created to workaround SQL2K Insert/Rowcount issue. */
/* 05/13/11 LB: PTS 55668 - Added DispatchGroupSN to the result set */
/* 09/14/11 DWG: PTS 58974 - UNKNOWN Dispatch Group SN retrieved */
/* 09/14/11 DWG: PTS 58991 - Performance revisions */

SET NOCOUNT ON

	DECLARE @TH2 TABLE (SN INT, 
						DTSent DATETIME, 
						DrvSN INT,
						TrcSN INT,
						DispatchGroupSN INT
					)

	DECLARE @AddressBy INT
	DECLARE @UNKNOWN_DispatchGroupSN int

	SELECT @AddressBy = CONVERT(int, Text) 
	FROM tblRs (NOLOCK) 
	WHERE KeyCode = 'ADDRESSBY'	
	
	SELECT @UNKNOWN_DispatchGroupSN = SN 
	FROM tblDispatchGroup (NOLOCK)
	WHERE Name = ' UNKNOWN'

	--Only show the dispatch group from the AddressBy
	IF @AddressBy = 0 --Driver
		BEGIN
		INSERT INTO @TH2 (SN, 
						DTSent, 
						DrvSN,
						TrcSN,
						DispatchGroupSN) 
			SELECT DISTINCT	ChosenMsg.SN,ChosenMsg.DTSent,

				CASE WHEN ISNULL(tblHistory.DriverSN,0) = 0 THEN  --if History Driver is not set then use the Message Driver SNs
						CASE WHEN ISNULL(ChosenMsg.ToDrvSN, 0) = 0 THEN ChosenMsg.FROMDrvSN ELSE ChosenMsg.ToDrvSN END 
					ELSE tblHistory.DriverSN END,

				CASE WHEN ISNULL(tblHistory.TruckSN,0) =0 THEN	--if History Truck is not set then use the Message Truck SNs
						CASE WHEN ISNULL(ChosenMsg.ToTrcSN, 0) = 0 THEN ChosenMsg.FROMTrcSN ELSE ChosenMsg.ToTrcSN END 
					ELSE tblHistory.TruckSN END,

				@UNKNOWN_DispatchGroupSN
		--We need to go to the original message to get the History Information.
		FROM tblDrivers (NOLOCK), 
		tblHistory (NOLOCK), 
		tblMessages HistMsgs (NOLOCK), 
		tblMessages ChosenMsg (NOLOCK)
		WHERE (tblDrivers.SN = tblHistory.DriverSN
			AND tblHistory.MsgSN = HistMsgs.SN)
			AND HistMsgs.OrigMsgSN = ChosenMsg.OrigMsgSN
			AND ChosenMsg.Folder = @FolderSN

		UPDATE #TH2 
			SET DispatchGroupSN = ISNULL(CurrentDispatcher, @UNKNOWN_DispatchGroupSN)
				FROM tblDrivers 
			WHERE tblDrivers.SN = DrvSN
		END
	ELSE  --AddressBy Truck
		BEGIN
		INSERT INTO @TH2 (SN, 
						DTSent, 
						DrvSN,
						TrcSN,
						DispatchGroupSN) 
			SELECT DISTINCT	ChosenMsg.SN,
				ChosenMsg.DTSent,

				CASE WHEN ISNULL(tblHistory.DriverSN,0) = 0 THEN  --if History Driver is not set then use the Message Driver SNs
						CASE WHEN ISNULL(ChosenMsg.ToDrvSN, 0) = 0 THEN ChosenMsg.FROMDrvSN ELSE ChosenMsg.ToDrvSN END 
					ELSE tblHistory.DriverSN END,

				CASE WHEN ISNULL(tblHistory.TruckSN,0) =0 THEN	--if History Truck is not set then use the Message Truck SNs
						CASE WHEN ISNULL(ChosenMsg.ToTrcSN, 0) = 0 THEN ChosenMsg.FROMTrcSN ELSE ChosenMsg.ToTrcSN END 
					ELSE tblHistory.TruckSN END,

				@UNKNOWN_DispatchGroupSN
		--We need to go to the original message to get the History Information.
		FROM tblTrucks (NOLOCK), 
		tblHistory (NOLOCK), 
		tblMessages HistMsgs (NOLOCK), 
		tblMessages ChosenMsg (NOLOCK)
		WHERE (tblTrucks.SN = tblHistory.TruckSN
			AND tblHistory.MsgSN = HistMsgs.SN)
			AND HistMsgs.OrigMsgSN = ChosenMsg.OrigMsgSN
			AND ChosenMsg.Folder = @FolderSN

		UPDATE @TH2 
			SET DispatchGroupSN = ISNULL(CurrentDispatcher, @UNKNOWN_DispatchGroupSN)
				FROM tblTrucks
			WHERE tblTrucks.SN = TrcSN
		END

	-- Set Max Messages if present
	IF ISNULL(@MaxMessages, 0)>0
		SET ROWCOUNT @MaxMessages

	-- Go get the message id's into a temp table.
	SELECT TH2.SN , TH2.DispatchGroupSN
		FROM @TH2 TH2
		ORDER BY TH2.DTSent DESC, TH2.SN DESC

	-- Restore the rowcount.
	SET ROWCOUNT 0

GO
GRANT EXECUTE ON  [dbo].[tm_get_outboxset_help] TO [public]
GO
