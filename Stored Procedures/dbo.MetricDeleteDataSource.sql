SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricDeleteDataSource] (@DataSourceSn int)
AS
	SET NOCOUNT ON

	IF EXISTS(SELECT * FROM rnExternalDataSource WHERE sn = @DataSourceSN) 
		DELETE rnExternalDataSource WHERE sn = @DataSourceSN

GO
GRANT EXECUTE ON  [dbo].[MetricDeleteDataSource] TO [public]
GO
