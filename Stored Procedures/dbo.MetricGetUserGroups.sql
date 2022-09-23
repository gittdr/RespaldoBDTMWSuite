SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetUserGroups] (@MembersOption varchar(1), @UserSN int)
AS
	SET NOCOUNT ON

	IF @MembersOption = 'B'
		SELECT t2.sn AS MugSN, t3.sn AS GroupSN, t3.GroupName, ISNULL(t3.Disable, 0) AS Disable, t2.sn AS GroupUsersSN
		FROM metricgroup t3 LEFT OUTER JOIN metricgroupusers t2 ON t3.sn = t2.GroupSN AND t2.UserSN = @UserSN
		WHERE t3.GroupName <> 'public' 
		ORDER BY GroupName
	ELSE IF @MembersOption = 'Y'
		SELECT t2.sn AS MugSN, t3.sn AS GroupSN, t3.GroupName, ISNULL(t3.Disable, 0) AS Disable, t2.sn AS GroupUsersSN
		FROM metricgroupusers t2, metricgroup t3 WHERE t2.GroupSN = t3.sn AND t2.UserSN = @UserSN
			AND t3.GroupName <> 'public'
		ORDER BY GroupName
	ELSE IF @MembersOption = 'N'
		SELECT 'NEW' As MugSN, t2.sn AS GroupSN, t2.GroupName, ISNULL(t2.Disable, 0) AS Disable, t2.sn AS GroupUsersSN
		FROM MetricGroup t2
		WHERE NOT EXISTS(SELECT sn FROM MetricGroupUsers t1 WHERE t1.GroupSn = t2.sn AND t1.UserSN = @UserSN)
			AND GroupName <> 'public'
		ORDER BY GroupName
GO
GRANT EXECUTE ON  [dbo].[MetricGetUserGroups] TO [public]
GO
