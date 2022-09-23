SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCheckSecurityOnOverviewPage] (@UserSN int, @Page int ) 
AS
	SET NOCOUNT ON

	-- Does this user have rights to view this page.
	DECLARE @GroupSN int

	IF EXISTS(SELECT t0.sn FROM metricgroupusers t0 INNER JOIN metricpermission t1 (NOLOCK) ON t0.GroupSN = t1.GroupSN
				INNER JOIN (SELECT DISTINCT Page FROM RN_OverviewParameter) t2 ON t1.OverviewPage = t2.Page 
				WHERE (t0.UserSN = @UserSN)
					AND t2.Page = @Page
			)
		SELECT 1
	ELSE
	BEGIN
		IF EXISTS(SELECT sn FROM metricpermission WHERE overviewpage = @Page AND GroupSN = 1)  -- i.e. public group has access.
			SELECT 1
		ELSE
			SELECT 0
	END
	
GO
GRANT EXECUTE ON  [dbo].[MetricCheckSecurityOnOverviewPage] TO [public]
GO
