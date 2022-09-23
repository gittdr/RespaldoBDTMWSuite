SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_MsgPropertiesofMAPIDType]
	@PropertyName varchar(20),
	@MsgSN int

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_MsgPropertiesofMAPIDType]
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
 * 001 - @PropertyName, varchar(20);
 * 002 - @MsgSN  int;
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_MsgPropertiesofMAPIDType]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tblMsgProperties.Value 
FROM tblMessages(NoLock), tblMsgProperties(NoLock), tblPropertyTypes(NoLock)
WHERE tblMessages.SN = tblMsgProperties.MsgSN 
AND tblMsgProperties.PropSN = tblPropertyTypes.SN 
AND tblPropertyTypes.PropertyName = @PropertyName
AND tblMessages.SN = @MsgSN


GO
GRANT EXECUTE ON  [dbo].[tm_GET_MsgPropertiesofMAPIDType] TO [public]
GO
