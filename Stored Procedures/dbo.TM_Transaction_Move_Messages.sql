SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TM_Transaction_Move_Messages]
	@iActiveTransCount int
AS 


/**
 * 
 * NAME:
 * dbo.TM_Transaction_Distribute_Messages
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Used for Message Balancing. Moves the messages from the T Inbox 
 *   and balances them through the other Tn inboxes
 *
 * RETURNS:
 * NONE
 * 
 * PARAMETERS:
 * @iActiveTransCount = Count of Active (Flag = 1 and Flag <> 4) transaction servers
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
	DECLARE @iTranSN int,
			@iTranInboxSN int,
			@iTran0SN int,
			@iTran0InboxSN int,
			@iCurrentMsgSN int,
			@iTransactionAgentToMoveTo int,
			@iTruckSN int,
			@iDriverSN int,
			@sSNToUse VARCHAR(15),
			@sServerCodeToUse VARCHAR(2),
			@sServerCodeToUseExclusive VARCHAR(2),
			@iFoundTransForSN int,
			@iFirstActiveTransAgent int,
			@dteProcessStartTime datetime,
			@iFromType int,
			@sFromName varchar(max),
			@iDeliverToType int,
			@sDeliverTo varchar(max)
	
	DECLARE @FolderMsgCount TABLE (Folder int, [Count] int)

	--All Active Transaction Agents are being reset - get out
	IF EXISTS (SELECT NULL FROM tblServer WHERE LEFT(ServerCode, 1) = 'T' AND (Flags & 1 > 0))
		IF NOT EXISTS (SELECT NULL FROM tblServer WHERE LEFT(ServerCode, 1) = 'T' AND (Flags & 1 > 0) AND (Flags & 4 = 0) AND (Flags & 8 = 0))
			RETURN
		
	SET @iTransactionAgentToMoveTo = -1
	
	--Get Transaction Agent 0 Inbox SN
	SELECT	@iTran0SN = SN, 
			@iTran0InboxSN = Inbox 
		FROM tblServer 
		WHERE ServerCode = 'T'

	SET @dteProcessStartTime = GETDATE()
	
	--Walk through Each Message in the Transaction Agent 0 (zero) Inbox
	SELECT @iCurrentMsgSN = MIN(SN) 
		FROM tblMessages 
		WHERE Folder = @iTran0InboxSN
	
	WHILE ISNULL(@iCurrentMsgSN, 0) > 0
	BEGIN
		SET @iTransactionAgentToMoveTo = 0

		--Get the first transaction agent that is active and not being reset
		SELECT @iFirstActiveTransAgent = CONVERT(int, SUBSTRING(ServerCode, 2, 10)) 
			FROM tblServer 
			WHERE ServerCode = (SELECT MIN(ServerCode) 
									FROM tblServer 
									WHERE LEFT(ServerCode, 1) = 'T' 
										AND Flags & 1 > 0  --Did not add flags 4 and 8 here because we still need the first agent
										AND ISNULL([Data2], '') = '') --Do not include Exclusive Transaction Servers
		
		--if non are active then assume Transaction agent 1 - have to have one
		IF ISNULL(@iFirstActiveTransAgent , 0) = 0 SET @iFirstActiveTransAgent = 1
		
		SET @sSNToUse = NULL
		SET @sServerCodeToUse = ''
		
		--Determine the SN to use for the list: FromTrcSN->ToTrcSN->HistTrk	
		SELECT @iTruckSN = ISNULL(HistTrk, ISNULL(ToTrcSN, FromTrcSN)) 
			FROM tblMessages 
			WHERE SN = @iCurrentMsgSN 
		IF ISNULL(@iTruckSN, 0) > 0 
			SET @sSNToUse = 'T' + CONVERT(varchar(12), @iTruckSN)
		ELSE
			BEGIN
				--See if the From Type is from the Truck
				--Determine the SN to use for the list: FromTrcSN->ToTrcSN->HistTrk	
				SELECT @sFromName = ISNULL(FromName, ''), @iFromType = ISNULL(FromType, ''),
						@sDeliverTo = ISNULL(DeliverTo, ''), @iDeliverToType = ISNULL(DeliverToType, '')
					FROM tblMessages 
					WHERE SN = @iCurrentMsgSN 
			
				if @iFromType = 4 or @iDeliverToType = 4 --Truck
					BEGIN
						IF @iFromType = 4
							SELECT @sSNToUse = 'T' + CONVERT(VARCHAR(12), SN) From tblTrucks WHERE TruckName = @sFromName 
						ELSE IF @iDeliverToType = 4
							SELECT @sSNToUse = 'T' + CONVERT(VARCHAR(12), SN) From tblTrucks WHERE TruckName = @sDeliverTo 
					END
				else
					--OK, no Truck, see if we have a Driver
					BEGIN
					--Determine the SN to use for the list: FromDrvSN->FromDrvSN->HistDrv
						SELECT @iDriverSN = ISNULL(HistDrv, ISNULL(ToDrvSN, FromDrvSN))
							FROM tblMessages 
							WHERE SN = @iCurrentMsgSN 
						IF ISNULL(@iDriverSN, 0) > 0 
							SET @sSNToUse = 'D' + CONVERT(varchar(12), @iDriverSN)
						ELSE
							BEGIN
								IF @iFromType = 5 --Driver
									SELECT @sSNToUse = 'D' + CONVERT(VARCHAR(12), SN) From tblDrivers WHERE Name = @sFromName 
								ELSE IF @iDeliverToType = 5 --Driver
									SELECT @sSNToUse = 'D' + CONVERT(VARCHAR(12), SN) From tblDrivers WHERE Name = @sDeliverTo 
							END
					END
			END			

		--If no SN to use then use Transaction Agent 1
		IF ISNULL(@sSNToUse, '') = ''
			BEGIN
				IF ISNULL(@sFromName, '') <> ''
					SELECT @sSNToUse = 'U' + @sFromName 
				ELSE IF ISNULL(@sDeliverTo, '') <> ''
					SELECT @sSNToUse = 'U' + @sDeliverTo 
			END

		SET @iFoundTransForSN = 0

		--If no SN to use then use Transaction Agent 1
		IF ISNULL(@sSNToUse, '') = ''
			--we could not determine the Truck or Driver for the message, all unknown resource messages go to Transaction 1
			SET @iTransactionAgentToMoveTo = @iFirstActiveTransAgent
		ELSE
			--See if the Truck is in one of the Transaction Agents list
			SELECT @sServerCodeToUse = ISNULL(MIN(ServerCode), '') 
				FROM tblServer 
				WHERE LEFT(ServerCode, 1) = 'T' 
					AND Flags & 1 > 0 
					AND (CHARINDEX(',' + @sSNToUse + ',', ',' + [Data] + ',') > 0)

			IF ISNULL(@sServerCodeToUse, '') = ''
				--See if the Truck is in one of the Exclusive Transaction Agents list
				SELECT @sServerCodeToUseExclusive = ISNULL(MIN(ServerCode), '') 
					FROM tblServer 
					WHERE LEFT(ServerCode, 1) = 'T' 
						AND Flags & 1 > 0 
						AND (CHARINDEX(',' + @sSNToUse + ',', ',' + [Data2] + ',') > 0) --If the SN is in the Exclusive list

			--If we found a Transaction Agent proceessing this resource SN
			IF ISNULL(@sServerCodeToUse, '') <> ''
				BEGIN
					SET @iFoundTransForSN = 1
					IF DATALENGTH (@sServerCodeToUse) = 1  --if the server code is T (not a valid server) then use the first active one
						SET @iTransactionAgentToMoveTo = @iFirstActiveTransAgent
					ELSE --Use the server it found
						SET @iTransactionAgentToMoveTo = CONVERT(int, SUBSTRING(@sServerCodeToUse, 2, 10))
				END

			ELSE IF ISNULL(@sServerCodeToUseExclusive , '') <> ''
				BEGIN
					IF DATALENGTH (@sServerCodeToUseExclusive) = 1  --if the server code is T (not a valid server) then use the first active one
						SET @iTransactionAgentToMoveTo = @iFirstActiveTransAgent
					ELSE --Use the server it found
						SET @iTransactionAgentToMoveTo = CONVERT(int, SUBSTRING(@sServerCodeToUseExclusive, 2, 10))
				END
			
			ELSE --SN is not assigned to any Transaction agent
				BEGIN
					--This section finds the Transaction agent with the no messages or the least amount of meessages 
					--  When found we add the Truck to that Transaction agent
					DELETE @FolderMsgCount --Clear the old message counts
					--Get the count for all non-exclusive active and non-reset Transaction Servers
					INSERT INTO @FolderMsgCount 
						SELECT Folder, COUNT(*) [Count]
							FROM tblMessages 
							WHERE Folder in 
								(SELECT inbox 
									FROM tblServer 
									WHERE LEFT(ServerCode, 1) = 'T' 
										AND Flags & 1 > 0
										AND Flags & 4 = 0
										AND Flags & 8 = 0
										AND ISNULL([Data2], '') = '')
							GROUP BY Folder 

					-- If no transaction agents have messages then use first active Transaction Agent
					IF (SELECT COUNT(*) FROM @FolderMsgCount) = 0
						SELECT @iTransactionAgentToMoveTo = CONVERT(int, SUBSTRING(ServerCode, 2, 10)) 
							FROM tblServer 
							WHERE ServerCode = (SELECT MIN(ServerCode) 
									FROM tblServer 
									WHERE LEFT(ServerCode, 1) = 'T' 
										AND Flags & 1 > 0 
										AND Flags & 4 = 0 
										AND Flags & 8 = 0
										AND ISNULL([Data2], '') = '')
					ELSE
						BEGIN
							--See if any active transaction Agents have no messages
							SELECT @iTranSN = MIN(SN) 
								FROM tblServer 
								WHERE LEFT(ServerCode, 1) = 'T'
									AND Flags & 1 > 0
									AND Flags & 4 = 0
									AND Flags & 8 = 0
									AND ISNULL([Data2], '') = ''
									AND NOT EXISTS (SELECT NULL 
														FROM @FolderMsgCount 
														WHERE Folder = tblServer.InBox)
							
							--If none of the Active Transaction Servers have no messages
							IF ISNULL(@iTranSN, 0) = 0
								--Find the Transaction Agent with the least messages
								SELECT @iTranSN = (SELECT SN 
													FROM tblServer 
													WHERE InBox = (SELECT MIN(Folder)
																		FROM @FolderMsgCount
																		WHERE [COUNT] = (SELECT MIN(Count) 
																							FROM @FolderMsgCount)))

							IF ISNULL(@iTranSN, 0) = 0 --Should never happen, but...
								SELECT @iTransactionAgentToMoveTo = CONVERT(int, SUBSTRING(ServerCode, 2, 10)) 
									FROM tblServer 
									WHERE ServerCode = (SELECT MIN(ServerCode) 
											FROM tblServer 
											WHERE LEFT(ServerCode, 1) = 'T' 
												AND Flags & 1 > 0 
												AND Flags & 4 = 0 
												AND Flags & 8 = 0
												AND ISNULL([Data2], '') = '')
							ELSE
								BEGIN
									--Get the Server Code (T, T1, T2, ...)
									SELECT @sServerCodeToUse = ISNULL(ServerCode, '') 
										FROM tblServer 
										WHERE SN = @iTranSN 
								
									IF DATALENGTH (@sServerCodeToUse) = 1 --if the server code is T (not a valid server) then use the first active one
										SELECT @iTransactionAgentToMoveTo = CONVERT(int, SUBSTRING(ServerCode, 2, 10)) 
											FROM tblServer 
											WHERE ServerCode = (SELECT MIN(ServerCode) 
													FROM tblServer 
													WHERE LEFT(ServerCode, 1) = 'T' 
														AND Flags & 1 > 0 
														AND Flags & 4 = 0 
														AND Flags & 8 = 0
														AND ISNULL([Data2], '') = '')
									
									ELSE --Use the server it found
										SET @iTransactionAgentToMoveTo = CONVERT(int, SUBSTRING(@sServerCodeToUse, 2, 10))
										
								END
						END
				END

		--if something went very wrong error, there is a lot of code above to try to make sure this does not happen
		IF ISNULL(@iTransactionAgentToMoveTo, 0) < 1
			BEGIN
			RAISERROR('Unable to determine Transaction Agent to move message to. Contact TMW TotalMail Support', 16, 1)
			SELECT -1 TrnsactionAgentNumber
			RETURN -1
			END
		ELSE --Update the Message
			BEGIN
				--Get the Transaction Servers Inbox that will be processing the Trucks Messages
				SELECT @iTranInboxSN = Inbox, @iTranSN = SN 
					FROM tblServer 
					WHERE ServerCode = 'T' + CONVERT(varchar(12), @iTransactionAgentToMoveTo)

				--Again should not happen, but...								
				IF ISNULL(@iTranInboxSN, 0) = 0
					BEGIN
					RAISERROR('Unable to find Transaction Agent %d. Contact TMW TotalMail Support', 16, 1, @iTransactionAgentToMoveTo)
					SELECT -1 TrnsactionAgentNumber
					RETURN -1
					END
				ELSE
					BEGIN

						--if we have more than 1 active transaction agent and the SN is not already in the list, add it						
						IF @iActiveTransCount > 1 AND @iFoundTransForSN = 0  
							UPDATE tblServer 
								SET [Data] = CASE WHEN ISNULL([Data], '') = '' THEN ',' ELSE [Data] END + @sSNToUse + ',' 
								WHERE SN = @iTranSN

						--If the Transacton Agent is in Reset Mode then do not put the Message in the Inbox											
						IF EXISTS (SELECT NULL FROM tblServer WHERE SN = @iTranSN AND Flags & 4 = 0)
							UPDATE tblMessages 
								SET Folder = @iTranInboxSN 
								WHERE SN = @iCurrentMsgSN
					END
			END
		
		--If we have been processing for more than 2 minuetes then get out, we need to see if we need to redistribute
		if DATEDIFF(MINUTE, @dteProcessStartTime, GETDATE()) > 1
			BREAK
						
		--Get the next message to process
		SELECT @iCurrentMsgSN = MIN(SN) 
			FROM tblMessages 
			WHERE Folder = @iTran0InboxSN 
				AND SN > @iCurrentMsgSN

	END
		
END

GO
GRANT EXECUTE ON  [dbo].[TM_Transaction_Move_Messages] TO [public]
GO
