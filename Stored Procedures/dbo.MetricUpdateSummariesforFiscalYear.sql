SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateSummariesforFiscalYear] 
(
	@MetricCodePassed VARCHAR(200) = NULL, 
	@DateFirstProcessDate datetime = NULL, 
	@Debug_Level int = NULL,
	@DateLastProcessDate datetime = NULL,
	@BatchGUID varchar(36) = NULL
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	-- Runs: ALWAYS at the end of MetricProcessing.

	DECLARE @MetricCode varchar(200)
	DECLARE @DateCur datetime, @DateLow datetime, @DateHigh datetime, @ProcName varchar(100)
	DECLARE @result decimal(20, 5), @ThisCount decimal(20, 5), @ThisTotal decimal(20, 5)
	DECLARE @DateStart datetime, @DateEnd datetime, @StartDateTime datetime, @MetricStartDate datetime
	DECLARE @ProcTime datetime, @ProcTimeEnd datetime, @ProcRunDuration decimal(9, 3)
	DECLARE @sTemp varchar(255)
	DECLARE @nCumulative int, @AdjustTo5DayWeekYN varchar(1)
	DECLARE @DoNotIncludeTotalForNonBusinessDayYN char(1) -- Total here refers to denominator. Actually, if there is no business day for time frame, then use it to estimate it.
	DECLARE @DateFirst int
	DECLARE @FormatText varchar(12)
	DECLARE @FiscalYTD	decimal(20,5)
	DECLARE @dBusinessDaysStart datetime, @dBusinessDaysEnd datetime
	DECLARE @FiscalStartDate varchar(5)
	DECLARE @DistinctItems int
	DECLARE @MSG varchar(1000)

	DECLARE @MetricDetailUseForUpdates TABLE (SPID int, DateInserted datetime DEFAULT getdate(), MetricCode varchar(200), DailyValue decimal(20, 5), DailyCount decimal(20, 5), DailyTotal decimal(20, 5), Upd_Summary datetime, PlainDate datetime, 
		ThisWTD decimal(20, 5), ThisMTD decimal(20, 5), ThisQTD decimal(20, 5), ThisYTD decimal(20, 5),
		WeeklyAve decimal(20, 5), MonthlyAve decimal(20, 5), QuarterlyAve decimal(20, 5), YearlyAve decimal(20, 5),
		PlainDayOfWeek int, PlainWeek int, PlainMonth int, PlainQuarter int, PlainYear int, PlainYearWeek int, RecordExists int DEFAULT(0),
		upd_daily datetime, ThisFiscalYTD decimal (20, 5), FiscalYearlyAve decimal (20, 5), PlainFiscalYear int
		) 
	DECLARE @MetricTempYear TABLE (spid int, YearlyAve decimal(20, 5), PlainYear int)

	SET NOCOUNT ON

	SELECT @sTemp = @MetricCodePassed 
				+ ', DtStart=' + ISNULL(CONVERT(varchar(10), @DateFirstProcessDate, 121), 'NULL Date')
				+ ', DtEnd=' + ISNULL(CONVERT(varchar(10), @DateLastProcessDate, 121), 'NULL Date')
	INSERT INTO ResNowLog (MetricCode, source, longdesc)
		VALUES (ISNULL(@MetricCodePassed, 'All Active'), 'UpdateSummaryFiscal', 'Fiscal summaries: ' + @sTemp)

	SELECT @StartDateTime = GETDATE()	-- This datetime is used to stamp MetricDetail.Upd_Summary

	-- Loop through all active MetricCodes.
	-- NOTE: Write message to log table if the stored procedure does not exist.
	IF @MetricCodePassed IS NULL 
		SELECT @MetricCode = MetricCode FROM metricitem WITH (NOLOCK) WHERE sn = (SELECT MIN(sn) FROM MetricItem WITH (NOLOCK) WHERE Active = 1)
	ELSE
		SELECT @MetricCode = @MetricCodePassed 

	IF ISNULL(@Debug_Level, 0) = 1
	BEGIN
		SELECT @msg = 'MetricUpdateSummaries for Fiscal Year has started.' + CHAR(13) + CHAR(10)
			+ '@MetricCodePassed = ' + ISNULL(@MetricCode, 'NULL') + CHAR(13) + CHAR(10)
			+ '@DateFirstProcessDate = ' + CONVERT(varchar(100), @DateFirstProcessDate) + CHAR(13) + CHAR(10)
			+ '@DateLastProcessDate = ' + CONVERT(varchar(100), @DateLastProcessDate) + CHAR(13) + CHAR(10)
			+ '@DateEnd (last day to update MetricDetail) = ' + CONVERT(varchar(100), @DateEnd) + CHAR(13) + CHAR(10)
		PRINT @msg
	END

	WHILE @MetricCode IS NOT NULL
	BEGIN 	-- 'BEGIN' for main while loop.
		SELECT @ProcName = ISNULL(ProcedureName, ''),
				@nCumulative = Cumulative,
				@DoNotIncludeTotalForNonBusinessDayYN = CASE WHEN ISNULL(DoNotIncludeTotalForNonBusinessDayYN, 'N') NOT IN ('N', 'Y') THEN 'N' ELSE ISNULL(DoNotIncludeTotalForNonBusinessDayYN, 'N') END,
				@FormatText = FormatText,
				@MetricStartDate = CASE WHEN StartDate = '' THEN NULL ELSE StartDate END 
			FROM MetricItem WITH (NOLOCK) WHERE MetricCode = @MetricCode
		IF NOT EXISTS(SELECT * FROM sysobjects WITH (NOLOCK) WHERE name = @ProcName AND type = 'p')
			INSERT INTO ResNowLog (MetricCode, source, longdesc) VALUES (@MetricCode, 'Metrics', 'Missing stored procedure: ' + @ProcName)
		ELSE
		BEGIN	-- The 'BEGIN' for IF bad stored procedure name.
			-- Always go back to first entry in MetricDetail for this year.
			-- If a StartDate exists in MetricItem for that metriccode, delete all entries before this date (for that metriccode).			SELECT @DateStart = NULL

			SELECT @FiscalStartDate = ISNULL((SELECT settingvalue from MetricGeneralSettings where settingname = 'FiscalYearStart'), '01/01')
			IF @FiscalStartDate = ''
			BEGIN
				SELECT @FiscalStartDate = '01/01'
				UPDATE MetricGeneralSettings SET SettingValue = '01/01' where settingname = 'FiscalYearStart'
			END

			IF @DateFirstProcessDate < cast(@FiscalStartDate + '/' + cast(datepart(yyyy,@DateFirstProcessDate) as varchar(4)) as datetime)
				SET @DateStart = dateadd(yyyy,-1,cast(@FiscalStartDate + '/' + cast(datepart(yyyy,@DateFirstProcessDate) as varchar(4)) as datetime))
			ELSE
				SET @DateStart = cast(@FiscalStartDate + '/' + cast(datepart(yyyy,@DateFirstProcessDate) as varchar(4)) as datetime)

			SET @DateEnd = @DateLastProcessDate

			INSERT INTO @MetricDetailUseForUpdates 
				(SPID, RecordExists, MetricCode, PlainDate, DailyValue, 
				DailyCount, DailyTotal, Upd_Daily, PlainFiscalYear)
			SELECT @@SPID, 1, MetricCode, PlainDate, DailyValue, 
				DailyCount, DailyTotal, Upd_Daily, PlainFiscalYear
			FROM MetricDetail WITH (NOLOCK)
			WHERE MetricCode = @MetricCode
				AND PlainDate BETWEEN @DateStart AND @DateEnd

			IF ISNULL(@Debug_Level, 0) = 1
			BEGIN
				SELECT @sTemp = 'Summary for @MetricCode ' + @MetricCode + CHAR(13) + CHAR(10)
							+ '@DateStart (This is date at which rollups will actually start) = ' + CONVERT(varchar(100), @DateStart) 
							+ CHAR(13) + CHAR(10)
				IF @DateFirstProcessDate > @DateEnd
				BEGIN
					SELECT @sTemp = @sTemp + 'The date at which summaries should start being rolled up (@DateFirstProcessDate) '
						+ 'occurs after the @DateEnd, so no updates will ONLY be done up to @DateEnd.'
				END

				PRINT @sTemp
			END
			--</STEP>
			
			-- We are going to reverse the order of the calculations
			-- 1) Do Fiscal Year first
			
			SELECT @DateCur = @DateStart

			WHILE @DateCur <= @DateEnd
			--*************************************************************************************
			-- Fiscal YEAR.
			--*************************************************************************************
			BEGIN

				IF @DateCur < cast(@FiscalStartDate + '/' + cast(datepart(yyyy,@DateCur) as varchar(4)) as datetime)
					SET @DateLow = dateadd(yyyy,-1,cast(@FiscalStartDate + '/' + cast(datepart(yyyy,@DateCur) as varchar(4)) as datetime))
				ELSE
					SET @DateLow = cast(@FiscalStartDate + '/' + cast(datepart(yyyy,@DateCur) as varchar(4)) as datetime)

				SET @DateHigh = @DateCur -- dateadd(d,1,@DateCur)

				SELECT @ThisCount = SUM(ISNULL(DailyCount, 0)), 
						@ThisTotal = SUM(ISNULL(DailyTotal, 0)) 
					FROM @MetricDetailUseForUpdates 
					WHERE SPID = @@SPID 
						AND PlainDate BETWEEN @DateLow AND @DateHigh
						AND Upd_Daily IS NOT NULL

				SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) FROM MetricDetailInfo (NOLOCK) WHERE PlainDate Between @DateLow AND @DateHigh AND MetricCode = @MetricCode),0)
				IF @DistinctItems > 0 
					SET @ThisTotal = @DistinctItems 

				IF ISNULL(@Debug_Level, 0) = 1
				BEGIN
					SELECT @msg = '1DateLow: ' + cast(@DateLow as varchar(20)) + ' ~ DateHigh: ' + cast(@DateHigh as varchar(20)) + ' ~ ThisCount: ' + cast(isnull(@ThisCount,0) as varchar(20)) + ' ~ ThisTotal: ' + cast(ISnull(@ThisTotal,0) as varchar(20))
					PRINT @msg
				END

				-- The standard way to calculate this is to SUM(Count) / SUM(Total) ==>> like Rev/Mile is just SUM(Rev)/Sum(Miles)
				IF (@nCumulative = 0) 
				BEGIN
					IF @DoNotIncludeTotalForNonBusinessDayYN = 'Y'  -- Total here refers to denominator.
					BEGIN
						SELECT @ThisTotal = SUM(ISNULL(DailyTotal, 0)) 
						FROM @MetricDetailUseForUpdates t1 INNER JOIN MetricBusinessDays t2 WITH (NOLOCK) ON t1.PlainDate = t2.PlainDate 
						WHERE t1.SPID = @@SPID
							AND BusinessDay = 1
							AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
							AND Upd_Daily IS NOT NULL
	
						IF ISNULL(@Debug_Level, 0) = 1
						BEGIN
							SELECT @msg = '2DateLow: ' + cast(@DateLow as varchar(20)) + ' ~ DateHigh: ' + cast(@DateHigh as varchar(20)) + ' ~ ThisCount: ' + cast(isnull(@ThisCount,0) as varchar(20)) + ' ~ ThisTotal: ' + cast(ISnull(@ThisTotal,0) as varchar(20)) + ' ~ 3: ' + cast(ISnull(@Result,0) as varchar(20))
							PRINT @msg
						END

						IF ISNULL(@ThisTotal, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
								SELECT @ThisTotal = SUM(ISNULL(DailyTotal, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL
						IF ISNULL(@Debug_Level, 0) = 1
						BEGIN
							SELECT @msg = '3DateLow: ' + cast(@DateLow as varchar(20)) + ' ~ DateHigh: ' + cast(@DateHigh as varchar(20)) + ' ~ ThisCount: ' + cast(isnull(@ThisCount,0) as varchar(20)) + ' ~ ThisTotal: ' + cast(ISnull(@ThisTotal,0) as varchar(20)) + ' ~ Result: ' + cast(ISnull(@Result,0) as varchar(20))
							PRINT @msg
						END

						IF @FormatText = 'PCT'	-- 5/21/2004: DAG
						BEGIN
							SELECT @ThisCount = SUM(ISNULL(DailyCount, 0)) 
							FROM @MetricDetailUseForUpdates t1 INNER JOIN MetricBusinessDays t2 WITH (NOLOCK) ON t1.PlainDate = t2.PlainDate 
							WHERE t1.SPID = @@SPID 
								AND BusinessDay = 1
								AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
								AND Upd_Daily IS NOT NULL  -- Do NOT count this day if MetricProcessing has not run against it.
							IF ISNULL(@Debug_Level, 0) = 1
							BEGIN
								SELECT @msg = '4DateLow: ' + cast(@DateLow as varchar(20)) + ' ~ DateHigh: ' + cast(@DateHigh as varchar(20)) + ' ~ ThisCount: ' + cast(isnull(@ThisCount,0) as varchar(20)) + ' ~ ThisTotal: ' + cast(ISnull(@ThisTotal,0) as varchar(20)) + ' ~ Result: ' + cast(ISnull(@Result,0) as varchar(20))
								PRINT @msg
							END

							IF ISNULL(@ThisCount, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
								SELECT @ThisCount = SUM(ISNULL(DailyCount, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL
							IF ISNULL(@Debug_Level, 0) = 1
							BEGIN
								SELECT @msg = '5DateLow: ' + cast(@DateLow as varchar(20)) + ' ~ DateHigh: ' + cast(@DateHigh as varchar(20)) + ' ~ ThisCount: ' + cast(isnull(@ThisCount,0) as varchar(20)) + ' ~ ThisTotal: ' + cast(ISnull(@ThisTotal,0) as varchar(20)) + ' ~ Result: ' + cast(ISnull(@Result,0) as varchar(20))
								PRINT @msg
							END

						END
					END
				END
				ELSE
				BEGIN
					-- ASSUMPTION::: If businessday table has any entries, then the relevant entries ARE present.
					-- SUGGESTION:: Change logic to use an OUTER join.  If NULL or zero indicates no business day.
					IF @DoNotIncludeTotalForNonBusinessDayYN = 'N' -- Total here refers to denominator.
					BEGIN
						SELECT @ThisTotal = AVG(ISNULL(DailyTotal, 0))
						FROM @MetricDetailUseForUpdates
						WHERE SPID = @@SPID
							AND PlainDate BETWEEN @DateLow AND @DateHigh
							AND Upd_Daily IS NOT NULL
						IF ISNULL(@Debug_Level, 0) = 1
						BEGIN
							SELECT @msg = '6DateLow: ' + cast(@DateLow as varchar(20)) + ' ~ DateHigh: ' + cast(@DateHigh as varchar(20)) + ' ~ ThisCount: ' + cast(isnull(@ThisCount,0) as varchar(20)) + ' ~ ThisTotal: ' + cast(ISnull(@ThisTotal,0) as varchar(20)) + ' ~ Result: ' + cast(ISnull(@Result,0) as varchar(20))
							PRINT @msg
						END

					END
					ELSE
					BEGIN
						-- SELECT @DaysForApprox = COUNT(*) FROM MetricBusinessDays WITH (NOLOCK) WHERE PlainDate BETWEEN @DateLow AND @DateHigh AND BusinessDay = 1
						-- IF @DaysForApprox = 0 SELECT @DaysForApprox = 1  -- Self-correcting for Sunday for example.  On Monday, things should be all better.
						SELECT @ThisTotal = AVG(ISNULL(DailyTotal, 0)) 
						FROM @MetricDetailUseForUpdates t1 INNER JOIN MetricBusinessDays t2 WITH (NOLOCK) ON t1.PlainDate = t2.PlainDate 
						WHERE t1.SPID = @@SPID
							AND BusinessDay = 1
							AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
							AND Upd_Daily IS NOT NULL
						
						IF ISNULL(@Debug_Level, 0) = 1
						BEGIN
							SELECT @msg = '7DateLow: ' + cast(@DateLow as varchar(20)) + ' ~ DateHigh: ' + cast(@DateHigh as varchar(20)) + ' ~ ThisCount: ' + cast(isnull(@ThisCount,0) as varchar(20)) + ' ~ ThisTotal: ' + cast(ISnull(@ThisTotal,0) as varchar(20)) + ' ~ Result: ' + cast(ISnull(@Result,0) as varchar(20))
							PRINT @msg
						END

						IF ISNULL(@ThisTotal, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
								SELECT @ThisTotal = AVG(ISNULL(DailyTotal, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL

						IF ISNULL(@Debug_Level, 0) = 1
						BEGIN
							SELECT @msg = '8DateLow: ' + cast(@DateLow as varchar(20)) + ' ~ DateHigh: ' + cast(@DateHigh as varchar(20)) + ' ~ ThisCount: ' + cast(isnull(@ThisCount,0) as varchar(20)) + ' ~ ThisTotal: ' + cast(ISnull(@ThisTotal,0) as varchar(20)) + ' ~ Result: ' + cast(ISnull(@Result,0) as varchar(20))
							PRINT @msg
						END

					END
				END
			
				SELECT @Result = CASE WHEN @ThisTotal = 0 THEN 0 ELSE @ThisCount / @ThisTotal END

				IF ISNULL(@Debug_Level, 0) = 1
				BEGIN
					SELECT @msg = 'FinalDateLow: ' + cast(@DateLow as varchar(20)) + ' ~ DateHigh: ' + cast(@DateHigh as varchar(20)) + ' ~ ThisCount: ' + cast(isnull(@ThisCount,0) as varchar(20)) + ' ~ ThisTotal: ' + cast(ISnull(@ThisTotal,0) as varchar(20)) + ' ~ Result: ' + cast(ISnull(@Result,0) as varchar(20))
					PRINT @msg
				END

				-- don't update yet
				SET @FiscalYTD = @Result
				SELECT @Result = NULL

				-- We do insert/update only once
				IF EXISTS(SELECT * FROM @MetricDetailUseForUpdates WHERE SPID = @@SPID AND PlainDate = @DateCur) 
				BEGIN
					UPDATE 	@MetricDetailUseForUpdates 
					SET 	ThisFiscalYTD = @FiscalYTD,
							PlainfiscalYear = DATEPART(yyyy, @DateLow)
					WHERE SPID = @@SPID AND PlainDate = @DateCur
				END
				ELSE
				BEGIN
					INSERT INTO @MetricDetailUseForUpdates 
							(SPID, MetricCode, PlainDate, ThisFiscalYTD,PlainFiscalYear)
					SELECT @@SPID, @MetricCode, @DateCur, @FiscalYTD, DATEPART(yyyy, @DateLow)
				END

				SELECT @Result = NULL, @DateCur = DATEADD(DAY, 1, @DateCur) 
			END

		END -- The 'END' for IF bad stored procedure name.

		--***************************************************************************************************************************************
		-- This section finds the actual Time Frame values as opposed to "To-Date" values as if viewed from that particular time in history.
		--***************************************************************************************************************************************	
		-- Yearly totals in MetricTempYear
		--MetricTempYear will be reused in this instance for Fiscal Year without changing the column headings to Fiscal...
		--TRUNCATE TABLE MetricTempYear -- DELETE MetricTempYear WHERE spid = @@spid

		INSERT INTO @MetricTempYear (spid, YearlyAve, PlainYear )
		SELECT @@spid, ISNULL(t1.ThisFiscalYTD, 0) AS YearlyAve, PlainFiscalYear 
		FROM @MetricDetailUseForUpdates t1 
		WHERE SPID = @@SPID		-- AND PlainDate < @DateEnd 
			AND t1.PlainDate = 	(
									SELECT MAX(PlainDate) 
									FROM @MetricDetailUseForUpdates 
									WHERE SPID = @@SPID AND PlainFiscalYear = t1.PlainFiscalYear
								)

		UPDATE @MetricDetailUseForUpdates SET 
			FiscalYearlyAve = t2.YearlyAve 
		FROM @MetricDetailUseForUpdates t1 INNER JOIN @MetricTempYear t2 ON t1.PlainFiscalYear = t2.PlainYear AND t2.spid = @@spid

		--**** Now, transfer to MetricDetail at one time.
		UPDATE MetricDetail
		SET Upd_SummaryFiscal = @StartDateTime, PlainDate = t1.PlainDate, 
			ThisFiscalYTD = t1.ThisFiscalYTD,
			FiscalYearlyAve = t1.FiscalYearlyAve,
			PlainFiscalYear = t1.PlainFiscalYear
		FROM @MetricDetailUseForUpdates t1
		WHERE t1.SPID = @@SPID 
			AND RecordExists = 1 
			AND MetricDetail.MetricCode = t1.MetricCode 
			AND MetricDetail.PlainDate = t1.PlainDate

		--**** Get the next MetricCode to process.
		IF @MetricCodePassed IS NOT NULL
			SELECT @MetricCode = NULL
		ELSE
			IF (SELECT MIN(sn) FROM MetricItem WITH (NOLOCK) WHERE Active = 1 AND sn > (SELECT sn FROM MetricItem WITH (NOLOCK) WHERE MetricCode = @MetricCode)) IS NULL  -- Is there any left.
				SELECT @MetricCode = NULL
			ELSE -- Get the next one.
				SELECT @MetricCode = MetricCode FROM metricitem WITH (NOLOCK) WHERE sn = (SELECT MIN(sn) FROM MetricItem WITH (NOLOCK) WHERE Active = 1 AND sn > (SELECT sn FROM MetricItem WITH (NOLOCK) WHERE MetricCode = @MetricCode))
	END	-- The 'END' for main WHILE loop.
	--</STEP>

	-- REMOVED 6/3/2008
	-- Let's update all the summaries here AND store them in table MetricItem.
	-- EXEC MetricUpdateItemSummaryFiscal @MetricCode

GO
GRANT EXECUTE ON  [dbo].[MetricUpdateSummariesforFiscalYear] TO [public]
GO
