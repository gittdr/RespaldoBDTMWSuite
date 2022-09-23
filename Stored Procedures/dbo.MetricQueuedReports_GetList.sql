SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[MetricQueuedReports_GetList] (@UserSN int)
AS
BEGIN
	SET NOCOUNT ON

	SELECT Status, dtCreate, 
			dtReady = CASE WHEN dtReady = '19000101' THEN CONVERT(varchar(30), '') ELSE CONVERT(varchar(30), dtReady) END, 
			dtRead = CASE WHEN dtRead = '19000101' THEN CONVERT(varchar(30), '') ELSE CONVERT(varchar(30), dtRead) END, 
			RunDuration = ISNULL(RunDuration, -1), 
			Report_GUID, 
			SQL = ISNULL(SQL, '') 
	FROM MetricQueuedReports 
	WHERE UserSN = @UserSN
	ORDER BY dtCreate DESC
END
GO
GRANT EXECUTE ON  [dbo].[MetricQueuedReports_GetList] TO [public]
GO
