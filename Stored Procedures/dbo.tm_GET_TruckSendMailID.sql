SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TruckSendMailID]
	@DefaultAltID varchar(50),
	@AdminMailBox int
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_KeyCodeText]
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
 * 001 - @DefaultAltID varchar(50)
 * 002 - @AdminMailBox int
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_TruckSendMailID]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT TruckName, EmailFolderID, AfterEmailSend 
FROM dbo.tblTrucks 
WHERE AlternateID = @DefaultAltID
AND UseAdminMailBox = @AdminMailBox



GO
GRANT EXECUTE ON  [dbo].[tm_GET_TruckSendMailID] TO [public]
GO
