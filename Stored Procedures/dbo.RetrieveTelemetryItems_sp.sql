SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RetrieveTelemetryItems_sp] 
AS
BEGIN
	SET NOCOUNT ON;
	Select TelemetryItems From TelemetryPermission ORDER BY ApplicationVersion Desc
END
GO
GRANT EXECUTE ON  [dbo].[RetrieveTelemetryItems_sp] TO [public]
GO
