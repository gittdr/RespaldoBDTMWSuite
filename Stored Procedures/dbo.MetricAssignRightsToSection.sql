SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MetricAssignRightsToSection] (@ResNowMenuSection_Caption varchar(40), @GroupName varchar(50))
AS
	DECLARE @ResnowMenuSectionSN int, @MetricGroupSN int
	SET @ResnowMenuSectionSN = (SELECT sn FROM ResNowMenuSection WHERE Caption = @ResNowMenuSection_Caption)
	SET @MetricGroupSN = (SELECT sn FROM MetricGroup WHERE GroupName = @GroupName)

	IF (@ResnowMenuSectionSN IS NOT NULL) AND (@MetricGroupSN IS NOT NULL)
	BEGIN
		-- ResNowSection
		IF NOT EXISTS(SELECT * FROM metricpermission WHERE GroupSN = @MetricGroupSN AND ResNowSectionSN = @ResnowMenuSectionSN)
			INSERT INTO MetricPermission (GroupSN, MetricCategorySN, ResNowPageSN, ResNowSectionSN)
			VALUES (@MetricGroupSN, 0, 0, @ResnowMenuSectionSN) 

		-- ResNowPage
		INSERT INTO MetricPermission (GroupSN, MetricCategorySN, ResNowPageSN, ResNowSectionSN)
		SELECT @MetricGroupSN, 0, sn, 0 FROM ResNowPage WHERE MenuSectionSN = @ResnowMenuSectionSN 
			AND NOT EXISTS(SELECT * FROM MetricPermission WHERE GroupSN = @MetricGroupSN AND ResNowSectionSN = @ResnowMenuSectionSN)

		-- MetricCategory
		INSERT INTO MetricPermission (GroupSN, MetricCategorySN, ResNowPageSN, ResNowSectionSN)
		SELECT @MetricGroupSN, t2.sn, 0, 0 FROM ResNowPage t1 INNER JOIN MetricCategory t2 ON t1.CategoryCode = t2.CategoryCode 
		WHERE t1.MenuSectionSN = @ResnowMenuSectionSN
			AND NOT EXISTS(SELECT * FROM MetricPermission WHERE GroupSN = @MetricGroupSN AND MetricCategorySN = t2.sn)
	END
GO
GRANT EXECUTE ON  [dbo].[MetricAssignRightsToSection] TO [public]
GO
