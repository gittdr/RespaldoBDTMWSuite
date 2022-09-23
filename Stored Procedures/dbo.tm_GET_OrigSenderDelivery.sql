SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_OrigSenderDelivery]
	@NewMessageSN int

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_OrigSenderDelivery]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls PropSN, FldType and TypeName value base on a EntryType and PropSN
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * PropSN, FldType and TypeName fields
 *
 * PARAMETERS:
 * 001 - @NewMessageSN int
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_OrigSenderDelivery]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT FromName, FromType, DeliverTo, DeliverToType, [Subject], DTReceived, Folder, OrigMsgSN, ReplyMsgSN 
FROM tblMessages(NoLock) 
WHERE SN = @NewMessageSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_OrigSenderDelivery] TO [public]
GO
