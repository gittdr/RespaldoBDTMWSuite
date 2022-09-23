SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GetMctypePropertiesbyFieldSNandPropType]
	@I_FieldSN Int,
	@I_PropType Int
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GetMctypePropertiesbyFieldSNandPropType]
 *
 * TYPE:
 * StoredProcedure 
 *
 *      
 *
 * REVISION HISTORY:
 * 08/23/12      - PTS 55851 JW
 **/

/* [tm_GetMctypePropertiesbyFieldSNandPropType]
 **************************************************************
******************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT DISTINCT PropSN, MCSN, ISNULL(Value,'') Value, FieldSN, Name, 
PropType, PropertyValueIndex
FROM dbo.tblMCTypeProperties mp
INNER JOIN tblPropertyList pl
ON mp.PropSN = pl.SN
WHERE FieldSN = @I_FieldSN 
and PropType = @I_PropType 
ORDER By PropSN

GO
GRANT EXECUTE ON  [dbo].[tm_GetMctypePropertiesbyFieldSNandPropType] TO [public]
GO
