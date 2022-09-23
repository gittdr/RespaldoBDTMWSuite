SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TruckNameNewRoute]
	@DispSysTruckID varchar (20)
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TruckNameNewRoute]
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
 * 001 - @DispSysTruckID varchar (20)
 * 
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_TruckNameNewRoute]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT TruckName 
FROM tblTrucks(NoLock) 
WHERE DispSysTruckID = @DispSysTruckID


GO
GRANT EXECUTE ON  [dbo].[tm_GET_TruckNameNewRoute] TO [public]
GO
