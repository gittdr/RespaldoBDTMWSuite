SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_MailObjbyExternalMsgID]
	@MsgID varchar(128)

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_MailObjbyExternalMsgID]
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
 * 001 - @MsgID varchar(128)
 * 
 *
 *     
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_MailObjbyExternalMsgID]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT TmailObjType, TMailObjSN, PageNum, CabUnitSN 
FROM dbo.tblExternalIDs With (Index = PK__tblexternalids__23CA01AF)
WHERE MCommTypeSN = 0 
AND ExternalID =  @MsgID



GO
GRANT EXECUTE ON  [dbo].[tm_GET_MailObjbyExternalMsgID] TO [public]
GO
