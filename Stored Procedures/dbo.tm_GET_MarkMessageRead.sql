SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_MarkMessageRead]
	@OriginalMessageSN int

	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_MarkMessageRead]
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
 * 001 - @OriginalMessageSN int

 *       
 *
 * REVISION HISTORY:
 * 06/12/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_MarkMessageRead]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT ISNULL(ReadByName,'') 
FROM tblMsgShareData(NoLock) 
WHERE OrigMsgSN = @OriginalMessageSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_MarkMessageRead] TO [public]
GO
