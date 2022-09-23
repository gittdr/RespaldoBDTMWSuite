SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_ResolveAddressAlias]
	@Alias varchar (30)
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_ResolveAddressAlias]
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
 * 001 - @Alias varchar (30)
 * 
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_ResolveAddressAlias]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT tblAddresses.AddressType, tblAddresses.AddressName 
FROM tblAddresses(NoLock), tblAddressBook(NoLock) 
WHERE tblAddressBook.Name= @Alias
AND tblAddresses.SN = tblAddressBook.DefaultAddress

GO
GRANT EXECUTE ON  [dbo].[tm_GET_ResolveAddressAlias] TO [public]
GO
