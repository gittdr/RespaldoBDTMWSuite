SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[Metric_BackBooking]
	(
	--Standard Parameters
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int
	
	--Additional/Optional Parameters

	)

AS

	SET NOCOUNT ON

	--Standard Initialization for all List Parameters


	--CREATE #ResultsTable 
	SELECT 
		Ord_hdrnumber as OrderNumber
		,ord_bookedby as BookingAssociate
		,ord_bookdate as BookingDate
		,ord_startdate as StartDate
	INTO #ResultsTable
	FROM orderheader (NOLOCK)
	WHERE	ord_bookdate between @DateStart AND @DateEnd
		AND ord_bookdate > ord_startdate
	ORDER BY ord_hdrnumber

	--SQL Calculation of the Numerator (@ThisCount) and the Denominator (@ThisTotal)
	Select @ThisCount = Count(*)
	From #ResultsTable

	Select @ThisTotal = Count(*)
	From orderheader (NOLOCK)
	WHERE ord_bookdate between @DateStart AND @DateEnd

	--Standard Final Result
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 

	--Detail (For returning detail for the ResultsNow detail request)
	IF @ShowDetail =1   --All
	BEGIN
		SELECT * From #ResultsTable (nolock)
		ORDER BY ordernumber
	END

GO
GRANT EXECUTE ON  [dbo].[Metric_BackBooking] TO [public]
GO
