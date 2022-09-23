SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CheckvalidAddresses]
	

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CheckvalidAddresses]
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

/* [tm_GET_CheckvalidAddresses]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT Folder, FromName, FromType, DeliverTo, DeliverToType, ToTrcSN, ToDrvSN, FromDrvSN, FromTrcSN 
FROM tblMessages(NoLock)  
WHERE SN =~ 1;

GO
GRANT EXECUTE ON  [dbo].[tm_GET_CheckvalidAddresses] TO [public]
GO
