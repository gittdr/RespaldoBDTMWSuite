SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_FilltheSourceView]
	@SubFormFilterData varchar (254)

	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_FilltheSourceView]
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
 * 001 - @SubFormFilterData varchar (254)
 *       
 *
 * REVISION HISTORY:
 * 06/12/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_FilltheSourceView]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT msg_ID, msg_Date, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_FormID, msg_To, msg_ToType, 
msg_From, msg_FromType, msg_Subject, GetDate() as NOW 
FROM tblSQLMessage(NoLock) 
WHERE msg_FilterData = @SubFormFilterData
ORDER BY msg_Date, msg_ID


GO
GRANT EXECUTE ON  [dbo].[tm_GET_FilltheSourceView] TO [public]
GO
