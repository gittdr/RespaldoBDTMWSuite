SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetCategoryInfo]
(
	@Category varchar(30), 
	@LayerCodeFilter varchar(255)
)
AS
	SET NOCOUNT ON  -- Must be on when using with SQLOLEDB
--Variable Declaration
/*
UPDATE metricItem 
SET BadData = 	(SELECT CASE WHEN EXISTS(SELECT sn FROM metricdetail (NOLOCK) WHERE metricCode = t1.metriccode AND DailyValue IS NULL) THEN 'x' ELSE '' END)
FROM MetricItem t1 
*/
	DECLARE @BusinessDayCurrent varchar(100), --This is the most recent Day processed in metricdetail.
			@BusinessDayThis varchar(100), --This is either the Current Day or the last FULL Business Day based on MetricCategory settings
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
--			@BusinessDayValue int,
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
--            @HeadingSetting varchar(1),
            @DayHeadingSetting varchar(1),
            @WeekHeadingSetting varchar(1),
            @MonthHeadingSetting varchar(1),
            @QuarterHeadingSetting varchar(1),
            @YearHeadingSetting varchar(1),
            @FiscalYearHeadingSetting varchar(1),
            @HeadingDaysBack int,
		    @DateFirst int,
            @FullTimeFrameDay char(1),
			@FiscalYearEndingYN char(1),
			@Annualize int,
			@MaxFiscalYearStartDate datetime
			
	DECLARE @Suffix varchar(200)
	Declare @LayerFilter varchar(100)
	DECLARE @MaxPlainYearWeekForPreviousWeek varchar(6)
	DECLARE @Style varchar(10) -- @Style: 'Normal' or 'Alt01'
	DECLARE @AltTimeFrameMonth varchar(100), @AltTimeFrameQuarter varchar(100), @AltTimeFrameYear varchar(100)
	DECLARE @dt1 datetime, @dt2 datetime, @dt3 datetime
	DECLARE @AllowChartDisplay_YN varchar(1)
	
	-- SET @Style = 'Alt01'
	SELECT @Style = CASE WHEN EXISTS(SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'UseAlternateTimeFramesYN' AND SettingValue = 'Y')
						THEN 'Alt01' ELSE '' END
	IF @Style = 'Alt01'
		SELECT 
			@AltTimeFrameMonth = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameMonth'), 'Month')
			,@AltTimeFrameQuarter = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameQuarter'), 'Quarter')
			,@AltTimeFrameYear = ISNULL((SELECT SettingValue FROM MetricGeneralSettings WHERE SettingName = 'AltTimeFrameYear'), 'Year')
	ELSE
		SELECT @AltTimeFrameMonth = 'Month', @AltTimeFrameQuarter = 'Quarter', @AltTimeFrameYear = 'Year'


--Create Temp Table
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
								
								CurrentDay decimal(20, 5),
								ThisDay decimal(20, 5), 
								LastDay decimal(20, 5), 
								GoalDay decimal(20, 5),
                                FullTimeFrameDay char(1),
								BusinessDayCurrent varchar(30),
								BusinessDayThis varchar(30), 
								BusinessDayLast varchar(30), 
								BusinessDayCurrentDate datetime,
								BusinessDayThisDate datetime,
								BusinessDayLastDate datetime,
																
								CurrentWeek decimal(20, 5),
								ThisWeek decimal(20, 5), 
								LastWeek decimal(20, 5), 
								GoalWeek decimal(20, 5), 
                                FullTimeFrameWeek char(1),
								WeekCurrentHeading varchar(30),
								WeekThisHeading varchar(30),
								WeekLastHeading varchar(30),
								WeekCurrentStartDate datetime,
								WeekThisStartDate datetime,
								WeekLastStartDate datetime,
																
                                CurrentMonth decimal(20,5),
								ThisMonth decimal(20, 5), 
								LastMonth decimal(20, 5), 
								GoalMonth decimal(20, 5), 
								FullTimeFrameMonth char(1),
								MonthCurrentHeading varchar(30),
								MonthThisHeading varchar(30),
								MonthLastHeading varchar (30),
								MonthCurrentStartDate datetime,
								MonthThisStartDate datetime,
								MonthLastStartDate datetime,
								MonthCurrentEndDate datetime,
								MonthThisEndDate datetime,
								MonthLastEndDate datetime,
															
								CurrentQuarter decimal(20,5),
								ThisQuarter decimal(20, 5), 
								LastQuarter decimal(20, 5), 
								GoalQuarter decimal(20, 5), 
								FullTimeFrameQuarter char(1),
								QuarterCurrentHeading varchar(30),
								QuarterThisHeading varchar(30),
								QuarterLastHeading varchar(30),
								QuarterCurrentStartDate datetime,
								QuarterThisStartDate datetime,
								QuarterLastStartDate datetime,
								QuarterCurrentEndDate datetime,
								QuarterThisEndDate datetime,
								QuarterLastEndDate datetime,
																																
                                CurrentYear decimal(20,5),
								ThisYear decimal(20, 5), 
								LastYear decimal(20, 5), 
								GoalYear decimal(20, 5),
								FullTimeFrameYear char(1),
								FullTimeFrameFiscalYear char(1),
								YearCurrentHeading varchar(30),
								YearThisHeading varchar(30),
								YearLastHeading varchar(30),
								YearCurrentStartDate datetime,
								YearThisStartDate datetime,
								YearLastStartDate datetime,
								YearCurrentEndDate datetime,
								YearThisEndDate datetime,
								YearLastEndDate datetime,
																								
                                CurrentFiscalYear decimal(20,5),
								ThisFiscalYear decimal(20, 5), 
								LastFiscalYear decimal(20, 5), 
								GoalFiscalYear decimal(20,5),
								FiscalYearCurrentHeading varchar(30),
								FiscalYearThisHeading varchar(30),
								FiscalYearLastHeading varchar(30),
								FiscalYearCurrentStartDate datetime,
								FiscalYearThisStartDate datetime,
								FiscalYearLastStartDate datetime,
																								
								GoalDigs int,

								AsOfDate varchar(10), 
						
								ShowDetailByDefault varchar(1), 
								Cumulative int, 
								Annualize int,
								Active int DEFAULT(-1),
								CurrentLastUpdate datetime,
                                ThisLastUpdate datetime,
								LastLastUpdate datetime,
								DetailFilename varchar(50),
								DataSourceSN int,
								BadData varchar(1)
							 )


	Select @DateFirst = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'datefirst'
  	select @DayHeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'dayheading'
	select @WeekHeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'weekheading'
	select @MonthHeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'monthheading'
	select @QuarterHeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'quarterheading'
	select @YearHeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'yearheading'
	select @FiscalYearHeadingSetting = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'Fiscalyearheading'
    SELECT @LocaleID = settingvalue from metricgeneralsettings where settingname = 'RNLocaleID'	
	SELECT @FiscalYearStartDate = settingvalue from metricgeneralsettings where settingname = 'FiscalYearStart'					--Fiscal Heading Setting (Example:  This Fiscal Year or 2006)
	SELECT @FiscalYearEndingYN = settingvalue from metricgeneralsettings WITH (NOLOCK) where settingname = 'FiscalYearEndingYN' --Fiscal Year Heading (Year Ended = Y, Year Started = N)

	SELECT @BusinessDayCurrent = MAX(PlainDate)
	FROM MetricDetail WITH (NOLOCK) JOIN MetricCategoryItems ON metricdetail.metriccode = metriccategoryitems.metriccode
	WHERE CategoryCode = @Category

--DECLARE @getdate datetime, @Step int

--SELECT @getdate = getdate(), @step = 0


    set datefirst @DateFirst

	IF (SELECT Active From MetricCategory WHERE CategoryCode = @Category) = 0
	BEGIN
		SELECT '' AS Nothing
		RETURN
	END

	Set @DateToUseAdjusted = CAST(CONVERT(char(8),getdate(),112) as datetime)

	--If No Layer Code, then No Suffix, otherwise set suffix to appropriate layer
	IF ISNULL(@LayerCodeFilter, '') = '' 
		SELECT @Suffix = '' 
	ELSE 
		SELECT @Suffix = '@' + @LayerCodeFilter
	
	--Find Setting for FullTime Frame
	SELECT @ShowFullTimeFrameDay = ShowFullTimeFrameDay,
			@ShowFullTimeFrameWeek = ShowFullTimeFrameWeek,
			@ShowFullTimeFrameMonth = ShowFullTimeFrameMonth,
			@ShowFullTimeFrameQuarter = ShowFullTimeFrameQuarter,
			@ShowFullTimeFrameYear = ShowFullTimeFrameYear,
			@ShowFullTimeFrameFiscalYear = ShowFullTimeFrameFiscalYear,
			@AllowChartDisplay_YN = ISNULL(AllowChartDisplay_YN, 'Y')
	FROM MetricCategory WITH (NOLOCK)
	WHERE CategoryCode = @Category

	DECLARE @MostRecentDateProcessedForCategory datetime

	--Find the Last Business Day Processed into MetricDetail, 
	--starting with Max Date in MetricDetail and proceeding back by 1 day at a time
	--This would be the THIS DAY (and possibly the CURRENT DAY)
	SELECT @MostRecentDateProcessedForCategory = MAX(PlainDate)
	FROM MetricDetail WITH (NOLOCK) JOIN MetricCategoryItems ON metricdetail.metriccode = metriccategoryitems.metriccode
	WHERE CategoryCode = @Category

	-- plainyearweek
	-- 1/8/2008 DAG (START): Giant Eagle reported this bug.  When time frame for week spans between years.
	SELECT @MaxPlainYearWeekForPreviousWeek = (select MAX(plainyearweek) FROM metricdetail (NOLOCK) WHERE plaindate = dateadd(week,-1, @MostRecentDateProcessedForCategory))

	SELECT @LastWeekDate = MAX(PlainDate)
	FROM MetricDetail WITH (NOLOCK) JOIN MetricCategoryItems ON metricdetail.metriccode = metriccategoryitems.metriccode
	WHERE CategoryCode = @Category AND PlainYearWeek = @MaxPlainYearWeekForPreviousWeek 
	-- 1/8/2008 DAG (END)


	-- Find the MOST RECENT business day that is ON or BEFORE the most recent processed.
	SELECT @BusinessDayThis = dbo.fnc_GetMostRecentBusinessDate(@MostRecentDateProcessedForCategory, 0) -- 0 is the offset.
	--Find the Next to Last Business Day Processed into MetricDetail, starting with @BusinessDayThis -1 and proceeding back by 1 day at a time
	SELECT @BusinessDayLast = dbo.fnc_GetMostRecentBusinessDate(@BusinessDayThis, -1) -- 0 is the offset.

--NOTE:  NEED TO ADD HEADING SETTINGS HERE

--Format the headings for this and last 
	select @FullTimeFrameDay = 'N'
  	If @DayHeadingSetting = '1' 
	Begin
        If @BusinessDayThis = CAST(CONVERT(char(8),getdate(),112) as datetime)
			SELECT @BusinessDayCurrentHeading = 'Today', @BusinessDayThisHeading = 'Today'
		ELSE
			SELECT @BusinessDayCurrentHeading = cast(-datediff(dd,getdate(),@BusinessDayCurrent) as char(4)) + 'Days Ago',
        			@BusinessDayThisHeading = cast(-datediff(dd,getdate(),@BusinessDayThis) as char(4)) + 'Days Ago'

        If @BusinessDayLast =  dateadd(d,-1,CAST(CONVERT(char(8),getdate(),112) as datetime))
            SELECT @BusinessDayLastHeading = 'Yesterday'
    	ELSE
			SELECT @BusinessDayLastHeading = cast(-datediff(dd,getdate(),@BusinessDayLast) as char(4)) + 'Days Ago'
	End	
 	Else	
	Begin
		IF @LocaleID = '2057'
			SELECT @BusinessDayCurrentHeading = LEFT(DATENAME(dw, @BusinessDayCurrent),3) + ' ' + CONVERT(varchar(2), DATEPART(day, @BusinessDayCurrent)) + '/' + CONVERT(varchar(2), DATEPART(month, @BusinessDayCurrent))
    			,@BusinessDayThisHeading = LEFT(DATENAME(dw, @BusinessDayThis),3) + ' ' + CONVERT(varchar(2), DATEPART(day, @BusinessDayThis)) + '/' + CONVERT(varchar(2), DATEPART(month, @BusinessDayThis))
    			,@BusinessDayLastHeading = LEFT(DATENAME(dw, @BusinessDayLast),3) + ' ' + CONVERT(varchar(2), DATEPART(day, @BusinessDayLast)) + '/' + CONVERT(varchar(2), DATEPART(month, @BusinessDayLast))
		ELSE
			SELECT @BusinessDayCurrentHeading = LEFT(DATENAME(dw, @BusinessDayCurrent),3) + ' ' + CONVERT(varchar(2), DATEPART(month, @BusinessDayCurrent)) + '/' + CONVERT(varchar(2), DATEPART(day, @BusinessDayCurrent))
    			,@BusinessDayThisHeading = LEFT(DATENAME(dw, @BusinessDayThis),3) + ' ' + CONVERT(varchar(2), DATEPART(month, @BusinessDayThis)) + '/' + CONVERT(varchar(2), DATEPART(day, @BusinessDayThis))
    			,@BusinessDayLastHeading = LEFT(DATENAME(dw, @BusinessDayLast),3) + ' ' + CONVERT(varchar(2), DATEPART(month, @BusinessDayLast)) + '/' + CONVERT(varchar(2), DATEPART(day, @BusinessDayLast))
	End

	--If the option for FullTimeFrame is selected, This = Last and Last = Last - 1
	--NOTE:  Current is still the most recent date processed
	IF @ShowFullTimeFrameDay = 1 
	BEGIN
		SET @FullTimeFrameDay = 'Y'
		SET @BusinessDayCurrent = @BusinessDayThis
		SET @BusinessDayThis = @BusinessDayLast
		SELECT @BusinessDayLast = dbo.fnc_GetMostRecentBusinessDate(@BusinessDayLast, -1)

		--NOTE:  NEED TO ADD HEADING SETTINGS HERE
		--Format the headings for this and last 
	  	If @DayHeadingSetting = '1' 
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
    	End	
 		Else	
    	Begin
    		IF @LocaleID = '2057'
  				SELECT @BusinessDayCurrentHeading = LEFT(DATENAME(dw, @BusinessDayCurrent),3) + ' ' + CONVERT(varchar(2), DATEPART(day, @BusinessDayCurrent)) + '/' + CONVERT(varchar(2), DATEPART(month, @BusinessDayCurrent))
	    			,@BusinessDayThisHeading = LEFT(DATENAME(dw, @BusinessDayThis),3) + ' ' + CONVERT(varchar(2), DATEPART(day, @BusinessDayThis)) + '/' + CONVERT(varchar(2), DATEPART(month, @BusinessDayThis))
	    			,@BusinessDayLastHeading = LEFT(DATENAME(dw, @BusinessDayLast),3) + ' ' + CONVERT(varchar(2), DATEPART(day, @BusinessDayLast)) + '/' + CONVERT(varchar(2), DATEPART(month, @BusinessDayLast))
    		ELSE
				SELECT @BusinessDayCurrentHeading = LEFT(DATENAME(dw, @BusinessDayCurrent),3) + ' ' + CONVERT(varchar(2), DATEPART(month, @BusinessDayCurrent)) + '/' + CONVERT(varchar(2), DATEPART(day, @BusinessDayCurrent))
	    			,@BusinessDayThisHeading = LEFT(DATENAME(dw, @BusinessDayThis),3) + ' ' + CONVERT(varchar(2), DATEPART(month, @BusinessDayThis)) + '/' + CONVERT(varchar(2), DATEPART(day, @BusinessDayThis))
	    			,@BusinessDayLastHeading = LEFT(DATENAME(dw, @BusinessDayLast),3) + ' ' + CONVERT(varchar(2), DATEPART(month, @BusinessDayLast)) + '/' + CONVERT(varchar(2), DATEPART(day, @BusinessDayLast))
  		End
	END

	--Show All Layers By Default Option
	SELECT Distinct metricitem.MetricCode, 
		categorycode,
		metricitem.MetricCode as TopLevelMetric, 
		metriccategoryitems.sort,
		showlayersbydefault,
		layerfilter
	INTO #TempTableForLayers
	From metricitem,metriccategoryitems
	Where metriccategoryitems.categorycode = @Category
		AND (MetricItem.MetricCode like metriccategoryitems.metriccode+'@%'
				-- PTS Change: Added line below to handle metrics in multiple categories.
				OR MetricItem.MetricCode = metriccategoryitems.metriccode
			)

	DELETE FROM #TempTableForLayers
	WHERE (MetricCode like '%@%' AND ShowLayersByDefault <> 1 And Not Exists (select mcatitem.metriccode from metriccategoryitems mcatitem where categorycode=@category and mcatitem.metriccode=#TempTableForLayers.metriccode))
		OR
	      (MetricCode like '%@%' And ShowLayersByDefault = 1  AND IsNull(layerfilter,'ALL') <> 'ALL' And MetricCode Not Like '%@' + LayerFilter + '%')

	-- delete duplicates if certain layers are in MetricCategoryInfo
	delete from #TempTableForLayers
		where CONVERT(VARCHAR(5), sort) + MetricCode in(
											select CONVERT(VARCHAR(5), sort) + MetricCode from #TempTableForLayers a
											where exists (select TOP 1 * from #TempTableForLayers b
											where a.metriccode = b.metriccode 
											and IsNull(a.sort,-1) < IsNull(b.sort,-1)))
	
	--Insert the Category Metrics in Temp Table
	INSERT INTO #MetricInfo (	TopLevelMetric, sort, CategoryCode, Caption, CaptionFull, 
								ItemCaption, ItemCaptionFull, BusinessDayCurrent, 
								BusinessDayThis, BusinessDayLast, BusinessDayThisDate,
								BusinessDayLastDate, 
								AsOfDate, ShowDetailByDefault, Cumulative, Annualize, DetailFilename)
	SELECT 	t4.TopLevelMetric As TopLevelMetric, t4.sort AS sort, t4.CategoryCode, t3.Caption, 
			t3.CaptionFull, t2.Caption, t2.CaptionFull, @BusinessDayCurrentHeading,
			@BusinessDayThisHeading, @BusinessDayLastHeading, @BusinessDayThis,
			@BusinessDayLast,
			@AsOfDate, t2.ShowDetailByDefaultYN, t2.Cumulative, t2.Annualize, t2.DetailFilename
    FROM metricitem t2 WITH (NOLOCK), metriccategory t3 WITH (NOLOCK), #TempTableForLayers t4
    WHERE 	t4.CategoryCode = t3.CategoryCode  
		 	AND t2.Active = 1 
			AND t4.CategoryCode = @Category
			AND t4.TopLevelMetric = t2.MetricCode
			
--Update the Metric and Goal Info

	UPDATE #MetricInfo
	SET MetricCode = t2.MetricCode,
		FormatText = t2.FormatText,
		Digs = t2.NumDigitsAfterDecimal,
		Active = t2.Active,
		PlusDeltaIsGood = t2.PlusDeltaIsGood,
		GoalDigs = t2.GoalNumDigitsAfterDecimal,
		GoalDay = t2.GoalDay, GoalWeek = t2.GoalWeek, 
		GoalMonth = t2.GoalMonth, GoalQuarter = t2.GoalQuarter, 
		GoalYear = t2.GoalYear, GoalFiscalYear = t2.GoalFiscalYear,
		DataSourceSN = ISNULL(t2.DataSourceSN, 0),
		BadData = t2.BadData
	FROM #MetricInfo t1, MetricItem t2 WITH (NOLOCK)
	WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode

	--Update This/Last Info
	--NEEDS TO COME FROM METRIC DETAIL NOT METRIC ITEM!!!!!
	UPDATE #MetricInfo
	SET FullTimeFrameDay = @FullTimeFrameDay,
		CurrentDay = CASE t1.Annualize WHEN 1 THEN t2.dailyvalue * 364.25 ELSE t2.dailyvalue END,
		BusinessDayCurrentDate = @BusinessDayCurrent,
        CurrentLastUpdate = t2.upd_daily
	FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
	WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
		AND t2.PlainDate = @BusinessDayCurrent

	UPDATE #MetricInfo
	SET ThisDay = CASE t1.Annualize WHEN 1 THEN t2.dailyvalue * 364.25 ELSE t2.dailyvalue END,
		BusinessDayThisDate = @BusinessDayThis,
        ThisLastUpdate = t2.upd_daily
	FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
	WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
		AND t2.PlainDate = @BusinessDayThis

	UPDATE #MetricInfo
	SET LastDay = CASE t1.Annualize WHEN 1 THEN t2.dailyvalue * 364.25 ELSE t2.dailyvalue END,
		BusinessDayLastDate = @BusinessDayLast,
        LastLastUpdate = t2.upd_daily
	FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
	WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
		AND t2.PlainDate = @BusinessDayLast 

	-----------------
	--Week
	-----------------

	UPDATE #MetricInfo
	SET CurrentWeek = CASE t1.Annualize WHEN 1 THEN t2.ThisWTD * 52 ELSE t2.ThisWTD END
	FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
	WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
		AND t2.PlainDate = @BusinessDayCurrent


	IF @ShowFullTimeFrameWeek = 1
	BEGIN
		UPDATE #MetricInfo
		SET ThisWeek = CASE t1.Annualize WHEN 1 THEN t2.ThisWTD * 52 ELSE t2.ThisWTD END, 
			FullTimeFrameWeek = 'Y'
		FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
		WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
			AND t2.PlainDate = @LastWeekDate

		UPDATE #MetricInfo
		SET LastWeek = CASE t1.Annualize WHEN 1 THEN t2.ThisWTD * 52 ELSE t2.ThisWTD END
		FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
		WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
			AND t2.PlainDate = DateAdd(ww,-1,@LastWeekDate)	
	
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
			SET @WeekLastHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(day, dateadd(ww,-1,@TempWeekDate))) + '/' + CONVERT(varchar(2), DATEPART(month, dateadd(ww,-1,@TempWeekDate)))
    	END
    	ELSE
    	BEGIN
			SET @WeekLastHeading = 'Week Ending ' + CONVERT(varchar(2), DATEPART(month, dateadd(ww,-1,@TempWeekDate))) + '/' + CONVERT(varchar(2), DATEPART(day, dateadd(ww,-1,@TempWeekDate)))
		END

		--Format Headings
	  	If @WeekHeadingSetting = '1' 
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
		UPDATE #MetricInfo
		SET CurrentWeek = CASE t1.Annualize WHEN 1 THEN t2.ThisWTD * 52 ELSE t2.ThisWTD END, 
			FullTimeFrameWeek = 'N'
		FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
		WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
			AND t2.PlainDate = @BusinessDayCurrent
		
		UPDATE #MetricInfo
		SET ThisWeek = CASE t1.Annualize WHEN 1 THEN t2.ThisWTD * 52 ELSE t2.ThisWTD END
		FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
		WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
			AND t2.PlainDate = @BusinessDayThis

		UPDATE #MetricInfo
		SET LastWeek = CASE t1.Annualize WHEN 1 THEN t2.ThisWTD * 52 ELSE t2.ThisWTD END
		FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
		WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
			AND t2.PlainDate = @LastWeekDate

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
  		If @WeekHeadingSetting = '1' 
    	Begin
			SET @WeekCurrentHeading = 'This Week'
	    	SET @WeekThisHeading = 'This Week'
	    	SET @WeekLastHeading = 'Last Week'
    	End	

		UPDATE #MetricInfo
		SET WeekCurrentHeading = @WeekCurrentHeading,
			WeekLastHeading = @WeekLastHeading,
			WeekThisHeading = @WeekThisHeading,
			WeekCurrentStartDate = dateadd(d,-6,@TempWeekDate),
			WeekLastStartDate = dateadd(d,-6,dateadd(ww,-1,@TempWeekDate)),
			WeekThisStartDate = dateadd(d,-6,@TempWeekDate)
		FROM #MetricInfo t1
	END


	------------------
	--Month
	------------------
	DECLARE @PlainDateToUseForThis datetime, @PlainDateToUseForLast datetime
	IF @ShowFullTimeFrameMonth = 1
	BEGIN
	  	If @MonthHeadingSetting = '1' 
    	Begin
    		IF @Style = 'Alt01'
				SELECT @MonthCurrentHeading = 'This ' + @AltTimeFrameMonth, @MonthThisHeading = 'Last ' + @AltTimeFrameMonth, @MonthLastHeading = '2 ' + @AltTimeFrameMonth + 's Ago'
			ELSE
				SELECT @MonthCurrentHeading = 'This ' + @AltTimeFrameMonth, @MonthThisHeading = 'Last ' + @AltTimeFrameMonth, @MonthLastHeading = '2 ' + @AltTimeFrameMonth + 's Ago'
        End
	    Else
        Begin
            SET @MonthCurrentHeading = CASE WHEN @Style = 'Alt01' THEN 
	    										(SELECT RIGHT('0' + CONVERT(varchar(2), date_AltMonth01), 2) FROM MetricBusinessDays (NOLOCK) WHERE PlainDate = @BusinessDayCurrent)
	    									ELSE LEFT(datename(mm, dateadd(mm, -1, @BusinessDayCurrent)),3) 
	    								END
	    	SELECT @MonthThisHeading = CASE WHEN @Style = 'Alt01' THEN 
	    										(SELECT RIGHT('0' + CONVERT(varchar(2), date_AltMonth01), 2) FROM MetricBusinessDays (NOLOCK) 
	    																WHERE PlainDate = dbo.fnc_Metric_DateAdd(@Style, 'mm',-1, @BusinessDayCurrent) )
	    									ELSE LEFT(datename(mm, dateadd(mm, -1, @BusinessDayCurrent)), 3) 
	    								END
	    	SELECT @MonthLastHeading = CASE WHEN @Style = 'Alt01' THEN 
	    										(SELECT RIGHT('0' + CONVERT(varchar(2), date_AltMonth01), 2) FROM MetricBusinessDays (NOLOCK) 
	    																WHERE PlainDate = dbo.fnc_Metric_DateAdd(@Style, 'mm',-2, @BusinessDayCurrent) )
	    									ELSE LEFT(datename(mm, dateadd(mm, -1, @BusinessDayCurrent)), 3) 
	    								END	    	
    	End	

		SELECT @dt1 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'month', @BusinessDayCurrent),
			@dt2 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'month', dbo.fnc_Metric_DateAdd(@Style, 'mm', -1, @BusinessDayCurrent)),
			@dt3 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'month', dbo.fnc_Metric_DateAdd(@Style, 'mm', -2, @BusinessDayCurrent))
			
		UPDATE #MetricInfo
		SET 
			MonthCurrentHeading = @MonthCurrentHeading,
			MonthThisHeading = @MonthThisHeading,
			MonthLastHeading = @MonthLastHeading,
   			MonthCurrentStartDate = @dt1,
			MonthThisStartDate = @dt2,
			MonthLastStartDate = @dt3

		SELECT @dt1 = dbo.fnc_Metric_DateAdd(@Style, 'mm', 1, @dt1) FROM #MetricInfo 

		UPDATE #MetricInfo
		SET MonthCurrentEndDate = @dt1
			,MonthThisEndDate = MonthCurrentStartDate
			,MonthLastEndDate = MonthThisStartDate

		SELECT @PlainDateToUseForThis = dateadd(day, -1, CONVERT(datetime, CONVERT(varchar(4), datepart(year, @BusinessDayCurrent)) + RIGHT('0' + CONVERT(varchar(2), datepart(month, @BusinessDayCurrent)), 2) + '01'))
				,@PlainDateToUseForLast = cast(convert(char(8),dateadd(day,-1, (
															CONVERT(datetime,
																		CONVERT(varchar(4), datepart(year, dateadd(month, -1, @BusinessDayCurrent)))
																		+ RIGHT('0' + CONVERT(varchar(2), datepart(month, dateadd(month, -1, @BusinessDayCurrent))), 2) 
																		+ '01'))),112) as datetime)

	END
	ELSE
	BEGIN
  		If @MonthHeadingSetting = '1'
    	Begin
    	    IF @Style = 'Alt01'
				SELECT @MonthCurrentHeading = 'This ' + @AltTimeFrameMonth, @MonthThisHeading = 'This ' + @AltTimeFrameMonth, @MonthLastHeading = 'Last ' + @AltTimeFrameMonth
    	    ELSE
				SELECT @MonthCurrentHeading = 'This ' + @AltTimeFrameMonth, @MonthThisHeading = 'This ' + @AltTimeFrameMonth, @MonthLastHeading = 'Last ' + @AltTimeFrameMonth
    	END
		Else
        Begin
            SET @MonthCurrentHeading = LEFT(datename(mm, @BusinessDayThis),3)
	    	SET @MonthThisHeading = LEFT(datename(mm, @BusinessDayThis),3)
	    	SET @MonthLastHeading = LEFT(datename(mm, dateadd(mm,-1,@BusinessDayThis )),3)
	    	
            -- SET @MonthCurrentHeading = LEFT(datename(mm, @BusinessDayCurrent),3)
            SET @MonthCurrentHeading = CASE WHEN @Style = 'Alt01' THEN 
	    										(SELECT RIGHT('0' + CONVERT(varchar(2), date_AltMonth01), 2) FROM MetricBusinessDays (NOLOCK) WHERE PlainDate = @BusinessDayThis)
	    									ELSE LEFT(datename(mm, @BusinessDayThis),3) 
	    								END
	    	-- SET @MonthThisHeading = LEFT(datename(mm, dateadd(mm,-1,@BusinessDayCurrent)),3)
	    	SELECT @MonthThisHeading = CASE WHEN @Style = 'Alt01' THEN 
	    										(SELECT RIGHT('0' + CONVERT(varchar(2), date_AltMonth01), 2) FROM MetricBusinessDays (NOLOCK) WHERE PlainDate = @BusinessDayThis)
	    									ELSE  LEFT(datename(mm, @BusinessDayThis),3)
	    								END
	    	-- SET @MonthLastHeading = LEFT(datename(mm, dateadd(mm,-2,@BusinessDayCurrent)),3)
	    	SELECT @MonthLastHeading = CASE WHEN @Style = 'Alt01' THEN 
	    										(SELECT RIGHT('0' + CONVERT(varchar(2), date_AltMonth01), 2) FROM MetricBusinessDays (NOLOCK) 
	    																WHERE PlainDate = dbo.fnc_Metric_DateAdd(@Style, 'mm',-1, @BusinessDayThis) )
	    									ELSE LEFT(datename(mm, dateadd(mm,-1,@BusinessDayThis )),3)
	    								END	    	    	
        End

		SELECT @dt1 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'month', @BusinessDayThis),
			@dt2 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'month', dbo.fnc_Metric_DateAdd(@Style, 'mm', -1, @BusinessDayThis))

		UPDATE #MetricInfo
		SET MonthCurrentHeading = @MonthCurrentHeading,
			MonthThisHeading = @MonthThisHeading,
			MonthLastHeading = @MonthLastHeading,
   			MonthCurrentStartDate = @dt1,
			MonthThisStartDate = @dt1,
			MonthLastStartDate = @dt2

		SET @dt1 = dbo.fnc_Metric_DateAdd(@Style, 'mm', 1, @dt1)

		UPDATE #MetricInfo
		SET MonthCurrentEndDate = @dt1
			,MonthThisEndDate = @dt1
			,MonthLastEndDate = MonthThisStartDate

	END

	IF @Style = '' OR @Style = 'Normal'
	BEGIN
		SELECT @PlainDateToUseForThis = @BusinessDayThis
				,@PlainDateToUseForLast = cast(convert(
													char(8),
													dateadd(day,-1,	
														CONVERT(datetime,	
															cast(datepart(year,@BusinessDayCurrent) as varchar(4)) + RIGHT('0' + CONVERT(varchar(2), datepart(month, @BusinessDayCurrent)), 2) + '01'
														)
													) 
												,112) as datetime)	

		UPDATE #MetricInfo
		SET FullTimeFrameMonth = CASE WHEN @ShowFullTimeFrameMonth = 1 THEN 'Y' ELSE 'N' END
			,CurrentMonth = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @BusinessDayCurrent, 'Month') * 12 
								ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @BusinessDayCurrent, 'Month') END
			,ThisMonth = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForThis, 'Month') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForThis, 'Month') END
			,LastMonth = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForLast, 'Month') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForLast, 'Month') END
	END
	ELSE
	BEGIN

		-- ********* CALCULATIONS FOR ROLLUPS (new in 2011 - bypasses metricupdatesummaries. ***********
		UPDATE #MetricInfo
		SET FullTimeFrameMonth = CASE WHEN @ShowFullTimeFrameMonth = 1 THEN 'Y' ELSE 'N' END
			,CurrentMonth = CASE t1.Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(t1.TopLevelMetric + @Suffix, @BusinessDayCurrent, 'AltMonth01') * 12 
								ELSE dbo.fnc_get_Metric_xTD_Alternate(t1.TopLevelMetric + @Suffix, @BusinessDayCurrent, 'AltMonth01') END
			,ThisMonth = CASE t1.Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(t1.TopLevelMetric + @Suffix, DATEADD(day, -1, MonthThisEndDate), 'AltMonth01') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(t1.TopLevelMetric + @Suffix, DATEADD(day, -1, MonthThisEndDate), 'AltMonth01') END
			,LastMonth = CASE t1.Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(t1.TopLevelMetric + @Suffix, DATEADD(day, -1, MonthLastEndDate), 'AltMonth01') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(t1.TopLevelMetric + @Suffix, DATEADD(day, -1, MonthLastEndDate), 'AltMonth01') END
		FROM #MetricInfo t1

	END

----------------
--Quarter
----------------
	IF @ShowFullTimeFrameQuarter = 1
	BEGIN
		SELECT @PlainDateToUseForThis = DATEADD(day, -1, dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'Quarter', @BusinessDayCurrent)) -- Get LAST day of last QUARTER or AltQuarter01.
			,@PlainDateToUseForLast = DATEADD(day, -1, dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'Quarter', dbo.fnc_Metric_DateAdd(@Style, 'Quarter', -1, @BusinessDayCurrent)))

		--Format Headings
    	If @QuarterHeadingSetting = '1' 
		Begin
			SET @QuarterCurrentHeading = 'This ' + @AltTimeFrameQuarter
	    	SET @QuarterThisHeading = 'Last ' + @AltTimeFrameQuarter
	    	SET @QuarterLastHeading = '2 ' + @AltTimeFrameQuarter + 's Ago'
		End	
    	Else
        Begin
			SELECT @QuarterCurrentHeading = 'Q' + date_AltQuarter01 + '-' +  date_AltYear01 FROM metricbusinessdays (NOLOCK) WHERE PlainDate = @BusinessDayCurrent
	    	SELECT @QuarterCurrentHeading = 'Q' + date_AltQuarter01 + '-' +  date_AltYear01 FROM metricbusinessdays (NOLOCK) WHERE PlainDate = dbo.fnc_Metric_DateAdd(@Style, 'q',-1, @BusinessDayCurrent)
	    	SELECT @QuarterCurrentHeading = 'Q' + date_AltQuarter01 + '-' +  date_AltYear01 FROM metricbusinessdays (NOLOCK) WHERE PlainDate = dbo.fnc_Metric_DateAdd(@Style, 'q',-2, @BusinessDayCurrent)
        End
        
        SELECT @dt1 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'quarter', @BusinessDayCurrent)
		SELECT @dt2 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'quarter', dbo.fnc_Metric_DateAdd(@Style, 'quarter', -1, @BusinessDayCurrent))
		SELECT @dt3 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'quarter', dbo.fnc_Metric_DateAdd(@Style, 'quarter', -2, @BusinessDayCurrent))
        
		UPDATE #MetricInfo
		SET QuarterCurrentHeading = @QuarterCurrentHeading,
			QuarterThisHeading = @QuarterThisHeading,
			QuarterLastHeading = @QuarterLastHeading,
			QuarterCurrentStartDate = @dt1,
			QuarterThisStartDate = @dt2,
			QuarterLastStartDate = @dt3

		SELECT @dt1 = dbo.fnc_Metric_DateAdd(@Style, 'quarter', 1, @dt1)

		UPDATE #MetricInfo
		SET QuarterCurrentEndDate = @dt1
			,QuarterThisEndDate = QuarterCurrentStartDate
			,QuarterLastEndDate = QuarterThisStartDate
	END
	ELSE
	BEGIN
		SELECT @PlainDateToUseForThis = @BusinessDayThis
			,@PlainDateToUseForLast = DATEADD(day, -1, dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'Quarter', @BusinessDayCurrent)) -- Get LAST day of last QUARTER or AltQuarter01.
	
		--Format Headings
    	If @QuarterHeadingSetting = '1' 
		Begin
			SET @QuarterCurrentHeading = 'This ' + @AltTimeFrameQuarter
	    	SET @QuarterThisHeading = 'This ' + @AltTimeFrameQuarter
	    	SET @QuarterLastHeading = 'Last ' + @AltTimeFrameQuarter
		End	
    	Else
        Begin
            SELECT @QuarterCurrentHeading = 'Q' + date_AltQuarter01 + '-' +  date_AltYear01 FROM metricbusinessdays (NOLOCK) WHERE PlainDate = @BusinessDayCurrent
	    	SELECT @QuarterThisHeading = 'Q' + date_AltQuarter01 + '-' +  date_AltYear01 FROM metricbusinessdays (NOLOCK) WHERE PlainDate = @BusinessDayThis
	    	SELECT @QuarterLastHeading = 'Q' + date_AltQuarter01 + '-' +  date_AltYear01 FROM metricbusinessdays (NOLOCK) WHERE PlainDate = dbo.fnc_Metric_DateAdd(@Style, 'q', -1, @BusinessDayThis)	    	
        End

		SET @dt1 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'quarter', @BusinessDayCurrent)
		SET @dt2 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'quarter', dbo.fnc_Metric_DateAdd(@Style, 'quarter', -1, @BusinessDayCurrent))

		UPDATE #MetricInfo
		SET QuarterCurrentHeading = @QuarterCurrentHeading,
			QuarterThisHeading = @QuarterThisHeading,
			QuarterLastHeading = @QuarterLastHeading,
			QuarterCurrentStartDate = @dt1,
			QuarterThisStartDate = @dt1,
			QuarterLastStartDate = @dt2

		SET @dt1 = dbo.fnc_Metric_DateAdd(@Style, 'quarter', 1, @dt1)

		UPDATE #MetricInfo
		SET QuarterCurrentEndDate = @dt1
			,QuarterThisEndDate = @dt1
			,QuarterLastEndDate = QuarterThisStartDate
			
	END

	IF @Style = '' OR @Style = 'Normal'
	BEGIN
		UPDATE #MetricInfo
		SET FullTimeFrameQuarter = CASE WHEN @ShowFullTimeFrameQuarter = 1 THEN 'Y' ELSE 'N' END
			,CurrentQuarter = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @BusinessDayCurrent, 'Quarter') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @BusinessDayCurrent, 'Quarter') END
			,ThisQuarter = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForThis, 'Quarter') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForThis, 'Quarter') END
			,LastQuarter= CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForLast, 'Quarter') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForLast, 'Quarter') END
	END
	ELSE
	BEGIN
		-- ********* CALCULATIONS FOR ROLLUPS (new in 2011 - bypasses metricupdatesummaries. ***********
		UPDATE #MetricInfo
		SET FullTimeFrameQuarter = CASE WHEN @ShowFullTimeFrameQuarter= 1 THEN 'Y' ELSE 'N' END
			,CurrentQuarter = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @BusinessDayCurrent, 'AltQuarter01') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @BusinessDayCurrent, 'AltQuarter01') END
			,ThisQuarter = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, DATEADD(day, -1, QuarterThisEndDate), 'AltQuarter01') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, DATEADD(day, -1, QuarterThisEndDate), 'AltQuarter01') END
			,LastQuarter = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, DATEADD(day, -1, QuarterLastEndDate), 'AltQuarter01') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, DATEADD(day, -1, QuarterLastEndDate), 'AltQuarter01') END
	END
--SELECT @step = @Step + 1 SELECT @step, GETDATE(), DATEDIFF(ms, @getdate, GETDATE()) , 'Start Year'
	----------------
	--Year
	----------------
	IF @ShowFullTimeFrameYear = 1
	BEGIN
		SELECT @PlainDateToUseForThis = DATEADD(day, -1, dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'Year', @BusinessDayCurrent)) -- Get LAST day of last QUARTER or AltQuarter01.
			,@PlainDateToUseForLast = DATEADD(day, -1, dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'Year', dbo.fnc_Metric_DateAdd(@Style, 'Year', -1, @BusinessDayCurrent)))

		--Format Headings
    	If @YearHeadingSetting = '1' 
		Begin
			SET @YearCurrentHeading = 'This ' + @AltTimeFrameYear
	    	SET @YearThisHeading = 'Last ' + @AltTimeFrameYear
	    	SET @YearLastHeading = '2 ' + @AltTimeFrameYear + 's Ago'
		End	
    	Else
        Begin
			SELECT @YearCurrentHeading = date_AltYear01 FROM metricbusinessdays (NOLOCK) WHERE PlainDate = @BusinessDayCurrent
	    	SELECT @YearThisHeading = date_AltYear01 FROM metricbusinessdays (NOLOCK) WHERE PlainDate = dbo.fnc_Metric_DateAdd(@Style, 'yyyy',-1, @BusinessDayCurrent)
	    	SELECT @YearLastHeading = date_AltYear01 FROM metricbusinessdays (NOLOCK) WHERE PlainDate = dbo.fnc_Metric_DateAdd(@Style, 'yyyy',-2, @BusinessDayCurrent)        
        End

		SELECT @dt1 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'year', @BusinessDayCurrent)
		SELECT @dt2 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'year', dbo.fnc_Metric_DateAdd(@Style, 'year', -1, @BusinessDayCurrent))
		SELECT @dt3 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'year', dbo.fnc_Metric_DateAdd(@Style, 'year', -2, @BusinessDayCurrent))

		UPDATE #MetricInfo
		SET YearCurrentHeading = @YearCurrentHeading,
			YearThisHeading = @YearThisHeading,
			YearLastHeading = @YearLastHeading,
			YearCurrentStartDate = @dt1,
			YearThisStartDate = @dt2,
			YearLastStartDate = @dt3

		SELECT @dt1 = dbo.fnc_Metric_DateAdd(@Style, 'Year', 1, @dt1)

		UPDATE #MetricInfo
		SET YearCurrentEndDate = @dt1
			,YearThisEndDate = YearCurrentStartDate
			,YearLastEndDate = YearThisStartDate
	END
	ELSE
	BEGIN
		SELECT @PlainDateToUseForThis = @BusinessDayThis
			,@PlainDateToUseForLast = DATEADD(day, -1, dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'Year', @BusinessDayCurrent)) -- Get LAST day of last QUARTER or AltQuarter01.
	
		--Format Headings
    	If @YearHeadingSetting = '1' 
		Begin
			SET @YearCurrentHeading = 'This ' + @AltTimeFrameYear
	    	SET @YearThisHeading = 'This ' + @AltTimeFrameYear
	    	SET @YearLastHeading = 'Last ' + @AltTimeFrameYear
		End
    	Else
        Begin
            SELECT @YearCurrentHeading = date_AltYear01 FROM metricbusinessdays (NOLOCK) WHERE PlainDate = @BusinessDayCurrent
	 		SELECT @YearThisHeading = date_AltYear01 FROM metricbusinessdays (NOLOCK) WHERE PlainDate = @BusinessDayThis
	    	SELECT @YearLastHeading = date_AltYear01 FROM metricbusinessdays (NOLOCK) WHERE PlainDate = dbo.fnc_Metric_DateAdd(@Style, 'yyyy', -1, @BusinessDayThis)
        End

		SET @dt1 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'year', @BusinessDayCurrent)
		SET @dt2 = dbo.fnc_Metric_FirstDateOfTimeFrame(@Style, 'year', dbo.fnc_Metric_DateAdd(@Style, 'year', -1, @BusinessDayCurrent))

		UPDATE #MetricInfo
		SET YearCurrentHeading = @YearCurrentHeading,
			YearThisHeading = @YearThisHeading,
			YearLastHeading = @YearLastHeading,
			YearCurrentStartDate = @dt1,
			YearThisStartDate = @dt1,
			YearLastStartDate = @dt2

		SET @dt1 = dbo.fnc_Metric_DateAdd(@Style, 'year', 1, @dt1)

		UPDATE #MetricInfo
		SET YearCurrentEndDate = @dt1
			,YearThisEndDate = @dt1
			,YearLastEndDate = YearThisStartDate
	END


	IF @Style = '' OR @Style = 'Normal'
	BEGIN
		UPDATE #MetricInfo
		SET FullTimeFrameYear = CASE WHEN @ShowFullTimeFrameYear = 1 THEN 'Y' ELSE 'N' END
			,CurrentYear = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @BusinessDayCurrent, 'Year') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @BusinessDayCurrent, 'Year') END
			,ThisYear = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForThis, 'Year') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForThis, 'Year') END
			,LastYear = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForLast, 'Year') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForLast, 'Year') END		
	END
	ELSE
	BEGIN
		UPDATE #MetricInfo
		SET FullTimeFrameYear = CASE WHEN @ShowFullTimeFrameYear = 1 THEN 'Y' ELSE 'N' END
			,CurrentYear = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @BusinessDayCurrent, 'AltYear01') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @BusinessDayCurrent, 'AltYear01') END
			,ThisYear = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForThis, 'AltYear01') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForThis, 'AltYear01') END
			,LastYear = CASE Annualize WHEN 1 THEN dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForLast, 'AltYear01') * 12 
													ELSE dbo.fnc_get_Metric_xTD_Alternate(TopLevelMetric + @Suffix, @PlainDateToUseForLast, 'AltYear01') END
	END
----SELECT @step = @Step + 1 SELECT @step, GETDATE(), DATEDIFF(ms, @getdate, GETDATE()) , 'Start Fiscal Year'	
	----------------
	--Fiscal Year
	----------------
	--Max Fiscal Year
	IF @BusinessDayCurrent  < CAST(@FiscalYearStartDate + '/' + datename(yyyy,@BusinessDayCurrent) as datetime)
		SET @MaxFiscalYearStartDate = dateadd(year,-1,cast(@FiscalYearStartDate + '/' + datename(yyyy,@BusinessDayCurrent) as datetime))
	ELSE
		SET @MaxFiscalYearStartDate = CAST(@FiscalYearStartDate + '/' + datename(yyyy,@BusinessDayCurrent) as datetime)

	IF @ShowFullTimeFrameFiscalYear = 1
	BEGIN
		UPDATE #MetricInfo
		SET CurrentFiscalYear = t2.ThisFiscalYTD,
			FullTimeFrameFiscalYear = 'Y'
		FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
		WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
			AND t2.PlainDate = (@BusinessDayCurrent)

		UPDATE #MetricInfo
		SET ThisFiscalYear = t2.ThisFiscalYTD
		FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
		WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
			AND t2.PlainDate = dateadd(day,-1,@MaxFiscalYearStartDate)

		UPDATE #MetricInfo
		SET LastFiscalYear = t2.ThisFiscalYTD
		FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
		WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
			AND t2.PlainDate = dateadd(day,-1,dateadd(year,-1,@MaxFiscalYearStartDate))

    	If @FiscalYearHeadingSetting = '1' 
		Begin
			UPDATE #MetricInfo
			SET FiscalYearCurrentHeading = 'This Fiscal Year',
				FiscalYearThisHeading = 'Last Fiscal Year',
				FiscalYearLastHeading = '2 Fiscal Years Ago',
				FiscalYearCurrentStartDate = @MaxFiscalYearStartDate,
				FiscalYearThisStartDate = DateAdd(year,-1,@MaxFiscalYearStartDate),
				FiscalYearLastStartDate = DateAdd(year,-2,@MaxFiscalYearStartDate)
			FROM #MetricInfo
		End	
    	Else
        Begin
			IF @FiscalYearEndingYN = 'Y'
			BEGIN
				UPDATE #MetricInfo
				SET FiscalYearCurrentHeading = DatePart(yyyy,DateAdd(day,-1,DateAdd(year,1,@MaxFiscalYearStartDate))),
					FiscalYearThisHeading = DatePart(yyyy,DateAdd(year,-1,DateAdd(day,-1,DateAdd(year,1,@MaxFiscalYearStartDate)))),
					FiscalYearLastHeading = DatePart(yyyy,DateAdd(year,-2,DateAdd(day,-1,DateAdd(year,1,@MaxFiscalYearStartDate)))),
					FiscalYearCurrentStartDate = @MaxFiscalYearStartDate,
					FiscalYearThisStartDate = DateAdd(year,-1,@MaxFiscalYearStartDate),
					FiscalYearLastStartDate = DateAdd(year,-2,@MaxFiscalYearStartDate)
				FROM #MetricInfo

			END
			ELSE
			BEGIN
				UPDATE #MetricInfo
				SET FiscalYearCurrentHeading = DatePart(yyyy,@MaxFiscalYearStartDate),
					FiscalYearThisHeading = DatePart(yyyy,DateAdd(year,-1,@MaxFiscalYearStartDate)),
					FiscalYearLastHeading = DatePart(yyyy,DateAdd(year,-2,@MaxFiscalYearStartDate)),
					FiscalYearCurrentStartDate = @MaxFiscalYearStartDate,
					FiscalYearThisStartDate = DateAdd(year,-1,@MaxFiscalYearStartDate),
					FiscalYearLastStartDate = DateAdd(year,-2,@MaxFiscalYearStartDate)
				FROM #MetricInfo
			END
        End		
	END
	ELSE
	BEGIN
		UPDATE #MetricInfo
		SET CurrentFiscalYear = t2.ThisFiscalYTD,
			FullTimeFrameFiscalYear = 'N'
		FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
		WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
			AND t2.PlainDate = @BusinessDayCurrent

		UPDATE #MetricInfo
		SET ThisFiscalYear = t2.ThisFiscalYTD
		FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
		WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
			AND t2.PlainDate = @BusinessDayCurrent

		UPDATE #MetricInfo
		SET LastFiscalYear = t2.ThisFiscalYTD
		FROM #MetricInfo t1, MetricDetail t2 WITH (NOLOCK)
		WHERE t1.TopLevelMetric + @Suffix = t2.MetricCode
			AND t2.PlainDate = dateadd(day,-1,@MaxFiscalYearStartDate)

    	If @FiscalYearHeadingSetting = '1' 
		Begin
			UPDATE #MetricInfo
			SET FiscalYearCurrentHeading = 'This Fiscal Year',
				FiscalYearThisHeading = 'This Fiscal Year',
				FiscalYearLastHeading = 'Last Fiscal Year',
				FiscalYearCurrentStartDate = @MaxFiscalYearStartDate,
				FiscalYearThisStartDate = @MaxFiscalYearStartDate,
				FiscalYearLastStartDate = DateAdd(year,-1,@MaxFiscalYearStartDate)
			FROM #MetricInfo
		End	
    	Else
        Begin
			IF @FiscalYearEndingYN = 'Y'
			BEGIN
				UPDATE #MetricInfo
				SET FiscalYearCurrentHeading = DatePart(yyyy,DateAdd(day,-1,DateAdd(year,1,@MaxFiscalYearStartDate))),
					FiscalYearThisHeading = DatePart(yyyy,DateAdd(day,-1,DateAdd(year,1,@MaxFiscalYearStartDate))),
					FiscalYearLastHeading = DatePart(yyyy,DateAdd(year,-1,DateAdd(day,-1,DateAdd(year,1,@MaxFiscalYearStartDate)))),
					FiscalYearCurrentStartDate = @MaxFiscalYearStartDate,
					FiscalYearThisStartDate = @MaxFiscalYearStartDate,
					FiscalYearLastStartDate = DateAdd(year,-1,@MaxFiscalYearStartDate)
				FROM #MetricInfo
			END
			ELSE
			BEGIN
				UPDATE #MetricInfo
				SET FiscalYearCurrentHeading = DatePart(yyyy,@MaxFiscalYearStartDate),
					FiscalYearThisHeading = DatePart(yyyy,@MaxFiscalYearStartDate),
					FiscalYearLastHeading = DatePart(yyyy,DateAdd(year,-1,@MaxFiscalYearStartDate)),
					FiscalYearCurrentStartDate = @MaxFiscalYearStartDate,
					FiscalYearThisStartDate = @MaxFiscalYearStartDate,
					FiscalYearLastStartDate = DateAdd(year,-1,@MaxFiscalYearStartDate)
				FROM #MetricInfo
			END
        End
	END
--SELECT @step = @Step + 1 SELECT @step, GETDATE(), DATEDIFF(ms, @getdate, GETDATE()) , 'Final Select'
	--Final Select
	SELECT t1.TopLevelMetric, t1.sort, t1.MetricCode, t1.Caption, t1.CaptionFull, t1.CategoryCode, t1.FormatText, t1.Digs, t1.PlusDeltaIsGood, t1.ItemCaption, t1.ItemCaptionFull, t1.CurrentDay, t1.ThisDay, 
			t1.CurrentWeek, t1.ThisWeek, t1.CurrentMonth, t1.ThisMonth, t1.CurrentQuarter, t1.ThisQuarter, 
			t1.CurrentYear, t1.ThisYear, t1.CurrentFiscalYear, t1.ThisFiscalYear, t1.LastDay, t1.LastWeek, t1.LastMonth, t1.LastQuarter, t1.LastYear, t1.LastFiscalYear, 
			t1.GoalDigs, t1.GoalDay, t1.GoalWeek, t1.GoalMonth, t1.GoalQuarter, t1.GoalYear, t1.GoalFiscalYear, t1.AsOfDate, t1.FullTimeFrameDay, t1.BusinessDayCurrent,
		t1.BusinessDayThis, t1.BusinessDayLast, t1.FullTimeFrameWeek, t1.WeekCurrentHeading, t1.WeekThisHeading, t1.WeekLastHeading, t1.FullTimeFrameMonth, t1.MonthCurrentHeading, 
		-- t1.BusinessDayThis, t1.BusinessDayLast, t1.FullTimeFrameWeek, t1.WeekCurrentHeading, t1.WeekThisHeading, t1.WeekLastHeading, t1.FullTimeFrameMonth, MonthCurrentHeading = 'Great', 		
		t1.MonthThisHeading, t1.MonthLastHeading, t1.FullTimeFrameQuarter, t1.QuarterCurrentHeading, t1.QuarterThisHeading, 
		-- MonthThisHeading = 'This Period', MonthLastHeading = 'Last Period', t1.FullTimeFrameQuarter, t1.QuarterCurrentHeading, t1.QuarterThisHeading, 
		t1.QuarterLastHeading, t1.FullTimeFrameYear, t1.FullTimeFrameFiscalYear, t1.YearCurrentHeading, t1.YearThisHeading, t1.YearLastHeading, t1.FiscalYearCurrentHeading, t1.FiscalYearThisHeading, t1.FiscalYearLastHeading, 
		BusinessDayCurrentDate = dbo.MetricCvtDateToText(t1.BusinessDayCurrentDate), 
		BusinessDayThisDate = dbo.MetricCvtDateToText(t1.BusinessDayThisDate), 
		BusinessDayThisDateEnd = dbo.MetricCvtDateToText(DATEADD(day, 1, t1.BusinessDayThisDate)), 
		BusinessDayLastDate = dbo.MetricCvtDateToText(t1.BusinessDayLastDate), 
		BusinessDayLastDateEnd = dbo.MetricCvtDateToText(DATEADD(day, 1, t1.BusinessDayLastDate)), 
		WeekCurrentStartDate = dbo.MetricCvtDateToText(t1.WeekCurrentStartDate), 
		WeekThisStartDate = dbo.MetricCvtDateToText(t1.WeekThisStartDate), 
		WeekLastStartDate = dbo.MetricCvtDateToText(t1.WeekLastStartDate), 
		MonthCurrentStartDate = dbo.MetricCvtDateToText(t1.MonthCurrentStartDate), 
		MonthThisStartDate = dbo.MetricCvtDateToText(t1.MonthThisStartDate), 
		MonthLastStartDate = dbo.MetricCvtDateToText(t1.MonthLastStartDate), 
		MonthCurrentEndDate = dbo.MetricCvtDateToText(ISNULL(t1.MonthCurrentEndDate, '20501231')), -- The actual end date that runs gets corrected in the web service.
		MonthThisEndDate = dbo.MetricCvtDateToText(ISNULL(t1.MonthThisEndDate, '20501231')), -- The actual end date that runs gets corrected in the web service.
		MonthLastEndDate = dbo.MetricCvtDateToText(ISNULL(t1.MonthLastEndDate, '20501231')), 		-- The actual end date that runs gets corrected in the web service.
		QuarterCurrentStartDate = dbo.MetricCvtDateToText(t1.QuarterCurrentStartDate), 		
		QuarterThisStartDate = dbo.MetricCvtDateToText(t1.QuarterThisStartDate), 
		QuarterLastStartDate = dbo.MetricCvtDateToText(t1.QuarterLastStartDate), 
		QuarterCurrentEndDate = dbo.MetricCvtDateToText(ISNULL(t1.QuarterCurrentEndDate, '20501231')), 		-- The actual end date that runs gets corrected in the web service.
		QuarterThisEndDate = dbo.MetricCvtDateToText(ISNULL(t1.QuarterThisEndDate, '20501231')), -- The actual end date that runs gets corrected in the web service.
		QuarterLastEndDate = dbo.MetricCvtDateToText(ISNULL(t1.QuarterLastEndDate, '20501231')), -- The actual end date that runs gets corrected in the web service.
		YearCurrentStartDate = dbo.MetricCvtDateToText(t1.YearCurrentStartDate), 
		YearThisStartDate = dbo.MetricCvtDateToText(t1.YearThisStartDate), 
		YearLastStartDate = dbo.MetricCvtDateToText(t1.YearLastStartDate), 
		YearCurrentEndDate = dbo.MetricCvtDateToText(ISNULL(t1.YearCurrentEndDate, '20501231')), -- The actual end date that runs gets corrected in the web service.
		YearThisEndDate = dbo.MetricCvtDateToText(ISNULL(t1.YearThisEndDate, '20501231')),  -- The actual end date that runs gets corrected in the web service.
		YearLastEndDate = dbo.MetricCvtDateToText(ISNULL(t1.YearLastEndDate, '20501231')), -- The actual end date that runs gets corrected in the web service.
		FiscalYearCurrentStartDate = dbo.MetricCvtDateToText(t1.FiscalYearCurrentStartDate), 
		FiscalYearThisStartDate = dbo.MetricCvtDateToText(t1.FiscalYearThisStartDate), 
		FiscalYearLastStartDate = dbo.MetricCvtDateToText(t1.FiscalYearLastStartDate), 
		t1.ShowDetailByDefault, t1.Cumulative, t1.Annualize, t1.Active, t1.CurrentLastUpdate, t1.ThisLastUpdate, t1.LastLastUpdate, t1.DetailFilename,
		BadData = t2.BadData -- (SELECT MAX(BadData) FROM metricdetail (READPAST) WHERE  metricCode = t1.metriccode ) -- (SELECT CASE WHEN EXISTS(SELECT sn FROM metricdetail (NOLOCK) WHERE metricCode = #metricInfo.metriccode AND DailyValue IS NULL) THEN 'x' ELSE '' END),
		,t1.DataSourceSN
		,AllowChartDisplay_YN = @AllowChartDisplay_YN
	FROM #MetricInfo t1 INNER JOIN MetricItem t2 ON t1.MetricCode = t2.MetricCode 
		ORDER BY t1.sort

	DROP TABLE #MetricInfo 
GO
GRANT EXECUTE ON  [dbo].[MetricGetCategoryInfo] TO [public]
GO
