SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_HandlePriority]
	@keycode varchar (10)


AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_HandlePriority]
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
 * 001 - @keycode varchar (10)
 *
 *       
 *
 * REVISION HISTORY:
 * 06/11/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_HandlePriority]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT [Text] 
FROM tblrs(NoLock) 
WHERE keycode = @keycode

GO
GRANT EXECUTE ON  [dbo].[tm_GET_HandlePriority] TO [public]
GO
