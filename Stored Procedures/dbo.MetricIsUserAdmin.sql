SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricIsUserAdmin] (@UserSN int)
AS
	SET NOCOUNT ON

	DECLARE @curAdminGroup varchar(50)
	SET @curAdminGroup = UPPER((SELECT TOP 1 SettingValue FROM dbo.MetricGeneralSettings WHERE SettingName = 'AdminGroup'))

	IF EXISTS(SELECT t1.sn FROM MetricPermission t1
					INNER JOIN MetricGroup t2 ON t1.GroupSN = t2.sn 
					INNER JOIN MetricGroupUsers t3 ON t2.sn = t3.GroupSN 
				WHERE t2.GroupName <> 'public' 
					AND UPPER(groupname) = @curAdminGroup
					AND t3.UserSN = @UserSN
			)
		SELECT 1 
	ELSE 
	BEGIN
		IF EXISTS(SELECT t1.sn FROM resnowmenusection t1 INNER JOIN metricpermission t2 ON t1.sn = t2.ResNowSectionSN 
						INNER JOIN MetricGroup t3 ON t2.GroupSN = t3.sn 
					WHERE t1.systemcode = @curAdminGroup AND GroupName = 'public'
				)
			SELECT 1
		ELSE
			SELECT 0
	END
GO
GRANT EXECUTE ON  [dbo].[MetricIsUserAdmin] TO [public]
GO
