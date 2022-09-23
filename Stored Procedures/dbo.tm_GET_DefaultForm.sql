SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DefaultForm]
	@FormSN int


AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DefaultForm]
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
 * 001 - @FormSN int
 *
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_DefaultForm]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DefaultPriority, DefaultReceipt, ReplyFormID 
FROM tblForms(NoLock)  
WHERE SN = @FormSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_DefaultForm] TO [public]
GO
