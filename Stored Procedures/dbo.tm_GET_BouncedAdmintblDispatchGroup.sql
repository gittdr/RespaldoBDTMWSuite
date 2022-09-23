SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_BouncedAdmintblDispatchGroup]
	@FromName varchar (50)

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_BouncedAdmintblDispatchGroup]
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

/* [tm_GET_BouncedAdmintblDispatchGroup]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tblDispatchGroup.InBox 
From tblDispatchGroup(NoLock), tblCabUnits(NoLock) 
WHERE tblCabUnits.UnitID = @FromName
AND tblCabUnits.CurrentDispatcher = tblDispatchGroup.SN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_BouncedAdmintblDispatchGroup] TO [public]
GO
