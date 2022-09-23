SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TruckNamewithDispSysTruckID]
	@DTruckID varchar (20)
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TruckNamewithDispSysTruckID]
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
 * 001 - @DTruckID varchar (20)
 * 
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_TruckNamewithDispSysTruckID]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT TruckName 
FROM dbo.tblTrucks 
WHERE DispSysTruckID = @DTruckID 



GO
GRANT EXECUTE ON  [dbo].[tm_GET_TruckNamewithDispSysTruckID] TO [public]
GO
