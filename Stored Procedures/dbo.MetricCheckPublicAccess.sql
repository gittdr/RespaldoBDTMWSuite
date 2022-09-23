SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricCheckPublicAccess] 
AS
	SET NOCOUNT ON

	IF EXISTS(		SELECT * FROM MetricPermission t1 (NOLOCK) INNER JOIN MetricGroup t2 (NOLOCK) ON t1.GroupSN = t2.sn
					INNER JOIN resnowmenusection t3 (NOLOCK) ON t1.ResNowSectionSN = t3.sn
					INNER JOIN resnowpage t4 (NOLOCK) ON t3.sn = t4.MenuSectionSN
					WHERE t2.GroupName = 'public'
		) 
	BEGIN
		SELECT 1 
	END
	ELSE 
		SELECT 0
GO
GRANT EXECUTE ON  [dbo].[MetricCheckPublicAccess] TO [public]
GO
