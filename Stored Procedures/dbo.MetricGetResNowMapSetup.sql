SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricGetResNowMapSetup] (@pgSN int)
AS
	SELECT * FROM ResNowMapSetup WHERE sn = @pgSN
GO
GRANT EXECUTE ON  [dbo].[MetricGetResNowMapSetup] TO [public]
GO
