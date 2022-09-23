SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GetPropertyListEntries_w_tblFldType]
	@EntryType int,
	@PropSN int

AS

/**
 * 
 * NAME:
 * dbo.tm_GetPropertyListEntries_w_tblFldType
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
 * 001 - @EntryType, int;
 * 002 - @PropSN  int;
 *       
 *
 * REVISION HISTORY:
 * 03/29/12      - PTS 55845  JW - Created for Get PropertyList Entries used in TMForms.clsformdefinition.getstaticinformation
 * 05/01/12      - PTS 55845  JW - 
 **/

/* tm_GetPropertyListEntries_w_tblFldType **************************************************************
** 
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT
	ple.PropSN,
	ISNULL(ple.FldType,'') FldType,
	ISNull(ft.TypeName,'') TypeName
FROM tblPropertyListEntries ple LEFT OUTER JOIN
	 tblFldType ft ON ft.SN = CASE WHEN ple.FldType = 0 THEN 0 ELSE ple.FldType End 
WHERE ple.EntryType = @EntryType 
	AND PropSN = @PropSN


GO
GRANT EXECUTE ON  [dbo].[tm_GetPropertyListEntries_w_tblFldType] TO [public]
GO
