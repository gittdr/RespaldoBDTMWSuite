SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetParmValue] (@MetricCodeByRequest varchar(200), @Column_Name varchar(255) )
AS
	SET NOCOUNT ON

	SELECT ParmValue 
	FROM metricparameter 
	WHERE Heading = 'MetricStoredProc' 
		AND SubHeading = @MetricCodeByRequest AND ParmName = @Column_Name
GO
GRANT EXECUTE ON  [dbo].[MetricGetParmValue] TO [public]
GO
