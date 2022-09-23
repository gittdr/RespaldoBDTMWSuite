SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CabUnitResource]
	@CabUnitSN int
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CabUnitResource]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:s
 * Pulls PropSN, FldType and TypeName value base on a EntryType and PropSN
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * PropSN, FldType and TypeName fields
 *
 * PARAMETERS:
 * 001 - @CabUnitSN int
 * 
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_CabUnitResource]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT ISNULL(LinkedObjSN, Truck) 
FROM tblCabUnits(NoLock) 
WHERE SN = @CabUnitSN


GO
GRANT EXECUTE ON  [dbo].[tm_GET_CabUnitResource] TO [public]
GO
