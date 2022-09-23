SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricInitializeItem] (
	-- All parameters except @sMetricCode are optional.

		@sMetricCode VARCHAR(200), 	-- NOT NULL
		@nActive int = 1, 			-- NOT NULL,   -- Used to determine whether updates should be run.
		@nSort int = 1 , 			-- NOT NULL, -- Used to determine the sort order that updates should be run.
		@sFormatText VARCHAR(12) = 'PCT',   -- NOT NULL
		@nNumDigitsAfterDecimal int = 0, -- NOT NULL,
		@nPlusDeltaIsGood int = 1, 	-- NOT NULL,
		@nCumulative int = 0, 		-- NOT NULL,
		@sCaption VARCHAR(80) = NULL, 
		@sCaptionFull VARCHAR(255) = NULL, 
		@sProcedureName VARCHAR(50) = NULL,
		@dStartDate datetime = NULL, 	-- Allows a metric to not have values in metric detail before a certain date.
		@nScheduleSN int = NULL,   -- Leave this at zero to set up on it's own schedule or to not run it.
		@sDetailFilename VARCHAR(50) = NULL,	  -- This may be a cookie-cutter file by default, but could be a customized detail program.
		@sThresholdAlertEmailAddress varchar(255) = NULL,
		@nThresholdAlertValue decimal(20, 5) = NULL,
		@sThresholdOperator varchar(2) = NULL,
		@sCachedDetailYN varchar(1) = 'N', 
		@nCacheRefreshAgeMaxMinutes int = NULL, 
		@sShowDetailByDefaultYN varchar(1) = 'N', 
		@sRefreshHistoryYN varchar(1) = '',  -- Changed from 'N' to '' when behavior changed on 8/10/2010.
		@nGoalDay decimal(20, 5) = NULL, 
		@nGoalWeek decimal(20, 5) = NULL, 
		@nGoalMonth decimal(20, 5) = NULL, 
		@nGoalQuarter decimal(20, 5) = NULL, 
		@nGoalYear decimal(20, 5) = NULL,
		@sCategory varchar(30) = 'NewItems',
		@sGradingScaleCode varchar(30) = NULL,  -- NULL means default to MetricCode
		@sGradeA decimal(20, 5) = NULL,
		@sGradeB decimal(20, 5) = NULL,
		@sGradeC decimal(20, 5) = NULL,
		@sGradeD decimal(20, 5) = NULL
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	SET NOCOUNT ON

	DECLARE @GradeA_PlusDeltaIsGood decimal(20, 5)
	DECLARE @GradeB_PlusDeltaIsGood decimal(20, 5)
	DECLARE @GradeC_PlusDeltaIsGood decimal(20, 5)
	DECLARE @GradeD_PlusDeltaIsGood decimal(20, 5)
	DECLARE @GradeA_PlusDeltaIsBad decimal(20, 5)
	DECLARE @GradeB_PlusDeltaIsBad decimal(20, 5)
	DECLARE @GradeC_PlusDeltaIsBad decimal(20, 5)
	DECLARE @GradeD_PlusDeltaIsBad decimal(20, 5)
	DECLARE @nGradeFactorTemp int

/*
COMMENTED OUT 7/6/2004 DAG

	-- ************************************************************************************************
	-- START: Setup for Default Grades
	-- ************************************************************************************************
	IF (UPPER(@sFormatText) = 'PCT') SELECT @nGradeFactorTemp = 1
	ELSE SELECT @nGradeFactorTemp = 100

	SELECT 	@GradeA_PlusDeltaIsGood = .90 * @nGradeFactorTemp,
			@GradeB_PlusDeltaIsGood = .80 * @nGradeFactorTemp,
			@GradeC_PlusDeltaIsGood = .70 * @nGradeFactorTemp,
			@GradeD_PlusDeltaIsGood = .60 * @nGradeFactorTemp,
			@GradeA_PlusDeltaIsBad = .10 * @nGradeFactorTemp,
			@GradeB_PlusDeltaIsBad = .20 * @nGradeFactorTemp,
			@GradeC_PlusDeltaIsBad = .30 * @nGradeFactorTemp,
			@GradeD_PlusDeltaIsBad = .40 * @nGradeFactorTemp

	IF (@nPlusDeltaIsGood = 1)
	BEGIN
		IF (@sGradeA IS NULL) SELECT @sGradeA = @GradeA_PlusDeltaIsGood
		IF (@sGradeB IS NULL) SELECT @sGradeB = @GradeB_PlusDeltaIsGood
		IF (@sGradeC IS NULL) SELECT @sGradeC = @GradeC_PlusDeltaIsGood
		IF (@sGradeD IS NULL) SELECT @sGradeD = @GradeD_PlusDeltaIsGood
	END
	ELSE
	BEGIN
		IF (@sGradeA IS NULL) SELECT @sGradeA = @GradeA_PlusDeltaIsBad
		IF (@sGradeB IS NULL) SELECT @sGradeB = @GradeB_PlusDeltaIsBad
		IF (@sGradeC IS NULL) SELECT @sGradeC = @GradeC_PlusDeltaIsBad
		IF (@sGradeD IS NULL) SELECT @sGradeD = @GradeD_PlusDeltaIsBad
	END
	-- ************************************************************************************************
	-- END: Setup for Default Grades
	-- ************************************************************************************************

	IF (ISNULL(@sGradingScaleCode, '') = '') SELECT @sGradingScaleCode = @sMetricCode -- Default to making a new scale with GradingScaleCode = MetricCode.
*/	

	IF NOT EXISTS(SELECT * FROM metricitem WHERE metriccode = @sMetricCode)
	BEGIN
		INSERT INTO MetricItem (MetricCode, Active, Sort, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, 
								Caption, CaptionFull, ProcedureName, GradingScaleCode, DetailFilename, 
								ThresholdAlertEmailAddress, ThresholdAlertValue, ThresholdOperator,
								CachedDetailYN, CacheRefreshAgeMaxMinutes, 
								ShowDetailByDefaultYN, RefreshHistoryYN, GoalNumDigitsAfterDecimal)
			SELECT @sMetricCode, @nActive, @nSort, @sFormatText, @nNumDigitsAfterDecimal, @nPlusDeltaIsGood, @nCumulative,
					@sCaption, @sCaptionFull, @sProcedureName, @sGradingScaleCode, @sDetailFilename, 
					@sThresholdAlertEmailAddress, @nThresholdAlertValue, @sThresholdOperator, @sCachedDetailYN, @nCacheRefreshAgeMaxMinutes,
					@sShowDetailByDefaultYN, ISNULL(@sRefreshHistoryYN, ''), 0 as GoalNumDigitsAfterDecimal
	END

	EXEC MetricInsertIntoCategory @sMetricCode, @sCategory, @nSort

/*
COMMENTED OUT 7/6/2004 DAG
	
	IF NOT EXISTS(SELECT * FROM MetricGradingScaleHeader WHERE GradingScaleCode = @sGradingScaleCode)
	BEGIN	
		INSERT INTO MetricGradingScaleHeader (GradingScaleCode, SystemScale, PlusDeltaIsGood, FormatText)
			VALUES (@sGradingScaleCode, 0, @nPlusDeltaIsGood, @sFormatText)

		IF NOT EXISTS(SELECT * FROM MetricGradingScaleDetail WHERE GradingScaleCode = @sGradingScaleCode)
		BEGIN	
			INSERT INTO MetricGradingScaleDetail (GradingScaleCode, Grade, FormatText, MinValue)
				VALUES (@sGradingScaleCode, 'A', @sFormatText, @sGradeA)						

			INSERT INTO MetricGradingScaleDetail (GradingScaleCode, Grade, FormatText, MinValue)
				VALUES (@sGradingScaleCode, 'B', @sFormatText, @sGradeB )

			INSERT INTO MetricGradingScaleDetail (GradingScaleCode, Grade, FormatText, MinValue)
				VALUES (@sGradingScaleCode, 'C', @sFormatText, @sGradeC )

			INSERT INTO MetricGradingScaleDetail (GradingScaleCode, Grade, FormatText, MinValue)
				VALUES (@sGradingScaleCode, 'D', @sFormatText, @sGradeD )

			INSERT INTO MetricGradingScaleDetail (GradingScaleCode, Grade, FormatText, MinValue)
				VALUES (@sGradingScaleCode, 'F', @sFormatText, NULL )

		END

	END
*/
GO
GRANT EXECUTE ON  [dbo].[MetricInitializeItem] TO [public]
GO
