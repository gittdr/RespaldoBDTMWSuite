SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_AddressNamebyAddressBook]
	@AddressName int
	
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_AddressNamebyAddressBook]
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

/* [tm_GET_AddressNamebyAddressBook]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT Name 
FROM dbo.tblAddressBook  
WHERE Name= @AddressName

GO
GRANT EXECUTE ON  [dbo].[tm_GET_AddressNamebyAddressBook] TO [public]
GO
