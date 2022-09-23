SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DescriptionFromtbl]
	@Type int
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DescriptionFromtbl]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls Description from tblAddressTypes based on SN
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * Description fields
 *
 * PARAMETERS:
 * 001 - @Type int
 * 
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_DescriptionFromtbl]
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT Description 
FROM dbo.tblAddressTypes 
WHERE SN = @Type

GO
GRANT EXECUTE ON  [dbo].[tm_GET_DescriptionFromtbl] TO [public]
GO
