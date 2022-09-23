SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_TestProcedure]
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

	SELECT @ThisCount = 1
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
GO
GRANT EXECUTE ON  [dbo].[Metric_TestProcedure] TO [public]
GO
