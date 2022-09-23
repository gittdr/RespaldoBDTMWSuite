SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricGetProceduresForAdmin] (
	@ActiveStatus int
		--	 Active  Inactive   ActiveStatus
		--     0        0           0		NONE
		--     0        1			1		Inactive-Only	
		--     1        0			2		ActiveOnly
		--	   1		1			3		BOTH
)
AS
	SET NOCOUNT ON

	-- MetricGetProceduresForAdmin 2
	IF (@ActiveStatus = 0) 
	BEGIN
		RETURN  -- Nothing to return.  Why bother calling the stored procedure.
	END

	SELECT DISTINCT t1.procedurename
	FROM metricitem t1 (NOLOCK)  
	WHERE t1.active = 
			CASE WHEN @ActiveStatus = 1 THEN 1 
				 WHEN @ActiveStatus = 2 THEN 0
			ELSE t1.active
			END
	ORDER BY t1.procedurename

GO
GRANT EXECUTE ON  [dbo].[MetricGetProceduresForAdmin] TO [public]
GO
