SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDataRule_NotProcessed] (@MetricCode varchar(200)= NULL, @DateStart datetime = NULL, @DateEnd datetime = NULL, @ListMetricCodes_YN varchar(1) = 'N' )
AS
	SET NOCOUNT ON

	-- Record exists in MetricDetail, but the metric stored procedure did not run.  This is indicated by Upd_Daily = NULL.
	-- (This is part of old rule #1)
	-- DECLARE @DateToUse datetime, @MetricProcessingDaysToOffset int

	DECLARE @MetricProcessingDaysToOffset int

	IF (@DateStart IS NULL) SELECT @DateStart = MIN(PlainDate) FROM MetricDetail (NOLOCK)
	IF (@DateEnd IS NULL) 
	BEGIN  
		SELECT @MetricProcessingDaysToOffset = ISNULL((SELECT cast(SettingValue as int) FROM MetricGeneralSettings WITH (NOLOCK) WHERE SettingName = 'MetricProcessingDaysToOffset'), 0)
		SELECT @DateEnd = DATEADD(day, -@MetricProcessingDaysToOffset, CONVERT(char(8), GETDATE(), 112))
		--SELECT @DateEnd = MAX(PlainDate) FROM MetricDetail (NOLOCK)
	END
	-- INSERT INTO dbo.MetricInvalidHistory (PlainDate, MetricCode)
	--SELECT PlainDate, MetricCode FROM MetricDetail (NOLOCK) WHERE (PlainDate <= @DateToUse) AND (Upd_Daily IS NULL) 
	

	IF (ISNULL(@MetricCode, '') = '')  --** All ACTIVE metrics.
		SELECT DISTINCT t1.PlainDate, CASE WHEN @ListMetricCodes_YN = 'Y' THEN t1.MetricCode ELSE '' END AS MetricCode 
		FROM MetricDetail t1 (NOLOCK) INNER JOIN MetricItem t2 (NOLOCK) ON t1.metriccode = t2.metriccode 
		WHERE (t1.PlainDate >= @DateStart AND t1.PlainDate < @DateEnd) AND t2.Active = 1 AND (t1.Upd_Daily IS NULL) 
	ELSE
		SELECT PlainDate, MetricCode FROM MetricDetail (NOLOCK) 
		WHERE (PlainDate >= @DateStart AND PlainDate < @DateEnd) AND MetricCode = @MetricCode AND (Upd_Daily IS NULL) 
GO
GRANT EXECUTE ON  [dbo].[MetricDataRule_NotProcessed] TO [public]
GO
