SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TblLoginAdmin]
	@LoginName varchar (50)
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TblLoginAdmin]
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
 * 001 - @LoginName varchar (50)
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_TblLoginAdmin]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT SN, Inbox, Outbox, [Sent], Deleted, TMPassword, LoginName, MAPIProfile, 
[Password],  SMTPReplyAddress, SMTPPassword, SMTPLogin  
FROM dbo.tblLogin 
WHERE LoginName = @LoginName 

GO
GRANT EXECUTE ON  [dbo].[tm_GET_TblLoginAdmin] TO [public]
GO
