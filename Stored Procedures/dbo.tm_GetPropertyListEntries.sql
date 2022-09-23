SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GetPropertyListEntries]
	@EntryType int,
	@PropSN int

AS
/**
 * 
 * NAME:
 * dbo.tm_GetPropertyListEntries
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls PropSN, Value, FldType and totalCount value base on a EntryType and PropSN
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
 * 03/29/12      - PTS 55847  JW - Created for Get PropertyList Entries used in TMForms.clsformdefinition.getstaticinformation
 *
 **/

/* tm_GetPropertyListEntries **************************************************************
** 
*********************************************************************************/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT
	PropSN,
	[Value],
	ISNULL(FldType,'') FldType,
	(Select Count(SN) FROM tblPropertyListEntries WHERE PropSN = @PropSN) AS Total
FROM tblPropertyListEntries 
WHERE EntryType = @EntryType
	AND PropSN = @PropSN

GO
GRANT EXECUTE ON  [dbo].[tm_GetPropertyListEntries] TO [public]
GO
