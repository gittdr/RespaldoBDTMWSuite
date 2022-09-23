SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CabUnitInbox]
	@CabUnitID varchar(50)
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CabUnitInbox]
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
 * 001 - @CabunitID varchar(50)
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_CabUnitInbox]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tdg.InBox 
From dbo.tblDispatchGroup tdg 
inner join tblcabunits tcu 
on tdg.sn = tcu.CurrentDispatcher
WHERE tcu.UnitID = @CabunitID

GO
GRANT EXECUTE ON  [dbo].[tm_GET_CabUnitInbox] TO [public]
GO
