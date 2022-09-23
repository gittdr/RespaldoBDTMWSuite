SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_NTLoginInfo]
	@SystemUserName varchar (256)


AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_NTLoginInfo]
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
 * 001 - @SystemUserName varchar (256)
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_NTLoginInfo]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT tblLogin.SN, tblLogin.LoginName  
FROM tblLogin(NoLock)  
Where NTLoginName = @SystemUserName

GO
GRANT EXECUTE ON  [dbo].[tm_GET_NTLoginInfo] TO [public]
GO
