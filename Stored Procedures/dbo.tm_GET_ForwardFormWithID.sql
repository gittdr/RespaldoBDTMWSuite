SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_ForwardFormWithID]
	@Status varchar (8),
	@MCTType varchar (20),
	@ParmList varchar (20)

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_ForwardFormWithID]
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
 * 001 - @Status varchar (8)
 * 002 - @MCTType varchar (20)
 * 003 - @ParmList varchar (20)
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_ForwardFormWithID]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT MIN(FormSN) 
FROM tblSelectedMobileComm(NoLock), tblMobileCommType(NoLock), tblForms(NoLock) 
WHERE tblSelectedMobileComm.ID = @ParmList 
AND tblSelectedMobileComm.Status = @Status
AND tblMobileCommType.MobileCommType = @MCTType 
AND tblSelectedMobileComm.MobileCommSN = tblMobileCommType.SN 
AND tblSelectedMobileComm.FormSN = tblForms.SN 
AND tblForms.Forward = 1

GO
GRANT EXECUTE ON  [dbo].[tm_GET_ForwardFormWithID] TO [public]
GO
