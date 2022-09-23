SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_ErrDatabyListId]
	@vData int
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_ErrDatabyListId]
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
 * 001 - @vData int
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_ErrDatabyListId]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT SN 
FROM dbo.tblErrorData 
WHERE ErrListID = @vData 
ORDER BY TimeStamp

GO
GRANT EXECUTE ON  [dbo].[tm_GET_ErrDatabyListId] TO [public]
GO
