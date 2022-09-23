SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricUpdateSummaries] 
(
		@MetricCodePassed VARCHAR(200) = NULL, 
		@DateFirstProcessDate datetime = NULL, 
		@Debug_Level int = NULL,
		@DateLastProcessDate datetime = NULL,
		@BatchGUID varchar(36) = NULL
)
/* WITH ENCRYPTION */ -- Do not touch this line.  This gets uncommented in the build process if the file is to be encrypted.
AS
	-- Runs: 1) ALWAYS at the end of MetricProcessing.
	-- 		2) 	
	-- Sunday=7, Monday=1, Tueday=2, Wednesday=3, Thursday=4, Friday=5, Saturday=6
	-- 	However, the first day of the week in SQL Server defaults to 7 (Sunday).
	--	To change the first day of the week to Monday, run: SET DATEFIRST 1
	--	To change the first day of the week to Tuesday, run: SET DATEFIRST 2
	-- For the sake of spanning years in a backfill, the years should be passed (optionally).
	-- 	When these are passed, only necessary if not this year, then use them.

	DECLARE @MetricCode varchar(200)
	DECLARE @DateCur datetime, @DateLow datetime, @DateHigh datetime, @ProcName varchar(100)
	DECLARE @result decimal(20, 5), @ThisCount decimal(20, 5), @ThisTotal decimal(20, 5)
	DECLARE @DateStart datetime, @DateEnd datetime, @StartDateTime datetime, @MetricStartDate datetime
	DECLARE @ProcTime datetime, @ProcTimeEnd datetime, @ProcRunDuration decimal(9, 3)
	DECLARE @QtrMonth int
--@@	DECLARE @RunPreviousDayYN varchar(1)
	DECLARE @sTemp varchar(255)
	DECLARE @nCumulative int, @AdjustTo5DayWeekYN varchar(1)
	DECLARE @PlainWeek int -- Last week of end of year can roll into first partial week of new year.
	DECLARE @LastNewYearsEve datetime
	DECLARE @PlainYearWeek varchar(6)
	DECLARE @WeekOneIsFirstFullWeekYN varchar(1)
	DECLARE @DoNotIncludeTotalForNonBusinessDayYN char(1) -- Total here refers to denominator. Actually, if there is no business day for time frame, then use it to estimate it.
	DECLARE @DateFirst int
	DECLARE @FormatText varchar(12)
	-- Date		Name		Description
	-- 05/24/04	Max Chang:	1)set varaibles for WTD, MTD, QTD, and YTD 2)put in the same loop and update only at the end
	DECLARE @WTD	decimal(20,5)	
	DECLARE @MTD	decimal(20,5)
	DECLARE @QTD	decimal(20,5)
	DECLARE @YTD	decimal(20,5)
	DECLARE @dBusinessDaysStart datetime, @dBusinessDaysEnd datetime
	DECLARE @DistinctItems int

	DECLARE @MetricDetailUseForUpdates TABLE (SPID int, DateInserted datetime DEFAULT getdate(), MetricCode varchar(200), DailyValue decimal(20, 5), DailyCount decimal(20, 5), DailyTotal decimal(20, 5), Upd_Summary datetime, PlainDate datetime, 
		ThisWTD decimal(20, 5), ThisMTD decimal(20, 5), ThisQTD decimal(20, 5), ThisYTD decimal(20, 5),
		-- WeeklyAve decimal(20, 5), MonthlyAve decimal(20, 5), QuarterlyAve decimal(20, 5), YearlyAve decimal(20, 5),
		PlainDayOfWeek int, PlainWeek int, PlainMonth int, PlainQuarter int, PlainYear int, PlainYearWeek int, RecordExists int DEFAULT(0),
		upd_daily datetime, ThisFiscalYTD decimal (20, 5), FiscalYearlyAve decimal (20, 5), PlainFiscalYear int
		) 

	SET NOCOUNT ON
	--<STEP note="General Comment">
	--This procedure will update summaries and not always automatically create 'valid' summaries.
	--A valid summary really should always go back to the start date, or to the first of the year.
	--A valid summary should also not have any days missing.
	--</STEP>

	-- EXEC MetricGetParameterText @DoNotIncludeTotalForNonBusinessDayYN OUTPUT, 'N', 'Config', 'All', 'DoNotIncludeTotalForNonBusinessDayYN'
	SELECT @DateFirst = settingvalue 
	FROM metricgeneralsettings 
	WHERE settingname = 'DateFirst'

	--OBSOLETE due to MetricGeneralSettings ~~ EXEC MetricGetParameterInt @DateFirst OUTPUT, 7, 'Config', 'All', 'DateFirst'
	SET DATEFIRST @DateFirst

	SELECT @sTemp = @MetricCodePassed 
				+ ', DtStart=' + ISNULL(CONVERT(varchar(10), @DateFirstProcessDate, 121), 'NULL Date')
				+ ', DtEnd=' + ISNULL(CONVERT(varchar(10), @DateLastProcessDate, 121), 'NULL Date')
	INSERT INTO ResNowLog (MetricCode, source, longdesc)
		VALUES (ISNULL(@MetricCodePassed, 'All Active'), 'UpdateSummary', @sTemp)

	SELECT @StartDateTime = GETDATE()	-- This datetime is used to stamp MetricDetail.Upd_Summary

	-- Determine if any metrics running now require business days
	--	If true, then make sure business days are up-to-date.
	DECLARE @UpdateBusinessDays int
	DECLARE @AdditionalBusinessDay int
	SET @UpdateBusinessDays = 0

	IF IsNumeric((SELECT SettingValue FROM MetricGeneralSettings WHERE settingname = 'AdditionalBusinessDay')) = 1
		SET @AdditionalBusinessDay = (SELECT SettingValue FROM MetricGeneralSettings WHERE settingname = 'AdditionalBusinessDay')
	ELSE
		SET @AdditionalBusinessDay = 0

	SET @UpdateBusinessDays = 1

	IF @UpdateBusinessDays = 1
	BEGIN
		SELECT @dBusinessDaysStart = MIN(PlainDate), @dBusinessDaysEnd = MAX(PlainDate) FROM MetricDetail
		IF @dBusinessDaysEnd
			> (SELECT max(plaindate) FROM MetricBusinessDays)
		BEGIN
			WHILE @dBusinessDaysStart < @dBusinessDaysEnd
			BEGIN
				IF NOT EXISTS(SELECT * FROM MetricBusinessDays WHERE PlainDate = @dBusinessDaysStart)
				BEGIN
					INSERT INTO MetricBusinessDays (PlainDate, BusinessDay, Weight)
						SELECT @dBusinessDaysStart, 
							CASE WHEN datename(weekday, @dBusinessDaysStart) = 'Saturday' AND @AdditionalBusinessDay <> 7
								OR datename(weekday, @dBusinessDaysStart) = 'Sunday' AND @AdditionalBusinessDay <> 1
								THEN 0 ELSE 1 END,
							0
				END
				SELECT @dBusinessDaysStart = DATEADD(day, 1, @dBusinessDaysStart)
			END 
		END
	END

	-- Loop through all active MetricCodes.
	-- NOTE: Write message to log table if the stored procedure does not exist.
	IF @MetricCodePassed IS NULL 
		SELECT @MetricCode = MetricCode FROM metricitem WITH (NOLOCK) WHERE sn = (SELECT MIN(sn) FROM MetricItem WITH (NOLOCK) WHERE Active = 1)
	ELSE
		SELECT @MetricCode = @MetricCodePassed 

	IF ISNULL(@Debug_Level, 0) = 1
	BEGIN
		SELECT @sTemp = 'MetricUpdateSummaries has started.' + CHAR(13) + CHAR(10)
					+ '@MetricCodePassed = ' + ISNULL(@MetricCode, 'NULL') + CHAR(13) + CHAR(10)
					+ '@DateFirstProcessDate = ' + CONVERT(varchar(100), @DateFirstProcessDate) + CHAR(13) + CHAR(10)
					+ '@DateLastProcessDate = ' + CONVERT(varchar(100), @DateLastProcessDate) + CHAR(13) + CHAR(10)
					+ '@DateEnd (last day to update MetricDetail) = ' + CONVERT(varchar(100), @DateEnd) + CHAR(13) + CHAR(10)
		SELECT @sTemp = 'MetricUpdateSummaries has started.'
		PRINT @sTemp
	END


	WHILE @MetricCode IS NOT NULL
	BEGIN 	-- 'BEGIN' for main while loop.
		SELECT @ProcName = ISNULL(ProcedureName, ''),
				@nCumulative = Cumulative,
				@DoNotIncludeTotalForNonBusinessDayYN = CASE WHEN ISNULL(DoNotIncludeTotalForNonBusinessDayYN, 'N') NOT IN ('N', 'Y') THEN 'N' ELSE ISNULL(DoNotIncludeTotalForNonBusinessDayYN, 'N') END,
				@FormatText = FormatText,
				@MetricStartDate = CASE WHEN StartDate = '' THEN NULL ELSE StartDate END 
			FROM MetricItem WITH (NOLOCK) WHERE MetricCode = @MetricCode
		IF 1=1 /*(NOT EXISTS(SELECT * FROM sysobjects WITH (NOLOCK) WHERE name = @ProcName AND type = 'p')
			INSERT INTO ResNowLog (AdminFlag, AdminReadFlag, source, longdesc) VALUES (1, 0, 'Metrics', 'Missing stored procedure: ' + @ProcName)
		ELSE */
		BEGIN	-- The 'BEGIN' for IF bad stored procedure name.
			-- Always go back to first entry in MetricDetail for this year.
			-- If a StartDate exists in MetricItem for that metriccode, delete all entries before this date (for that metriccode).
			SELECT @DateStart = NULL

			-------------------------------------------------------------------------------------
			-- START: If metric has a startdate AND MetricDetail exists before this, DELETE it. 
			-------------------------------------------------------------------------------------
			IF (@MetricStartDate IS NOT NULL)
			BEGIN
				IF EXISTS(SELECT * FROM MetricDetail WITH (NOLOCK) WHERE MetricCode = @MetricCode AND PlainDate < @MetricStartDate)
				BEGIN
					DELETE MetricDetail WHERE MetricCode = @MetricCode AND PlainDate < @MetricStartDate
					IF ISNULL(@Debug_Level, 0) = 1
					BEGIN
						SELECT @sTemp = 'DATA DELETED!!! The StartDate for this metric is later than data in MetricDetail for @MetricCode: ' + @MetricCode + CHAR(13) + CHAR(10)
									+ 'StartDate in MetricItem is = ' + CONVERT(varchar(100), @MetricStartDate)
									+ 'Data in metricdetail was deleted for dates before StartDate'
						PRINT @sTemp
					END
				END
			END
			-------------------------------------------------------------------------------------
			-- END: If metric has a startdate AND MetricDetail exists before this, DELETE it. 
			-------------------------------------------------------------------------------------

			EXEC MetricUpdateSummariesGetDateRange @MetricCode, @DateFirstProcessDate, 0, @DateLastProcessDate, 
					@ActualDateStart = @DateStart OUT, @ActualDateEnd = @DateEnd OUT

			--<STEP note="Set the date to start rollups">
			-- 1) The oldest date in metric history for the year that MetricProcessing started (strip times).
			-- 2) If 1 doesn't exist, set it equal to the date that MetricProcessing started (strip times).
			-- 
			-- Note: Does not necessarily go back to January 1st.
			--</STEP>
			--<STEP id="SQL">

			-- TRUNCATE TABLE MetricDetailUseForUpdates

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
			-- 1) Do Year first, then Quarter, Month, and week
			-- In this way, we only need to update once for each row instead of 4 times.
			-- 2) Put all 4 calculations in the same date range loop
			
			SELECT @DateCur = @DateStart

DECLARE @DateCur_ORIG datetime
SET @DateCur_ORIG = @DateCur
			SELECT @DateCur = ISNULL(MIN(PlainDate), @DateCur) FROM MetricDetail (NOLOCK) 
			WHERE metriccode = @metriccode 
				AND plainyearweek = (SELECT PlainYearWeek FROM MetricDetail (NOLOCK) WHERE PlainDate = @DateCur AND metriccode = @metriccode )


			INSERT INTO @MetricDetailUseForUpdates (SPID, RecordExists, MetricCode, PlainDate, DailyValue, DailyCount, DailyTotal, Upd_Daily,  -- Upd_Summary, ThisWTD, ThisMTD, ThisQTD, ThisYTD, 
							PlainDayOfWeek, PlainWeek, PlainMonth, PlainQuarter, PlainYear, PlainYearWeek)
				SELECT @@SPID, 1, MetricCode, PlainDate, DailyValue, DailyCount, DailyTotal, Upd_Daily, -- ThisWTD, ThisMTD, ThisQTD, ThisYTD, 
							PlainDayOfWeek, PlainWeek, PlainMonth, PlainQuarter, PlainYear, PlainYearWeek
				FROM MetricDetail WITH (NOLOCK)
				WHERE MetricCode = @MetricCode
					AND PlainDate BETWEEN @DateCur AND @DateEnd


			WHILE @DateCur <= @DateEnd
			BEGIN
				--*************************************************************************************
				-- First, do YEAR.
				--*************************************************************************************
IF @DateCur >= @DateCur_ORIG
BEGIN
				SELECT @DateLow = CONVERT(datetime, CONVERT(VARCHAR(4), DATEPART(YEAR, @DateCur)) + '0101'),  -- Go back to the first day of the month
						@DateHigh = @DateCur  -- So the date range is between the beginning of the week AND @DateHigh
		
				SELECT @ThisCount = SUM(ISNULL(DailyCount, 0)), 
						@ThisTotal = SUM(ISNULL(DailyTotal, 0)) 
					FROM @MetricDetailUseForUpdates 
					WHERE SPID = @@SPID 
						AND PlainDate BETWEEN @DateLow AND @DateHigh
						AND Upd_Daily IS NOT NULL
				
				SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) FROM MetricDetailInfo (NOLOCK) WHERE PlainDate Between @DateLow AND @DateHigh AND MetricCode = @MetricCode),0)
				IF @DistinctItems > 0 
					SET @ThisTotal = @DistinctItems 

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

						SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) 
																FROM MetricDetailInfo t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 (NOLOCK)
																		ON t1.PlainDate = t2.PlainDate 
																WHERE BusinessDay = 1
																	AND t1.PlainDate Between @DateLow AND @DateHigh 
																	AND t1.MetricCode = @MetricCode),0)
						IF @DistinctItems > 0 
							SET @ThisTotal = @DistinctItems 

						IF ISNULL(@ThisTotal, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
							BEGIN
								SELECT @ThisTotal = SUM(ISNULL(DailyTotal, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL

								SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) FROM MetricDetailInfo t1 (NOLOCK) 
																		WHERE t1.PlainDate Between @DateLow AND @DateHigh 
																		AND t1.MetricCode = @MetricCode),0)
								IF @DistinctItems > 0 
									SET @ThisTotal = @DistinctItems 
							END

						IF @FormatText = 'PCT'	-- 5/21/2004: DAG
						BEGIN
							SELECT @ThisCount = SUM(ISNULL(DailyCount, 0)) 
							FROM @MetricDetailUseForUpdates t1 INNER JOIN MetricBusinessDays t2 WITH (NOLOCK)
								ON t1.PlainDate = t2.PlainDate 
							WHERE t1.SPID = @@SPID 
								AND BusinessDay = 1
								AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
								AND Upd_Daily IS NOT NULL  -- Do NOT count this day if MetricProcessing has not run against it.

							IF ISNULL(@ThisCount, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
								SELECT @ThisCount = SUM(ISNULL(DailyCount, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL
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

						IF ISNULL(@ThisTotal, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
								SELECT @ThisTotal = AVG(ISNULL(DailyTotal, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL
					END
				END
			
				SELECT @Result = CASE WHEN @ThisTotal = 0 THEN 0 ELSE @ThisCount / @ThisTotal END
				-- don't update yet
				SET @YTD = @Result
				SELECT @Result = NULL
				-- No need to insert, because it should already exist from WEEK section.
				-- UPDATE @MetricDetailUseForUpdates SET ThisYTD = @Result WHERE SPID = @@SPID AND PlainDate = @DateCur
		
				-- SELECT @Result = NULL, @DateCur = DATEADD(DAY, 1, @DateCur) 
			-- END
			
			--*************************************************************************************
			-- Then, do QUARTER.
			--*************************************************************************************
			-- BEGIN
				SELECT @QtrMonth = DATEPART(MONTH, @DateCur) 
				SELECT @DateLow = CONVERT(datetime, 
									CONVERT(VARCHAR(4), DATEPART(YEAR, @DateCur))
									+ RIGHT('0' + CONVERT(VARCHAR(2), 
										CASE WHEN @QtrMonth < 4 THEN 1 
											WHEN @QtrMonth BETWEEN 4 AND 6 THEN 4
								        	WHEN @QtrMonth BETWEEN 7 AND 9 THEN 7
								        	WHEN @QtrMonth BETWEEN 10 AND 12 THEN 10
										END), 2)
								 + '01'),  -- Go back to the first day of the QUARTER
						@DateHigh = @DateCur  -- So the date range is between the beginning of the week AND @DateHigh
		
				SELECT @ThisCount = SUM(ISNULL(DailyCount, 0)), 
						@ThisTotal = SUM(ISNULL(DailyTotal, 0)) 
					FROM @MetricDetailUseForUpdates 
					WHERE SPID = @@SPID
						AND PlainDate BETWEEN @DateLow AND @DateHigh
						AND Upd_Daily IS NOT NULL

				SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) FROM MetricDetailInfo (NOLOCK) WHERE PlainDate Between @DateLow AND @DateHigh AND MetricCode = @MetricCode),0)
				IF @DistinctItems > 0 
					SET @ThisTotal = @DistinctItems 


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

						SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) FROM MetricDetailInfo t1 (NOLOCK), 
																		MetricBusinessDays t2 (NOLOCK)
																		WHERE t1.PlainDate = t2.PlainDate AND BusinessDay = 1
																		AND t1.PlainDate Between @DateLow AND @DateHigh 
																		AND t1.MetricCode = @MetricCode),0)
						IF @DistinctItems > 0 
							SET @ThisTotal = @DistinctItems 


						IF ISNULL(@ThisTotal, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
							BEGIN
								SELECT @ThisTotal = SUM(ISNULL(DailyTotal, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL

								SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) FROM MetricDetailInfo t1 (NOLOCK) 
																		WHERE t1.PlainDate Between @DateLow AND @DateHigh 
																		AND t1.MetricCode = @MetricCode),0)
								IF @DistinctItems > 0 
									SET @ThisTotal = @DistinctItems 
							END

						IF @FormatText = 'PCT'	-- 5/21/2004: DAG
						BEGIN
							SELECT @ThisCount = SUM(ISNULL(DailyCount, 0)) 
							FROM @MetricDetailUseForUpdates t1 INNER JOIN MetricBusinessDays t2 WITH (NOLOCK) ON t1.PlainDate = t2.PlainDate 
							WHERE t1.SPID = @@SPID 
								AND BusinessDay = 1
								AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
								AND Upd_Daily IS NOT NULL  -- Do NOT count this day if MetricProcessing has not run against it.

							IF ISNULL(@ThisCount, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
								SELECT @ThisCount = SUM(ISNULL(DailyCount, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL
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

						IF ISNULL(@ThisTotal, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
								SELECT @ThisTotal = AVG(ISNULL(DailyTotal, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL
					END
				END

				SELECT @Result = CASE WHEN @ThisTotal = 0 THEN 0 ELSE @ThisCount / @ThisTotal END
				-- don't update yet
				SET @QTD = @Result
				SELECT @Result = NULL
				-- No need to insert, because it should already exist from WEEK section.
				-- UPDATE @MetricDetailUseForUpdates SET ThisQTD = @Result WHERE SPID = @@SPID AND PlainDate = @DateCur
		
				-- SELECT @Result = NULL, @DateCur = DATEADD(DAY, 1, @DateCur) 
			-- END
			
			--*************************************************************************************
			-- Then, do MONTH.
			--*************************************************************************************
			-- BEGIN
				SELECT @DateLow = CONVERT(datetime, CONVERT(VARCHAR(4), DATEPART(YEAR, @DateCur)) + RIGHT('0' + CONVERT(VARCHAR(2), DATEPART(MONTH, @DateCur)), 2) + '01'),  -- Go back to the first day of the month
						@DateHigh = @DateCur  -- So the date range is between the beginning of the week AND @DateHigh

				SELECT @ThisCount = SUM(ISNULL(DailyCount, 0)), 
						@ThisTotal = SUM(ISNULL(DailyTotal, 0)) 
					FROM @MetricDetailUseForUpdates 
					WHERE SPID = @@SPID 
						AND PlainDate BETWEEN @DateLow AND @DateHigh
						AND Upd_Daily IS NOT NULL

				SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) FROM MetricDetailInfo (NOLOCK) WHERE PlainDate Between @DateLow AND @DateHigh AND MetricCode = @MetricCode),0)
				IF @DistinctItems > 0 
					SET @ThisTotal = @DistinctItems 

				-- The standard way to calculate this is to SUM(Count) / SUM(Total) ==>> like Rev/Mile is just SUM(Rev)/Sum(Miles)
				IF (@nCumulative = 0) 
				BEGIN
					IF @DoNotIncludeTotalForNonBusinessDayYN = 'Y'  -- Total here refers to denominator.
					BEGIN
						-- Need to change @ThisTotal.
						SELECT @ThisTotal = SUM(ISNULL(DailyTotal, 0)) 
						FROM @MetricDetailUseForUpdates t1 INNER JOIN MetricBusinessDays t2 WITH (NOLOCK) ON t1.PlainDate = t2.PlainDate 
						WHERE t1.SPID = @@SPID 
							AND BusinessDay = 1
							AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
							AND Upd_Daily IS NOT NULL

						SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) 
														FROM MetricDetailInfo t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 (NOLOCK) ON t1.PlainDate = t2.PlainDate 
														WHERE BusinessDay = 1
															AND t1.PlainDate Between @DateLow AND @DateHigh 
															AND t1.MetricCode = @MetricCode),0)
						IF @DistinctItems > 0 
							SET @ThisTotal = @DistinctItems 

						IF ISNULL(@ThisTotal, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
							BEGIN
								SELECT @ThisTotal = SUM(ISNULL(DailyTotal, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL

								SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) FROM MetricDetailInfo t1 (NOLOCK) 
																		WHERE t1.PlainDate Between @DateLow AND @DateHigh 
																		AND t1.MetricCode = @MetricCode),0)
								IF @DistinctItems > 0 
									SET @ThisTotal = @DistinctItems 
							END
						IF @FormatText = 'PCT'	-- 5/21/2004: DAG
						BEGIN
							SELECT @ThisCount = SUM(ISNULL(DailyCount, 0)) 
							FROM @MetricDetailUseForUpdates t1 INNER JOIN MetricBusinessDays t2 WITH (NOLOCK) ON t1.PlainDate = t2.PlainDate 
							WHERE t1.SPID = @@SPID 
								AND BusinessDay = 1
								AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
								AND Upd_Daily IS NOT NULL  -- Do NOT count this day if MetricProcessing has not run against it.

							IF ISNULL(@ThisCount, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
								SELECT @ThisCount = SUM(ISNULL(DailyCount, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL

						END
					END
				END
				ELSE
				BEGIN
					-- ASSUMPTION::: If businessday table has any entries, then the relevant entries ARE present.
					-- SUGGESTION:: Change logic to use an OUTER join.  If NULL or zero indicates no business day.
					IF @DoNotIncludeTotalForNonBusinessDayYN = 'N'  -- Total here refers to denominator.
					BEGIN
						SELECT @ThisTotal = AVG(ISNULL(DailyTotal, 0))
						FROM @MetricDetailUseForUpdates
						WHERE SPID = @@SPID
							AND PlainDate BETWEEN @DateLow AND @DateHigh
							AND Upd_Daily IS NOT NULL
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

						IF ISNULL(@ThisTotal, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
								SELECT @ThisTotal = AVG(ISNULL(DailyTotal, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL
					END
				END
				SELECT @Result = CASE WHEN @ThisTotal = 0 THEN 0 ELSE @ThisCount / @ThisTotal END
				SET @MTD = @Result
				SELECT @Result = NULL
				-- No need to insert, because it should already exist from WEEK section.
				-- UPDATE @MetricDetailUseForUpdates SET ThisMTD = @Result WHERE SPID = @@SPID AND PlainDate = @DateCur
	-- select @DateCur, @Result, @DateLow, @DateHigh, @ThisCount, @ThisTotal
				-- SELECT @Result = NULL, @DateCur = DATEADD(DAY, 1, @DateCur) 
			-- END
END

			--*************************************************************************************
			-- Then summarize WEEK.
			--*************************************************************************************
			-- BEGIN
				SELECT @DateLow = DATEADD(DAY, 1-DATEPART(weekday, @DateCur), @DateCur),  -- Go back to the first day of the week (usually starting with Sunday).
						@DateHigh = @DateCur  -- So the date range is between the beginning of the week AND @DateCur.

				SELECT @ThisCount = SUM(ISNULL(DailyCount, 0)),
						@ThisTotal = SUM(ISNULL(DailyTotal, 0))
					FROM @MetricDetailUseForUpdates
					WHERE SPID = @@SPID
						AND PlainDate BETWEEN @DateLow AND @DateHigh
						AND Upd_Daily IS NOT NULL

				SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) FROM MetricDetailInfo (NOLOCK) WHERE PlainDate Between @DateLow AND @DateHigh AND MetricCode = @MetricCode),0)
				IF @DistinctItems > 0 
					SET @ThisTotal = @DistinctItems 

				-- The standard way to calculate this is to SUM(Count) / SUM(Total) ==>> like Rev/Mile is just SUM(Rev)/Sum(Miles)
				IF (@nCumulative = 0)
				BEGIN
					IF @DoNotIncludeTotalForNonBusinessDayYN = 'Y'  -- Total here refers to denominator.
					BEGIN
						-- Need to recalculate the total.
						SELECT @ThisTotal = SUM(ISNULL(DailyTotal, 0)) 
						FROM @MetricDetailUseForUpdates t1 INNER JOIN MetricBusinessDays t2 WITH (NOLOCK) ON t1.PlainDate = t2.PlainDate 
						WHERE t1.SPID = @@SPID 
							AND BusinessDay = 1
							AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
							AND Upd_Daily IS NOT NULL  -- Do NOT count this day if MetricProcessing has not run against it.

						SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) 
														FROM MetricDetailInfo t1 (NOLOCK) INNER JOIN MetricBusinessDays t2 (NOLOCK) ON t1.PlainDate = t2.PlainDate 
														WHERE BusinessDay = 1
															AND t1.PlainDate Between @DateLow AND @DateHigh 
															AND t1.MetricCode = @MetricCode),0)
						IF @DistinctItems > 0 
							SET @ThisTotal = @DistinctItems 

						IF ISNULL(@ThisTotal, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
							BEGIN
							SELECT @ThisTotal = SUM(ISNULL(DailyTotal, 0))
							FROM @MetricDetailUseForUpdates	
							WHERE SPID = @@SPID
								AND PlainDate BETWEEN @DateLow AND @DateHigh
								AND Upd_Daily IS NOT NULL

								SET @DistinctItems = IsNull((SELECT COUNT(DISTINCT MetricItem) FROM MetricDetailInfo t1 (NOLOCK) 
																		WHERE t1.PlainDate Between @DateLow AND @DateHigh 
																		AND t1.MetricCode = @MetricCode),0)
								IF @DistinctItems > 0 
									SET @ThisTotal = @DistinctItems 

							END
						IF @FormatText = 'PCT'	-- 5/21/2004: DAG
						BEGIN
							SELECT @ThisCount = SUM(ISNULL(DailyCount, 0)) 
							FROM @MetricDetailUseForUpdates t1 INNER JOIN MetricBusinessDays t2 WITH (NOLOCK) ON t1.PlainDate = t2.PlainDate 
							WHERE t1.SPID = @@SPID 
								AND BusinessDay = 1
								AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
								AND Upd_Daily IS NOT NULL  -- Do NOT count this day if MetricProcessing has not run against it.

							IF ISNULL(@ThisCount, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
								SELECT @ThisCount = SUM(ISNULL(DailyCount, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL
						END
					END
				END
				ELSE
				BEGIN
					-- ASSUMPTION::: If businessday table has any entries, then the relevant entries ARE present.
					-- SUGGESTION:: Change logic to use an OUTER join.  If NULL or zero indicates no business day.
					IF @DoNotIncludeTotalForNonBusinessDayYN = 'N'  -- Total here refers to denominator.
					BEGIN
						SELECT @ThisTotal = AVG(ISNULL(DailyTotal, 0))
						FROM @MetricDetailUseForUpdates
						WHERE SPID = @@SPID 
							AND PlainDate BETWEEN @DateLow AND @DateHigh
							AND Upd_Daily IS NOT NULL
					END
					ELSE
					BEGIN
						-- Need to recalculate the total.
						-- SELECT @DaysForApprox = COUNT(*) FROM MetricBusinessDays WITH (NOLOCK) WHERE PlainDate BETWEEN @DateLow AND @DateHigh AND BusinessDay = 1
						-- IF @DaysForApprox = 0 SELECT @DaysForApprox = 1  -- Self-correcting for Sunday for example.  On Monday, things should be all better.
						SELECT @ThisTotal = AVG(ISNULL(DailyTotal, 0)) 
						FROM @MetricDetailUseForUpdates t1 INNER JOIN MetricBusinessDays t2 WITH (NOLOCK) ON t1.PlainDate = t2.PlainDate 
						WHERE t1.SPID = @@SPID
							AND BusinessDay = 1
							AND t1.PlainDate BETWEEN @DateLow AND @DateHigh
							AND Upd_Daily IS NOT NULL

						IF ISNULL(@ThisTotal, 0) = 0 -- This essentially is an estimate using those values for non-business days ONLY if there are no business days in the date range.
								SELECT @ThisTotal = AVG(ISNULL(DailyTotal, 0))
								FROM @MetricDetailUseForUpdates	
								WHERE SPID = @@SPID
									AND PlainDate BETWEEN @DateLow AND @DateHigh
									AND Upd_Daily IS NOT NULL
					END
				END

				-- RULE: If January 7th is week 1, then no adjustment. (full week starts the year)  
				--    This is typically once every 5, 6, or 11 years: 1967(6), 1978(11), 1984(6), 1989(5), 1995(6), 2006(11), 2012(6), 2017(5), 2023(6)
				--    Sometimes (every four hundered years) after 7 years: 2204, 2604, 3004, 3404
				-- RULE: If January 7th is NOT week 1, then adjustment: 
				--			All other weeks besides Week 1 are WEEK-1
				--			Week 1 = Last week of last year - (WHEN 1/7/LASTYEAR is week 1, then 0 ELSE 1)
				SELECT @LastNewYearsEve = CONVERT(datetime, CONVERT(char(4), DATEPART(year, @DateCur)-1) + '1231')

				SELECT @PlainWeek =  
						CASE WHEN DATEPART(week, CONVERT(datetime, CONVERT(char(4), DATEPART(year, @DateCur)) + '0107')) = 1  -- Why not just look at 1/1 being dw=1?
							THEN DATEPART(week, @DateCur)
							ELSE 
								CASE WHEN DATEPART(week, @DateCur) = 1
									THEN DATEPART(week, @LastNewYearsEve) 
									-	CASE WHEN DATEPART(week, CONVERT(datetime, CONVERT(char(4), DATEPART(year, @LastNewYearsEve)) + '0107')) = 1
											THEN 0 
										ELSE 1
										END
									ELSE DATEPART(week, @DateCur) - 1 
								END
						END

				IF @PlainWeek > 50 AND DATEPART(week, @DateCur) < 10 -- Then this is the first partial week of the year.
					SELECT @PlainYearWeek = CONVERT(char(4), DATEPART(year, @DateCur)-1) + RIGHT('00' + CONVERT(varchar(2), @PlainWeek), 2)
				ELSE
					SELECT @PlainYearWeek = CONVERT(char(4), DATEPART(year, @DateCur)) + RIGHT('00' + CONVERT(varchar(2), @PlainWeek), 2)


				SELECT @Result = CASE WHEN @ThisTotal = 0 THEN 0 ELSE @ThisCount / @ThisTotal END
				SET @WTD = @Result


				-- We do insert/update only once
				IF EXISTS(SELECT * FROM @MetricDetailUseForUpdates WHERE SPID = @@SPID AND PlainDate = @DateCur) 
				BEGIN
					UPDATE @MetricDetailUseForUpdates SET ThisWTD = @WTD, ThisMTD = @MTD, ThisQTD = @QTD, ThisYTD = @YTD,
							PlainWeek = @PlainWeek, PlainYearWeek = @PlainYearWeek, PlainDayOfWeek = DATEPART(dw, @DateCur),
							PlainMonth = DATEPART(m, @DateCur), PlainQuarter = DATEPART(q, @DateCur), PlainYear = DATEPART(yyyy, @DateCur)
						WHERE SPID = @@SPID AND PlainDate = @DateCur
				END
				ELSE
				BEGIN
					INSERT INTO @MetricDetailUseForUpdates (SPID, MetricCode, PlainDate, ThisWTD, ThisMTD, ThisQTD, ThisYTD,
						PlainDayOfWeek, PlainWeek, PlainMonth, PlainQuarter, PlainYear, PlainYearWeek)
					SELECT @@SPID, @MetricCode, @DateCur, @WTD, @MTD, @QTD, @YTD, DATEPART(dw, @DateCur), @PlainWeek, DATEPART(m, @DateCur), DATEPART(q, @DateCur), DATEPART(yyyy, @DateCur), @PlainYearWeek
				END

				SELECT @Result = NULL, @DateCur = DATEADD(DAY, 1, @DateCur) 
			END

		END -- The 'END' for IF bad stored procedure name.


		--**** Now, transfer to MetricDetail at one time.
		UPDATE MetricDetail
		SET Upd_Summary = @StartDateTime, PlainDate = t1.PlainDate, 
			ThisWTD = t1.ThisWTD, ThisMTD = ISNULL(t1.ThisMTD, MetricDetail.ThisMTD), ThisQTD = ISNULL(t1.ThisQTD, MetricDetail.ThisQTD) , ThisYTD = ISNULL(t1.ThisYTD, MetricDetail.ThisYTD),
--			WeeklyAve = t1.WeeklyAve, MonthlyAve = t1.MonthlyAve, QuarterlyAve = t1.QuarterlyAve, YearlyAve = t1.YearlyAve,
			PlainDayOfWeek = t1.PlainDayOfWeek, PlainWeek = t1.PlainWeek, PlainMonth = t1.PlainMonth, 
			PlainQuarter = t1.PlainQuarter, PlainYear = t1.PlainYear, PlainYearWeek = t1.PlainYearWeek
		FROM @MetricDetailUseForUpdates t1
		WHERE -- @MetricDetailUseForUpdates.SPID = @@SPID 
			RecordExists = 1 
			AND MetricDetail.MetricCode = t1.MetricCode 
			AND MetricDetail.PlainDate = t1.PlainDate

		INSERT INTO MetricDetail 
			(MetricCode, Upd_Summary, PlainDate, ThisWTD, ThisMTD, ThisQTD, ThisYTD, 
--			WeeklyAve, MonthlyAve, QuarterlyAve, YearlyAve, 
			PlainDayOfWeek, PlainWeek, PlainMonth, PlainQuarter, PlainYear, PlainYearWeek)
		SELECT MetricCode, @StartDateTime, PlainDate, ThisWTD, ThisMTD, ThisQTD, ThisYTD, 
--			WeeklyAve, MonthlyAve, QuarterlyAve, YearlyAve, 
			PlainDayOfWeek, PlainWeek, PlainMonth, PlainQuarter, PlainYear, PlainYearWeek
		FROM @MetricDetailUseForUpdates
		WHERE -- SPID = @@SPID 
			RecordExists = 0
		-- DELETE @MetricDetailUseForUpdates WHERE SPID = @@SPID

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

	-- REMOVED 6/30/2008
	-- Let's update all the summaries here AND store them in table MetricItem.
	-- EXEC MetricUpdateItemSummary @MetricCode

	--Example cases:
	--
	--CASE 1: Today is 1/6/2004.  Run MetricProcessing for 12/25/2003 - 12/26/2003.
	--	SummaryStartDate:	1) If start date for metric exists, delete any metricdetail records older than this date.
	--						2) SummaryStartDate equals oldest date in MetricDetail for the year of @DateFirstProcessDate.
	--						3) If no records returned for #2, then SummaryStartDate = @DateFirstProcessDate.
	--	SummaryEndDate:		1) If Simulation date exists, use that date.  (Warning is displayed if SummaryStartDate < SummaryEndDate.)
	--						2) 

GO
GRANT EXECUTE ON  [dbo].[MetricUpdateSummaries] TO [public]
GO
