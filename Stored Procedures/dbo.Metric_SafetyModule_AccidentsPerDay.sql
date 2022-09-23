SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     PROCEDURE [dbo].[Metric_SafetyModule_AccidentsPerDay] 
(
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	@MetricCode varchar(255)= 'SafetyModuleAccidentsPerDay',
	@Terminal varchar(255) = ''
)
AS
	SET NOCOUNT ON  -- PTS46367


SELECT @Terminal = ',' + LTRIM(RTRIM(ISNULL(@Terminal, ''))) + ','

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'SafetyModuleAccidentsPerDay',
		@nActive = 1,	-- 1=active, 0=inactive.
		@nSort = 106, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Accidents Per Day',
		@sCaptionFull = 'Accidents Per Day',
		@sProcedureName = 'Metric_SafetyModule_AccidentsPerDay',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = 'Dispatch'

	</METRIC-INSERT-SQL>
*/

/*	To test this:
	DECLARE	@Result decimal(20, 5), @ThisCount decimal(20, 5), @ThisTotal decimal(20, 5), @DateStart datetime, @DateEnd datetime, @UseMetricParms int, @ShowDetail int
	EXEC Metric_RevPerTrc @Result OUTPUT, @ThisCount OUTPUT, @ThisTotal OUTPUT, '3/3/2002', '3/4/2002', 1, 1
*/
 
	Select  acd_Driver1 as [Driver1 ID] ,
		srp_EventDate as [Event Date],
		acd_tractor as [Tractor],
		safetyreport.srp_terminal as [Terminal],
		acd_AccidentType1 as [Accident Type1],
		CONVERT(varchar(4000), acd_description) as [Accident Description]
 	into    #TempAccidents
	From    Accident (NOLOCK),SafetyReport (NOLOCK)
	Where   srp_eventdate >= @DateStart and srp_eventdate < @DateEnd
	        And
	        Accident.srp_id = SafetyReport.srp_id
                And
                (@Terminal = ',,' OR CHARINDEX(',' + RTRIM( safetyreport.srp_terminal ) + ',', @Terminal) > 0)

	Select @ThisCount = Count(*)
	From   #TempAccidents
	
	SELECT @ThisTotal = DATEDIFF(day, @DateStart, @DateEnd)
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
 
	IF (@ShowDetail=1)
	BEGIN
		Select *
		From   #TempAccidents 							

		
		
	End
	
	
GO
GRANT EXECUTE ON  [dbo].[Metric_SafetyModule_AccidentsPerDay] TO [public]
GO
