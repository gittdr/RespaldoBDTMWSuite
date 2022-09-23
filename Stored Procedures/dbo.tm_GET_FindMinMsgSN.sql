SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_FindMinMsgSN]
	@OrigMsgSN int
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_FindMinMsgSN]
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
 * 001 - @OrigMsgSN int
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_FindMinMsgSN]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT Min(SN) 
FROM tblMessages(NoLock) 
WHERE OrigMsgSN = @OrigMsgSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_FindMinMsgSN] TO [public]
GO
