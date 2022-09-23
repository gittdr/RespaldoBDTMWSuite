SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_LoginSMTPInformationbyLogin]
	@FromName varchar(50)
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_LoginSMTPInformationbyLogin]
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
 * 001 - @FromName varchar(50)
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_LoginSMTPInformationbyLogin]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT MAPIProfile, SMTPReplyAddress, SMTPPassword, SMTPLogin, AlternateID 
FROM dbo.tblLogin 
WHERE LoginName = @FromName



GO
GRANT EXECUTE ON  [dbo].[tm_GET_LoginSMTPInformationbyLogin] TO [public]
GO
