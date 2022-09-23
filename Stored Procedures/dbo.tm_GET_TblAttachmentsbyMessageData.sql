SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TblAttachmentsbyMessageData]
	@SN int

 

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TblAttachmentsbyMessageata]
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
 * 08/16/12      - PTS 60785 JW - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_TblAttachmentsbyMessageData]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT SN, InsertionPt, DataSN 
FROM dbo.tblAttachments 
WHERE [Message] = @SN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_TblAttachmentsbyMessageData] TO [public]
GO
