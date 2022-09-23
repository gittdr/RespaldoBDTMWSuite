SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_NewMessageDisplay]
	@NewMessageSN int
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_NewMessageDisplay]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls FromName, FromType, DeliverTo, DeliverToType, Subject,DTReceived, Folder, OrigMsgSN, ReplyMsgSN 
 * values base on a SN
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * FromName, FromType, DeliverTo, DeliverToType, Subject,DTReceived, Folder, OrigMsgSN, ReplyMsgSN  fields
 *
 * PARAMETERS:
 * 001 - @NewMessageSN int
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_NewMessageDisplay]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT FromName, FromType, DeliverTo, DeliverToType, Subject, DTReceived, Folder, OrigMsgSN, 
ReplyMsgSN, Contents
FROM dbo.tblMessages 
WHERE SN = @NewMessageSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_NewMessageDisplay] TO [public]
GO
