SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetOverviewParametersForPage] (@pageSN int, @Side varchar(5))
AS
	SET NOCOUNT ON

	SELECT Heading, LabelDefinition, Mode, PrcHeading, NumberOfValues, DaysBack, DaysRange, Colors, Parameters
		,DateStart = CONVERT(varchar(10), ISNULL( (SELECT MIN(DateStart) FROM RNTrial_Cache_TopValues t02 (NOLOCK) WHERE t02.ItemCategory = t1.mode), DATEADD(day, -t1.DaysBack-t1.DaysRange, GETDATE()) ), 121)
		,DateEnd = CONVERT(varchar(10), ISNULL( (SELECT MIN(DateEnd) FROM RNTrial_Cache_TopValues t03 (NOLOCK) WHERE t03.ItemCategory = t1.mode)	, DATEADD(day, -DaysBack, GETDATE()) ), 121)
		, NeedsRefresh = CASE WHEN NOT EXISTS(SELECT RecNum FROM RNTrial_Cache_TopValues t04 (NOLOCK) WHERE t04.ItemCategory = t1.mode) THEN 1 ELSE 0 END
	FROM RN_OverviewParameter t1 (NOLOCK)
	WHERE Side = @Side 
		AND Active = 1 
		AND Page = @PageSN
	ORDER BY Sort
GO
GRANT EXECUTE ON  [dbo].[MetricGetOverviewParametersForPage] TO [public]
GO
