SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricQueuedReports_GetReport] (@ReportGuid varchar(36), @UserSN int)
AS
	SET NOCOUNT ON
	
	SELECT Path FROM MetricQueuedReports WHERE Report_Guid = @ReportGuid AND UserSN = @UserSN
	
GO
GRANT EXECUTE ON  [dbo].[MetricQueuedReports_GetReport] TO [public]
GO
