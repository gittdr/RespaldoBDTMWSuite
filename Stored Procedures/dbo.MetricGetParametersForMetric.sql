SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetParametersForMetric]  (@MetricCode varchar(200))
AS
	SET NOCOUNT ON

	SELECT ParmName, ParmSort 
	FROM MetricParameter 
	WHERE Heading = 'MetricStoredProc' 
		AND SubHeading = @MetricCode
	ORDER BY ParmSort

GO
GRANT EXECUTE ON  [dbo].[MetricGetParametersForMetric] TO [public]
GO
