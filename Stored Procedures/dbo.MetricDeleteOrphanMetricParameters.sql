SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteOrphanMetricParameters] (@MetricCode varchar(200), @ProcedureName varchar(255) )
AS

	SET NOCOUNT ON

	DELETE metricparameter WHERE heading = 'MetricStoredProc' AND SubHeading = @MetricCode 
		AND	NOT EXISTS(SELECT t2.id FROM sysobjects t1 INNER JOIN syscolumns t2 ON t1.id = t2.id 
						WHERE t1.type = 'p' AND t1.name = @ProcedureName AND t2.name = metricparameter.ParmName)
GO
GRANT EXECUTE ON  [dbo].[MetricDeleteOrphanMetricParameters] TO [public]
GO
