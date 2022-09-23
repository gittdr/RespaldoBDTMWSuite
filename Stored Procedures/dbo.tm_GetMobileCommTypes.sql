SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetMobileCommTypes]

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT SN, AllowBlankVersion, AllowIDShare, DefaultDisplayRows, 
DisplayInMultiMode, DisplayName, EnabledUntil, IsIDAlpha, IsVersionAlpha, 
CostPerPage, CostPerChar, MobileCommType, NoPending, NumCols, NumRows, 
PSMobileCommName, XfcID, CanLink, CanKeyBlock
FROM tblMobileCommType
ORDER BY 1

GO
GRANT EXECUTE ON  [dbo].[tm_GetMobileCommTypes] TO [public]
GO
