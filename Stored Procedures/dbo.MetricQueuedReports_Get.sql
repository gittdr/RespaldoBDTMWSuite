SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricQueuedReports_Get] (@UserSN int)
AS
BEGIN
	SET NOCOUNT ON

	SELECT [GETDATE] = GETDATE()
		,[Queued] = (SELECT COUNT(*) FROM MetricQueuedReports WHERE UserSN = @UserSN AND Status = 'Queued' AND UserSN = @UserSN)
		,[Ready] = (SELECT COUNT(*) FROM MetricQueuedReports WHERE UserSN = @UserSN AND Status = 'Ready' AND UserSN = @UserSN)
		,[Read] = (SELECT COUNT(*) FROM MetricQueuedReports WHERE UserSN = @UserSN AND Status = 'Read' AND UserSN = @UserSN)
END
GO
GRANT EXECUTE ON  [dbo].[MetricQueuedReports_Get] TO [public]
GO
