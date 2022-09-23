SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_BouncedAdmintblDrivers]
	@FromName varchar (50)

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_BouncedAdmintblDrivers]
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
 * 001 - @FromName, varchar (50)
 * 
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_BouncedAdmintblDrivers]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tblDispatchGroup.InBox 
From tblDispatchGroup(NoLock), tblDrivers(NoLock) 
WHERE tblDrivers.Name = @FromName
AND tblDrivers.CurrentDispatcher = tblDispatchGroup.SN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_BouncedAdmintblDrivers] TO [public]
GO
