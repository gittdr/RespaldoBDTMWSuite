SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CheckDispGrpRetiredExists]
	


AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CheckDispGrpRetiredExists]
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
 *  
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_CheckDispGrpRetiredExists]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT Retired  
FROM tblDispatchGroup(NoLock)  
WHERE SN = 0

GO
GRANT EXECUTE ON  [dbo].[tm_GET_CheckDispGrpRetiredExists] TO [public]
GO
