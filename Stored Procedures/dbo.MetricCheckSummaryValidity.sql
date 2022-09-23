SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCheckSummaryValidity] 
	@ShowDetail int = NULL, 
	@DetailToShow int = NULL
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

-- ********** THIS IS CURRENTLY DISABLED BECAUSE OF THE LAST SECTION BELOW. 
-- ********** IT WILL BE ENHANCED and FIXED IN THE NEAR FUTURE.  DAG 2003-12-03

	--***** RULES
	-- 1) Any NULL dates for PlainDate, Upd_Daily, or Upd_Sumary indicates BAD.
	-- 2) If the first date for any metric is NOT '1/1/yyyy', or its corresponding start date, then warn the display.
	-- 3) There must be a continous flow of data once a metric starts.

	DECLARE @DateToUse datetime, @GlobalStartDate datetime
	DECLARE @ValidData int, @ReasonInvalidData VARCHAR(1000)
	DECLARE @TEXTOUT_Rule01 VARCHAR(2000), @TEXTOUT_Rule02 VARCHAR(2000), @TEXTOUT_Rule03 VARCHAR(2000)
	DECLARE @RunPreviousDayYN varchar(1)

	SELECT @ValidData = 1, @ReasonInvalidData = '', 
		   @TEXTOUT_Rule01 = 'Rule #1 FAILED: Upd_Daily or Upd_Summary contain NULL values.  ',
		   @TEXTOUT_Rule02 = 'Rule #2 FAILED: A minimum plain date for a metric for at least one job is not consistent with the start date for that metric. '
							+ 'If Backfill was not done starting at the beginning of the year, then set the [startdate] field in MetricItem to that date that backfill started.  ',
		   @TEXTOUT_Rule03 = 'Rule #3 FAILED: Data for at least one metric does not appear to be continuous.',
		   @ShowDetail = ISNULL(@ShowDetail, 0), @DetailToShow = ISNULL(@DetailToShow, 0)

	EXEC MetricGetParameterText @RunPreviousDayYN OUTPUT, 'Y', 'Config', 'All', 'Process_And_Show_For_Previous_Day_YN'

	-- Any metric item can have a start date to determine the data validity. 
	-- If a metric does not have one defined, then use the global setting to determine if there is data missing.
	-- If there is not a global setting to StartDate, then use the oldest year for PlainDate, and go to January 1st of that year.
	SELECT @GlobalStartDate = CASE WHEN ISNULL((SELECT ParmValue from metricparameter WITH (NOLOCK) WHERE Heading = 'MetricGeneral' AND SubHeading = 'Data' AND ParmName = 'StartDate'), '') = '' 
										THEN (SELECT CONVERT(datetime, '1/1/' + CONVERT(varchar(4), DATEPART(yyyy, MIN(PlainDate)))) FROM MetricDetail WITH (NOLOCK))
								ELSE CONVERT(datetime, (SELECT ParmValue from metricparameter WITH (NOLOCK) WHERE Heading = 'MetricGeneral' AND SubHeading = 'Data' AND ParmName = 'StartDate'))
								END

	-- This is the current ending date.  Use today if the debug parameter is not set.
	SELECT @DateToUse = CASE WHEN ISNULL((SELECT ParmValue from metricparameter WITH (NOLOCK) WHERE Heading = 'MetricGeneral' AND SubHeading = 'DEBUG' AND ParmName = 'MockDate'), '') = '' THEN GETDATE() 
	                    ELSE CONVERT(datetime, (SELECT ParmValue from metricparameter WITH (NOLOCK) WHERE Heading = 'MetricGeneral' AND SubHeading = 'DEBUG' AND ParmName = 'MockDate')) 
                        END 
	IF (@RunPreviousDayYN = 'Y') SELECT @DateToUse = DATEADD(day, -1, @DateToUse)

	-- RULE #1: This is the easy/obvious rule.  IGNORE the PlainDate = NULL for now.  This just means that 
	IF (SELECT COUNT(*) FROM MetricDetail WITH (NOLOCK) WHERE (PlainDate <= @DateToUse) AND (Upd_Daily IS NULL OR Upd_Summary IS NULL)) > 0
	BEGIN
		SELECT @ValidData = 0, @ReasonInvalidData = @ReasonInvalidData + @TEXTOUT_Rule01	-- Indicates BAD data.
		IF (@ShowDetail = 1 AND @DetailToShow = 1)
			SELECT * FROM MetricDetail WITH (NOLOCK) WHERE (PlainDate <= @DateToUse) AND (Upd_Daily IS NULL OR Upd_Summary IS NULL) ORDER BY MetricCode, PlainDate
	END

	-- RULE #2: Check only PlainDate here.  A minimum plain date for a metric for at least one job is not consistent with the start date for that metric.
	IF (SELECT COUNT(*) FROM MetricItem t2 WITH (NOLOCK)
			WHERE (SELECT MIN(PlainDate) FROM MetricDetail WITH (NOLOCK) WHERE MetricCode = t2.MetricCode) <> ISNULL(t2.StartDate, @GlobalStartDate)) > 0
	BEGIN
		SELECT @ValidData = 0, @ReasonInvalidData = @ReasonInvalidData + @TEXTOUT_Rule02
		IF (@ShowDetail = 1 AND @DetailToShow = 2)
			SELECT * FROM MetricItem t2 WITH (NOLOCK)
			WHERE (SELECT MIN(PlainDate) FROM MetricDetail WITH (NOLOCK) WHERE MetricCode = t2.MetricCode) <> ISNULL(t2.StartDate, @GlobalStartDate) 
	END
	
	-- RULE #3: Continuous data flow. 
	IF (SELECT COUNT(MetricCode) FROM MetricItem t1 WITH (NOLOCK)
		WHERE Active = 1 
			AND DATEDIFF(day, ISNULL(StartDate, @GlobalStartDate), @DateToUse) + 1 <> (SELECT COUNT(*) FROM MetricDetail WITH (NOLOCK) WHERE MetricCode = t1.MetricCode AND PlainDate <= @DateToUse)
		) > 0
	BEGIN
		SELECT @ValidData = 0, @ReasonInvalidData = @ReasonInvalidData + @TEXTOUT_Rule03
		IF (@ShowDetail = 1 AND @DetailToShow = 3)
		SELECT MetricCode, DATEDIFF(day, ISNULL(StartDate, @GlobalStartDate), @DateToUse) + 1, (SELECT COUNT(*) FROM MetricDetail WITH (NOLOCK) WHERE MetricCode = t1.MetricCode AND PlainDate <= @DateToUse)
			FROM MetricItem t1 WITH (NOLOCK)
			WHERE Active = 1
				AND DATEDIFF(day, ISNULL(StartDate, @GlobalStartDate), @DateToUse) + 1 <> (SELECT COUNT(*) FROM MetricDetail WITH (NOLOCK) WHERE MetricCode = t1.MetricCode AND PlainDate <= @DateToUse)
	END

--	IF @ShowDetail = 0
--		SELECT @ValidData, @ReasonInvalidData 
	-- ********** THIS IS CURRENTLY DISABLED BECAUSE OF THE LINE BELOW. 
	-- ********** IT WILL BE ENHANCED and FIXED IN THE NEAR FUTURE.
	SELECT 1, @ReasonInvalidData 
GO
GRANT EXECUTE ON  [dbo].[MetricCheckSummaryValidity] TO [public]
GO
