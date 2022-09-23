SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogGetScheduleByName] (@ScheduleName varchar(255))
AS
	SET NOCOUNT ON

	SELECT id
	FROM WatchDogScheduleObject 
	WHERE ScheduleName = @ScheduleName

GO
GRANT EXECUTE ON  [dbo].[WatchdogGetScheduleByName] TO [public]
GO
