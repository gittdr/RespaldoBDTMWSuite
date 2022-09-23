SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MsgBal_GetWork] @AgentID VARCHAR(36), 
                                           @BackLogInbox INT,
                                           @WorkingFolder INT, 
                                           @Flags INT
/*******************************************************************************************************************  
  Object Description:
    Selects the next Task/Message for prossessing
    Used by Transaction Agent

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/01/19   W. Riley Wolfe    PTS98345     init 
  2016/06/28   W. Riley Wolfe    PTS96634     added support for Inbound/Outbound only agents
  2016/06/28   W. Riley Wolfe    PTS101538    minor cleanup of locking and format
********************************************************************************************************************/
AS
SET NOCOUNT ON;

DECLARE @msgSN INT,
	@myID UNIQUEIDENTIFIER,
	@Tasked INT;

SET @myID = CAST(@AgentID AS UNIQUEIDENTIFIER);

EXEC dbo.tm_MsgBal_CompleteQry @myID;

IF @Flags = 0
BEGIN
	EXEC dbo.tm_MsgBal_QryTask @myID,
		@Tasked OUTPUT;

	IF COALESCE(@Tasked, 0) = 1
	BEGIN
		RETURN;
	END

	EXEC dbo.tm_MsgBal_QryMessage @myID,
		@BackLogInbox,
		@WorkingFolder,
		@msgSN OUTPUT,
		@Tasked OUTPUT;
END
ELSE IF @Flags = 1 --Outbound only
BEGIN
	EXEC dbo.tm_MsgBal_OutOnly_QryMessage @myID,
		@BackLogInbox,
		@WorkingFolder,
		@msgSN OUTPUT,
		@Tasked OUTPUT;
END
ELSE IF @Flags = 2 --Inbound only
BEGIN
	EXEC dbo.tm_MsgBal_InOnlyQryMessage @myID,
		@BackLogInbox,
		@WorkingFolder,
		@msgSN OUTPUT,
		@Tasked OUTPUT;
END



IF COALESCE(@msgSN, 0) > 0
BEGIN
	SELECT SN,
		[Subject],
		DeliverTo,
		DeliverToType,
		FromName,
		FromType,
		ResubmitOf,
		DTSent,
		DTReceived,
		VehicleIgnition,
		Position,
		PositionZip,
		NLCPosition,
		NLCPositionZip,
		Latitude,
		Longitude,
		COALESCE(DTPosition, '1/1/1950') DTPosition,
		Odometer,
		Type,
		SpecialMsgSN,
		CONVERT(VARCHAR(30), GETDATE(), 121) AS sGetDate,
		Priority,
		ReplyMsgSN,
		ReplyMsgPage,
		OrigMsgSN,
		BaseSN,
		DeliveryKey,
		'MSG' AS Task
	FROM tblMessages(NOLOCK)
	WHERE SN = @msgSN;
END


GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_GetWork] TO [public]
GO
