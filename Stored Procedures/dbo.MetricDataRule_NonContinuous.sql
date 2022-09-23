SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDataRule_NonContinuous]  (@MetricCodePassed varchar(200) = NULL, @DateStart datetime = NULL, @DateEnd datetime = NULL, @ListMetricCodes_YN varchar(1) = 'N' ) -- (@nActive int = NULL)  -- NULL indicates either.
AS
	SET NOCOUNT ON

	DECLARE @MetricProcessingDaysToOffset int
	DECLARE @metriccode varchar(200) 
	DECLARE @loopDate datetime
	DECLARE @tblMetric TABLE (sn int identity, MetricCode varchar(200), PlainDate datetime) 

	DECLARE @PlainDates TABLE (PlainDate datetime)
	DECLARE @MaxDate datetime, @MinDate datetime
	
	IF (@DateStart IS NULL) SELECT @DateStart = MIN(PlainDate) FROM MetricDetail (NOLOCK)
	IF (@DateEnd IS NULL) 
	BEGIN  
		SELECT @MetricProcessingDaysToOffset = ISNULL((SELECT cast(SettingValue as int) FROM MetricGeneralSettings WITH (NOLOCK) WHERE SettingName = 'MetricProcessingDaysToOffset'), 0)
		SELECT @DateEnd = DATEADD(day, -@MetricProcessingDaysToOffset, CONVERT(char(8), GETDATE(), 112))
		--SELECT @DateEnd = MAX(PlainDate) FROM MetricDetail (NOLOCK)
	END
	
	-- ************************************************************
	-- Initialize a table with all the valid plaindates.
	-- ************************************************************
	SELECT @MaxDate = MAX(PlainDate), @MinDate = MIN(PlainDate) FROM MetricDetail (NOLOCK)
	IF (@MaxDate IS NULL) OR (@MinDate IS NULL) RETURN -- No records in the table, or all records have NULL plaindates.

	IF (@MinDate < @DateStart) -- If there are records in the table that are LESS than the "passed in" datestart, then use the "passed in" date start as the date of valid start dates.
		SELECT @MinDate = @DateStart -- ELSE SELECT @MinDate = @MinDate   -- OTHERWISE, use the Minimum date to start.  Might want to respect STARTDATE if this is an issue.

	IF (@MaxDate < @DateEnd) 
		SELECT @MaxDate = @DateEnd -- ELSE SELECT @MaxDate = @MaxDate   -- This should catch recent missing records.

	SET @loopDate = @MinDate
	WHILE @loopDate <= @MaxDate 
	BEGIN
		INSERT INTO @PlainDates (PlainDate) SELECT @loopDate
		SELECT @loopDate = DATEADD(day, 1, @loopDate)
	END

	IF ISNULL(@MetricCodePassed, '') = '' 
		SELECT @MetricCode = MIN(MetricCode) FROM MetricItem (NOLOCK) WHERE Active = 1
	ELSE
		SELECT @MetricCode = @MetricCodePassed

	WHILE ISNULL(@MetricCode, '') <> ''
	BEGIN
		-- Show records in @PlainDates where there are no corresponding records for these dates in metric detail for this metric.
		INSERT INTO @tblMetric(MetricCode, PlainDate)
		SELECT CASE WHEN @ListMetricCodes_YN = 'Y' THEN @MetricCode ELSE '' END, t1.PlainDate 
			FROM @PlainDates t1 LEFT OUTER JOIN 
						(SELECT PlainDate FROM MetricDetail (NOLOCK) WHERE MetricCode = @MetricCode) t2 ON t1.PlainDate = t2.PlainDate 
			WHERE t1.PlainDate >= @DateStart AND t1.PlainDate < @DateEnd 
				AND t2.PlainDate IS NULL
				/* t1.PlainDate > (SELECT MIN(PlainDate) FROM MetricDetail (NOLOCK) WHERE MetricCode = @MetricCode)
				AND t1.PlainDate <= @EndDateToUse
				AND */

		IF ISNULL(@MetricCodePassed, '') = '' 
			SELECT @MetricCode = MIN(MetricCode) FROM MetricItem (NOLOCK) WHERE Active = 1 AND MetricCode > @MetricCode
		ELSE
			SELECT @MetricCode = ''
	END

	SELECT DISTINCT PlainDate, CASE WHEN @ListMetricCodes_YN = 'Y' THEN MetricCode ELSE '' END AS MetricCode 
	FROM @tblMetric

	-- Show holes
	-- Estimate time to run based on previous days.
	-- Queue to process (run each date indivisually without RefreshHistory and without alerts, then refresh history starting from the oldest date to the most recent.
GO
GRANT EXECUTE ON  [dbo].[MetricDataRule_NonContinuous] TO [public]
GO
