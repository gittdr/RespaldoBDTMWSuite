SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetCategoriesForAdmin] (
	@ActiveStatus int
		--	 Active  Inactive   ActiveStatus
		--     0        0           0		NONE
		--     0        1			1		Inactive-Only	
		--     1        0			2		ActiveOnly
		--	   1		1			3		BOTH
)
AS
	SET NOCOUNT ON

	IF (@ActiveStatus = 0) 
	BEGIN
		RETURN  -- Nothing to return.  Why bother calling the stored procedure.
	END

	SELECT DISTINCT t3.CategoryCode, t3.Caption
	FROM metricitem t1 (NOLOCK)  LEFT JOIN metriccategoryitems t2 (NOLOCK) ON t1.metriccode = t2.metriccode
		INNER JOIN metriccategory t3  (NOLOCK) ON t2.categoryCode = t3.categoryCode
	WHERE t1.active = 
			CASE WHEN @ActiveStatus = 1 THEN 1 
				 WHEN @ActiveStatus = 2 THEN 0
			ELSE t1.active -- @ActiveStatus = 3 THEN 
			END
	ORDER BY t3.Caption
GO
GRANT EXECUTE ON  [dbo].[MetricGetCategoriesForAdmin] TO [public]
GO
