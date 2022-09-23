SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TMmessage]
	@SN int



AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TMmessage]
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
 * 001 - @SN int
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_TMmessage]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT tblAttachmentData.SN, [Filename] 
FROM tblAttachments(NoLock), tblAttachmentData(NoLock)  
WHERE tblAttachments.DataSN = tblAttachmentData.SN  
AND tblAttachments.Message = @SN
ORDER BY tblAttachments.InsertionPt


GO
GRANT EXECUTE ON  [dbo].[tm_GET_TMmessage] TO [public]
GO
