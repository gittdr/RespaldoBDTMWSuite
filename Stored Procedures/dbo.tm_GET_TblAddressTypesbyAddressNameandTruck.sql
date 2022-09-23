SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TblAddressTypesbyAddressNameandTruck]
	@AddressName int
	
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TblAddressTypesbyAddressNameandTruck]
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
 * 001 - @AddressName int
 * 
 *    
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_TblAddressTypesbyAddressNameandTruck]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT ad.AddressType, ad.AddressName, AddresseeType = 
CASE WHEN ad.AddressType = 4 THEN 
CASE WHEN ISNULL(tr.GroupFlag, -1) = 0 THEN 'Truck' 
	WHEN ISNULL(tr.GroupFlag, -1) > 0 THEN 'Group' 
	ELSE '<UNK>' END 
ELSE ty.Description END  
FROM dbo.tblAddresses ad 
INNER JOIN tblAddressTypes ty ON ad.AddressType = ty.SN 
LEFT JOIN tblTrucks tr ON tr.TruckName = ad.AddressName 
WHERE ad.AddressName LIKE @AddressName AND ad.UseInResolve = 1

GO
GRANT EXECUTE ON  [dbo].[tm_GET_TblAddressTypesbyAddressNameandTruck] TO [public]
GO
