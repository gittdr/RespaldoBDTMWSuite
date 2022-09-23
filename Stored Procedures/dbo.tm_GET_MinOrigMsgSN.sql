SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_MinOrigMsgSN]
	@OrigMsgSN int
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_MinOrigMsgSN]
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
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_MinOrigMsgSN]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT Min(SN)
FROM tblMessages
WHERE OrigMsgSN = @OrigMsgSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_MinOrigMsgSN] TO [public]
GO
