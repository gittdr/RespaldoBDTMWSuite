SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCheckSecurityOnMetricCode] (@UserSN int, @MetricCode varchar(100) ) 
AS
	SET NOCOUNT ON

	-- Does this user have rights to view this page.
	DECLARE @GroupSN int
	DECLARE @LayerSN int, @BaseMetricCode varchar(200)


	-- Is it a layer?
	SELECT @LayerSN = ISNULL(LayerSN, 0) FROM MetricItem (NOLOCK) WHERE metriccode = @MetricCode
	IF @LayerSN > 0
	BEGIN
		SELECT @MetricCode = MetricCode FROM MetricLayer WHERE Layersn = @LayerSN
	END

	-- SELECT @GroupSN = GroupSN FROM metricgroupusers (NOLOCK) WHERE UserSN = @UserSN

	IF EXISTS(SELECT t3.sn 
				FROM metricgroupusers t0 INNER JOIN metricpermission t1 (NOLOCK) ON t0.GroupSN = t1.GroupSN
					INNER JOIN MetricCategory t2 (NOLOCK) ON t1.MetricCategorySN = t2.sn
					INNER JOIN MetricCategoryItems t3 (NOLOCK) ON t2.CategoryCode = t3.CategoryCode 
				WHERE t0.UserSN = @UserSN AND t1.MetricCategorySN <> 0 AND t3.metricCode = @MetricCode)
		SELECT 1
	ELSE
		SELECT 0
	
GO
GRANT EXECUTE ON  [dbo].[MetricCheckSecurityOnMetricCode] TO [public]
GO
