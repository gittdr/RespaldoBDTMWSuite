SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TMail_Transaction_Move_Messages]
	-- 90738 AB: only kept as to not break stuff.
	@iActiveTransCount int = NULL,
	@InstanceName VARCHAR(4) = NULL
AS 


/**
 * 
 * NAME:
 * dbo.TMail_Transaction_Move_Messages
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Used for Message Balancing. Updates the TranInstance field in TMSQLMessages to the appropriate 
 *   Transaction Server
 *
 * RETURNS:
 * NONE
 * 
 * PARAMETERS:
 * @iActiveTransCount = Count of Active (Flag = 1 and Flag <> 4) transaction servers
 * 
 * Change Log: 
 * DWG 05/01/2013 PTS 61250 - Created
 * AB  05/27/2015 PTS 90738 - Changed the behaviour of this stored proc
 *
 **/


 DECLARE	@TranCount			INT,
			@Flags				INT,
			@ServerCode			VARCHAR(4),
			@SN					INT,
			@Data				VARCHAR(MAX),
			@TranInstance		INT,
			@MessageSN			INT,
			@MessageCount		INT,
			@MessageTo			VARCHAR(100),
			@MessageToType		INT

-- Get the transaction agents count
SET @TranCount = (SELECT COUNT(*) FROM TMSQLMessageTran WHERE Flags = 3)

-- If we have more than one, error out. ONLY one can process from TMSQLMessage
IF @TranCount > 1
BEGIN
	--RAISERROR('There is more than one Transaction Agent available for source processing. Only one (1) Transaction Agent should be enabled for sourcing. Please examine command line parameters.', 16, 1)
	IF ISNULL(@InstanceName, '') = ''
	BEGIN
		UPDATE TMSQLMessageTran SET Flags = 1
	END
	ELSE
	BEGIN
		UPDATE TMSQLMessageTran SET Flags = 1 WHERE TMSQLMessageTran.ServerCode = @InstanceName
	END
END

-- Lets get the transaction agent with source processing
SELECT 
	@SN				= SN, 
	@ServerCode		= ServerCode, 
	@Flags			= Flags, 
	@Data			= Data 
FROM 
	TMSQLMessageTran
WHERE Flags = 3

-- Do we have messages to process? If not, exit
SET @MessageCount = (SELECT COUNT(*) FROM TMSQLMessage WHERE TranInstance IS NULL)

IF ISNULL(@MessageCount, 0) = 0
BEGIN
	RETURN
END

-- Loop through messages and process them.
WHILE ISNULL(@MessageCount, 0) > 0
BEGIN

	-- Decrement the messages count
	SET @MessageCount = @MessageCount - 1

	-- Get the top message in the list
	SELECT TOP 1
		@MessageSN			= msg_ID,
		@MessageTo			= msg_To,
		@MessageToType		= msg_ToType,
		@TranInstance		= TranInstance
	FROM TMSQLMessage
	WHERE TranInstance IS NULL

	-- Set up the data field
	IF ISNULL(@Data, '') = ''
	BEGIN
		SET @Data = ',' + CONVERT(VARCHAR, @MessageToType) + ':' + @MessageTo + ','
	END
	ELSE
	BEGIN
		SET @Data = @Data + CONVERT(VARCHAR, @MessageToType) + ':' + @MessageTo + ','
	END

	-- Update TMSQLMessage to assign the xact SN to the message
	UPDATE TMSQLMessage
	-- PTS 93372 - 08/04/15 AB: We need to look for the instance ID
	-- not the SN of the server.
	--SET	TranInstance = @SN
	SET TranInstance = RIGHT(@ServerCode, LEN(@ServerCode)-1)
	WHERE TranInstance IS NULL
	AND msg_ID = @MessageSN

	-- Finally, update the TMSQLMessageTran with the data
	UPDATE 
		TMSQLMessageTran
	SET Data = @Data
	WHERE Flags = 3
END
GO
GRANT EXECUTE ON  [dbo].[TMail_Transaction_Move_Messages] TO [public]
GO
