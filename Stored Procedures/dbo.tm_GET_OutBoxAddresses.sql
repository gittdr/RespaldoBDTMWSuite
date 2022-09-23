SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_OutBoxAddresses]
	@FromName varchar (50),
	@FromType int


AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_OutBoxAddresses]
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
 * 001 - @FromName varchar (50)
 * 002 - @FromType int 
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_OutBoxAddresses]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT Outbox  
FROM tblAddresses(NoLock)  
WHERE AddressName = @FromName
AND AddressType = @FromType

GO
GRANT EXECUTE ON  [dbo].[tm_GET_OutBoxAddresses] TO [public]
GO
