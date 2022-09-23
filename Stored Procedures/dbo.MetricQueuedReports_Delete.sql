SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricQueuedReports_Delete] (@ReportGUID varchar(100), @UserSN int)
AS
	SET NOCOUNT ON

	DELETE MetricQueuedReports WHERE Report_GUID = @ReportGUID AND UserSN = @UserSN
GO
GRANT EXECUTE ON  [dbo].[MetricQueuedReports_Delete] TO [public]
GO
