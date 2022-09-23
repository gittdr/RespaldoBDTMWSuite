SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



Create PROCEDURE [dbo].[tm_GetPropertyListEntriesCount]
	@EntryType int

AS
/**
 * 
 * NAME:
 * dbo.tm_GetPropertyListEntriesCount
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls count of SN based on a EntryType 
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * Total
 *
 * PARAMETERS:
 * 001 - @EntryType, int;

 *       
 *
 * REVISION HISTORY:
 * 03/29/12      - PTS 55848  JW - Created for Get PropertyList Entries used in TMForms.clsformdefinition.getstaticinformation
 *
 **/

/* tm_GetPropertyListEntriesCount **************************************************************
** 
*********************************************************************************/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT COUNT(SN) as Total
FROM tblPropertyListEntries
WHERE EntryType = @EntryType 
GROUP BY PropSN

GO
GRANT EXECUTE ON  [dbo].[tm_GetPropertyListEntriesCount] TO [public]
GO
