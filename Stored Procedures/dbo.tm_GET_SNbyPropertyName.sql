SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_SNbyPropertyName]
	@PropertyName varchar(20)
	
	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_SNbyPropertyName]
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
 * 001 - @PropertyName varchar(20)
 * 
 *    
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_SNbyPropertyName]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT SN 
FROM dbo.tblPropertyTypes 
WHERE PropertyName = @PropertyName

GO
GRANT EXECUTE ON  [dbo].[tm_GET_SNbyPropertyName] TO [public]
GO
