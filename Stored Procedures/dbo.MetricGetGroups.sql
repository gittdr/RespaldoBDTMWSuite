SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetGroups] (@GroupSN int) 
AS
	SET NOCOUNT ON

   If @GroupSN = 0 
		--*** GroupSN and UserSN is 0 to show all rows in MetricGroup table.
		SELECT sn, GroupName, Disable, CASE WHEN GroupName = 'public' THEN 0 ELSE 1 END FROM MetricGroup 
		ORDER BY CASE WHEN GroupName = 'public' THEN 0 ELSE 1 END, GroupName

   ELSE IF @GroupSN <> 0 
		SELECT sn, GroupName, Disable FROM MetricGroup WHERE sn = @GroupSN

GO
GRANT EXECUTE ON  [dbo].[MetricGetGroups] TO [public]
GO
