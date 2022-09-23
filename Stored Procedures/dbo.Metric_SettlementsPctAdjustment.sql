SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[Metric_SettlementsPctAdjustment]
	(	
		@Result decimal(20, 5) OUTPUT, @ThisCount decimal(20, 5) OUTPUT, @ThisTotal decimal(20, 5) OUTPUT, @DateStart datetime, @DateEnd datetime, @UseMetricParms int, 
		@ShowDetail int
		/*,

		@LowSettlementDate datetime, 
		@HighSettlementDate Datetime,
		@CountOfCleanPayDetails Int OUT,
		@CountOfCorrectedPayDetails Int OUT,
		@PercentageOfPaydetailsCorrected FLOAT OUT
		*/
	)
AS
	SET NOCOUNT ON  -- PTS46367


/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'SettlementsPctAdjustment', 
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 305, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Settlements % Adjustment',
		@sCaptionFull = 'Settlements % Adjustment',
		@sProcedureName = 'Metric_SettlementsPctAdjustment',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/

	/*
		--Returns Settlement accuracy for a date range - DM 3/3/03
		--Sample Call
		Declare	@LowSettlementDate datetime 
		Declare	@HighSettlementDate Datetime
		Declare	@CountOfCleanPayDetails Int 
		Declare	@CountOfCorrectedPayDetails Int 
		Declare	@PercentageOfPaydetailsCorrected FLOAT 
	
		Set @LowSettlementDate ='9/1/02'
		Set @HighSettlementDate ='9/30/02'
	
		Exec Metric_SettlementsPctAdjustment
			@LowSettlementDate , 
			@HighSettlementDate,
			@CountOfCleanPayDetails OUT,
			@CountOfCorrectedPayDetails OUT,
			@PercentageOfPaydetailsCorrected OUT
	
		Select	CountOfCleanPayDetails				=@CountOfCleanPayDetails,
			CountOfCorrectedPayDetails 	 		=@CountOfCorrectedPayDetails ,
			PercentageOfPaydetailsCorrected			=@PercentageOfPaydetailsCorrected 
		
	*/
	
	Declare		@LowSettlementDate datetime 
	Declare		@HighSettlementDate Datetime
	Declare		@CountOfCleanPayDetails Int 
	Declare		@CountOfCorrectedPayDetails Int 
	Declare		@PercentageOfPaydetailsCorrected FLOAT 
	
	Declare @DaysFromSunday int
	
		-- Find Settlement Periord for LAST WEEK
		Set @DaysFromSunday = (Select datepart(dw,@DateEnd))-1
		Set @HighSettlementDate =DateAdd(d,-@DaysFromSunday,@DateEnd)
		Set @LowSettlementDate =DateAdd(d,-7,@DateEnd)
	
	
	
	Declare @CountOfPayDetails Int
	
	Set @CountOfPayDetails =
	(
	select 
		count(*) 
	from PayDetail (NOLOCK)
	where 	pyh_payperiod  between @LowSettlementDate and @HighSettlementDate
	)
	
	Set @CountOfCorrectedPayDetails =
	(
	select 
		count(*) 
	from PayDetail (NOLOCK)
	where 	pyh_payperiod  between @LowSettlementDate and @HighSettlementDate
	
		and (pyd_amount<0 or pyd_minus=-1 or pyd_adj_flag<>'N') and pyd_pretax='Y' 
	
	)
	Set @CountOfCleanPayDetails = @CountOfPayDetails- @CountOfCorrectedPayDetails
		
	Set @PercentageOfPaydetailsCorrected =0
	If (@CountOfPayDetails>0) 
	BEGIN
		Set @PercentageOfPaydetailsCorrected =    Convert(Float,@CountOfCorrectedPayDetails)
							/
							Convert(Float,@CountOfPayDetails)
	END
	
	
	Select @ThisTotal = @CountOfPayDetails
	Select @ThisCount = @CountOfCorrectedPayDetails

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	If (@ShowDetail=1)
	BEGIN
		Select 	@LowSettlementDate LowSettlementDateUsed,
			@HighSettlementDate HighSettlementDateUsed,
			@CountOfCleanPayDetails CountOfCleanPayDetails,
			@CountOfCorrectedPayDetails CountOfCorrectedPayDetails,
			@PercentageOfPaydetailsCorrected PercentageOfPaydetailsCorrected

	END
GO
GRANT EXECUTE ON  [dbo].[Metric_SettlementsPctAdjustment] TO [public]
GO
