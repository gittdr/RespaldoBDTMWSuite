SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CreateAverageFuelPriceFormula] @processDate  DATETIME, 
												   @affFormulaTableId VARCHAR(8)
AS
SET NOCOUNT ON

DECLARE @giString1              VARCHAR(6),
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
        @affInterval            VARCHAR(8),
        @affCycleDay            VARCHAR(8),
        @affFormula             VARCHAR(8),
        @affFormulaAcronym      VARCHAR(12),
        @affEffectiveDay1       SMALLINT,
        @affEffectiveDay2       SMALLINT,
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
        @effectiveDoeDate		TINYINT,
        @tempDateString	        VARCHAR(20), 
        @validDate              INTEGER,
        @tempDay                SMALLINT

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
	   @effectiveDoeDate = aff_effective_doe_date,
	   @giInteger1 = aff_start_day
  FROM avgfuelformulacriteria
 WHERE aff_formula_tableid = @affFormulaTableId

SET @throughDate = DATEADD(YEAR, -1, @processDate)

WHILE @processDate >= @throughDate
BEGIN 
	--Get the current process date and then compute the current week and the previous 4 weeks date ranges
	SET @month = MONTH(@processDate)
	SET @day = DAY(@processDate)
	SET @year = YEAR(@processDate)
	SET @processDate = RTRIM(CAST(@year AS VARCHAR(4))) + '-' + RTRIM(CAST(@month AS VARCHAR(2))) + '-' + RTRIM(CAST(@day AS VARCHAR(2))) + ' 23:59:59'
	SET @dayOfWeek = DATEPART(DW, @processDate)
	IF @dayOfWeek < @giInteger1 
	BEGIN
	   SET @currWeekStart = DATEADD(DAY, (@giInteger1 - @dayOfWeek) - 7, @processDate)
	END
	ELSE
	BEGIN
	   SET @currWeekStart = DATEADD(DAY, (@giInteger1 - @dayOfWeek), @processDate)
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
	
	IF @affInterval = 'WKLY' OR @affInterval = 'BIWKLY'
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
	   IF @cycleDayOfWeek < @giInteger1
	   BEGIN
		  SET @afpNewDate = DATEADD(DAY, (@cycleDayOfWeek - @giInteger1) + 7, @currWeekStart)
	   END
	   ELSE
	   BEGIN
		  SET @afpNewDate = DATEADD(DAY, @cycleDayOfWeek - @giInteger1, @currWeekStart)
	   END

	   --Check to see if an average fuel price for this formula already exists in the averagefuelprice table, if so continue
	   SET @afpNewDescription = LTRIM(RTRIM(@afpDescription))
	   IF EXISTS (SELECT * 
					FROM averagefuelprice
				   WHERE afp_tableid = @affFormulaTableId AND
						 afp_date = @afpNewDate) 
	   BEGIN
		  SET @processDate = DATEADD(DAY, -7, @processDATE)
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
		     SET @processDate = DATEADD(DAY, -7, @processDATE)
			 CONTINUE
		  END
	   END
	   ELSE
	   BEGIN
	      SET @processDate = DATEADD(DAY, -7, @processDATE)
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
		     SET @processDate = DATEADD(DAY, -7, @processDATE)
			 CONTINUE
		  END
	   END
	   ELSE
	   BEGIN
	      SET @processDate = DATEADD(DAY, -7, @processDATE)
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
		     SET @processDate = DATEADD(DAY, -7, @processDATE)
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
			    SET @processDate = DATEADD(DAY, -7, @processDATE)
				CONTINUE
			 END
		  END
		  ELSE
		  BEGIN
		     SET @processDate = DATEADD(DAY, -7, @processDATE)
			 CONTINUE
		  END
	   END
	END
	
	IF @affFormula <> 'PREM'
	BEGIN
		IF @effectiveDoeDate = 1
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
	
		IF @effectiveDoeDate = 2 
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
	
	IF @affInterval <> 'BIWKLY'
	BEGIN
	   SET @processDate = DATEADD(DAY, -7, @processDate)
	END
	ELSE
	BEGIN
	   SET @processDate = DATEADD(DAY, -14, @processDate)
	END
END

GO
GRANT EXECUTE ON  [dbo].[CreateAverageFuelPriceFormula] TO [public]
GO
