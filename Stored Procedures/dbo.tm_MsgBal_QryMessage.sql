SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MsgBal_QryMessage] @AgentID UNIQUEIDENTIFIER,
	                                            @QueryFolder INT,
                                              @OutFolder INT,
	                                            @MSGSN INT OUTPUT,
	                                            @CheckOutSN INT OUTPUT
/*******************************************************************************************************************  
  Object Description:
    Selects the next Message for prossessing
    Used by Transaction Agent
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2016/01/27   W. Riley Wolfe    PTS98345     init 
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
  @DlyToType INT,
  @DlyFrom VARCHAR(50) = NULL,
  @DlyFromType INT,
  @TempMSGSN INT;

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
  @DlyToType = msgs.DeliverToType,
  @DlyFrom = msgs.FromName,
  @DlyFromType = msgs.FromType
FROM tblMessages msgs (NOLOCK)
WHERE 
  msgs.Folder = @QueryFolder
  AND msgs.DeliveryKey & 32 = 32
	AND NOT COALESCE(msgs.ToDrvSN, 0) IN (
		SELECT DriverSN
		FROM tblMsgCheckout
		WHERE DriverSN IS NOT NULL
		) 
	AND NOT COALESCE(msgs.FromDrvSN, 0) IN (
		SELECT DriverSN
		FROM tblMsgCheckout
		WHERE DriverSN IS NOT NULL
		) 
	AND NOT COALESCE(msgs.ToTrcSN, 0) IN (
		SELECT TruckSN
		FROM tblMsgCheckout
		WHERE TruckSN IS NOT NULL
		) 
	AND NOT COALESCE(msgs.FromTrcSN, 0) IN (
		SELECT TruckSN
		FROM tblMsgCheckout
		WHERE TruckSN IS NOT NULL
		) 
	AND (
		(msgs.DeliverToType < 6
		OR NOT COALESCE(DeliverTo, '') IN (
			SELECT UnitID
			FROM tblMsgCheckout
			WHERE UnitID IS NOT NULL
			))
      AND
    (msgs.FromType < 6
		OR NOT COALESCE(FromName, '') IN (
			SELECT UnitID
			FROM tblMsgCheckout
			WHERE UnitID IS NOT NULL
			))
		)
  ORDER BY DTSent ASC, SN ASC;

if ISNULL(@TempMSGSN, 0) = 0 --No oustanding messages
Begin
  Commit Tran
  return;
END

SET @RealDRV = COALESCE(@toDRV, @frmDRV);
SET @RealTRC = COALESCE(@toTRC, @frmTRC);

IF @DlyToType = 6 
BEGIN
  SET @DlyFrom = @DlyTo;
  SET @DlyFromType = @DlyToType;
END


IF @DlyFromType <> 6 
BEGIN
	SET @DlyFrom = NULL;
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
	@DlyFrom,
	@TempMSGSN
	);


SELECT @CheckOutSN = SCOPE_IDENTITY();

SET @MSGSN = @TempMSGSN;

UPDATE tblMessages
SET Folder = @OutFolder
WHERE SN = @MSGSN;

COMMIT TRAN


GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_QryMessage] TO [public]
GO
