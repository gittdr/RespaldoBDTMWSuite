SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_StaticVariable]
	@TotalMail varchar (20),
	@Status varchar (8),
	@ID varchar (50)

	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_StaticVariable]
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
 * 001 - @TotalMail varchar (20)
 * 002 - @Status varchar (8)
 * 003 - @ID varchar (50)
 *       
 *
 * REVISION HISTORY:
 * 06/12/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_StaticVariable]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT FormSN 
FROM tblSelectedMobilecomm(NoLock) 
WHERE MobileCommSN = 
(SELECT SN 
FROM tblMobileCommType(NoLock) 
WHERE MobileCommType = @TotalMail 
AND tblSelectedMobilecomm.Status = @Status 
AND tblSelectedMobilecomm.ID = @ID)


GO
GRANT EXECUTE ON  [dbo].[tm_GET_StaticVariable] TO [public]
GO
