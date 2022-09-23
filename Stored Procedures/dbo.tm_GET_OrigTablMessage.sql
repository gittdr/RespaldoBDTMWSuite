SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_OrigTablMessage]
	@lMsgSN int
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_OrigTablMessage]
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
 * 001 - @lMsgSN int
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_OrigTablMessage]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT OrigMsgSN 
FROM dbo.tblMessages 
WHERE SN = @lMsgSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_OrigTablMessage] TO [public]
GO
