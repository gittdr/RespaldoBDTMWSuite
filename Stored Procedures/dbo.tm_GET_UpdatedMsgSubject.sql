SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_UpdatedMsgSubject]
	@MessageSN int

	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_UpdatedMsgSubject]
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
 * 001 - @MessageSN int

 *       
 *
 * REVISION HISTORY:
 * 06/12/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_UpdatedMsgSubject]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT [Subject] 
FROM tblMessages(NoLock) 
WHERE tblMessages.SN = @MessageSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_UpdatedMsgSubject] TO [public]
GO
