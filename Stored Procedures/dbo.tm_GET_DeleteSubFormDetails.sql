SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DeleteSubFormDetails]
	@FilterData varchar (254),
	@MsgID varchar (20)

	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DeleteSubFormDetails]
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
 * 001 - @FilterData varchar (254)
 * 002 - @MsgID varchar (20)      
 *
 * REVISION HISTORY:
 * 06/12/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_DeleteSubFormDetails]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT msg_date 
FROM tblSQLMessage 
WHERE msg_ID = @MsgID 
AND msg_FilterData = @FilterData


GO
GRANT EXECUTE ON  [dbo].[tm_GET_DeleteSubFormDetails] TO [public]
GO
