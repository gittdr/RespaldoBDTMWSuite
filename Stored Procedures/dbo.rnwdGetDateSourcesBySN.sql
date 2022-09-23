SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rnwdGetDateSourcesBySN] (@sn int)
AS
	SET NOCOUNT ON

	SELECT sn, Available_YN, 
		Available = CASE WHEN Available_YN = 'Y' THEN 'YES' ELSE 'NO' END, 
		Caption, CaptionFull, DataSourceType, ServerName, CatalogName, UserId, [Password], ConnectionStringOverride,
		ConnectionStringOverrideExists = CASE WHEN ISNULL(ConnectionStringOverride, '') <> '' THEN 'YES' ELSE 'NO' END
	FROM rnExternalDataSource
	WHERE sn = @sn
GO
GRANT EXECUTE ON  [dbo].[rnwdGetDateSourcesBySN] TO [public]
GO
