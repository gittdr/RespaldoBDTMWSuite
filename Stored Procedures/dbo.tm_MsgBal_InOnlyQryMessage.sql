SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MsgBal_InOnlyQryMessage] @AgentID UNIQUEIDENTIFIER,
                                                    @QueryFolder INT,
                                                    @WorkingFolder INT,
                                                    @MSGSN INT OUTPUT,
                                                    @CheckOutSN INT OUTPUT
/*******************************************************************************************************************  
  Object Description:
    Selects the next Message for prossessing
    This version only gets Inbound messages
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
	@DlyFrom = msgs.FromName, --don't know if it is outbound or inbound, check both to and from, one will be null
	@DlyFromType = msgs.FromType
FROM tblMessages msgs (NOLOCK)
WHERE 
  msgs.Folder = @QueryFolder
  AND msgs.DeliveryKey & 32 = 32
	AND COALESCE(msgs.ToDrvSN, 0) = 0	
	AND NOT COALESCE(msgs.FromDrvSN, 0) IN (
		SELECT DriverSN
		FROM tblMsgCheckout
		WHERE DriverSN IS NOT NULL
		)
	AND COALESCE(msgs.ToTrcSN, 0) = 0	
	AND NOT COALESCE(msgs.FromTrcSN, 0) IN (
		SELECT TruckSN
		FROM tblMsgCheckout
		WHERE TruckSN IS NOT NULL
		) --Delivery support for Unit inbounds without a Truck/Driver is broke, and will probly not be fixed
	--AND (
	--	msgs.FromType < 6
	--	OR (
	--		NOT ISNULL(FromType, '') IN (
	--			SELECT UnitID
	--			FROM tblMsgCheckout
	--			WHERE UnitID IS NOT NULL
	--			)
	--		AND ISNULL(DeliverTo, '') = ''
	--		)
	--	)
  ORDER BY DTSent ASC, SN ASC;

if COALESCE(@TempMSGSN, 0) = 0 --No oustanding messages
Begin
  COMMIT TRAN
  RETURN;
END

SET @RealDRV = COALESCE(@toDRV, @frmDRV);
SET @RealTRC = COALESCE(@toTRC, @frmTRC);

--IF @DlyFromType < 6
--BEGIN
--	SET @DlyFrom = NULL
--END

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
	NULL,
	@TempMSGSN
	);


SELECT @CheckOutSN = SCOPE_IDENTITY();

SET @MSGSN = @TempMSGSN;

UPDATE tblMessages
SET Folder = @WorkingFolder
WHERE SN = @MSGSN;

COMMIT TRAN


GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_InOnlyQryMessage] TO [public]
GO
