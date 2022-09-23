SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create PROCEDURE [dbo].[tm_GetPropertyList_w_MCTypeProperties]
	@PropType int

AS

/**
 * 
 * NAME:
 * dbo.tm_GetPropertyList_w_MCTypeProperties
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls SN, Name, dataType, DefaultValue, Range1, Range2, Editable, IsUnique, Description, PropType, MCSN value base on a EntryType and PropSN
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * p.SN, 
	p.Name, 
	p.DataType, 
	p.Defaultvalue, 
	p.Range1, 
	p.Range2, 
	p.Editable, 
	p.IsUnique,
	p.[Description], 
	p.PropType, 
	UniquePropList.MCSN, 
	p.IsParent, 
	p.ParentSN, 
	p.IsDataDef, 
	p.DataSequence, 
	p.[ReadOnly], 
	p.MultSetsAllowed  fields
 *
 * PARAMETERS:
 *       
 *
 * REVISION HISTORY:
 * 03/29/12      - PTS 55849  JW
 *
 **/

/* tm_GetPropertyList_w_MCTypeProperties **************************************************************
** 
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT 
	p.SN, 
	p.Name, 
	p.DataType, 
	p.Defaultvalue, 
	p.Range1, 
	p.Range2, 
	p.Editable, 
	p.IsUnique,
	p.[Description], 
	p.PropType, 
	UniquePropList.MCSN, 
	p.IsParent, 
	p.ParentSN, 
	p.IsDataDef, 
	p.DataSequence, 
	p.[ReadOnly], 
	p.MultSetsAllowed 
FROM tblPropertyList p INNER JOIN
	(SELECT DISTINCT tblPropertyList.SN, Name, MCSN 
		From tblPropertyList INNER JOIN 
		tblMCTypeProperties ON tblMCTypeProperties.PropSN = tblPropertyList.SN
		WHERE PropType = @PropType) UniquePropList ON p.SN = UniquePropList.SN
ORDER BY p.SN

GO
GRANT EXECUTE ON  [dbo].[tm_GetPropertyList_w_MCTypeProperties] TO [public]
GO
