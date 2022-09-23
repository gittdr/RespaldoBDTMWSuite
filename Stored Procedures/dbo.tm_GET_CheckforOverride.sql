SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CheckforOverride]
	@FormID int, 
	@Status varchar (8)
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CheckforOverride]
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
 * 001 - @FormID int
 * 002 - @Status varchar (8)
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_CheckforOverride]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT SN 
FROM tblForms(NoLock) 
WHERE FormId = @FormID
AND status = @Status


GO
GRANT EXECUTE ON  [dbo].[tm_GET_CheckforOverride] TO [public]
GO
