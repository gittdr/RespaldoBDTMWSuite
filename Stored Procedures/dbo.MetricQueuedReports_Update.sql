SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricQueuedReports_Update] (@ReportGUID varchar(100), @UserSN int)
AS
	SET NOCOUNT ON

	UPDATE MetricQueuedReports SET Status = 'Read', dtRead = GETDATE() 
	WHERE Report_Guid = @ReportGuid AND UserSN = @UserSN
GO
GRANT EXECUTE ON  [dbo].[MetricQueuedReports_Update] TO [public]
GO
