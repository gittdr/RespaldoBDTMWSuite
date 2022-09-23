SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_MCVendorSN]
	@MCVendorName varchar (20)
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_MCVendorSN]
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
 * 001 - @MCVendorName varchar (20)
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_MCVendorSN]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT SN  
FROM tblMobileCommType(NoLock)  
WHERE MobileCommType = @MCVendorName


GO
GRANT EXECUTE ON  [dbo].[tm_GET_MCVendorSN] TO [public]
GO
