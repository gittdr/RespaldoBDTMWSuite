SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricGetMetricsForAdmin] (
	@ActiveStatus int,  
		--	 Active  Inactive   ActiveStatus
		--     0        0           0		NONE
		--     0        1			1		Inactive-Only	
		--     1        0			2		ActiveOnly
		--	   1		1			3		BOTH
	@ProcedureName varchar(255) = '',
	@MetricFilter varchar(100) = '%',
	@CategoryCode varchar(100) = ''
)
AS
	SET NOCOUNT ON

	IF ISNULL(@MetricFilter, '%') = '' SELECT @MetricFilter = '%'

	IF (@ActiveStatus = 0) 
	BEGIN
		RETURN  -- Nothing to return.  Why bother calling the stored procedure.
	END

SET ROWCOUNT 2000
	SELECT DISTINCT t1.sn, t1.metriccode, t1.active, t1.Caption, t1.CaptionFull, t1.procedurename
	FROM metricitem t1 (NOLOCK)  LEFT JOIN metriccategoryitems  t2 (NOLOCK)ON t1.metriccode = t2.metriccode
	WHERE t1.active = 
			CASE WHEN @ActiveStatus = 1 THEN 1 
				 WHEN @ActiveStatus = 2 THEN 0
			ELSE t1.active -- @ActiveStatus = 3 THEN 
			END
		AND ProcedureName = CASE WHEN ISNULL(@ProcedureName, '') = '' THEN ProcedureName ELSE ISNULL(@ProcedureName, '') END
		AND	(t1.MetricCode LIKE @MetricFilter OR t1.Caption LIKE @MetricFilter)
		AND	t2.CategoryCode = CASE WHEN ISNULL(@CategoryCode, '') = '' THEN t2.CategoryCode ELSE ISNULL(@CategoryCode, '') END
	ORDER BY t1.caption

SET ROWCOUNT 0
GO
GRANT EXECUTE ON  [dbo].[MetricGetMetricsForAdmin] TO [public]
GO
