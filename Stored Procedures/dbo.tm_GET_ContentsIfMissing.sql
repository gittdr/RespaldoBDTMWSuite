SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_ContentsIfMissing]
	@AdminServerCode varchar (4)
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_ContentsIfMissing]
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
 * 001 - @AdminServerCode
 * 
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_ContentsIfMissing]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


Select Inbox  
FROM tblServer(NoLock)  
WHERE ServerCode = @AdminServerCode


GO
GRANT EXECUTE ON  [dbo].[tm_GET_ContentsIfMissing] TO [public]
GO
