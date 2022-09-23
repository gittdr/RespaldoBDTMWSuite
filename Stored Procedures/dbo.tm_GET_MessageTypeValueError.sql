SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_MessageTypeValueError]
	@MessageSN int, 
	@PropertyTypeFormSN int 

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_MessageTypeValueError]
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
 * 002 - @PropertyTypeFormSN int
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_MessageTypeValueError]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT [Value] 
FROM tblMsgProperties(NoLock) 
WHERE MsgSN = @MessageSN
AND PropSN = @PropertyTypeFormSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_MessageTypeValueError] TO [public]
GO
