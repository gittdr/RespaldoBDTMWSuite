SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_DescriptionFromtblAddressTypes]
	@PropSN int

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_DescriptionFromtblAddressTypes]
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
 * Description field
 * PARAMETERS:
 * 001 - @PropSN  int;
 *       
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_DescriptionFromtblAddressTypes]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT Description
FROM dbo.tblAddresstypes
WHERE SN = @PropSN 


GO
GRANT EXECUTE ON  [dbo].[tm_GET_DescriptionFromtblAddressTypes] TO [public]
GO
