SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_WriteNewRecord]
	@attachmentDataSN int



AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_WriteNewRecord]
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
 * 001 - attachmentDataSN int 
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_WriteNewRecord]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT [FileName], Data  
FROM tblAttachmentData(NoLock)  
WHERE SN = @attachmentDataSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_WriteNewRecord] TO [public]
GO
