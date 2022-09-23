SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DriverIDNewRoute]
	@DispSysDrvID varchar (20)
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DriverIDNewRoute]
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
 * 001 - @DispSysDrvID varchar (20)
 * 
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_DriverIDNewRoute]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT [Name] 
FROM tblDrivers(NoLock) 
WHERE DispSysDriverID = @DispSysDrvID

GO
GRANT EXECUTE ON  [dbo].[tm_GET_DriverIDNewRoute] TO [public]
GO
