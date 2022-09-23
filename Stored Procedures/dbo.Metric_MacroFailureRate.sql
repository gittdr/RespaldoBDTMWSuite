SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_MacroFailureRate]
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	@TMServer VARCHAR(40) = NULL, -- DEFAULT TO this SERVER.
	@TMDatabase VARCHAR(40) = NULL, -- DEFAULT TO THIS DATABASE.
	@FormIdList VARCHAR(255) = NULL,  -- This is the TotalMail FormID or Macro Number.
	@DispSysTruckIdList VARCHAR(255) = NULL,
	@DispSysDriverIDList VARCHAR(255) = NULL
AS

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'MacroFailureRate',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 601, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'TotalMail Macro Failure %',
		@sCaptionFull = 'TotalMail Macro Failure %',
		@sProcedureName = 'Metric_MacroFailureRate',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/

	-- NOTE 1: This might be inaccurate to run as backfill because history may be purged, and driver/truck assignments change.
	-- NOTE 2: Make a shell procedure on TMWSuite server/database that calls equivalent procedure on TotalMail server/database.
	DECLARE @TMPrefix VARCHAR(255), @SQL varchar(8000)
	SET NOCOUNT ON

	CREATE TABLE #results (Result decimal(20, 5), ThisCount decimal(20, 5), ThisTotal decimal(20, 5) )

	IF (ISNULL(@TMServer, '') = '') SELECT @TMPrefix = '' ELSE SELECT @TMPrefix = '[' + @TMServer + '].'
	IF (ISNULL(@TMDatabase, '') = '') SELECT @TMPrefix = '' ELSE SELECT @TMPrefix = @TMPrefix + '[' + @TMDatabase + '].dbo.'

	IF @ShowDetail = 0
	BEGIN
		SELECT @SQL = 'EXEC ' + @TMPrefix + 'Metric_MacroFailureRate_TM ''' + CONVERT(VARCHAR(19), @DateStart, 121) + ''', ''' + CONVERT(VARCHAR(19), @DateEnd, 121) 
										+ ''', 1, 0, ''' + ISNULL(@FormIdList, '') + ''', ''' + ISNULL(@DispSysTruckIdList, '') + ''', ''' + ISNULL(@DispSysDriverIDList, '') + ''''
		INSERT INTO #results 
		EXEC (@SQL)

		SELECT @Result = Result, @ThisCount = ThisCount, @ThisTotal = ThisTotal FROM #results
	END
	ELSE
	BEGIN
		SELECT @SQL = 'EXEC ' + @TMPrefix + 'Metric_MacroFailureRate_TM ''' + CONVERT(VARCHAR(19), @DateStart, 121) + ''', ''' + CONVERT(VARCHAR(19), @DateEnd, 121) 
										+ ''', 1, 1, ''' + ISNULL(@FormIdList, '') + ''', ''' + ISNULL(@DispSysTruckIdList, '') + ''', ''' + ISNULL(@DispSysDriverIDList, '') + ''''
		EXEC (@SQL)
	END

	SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[Metric_MacroFailureRate] TO [public]
GO
