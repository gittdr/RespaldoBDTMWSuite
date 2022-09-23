SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_MOD_StatustoFail]
	@OrigMsgSN int
	
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_MOD_StatustoFail]
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
 * 001 - @OrigMsgSN int
 * 
 * 
 *    
 *
 * REVISION HISTORY:
 * 06/1/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_MOD_StatustoFail]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

UPDATE tblMessages 
SET Status = (select sn from tblmsgstatus where code = 'fail')
WHERE OrigMsgSN = @OrigMsgSN

GO
GRANT EXECUTE ON  [dbo].[tm_MOD_StatustoFail] TO [public]
GO
