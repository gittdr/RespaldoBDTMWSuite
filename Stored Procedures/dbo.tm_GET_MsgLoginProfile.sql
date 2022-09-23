SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_MsgLoginProfile]
	
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_MsgLoginProfile]
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
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_MsgLoginProfile]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT MAPIProfile, Password, LoginName, SMTPReplyAddress, AfterEmailSend
FROM tblLogin
WHERE ISNULL(MAPIProfile, '') > '' 
AND UseAdminMailBox = 0

GO
GRANT EXECUTE ON  [dbo].[tm_GET_MsgLoginProfile] TO [public]
GO
