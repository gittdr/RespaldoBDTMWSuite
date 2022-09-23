SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_SendTrailerAlarm]
	@TruckID  VARCHAR(25) = NULL,
	@AssetID  VARCHAR(25),
	@DataGateID  VARCHAR(25),
	@FromName VARCHAR(25),
	@Subject VARCHAR(255),
	@MsgText VARCHAR(4000),
	@SendToAdmin BIT = 0,
	@SendToHistory BIT = 0,
	@AutoCreateDevices BIT = 0

AS

/**
 * 
 * NAME:
 * dbo.[tm_SendTrailerAlarm]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Sends a message to the admin and truck history
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * @TruckID VARCHAR(25		- The Tractor ID
 * @AssetID VARCHAR(25		- The Asset ID
 * @DataGateID VARCHAR(25	- The DataGate ID
 * @FromName VARCHAR(25),	- ORBCOMM Service
 * @Subject VARCHAR(255),	- The subject
 * @Message VARCHAR(4000),	- The message
 * @SendToAdmin BIT,		- A flag indicating whether to send a message to admin or not
 * @SendToHistory BIT		- A flag indicating whether to send a message to truck history or not
 * @AutoCreateDevices BIT	- Whether or Not to add the device to TotalMail
 * 
 *
 * REVISION HISTORY:
 * 11/26/14					- PTS 79455 AB - Created Stored Procedure for ORBCOMM Trailer Management Service
 * 01/16/15					- Modified the stored proc to enhance the delivery of messages to the appropriate
 *							  recepient.
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @FromType Int,
		@TrailerSN VARCHAR(25),
		@Status Int,
		@HistFldrSN Int,
		@DrvSN Int,
		@MsgSN Int,
		@DeliverTo Varchar(50),
		@DeliverToType Int,
		@Date datetime


----------------------------------------------------------------------------------------------------------

--	Set constants

----------------------------------------------------------------------------------------------------------
SET @FromType = 1
SET @Status = 1
SET @Date = GETDATE()

----------------------------------------------------------------------------------------------------------

--	Set the FromName to equal the Asset ID

----------------------------------------------------------------------------------------------------------
IF @AssetID IS NOT NULL
BEGIN
	SET @FromName = @AssetID
END

----------------------------------------------------------------------------------------------------------

--	Send an admin message IF @SendToAdmin is set

----------------------------------------------------------------------------------------------------------
IF (@SendToAdmin=1)
BEGIN
	EXEC [dbo].[tm_AdminMessage] @FromName, @FromType, @Subject, @MsgText, @Status
	
	----------------------------------------------------------------------------------------------------------
	-- Make the message red
	----------------------------------------------------------------------------------------------------------
	SET @MsgSN = (SELECT TOP 1 SN FROM tblMessages ORDER BY SN DESC)
	
	----------------------------------------------------------------------------------------------------------
	-- Set the priority to high
	----------------------------------------------------------------------------------------------------------
	UPDATE tblMessages SET Priority=4 WHERE SN=@MsgSN
	
	----------------------------------------------------------------------------------------------------------
	-- Make the message red
	----------------------------------------------------------------------------------------------------------
	EXEC [dbo].[tm_AddErrorToMessage] @MsgSN, 0, @MsgText, @AssetID, 0
END

----------------------------------------------------------------------------------------------------------

--	Get the TruckSN of the trailer (TruckSN belongs to a trailer since we don't have a seperate trailer tbl)

----------------------------------------------------------------------------------------------------------
IF @TrailerSN IS NULL
BEGIN
	SET @TrailerSN = (SELECT SN FROM tblTrucks where TruckName = @AssetID)
	
	-- If it still doesn't exist, try and create it
	IF @TrailerSN IS NULL AND @AutoCreateDevices=1
	BEGIN
		EXECUTE [dbo].[tm_ConfigTrailer] 
		   @AssetID
		  ,@AssetID
		  ,NULL
		  ,NULL
		  ,@DataGateID
		  ,0
		  ,1
		  
		-- now try and get the SN once more
		SET @TrailerSN = (SELECT SN FROM tblTrucks where TruckName = @AssetID)
		
		-- since the proc tm_ConfigTrailer automatically sets the mcunit
		-- type to TTIS, we have to manually change that to ORBCOMM
		IF @TrailerSN IS NOT NULL
		BEGIN
		EXEC dbo.tm_ConfigMCUnit @DataGateID,
			'',
			'TTIS', -- temporarily. Untill orbcomm type is added
			NULL,
			NULL,
			NULL,
			NULL,
			NULL
		END
	END
	
	IF @TrailerSN IS NULL AND @SendToHistory=1
	BEGIN
		RAISERROR(N'No trailer history was found', 16, 1)
		RETURN
	END
END

----------------------------------------------------------------------------------------------------------

--	Send a history message IF @SendToHistory is set and TractorSN or AssetID are not null

----------------------------------------------------------------------------------------------------------
IF (@SendToHistory=1 AND @TrailerSN IS NOT NULL)
BEGIN

	BEGIN TRY

		----------------------------------------------------------------------------------------------------------

		--	Get SN for the History Folder:

		----------------------------------------------------------------------------------------------------------

		SELECT @HistFldrSN = text

		FROM tblRS (NOLOCK)

		WHERE keyCode = 'HISTORY'



		IF ISNULL(@HistFldrSN,-1) < 0

			RAISERROR(N'History folder could not be found in tblRS', 16, 1)

		----------------------------------------------------------------------------------------------------------

		--	Get the TruckName and Driver SN:

		----------------------------------------------------------------------------------------------------------

		SELECT	@DeliverTo = TruckName, @DrvSN = DefaultDriver	

		FROM tblTrucks (NOLOCK)

		WHERE SN = @TrailerSN


		IF ISNULL(@TrailerSN,-1) < 0

			RAISERROR(N'tblTrucks record not found where SN = ''%s''', 16 ,1, @TrailerSN)

		----------------------------------------------------------------------------------------------------------

		BEGIN TRANSACTION

		----------------------------------------------------------------------------------------------------------

			INSERT INTO tblMessages	
			(
				Type, 
				Status, 
				Priority, 
				FromType, 
				DeliverToType, 
				DTSent, 
				DTReceived, 
				DTTransferred, 
				Folder, 
				Contents, 
				FromName, 
				Subject, 
				DeliverTo, 
				HistDrv, 
				HistTrk, 
				Receipt, 
				ToDrvSN, 
				ToTrcSN
			)
			VALUES
			(
				1,	
				4,		
				4,		
				@FromType, 
				@DeliverToType,	
				@Date,	
				@Date, 
				@Date, 
				@HistFldrSN, 
				@MsgText, 
				@FromName, 
				@Subject, 
				@DeliverTo, 
				@DrvSN, 
				@TrailerSN, 
				0,		
				@DrvSN,	
				@TrailerSN
			)

			SELECT @MsgSN = SCOPE_IDENTITY()

			----------------------------------------------------------------------------------------------------------

			UPDATE tblMessages 

			SET OrigMsgSN = @MsgSN, BaseSN = @MsgSN 

			WHERE SN = @MsgSN 

			----------------------------------------------------------------------------------------------------------

			INSERT INTO tblHistory(DriverSN, TruckSN, MsgSN, Chached)

			VALUES(@DrvSN, @TrailerSN, @MsgSN, 1)

			----------------------------------------------------------------------------------------------------------

			INSERT INTO tblTo(Message, ToName, ToType, DTTransferred, IsCC)

			VALUES(@MsgSN, @DeliverTo, @DeliverToType, GETDATE(), 0)
			
			----------------------------------------------------------------------------------------------------------
			-- Make the message red
			----------------------------------------------------------------------------------------------------------
			EXEC [dbo].[tm_AddErrorToMessage] @MsgSN, 0, @MsgText, @AssetID, 0

		COMMIT TRAN

	END TRY

	BEGIN CATCH

		DECLARE @ErrorMessage NVARCHAR(4000);

		DECLARE @ErrorSeverity INT;

		DECLARE @ErrorState INT;



		IF @@TRANCOUNT > 0

			ROLLBACK TRAN



		SELECT 

			@ErrorMessage = ERROR_MESSAGE(),

			@ErrorSeverity = ERROR_SEVERITY(),

			@ErrorState = ERROR_STATE();



		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
		
	END CATCH
END
GO
GRANT EXECUTE ON  [dbo].[tm_SendTrailerAlarm] TO [public]
GO
