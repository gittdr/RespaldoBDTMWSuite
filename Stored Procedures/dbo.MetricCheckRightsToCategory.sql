SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCheckRightsToCategory] (@UserSN int, @CategoryCode varchar(30)) 
AS
	SET NOCOUNT ON

	DECLARE @categorySN int

	SELECT @categorySN = sn FROM MetricCategory WHERE CategoryCode = @CategoryCode

	IF EXISTS(SELECT t1.sn FROM MetricPermission t1 INNER JOIN MetricGroupUsers t2 ON t1.GroupSN = t2.GroupSN
				WHERE t2.UserSN = @UserSN AND MetricCategorySN = @categorySN
			)
		SELECT 1
	ELSE
		SELECT 0
GO
GRANT EXECUTE ON  [dbo].[MetricCheckRightsToCategory] TO [public]
GO
