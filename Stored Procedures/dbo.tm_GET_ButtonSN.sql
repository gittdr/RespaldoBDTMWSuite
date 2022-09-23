SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_ButtonSN]
	@TMType int,
	@MCType int,
	@Code varchar (10)
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_ButtonSN]
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
 * 001 - @TMType int
 * 002 - @MCType int
 * 003 - @Code varchar (10)
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_ButtonSN]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT SN 
FROM tblFldType(NoLock) 
WHERE TotalMailType = @TMType
AND MobileCommType = @MCType
AND Code = @Code

GO
GRANT EXECUTE ON  [dbo].[tm_GET_ButtonSN] TO [public]
GO
