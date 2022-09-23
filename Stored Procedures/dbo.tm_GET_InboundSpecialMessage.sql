SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_InboundSpecialMessage]
	@SpecialMsgSN int

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_InboundSpecialMessage]
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
 * 001 - @SpecialMsgSN int
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_InboundSpecialMessage]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT class 
FROM tblSpecialMessages(NoLock) 
WHERE SN = @SpecialMsgSN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_InboundSpecialMessage] TO [public]
GO
