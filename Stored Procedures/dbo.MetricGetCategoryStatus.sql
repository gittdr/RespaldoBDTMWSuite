SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[MetricGetCategoryStatus] (@CategoryCode varchar(30)) 
AS
	SELECT ISNULL(Active, 0), DateOrderLeftToRight = ISNULL(DateOrderLeftToRight, '')
		     , AllowChartDisplay_YN = ISNULL(AllowChartDisplay_YN, 'Y')
		     , Caption
	FROM  metriccategory where categorycode = @CategoryCode 


GRANT EXECUTE ON dbo.MetricGetCategoryStatus TO public
GO
GRANT EXECUTE ON  [dbo].[MetricGetCategoryStatus] TO [public]
GO
