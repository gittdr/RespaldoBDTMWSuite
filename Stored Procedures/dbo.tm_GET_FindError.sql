SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_FindError]
	@SN int
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_FindError]
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
 * 001 - @SN int
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_FindError]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT VBError, [Description], Source, [TimeStamp], ErrListID, ISNULL([View],0) [View], ISNULL(Page,0) Page  
FROM tblErrorData(NoLock)  
WHERE SN = @SN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_FindError] TO [public]
GO
