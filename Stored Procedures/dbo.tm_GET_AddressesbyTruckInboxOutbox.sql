SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_AddressesbyTruckInboxOutbox]
	@AddressText varchar(50),
	@AddressType int
	
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_AddressesbyTruckInboxOutbox]
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
 * 001 - @AddressText varchar(50)
 * 002 - @AddressType int
 * 
 *    
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_AddressesbyTruckInboxOutbox]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tn.SN 
FROM dbo.tblAddresses ta
Inner Join  tblTrucks tn
ON ta.Inbox = tn.Inbox 
AND ta.Outbox = tn.Outbox 
WHERE ta.AddressName = @AddressText
AND ta.AddressType = @AddressType


GO
GRANT EXECUTE ON  [dbo].[tm_GET_AddressesbyTruckInboxOutbox] TO [public]
GO
