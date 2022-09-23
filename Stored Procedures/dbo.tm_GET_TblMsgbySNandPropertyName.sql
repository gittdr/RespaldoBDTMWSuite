SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TblMsgbySNandPropertyName]
	@PropertyName int,
	@MessageID int
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TblMsgbySNandPropertyName]
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
 * 001 - @PropertyName int
 * 002 - @MessageID int
 *    
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_TblMsgbySNandPropertyName]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tm.SN 
FROM dbo.tblMessages tm 
Inner join tblMsgProperties tmp on tm.sn = tmp.msgsn 
inner join tblPropertyTypes tpt on tmp.PropSN = tpt.SN 
WHERE tpt.PropertyName = @PropertyName  AND tmp.Value =@MessageID

GO
GRANT EXECUTE ON  [dbo].[tm_GET_TblMsgbySNandPropertyName] TO [public]
GO
