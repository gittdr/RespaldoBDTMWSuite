SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RetrieveTelemetryPrompted_sp] 
AS
BEGIN
	SET NOCOUNT ON;
	Select TOP 1 Prompted From TelemetryPermission ORDER BY ID DESC
END
GO
GRANT EXECUTE ON  [dbo].[RetrieveTelemetryPrompted_sp] TO [public]
GO
