SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MsgBal_Cleanup]  @TimeOut INT, 
                                            @AdminInbox INT, 
                                            @AgentBackLog INT,
                                            @AgentWorking INT
/*******************************************************************************************************************  
  Object Description:
    Cleans up Message balancing tables if a agent is killed.  
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/02/27   W. Riley Wolfe    PTS98345     init 
  2016/03/21   W. Riley Wolfe    PTS96634     Ajustments for Exclusive agents 
  2016/06/28   W. Riley Wolfe    PTS101538    minor cleanup of locking and format
********************************************************************************************************************/
AS
SET NOCOUNT ON;
DECLARE @TimedOutMsgs TABLE (MsgSN INT);
DECLARE @iCur INT,
	      @iNext INT;

INSERT INTO @TimedOutMsgs
SELECT MsgSN
FROM tblMsgCheckout cko WITH (NOLOCK)
JOIN tblMessages msg WITH (NOLOCK) ON cko.MsgSN = msg.SN
WHERE DATEDIFF(SECOND, Assigned, GetDate()) > @TimeOut
	AND Folder = @AgentWorking;

--Remove Old Stuff
DELETE tblServer
WHERE ServerCode = 'TMUL'
	AND DATEDIFF(SECOND, LastPoll, GetDate()) > @TimeOut; --remove old Xacts

UPDATE tblTranTaskList
SET StartTime = NULL,
	Agent = NULL
WHERE Agent NOT IN (
		SELECT AgentID
		FROM tblServer(NOLOCK)
		WHERE ServerCode = 'TMUL'
		); --Remove tasks that don't have an Xact


BEGIN TRAN

UPDATE tblMessages
SET Folder = @AdminInbox
WHERE sn IN (
		SELECT MsgSN
		FROM @TimedOutMsgs
		);

SELECT TOP 1 @iCur = MsgSN
FROM @TimedOutMsgs
WHERE MsgSN > 0
ORDER BY MsgSN;

WHILE isnull(@iCur, 0) > 0 --looping, applying error message to all those that timed out
BEGIN
	SET @iNext = 0;

	EXEC tm_AddErrorToMessage 
    @iCur,
		0,
		'Transaction Agent Timeout, Message Failed.  If you believe this failure is in error, you may choose to change the Timeout in Delivery Agent’s Message Balancing Tab.  ',
		'TMXact.clsTMXact',
		0;

	SELECT TOP 1 @iNext = MsgSN
	FROM @TimedOutMsgs
	WHERE MsgSN > @iCur
		AND MsgSN > 0
	ORDER BY MsgSN;

	SET @iCur = @iNext;
END

DELETE tblMsgCheckout
WHERE MsgSN IN (
		SELECT MsgSN
		FROM @TimedOutMsgs
		);

COMMIT TRAN


--collect stats on how busy totalmail is for Message Balancing
SELECT (SELECT Count(SN) FROM tblMessages(NOLOCK) WHERE Folder = @AgentBackLog) AS BackLogedCount, 
(SELECT count(ServerCode) FROM tblServer (NOLOCK) WHERE ServerCode = 'TMUL') AS AgentCount, 
(SELECT count(SN) FROM tblTranTaskList (NOLOCK)) AS TaskCount;

GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_Cleanup] TO [public]
GO
