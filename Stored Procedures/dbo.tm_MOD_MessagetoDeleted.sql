SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_MOD_MessagetoDeleted]
	@DeletedFolder int,
	@MessageNum int
	
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_MOD_MessagetoDeleted]
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
 * 001 - @DeletedFolder	int
 * 002- @MessageNum int
 * 
 *    
 *
 * REVISION HISTORY:
 * 06/1/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_MOD_MessagetoDeleted]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

UPDATE tblMessages 
SET Folder = @DeletedFolder 
WHERE tblMessages.SN = @MessageNum

GO
GRANT EXECUTE ON  [dbo].[tm_MOD_MessagetoDeleted] TO [public]
GO
