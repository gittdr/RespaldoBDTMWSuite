SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_InboxofOffendingMessage]
	@FromName varchar (50),
	@FromType varchar (1)

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_InboxofOffendingMessage]
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
 * 001 - @FromName, varchar (50)
 * 002 - @FromType, varchar (1)
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_InboxofOffendingMessage]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT Inbox 
FROM tblAddresses(NoLock), tblAddressTypes(NoLock) 
WHERE tblAddressTypes.SN = tblAddresses.AddressType 
AND tblAddressTypes.SN = @FromType
AND tblAddresses.AddressName= @FromName

GO
GRANT EXECUTE ON  [dbo].[tm_GET_InboxofOffendingMessage] TO [public]
GO
