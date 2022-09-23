SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TblMesgPropertiesbyValue]
	@Property varchar (20),
	@MessageSN int
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TblMesgPropertiesbyValue]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls Value from tblMsgProperties base on Property and MessageSN
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * PropSN, FldType and TypeName fields
 *
 * PARAMETERS:
 * 001 - @Property varchar (20)
 * 002 - @MessageSN int
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_TblMesgPropertiesbyValue]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tp.Value 
FROM dbo.tblMessages tm
INNER JOIN tblMsgProperties tp ON tm.SN = tp.MsgSN 
INNER JOIN tblPropertyTypes pt ON tp.PropSN = pt.SN  
WHERE pt.PropertyName = @Property  
AND tm.SN = @MessageSN


GO
GRANT EXECUTE ON  [dbo].[tm_GET_TblMesgPropertiesbyValue] TO [public]
GO
