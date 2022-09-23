SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetPagesForCategorySN] (@CategorySN int)
AS
	SET NOCOUNT OFF

	SELECT * FROM ResNowPage WHERE MetricCategorySN = @CategorySN
GO
GRANT EXECUTE ON  [dbo].[MetricGetPagesForCategorySN] TO [public]
GO
