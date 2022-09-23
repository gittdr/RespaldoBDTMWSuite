SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MsgBal_InsertExclusive] @MsgSNCode INT, @DRV varchar(50), @TRC varchar(50),  @Unit Varchar(50)
	/*
NAME:
dbo.tm_MsgBal_InsertExclusive

TYPE:
Stored Procedure

DESCRIPTION:
Setsup Exclusive List for a Exclusive Transaction Agent

Prams:
@MsgSNCode: Transaction Agent Exclusive List ID
@DRV: Driver on the list
@TRC: Truck on the list
@Unit: Unit on the List

Change Log: 
rwolfe	2016/03/21  PTS96634	init 

*/
AS
SET NOCOUNT ON

BEGIN TRAN

IF isnull(@MsgSNCode, 0) = 0
BEGIN
	SELECT @MsgSNCode = isnull(Min(MsgSN), 0)
	FROM tblMsgCheckout WITH (TABLOCKX, HOLDLOCK) --hold everything until insert, otherwise we will have race conditions

  IF @MsgSNCode > 0
  BEGIN
    SET @MsgSNCode = 0
  END

	SET @MsgSNCode -= 1
END

IF @TRC = 0
BEGIN
	SET @TRC = NULL
END

IF @DRV = 0
BEGIN
	SET @DRV = NULL
END

IF @Unit = ''
BEGIN
	SET @Unit = NULL
END


INSERT INTO tblMsgCheckout (
	Agent,
	DriverSN,
	TruckSN,
	UnitID,
	MsgSN
	)
VALUES (
	NEWID(),
	@DRV,
	@TRC,
	@Unit,
	@MsgSNCode
	)

COMMIT TRAN

SELECT @MsgSNCode


GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_InsertExclusive] TO [public]
GO
