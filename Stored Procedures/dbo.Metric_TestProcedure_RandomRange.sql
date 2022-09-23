SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Metric_TestProcedure_RandomRange]
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	@UpperBound_DailyValue float = .73,
	@LowerBound_DailyValue float = .55,
	@UpperBound_Denominator float = 270,
	@LowerBound_Denominator float = 350,
	@ProbabilityOfZeroNumerator float = .10,  -- 10% chance.
	@ProbabilityOfZeroDenominator float = .10  -- 10% chance.
AS
/* For example: Typical "cost per mile" between .55 and .73
	@UpperBound_DailyValue = .73
	@LowerBound_DailyValue = .55

	But the average miles, the denominator, in one day is 300.
*/

	SET NOCOUNT ON
	DECLARE @t table (sort int, textout varchar(1000))

	DECLARE @DailyValue float

	-- DECLARE	@UpperBound_DailyValue float, @LowerBound_DailyValue float, @UpperBound_Denominator float, @LowerBound_Denominator float
	-- SELECT 	@UpperBound_DailyValue = .73, @LowerBound_DailyValue = .55, @UpperBound_Denominator = 270, @LowerBound_Denominator = 300
	-- SELECT @DailyValue = @LowerBound_DailyValue + (@UpperBound_DailyValue - @LowerBound_DailyValue) * RAND()
	-- SELECT @DailyValue
	-- SELECT @ThisTotal = @LowerBound_Denominator + (@UpperBound_Denominator - @LowerBound_Denominator) * RAND()
	-- SELECT @ThisTotal
	-- SELECT ThisCount = @ThisTotal * @DailyValue


	SELECT @DailyValue = @LowerBound_DailyValue + (@UpperBound_DailyValue - @LowerBound_DailyValue) * RAND()
	SELECT @ThisTotal = @LowerBound_Denominator + (@UpperBound_Denominator - @LowerBound_Denominator) * RAND()
	SELECT @ThisCount = @ThisTotal * @DailyValue

	--select @Result, @DailyValue, @ThisTotal, @ThisCount, RAND()	

	IF (RAND() < @ProbabilityOfZeroNumerator) SELECT @ThisCount = 0
	IF (RAND() < @ProbabilityOfZeroDenominator) SELECT @ThisTotal = 0

	--Standard Result Calculation
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 

	-- select @Result, @DailyValue, @ThisTotal, @ThisCount, RAND()	
	IF @ShowDetail = 1
	BEGIN
		INSERT INTO @t (sort, textout) SELECT 1, 'Information for ' + CONVERT(varchar(40), @DateStart) + ' (the first day in this time frame):'
		INSERT INTO @t (sort, textout) SELECT 2, '- This day is a ' + DATENAME(dw, @DateStart) + '.'
		INSERT INTO @t (sort, textout) SELECT 3, '- Day # ' + DATENAME(dayofyear, @DateStart) + ' of the year.'
		INSERT INTO @t (sort, textout) SELECT 4, '- Part of week # ' + DATENAME(wk, @DateStart) + '.'

		SELECT textout AS 'Information' FROM @t ORDER BY sort	
		
	END

	SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[Metric_TestProcedure_RandomRange] TO [public]
GO
