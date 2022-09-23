SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TruckNameInbox]
	@TruckName varchar(15)
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TruckNameInbox]
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
 * 001 - @TruckName varchar(15)
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_TruckNameInbox]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tdg.InBox 
From dbo.tblDispatchGroup tdg
inner join tblTrucks tt
	on tdg.sn = tt.CurrentDispatcher
WHERE tt.TruckName = @TruckName

GO
GRANT EXECUTE ON  [dbo].[tm_GET_TruckNameInbox] TO [public]
GO
