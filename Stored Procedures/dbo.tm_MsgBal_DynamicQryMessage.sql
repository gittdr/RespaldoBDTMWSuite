SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MsgBal_DynamicQryMessage]  @AgentID UNIQUEIDENTIFIER,
                                                      @QueryFolder INT,
                                                      @OutFolder INT,
                                                      @MyMSGCode INT
/*******************************************************************************************************************  
  Object Description:
    Selects the next Message for prossessing
    This version only Selects Exclusive Agent Resources
    Used by Transaction Agent

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/03/21   W. Riley Wolfe    PTS98345     init 
  2016/06/28   W. Riley Wolfe    PTS101538    minor cleanup of locking and format
********************************************************************************************************************/
AS
SET NOCOUNT ON;

DECLARE @getLock INT,
	@frmDRV INT,
	@toDRV INT,
	@frmTRC INT,
	@toTRC INT,
	@RealTRC INT = NULL,
	@RealDRV INT = NULL,
	@DlyTo VARCHAR(50) = NULL,
	@DlyType INT,
	@TempMSGSN INT;

EXEC dbo.tm_MsgBal_CompleteQry @AgentID;
Update tblMsgCheckout set Assigned = GETDATE() where MsgSN = @MyMSGCode; --safe because there is no functional change, just keeps it alive

BEGIN TRAN

SELECT TOP 1 @getLock = sn
FROM tblMsgCheckout WITH (
		TABLOCKX /*  <--MsgBal Querrys CANNOT run at the same time */
		,
		HOLDLOCK
		);

SELECT TOP 1 @TempMSGSN = msgs.SN,
	@frmDRV = msgs.FromDrvSN,
	@toDRV = msgs.ToDrvSN,
	@frmTRC = msgs.FromTrcSN,
	@toTRC = msgs.ToTrcSN,
	@DlyTo = msgs.DeliverTo, --don't know if it is outbound or inbound, check both to and from, one will be null
	@DlyType = msgs.DeliverToType
FROM tblMessages msgs (NOLOCK)
WHERE 
  msgs.Folder = @QueryFolder
  AND msgs.DeliveryKey & 32 = 32
	AND NOT COALESCE(msgs.ToDrvSN, 0) IN (
		SELECT DriverSN
		FROM tblMsgCheckout
		WHERE DriverSN IS NOT NULL
      AND MsgSN > 0
		) 
	AND NOT COALESCE(msgs.FromDrvSN, 0) IN (
		SELECT DriverSN
		FROM tblMsgCheckout
		WHERE DriverSN IS NOT NULL
      AND MsgSN > 0
		) 
	AND NOT COALESCE(msgs.ToTrcSN, 0) IN (
		SELECT TruckSN
		FROM tblMsgCheckout
		WHERE TruckSN IS NOT NULL
      AND MsgSN > 0
		) 
	AND NOT COALESCE(msgs.FromTrcSN, 0) IN (
		SELECT TruckSN
		FROM tblMsgCheckout
		WHERE TruckSN IS NOT NULL
      AND MsgSN > 0
		) 
	AND (
		(msgs.DeliverToType < 6
		OR NOT COALESCE(DeliverTo, '') IN (
			SELECT UnitID
			FROM tblMsgCheckout
			WHERE UnitID IS NOT NULL
        AND MsgSN > 0
			))
      OR
    (msgs.FromType < 6
		OR NOT COALESCE(FromType, '') IN (
			SELECT UnitID
			FROM tblMsgCheckout
			WHERE UnitID IS NOT NULL
        AND MsgSN > 0
			))
		)
  --exclisive part
  AND (
    COALESCE(msgs.ToDrvSN, 0) IN (
		SELECT DriverSN
		FROM tblMsgCheckout
		WHERE DriverSN IS NOT NULL
      AND MsgSN = @MyMSGCode
		) 
	OR COALESCE(msgs.FromDrvSN, 0) IN (
		SELECT DriverSN
		FROM tblMsgCheckout
		WHERE DriverSN IS NOT NULL
      AND MsgSN = @MyMSGCode
		) 
	OR COALESCE(msgs.ToTrcSN, 0) IN (
		SELECT TruckSN
		FROM tblMsgCheckout
		WHERE TruckSN IS NOT NULL
      AND MsgSN = @MyMSGCode
		) 
	OR COALESCE(msgs.FromTrcSN, 0) IN (
		SELECT TruckSN
		FROM tblMsgCheckout
		WHERE TruckSN IS NOT NULL
      AND MsgSN = @MyMSGCode
		) 
	OR (
		(msgs.DeliverToType = 6
		AND NOT COALESCE(DeliverTo, '') IN (
			SELECT UnitID
			FROM tblMsgCheckout
			WHERE UnitID IS NOT NULL
        AND MsgSN = @MyMSGCode
			))
      OR
    (msgs.FromType = 6
		AND NOT COALESCE(FromType, '') IN (
			SELECT UnitID
			FROM tblMsgCheckout
			WHERE UnitID IS NOT NULL
        AND MsgSN = @MyMSGCode
			))
		)
  )
  ORDER BY DTSent ASC, SN ASC;

if COALESCE(@TempMSGSN, 0) = 0 --No oustanding messages
Begin
  COMMIT TRAN
  return;
END

SET @RealDRV = COALESCE(@toDRV, @frmDRV);
SET @RealTRC = COALESCE(@toTRC, @frmTRC);

IF @DlyType < 6
BEGIN
	SET @DlyTo = NULL;
END

INSERT INTO tblMsgCheckout (
	Agent,
	DriverSN,
	TruckSN,
	UnitID,
	MsgSN
	)
VALUES (
	@AgentID,
	@RealDRV,
	@RealTRC,
	@DlyTo,
	@TempMSGSN
	);
 
IF COALESCE(@TempMSGSN, 0) > 0
BEGIN
  UPDATE tblMessages
  SET Folder = @OutFolder
  WHERE SN = @TempMSGSN;
END

COMMIT TRAN

IF COALESCE(@TempMSGSN, 0) > 0
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
	WHERE SN = @TempMSGSN;
END


GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_DynamicQryMessage] TO [public]
GO
