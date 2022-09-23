SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricDeleteUserAndUserGroups] (@UserSN int)
AS
	SET NOCOUNT ON

	DELETE MetricGroupUsers WHERE UserSN = @UserSN

	DELETE metricuser WHERE sn = @UserSN
GO
GRANT EXECUTE ON  [dbo].[MetricDeleteUserAndUserGroups] TO [public]
GO
