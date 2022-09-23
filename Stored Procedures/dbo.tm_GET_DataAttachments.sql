SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DataAttachments]
	@Attachment int,
	@DataAttachment int 
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DataAttachments]
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
 * 001 - @Attachment int
 * oo2 - @DataAttachment int
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_DataAttachments]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DataSN, SN
FROM dbo.tblAttachments 
WHERE SN = @Attachment 
AND DataSN = @DataAttachment 


GO
GRANT EXECUTE ON  [dbo].[tm_GET_DataAttachments] TO [public]
GO
