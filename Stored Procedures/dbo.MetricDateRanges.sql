SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDateRanges]  (@CategoryCode varchar(30))
AS
	SET NOCOUNT ON  -- Must be on when using with SQLOLEDB

/* 
MetricDateRanges 'red' 
*/
--Variable Declaration

	DECLARE	@WeekCurrentStart datetime,
			@WeekThisStart datetime,
			@WeekLastStart datetime,
			@MonthCurrentStartDate datetime,
			@MonthThisStartDate datetime,
			@MonthLastStartDate datetime,
			@QuarterCurrentStartDate datetime,
			@QuarterThisStartDate datetime,
			@QuarterLastStartDate datetime,
			@YearCurrentStartDate datetime,
			@YearThisStartDate datetime,
			@YearLastStartDate datetime,
			@FiscalYearCurrentStartDate datetime,
			@FiscalYearThisStartDate datetime,
			@FiscalYearLastStartDate datetime

	DECLARE @BusinessDayCurrent varchar(100), --This is the Current Day
			@BusinessDayThis varchar(100), --This is either the Current Day or the last Full Business Day based on MetricCategory settings
			@BusinessDayLast varchar(100), --This is either the Last Full Business Day or 2 Days Ago based on MetricCategory settings
			@AsOfDate varchar(10), --Date to Use for finding This and Last
			@ShowFullTimeFrameDay int, --1=Show the last full day; 0=Show today
			@ShowFullTimeFrameWeek int, --1=Show the last full Week; 0=Show Current Week
			@ShowFullTimeFrameMonth int, --1=Show the last full Month;0=Show Current Month
			@ShowFullTimeFrameQuarter int, --1=Show the last full Quarter;0=Show Current Quarter
			@ShowFullTimeFrameYear int, --1=Show the last full Year;0=Show Current Year
			@ShowFullTimeFrameFiscalYear int, --1=Show the last full Year;0=Show Current Year
			@DateToUseAdjusted datetime, 
--			@BusinessDay datetime,
			@BusinessDayPlainDate datetime,
			@BusinessDayValue int,
			@DateToUseLast datetime,
			@TempWeekDate datetime,
			@LocaleID varchar(6),
			@LastWeekDate varchar(100)
	DECLARE @BusinessDayCurrentHeading varchar(100), --Current Day Formatted
			@BusinessDayThisHeading varchar(100), --Formatted This is either the Current Day or the last Full Business Day based on MetricCategory settings
			@BusinessDayLastHeading varchar(100), --Formatted This is either the Last Full Business Day or 2 Days Ago based on MetricCategory settings
			@WeekCurrentHeading varchar(100),
            @WeekThisHeading varchar(100),
			@WeekLastHeading varchar(100),
            @MonthCurrentHeading varchar(100),
			@MonthThisHeading varchar(100),
			@MonthLastHeading varchar(100),
            @QuarterCurrentHeading varchar(100),
			@QuarterThisHeading varchar(100),
			@QuarterLastHeading varchar(100),
            @YearCurrentHeading varchar(100),
			@YearThisHeading varchar(100),
			@YearLastHeading varchar(100),
			@FiscalYearStartDate varchar(5),
            @FiscalYearCurrentHeading varchar(100),
			@FiscalYearThisHeading varchar(100),
			@FiscalYearLastHeading varchar(100),
			@TempDate datetime,
			@TempDate2 datetime,
			@TempDate3 datetime,
            @HeadingSetting varchar(1),
            @HeadingDaysBack int,
		    @DateFirst int,
            @FullTimeFrameDay char(1),
			@FiscalYearEndingYN char(1),
			@Annualize int,
			@MaxFiscalYearStartDate datetime
			
	DECLARE @Suffix varchar(200)

	SET @DateFirst = (Select settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'datefirst')
    SET datefirst @DateFirst


	CREATE TABLE #MetricInfo (	TopLevelMetric varchar(200), sort int, 
								MetricCode varchar(200), 
								Caption varchar(80), 
								CaptionFull varchar(255), 
								CategoryCode varchar(30), 
								FormatText varchar(12), 
								Digs int, 
								PlusDeltaIsGood int, 
								ItemCaption varchar(80), 
								ItemCaptionFull varchar(255),
								AsOfDate varchar(10), 
                                FullTimeFrameDay char(1),
								BusinessDayCurrent varchar(100),
								BusinessDayThis varchar(100), 
								BusinessDayLast varchar(100), 
                                FullTimeFrameWeek char(1),
								WeekCurrentHeading varchar(100),
								WeekThisHeading varchar(100),
								WeekLastHeading varchar(100),
								FullTimeFrameMonth char(1),
								MonthCurrentHeading varchar(100),
								MonthThisHeading varchar(100),
								MonthLastHeading varchar (100),
								FullTimeFrameQuarter char(1),
								QuarterCurrentHeading varchar(100),
								QuarterThisHeading varchar(100),
								QuarterLastHeading varchar(100),
								FullTimeFrameYear char(1),
								FullTimeFrameFiscalYear char(1),
								YearCurrentHeading varchar(100),
								YearThisHeading varchar(100),
								YearLastHeading varchar(100),
								FiscalYearCurrentHeading varchar(100),
								FiscalYearThisHeading varchar(100),
								FiscalYearLastHeading varchar(100),
								BusinessDayCurrentDate datetime,
								BusinessDayThisDate datetime,
								BusinessDayLastDate datetime,
								WeekCurrentStartDate datetime,
								WeekThisStartDate datetime,
								WeekLastStartDate datetime,
								MonthCurrentStartDate datetime,
								MonthThisStartDate datetime,
								MonthLastStartDate datetime,
								QuarterCurrentStartDate datetime,
								QuarterThisStartDate datetime,
								QuarterLastStartDate datetime,
								YearCurrentStartDate datetime,
								YearThisStartDate datetime,
								YearLastStartDate datetime,
								FiscalYearCurrentStartDate datetime,
								FiscalYearThisStartDate datetime,
								FiscalYearLastStartDate datetime,
								ShowDetailByDefault varchar(1), 
								Cumulative int, 
								Annualize int,
								Active int DEFAULT(-1),
								CurrentLastUpdate datetime,
                                ThisLastUpdate datetime,
								LastLastUpdate datetime,
								DetailFilename varchar(50)
							 )

	Set @DateToUseAdjusted = CAST(CONVERT(char(8),getdate(),112) as datetime)


	--Find Setting for FullTime Frame
	SELECT @ShowFullTimeFrameDay = ShowFullTimeFrameDay,
			@ShowFullTimeFrameWeek = ShowFullTimeFrameWeek,
			@ShowFullTimeFrameMonth = ShowFullTimeFrameMonth,
			@ShowFullTimeFrameQuarter = ShowFullTimeFrameQuarter,
			@ShowFullTimeFrameYear = ShowFullTimeFrameYear,
			@ShowFullTimeFrameFiscalYear = ShowFullTimeFrameFiscalYear
	FROM MetricCategory WITH (NOLOCK)
	WHERE CategoryCode = @CategoryCode

	
	--Find the Last Business Day Processed into MetricDetail, 
	--starting with Max Date in MetricDetail and proceeding back by 1 day at a time
	--This would be the THIS DAY (and possibly the CURRENT DAY)
	SELECT @BusinessDayCurrent = CAST(CONVERT(char(8),getdate(),112) as datetime)

	SELECT @BusinessDayCurrent = MAX(PlainDate)
	FROM MetricDetail WITH (NOLOCK) JOIN MetricCategoryItems ON metricdetail.metriccode = metriccategoryitems.metriccode
	WHERE [MetricCategoryItems].[CategoryCode] = @CategoryCode


	-- 1/8/2008 DAG (START): Giant Eagle reported this bug.  When time frame for week spans between years.
	DECLARE @MaxPlainYearWeekForPreviousWeek varchar(6)

	SELECT @MaxPlainYearWeekForPreviousWeek = (select MAX(plainyearweek) FROM metricdetail (NOLOCK) WHERE plaindate = dateadd(week,-1, @BusinessDayCurrent))

	SELECT @LastWeekDate = MAX(PlainDate)
	FROM MetricDetail WITH (NOLOCK) JOIN MetricCategoryItems ON metricdetail.metriccode = metriccategoryitems.metriccode
	WHERE PlainYearWeek = @MaxPlainYearWeekForPreviousWeek 
		AND [MetricCategoryItems].[CategoryCode] = @CategoryCode
	-- 1/8/2008 DAG (END)


	-- plainyearweek
	SELECT @BusinessDayPlainDate = B.PlainDate, @BusinessDayValue = B.BusinessDay -- B.BusinessDay
	FROM MetricBusinessDays B (NOLOCK) INNER Join MetricDetail D (NOLOCK)
		On B.Plaindate = D.PlainDate
	WHERE B.PlainDate = @BusinessDayCurrent

	WHILE ISNULL(@BusinessDayValue, 1) = 0
	BEGIN
		SELECT @BusinessDayCurrent = DATEADD(day, -1, @BusinessDayCurrent)
		SET @BusinessDayPlainDate = NULL
		SET @BusinessDayValue = NULL
		
		SELECT @BusinessDayPlainDate = B.PlainDate, @BusinessDayValue = B.BusinessDay 
		FROM MetricBusinessDays B (NOLOCK) INNER JOIN MetricDetail D (NOLOCK)
			On B.Plaindate = D.PlainDate
		WHERE B.PlainDate = @BusinessDayCurrent
	END

	SET @BusinessDayThis = @BusinessDayCurrent
    
	--Find the Next to Last Business Day Processed into MetricDetail, 
	--starting with @BusinessDayThis -1  and proceeding back by 1 day at a time
	--This would be the LAST DAY (and possibly YESTERDAY)
	SET @BusinessDayLast = DATEADD(day, -1, @BusinessDayThis)

	SELECT @BusinessDayPlainDate = PlainDate, @BusinessDayValue = BusinessDay 
	FROM MetricBusinessDays WITH (NOLOCK) 
	WHERE PlainDate = @BusinessDayLast
	WHILE ISNULL(@BusinessDayValue, 1) = 0
	BEGIN
		SELECT @BusinessDayLast = DATEADD(day, -1, @BusinessDayLast)
		SET @BusinessDayPlainDate = NULL
		SET @BusinessDayValue = NULL
		
		SELECT @BusinessDayPlainDate = PlainDate, @BusinessDayValue = BusinessDay 
		FROM MetricBusinessDays WITH (NOLOCK) 
		WHERE PlainDate = @BusinessDayLast
	END


	--If the option for FullTimeFrame is selected, This = Last and Last = Last - 1
	--NOTE:  Current is still the most recent date processed
	IF @ShowFullTimeFrameDay = 1 
	BEGIN
		SET @FullTimeFrameDay = 'Y'
		SET @BusinessDayCurrent = @BusinessDayThis
		SET @BusinessDayThis = @BusinessDayLast
		Set @BusinessDayLast = DATEADD(day, -1, @BusinessDayLast)

		SELECT @BusinessDayValue = BusinessDay , @BusinessDayPlainDate = PlainDate
		FROM MetricBusinessDays WITH (NOLOCK) 
		WHERE PlainDate = @BusinessDayLast

		WHILE ISNULL(@BusinessDayValue, 1) = 0
		BEGIN
			SELECT @BusinessDayLast = DATEADD(day, -1, @BusinessDayLast)
			SET @BusinessDayValue = NULL
			SET @BusinessDayPlainDate = NULL
			
			SELECT @BusinessDayValue = BusinessDay , @BusinessDayPlainDate = PlainDate
			FROM MetricBusinessDays WITH (NOLOCK) 
			WHERE PlainDate = @BusinessDayLast
		END

		--NOTE:  NEED TO ADD HEADING SETTINGS HERE
		--Format the headings for this and last 
  		select @HeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'dayheading'
  		If @HeadingSetting = '1' 
		Begin
			If @BusinessDayThis = CAST(CONVERT(char(8),getdate(),112) as datetime)
         		SET @BusinessDayThisHeading = 'Today'	
			Else
			BEGIN
				If @BusinessDayThis = DateAdd(d,-1,CAST(CONVERT(char(8),getdate(),112) as datetime))
					SET @BusinessDayThisHeading = 'Yesterday'
				Else
					SET @BusinessDayThisHeading = cast(-datediff(dd,getdate(),@BusinessDayThis) as char(4)) + 'Days Ago'
			END
			If @BusinessDayCurrent = CAST(CONVERT(char(8),getdate(),112) as datetime)
				SET @BusinessDayCurrentHeading = 'Today'
			Else
				SET @BusinessDayThisHeading = cast(-datediff(dd,getdate(),@BusinessDayThis) as char(4)) + 'Days Ago'

			If @BusinessDayLast =  dateadd(d,-1,CAST(CONVERT(char(8),getdate(),112) as datetime))
				SET @BusinessDayLastHeading = 'Yesterday'
    		Else
				SET @BusinessDayLastHeading = cast(-datediff(dd,getdate(),@BusinessDayLast) as char(4)) + 'Days Ago'
				
		END
 		ELSE	
		BEGIN
			SELECT @LocaleID = settingvalue from metricgeneralsettings where settingname = 'RNLocaleID'
			IF @LocaleID = '2057'
			BEGIN
				SET @BusinessDayCurrentHeading = LEFT(DATENAME(dw, @BusinessDayCurrent),3) + ' ' + CONVERT(varchar(2), DATEPART(day, @BusinessDayCurrent)) + '/' + CONVERT(varchar(2), DATEPART(month, @BusinessDayCurrent))
    			SET @BusinessDayThisHeading = LEFT(DATENAME(dw, @BusinessDayThis),3) + ' ' + CONVERT(varchar(2), DATEPART(day, @BusinessDayThis)) + '/' + CONVERT(varchar(2), DATEPART(month, @BusinessDayThis))
    			SET @BusinessDayLastHeading = LEFT(DATENAME(dw, @BusinessDayLast),3) + ' ' + CONVERT(varchar(2), DATEPART(day, @BusinessDayLast)) + '/' + CONVERT(varchar(2), DATEPART(month, @BusinessDayLast))
		
			END
			ELSE
			BEGIN
				SET @BusinessDayCurrentHeading = LEFT(DATENAME(dw, @BusinessDayCurrent),3) + ' ' + CONVERT(varchar(2), DATEPART(month, @BusinessDayCurrent)) + '/' + CONVERT(varchar(2), DATEPART(day, @BusinessDayCurrent))
    			SET @BusinessDayThisHeading = LEFT(DATENAME(dw, @BusinessDayThis),3) + ' ' + CONVERT(varchar(2), DATEPART(month, @BusinessDayThis)) + '/' + CONVERT(varchar(2), DATEPART(day, @BusinessDayThis))
    			SET @BusinessDayLastHeading = LEFT(DATENAME(dw, @BusinessDayLast),3) + ' ' + CONVERT(varchar(2), DATEPART(month, @BusinessDayLast)) + '/' + CONVERT(varchar(2), DATEPART(day, @BusinessDayLast))
    		END
		END
	END


	-----------------
	--Week
	-----------------
	IF @ShowFullTimeFrameWeek = 1
	BEGIN
		SET @TempWeekDate = (@LastWeekDate)
			
		IF @LocaleID = '2057'
    	BEGIN
    		SET @WeekThisHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(day, @TempWeekDate)) + '/' + CONVERT(varchar(2), DATEPART(month, @TempWeekDate))
    	END
    	ELSE
    	BEGIN	
			SET @WeekThisHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(month, @TempWeekDate)) + '/' + CONVERT(varchar(2), DATEPART(day, @TempWeekDate))
		END
		
		WHILE Datepart(dw,@TempWeekDate) <> 7
		BEGIN
			IF @LocaleID = '2057'
			BEGIN
				SET @TempWeekDate = DateAdd(dd,1,@TempWeekDate)
				SET @WeekCurrentHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(day, @TempWeekDate)) + '/' + CONVERT(varchar(2), DATEPART(month, @TempWeekDate))
			END
			ELSE
			BEGIN
				SET @TempWeekDate = DateAdd(dd,1,@TempWeekDate)
				SET @WeekCurrentHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(month, @TempWeekDate)) + '/' + CONVERT(varchar(2), DATEPART(day, @TempWeekDate))
			END
		END
		IF @LocaleID = '2057'
    	BEGIN
    		--SET @WeekThisHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(day, dateadd(ww,-1,@TempWeekDate))) + '/' + CONVERT(varchar(2), DATEPART(month, dateadd(ww,-1,@TempWeekDate)))
			SET @WeekLastHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(day, dateadd(ww,-1,@TempWeekDate))) + '/' + CONVERT(varchar(2), DATEPART(month, dateadd(ww,-1,@TempWeekDate)))
    	END
    	ELSE
    	BEGIN
			--SET @WeekThisHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(month, dateadd(ww,-1,@TempWeekDate))) + '/' + CONVERT(varchar(2), DATEPART(day, dateadd(ww,-1,@TempWeekDate)))
			SET @WeekLastHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(month, dateadd(ww,-1,@TempWeekDate))) + '/' + CONVERT(varchar(2), DATEPART(day, dateadd(ww,-1,@TempWeekDate)))
		END

		--Format Headings
    	select @HeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'weekheading'

	  	If @HeadingSetting = '1' 
	    	Begin
				SET @WeekCurrentHeading = 'This Week'
		    	SET @WeekThisHeading = 'Last Week'
		    	SET @WeekLastHeading = '2 Weeks Ago'
	    	End	
	
		UPDATE #MetricInfo
		SET WeekCurrentHeading = @WeekCurrentHeading,
			WeekLastHeading = @WeekLastHeading,
			WeekThisHeading = @WeekThisHeading,
			WeekCurrentStartDate = dateadd(d,-6,@TempWeekDate),
			WeekLastStartDate = dateadd(d,-6,dateadd(ww,-1,@TempWeekDate)), --replaced above lines with this mks
			WeekThisStartDate = dateadd(d,-6,@TempWeekDate) -- replaced above lines with this mks

		FROM #MetricInfo t1	
	END
	ELSE
	BEGIN
		SET @TempWeekDate = @BusinessDayThis
		
		IF @LocaleID = '2057'
		BEGIN
			SET @WeekThisHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(day, @TempWeekDate)) + '/' + CONVERT(varchar(2), DATEPART(month, @TempWeekDate))
		END
		ELSE
		BEGIN
			SET @WeekThisHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(month, @TempWeekDate)) + '/' + CONVERT(varchar(2), DATEPART(day, @TempWeekDate))
		END
		WHILE Datepart(dw,@TempWeekDate) <> 7
			BEGIN
				IF @LocaleID = '2057'
				BEGIN
					SET @TempWeekDate = DateAdd(d,1,@TempWeekDate)
					SET @WeekThisHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(day, @TempWeekDate)) + '/' + CONVERT(varchar(2), DATEPART(month, @TempWeekDate))
					SET @WeekCurrentHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(day, @TempWeekDate)) + '/' + CONVERT(varchar(2), DATEPART(month, @TempWeekDate))
				END
				ELSE
				BEGIN
					SET @TempWeekDate = DateAdd(d,1,@TempWeekDate)
					SET @WeekThisHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(month, @TempWeekDate)) + '/' + CONVERT(varchar(2), DATEPART(day, @TempWeekDate))
					SET @WeekCurrentHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(month, @TempWeekDate)) + '/' + CONVERT(varchar(2), DATEPART(day, @TempWeekDate))
				END
			END
		IF @LocaleID = '2057'
		BEGIN
			SET @WeekLastHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(day, dateadd(ww,-1,@TempWeekDate))) + '/' + CONVERT(varchar(2), DATEPART(month, dateadd(ww,-1,@TempWeekDate)))
		END
		ELSE
		BEGIN
			SET @WeekLastHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(month, dateadd(ww,-1,@TempWeekDate))) + '/' + CONVERT(varchar(2), DATEPART(day, dateadd(ww,-1,@TempWeekDate)))
		END
		--Format Headings
		select @HeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'weekheading'

  		If @HeadingSetting = '1' 
		Begin
			SET @WeekCurrentHeading = 'This Week'
    		SET @WeekThisHeading = 'This Week'
    		SET @WeekLastHeading = 'Last Week'
		End	

		SELECT -- BusinessDayThis = @BusinessDayThis , BusinessDayLast = @BusinessDayLast,
			@WeekCurrentHeading = @WeekCurrentHeading,
			@WeekLastHeading = @WeekLastHeading,
			@WeekThisHeading = @WeekThisHeading,
			@WeekCurrentStart = dateadd(d,-6,@TempWeekDate),
			@WeekLastStart = dateadd(d,-6,dateadd(ww,-1,@TempWeekDate)),
			@WeekThisStart = dateadd(d,-6,@TempWeekDate)

	END

	------------------
	--Month
	------------------
	IF @ShowFullTimeFrameMonth = 1
	BEGIN
	    select @HeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'monthheading'
	
	  	If @HeadingSetting = '1' 
    	Begin
			SET @MonthCurrentHeading = 'This Month'
	    	SET @MonthThisHeading = 'Last Month'
	    	SET @MonthLastHeading = '2 Months Ago'
        End
	    Else
        Begin
            SET @MonthCurrentHeading = LEFT(datename(mm, @BusinessDayCurrent),3)
	    	SET @MonthThisHeading = LEFT(datename(mm, dateadd(mm,-1,@BusinessDayCurrent)),3)
	    	SET @MonthLastHeading = LEFT(datename(mm, dateadd(mm,-2,@BusinessDayCurrent)),3)
    	End	

		SELECT
			@MonthCurrentHeading = @MonthCurrentHeading,
			@MonthThisHeading = @MonthThisHeading,
			@MonthLastHeading = @MonthLastHeading,
			@MonthCurrentStartDate = convert(datetime, CONVERT(varchar(4),datepart(year,dateadd(mm,0,@BusinessDayCurrent))) + RIGHT('0' + CONVERT(varchar(2),datepart(month,dateadd(mm,0,@BusinessDayCurrent))), 2) + '01' ),
			@MonthThisStartDate = convert(datetime, CONVERT(varchar(4),datepart(year,dateadd(mm,-1,@BusinessDayCurrent))) + RIGHT('0' + CONVERT(varchar(2),datepart(month,dateadd(mm,-1,@BusinessDayCurrent))), 2) + '01' ),
			@MonthLastStartDate = convert(datetime, CONVERT(varchar(4),datepart(year,dateadd(mm,-2,@BusinessDayCurrent))) + RIGHT('0' + CONVERT(varchar(2),datepart(month,dateadd(mm,-2,@BusinessDayCurrent))), 2) + '01' )
	END
	ELSE
	BEGIN
		--Format Headings
		select @HeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'monthheading'

  		If @HeadingSetting = '1' 
		Begin
			SET @MonthCurrentHeading = 'This Month'
    		SET @MonthThisHeading = 'This Month'
    		SET @MonthLastHeading = 'Last Month'
		End	
		Else
		Begin
			SET @MonthCurrentHeading = LEFT(datename(mm, @BusinessDayThis),3)
    		SET @MonthThisHeading = LEFT(datename(mm, @BusinessDayThis),3)
    		SET @MonthLastHeading = LEFT(datename(mm, dateadd(mm,-1,@BusinessDayThis )),3)
		End

		SELECT @MonthCurrentHeading = @MonthCurrentHeading,
			@MonthThisHeading = @MonthThisHeading,
			@MonthLastHeading = @MonthLastHeading,
			@MonthCurrentStartDate = convert(datetime, CONVERT(varchar(4),datepart(year,dateadd(mm,0,@BusinessDayThis))) + RIGHT('0' + CONVERT(varchar(2),datepart(month,dateadd(mm,0,@BusinessDayThis))), 2) + '01' ),
			@MonthThisStartDate = convert(datetime, CONVERT(varchar(4),datepart(yyyy,@BusinessDayThis)) + RIGHT('0' + CONVERT(varchar(2),datepart(month,@BusinessDayThis)), 2) + '01' ),
			@MonthLastStartDate = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(m,-1,@BusinessDayThis))) + RIGHT('0' + CONVERT(varchar(2),datepart(month,dateadd(m,-1,@BusinessDayThis))), 2) + '01' )
	END
	

	----------------
	--Quarter
	----------------

	IF @ShowFullTimeFrameQuarter = 1
	BEGIN
		If datename(q, dateadd(q,-1,@BusinessDayCurrent)) in (1) 
			Begin
				set @TempDate = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-1,@BusinessDayCurrent))) + '0101' )
				set @TempDate2 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-2,@BusinessDayCurrent))) + '1001' )
				set @TempDate3 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,0,@BusinessDayCurrent))) + '0401' )
			End
		Else If datename(q, dateadd(q,-1,@BusinessDayCurrent)) in (2) 
			Begin
				set @TempDate = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-1,@BusinessDayCurrent))) + '0401'  )
				set @TempDate2 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-2,@BusinessDayCurrent))) + '0101' )
				set @TempDate3 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,0,@BusinessDayCurrent))) + '0701' )
			End
		Else If datename(q, dateadd(q,-1,@BusinessDayCurrent)) in (3) 
			Begin
				set @TempDate = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-1,@BusinessDayCurrent))) + '0701' )
				set @TempDate2 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-2,@BusinessDayCurrent))) + '0401' )
				set @TempDate3 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,0,@BusinessDayCurrent))) + '1001' )
			End
		Else If datename(q, dateadd(q,-1,@BusinessDayCurrent)) in (4) 
			Begin
				set @TempDate = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-1,@BusinessDayCurrent))) + '1001' )
				set @TempDate2 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-2,@BusinessDayCurrent))) + '0701' )
				set @TempDate3 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,0,@BusinessDayCurrent))) + '0101' )
			End
		Else
			Begin
				set @TempDate = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-1,@BusinessDayCurrent))) + RIGHT('0' + CONVERT(varchar(2),datepart(mm,dateadd(qq,-1,@BusinessDayThis))), 2) + '01' )
				set @TempDate2 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-2,@BusinessDayCurrent))) + RIGHT('0' + CONVERT(varchar(2),datepart(mm,dateadd(qq,-2,@BusinessDayThis))), 2) + '01' )
				set @TempDate3 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,0,@BusinessDayCurrent))) + RIGHT('0' + CONVERT(varchar(2),datepart(mm,dateadd(qq,0,@BusinessDayThis))), 2) + '01' )
			End

		--Format Headings
   		select @HeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'quarterheading'

    	If @HeadingSetting = '1' 
    		Begin
				SET @QuarterCurrentHeading = 'This Qtr'
		    	SET @QuarterThisHeading = 'Last Qtr'
		    	SET @QuarterLastHeading = '2 Qtrs Ago'
    		End	
    	Else
	        Begin
	            SET @QuarterCurrentHeading = 'Qtr ' + datename(q, @BusinessDayCurrent) + ' ' + datename(yyyy,@BusinessDayCurrent)
		    	SET @QuarterThisHeading =  'Qtr ' + datename(q, dateadd(q,-1,@BusinessDayThis)) + ' ' + datename(yyyy,dateadd(q,-1,@BusinessDayCurrent))
		    	SET @QuarterLastHeading = 'Qtr ' + datename(q, dateadd(q,-2,@BusinessDayThis)) + ' ' + datename(yyyy,dateadd(q,-2,@BusinessDayCurrent))
	        End

		SELECT
			@QuarterCurrentHeading = @QuarterCurrentHeading,
			@QuarterThisHeading = @QuarterThisHeading,
			@QuarterLastHeading = @QuarterLastHeading,
			@QuarterCurrentStartDate = @TempDate3,
			@QuarterThisStartDate = @TempDate,
			@QuarterLastStartDate = @TempDate2
	END
	ELSE
	BEGIN

		If datename(q, @BusinessDayThis) in (1) 
			Begin
				set @TempDate = convert(datetime, CONVERT(varchar(4),datepart(yyyy,@BusinessDayThis)) + '0101'  )
				set @TempDate2 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-1,@BusinessDayThis))) + '1001' )
			End
		Else If datename(q, @BusinessDayThis) in (2)
			Begin
				Set @TempDate = convert(datetime, CONVERT(varchar(4),datepart(yyyy,@BusinessDayThis)) + '0401' )
				set @TempDate2 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-1,@BusinessDayThis))) + '0101' )
			End
		Else If datename(q, @BusinessDayThis) in (3) 
			Begin
				set @TempDate = convert(datetime, CONVERT(varchar(4),datepart(yyyy,@BusinessDayThis)) + '0701' )
				set @TempDate2 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-1,@BusinessDayThis))) + '0401' )
			End
		Else If datename(q, @BusinessDayThis) in (4) 
			Begin
				set @TempDate = convert(datetime, CONVERT(varchar(4),datepart(yyyy,@BusinessDayThis)) + '1001' )
				set @TempDate2 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-1,@BusinessDayThis))) + '0701')
			End
		Else
			Begin
				set @TempDate = convert(datetime, CONVERT(varchar(4),datepart(yyyy,@BusinessDayThis)) + RIGHT('0' + CONVERT(varchar(2),datepart(mm,@BusinessDayThis)), 2) + '01' )
				set @TempDate2 = convert(datetime, CONVERT(varchar(4),datepart(yyyy,dateadd(qq,-1,@BusinessDayThis))) + RIGHT('0' + CONVERT(varchar(2),datepart(mm,dateadd(qq,-1,@BusinessDayThis))), 2) + '01' )
			End

		--Format Headings
   		 select @HeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'quarterheading'

    	If @HeadingSetting = '1' 
    		Begin
				SET @QuarterCurrentHeading = 'This Qtr'
		    	SET @QuarterThisHeading = 'This Qtr'
		    	SET @QuarterLastHeading = 'Last Qtr'
    		End	
    	Else
	        Begin
	            SET @QuarterCurrentHeading = 'Qtr ' + datename(q, @BusinessDayCurrent)  +' '+ datename(yyyy,@BusinessDayCurrent)
		    	SET @QuarterThisHeading = 'Qtr ' + datename(q, @BusinessDayThis)  +' '+ datename(yyyy,@BusinessDayThis)
		    	SET @QuarterLastHeading = 'Qtr ' + datename(q, dateadd(q,-1,@BusinessDayThis)) +' '+ datename(yyyy,dateadd(q,-1,@BusinessDayThis))
	        End

		SELECT
			@QuarterCurrentHeading = @QuarterCurrentHeading,
			@QuarterThisHeading = @QuarterThisHeading,
			@QuarterLastHeading = @QuarterLastHeading,
			@QuarterCurrentStartDate = @TempDate,
			@QuarterThisStartDate = @TempDate,
			@QuarterLastStartDate = @TempDate2
	END
	


	----------------
	--Year
	----------------
	IF @ShowFullTimeFrameYear = 1
	BEGIN
		--Format Headings
   		 select @HeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'yearheading'

    	If @HeadingSetting = '1' 
    		Begin
				SET @YearCurrentHeading = 'This Year'
		    	SET @YearThisHeading = 'Last Year'
		    	SET @YearLastHeading = '2 Years Ago'
    		End	
    	Else
	        Begin
	            SET @YearCurrentHeading = datename(yyyy,@BusinessDayCurrent)
		    	SET @YearThisHeading = datename(yyyy,dateadd(yyyy,-1,@BusinessDayCurrent))
		    	SET @YearLastHeading = datename(yyyy,dateadd(yyyy,-2,@BusinessDayCurrent))
	        End

		SELECT
			@YearCurrentHeading = @YearCurrentHeading,
			@YearThisHeading = @YearThisHeading,
			@YearLastHeading = @YearLastHeading,
			@YearCurrentStartDate = convert(datetime, CONVERT(varchar(4),datepart(year,dateadd(yyyy,0,@BusinessDayCurrent))) + '0101' ),
			@YearThisStartDate = convert(datetime, CONVERT(varchar(4),datepart(year,dateadd(yyyy,-1,@BusinessDayCurrent))) + '0101' ),
			@YearLastStartDate = convert(datetime, CONVERT(varchar(4),datepart(year,dateadd(yyyy,-2,@BusinessDayCurrent))) + '0101' )
	END
	ELSE
	BEGIN

		--Format Headings
   		select @HeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'yearheading'

    	If @HeadingSetting = '1' 
		Begin
			SET @YearCurrentHeading = 'This Year'
	    	SET @YearThisHeading = 'This Year'
	    	SET @YearLastHeading = 'Last Year'
		End	
    	Else
        Begin
            SET @YearCurrentHeading = datename(yyyy,@BusinessDayCurrent)
	    	SET @YearThisHeading = datename(yyyy,@BusinessDayThis)
	    	SET @YearLastHeading = datename(yyyy,dateadd(yyyy,-1,@BusinessDayThis))
        End

		SELECT 
			@YearCurrentHeading = @YearCurrentHeading,
			@YearThisHeading = @YearThisHeading,
			@YearLastHeading = @YearLastHeading,
			@YearCurrentStartDate = convert(datetime, CONVERT(varchar(4),datepart(year,@BusinessDayThis)) + '0101' ),
			@YearThisStartDate = convert(datetime, CONVERT(varchar(4),datepart(year,@BusinessDayThis)) + '0101' ),
			@YearLastStartDate = convert(datetime, CONVERT(varchar(4),datepart(year,dateadd(yyyy,-1,@BusinessDayThis))) + '0101' )
	END
	

	----------------
	--Fiscal Year
	----------------

	--Fiscal Start Date
	SELECT @FiscalYearStartDate = settingvalue from metricgeneralsettings where settingname = 'FiscalYearStart'

	--Fiscal Heading Setting (Example:  This Fiscal Year or 2006)
	select @HeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'Fiscalyearheading'

	--Fiscal Year Heading (Year Ended = Y, Year Started = N)
	set @FiscalYearEndingYN = (Select settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'FiscalYearEndingYN')

	--Max Fiscal Year
	IF @BusinessDayCurrent  < CAST(@FiscalYearStartDate + '/' + datename(yyyy,@BusinessDayCurrent) as datetime)
		SET @MaxFiscalYearStartDate = dateadd(year,-1,cast(@FiscalYearStartDate + '/' + datename(yyyy,@BusinessDayCurrent) as datetime))
	ELSE
		SET @MaxFiscalYearStartDate = CAST(@FiscalYearStartDate + '/' + datename(yyyy,@BusinessDayCurrent) as datetime)

	IF @ShowFullTimeFrameFiscalYear = 1
	BEGIN
    	IF @HeadingSetting = '1' 
		Begin
			SELECT
				@FiscalYearCurrentHeading = 'This Fiscal Year',
				@FiscalYearThisHeading = 'Last Fiscal Year',
				@FiscalYearLastHeading = '2 Fiscal Years Ago',
				@FiscalYearCurrentStartDate = @MaxFiscalYearStartDate,
				@FiscalYearThisStartDate = DateAdd(year,-1,@MaxFiscalYearStartDate),
				@FiscalYearLastStartDate = DateAdd(year,-2,@MaxFiscalYearStartDate)
		End	
    	Else
        Begin
			IF @FiscalYearEndingYN = 'Y'
				SELECT
					@FiscalYearCurrentHeading = DatePart(yyyy,DateAdd(day,-1,DateAdd(year,1,@MaxFiscalYearStartDate))),
					@FiscalYearThisHeading = DatePart(yyyy,DateAdd(year,-1,DateAdd(day,-1,DateAdd(year,1,@MaxFiscalYearStartDate)))),
					@FiscalYearLastHeading = DatePart(yyyy,DateAdd(year,-2,DateAdd(day,-1,DateAdd(year,1,@MaxFiscalYearStartDate)))),
					@FiscalYearCurrentStartDate = @MaxFiscalYearStartDate,
					@FiscalYearThisStartDate = DateAdd(year,-1,@MaxFiscalYearStartDate),
					@FiscalYearLastStartDate = DateAdd(year,-2,@MaxFiscalYearStartDate)
			ELSE
				SELECT
					@FiscalYearCurrentHeading = DatePart(yyyy,@MaxFiscalYearStartDate),
					@FiscalYearThisHeading = DatePart(yyyy,DateAdd(year,-1,@MaxFiscalYearStartDate)),
					@FiscalYearLastHeading = DatePart(yyyy,DateAdd(year,-2,@MaxFiscalYearStartDate)),
					@FiscalYearCurrentStartDate = @MaxFiscalYearStartDate,
					@FiscalYearThisStartDate = DateAdd(year,-1,@MaxFiscalYearStartDate),
					@FiscalYearLastStartDate = DateAdd(year,-2,@MaxFiscalYearStartDate)
        End		
	END
	ELSE
	BEGIN
    	IF @HeadingSetting = '1' 
		Begin
			SELECT
				@FiscalYearCurrentHeading = 'This Fiscal Year',
				@FiscalYearThisHeading = 'This Fiscal Year',
				@FiscalYearLastHeading = 'Last Fiscal Year',
				@FiscalYearCurrentStartDate = @MaxFiscalYearStartDate,
				@FiscalYearThisStartDate = @MaxFiscalYearStartDate,
				@FiscalYearLastStartDate = DateAdd(year,-1,@MaxFiscalYearStartDate)
		End	
    	Else
        Begin
			IF @FiscalYearEndingYN = 'Y'
				SELECT 
					@FiscalYearCurrentHeading = DatePart(yyyy,DateAdd(day,-1,DateAdd(year,1,@MaxFiscalYearStartDate))),
					@FiscalYearThisHeading = DatePart(yyyy,DateAdd(day,-1,DateAdd(year,1,@MaxFiscalYearStartDate))),
					@FiscalYearLastHeading = DatePart(yyyy,DateAdd(year,-1,DateAdd(day,-1,DateAdd(year,1,@MaxFiscalYearStartDate)))),
					@FiscalYearCurrentStartDate = @MaxFiscalYearStartDate,
					@FiscalYearThisStartDate = @MaxFiscalYearStartDate,
					@FiscalYearLastStartDate = DateAdd(year,-1,@MaxFiscalYearStartDate)
			ELSE
				SELECT 
					@FiscalYearCurrentHeading = DatePart(yyyy,@MaxFiscalYearStartDate),
					@FiscalYearThisHeading = DatePart(yyyy,@MaxFiscalYearStartDate),
					@FiscalYearLastHeading = DatePart(yyyy,DateAdd(year,-1,@MaxFiscalYearStartDate)),
					@FiscalYearCurrentStartDate = @MaxFiscalYearStartDate,
					@FiscalYearThisStartDate = @MaxFiscalYearStartDate,
					@FiscalYearLastStartDate = DateAdd(year,-1,@MaxFiscalYearStartDate)
        End
	END
			
	--Final Select
	SELECT 
		BusinessDayCurrentDate = dbo.MetricCvtDateToText(@BusinessDayCurrent), 
		BusinessDayThisDate = dbo.MetricCvtDateToText(@BusinessDayThis), 
		BusinessDayLastDate = dbo.MetricCvtDateToText(@BusinessDayLast), 
		WeekCurrentStartDate = dbo.MetricCvtDateToText(@WeekCurrentStart), 
		WeekThisStartDate = dbo.MetricCvtDateToText(@WeekThisStart), 
		WeekLastStartDate = dbo.MetricCvtDateToText(@WeekLastStart),

		MonthCurrentStartDate = dbo.MetricCvtDateToText(@MonthCurrentStartDate), 
		MonthThisStartDate = dbo.MetricCvtDateToText(@MonthThisStartDate), 
		MonthLastStartDate = dbo.MetricCvtDateToText(@MonthLastStartDate), 
		QuarterCurrentStartDate = dbo.MetricCvtDateToText(@QuarterCurrentStartDate), 		
		QuarterThisStartDate = dbo.MetricCvtDateToText(@QuarterThisStartDate), 
		QuarterLastStartDate = dbo.MetricCvtDateToText(@QuarterLastStartDate), 
		YearCurrentStartDate = dbo.MetricCvtDateToText(@YearCurrentStartDate), 
		YearThisStartDate = dbo.MetricCvtDateToText(@YearThisStartDate), 
		YearLastStartDate = dbo.MetricCvtDateToText(@YearLastStartDate), 
		FiscalYearCurrentStartDate = dbo.MetricCvtDateToText(@FiscalYearCurrentStartDate), 
		FiscalYearThisStartDate = dbo.MetricCvtDateToText(@FiscalYearThisStartDate), 
		FiscalYearLastStartDate = dbo.MetricCvtDateToText(@FiscalYearLastStartDate)

GO
GRANT EXECUTE ON  [dbo].[MetricDateRanges] TO [public]
GO
