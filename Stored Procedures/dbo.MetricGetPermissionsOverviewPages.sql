SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetPermissionsOverviewPages] (@GroupSN int, @MembersOption VARCHAR(1) )
AS
	SET NOCOUNT ON

	If @MembersOption = 'B'
		SELECT t1.sn AS mgpSn, t2.Page 
			FROM (SELECT DISTINCT Page FROM RN_OverviewParameter) t2 LEFT OUTER JOIN metricpermission t1 
				ON t1.OverviewPage = t2.Page AND GroupSN = @GroupSN
		ORDER BY t2.page

	ELSE IF @MembersOption = 'Y'
		SELECT t1.sn AS mgpSn, t2.Page 
			FROM (SELECT DISTINCT Page FROM RN_OverviewParameter) t2 INNER JOIN metricpermission t1 ON t1.OverviewPage = t2.Page
		WHERE GroupSN = @GroupSN
		ORDER BY t2.page

	ELSE IF @MembersOption = 'N'
		SELECT 'NEW' As mgpSN, t2.Page
		FROM (SELECT DISTINCT Page FROM RN_OverviewParameter) t2 
		WHERE NOT EXISTS(SELECT sn FROM metricpermission t1 WHERE t1.OverviewPage = t2.Page AND ISNULL(GroupSN, 0) = @GroupSN)
		ORDER BY t2.page

GO
GRANT EXECUTE ON  [dbo].[MetricGetPermissionsOverviewPages] TO [public]
GO
