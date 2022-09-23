SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetCategories] (@OrderByCategoryCodeYN varchar(1) = 'N')
AS
	SET NOCOUNT ON

	IF ISNULL(@OrderByCategoryCodeYN, 'N') = 'N'
		SELECT sn FROM MetricCategory ORDER BY Caption
	ELSE
		SELECT sn, Active, CategoryCode, Caption, Parent, ShowFullTimeFrameDay, ShowFullTimeFrameWeek,
			ShowFullTimeFrameMonth, ShowFullTimeFrameQuarter, ShowFullTimeFrameYear, ShowFullTimeFrameFiscalYear ,
			menusectionsn = (select top 1 isNull(ResNowMenuSection.sn,'') from ResNowMenuSection where
			ResNowMenuSection.sn = (select max(menusectionsn) from resnowpage where metriccategorysn = MetricCategory.sn)),
			security = (select count(*) from metricpermission  where metriccategorySN = MetricCategory.sn),
			DateOrderLeftToRight = CASE WHEN ISNULL(DateOrderLeftToRight, '') = '' OR ISNULL(DateOrderLeftToRight, '') = 'CURRENTPRIOR' OR ISNULL(DateOrderLeftToRight, '') = 'DESC' THEN 'DESC' ELSE '' END
			, AllowChartDisplay_YN = ISNULL(AllowChartDisplay_YN, 'Y')
		FROM MetricCategory 
		Order by CategoryCode
GO
GRANT EXECUTE ON  [dbo].[MetricGetCategories] TO [public]
GO
