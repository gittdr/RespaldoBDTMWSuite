SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_DeleteHistoryForResource] @lResourceSN int, 
											 @ResourceType varchar (6),	-- Truck, Driver
											 @LeaveHistoryRecord int  --1 = Leave the History record for the other resource to acess, soft delete

AS
SET NOCOUNT ON

DECLARE @lPurgeFolder int, @lRecordCount int

--Get Purge directory
EXEC dbo.tm_PurgeInit @lPurgeFolder OUT
if ISNULL(@lPurgeFolder, 0) = 0
	RAISERROR('Unabled to establish purge directory. Falied to delete history.', 16, 1)

--Get Record count to Move
if @ResourceType = 'Driver'
	BEGIN
		if @LeaveHistoryRecord = 1
			SELECT @lRecordCount = COUNT(*) 
				FROM tblHistory h (NOLOCK)
				WHERE h.DriverSN = @lResourceSN 
		else
			SELECT @lRecordCount = COUNT(*) 
				FROM tblHistory h (NOLOCK)
					INNER JOIN tblMessages m (NOLOCK) ON h.MsgSN = m.SN
				WHERE DriverSN = @lResourceSN AND m.Folder <> @lPurgeFolder
	END
ELSE IF @ResourceType = 'Truck'
	if @LeaveHistoryRecord = 1 --Just remove the resource SN from the record, allows the other resource to access the record
		SELECT @lRecordCount = COUNT(*) 
			FROM tblHistory h (NOLOCK)
			WHERE h.TruckSN = @lResourceSN 
	else
		SELECT @lRecordCount = COUNT(*) 
		FROM tblHistory h (NOLOCK)
			INNER JOIN tblMessages m (NOLOCK) ON h.MsgSN = m.SN
		WHERE h.TruckSN = @lResourceSN AND m.Folder <> @lPurgeFolder

WHILE @lRecordCount > 0 
BEGIN
	--Only move 1000 records at a time
	SET ROWCOUNT 1000

	if @ResourceType = 'Driver'
		BEGIN
			if @LeaveHistoryRecord = 1
				BEGIN
					--Remove the Resource for up to 1000 records
					UPDATE tblHistory 
					SET DriverSN = NULL
					WHERE DriverSN = @lResourceSN

					--Remove Row Count to get remaining record count
					SET ROWCOUNT 0

					SELECT @lRecordCount = COUNT(*) 
						FROM tblHistory h (NOLOCK)
						WHERE h.DriverSN = @lResourceSN 
				END
			else
				BEGIN
					--Move up to 1000 messages to the Purge folder 
					UPDATE tblMessages 
					SET Folder = @lPurgeFolder 
					FROM tblMessages m 
						INNER JOIN tblHistory h ON m.SN = h.MsgSN
					WHERE h.DriverSN = @lResourceSN AND m.Folder <> @lPurgeFolder
			
					--Remove Row Count to get remaining record count
					SET ROWCOUNT 0
				
					--Get Record count to Move
					SELECT @lRecordCount = COUNT(*) 
			 			FROM tblHistory h (NOLOCK)
							INNER JOIN tblMessages m (NOLOCK) ON h.MsgSN = m.SN
						WHERE h.DriverSN = @lResourceSN AND m.Folder <> @lPurgeFolder
				END
		END

	ELSE IF @ResourceType = 'Truck'
		BEGIN
			if @LeaveHistoryRecord = 1
				BEGIN
					--Remove the Resource for up to 1000 records
					UPDATE tblHistory 
					SET TruckSN = NULL
					WHERE TruckSN = @lResourceSN

					--Remove Row Count to get remaining record count
					SET ROWCOUNT 0

					SELECT @lRecordCount = COUNT(*) 
						FROM tblHistory h(NOLOCK)
						WHERE h.TruckSN = @lResourceSN 
				END
			else
				BEGIN
					--Move up to 1000 messages to the Purge folder 
					UPDATE tblMessages 
					SET Folder = @lPurgeFolder 
					FROM tblMessages m
						INNER JOIN tblHistory h ON m.SN = h.MsgSN
					WHERE h.TruckSN = @lResourceSN AND m.Folder <> @lPurgeFolder
			
					--Remove Row Count to get remaining record count
					SET ROWCOUNT 0
			
					--Get Record count to Move
					SELECT @lRecordCount = COUNT(*) 
					FROM tblHistory h (NOLOCK)
						INNER JOIN tblMessages m (NOLOCK) ON h.MsgSN = m.SN
					WHERE h.TruckSN = @lResourceSN AND m.Folder <> @lPurgeFolder
				END
		END
END

if @LeaveHistoryRecord <> 1
	EXEC dbo.tm_KillFolder @lPurgeFolder, 1
GO
GRANT EXECUTE ON  [dbo].[tm_DeleteHistoryForResource] TO [public]
GO
