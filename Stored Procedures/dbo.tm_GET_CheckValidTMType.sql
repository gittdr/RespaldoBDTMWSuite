SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CheckValidTMType]
	@AddressText varchar (30)
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CheckValidTMType]
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
 * 001 - @AddressText varchar (30)
 * 
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_CheckValidTMType]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tblAddresses.SN, tblAddresses.addressname, tblAddresses.addresstype 
From tblAddresses(NoLock) 
INNER JOIN tblAddressBook(NoLock) ON tbladdresses.sn = tbladdressbook.defaultaddress 
WHERE tblAddressBook.Name = @AddressText


GO
GRANT EXECUTE ON  [dbo].[tm_GET_CheckValidTMType] TO [public]
GO
