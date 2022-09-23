SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_NumberOfWorkingDays] (
	@Result decimal(20, 5) OUTPUT, @ThisCount decimal(20, 5) OUTPUT, @ThisTotal decimal(20, 5) OUTPUT, @DateStart datetime, @DateEnd datetime, @UseMetricParms int, @ShowDetail int
)
AS
	SET NOCOUNT ON  -- PTS46367

	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>
	INSERT INTO MetricItem (MetricCode, Active, Sort, FormatText, NumDigitsAfterDecimal, PlusDeltaIsGood, Cumulative, Caption, CaptionFull, ProcedureName, DetailFilename, CachedDetailYN, CacheRefreshAgeMaxMinutes, ShowDetailByDefaultYN, RefreshHistoryYN)
	VALUES ('NumberOfWorkingDays', 1, 106, 'USD', 2, 1, 0, 'Revenue Per Working Day ', 'Dispatch 6: Revenue Per Working Day', 'Metric_NumberOfWorkingDays', '', '', 0, 'N', '') 

	EXEC MetricInsertIntoCategory 'RevenuePerWorkingDay', 'Dispatch'
	</METRIC-INSERT-SQL>
	*/

	/*	To test this:
	DECLARE	@Result decimal(20, 5), @ThisCount decimal(20, 5), @ThisTotal decimal(20, 5), @DateStart datetime, @DateEnd datetime, @UseMetricParms int, @ShowDetail int
	EXEC Metric_NumberOfWorkingDays @Result OUTPUT, @ThisCount OUTPUT, @ThisTotal OUTPUT, '3/3/2002', '3/4/2002', 1, 1
	*/


	Set @ThisCount = IsNull((Select sum(IsNull(BusinessDay,0)) from MetricBusinessDays where PlainDate >= @DateStart and PlainDate < @DateEnd and businessday > 0),0)

	SET  @ThisTotal = DATEDIFF(day, @DateStart,@DateEnd)  -- # of days
	
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

GO
GRANT EXECUTE ON  [dbo].[Metric_NumberOfWorkingDays] TO [public]
GO
