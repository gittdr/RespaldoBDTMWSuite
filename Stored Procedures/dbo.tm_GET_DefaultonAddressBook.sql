SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DefaultonAddressBook]
	@Mask varchar (30),
	@UseInResolve bit
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DefaultonAddressBook]
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
 * 001 - @Mask varchar (30)
 * 002 - @UseInResolve bit
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_DefaultonAddressBook]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT ad.AddressType, AddressName,  
--& CStr(g_AddressTypeAddressBook) & n_(" AS AddressType,") 
AddresseeType =(CASE WHEN ad.AddressType = 4 
THEN CASE WHEN ISNULL(GroupFlag, -1) = 0 
THEN 'Truck' WHEN ISNULL(GroupFlag, -1) > 0
THEN 'Group' ELSE '<UNK>' END 
ELSE ty.Description END)
FROM tblAddressBook ab(NoLock) 
INNER JOIN tblAddresses ad(NoLock) 
ON Defaultaddress = ad.SN 
INNER JOIN tblAddressTypes ty(NoLock) 
ON ad.AddressType = ty.SN  
LEFT JOIN tblTrucks tr(NoLock) 
ON tr.TruckName = ad.AddressName  
WHERE ab.Name LIKE @Mask 
AND ab.UseInResolve = @UseInResolve

GO
GRANT EXECUTE ON  [dbo].[tm_GET_DefaultonAddressBook] TO [public]
GO
