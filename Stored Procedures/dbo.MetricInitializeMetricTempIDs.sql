SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInitializeMetricTempIDs] 
AS
	-- PART 1: Handle MetricTempIDs
	DELETE MetricTempIDs 

	-- PART 2: Handle MetricTempIDs2
	DELETE MetricTempIDs2 WHERE spid = @@spid OR dt_inserted < DATEADD(day, -3, GETDATE())
GO
GRANT EXECUTE ON  [dbo].[MetricInitializeMetricTempIDs] TO [public]
GO
