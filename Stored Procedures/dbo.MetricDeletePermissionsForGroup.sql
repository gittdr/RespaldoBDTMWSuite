SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeletePermissionsForGroup] (@GroupSN int, @CategorySN int, @ResNowsectionSN int, @OverviewPage int)
AS
	SET NOCOUNT ON

	IF @CategorySN > 0
		DELETE MetricPermission WHERE ISNULL(GroupSN, 0) = @GroupSN AND ISNULL(MetricCategorySN, 0) = @CategorySN  
	ELSE IF @ResNowSectionSN > 0
		DELETE MetricPermission WHERE ISNULL(GroupSN, 0) = @GroupSN AND ISNULL(ResNowsectionSN, 0) = @ResNowsectionSN  
	ELSE IF @OverviewPage > 0
		DELETE MetricPermission WHERE ISNULL(GroupSN, 0) = @GroupSN AND ISNULL(OverviewPage, 0) = @OverviewPage
	ELSE
		DELETE MetricPermission WHERE ISNULL(GroupSN, 0) = @GroupSN
GO
GRANT EXECUTE ON  [dbo].[MetricDeletePermissionsForGroup] TO [public]
GO
