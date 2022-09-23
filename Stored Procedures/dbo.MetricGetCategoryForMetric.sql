SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetCategoryForMetric]
(
	@MetricCode varchar(200)
)
AS
	SET NOCOUNT ON
	
	SELECT t2.MetricCode, t1.sn, t1.Active, t1.Sort, t1.ShowTime, t1.CategoryCode, t1.Caption 
	FROM MetricCategory t1 LEFT OUTER JOIN MetricCategoryItems t2 ON t1.CategoryCode = t2.CategoryCode AND t2.MetricCode = @MetricCode
	ORDER BY t1.Caption
GO
GRANT EXECUTE ON  [dbo].[MetricGetCategoryForMetric] TO [public]
GO
