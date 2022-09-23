SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetCategoryBySN] (@CategorySN int)
AS
	SET NOCOUNT ON

	DECLARE @CategoryCode varchar(30)

	SELECT @CategoryCode = CategoryCode
    FROM MetricCategory
    Where sn = @CategorySN 

        
	SELECT mci.sn, mci.sort, mi.MetricCode, mi.Caption, CategoryCode = @CategoryCode
	FROM metricitem mi join metriccategoryitems mci on mi.metriccode = mci.metriccode
	WHERE mci.categorycode = @CategoryCode
		AND mci.Active = 1
		AND mi.Active = 1
	ORDER BY mci.sort
GO
GRANT EXECUTE ON  [dbo].[MetricGetCategoryBySN] TO [public]
GO
