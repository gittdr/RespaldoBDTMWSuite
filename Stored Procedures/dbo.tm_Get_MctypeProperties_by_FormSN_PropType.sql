SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_Get_MctypeProperties_by_FormSN_PropType]
	@I_FormSN Int,
	@I_PropType Int
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_Get_MctypeProperties_by_FormSN_PropType]
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
 * 10/18/2012	 - PTS55851 - APC - 
 **/

/* [tm_Get_MctypeProperties_by_FormSN_PropType]
 **************************************************************
******************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT mp.PropSN, mp.MCSN, mp.Value, mp.FormSN, pl.Name, pl.PropType 
FROM tblMCTypeProperties mp (NOLOCK)
INNER JOIN tblPropertyList pl (NOLOCK)
ON mp.PropSN = pl.SN
WHERE mp.FormSN = @I_FormSN 
and pl.PropType = @I_PropType 
ORDER By mp.PropSN

GO
GRANT EXECUTE ON  [dbo].[tm_Get_MctypeProperties_by_FormSN_PropType] TO [public]
GO
