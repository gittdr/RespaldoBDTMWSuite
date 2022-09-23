SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_AdNameSNandAdTypeSN]
	@AdNameText varchar (50),
	@AdType	int
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_AdNameSNandAdTypeSN]
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
 * 001 - @AdNameText varchar (50)
 * oo2 - @AdType int
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_AdNameSNandAdTypeSN]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT SN 
From dbo.tblAddresses 
WHERE AddressName = @AdNameText
AND AddressType = @AdType



GO
GRANT EXECUTE ON  [dbo].[tm_GET_AdNameSNandAdTypeSN] TO [public]
GO
