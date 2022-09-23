SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_EnglishLanguageID]
	@English varchar(200),
 	@LanguageID char(10),
 	@Context int
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_EnglishLanguageID]
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
 * 001 - @English varchar(200)
 * 002 - @LanguageID char(10)
 * 003 - @Context int
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_EnglishLanguageID]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT [Language]
FROM dbo.Language_Text 
WHERE English = @English 
AND Language_id = @LanguageID 
AND Context = @Context

GO
GRANT EXECUTE ON  [dbo].[tm_GET_EnglishLanguageID] TO [public]
GO
