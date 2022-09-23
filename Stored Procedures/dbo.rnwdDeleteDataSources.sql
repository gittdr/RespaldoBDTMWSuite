SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[rnwdDeleteDataSources] (@DataSourceSN int)
AS
	SET NOCOUNT ON
	
    IF EXISTS(SELECT * FROM rnExternalDataSource WHERE sn = @DataSourceSN) DELETE rnExternalDataSource WHERE sn = @DataSourceSN
GO
GRANT EXECUTE ON  [dbo].[rnwdDeleteDataSources] TO [public]
GO
