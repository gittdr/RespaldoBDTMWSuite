SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DistinctInbox]
	@ADTFromType varchar(1),
	@ADFromName varchar(50)
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DistinctInbox]
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
 * 001 - @ADTFromType varchar(1)
 * 002 - @ADFromName varchar(50)
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_DistinctInbox]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT Inbox 
FROM dbo.tblAddresses ad
INNER JOIN  tblAddressTypes at
ON at.SN = ad.AddressType
WHERE  at.SN = @ADTFromType 
AND ad.AddressName= @ADFromName



GO
GRANT EXECUTE ON  [dbo].[tm_GET_DistinctInbox] TO [public]
GO
