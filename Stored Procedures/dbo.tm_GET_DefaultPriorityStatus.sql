SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DefaultPriorityStatus]
	@Status varchar (8),
	@DefaultReplyForm int


AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DefaultPriorityStatus]
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
 * 001 - @Status varchar (8)
 * 002 - @DefaultReplyForm int
 *
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_DefaultPriorityStatus]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DefaultPriority  
FROM tblForms(NoLock) 
WHERE [Status] = @Status 
AND FormID = @DefaultReplyForm

GO
GRANT EXECUTE ON  [dbo].[tm_GET_DefaultPriorityStatus] TO [public]
GO
