SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CreateFutureAverageFuelPriceFormulas] @processDate  DATETIME
AS
SET NOCOUNT ON

DECLARE @giString3              INTEGER,
        @giInteger1             INTEGER,
        @formulaCount           INTEGER,
        @minAffId               INTEGER,
        @returnMessage          VARCHAR(255),
        @month                  SMALLINT,
        @day                    SMALLINT,
        @day2                   SMALLINT,
        @year                   INTEGER,
        @affId                  INTEGER,
        @afpTableId             VARCHAR(8),
        @afpDescription         VARCHAR(30),
		@affFormulaTableId		VARCHAR(8),
        @affInterval            VARCHAR(8),
        @affCycleDay            VARCHAR(8),
        @affFormula             VARCHAR(8),
        @affFormulaAcronym      VARCHAR(12),
        @affEffectiveDay1       SMALLINT,
        @affEffectiveDay2       SMALLINT,
		@affEffectiveDoeDate	SMALLINT,
		@affStartDay            SMALLINT,
        @currWeekStart          DATETIME,
        @currWeekEnd            DATETIME,
        @prevWeekStart          DATETIME,
        @prevWeekEnd            DATETIME,
        @prev2WeekStart         DATETIME,
        @prev2WeekEnd           DATETIME,
        @prev3weekStart         DATETIME,
        @prev3WeekEnd           DATETIME,
        @prev4WeekStart         DATETIME,
        @prev4WeekEnd           DATETIME,
        @dayOfWeek              SMALLINT,
        @cycleDayOfWeek         SMALLINT,
        @afpNewDate             DATETIME,
        @afpNewDescription      VARCHAR(30),
        @currWeekPrice          MONEY,
        @prevWeekPrice          MONEY,
        @prev2WeekPrice         MONEY,
        @prev3WeekPrice         MONEY,
        @prev4WeekPrice         MONEY,
        @prevMonthPrice         MONEY,
        @processDay1            SMALLINT,
        @throughDate			DATETIME,
        @tempDateString	        VARCHAR(20), 
        @validDate              INTEGER,
        @tempDay                SMALLINT
		
DECLARE @fuelFormulas TABLE
(
   aff_id                       INTEGER,
   afp_tableid                  VARCHAR(8),
   afp_description              VARCHAR(30),
   aff_formula_tableid          VARCHAR(8),
   aff_interval                 VARCHAR(8),
   aff_cycleday                 VARCHAR(8),
   aff_formula                  VARCHAR(8),
   aff_formula_acronym          VARCHAR(12),
   aff_effective_day1           SMALLINT,
   aff_effective_day2           SMALLINT,
   aff_effective_doe_date       SMALLINT,
   aff_start_day                SMALLINT
)

SELECT @giString3 = ISNULL(CAST(gi_string3 AS SMALLINT), 0),
       @giInteger1 = ISNULL(gi_integer1, 2)
  FROM generalinfo
 WHERE gi_name = 'EnableAvgFuelFormulaCalc'
 
INSERT INTO @fuelFormulas
	SELECT aff_id,
		   afp_tableid,
		   afp_description,
		   aff_formula_tableid,
		   aff_interval,
		   aff_cycleday,
		   aff_formula,
		   aff_formula_acronym,
		   aff_effective_day1,
		   aff_effective_day2,
		   aff_effective_doe_date,
		   aff_start_day
	  FROM avgfuelformulacriteria
	ORDER BY aff_id

SELECT @formulaCount = COUNT(*)
  FROM @fuelFormulas

IF @formulaCount > 0 
BEGIN
	UPDATE @fuelFormulas
	   SET aff_effective_doe_date = @giString3
	 WHERE aff_effective_doe_date IS NULL
	
	UPDATE @fuelFormulas
	   SET aff_start_day = @giInteger1
	 WHERE aff_start_day IS NULL
	
	SET @minAffId = 0
	WHILE 1=1
	BEGIN
		SELECT @minAffId = MIN(aff_id)
		  FROM @fuelFormulas
		 WHERE aff_id > @minAffId

		IF @minAffId IS NULL
			BREAK
			
		--Get the average fuel formula
		SELECT @affId = aff_id,
			   @afpTableId = afp_tableid,
			   @afpDescription = afp_description,
			   @affFormulaTableId = aff_formula_tableid,
			   @affInterval = aff_interval,
			   @affCycleDay = aff_cycleday,
			   @affFormula = aff_formula,
			   @affFormulaAcronym = aff_formula_acronym,
			   @affEffectiveDay1 = aff_effective_day1,
			   @affEffectiveDay2 = aff_effective_day2,
			   @affEffectiveDoeDate = aff_effective_doe_date,
			   @affStartDay = aff_start_day
		  FROM @fuelFormulas
		 WHERE aff_id = @minAffId

		--Get the current process date and then compute the current week and the previous 4 weeks date ranges
		SET @month = MONTH(@processDate)
		SET @day = DAY(@processDate)
		SET @year = YEAR(@processDate)
		SET @processDate = RTRIM(CAST(@year AS VARCHAR(4))) + '-' + RTRIM(CAST(@month AS VARCHAR(2))) + '-' + RTRIM(CAST(@day AS VARCHAR(2))) + ' 23:59:59'
		SET @dayOfWeek = DATEPART(DW, @processDate)
		IF @dayOfWeek < @affStartDay 
		BEGIN
			SET @currWeekStart = DATEADD(DAY, (@affStartDay - @dayOfWeek) - 7, @processDate)
		END
		ELSE
		BEGIN
			SET @currWeekStart = DATEADD(DAY, (@affStartDay - @dayOfWeek), @processDate)
		END
		SET @month = MONTH(@currWeekStart)
		SET @day = DAY(@currWeekStart)
		SET @year = YEAR(@currWeekStart)
		SET @currWeekStart = RTRIM(CAST(@year AS VARCHAR(4))) + '-' + RTRIM(CAST(@month AS VARCHAR(2))) + '-' + RTRIM(CAST(@day AS VARCHAR(2))) + ' 00:00:00'
		SET @currWeekEnd = DATEADD(DAY, 6, @currWeekStart)
		SET @month = MONTH(@currWeekEnd)
		SET @day = DAY(@currWeekEnd)
		SET @year = YEAR(@currWeekEnd)
		SET @currWeekEnd = RTRIM(CAST(@year AS VARCHAR(4))) + '-' + RTRIM(CAST(@month AS VARCHAR(2))) + '-' + RTRIM(CAST(@day AS VARCHAR(2))) + ' 23:59:59'
		SET @prevWeekStart = DATEADD(DAY, -7, @currWeekStart)
		SET @prevWeekEnd = DATEADD(DAY, -7, @currWeekEnd)
		SET @prev2WeekStart = DATEADD(DAY, -14, @currWeekStart)
		SET @prev2WeekEnd = DATEADD(DAY, -14, @currWeekEnd)
		SET @prev3WeekStart = DATEADD(DAY, -21, @currWeekStart)
		SET @prev3WeekEnd = DATEADD(DAY, -21, @currWeekEnd)
		SET @prev4WeekStart = DATEADD(DAY, -28, @currWeekStart)
		SET @prev4WeekEnd = DATEADD(DAY, -28, @currWeekEnd)
	
		IF @affInterval = 'WKLY'
		BEGIN
			--Figure out the current week weekday to use based on the aff_cycleday
			SET @cycleDayOfWeek =
				CASE
					WHEN @affCycleDay = 'SUN' THEN 1
					WHEN @affCycleDay = 'MON' THEN 2
					WHEN @affCycleDay = 'TUE' THEN 3
					WHEN @affCycleDay = 'WED' THEN 4
					WHEN @affCycleDay = 'THUR' THEN 5
					WHEN @affCycleDay = 'FRI' THEN 6
					WHEN @affCycleDay = 'SAT' THEN 7
				END 
			IF @cycleDayOfWeek < @affStartDay
			BEGIN
				SET @afpNewDate = DATEADD(DAY, (@cycleDayOfWeek - @affStartDay) + 7, @currWeekStart)
			END
			ELSE
			BEGIN
				SET @afpNewDate = DATEADD(DAY, @cycleDayOfWeek - @affStartDay, @currWeekStart)
			END

			--Check to see if an average fuel price for this formula already exists in the averagefuelprice table, if so continue
			SET @afpNewDescription = LTRIM(RTRIM(@afpDescription))
			IF EXISTS (SELECT * 
						 FROM averagefuelprice
						WHERE afp_tableid = @affFormulaTableId AND
							  afp_date = @afpNewDate) 
			BEGIN
				CONTINUE
			END
		END
		
		IF @affInterval = 'BIWKLY'
		BEGIN
			--Figure out the current week weekday to use based on the aff_cycleday
			SET @cycleDayOfWeek =
				CASE
					WHEN @affCycleDay = 'SUN' THEN 1
					WHEN @affCycleDay = 'MON' THEN 2
					WHEN @affCycleDay = 'TUE' THEN 3
					WHEN @affCycleDay = 'WED' THEN 4
					WHEN @affCycleDay = 'THUR' THEN 5
					WHEN @affCycleDay = 'FRI' THEN 6
					WHEN @affCycleDay = 'SAT' THEN 7
				END 
			IF @cycleDayOfWeek < @affStartDay
			BEGIN
				SET @afpNewDate = DATEADD(DAY, (@cycleDayOfWeek - @affStartDay) + 7, @currWeekStart)
			END
			ELSE
			BEGIN
				SET @afpNewDate = DATEADD(DAY, @cycleDayOfWeek - @affStartDay, @currWeekStart)
			END
			--Check to see if an average fuel price for this formula already exists in the averagefuelprice table, if so continue
			SET @afpNewDescription = LTRIM(RTRIM(@afpDescription))
			IF EXISTS (SELECT * 
						 FROM averagefuelprice
						WHERE afp_tableid = @affFormulaTableId AND
							  (afp_date = @afpNewDate OR afp_date = DATEADD(DAY, -7, @afpNewDate)))
			BEGIN
				CONTINUE
			END
		END

		IF @affInterval = 'MNTH' AND @affFormula <> 'PREMN'
		BEGIN
			--Figure out if the effective day1 falls within the current weekday
			SET @tempDateString = RTRIM(CAST(YEAR(@currWeekStart) AS VARCHAR(4))) + '-' + RTRIM(CAST(MONTH(@currWeekStart) AS VARCHAR(2))) + '-' + RTRIM(CAST(@affEffectiveDay1 AS VARCHAR(2))) + ' 00:00:00'
			SET @tempDay = @affEffectiveDay1
			SET @validDate = 0
			WHILE @validDate = 0
			BEGIN
				SET @validDate = ISDATE(@tempDateString)
				IF @validDate = 0
				BEGIN
					SET @tempDay = @tempDay - 1
					SET @tempDateString = RTRIM(CAST(YEAR(@currWeekStart) AS VARCHAR(4))) + '-' + RTRIM(CAST(MONTH(@currWeekStart) AS VARCHAR(2))) + '-' + RTRIM(CAST(@tempDay AS VARCHAR(2))) + ' 00:00:00'
				END
			END
			SET @afpNewDate = @tempDateString
			IF @afpNewDate >= @currWeekStart AND @afpNewDate <= @currWeekEnd
			BEGIN
				SET @afpNewDescription = LTRIM(RTRIM(@afpDescription))
				IF EXISTS (SELECT *
							 FROM averagefuelprice
							WHERE afp_tableid = @affFormulaTableId AND
								  afp_date = @afpNewDate)
				BEGIN
					CONTINUE
				END
			END
			ELSE
			BEGIN
				CONTINUE
			END
		END
		
		IF @affInterval = 'MNTH' AND @affFormula = 'PREMN'
		BEGIN
			SET @afpNewDate = RTRIM(CAST(YEAR(@currWeekEnd) AS VARCHAR(4))) + '-' + RTRIM(CAST(MONTH(@currWeekEnd) AS VARCHAR(2))) + '-' + RTRIM(CAST(@affEffectiveDay1 AS VARCHAR(2))) + ' 00:00:00'
			IF @afpNewDate >= @currWeekStart AND @afpNewDate <= @currWeekEnd
			BEGIN
				SET @afpNewDescription = LTRIM(RTRIM(@afpDescription))
				IF EXISTS (SELECT *
							 FROM averagefuelprice
							WHERE afp_tableid = @affFormulaTableId AND
								  afp_date = @afpNewDate)
				BEGIN
					CONTINUE
				END
			END
			ELSE
			BEGIN
				CONTINUE
			END
		END

		IF @affInterval = 'BIMNTH'
		BEGIN
			SET @tempDateString = RTRIM(CAST(YEAR(@currWeekStart) AS VARCHAR(4))) + '-' + RTRIM(CAST(MONTH(@currWeekStart) AS VARCHAR(2))) + '-' + RTRIM(CAST(@affEffectiveDay1 AS VARCHAR(2))) + ' 00:00:00'
			SET @validDate = 0
			SET @tempDay = @affEffectiveDay1
			WHILE @validDate = 0
			BEGIN
				SET @validDate = ISDATE(@tempDateString)
				IF @validDate = 0
				BEGIN
					SET @tempDay = @tempDay - 1
					SET @tempDateString = RTRIM(CAST(YEAR(@currWeekStart) AS VARCHAR(4))) + '-' + RTRIM(CAST(MONTH(@currWeekStart) AS VARCHAR(2))) + '-' + RTRIM(CAST(@tempDay AS VARCHAR(2))) + ' 00:00:00'
				END
			END
			SET @afpNewDate = @tempDateString
			SET @processDay1 = 0
			IF @afpNewDate >= @currWeekStart AND @afpNewDate <= @currWeekEnd
			BEGIN
				SET @afpNewDescription = LTRIM(RTRIM(@afpDescription))
				IF EXISTS (SELECT *
							 FROM averagefuelprice
							WHERE afp_tableid = @affFormulaTableId AND
								  afp_date = @afpNewDate)
				BEGIN
					CONTINUE
				END
				SET @processDay1 = 1
			END
					  
			IF @processDay1 = 0
			BEGIN
				SET @tempDateString = RTRIM(CAST(YEAR(@currWeekStart) AS VARCHAR(4))) + '-' + RTRIM(CAST(MONTH(@currWeekStart) AS VARCHAR(2))) + '-' + RTRIM(CAST(@affEffectiveDay2 AS VARCHAR(2))) + ' 00:00:00'
				SET @tempDay = @affEffectiveDay2
				SET @validDate = 0
				WHILE @validDate = 0
				BEGIN
					SET @validDate = ISDATE(@tempDateString)
					IF @validDate = 0
					BEGIN
						SET @tempDay = @tempDay - 1
						SET @tempDateString = RTRIM(CAST(YEAR(@currWeekStart) AS VARCHAR(4))) + '-' + RTRIM(CAST(MONTH(@currWeekStart) AS VARCHAR(2))) + '-' + RTRIM(CAST(@tempDay AS VARCHAR(2))) + ' 00:00:00'
					END
				END
				SET @afpNewDate = @tempDateString
				IF @afpNewDate >= @currWeekStart AND @afpNewDate <= @currWeekEnd
				BEGIN
					SET @afpNewDescription = LTRIM(RTRIM(@afpDescription))
					IF EXISTS (SELECT *
								 FROM averagefuelprice
								WHERE afp_tableid = @affFormulaTableId AND
									  afp_date = @afpNewDate)
					BEGIN
						CONTINUE
					END
				END
				ELSE
				BEGIN
					CONTINUE
				END
			END
		END
	
		IF @affFormula <> 'PREMN'
		BEGIN
			IF @affEffectiveDoeDate = 1
			BEGIN
				SET @currWeekStart = DATEADD(DAY, -7, @currWeekStart)
				SET @currWeekEnd = DATEADD(DAY, -7, @currWeekEnd)
				SET @prevWeekStart = DATEADD(DAY, -7, @prevWeekStart)
				SET @prevWeekEnd = DATEADD(DAY, -7, @prevWeekEnd)
				SET @prev2WeekStart = DATEADD(DAY, -7, @prev2WeekStart)
				SET @prev2WeekEnd = DATEADD(DAY, -7, @prev2WeekEnd)
				SET @prev3WeekStart = DATEADD(DAY, -7, @prev3weekStart)
				SET @prev3WeekEnd = DATEADD(DAY, -7, @prev3WeekEnd)
				SET @prev4WeekStart = DATEADD(DAY, -7, @prev4WeekStart)
				SET @prev4WeekEnd = DATEADD(DAY, -7, @prev4WeekEnd)
			END
	
			IF @affEffectiveDoeDate = 2 
			BEGIN
				SET @currWeekStart = DATEADD(DAY, -14, @currWeekStart)
				SET @currWeekEnd = DATEADD(DAY, -14, @currWeekEnd)
				SET @prevWeekStart = DATEADD(DAY, -14, @prevWeekStart)
				SET @prevWeekEnd = DATEADD(DAY, -14, @prevWeekEnd)
				SET @prev2WeekStart = DATEADD(DAY, -14, @prev2WeekStart)
				SET @prev2WeekEnd = DATEADD(DAY, -14, @prev2WeekEnd)
				SET @prev3WeekStart = DATEADD(DAY, -14, @prev3WeekStart)
				SET @prev3WeekEnd = DATEADD(DAY, -14, @prev3WeekEnd)
				SET @prev4WeekStart = DATEADD(DAY, -14, @prev4WeekStart)
				SET @prev4WeekEnd = DATEADD(DAY, -14, @prev4WeekEnd)
			END
		END

		--If the averagefuelprice does not exist for the current week and this formula, figure out the new price
		--based on the formula
		IF @affFormula = 'CURWK'
		BEGIN
			SET @currWeekPrice = 0
			SELECT @currWeekPrice = afp_price
			  FROM averagefuelprice
			 WHERE afp_tableid = @afpTableId AND
				   afp_isformula = 0 AND
				   afp_date between @currWeekStart and @currWeekEnd
			IF @currWeekPrice > 0
			BEGIN
				INSERT INTO averagefuelprice (afp_tableid, afp_date, afp_description, afp_price, afp_isformula)
								VALUES (@affFormulaTableId, @afpNewDate, @afpNewDescription, @currWeekPrice, 1)
			END
		END

		IF @affFormula = 'PREWK'
		BEGIN
			SET @prevWeekPrice = 0
			SELECT @prevWeekPrice = afp_price 
			  FROM averagefuelprice
			 WHERE afp_tableid = @afpTableId AND
				   afp_isformula = 0 AND 
				   afp_date BETWEEN @prevWeekStart AND @prevWeekEnd
			IF @prevWeekPrice > 0
			BEGIN
				INSERT INTO averagefuelprice (afp_tableid, afp_date, afp_description, afp_price, afp_isformula)
								VALUES (@affFormulaTableId, @afpNewDate, @afpNewDescription, @prevWeekPrice, 1)
			END
		END

		IF @affFormula = 'AVG2WK'
		BEGIN
			SET @prevWeekPrice = 0
			SELECT @prevWeekPrice = afp_price 
			  FROM averagefuelprice
			 WHERE afp_tableid = @afpTableId AND
				   afp_isformula = 0 AND 
				   afp_date BETWEEN @prevWeekStart AND @prevWeekEnd
			SET @prev2WeekPrice = 0
			SELECT @prev2WeekPrice = afp_price
			  FROM averagefuelprice
			 WHERE afp_tableid = @afpTableId AND
				   afp_isformula = 0 AND
				   afp_date BETWEEN @prev2WeekStart AND @prev2WeekEnd
			IF @prevWeekPrice > 0 AND @prev2WeekPrice > 0
			BEGIN
				INSERT INTO averagefuelprice (afp_tableid, afp_date, afp_description, afp_price, afp_isformula)
								VALUES (@affFormulaTableId, @afpNewDate, @afpNewDescription, ((@prevWeekPrice + @prev2WeekPrice)/2), 1)
			END
		END

		IF @affFormula = 'AVG4WK'
		BEGIN
			SET @prevWeekPrice = 0
			SELECT @prevWeekPrice = afp_price 
			  FROM averagefuelprice
			 WHERE afp_tableid = @afpTableId AND
				   afp_isformula = 0 AND 
				   afp_date BETWEEN @prevWeekStart AND @prevWeekEnd
			SET @prev2WeekPrice = 0
			SELECT @prev2WeekPrice = afp_price
			  FROM averagefuelprice
			 WHERE afp_tableid = @afpTableId AND
				   afp_isformula = 0 AND
				   afp_date BETWEEN @prev2WeekStart AND @prev2WeekEnd
			SET @prev3WeekPrice = 0
			SELECT @prev3WeekPrice = afp_price
			  FROM averagefuelprice
			 WHERE afp_tableid = @afpTableId AND
				   afp_isformula = 0 AND
				   afp_date BETWEEN @prev3WeekStart AND @prev3WeekEnd
			SET @prev4WeekPrice = 0
			SELECT @prev4WeekPrice = afp_price
			  FROM averagefuelprice
			 WHERE afp_tableid = @afpTableId AND
				   afp_isformula = 0 AND
				   afp_date BETWEEN @prev4WeekStart AND @prev4WeekEnd
			IF @prevWeekPrice > 0 AND @prev2WeekPrice > 0 AND @prev3WeekPrice > 0 AND @prev4WeekPrice > 0
			BEGIN
				INSERT INTO averagefuelprice (afp_tableid, afp_date, afp_description, afp_price, afp_isformula)
								VALUES (@affFormulaTableId, @afpNewDate, @afpNewDescription, ((@prevWeekPrice + @prev2WeekPrice + @prev3WeekPrice + @prev4WeekPrice)/4), 1)
			END
		END

		IF @affFormula = 'PREMN' AND @affInterval = 'MNTH'
		BEGIN
			SET @month = MONTH(@afpNewDate)
			IF @month = 1
			BEGIN 
				SET @month = 12
				SET @year = YEAR(@currWeekStart) - 1
			END
			ELSE
			BEGIN
				SET @month = @month - 1
				SET @year = YEAR(@currWeekStart)
			END
			SET @currWeekPrice = 0 
			SELECT @currWeekPrice = afp_price
			  FROM averagefuelprice
			 WHERE afp_tableid = @afpTableId AND
			       afp_isformula = 0 AND
				   afp_date BETWEEN @currWeekStart AND @currWeekEnd
			SET @prevMonthPrice = 0
			SELECT @prevMonthPrice = AVG(afp_price)
			  FROM averagefuelprice 
			 WHERE afp_tableid = @afpTableId AND
				   afp_isformula = 0 AND
				   MONTH(afp_date) = @month AND
				   YEAR(afp_date) = @year
			IF @currWeekPrice > 0 AND @prevMonthPrice > 0
			BEGIN
				INSERT INTO averagefuelprice (afp_tableid, afp_date, afp_description, afp_price, afp_isformula)
								VALUES (@affFormulaTableId, @afpNewDate, @afpNewDescription, @prevMonthPrice, 1)
			END
		END
	END
END

GO
GRANT EXECUTE ON  [dbo].[CreateFutureAverageFuelPriceFormulas] TO [public]
GO
