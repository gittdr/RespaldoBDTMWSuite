SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricAddPermissionForGroup] (@GroupSN int, @CategorySN int, @ResNowsectionSN int, @OverviewPage int)
AS
	SET NOCOUNT ON

	IF @CategorySN > 0
		INSERT INTO MetricPermission (GroupSN, MetricCategorySN, ResNowSectionSN, OverviewPage) SELECT @GroupSN, @CategorySN, 0, 0
	ELSE IF @ResNowSectionSN > 0
		INSERT INTO MetricPermission (GroupSN, MetricCategorySN, ResNowSectionSN, OverviewPage) SELECT @GroupSN, 0, @ResNowsectionSN, 0
	ELSE IF @OverviewPage > 0
		INSERT INTO MetricPermission (GroupSN, MetricCategorySN, ResNowSectionSN, OverviewPage) SELECT @GroupSN, 0, 0, @OverviewPage
GO
GRANT EXECUTE ON  [dbo].[MetricAddPermissionForGroup] TO [public]
GO
