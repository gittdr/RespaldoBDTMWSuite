SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricUpdateYearWeekInBusinessDays]
AS
	DECLARE @SettingValue int
	Select @SettingValue = settingvalue from MetricGeneralSettings where settingname = 'DateFirst'
	SET DATEFIRST @SettingValue
	

	-- RULE: If January 7th is week 1, then no adjustment. (full week starts the year)  
	--    This is typically once every 5, 6, or 11 years: 1967(6), 1978(11), 1984(6), 1989(5), 1995(6), 2006(11), 2012(6), 2017(5), 2023(6)
	--    Sometimes (every four hundered years) after 7 years: 2204, 2604, 3004, 3404
	-- RULE: If January 7th is NOT week 1, then adjustment: 
	--			All other weeks besides Week 1 are WEEK-1
	--			Week 1 = Last week of last year - (WHEN 1/7/LASTYEAR is week 1, then 0 ELSE 1)
	DECLARE @t1 TABLE (date_year int, LastNewYearsEve datetime, PlainWeek int, PlainYearWeek int)
	
	INSERT INTO @t1 (date_year, LastNewYearsEve)
	SELECT DISTINCT date_year, CONVERT(datetime, CONVERT(varchar(4), date_Year - 1) + '1231') FROM metricbusinessdays ORDER BY date_year
	-- SELECT @LastNewYearsEve = CONVERT(datetime, CONVERT(char(4), DATEPART(year, @DateCur)-1) + '1231')

	UPDATE MetricBusinessDays SET date_Week = RIGHT('0' + CONVERT(varchar(2), 
			CASE WHEN DATEPART(week, CONVERT(datetime, CONVERT(char(4), DATEPART(year, t2.PlainDate)) + '0107')) = 1  -- Why not just look at 1/1 being dw=1?
				THEN DATEPART(week, t2.PlainDate)
				ELSE 
					CASE WHEN DATEPART(week, t2.PlainDate) = 1
						THEN DATEPART(week, t1.LastNewYearsEve) 
						-	CASE WHEN DATEPART(week, CONVERT(datetime, CONVERT(char(4), DATEPART(year, t1.LastNewYearsEve)) + '0107')) = 1
								THEN 0 
							ELSE 1
							END
						ELSE DATEPART(week, t2.PlainDate) - 1
					END
			END), 2)
	FROM @t1 t1 INNER JOIN MetricBusinessDays t2 (NOLOCK) ON t1.date_year = t2.date_Year

	UPDATE MetricBusinessDays SET date_YearWeek =
			CASE WHEN date_Week > 50 AND DATEPART(week, PlainDate) < 10 -- Then this is the first partial week of the year.
							THEN CONVERT(char(4), DATEPART(year, PlainDate)-1) + RIGHT('00' + CONVERT(varchar(2), date_week), 2)
							ELSE CONVERT(char(4), DATEPART(year, PlainDate)) + RIGHT('00' + CONVERT(varchar(2), date_week), 2)
			END

GO
