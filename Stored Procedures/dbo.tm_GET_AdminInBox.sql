SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_AdminInBox]
	@ServerCode varchar (4)
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_AdminInBox]
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
 * 001 - @ServerCode varchar (4)
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_AdminInBox]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT InBox 
FROM tblServer(NoLock) 
WHERE ServerCode = @ServerCode 


GO
GRANT EXECUTE ON  [dbo].[tm_GET_AdminInBox] TO [public]
GO
