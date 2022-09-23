SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CheckTractor]
	@Tractor varchar (15)
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CheckTractor]
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
 * 001 - @Tractor varchar (15)
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_CheckTractor]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT SN 
FROM tblTrucks(NoLock) 
WHERE TruckName = @Tractor

GO
GRANT EXECUTE ON  [dbo].[tm_GET_CheckTractor] TO [public]
GO
