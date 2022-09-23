SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_MsgSNbyExternalID]
	@ExternalID varchar(128),
	@TmailObjType varchar (6),
	@ExternalIDMCSN int
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_MsgSNbyExternalID]
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
 * 001 - @ExternalID varchar (128)
 * 002 - @TmailObjType varchar (6)
 * 003 - @ExternalIDMCSN int
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_MsgSNbyExternalID]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT TMailObjSN, PageNum 
FROM tblExternalIDs(NoLock) 
WHERE MCommTypeSN = @ExternalIDMCSN 
AND ExternalID = @ExternalID
AND TmailObjType = @TmailObjType

GO
GRANT EXECUTE ON  [dbo].[tm_GET_MsgSNbyExternalID] TO [public]
GO
