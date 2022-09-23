SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_MOD_InboxAsTouched]
	@ToInbox datetime
	
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_MOD_InboxAsTouched]
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
 * 001 - @ToInbox datetime
 * 
 * 
 *    
 *
 * REVISION HISTORY:
 * 06/1/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_MOD_InboxAsTouched]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

UPDATE tblLogin  
SET LastTMDlvry = GetDate() 
WHERE Inbox = @ToInbox

GO
GRANT EXECUTE ON  [dbo].[tm_MOD_InboxAsTouched] TO [public]
GO
