SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCopyItem] (
	@MetricCode varchar(200), @CopiedMetricSN int, @CopyCategoryInfo varchar(10)
)
AS
	SET NOCOUNT ON

	DECLARE @status varchar(12)

	SELECT @status = ''

	IF EXISTS(SELECT * FROM MetricItem WHERE MetricCode = @MetricCode)
	BEGIN
		SELECT [CopyStatus] = 'FAILED'
		RETURN
	END
	ELSE
	BEGIN
		INSERT INTO MetricItem (MetricCode, Active, Sort, Caption, CaptionFull, ProcedureName, DetailFileName, GoalDay, GoalWeek, GoalMonth, GoalQuarter, GoalYear,
				FormatText, NumDigitsAfterDecimal, GoalNumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative,
				RNIDateFormat, RNIActiveLanguage, RNILocaleID, RNIDefaultCurrency, RNICurrencyDateType, RNICurrencySymbol, RNINumericFormat, RefreshHistoryYN, DoNotIncludeTotalForNonBusinessDayYN )
		SELECT @MetricCode, Active, Sort, Caption, CaptionFull, ProcedureName, DetailFileName, GoalDay, GoalWeek, GoalMonth, GoalQuarter, GoalYear,
				FormatText, NumDigitsAfterDecimal, GoalNumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative,
				RNIDateFormat, RNIActiveLanguage, RNILocaleID, RNIDefaultCurrency, RNICurrencyDateType, RNICurrencySymbol, RNINumericFormat, 
				ISNULL(RefreshHistoryYN, ''), DoNotIncludeTotalForNonBusinessDayYN
		FROM MetricItem WHERE sn = @CopiedMetricSN


		INSERT INTO MetricParameter (Heading, SubHeading, ParmName, ParmSort, ParmValue, [Format]) 
		SELECT Heading, @MetricCode, ParmName, ParmSort, ParmValue, [Format]
		FROM metricParameter mp join metricitem mi
			ON Heading = 'MetricStoredProc' AND Subheading = mi.MetricCode
		WHERE mi.sn = @CopiedMetricSN 

		IF @CopyCategoryInfo = 'YES'
		BEGIN
			--'**** New for COPY CATEGORY INFO.
			INSERT INTO MetricCategoryItems (CategoryCode, MetricCode, Active, Sort, ShowLayersByDefault, LayerFilter)
			SELECT t1.CategoryCode, @MetricCode, t1.Active, t1.Sort, t1.ShowLayersByDefault, t1.LayerFilter
			FROM MetricCategoryItems t1 INNER JOIN metricitem t2 ON t1.metriccode = t2.metriccode
			WHERE t2.sn = @CopiedMetricSN
		END
	END



GO
GRANT EXECUTE ON  [dbo].[MetricCopyItem] TO [public]
GO
