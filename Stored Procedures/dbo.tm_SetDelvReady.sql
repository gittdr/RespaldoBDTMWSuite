SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_SetDelvReady] @MsgSN INT

	/*
NAME:
dbo.tm_SetDelvReady

TYPE:
Stored Procedure

DESCRIPTION:
Note that there are no Drv/Trc Resources for a message

Prams:
@MSGSN: message to Stamp

Change Log: 
2016/03/9 rwolfe: PTS98345	init

*/
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

UPDATE tblMessages set DeliveryKey = isnull(DeliveryKey, 0) | 32 where SN = @MsgSN

GO
GRANT EXECUTE ON  [dbo].[tm_SetDelvReady] TO [public]
GO
