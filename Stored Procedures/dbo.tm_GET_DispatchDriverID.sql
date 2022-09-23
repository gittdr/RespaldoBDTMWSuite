SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DispatchDriverID]
	@DriverSN int
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DispatchDriverID]
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
 * 001 - @DriverSN int
 * 
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_DispatchDriverID]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DispSysDriverID 
FROM tblDrivers(NoLock) 
WHERE SN = @DriverSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_DispatchDriverID] TO [public]
GO
