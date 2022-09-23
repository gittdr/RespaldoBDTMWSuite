SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TM_Transaction_ReDistribute_Messages]
	@iActiveTransCount int,
	@iForceReset int
	
AS 

/**
 * 
 * NAME:
 * dbo.TM_Transaction_Move_OutBox_Messages
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Used for Message Balancing. Puts the transaction servers in reset mode.
 *   Moves message from the Tn inboxes back to the T inbox. Releases the Transaction Servers.
 *   Executes the Move message SP to redistribute the messages agsin
 *
 * RETURNS:
 * NONE
 * 
 * PARAMETERS:
 * @iActiveTransCount = Count of Active (Flag = 1 and Flag <> 4) transaction servers
 * @iForceReset = Do not check the last time the messages were redistributed. Just do it.
 * 
 * Change Log: 
 * DWG 05/01/2013 PTS 61250 - Created
 *
 **/

/*
 Flags:
	See TM_Transaction_Distribute_Messages
*/
BEGIN

DECLARE @iTran0SN int,
		@iTran0InboxSN int,
		@dteProcessStartTime datetime,
		@iTimedOut int,
		@iTransactionSeverCodeImplemented int,
		@iRedistributeMsgMinInterval int

	--
	-- SUPPORT LOOK HERE!!
	--
	-- if the TotalMail Transaction and Delivery have not been updated to support the new
	--  balancing then set this to 0. When the user upgrades the setting will go back to 1
	SET @iTransactionSeverCodeImplemented = 1

	if ISNULL(@iForceReset, 0) = 0 
	BEGIN
		--We do not want to keep resetting. Make sure we have not done it in the last 10 min
		if NOT EXISTS (SELECT NULL FROM tblRS WHERE keyCode = 'LstMsgRedt')
			INSERT INTO tblRS (keyCode, [text], [description], [static])
				VALUES ('LstMsgRedt', GETDATE(), 'Last time the Transaction Inbox messages where redistributed', 1)
		else
			BEGIN
				SELECT @iRedistributeMsgMinInterval = CONVERT(int, ISNULL(Text, 0)) FROM tblRS WHERE keyCode = 'TrnRdstInt'
				if @iRedistributeMsgMinInterval = 0 SET @iRedistributeMsgMinInterval = 10 --Default to 10 minutes

				IF DATEDIFF(MINUTE, (SELECT CONVERT(DATETIME, text) FROM tblRS WHERE keyCode = 'LstMsgRedt'), getdate()) < @iRedistributeMsgMinInterval
					BEGIN --We reset in the last 10 min, will not do it now.
						EXEC TM_Transaction_Move_Messages @iActiveTransCount
						RETURN 
					END
			END
	END

	UPDATE tblRS SET text = GETDATE() WHERE keyCode = 'LstMsgRedt'

	--Get Transaction Agent 0 Inbox SN
	SELECT	@iTran0SN = SN, 
			@iTran0InboxSN = Inbox 
		FROM tblServer 
		WHERE ServerCode = 'T'

	--Set Active Transaction Server to reset
	UPDATE tblServer 
		SET Flags = CASE WHEN (ISNULL(FLAGS, 0) & 4) = 0 THEN ISNULL(Flags, 0) ^ 4 ELSE ISNULL(FLAGS, 0) END
		WHERE LEFT(ServerCode, 1) = 'T' 
			AND (ISNULL(Flags, 0) & 1) > 0

	--Remove any Transaction Servers that are in Startup mode
	UPDATE tblServer 
		SET Flags = CASE WHEN (ISNULL(FLAGS, 0) & 8) > 0 THEN ISNULL(FLAGS, 0) ^ 8 ELSE ISNULL(FLAGS, 0) END
		WHERE LEFT(ServerCode, 1) = 'T' 
			AND (ISNULL(Flags, 0) & 1) > 0

	if @iTransactionSeverCodeImplemented = 1 
		BEGIN
			SET @iTimedOut = 1
		
			--Transaction will add Flag 8 (Startup) when it has reset
			-- Flag 4 and 8 means the server has reset and is waiting
			WHILE DATEDIFF(MINUTE, @dteProcessStartTime, GETDATE()) < 2
				BEGIN
					IF (SELECT COUNT(*) 
						FROM tblServer 
						WHERE LEFT(ServerCode, 1) = 'T' 
								AND (ISNULL(Flags, 0) & 4) > 0 
								AND (ISNULL(Flags, 0) & 8) = 0) = 0 
					BEGIN
						SET @iTimedOut = 0
						BREAK
					END
					
				END
		END	
	ELSE
		BEGIN
			SET @iTimedOut = 0

			--Wait 30 seconds for the Trnsaction agents to clear
			SET @dteProcessStartTime = GETDATE()
			WHILE 1=1
			BEGIN
				IF DATEDIFF(SECOND, @dteProcessStartTime, GETDATE()) > 30
					BREAK
			END
		END

	--Set Active Transaction Server Processed Truck list to NULL (Includes Exclusive Servers)
	IF @iTimedOut = 0 --If we did not time out reset the Truck list
		BEGIN
			--move all Transaction Server message back to the main inbox
			UPDATE tblMessages 
				SET Folder = @iTran0InboxSN
				WHERE Folder IN (SELECT Inbox 
									FROM tblServer
									WHERE LEFT(ServerCode, 1) = 'T' 
											AND ServerCode <> 'T')

			UPDATE tblServer 
				SET [Data] = NULL
				WHERE LEFT(ServerCode, 1) = 'T' 
					AND (ISNULL(Flags, 0) & 1) > 0
		END
	
	--Set the Active Transaction Servers back to normal processing		
	UPDATE tblServer 
		SET Flags = 1
		WHERE LEFT(ServerCode, 1) = 'T' 
			AND (ISNULL(Flags, 0) & 1) > 0
			AND (ISNULL(Flags, 0) & 32) = 0  --do not reset Transaction Servers that are shutting down

	--Move the Messages back into the Transaction Agent inboxes	
	EXEC TM_Transaction_Move_Messages @iActiveTransCount

END

GO
GRANT EXECUTE ON  [dbo].[TM_Transaction_ReDistribute_Messages] TO [public]
GO
