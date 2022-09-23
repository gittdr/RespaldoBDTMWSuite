SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TblAddressBookNamebyTruck]
	@AddressBookName varchar(30),
	@AddressType varchar(100)
	
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TblAddressBookNamebyTruck]
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
 * 001 - @AddressBookName varchar(30)
 * 002 - @AddressType varchar(100)
 *    
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_TblAddressBookNamebyTruck]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT ad.AddressType, AddressName, @AddressType AS AddressType,
 CASE WHEN ad.AddressType = 4 THEN CASE WHEN ISNULL(GroupFlag, -1) = 0 THEN 'Truck' WHEN ISNULL(GroupFlag, -1) > 0 THEN 'Group' ELSE '<UNK>' END ELSE ty.Description END AS AddresseeType
FROM dbo.tblAddressBook ab 
INNER JOIN tblAddresses ad ON Defaultaddress = ad.SN 
INNER JOIN tblAddressTypes ty ON ad.AddressType = ty.SN 
LEFT JOIN tblTrucks tr ON tr.TruckName = ad.AddressName 
WHERE ab.Name LIKE @AddressBookName
AND ab.UseInResolve = 1

GO
GRANT EXECUTE ON  [dbo].[tm_GET_TblAddressBookNamebyTruck] TO [public]
GO
