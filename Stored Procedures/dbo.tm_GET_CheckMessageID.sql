SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CheckMessageID]
	@MapiID varchar (20),
	@MessageID varchar (200)

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CheckMessageID]
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
 * 001 - @MapiID, varchar (20)
 * 002 - @MessageID, varchar (200)
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_CheckMessageID]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tblMessages.SN 
FROM tblMessages(NoLock), tblMsgProperties(NoLock), tblPropertyTypes(NoLock) 
WHERE tblMessages.SN=tblMsgProperties.MsgSN 
AND tblMsgProperties.PropSN = tblPropertyTypes.SN 
AND tblPropertyTypes.PropertyName = @MapiID
AND tblMsgProperties.Value = @MessageID

GO
GRANT EXECUTE ON  [dbo].[tm_GET_CheckMessageID] TO [public]
GO
