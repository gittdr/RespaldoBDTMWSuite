SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetFldType_MobileCommTypes]

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT tblFldType.TypeName, tblFldType.Code, tblFldType.DefaultWidth, 
tblFldType.Description, tblFldType.IsDefault, tblFldType.IsMCSystemDefault, 
tblFldType.MaxWidth, tblFldType.MobileCommType, 
ISNULL(tblMobileCommType.MobileCommType, 'GENERIC') MCTypeDesc, tblFldType.MinWidth, 
tblFldType.SN, tblFldType.TotalMailType
FROM tblFldType
LEFT JOIN tblMobileCommType ON tblFldType.MobileCommType = tblMobileCommType.SN
ORDER BY 11
GO
GRANT EXECUTE ON  [dbo].[tm_GetFldType_MobileCommTypes] TO [public]
GO
