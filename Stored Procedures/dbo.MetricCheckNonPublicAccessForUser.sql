SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCheckNonPublicAccessForUser] (@UserSN int)
AS
	SET NOCOUNT ON

	IF EXISTS(SELECT t1.sn 
				FROM MetricPermission t1 INNER JOIN MetricGroup t2 ON t1.GroupSN = t2.sn 
					INNER JOIN MetricGroupUsers t3 ON t2.sn = t3.GroupSN 
				WHERE t2.GroupName <> 'public' AND t3.UserSN = @UserSN 
				)
		SELECT 1 
	ELSE 
		SELECT 0
GO
GRANT EXECUTE ON  [dbo].[MetricCheckNonPublicAccessForUser] TO [public]
GO
