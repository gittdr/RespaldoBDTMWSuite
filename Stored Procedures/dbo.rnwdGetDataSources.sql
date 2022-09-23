SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rnwdGetDataSources] (@AvailableOnlyYN varchar(1) = 'N')
AS
	SET NOCOUNT ON

	SELECT sn, Available_YN, 
		Available = CASE WHEN Available_YN = 'Y' THEN 'YES' ELSE 'NO' END, 
		Caption, CaptionFull, DataSourceType, ServerName, CatalogName, UserId, [Password], ConnectionStringOverride,
		ConnectionStringOverrideExists = CASE WHEN ISNULL(ConnectionStringOverride, '') <> '' THEN 'YES' ELSE 'NO' END
	FROM rnExternalDataSource
	WHERE Available_YN = CASE WHEN ISNULL(@AvailableOnlyYN, 'N') = 'N' THEN Available_YN ELSE 'Y' END
GO
GRANT EXECUTE ON  [dbo].[rnwdGetDataSources] TO [public]
GO
