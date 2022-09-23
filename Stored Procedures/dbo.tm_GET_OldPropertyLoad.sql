SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_OldPropertyLoad]
	@MsgNumber int,
	@ErrMsgPropertySN int

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_OldPropertyLoad]
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
 * 001 - @MsgNumber int
 * 002 - @ErrMsgPropertySN int 
 *
 *       
 *
 * REVISION HISTORY:
 * 06/08/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_OldPropertyLoad]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT MsgSN, PropSN, Value 
FROM tblMsgProperties(NoLock)  
WHERE MsgSN = @MsgNumber
AND PropSN = @ErrMsgPropertySN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_OldPropertyLoad] TO [public]
GO
