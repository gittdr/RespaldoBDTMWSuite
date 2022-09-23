SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricGetPageByUserAndPage] (@UserSN int, @PageSN int) 
AS
	SET NOCOUNT ON

	DECLARE @GroupSN int

	SELECT @GroupSN = GroupSN FROM metricgroupusers (NOLOCK) WHERE UserSN = @UserSN

	SELECT PageURL FROM resnowpage WHERE MenuSectionSN IN 
		( SELECT ResNowSectionSN FROM MetricPermission (NOLOCK) WHERE GroupSN = @GroupSN )
		AND sn = @PageSN

GO
GRANT EXECUTE ON  [dbo].[MetricGetPageByUserAndPage] TO [public]
GO
