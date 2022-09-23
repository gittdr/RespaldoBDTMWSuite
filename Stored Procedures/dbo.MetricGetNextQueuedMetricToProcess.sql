SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetNextQueuedMetricToProcess] (@MetricCode varchar(200), @QueueSN int, @BatchGUID varchar(36) )
AS

	SET NOCOUNT ON 
	DECLARE @sn int, @DateStartPassed datetime, @DateEndPassed datetime, @ProcessFlags int 

	-- Update the BadData indicator if there is a problem.
	UPDATE MetricItem SET BadData = CASE WHEN EXISTS(SELECT sn FROM metricdetail (NOLOCK) WHERE metriccode = @MetricCode AND DailyCount IS NULL) THEN 1 ELSE 0 END
	WHERE metriccode = @MetricCode
	
	-- Reset metriccode.
	SELECT @MetricCode = NULL

	-- Remove old entry.
	DELETE MetricProcessingSort WHERE sn = @QueueSN

	-- Get the next entry.
	SELECT @sn = ISNULL(MIN(sn),-1) FROM MetricProcessingSort WHERE BatchGUID = @BatchGUID AND ISNULL(Status, 'Queued') = 'Queued' AND sn > @QueueSN 
	IF @sn > 0 
	BEGIN 
	   SELECT @MetricCode = MetricCode, @DateStartPassed = DateStartPassed, @DateEndPassed = DateEndPassed, @ProcessFlags = ProcessFlags FROM MetricProcessingSort WHERE sn = @sn and BatchGUID = @BatchGUID
	   UPDATE MetricProcessingSort SET Status = 'Started' WHERE sn = @sn 
	END
	ELSE 
	   SELECT @MetricCode = '', @sn = -1 

	SELECT sn = @sn, MetricCode = @MetricCode, 
				DateStartPassed = CASE WHEN @DateStartPassed IS NULL THEN CONVERT(char(1), '') ELSE CONVERT(varchar(23), @DateStartPassed, 121) END, 
				DateEndPassed = CASE WHEN @DateEndPassed IS NULL THEN CONVERT(char(1), '') ELSE CONVERT(varchar(23), @DateEndPassed, 121) END, ProcessFlags = ISNULL(@ProcessFlags, 0) 

GO
GRANT EXECUTE ON  [dbo].[MetricGetNextQueuedMetricToProcess] TO [public]
GO
