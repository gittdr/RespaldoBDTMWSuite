SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DetailMsgData]
	@MsgID int

	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DetailMsgData]
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
 * 001 - @MsgID int
 *       
 *
 * REVISION HISTORY:
 * 06/12/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_DetailMsgData]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT msd_FieldName, msd_FieldValue 
FROM tblSQLMessageData(NoLock) 
WHERE msg_ID = @MsgID
ORDER BY msd_FieldName, msd_Seq, msd_ID


GO
GRANT EXECUTE ON  [dbo].[tm_GET_DetailMsgData] TO [public]
GO
