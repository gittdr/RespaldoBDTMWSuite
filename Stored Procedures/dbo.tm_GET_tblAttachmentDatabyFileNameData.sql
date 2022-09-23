SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_tblAttachmentDatabyFileNameData]
	@AttachmentData text
	


 

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_tblAttachmentDatabyFileNameData]
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
 * 001 - @AttachmentData text
 * 
 *
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_tblAttachmentDatabyFileNameData]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT SN, FileName, Data 
FROM dbo.tblAttachmentData 
WHERE SN = 0



GO
GRANT EXECUTE ON  [dbo].[tm_GET_tblAttachmentDatabyFileNameData] TO [public]
GO
