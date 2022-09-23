SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_MsgBal_ReadyTransactionMsgs] @QueryFolder INT
	/*
NAME:
dbo.tm_MsgBal_ReadyTransactionMsgs

TYPE:
Stored Procedure

DESCRIPTION:
Selects the next Message for prossessing
Used by Transaction Agent

Prams:
@AgentID: Transaction Agent ID 
@QueryFolder: Inbox for messages to prossess
@MSGSN: message we got

Change Log: 
rwolfe	2016/02/22  PTS98345	init 

*/
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select SN, FromName, FromType, DeliverTo, DeliverToType --, ToDrvSN, ToTrcSN, FromDrvSN, FromTrcSN
 from tblmessages
 where Folder = 371
 and isnull(DeliveryKey,0) & 32 = 0
 Order by DTSent, DTReceived

GO
GRANT EXECUTE ON  [dbo].[tm_MsgBal_ReadyTransactionMsgs] TO [public]
GO
