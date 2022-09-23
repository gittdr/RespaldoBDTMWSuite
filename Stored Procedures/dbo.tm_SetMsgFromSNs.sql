SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_SetMsgFromSNs] @MsgSN INT,
	@TruckSN INT,
	@DriverSN INT 
	/*
NAME:
dbo.tm_SetMsgToSNs

TYPE:
Stored Procedure

DESCRIPTION:
Stamps From Driver and From Truck for a message


Prams:
@TruckSN: Truck Resource
@DriverSN: Driver Resource
@MSGSN: message to stamp

Change Log: 
2016/02/23  rwolfe  PTS98345	init
*/
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

if @TruckSN = 0 
BEGIN
  set @TruckSN = NULL
END

if @DriverSN = 0 
BEGIN
  set @DriverSN = NULL
END

UPDATE tblMessages set FromDrvSN = @DriverSN, FromTrcSN = @TruckSN, DeliveryKey = isnull(DeliveryKey, 0) | 32 where SN = @MsgSN

GO
GRANT EXECUTE ON  [dbo].[tm_SetMsgFromSNs] TO [public]
GO
