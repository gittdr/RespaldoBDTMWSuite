SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_tblServerInboxOutbox]
	@ServerCode varchar(4)
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_tblServerInboxOutbox]
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
 * 001 - @Servercode  varchar(4)
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_tblServerInboxOutbox]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT InBox, OutBox
FROM dbo.tblServer 
WHERE Servercode = @ServerCode

GO
GRANT EXECUTE ON  [dbo].[tm_GET_tblServerInboxOutbox] TO [public]
GO
