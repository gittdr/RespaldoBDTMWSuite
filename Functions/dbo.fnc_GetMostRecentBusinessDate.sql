SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fnc_GetMostRecentBusinessDate] (@StartingDate datetime, @Offset int)
RETURNS datetime
AS
BEGIN
/*
SELECT dbo.fnc_GetMostRecentBusinessDate('3/8/2010', -1)
SELECT dbo.fnc_GetMostRecentBusinessDate('3/7/2010', 0)
*/
	DECLARE @BusinessDayValue int
	
	SET @StartingDate = DATEADD(day, @Offset, @StartingDate)
	
	SELECT @BusinessDayValue = B.BusinessDay FROM MetricBusinessDays B (NOLOCK) INNER Join MetricDetail D (NOLOCK) ON B.Plaindate = D.PlainDate
	WHERE B.PlainDate = @StartingDate
	
	-- Find the MOST RECENT business day that is ON or BEFORE the most recent processed.
	WHILE ISNULL(@BusinessDayValue, 1) = 0
	BEGIN
		SELECT @StartingDate = DATEADD(day, -1, @StartingDate)
		
		SELECT @BusinessDayValue = B.BusinessDay 
		FROM MetricBusinessDays B (NOLOCK) INNER JOIN MetricDetail D (NOLOCK)
			On B.Plaindate = D.PlainDate
		WHERE B.PlainDate = @StartingDate
	END
	RETURN @StartingDate
END
GO
GRANT EXECUTE ON  [dbo].[fnc_GetMostRecentBusinessDate] TO [public]
GO
