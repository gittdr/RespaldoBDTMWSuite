SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_MessageProperties]
	@mvarMsgNumber int,
	@ErrMsgPropertySN int
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_MessageProperties]
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
 * 001 - @mvarMsgNumber int
 * 002 - @ErrMsgPropertySN int    
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_MessageProperties]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT MsgSN, PropSN, Value 
FROM dbo.tblMsgProperties 
WHERE MsgSN = @mvarMsgNumber AND PropSN = @ErrMsgPropertySN

GO
GRANT EXECUTE ON  [dbo].[tm_GET_MessageProperties] TO [public]
GO
