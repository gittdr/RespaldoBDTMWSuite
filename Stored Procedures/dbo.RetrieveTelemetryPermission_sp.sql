SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RetrieveTelemetryPermission_sp] 
AS
BEGIN
	SET NOCOUNT ON;
	Select TOP 1 Permission From TelemetryPermission ORDER BY ID DESC
END
GO
GRANT EXECUTE ON  [dbo].[RetrieveTelemetryPermission_sp] TO [public]
GO
