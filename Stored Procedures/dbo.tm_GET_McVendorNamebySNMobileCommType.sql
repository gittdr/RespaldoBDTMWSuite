SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_McVendorNamebySNMobileCommType]
	@McVendorName varchar (20)
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_McVendorNamebySNMobileCommType]
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
 * 001 - McVendorName varchar (20)
 * 
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_McVendorNamebySNMobileCommType]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT SN 
FROM dbo.tblMobileCommType 
WHERE MobileCommType = @McVendorName

GO
GRANT EXECUTE ON  [dbo].[tm_GET_McVendorNamebySNMobileCommType] TO [public]
GO
