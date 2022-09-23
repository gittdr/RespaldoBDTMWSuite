SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_KeyCodeText]
	@KeyCode varchar(10)
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_KeyCodeText]
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
 * 001 - @KeyCode varchar(10)
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_KeyCodeText]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT [Text]
FROM dbo.tblRS 
WHERE KeyCode = @KeyCode

GO
GRANT EXECUTE ON  [dbo].[tm_GET_KeyCodeText] TO [public]
GO
