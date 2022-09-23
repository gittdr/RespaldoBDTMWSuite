SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MsgBal_AgentCheckin] @AgentID varchar(36), @SystemInfo Varchar(1000), @Working INT

/*
NAME:
dbo.tm_MsgBal_AgentCheckin

TYPE:
Stored Procedure

DESCRIPTION:
inserts tblserver records to keep log of active agents

Prams:
@AgentID: Agent Guid
@SystemInfo: System Info of that agent, allows for idetification
@working: If we are a Exclusive Agent, our Groups Identifier, otherwise 0.  

Change Log: 
rwolfe	2016/03/08 PTS98345	init 
rwolfe	2016/03/21 PTS96634	 Added support for Exclusive Agents with Working parm.  
*/
AS
SET NOCOUNT ON

DECLARE @SN INT,
	@uAgentID UNIQUEIDENTIFIER;

SET @uAgentID = CAST(@AgentID AS UNIQUEIDENTIFIER)

SELECT @SN = SN
FROM tblServer
WHERE AgentID = @uAgentID

SET @Working = ISNULL(@Working, 0)

IF Isnull(@SN, 0) = 0
BEGIN
	INSERT INTO tblServer (
		ServerCode,
		LastPoll,
		AgentID,
		Working,
		Data2
		)
	VALUES (
		'TMUL',
		GETDATE(),
		@uAgentID,
		@Working,
		@SystemInfo
		)
END
ELSE
BEGIN
	UPDATE tblServer
	SET LastPoll = GETDATE()
	WHERE AgentID = @uAgentID
END


GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_AgentCheckin] TO [public]
GO
