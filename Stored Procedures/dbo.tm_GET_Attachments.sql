SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_Attachments]
	@SN int
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_Attachments]
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
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_Attachments]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT atd.SN, [Filename]
FROM dbo.tblAttachments at
INNER JOIN tblAttachmentData atd
ON at.DataSN = atd.SN 
WHERE at.[Message] = @SN 
ORDER BY at.InsertionPt

GO
GRANT EXECUTE ON  [dbo].[tm_GET_Attachments] TO [public]
GO
