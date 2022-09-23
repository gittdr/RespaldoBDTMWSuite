SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_Get_MctypeProperties_by_FieldSN_PropType]
	@I_FieldSN Int,
	@I_PropType Int
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_Get_MctypeProperties_by_FieldSN_PropType]
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *	
 * 
 * RETURNS:
 *  none
 *
 * RESULT SETS: 
 *  none
 *
 * PARAMETERS:
 * 001 - @p_varname varchar12)     
 *
 * REVISION HISTORY:
 * 08/23/12      - PTS55851 - JW  - created
 * 10/18/2012	 - PTS55851 - APC - renamed
 **/

/* [tm_Get_MctypeProperties_by_FieldSN_PropType]
 **************************************************************
******************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT mp.PropSN, mp.MCSN, ISNULL(mp.Value,'') Value, mp.FieldSN, pl.Name, 
pl.PropType, mp.PropertyValueIndex
FROM dbo.tblMCTypeProperties mp (NOLOCK)
INNER JOIN tblPropertyList pl (NOLOCK)
ON mp.PropSN = pl.SN
WHERE mp.FieldSN = @I_FieldSN 
and pl.PropType = @I_PropType 
ORDER By mp.PropSN

GO
GRANT EXECUTE ON  [dbo].[tm_Get_MctypeProperties_by_FieldSN_PropType] TO [public]
GO
