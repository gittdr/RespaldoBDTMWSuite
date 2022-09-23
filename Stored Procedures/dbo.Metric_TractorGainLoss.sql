SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_TractorGainLoss]
 
(		
		--Standard Parameters
		@Result decimal(20, 5) OUTPUT, --Value of the metric for the time frame passed
		@ThisCount decimal(20, 5) OUTPUT, --Numerator of the daily metric calculation
		@ThisTotal decimal(20, 5) OUTPUT, --Denominator of the daily metric calculation
		@DateStart datetime, --Start Date of metric calculation time frame
		@DateEnd datetime, --End Date of metric calculation time frame
		@UseMetricParms int, --Use Metric Parms Flag
		@ShowDetail int, --Show Detail Flag

		--Additional/Optional Parameters
		@OnlyTrcType1List varchar(100) ='',
		@OnlyTrcType2List varchar(100)='',
		@OnlyTrcType3List varchar(100)='',
		@OnlyTrcType4List varchar(100)='',
		@Mode varchar(100) = 'Gain'  --Gain, Loss 
)

AS

	set nocount on
	
	--Metric Initialization
		/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
			<METRIC-INSERT-SQL>
	
			EXEC MetricInitializeItem
				@sMetricCode = 'TractorGain',
				@nActive = 1,	-- 1=active, 0=inactive.
				@nSort = 10, 	-- Used to determine the sort order that updates should be run.
				@sFormatText = '',	-- Typically 'PCT' or blank ('').
				@nNumDigitsAfterDecimal = 0,
				@nPlusDeltaIsGood = 0,
				@nCumulative = 0,
				@sCaption = 'Tractor Gain',
				@sCaptionFull = 'Tractor Gain',
				@sProcedureName = 'Metric_TractorGainLoss',
				@sCachedDetailYN = '',
				@nCacheRefreshAgeMaxMinutes = 0,
				@sShowDetailByDefaultYN = 'N', -- Typically 'N'
				@sRefreshHistoryYN = '',	-- Typically 'N'
				@sCategory = @@NoCategory
		
			</METRIC-INSERT-SQL>
	
		*/

	select 	@OnlyTrcType1List = ',' + @OnlyTrcType1List + ','
	select 	@OnlyTrcType2List = ',' + @OnlyTrcType2List + ','
	select 	@OnlyTrcType3List = ',' + @OnlyTrcType3List + ','
	select 	@OnlyTrcType4List = ',' + @OnlyTrcType4List + ','

	IF @Mode = 'Gain'
		SELECT @ThisCount = count(*) 
		FROM	tractorprofile (NOLOCK)
		WHERE 	trc_startdate >= @DateStart and trc_startdate <= @DateEnd 
	ELSE
		SELECT @ThisCount = count(*) 
		FROM	tractorprofile (NOLOCK)
		WHERE 	trc_retiredate >= @DateStart and trc_retiredate <= @DateEnd 
		
	SELECT @ThisTotal = CASE WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) 
									THEN 1 ELSE DATEDIFF(day, @DateStart, @DateEnd) END
	
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
	
	--Show Detail
	If @ShowDetail=1
		BEGIN
			IF @Mode = 'Gain'
				SELECT trc_number as [Tractor ID],
						trc_startdate as [Start Date],
						trc_type1 as [TRCType1],
						trc_type2 as [TRCType2],
						trc_type3 as [TRCType3],
						trc_type4 as [TRCType4],
						trc_status as [Status]
				FROM	tractorprofile (NOLOCK)
				WHERE 	trc_startdate >= @DateStart and trc_startdate <= @DateEnd 
			ELSE
				SELECT 	trc_number as [Tractor ID],
						trc_startdate as [Start Date],
						trc_retiredate as [Retire Date],
						trc_type1 as [TRCType1],
						trc_type2 as [TRCType2],
						trc_type3 as [TRCType3],
						trc_type4 as [TRCType4],
						trc_status as [Status] 
				FROM	tractorprofile (NOLOCK)
				WHERE 	trc_retiredate >= @DateStart and trc_retiredate <= @DateEnd 	
			
	END

	SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[Metric_TractorGainLoss] TO [public]
GO
