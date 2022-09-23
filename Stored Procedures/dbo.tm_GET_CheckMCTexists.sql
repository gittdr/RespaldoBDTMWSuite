SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CheckMCTexists]
	@MCTType int,
	@AddressTypeTruck int,
	@UnitID varchar (50)
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CheckMCTexists]
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
 * 001 - @MCTType int
 * 002 - @AddressTypeTruck int 
 * 003 - @UnitID varchar (50)
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_CheckMCTexists]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT SN 
FROM tblCabUnits(NoLock) 
WHERE UnitID = @UnitID
AND Type = @MCTTYpe
AND LinkedAddrType = @AddressTypeTruck

GO
GRANT EXECUTE ON  [dbo].[tm_GET_CheckMCTexists] TO [public]
GO
