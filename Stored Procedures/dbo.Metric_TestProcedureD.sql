SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_TestProcedureD]
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int
AS
	SET NOCOUNT ON

	DECLARE @t table (sort int, textout varchar(1000))

	SELECT @ThisCount = (5 
							+ (CASE WHEN DATEPART(day, @DateStart) % 2 = 0 THEN 1 ELSE -1 END)  -- This line just makes it alternate between negative and positive.
							* (DATEPART(day, @DateStart) % 5)
							)
	SELECT @ThisTotal = 1
			
	--Standard Result Calculation
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 
	
	IF @ShowDetail = 1
	BEGIN
		INSERT INTO @t (sort, textout) SELECT 1, 'Information for ' + CONVERT(varchar(40), @DateStart) + ' (the first day in this time frame):'
		INSERT INTO @t (sort, textout) SELECT 2, '- This day is a ' + DATENAME(dw, @DateStart) + '.'
		INSERT INTO @t (sort, textout) SELECT 3, '- Day # ' + DATENAME(dayofyear, @DateStart) + ' of the year.'
		INSERT INTO @t (sort, textout) SELECT 4, '- Part of week # ' + DATENAME(wk, @DateStart) + '.'

		SELECT textout AS 'Information' FROM @t ORDER BY sort	
		
	END

	SET NOCOUNT OFF

	/*
	SET NOCOUNT on
	DECLARE @i int
	DECLARE @x table (idx int, val int)
	set @i = 1
	WHILE @i < 31
	BEGIN
		--SELECT  @i, 1 * (5 + (-1 * (@i % 2)) 
		--					* (@i % 5))
		INSERT INTO @x (idx, val) SELECT @i, 1 * (5 + (CASE WHEN @i % 2 = 0 THEN 1 ELSE -1 END) * (@i % 5))
		SET @i = @i + 1
	END
	SELECT val, count(*) from @x GROUP BY val
	*/
GO
GRANT EXECUTE ON  [dbo].[Metric_TestProcedureD] TO [public]
GO
