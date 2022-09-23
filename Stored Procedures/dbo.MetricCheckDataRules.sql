SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCheckDataRules] (@MetricCode varchar(200) = NULL, @DateStart varchar(100) = NULL, @DateEnd varchar(100) = NULL, @ListMetricCodes_YN varchar(1) = 'N')
AS
	SET NOCOUNT ON

	DECLARE @DateStart_DT datetime, @DateEnd_DT datetime
	SELECT @DateStart_DT = @DateStart, @DateEnd_DT = @DateEnd
	
	DECLARE @BatchGUID varchar(36) -- Use BatchGuid enables user to possibly monitor changes to these records only.  It also shows a history of records checked.
	CREATE TABLE #tempBad (PlainDate datetime, MetricCode varchar(200))
	DECLARE @MetricProcessingDaysToOffset int

	IF (@DateStart_DT IS NULL) SELECT @DateStart_DT = MIN(PlainDate) FROM MetricDetail (NOLOCK)
	IF (@DateEnd_DT IS NULL) 
	BEGIN  
		SELECT @MetricProcessingDaysToOffset = ISNULL((SELECT cast(SettingValue as int) FROM MetricGeneralSettings WITH (NOLOCK) WHERE SettingName = 'MetricProcessingDaysToOffset'), 0)
		If @MetricProcessingDaysToOffset = 0
			SELECT @DateEnd_DT = GETDATE()
		ELSE
			SELECT @DateEnd_DT = DATEADD(day, -@MetricProcessingDaysToOffset, CONVERT(char(8), GETDATE(), 112))
	END	
	If DATEPART(year, @DateStart_DT) > DATEPART(year, GETDATE()) AND DATEPART(year, @DateEnd_DT) > DATEPART(year, GETDATE())
		RETURN -- Disallow future date searches here...

	SELECT @BatchGUID = NEWID()

	DELETE dbo.MetricInvalidHistory WHERE dt_insert < DATEADD(day, -7, GETDATE())

	--****************** START: CHECK DATA RULES ***************************************************
	INSERT INTO #tempBad (PlainDate, MetricCode)
	EXEC MetricDataRule_NullResults @MetricCode, @DateStart_DT, @DateEnd_DT, @ListMetricCodes_YN

	INSERT INTO #tempBad (PlainDate, MetricCode)
	EXEC dbo.MetricDataRule_NoSummaryRun @MetricCode, @DateStart_DT, @DateEnd_DT, @ListMetricCodes_YN

	INSERT INTO #tempBad (PlainDate, MetricCode)
	EXEC dbo.MetricDataRule_NotProcessed @MetricCode, @DateStart_DT, @DateEnd_DT, @ListMetricCodes_YN

	INSERT INTO #tempBad (PlainDate, MetricCode)
	EXEC dbo.MetricDataRule_NonContinuous @MetricCode, @DateStart_DT, @DateEnd_DT, @ListMetricCodes_YN
	--****************** END: CHECK DATA RULES ***************************************************

	-- **** FINAL STEP ****
	INSERT INTO dbo.MetricInvalidHistory (BatchGuid, PlainDate, MetricCode)
	SELECT DISTINCT @BatchGuid, PlainDate, MetricCode FROM #tempBad 

	SELECT BatchGuid, CONVERT(varchar(23), PlainDate, 121) AS PlainDate, CONVERT(varchar(23), DATEADD(day, 1, PlainDate), 121) AS PlainDateEnd, MetricCode FROM dbo.MetricInvalidHistory (NOLOCK) WHERE BatchGuid = @BatchGuid ORDER BY MetricCode, PlainDate
GO
GRANT EXECUTE ON  [dbo].[MetricCheckDataRules] TO [public]
GO
