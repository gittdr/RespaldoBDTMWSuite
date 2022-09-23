SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_FormNumberValue]
	@MessagesN int, 
	@FormMsgPropertySN int 
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_FormNumberValue]
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
 * 001 - @MessageSN int 
 * 002 - @FormMsgPropertySN int
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_FormNumberValue]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT [Value] 
FROM tblMsgProperties(NoLock)  
WHERE MsgSN = @MessageSN
AND PropSN = @FormMsgPropertySN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_FormNumberValue] TO [public]
GO
