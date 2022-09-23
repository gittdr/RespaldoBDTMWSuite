SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_PayTrendDecline] 
	(
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	@UseLast6MonthsToFindAverageYN Char(1) ='Y', 
	@PercentOffOfAverageToFlagAsDeclined decimal(20, 5) = .1, -- MAYBE USE THIS? => @DecliningPeriods = 3,
	@PassedInLowPayPeriodDate datetime = NULL,	
	@PassedInHighPayPeriodDate datetime = NULL, -- These dates are ignored if @UseLast6MonthsToFindAverageYN ='Y'
	@MetricCode varchar(255)='PayTrendDecline',
	@ExcludePayPeriodsWithExceptions Char(1) = 'N',
	@OnlyDrvType1List varchar(255)='',
	@OnlyDrvType2List varchar(255)='',
	@OnlyDrvType3List varchar(255)='',
	@OnlyDrvType4List varchar(255)='',
	@OnlyTrcType1List varchar(255)='',
	@OnlyTrcType2List varchar(255)='',
	@OnlyTrcType3List varchar(255)='',
	@OnlyTrcType4List varchar(255)='',
	@OnlyDrvTerminalList varchar(255)='',
	@OnlyTrcTerminalList varchar(255)=''
	
)

AS 
	SET NOCOUNT ON  -- PTS46367

	--Populate default currency and currency date types
        Exec PopulateSessionIDParamatersInProc 'Pay',@MetricCode  

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'PayTrendDecline', 
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 304, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Pay Trend Decline',
		@sCaptionFull = 'Pay Trend Decline',
		@sProcedureName = 'Metric_PayTrendDecline',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/

	/*		@CountOfDriversWith3SubAvePays 		Int	Out,
			@PercentOfDriversWithDecliningPay3PayPeriods decimal(20, 5)	Out,

			@CountOfDriversWith2OrMoreSubAvePays 	Int	Out,
			@PercentOfDriversWithDecliningPay2PayPeriods decimal(20, 5)	Out
	*/
	
	Declare @LowPayPeriodDate DateTime
	Declare @HighPayPeriodDate DateTime
	Declare @PayPeriodStart DateTime	
	Declare @TempAsgn_type char(6)
	Declare @TempAsgn_id char(12)
	Declare @TempPayPeriod datetime
	Declare @iCnt int
	Declare @LoopCounter Int
	Declare @debugvalue Decimal (10,3)
	
	SET @OnlyDrvType1List = ',' + ISNULL(@OnlyDrvType1List,'') + ','
	SET @OnlyDrvType2List = ',' + ISNULL(@OnlyDrvType2List,'') + ','
	SET @OnlyDrvType3List = ',' + ISNULL(@OnlyDrvType3List,'') + ','
	SET @OnlyDrvType4List = ',' + ISNULL(@OnlyDrvType4List,'') + ','
	SET @OnlyTrcType1List = ',' + ISNULL(@OnlyTrcType1List,'') + ','
	SET @OnlyTrcType2List = ',' + ISNULL(@OnlyTrcType2List,'') + ','
	SET @OnlyTrcType3List = ',' + ISNULL(@OnlyTrcType3List,'') + ','
	SET @OnlyTrcType4List = ',' + ISNULL(@OnlyTrcType4List,'') + ','
	SET @OnlyDrvTerminalList = ',' + ISNULL(@OnlyDrvTerminalList,'') + ','
	SET @OnlyTrcTerminalList = ',' + ISNULL(@OnlyTrcTerminalList,'') + ','
	

--IF EXISTS (SELECT * FROM sysobjects WHERE name = 'PayHistory')
--	DROP TABLE dbo.PayHistory
	
	-- Probably there is better way to find order of payperiod per driver, but this works
	CREATE TABLE #PayHistory (asgn_type	Char(6), asgn_id char(12), PayPeriod Datetime, totalcomp Money,	PayPeriodOrder int)
	CREATE INDEX py_id_ind ON #PayHistory (asgn_type, asgn_id, PayPeriod)


	SET NOCOUNT OFF

	IF (@UseLast6MonthsToFindAverageYN = 'Y') 		-- SELECT @LowPayPeriodDate = DATEADD(D, -190, GETDATE()), @HighPayPeriodDate = DATEADD(d, -3, GETDATE())
		SELECT @LowPayPeriodDate = DATEADD(D, -190, @DateStart), @HighPayPeriodDate = DATEADD(d, -3, @DateEnd)
	ELSE -- IF (@UseLast6MonthsToFindAverageYN <> 'Y')
		SELECT @LowPayPeriodDate = @PassedInLowPayPeriodDate, @HighPayPeriodDate = @PassedInHighPayPeriodDate

	INSERT INTO #PayHistory
	SELECT asgn_type, asgn_id, pyh_payperiod, pyh_totalcomp, 0 PayPeriodOrder 
	FROM payheader WITH (NOLOCK) 
		left join manpowerprofile (NOLOCK) on asgn_id = mpp_id 
			AND asgn_type = 'DRV' 
			AND mpp_terminationdt >= @HighPayPeriodDate
			AND (@OnlyDrvType1List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type1 ) + ',', @OnlyDrvType1List) >0)
			AND (@OnlyDrvType2List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type2 ) + ',', @OnlyDrvType2List) >0)
			AND (@OnlyDrvType3List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type3 ) + ',', @OnlyDrvType3List) >0)
			AND (@OnlyDrvType4List =',,' or CHARINDEX(',' + RTRIM( Mpp_Type4 ) + ',', @OnlyDrvType4List) >0)
			AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + RTRIM( Mpp_Terminal ) + ',', @OnlyDrvTerminalList) >0)
			
        left join TractorProfile (NOLOCK) on asgn_id = trc_number 
			AND asgn_type = 'TRC' 
			AND trc_retiredate >= @HighPayPeriodDate
			AND (@OnlyTrcType1List =',,' or CHARINDEX(',' + RTRIM( trc_Type1 ) + ',', @OnlyTrcType1List) >0)
			AND (@OnlyTrcType2List =',,' or CHARINDEX(',' + RTRIM( trc_Type2 ) + ',', @OnlyTrcType2List) >0)
			AND (@OnlyTrcType3List =',,' or CHARINDEX(',' + RTRIM( trc_Type3 ) + ',', @OnlyTrcType3List) >0)
			AND (@OnlyTrcType4List =',,' or CHARINDEX(',' + RTRIM( trc_Type4 ) + ',', @OnlyTrcType4List) >0)		
			AND (@OnlyTrcTerminalList =',,' or CHARINDEX(',' + RTRIM( trc_Terminal ) + ',', @OnlyTrcTerminalList) >0) 
	WHERE pyh_payperiod BETWEEN @LowPayPeriodDate AND @HighPayPeriodDate	
		AND asgn_type IN ('DRV', 'TRC')

	SELECT @TempAsgn_type = 'DRV', @TempAsgn_id = ''
	SET NOCOUNT ON

	SELECT @LoopCounter = 0
	
	-- Probably there is better way to find order of payperiod per driver, but this works	
	WHILE 1=1
	BEGIN
		SELECT @TempAsgn_id = MIN(asgn_id) 
			FROM #PayHistory 
			WHERE asgn_type = @TempAsgn_type
				AND asgn_id > @TempAsgn_id

		IF (@TempAsgn_id IS NULL)
		BEGIN
			IF (@TempAsgn_type = 'TRC') BREAK
			SELECT @TempAsgn_type = 'TRC', @TempAsgn_id =''	
			SELECT @TempAsgn_id = MIN(asgn_id) 
				FROM #PayHistory 
				WHERE asgn_type = @TempAsgn_type
					AND asgn_id > @TempAsgn_id

			IF (@TempAsgn_id IS NULL) BREAK
		END
		SET @TempPayPeriod = DATEADD(d, 1, @HighPayPeriodDate)
		SET @iCnt=0
		WHILE 1=1
		BEGIN
			SELECT @TempPayPeriod = MAX(PayPeriod) 
				FROM #PayHistory
				WHERE asgn_type = @TempAsgn_type
					AND	asgn_id = @TempAsgn_id
					AND	PayPeriod < @TempPayPeriod

			IF (@TempPayPeriod IS NULL) BREAK
			SET @icnt = @icnt + 1
			SET @LoopCounter = @LoopCounter + 1

			UPDATE #PayHistory 
			SET PayPeriodOrder = @icnt
			WHERE asgn_type = @TempAsgn_type
				AND	asgn_id = @TempAsgn_id
				AND	PayPeriod = @TempPayPeriod
			IF @ExcludePayPeriodsWithExceptions = 'Y' AND @icnt > 1
			BEGIN
				Set @PayPeriodStart = (SELECT PayPeriod FROM #PayHistory
				WHERE asgn_type = @TempAsgn_type
					AND	asgn_id = @TempAsgn_id
					AND	PayPeriodOrder = (@icnt - 1))

				IF (SELECT COUNT(*) FROM Expiration (NOLOCK)
					WHERE @TempAsgn_type = exp_idtype
					AND   @TempAsgn_id = exp_id
					AND (exp_expirationdate BETWEEN @PayPeriodStart AND @TempPayPeriod
					OR exp_compldate BETWEEN @PayPeriodStart AND @TempPayPeriod)) > 0
				BEGIN						
						DELETE #PayHistory 
						WHERE asgn_type = @TempAsgn_type
							AND	asgn_id = @TempAsgn_id
							AND	PayPeriodOrder = @icnt

						SET @icnt = @icnt - 1
				END
			END
		END
	END

	SELECT asgn_type, asgn_id, AVG(totalcomp) AvgComp, SUM(totalcomp) TotalComp, COUNT(payperiod) PayPeriodCount
		INTO #temp1
		FROM #PayHistory WITH (NOLOCK) 
		GROUP BY asgn_type , asgn_id
		HAVING COUNT(payperiod) > 3

	SELECT *, 
		CountOfPayInLast3PayPeriodNPercLessThanNorm = (SELECT COUNT(*)
											FROM #PayHistory
											WHERE #temp1.asgn_type = #PayHistory.asgn_type
												AND	#temp1.asgn_id = #PayHistory.asgn_id
												AND	PayPeriodOrder < 4
												AND	(totalcomp < (AvgComp * (1 - @PercentOffOfAverageToFlagAsDeclined))) 		
											),
		PayForLastPayPeriod = (SELECT totalcomp
								FROM #PayHistory
								WHERE #temp1.asgn_type = #PayHistory.asgn_type
									AND	#temp1.asgn_id = #PayHistory.asgn_id
									AND	PayPeriodOrder=1
								),
		PayPeriodDateForLastPayPeriod =	(SELECT PayPeriod
											FROM #PayHistory
											WHERE #temp1.asgn_type = #PayHistory.asgn_type
												AND	#temp1.asgn_id = #PayHistory.asgn_id
												AND	PayPeriodOrder = 1
										),			
		PayFor2ndToLastPayPeriod = (SELECT totalcomp
									FROM #PayHistory
									WHERE #temp1.asgn_type = #PayHistory.asgn_type
										AND #temp1.asgn_id = #PayHistory.asgn_id
										AND	PayPeriodOrder = 2
									),
		PayPeriodDateFor2ndToLastPayPeriod = (SELECT PayPeriod
												FROM #PayHistory
												WHERE #temp1.asgn_type = #PayHistory.asgn_type
												AND	#temp1.asgn_id = #PayHistory.asgn_id
												AND	PayPeriodOrder = 2
											),
		PayFor3rdToLastPayPeriod = (SELECT totalcomp
									FROM #PayHistory
									WHERE #temp1.asgn_type = #PayHistory.asgn_type
										AND	#temp1.asgn_id = #PayHistory.asgn_id
										AND	PayPeriodOrder = 3
									),
		PayPeriodDateFor3rdToLastPayPeriod = (SELECT PayPeriod
												FROM #PayHistory
												WHERE #temp1.asgn_type = #PayHistory.asgn_type
													AND	#temp1.asgn_id = #PayHistory.asgn_id
													AND	PayPeriodOrder = 3
												)		
		INTO #Results	
		FROM #temp1

	IF (@ShowDetail = 1) SELECT * FROM #Results
	SELECT @ThisTotal = COUNT(*) FROM #Results
	SELECT @ThisCount = COUNT(*) FROM #Results WHERE CountOfPayInLast3PayPeriodNPercLessThanNorm = 3

	-- SELECT @CountOfDriversWith2OrMoreSubAvePays = COUNT(*) FROM #Results WHERE CountOfPayInLast3PayPeriodNPercLessThanNorm > 2
	--Set @PercentOfDriversWithDecliningPay2PayPeriods = 0
		
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	DROP TABLE #temp1
	DROP TABLE #PayHistory
	DROP TABLE #Results	

	SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[Metric_PayTrendDecline] TO [public]
GO
