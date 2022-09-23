SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create Proc [dbo].[Metric_MajorCustBillMiles]	-- NORMAL RUN AS DETAIL REPORT for @UseLast7DaysFromDateEnd Char(1)='Y'
	(	
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	@TopN	Int =10,
	@UseLast7DaysFromDateEnd Char(1)='Y',

	@OnlyRevClass1List varchar(128) ='',
	@OnlyRevClass2List varchar(128) ='',
	@OnlyRevClass3List varchar(128) ='',
	@OnlyRevClass4List varchar(128) =''

	)
AS 
	SET NOCOUNT ON  -- PTS46367

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'MajorCustBillMiles', 
		@nActive = 1,	-- 1=active, 0=inactive.
		@nSort = 701, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Major Customer Bill Miles',
		@sCaptionFull = 'Major Customer Bill Miles',
		@sProcedureName = 'Metric_MajorCustBillMiles',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'Y', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = 'DetailReports'

	</METRIC-INSERT-SQL>
*/


	Declare @DisplayResultsFromCacheYN Char(1)

	Declare	@LowDate DateTime
	Declare	@HighDate DateTime
	Declare @PrevPeriodLowDate DateTime
	Declare @PrevPeriodhighDate DateTime
	Declare @CurDTRange varchar(20)
	Declare @PrevDTRange varchar(20)
	Declare @DebugCheatMilesLastWeek int

	Declare @LowBookDate DateTime	-- There is a book date index
	Declare @highBookDate DateTime
	Declare @LowBookDate4WeeksAgo DateTime	-- There is a book date index
	Declare @highBookDate4WeeksAgo DateTime
	
	IF ISNULL((SELECT ParmValue FROM MetricParameter WITH (NOLOCK) 
		WHERE Heading = 'Config' AND SubHeading = 'All' AND ParmName = 'DemoModeYN'), 'N') = 'Y'

	IF (@DisplayResultsFromCacheYN='Y')
	BEGIN
		IF ISNULL((SELECT ParmValue FROM MetricParameter WITH (NOLOCK) 
					WHERE Heading = 'Config' AND SubHeading = 'All' AND ParmName = 'DemoModeYN'), 'N') = 'Y'
		BEGIN
			Select BilledMiles	,
				BilltoName 	,
				DateRange	,
				ChangeFrom4WeeksAgo 		,
				FourWeeksAgoMiles	,
				AverageForLast6Months 	,
				ChangeFromAve	,
				Rank		
			from MetricCacheMajorCustMiles 
			WHERE
						DateStart =@DateStart
						AND
						DateEnd =@DateEnd
						AND
						@TopN=TopN	
						AND
						@UseLast7DaysFromDateEnd = UseLast7DaysFromDateEnd 
						AND @OnlyRevClass1List= OnlyRevClass1List 
						AND @OnlyRevClass2List= OnlyRevClass2List 
						AND @OnlyRevClass3List= OnlyRevClass3List 
						AND @OnlyRevClass4List= OnlyRevClass4List 
			order by Rank

			RETURN
		END
	END

	Create Table #RankedBilltos
	(
		Rank	int identity(1,1),
		BilledMiles Int,
		FourWeeksAgoMiles Int,
		BillToID Varchar(8),
		BilltoName Varchar(20),
		DateRange Varchar(20),
		Change Varchar(20)
	)

	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	Set @DisplayResultsFromCacheYN =
		ISNULL(

		(Select 'Y'
		WHERE
			EXISTS (Select * 
				From MetricCacheMajorCustMiles
				Where 
					DateStart =@DateStart
					AND
					DateEnd =@DateEnd
					and
					ABS(DateDiff(hh,GetDate(),IsNull(LastUpdatedDate,'19500101'))) < 24
					AND
					@TopN=TopN	
					AND
					@UseLast7DaysFromDateEnd = UseLast7DaysFromDateEnd 
					AND @OnlyRevClass1List= OnlyRevClass1List 
					AND @OnlyRevClass2List= OnlyRevClass2List 
					AND @OnlyRevClass3List= OnlyRevClass3List 
					AND @OnlyRevClass4List= OnlyRevClass4List 


				)
		)
		,'N')
	IF (@DisplayResultsFromCacheYN='Y')
	BEGIN
		Select 
			BilledMiles	,
			BilltoName 	,
			DateRange	,
			ChangeFrom4WeeksAgo 		,
			FourWeeksAgoMiles	,
			AverageForLast6Months 	,
			ChangeFromAve	,
			Rank		
 

		from MetricCacheMajorCustMiles 
		WHERE
					DateStart =@DateStart
					AND
					DateEnd =@DateEnd
					and
					ABS(DateDiff(hh,GetDate(),IsNull(LastUpdatedDate,'19500101'))) < 24
					AND
					@TopN=TopN	
					AND
					@UseLast7DaysFromDateEnd = UseLast7DaysFromDateEnd 
					AND @OnlyRevClass1List= OnlyRevClass1List 
					AND @OnlyRevClass2List= OnlyRevClass2List 
					AND @OnlyRevClass3List= OnlyRevClass3List 
					AND @OnlyRevClass4List= OnlyRevClass4List 

		order by Rank


		SET  @ThisTotal = (Select Max(IsNull(ThisTotal,0)) from MetricCacheMajorCustMiles
		WHERE
					DateStart =@DateStart
					AND
					DateEnd =@DateEnd
					and
					ABS(DateDiff(hh,GetDate(),IsNull(LastUpdatedDate,'19500101'))) < 24
					AND
					@TopN=TopN	
					AND
					@UseLast7DaysFromDateEnd = UseLast7DaysFromDateEnd 
					AND @OnlyRevClass1List= OnlyRevClass1List 
					AND @OnlyRevClass2List= OnlyRevClass2List 
					AND @OnlyRevClass3List= OnlyRevClass3List 
					AND @OnlyRevClass4List= OnlyRevClass4List 

		)
		
		SET   @ThisCount = (Select Max(IsNull(ThisCount,0)) from MetricCacheMajorCustMiles
		WHERE
					DateStart =@DateStart
					AND
					DateEnd =@DateEnd
					and
					ABS(DateDiff(hh,GetDate(),IsNull(LastUpdatedDate,'19500101'))) < 24
					AND
					@TopN=TopN	
					AND
					@UseLast7DaysFromDateEnd = UseLast7DaysFromDateEnd 
					AND @OnlyRevClass1List= OnlyRevClass1List 
					AND @OnlyRevClass2List= OnlyRevClass2List 
					AND @OnlyRevClass3List= OnlyRevClass3List 
					AND @OnlyRevClass4List= OnlyRevClass4List 

		)

		
		SET   @Result = (Select Max(IsNull(Result,0)) from MetricCacheMajorCustMiles
		WHERE
					DateStart =@DateStart
					AND
					DateEnd =@DateEnd
					and
					ABS(DateDiff(hh,GetDate(),IsNull(LastUpdatedDate,'19500101'))) < 24
					AND
					@TopN=TopN	
					AND
					@UseLast7DaysFromDateEnd = UseLast7DaysFromDateEnd 
					AND @OnlyRevClass1List= OnlyRevClass1List 
					AND @OnlyRevClass2List= OnlyRevClass2List 
					AND @OnlyRevClass3List= OnlyRevClass3List 
					AND @OnlyRevClass4List= OnlyRevClass4List 

		)

		RETURN
	END

	DELETE MetricCacheMajorCustMiles WHERE ABS(DateDiff(hh,GetDate(),IsNull(LastUpdatedDate,'19500101'))) < 24

-- Wipe out any cache. Rerunning it now


	/*
	Create Table #results
	(
		Miles Int ,
		BillToID Varchar(8),
		BilltoName Varchar(20),
		DateRange Varchar(20),
		Rank Int,
		TimePeriod Varchar(20),
		Change 	 Varchar(20)	 	 
	)
	*/

	Set @LowDate= @DateStart
	Set @HighDate= @DateEnd

	if (@UseLast7DaysFromDateEnd ='Y')
	BEGIN
		Set @HighDate= convert(datetime,Floor(  convert(float,@DateEnd) ))
		Set @LowDate= DateAdd(d,-7,@HighDate) 
	END


	Set @PrevPeriodLowDate =DateAdd(d,-28,@LowDate) 
	Set @PrevPeriodhighDate=DateAdd(d,-28,@highDate) 

	Set @CurDTRange		=	Convert(varchar(5),@LowDate,1) +'-' + Convert(varchar(5),@HighDate,1)
	Set @PrevDTRange	=	Convert(varchar(5),@PrevPeriodLowDate,1) +'-' + Convert(varchar(5),@PrevPeriodHighDate,1)


	Set @LowBookDate = DateAdd(d,-10,@LowDate) 
	Set @highBookDate =@HighDate
	Set @LowBookDate4WeeksAgo =DateAdd(d,-28,@LowBookDate) 
	Set @highBookDate4WeeksAgo=DateAdd(d,-28,@highBookDate) 


	Insert into #RankedBilltos

	Select 
		sum(stp_ord_mileage) BilledMiles,
		FourWeeksAgoMiles=	
			(Select 
				sum(stp_ord_mileage)
			From
				Stops S WITH (NOLOCK, INDEX=sk_stp_ordnum),
				Orderheader o2 (NOLOCK)
			where
				o2.ord_BookDate between @LowBookDate4WeeksAgo and @highBookDate4WeeksAgo 
				And
				o2.ord_completiondate between @PrevPeriodLowDate and @PrevPeriodhighDate
				and
				s.ord_hdrnumber=o2.ord_hdrnumber
				and
				o2.ord_status='CMP'
				and
				o2.ord_billto=o.ord_billto
			),
		ord_billto	BillToID,
		BilltoName=(Select left(cmp_name,20) from company (NOLOCK) where cmp_id=ord_billto),
		DateRange = @CurDTRange,
		'' Change
	From
		Stops S WITH (noLock, INDEX=sk_stp_ordnum),
		Orderheader o (nolock)
	where
		ord_BookDate between @LowBookDate and @highBookDate 
		AND
		ord_completiondate between @LowDate and @highDate
		and
		s.ord_hdrnumber=o.ord_hdrnumber
		and
		ord_status='CMP'
	Group by ord_billto 
	order by BilledMiles Desc 

	Update #RankedBilltos
		Set Change =	Convert(varchar(20),
					Convert(decimal(9,2),
					 (1.00- convert(float,FourWeeksAgoMiles)/ convert(float,BilledMiles) ) * 100
					)		
				)+'%'
		WHERE BilledMiles>0


	/*
	Set Rowcount 20
	Select 	* from #RankedBilltos

	INSERT INTO #results
	Select 
		BilledMiles Miles,
		BillToID,
		BilltoName,
		DateRange,
		Rank,
		'CurrentPeriod' TimePeriod,	 
		'' Change 
	from 
		#RankedBilltos

	UNION
	Select 
		FourWeeksAgoMiles Miles,
		BillToID,
		BilltoName,
		@PrevDTRange,
		Rank,
		'PrevPeriod' TimePeriod,
		'' Change 	 	 	 
	from 
		#RankedBilltos
	order by Rank,TimePeriod

	Set Rowcount 0

	Update #results
		Set Change =
			(select 
				Convert(varchar(20),
					Convert(decimal(9,2),
					 (1.00- convert(float,BilledMiles)/ convert(float,FourWeeksAgoMiles) ) * 100
					)
				)+'%' c
			From 	#RankedBilltos

			where 	#results.billtoID= #RankedBilltos.billtoID
				AND
				TimePeriod='CurrentPeriod' 
			)
		WHERE TimePeriod='CurrentPeriod'

		
	
	IF (@ShowDetail = 1) 
	BEGIN
		SELECT 
			Miles,
			Change,
			(CASE WHEN TimePeriod='PrevPeriod' Then '' else BillToID end) BillToID,
			(CASE WHEN TimePeriod='PrevPeriod' Then '' else BilltoName end) BilltoName ,
			DateRange ,
			Rank ,
			TimePeriod 
		

		FROM #results 
		order by Rank,TimePeriod 

		
	END
	*/


	SET  @ThisTotal = 1
	SET   @ThisCount = (select SUM(BilledMiles) from #RankedBilltos where Rank<=@TopN)
	SET   @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 

	IF (@ShowDetail = 1) 
	BEGIN
		Select 
			BilledMiles,
			BilltoName,
			DateRange,
			Change ChangeFrom4WeeksAgo,
			FourWeeksAgoMiles,
			AverageForLast6Months= 	(select sum(stp_ord_mileage)
					From stops s (NOLOCK), orderheader o (NOLOCK)
					where o.Ord_bookdate between dateAdd(d,-26 * 7,@HighDate) and @HighDate
					and o.ord_status='CMP'
					and o.ord_billto=#RankedBilltos.billtoId
					and s.ord_hdrnumber=o.ord_hdrnumber
					)
					*
					( Convert(int,@HighDate) -Convert(int,@LowDate) ) / (26*7),
			convert(varchar(20),'') ChangeFromAve,
			Rank
			/*
			ChangeFromAve=
				Convert(varchar(20),
					Convert(decimal(9,2),
					 (1.00- convert(float,AverageForLast6Months)/ convert(float,BilledMiles) ) * 100
					)		
				)+'%'
			*/
		Into #t
		from #RankedBilltos where Rank<=@TopN		
		order by Rank 
		Update #t 
			Set 			ChangeFromAve=
				Convert(varchar(20),
					Convert(decimal(9,2),
					 (1.00- convert(float,AverageForLast6Months)/ convert(float,BilledMiles) ) * 100
					)		
				)+'%'
		Select * from #t order by Rank

		insert into  MetricCacheMajorCustMiles
		Select 
			GetDate() LastUpdatedDate	,

			BilledMiles	,
			BilltoName 	,
			DateRange	,
			ChangeFrom4WeeksAgo	,
			FourWeeksAgoMiles	,
			AverageForLast6Months 	,
			ChangeFromAve	,
			Rank		,
	
			@DateStart DateStart , 
			@DateEnd DateEnd , 
			@TopN TopN	,
			@UseLast7DaysFromDateEnd UseLast7DaysFromDateEnd ,
			@Result Result  , 
			@ThisCount ThisCount  , 
			@ThisTotal ThisTotal,
			@OnlyRevClass1List OnlyRevClass1List, 
			@OnlyRevClass2List OnlyRevClass2List, 
			@OnlyRevClass3List OnlyRevClass3List, 
			@OnlyRevClass4List OnlyRevClass4List 




		From #T


	END
GO
GRANT EXECUTE ON  [dbo].[Metric_MajorCustBillMiles] TO [public]
GO
