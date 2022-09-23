SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CheckValidTMTypeError]
	@AddressText varchar (50),
	@AddressType int
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CheckValidTMTypeError]
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
 * 001 - @AddressText varchar (50)
 * 002 - @AddressType int 
 * 
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_CheckValidTMTypeError]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT SN 
From tblAddresses(NoLock) 
WHERE AddressName = @AddressText
AND AddressType = @AddressType


GO
GRANT EXECUTE ON  [dbo].[tm_GET_CheckValidTMTypeError] TO [public]
GO
