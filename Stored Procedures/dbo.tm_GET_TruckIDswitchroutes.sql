SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TruckIDswitchroutes]
	@TruckSN int
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TruckIDswitchroutes]
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
 * 001 - @TruckSN int
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_TruckIDswitchroutes]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT TruckName 
FROM tblTrucks(NoLock) 
WHERE SN = @TruckSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_TruckIDswitchroutes] TO [public]
GO
