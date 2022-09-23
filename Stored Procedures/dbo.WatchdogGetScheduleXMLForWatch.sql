SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogGetScheduleXMLForWatch] (@WatchName varchar(255))
AS
	SET NOCOUNT ON

	SELECT ObjectXML , ScheduleName 
	FROM WatchDogItem Inner Join WatchDogScheduleObject ON WatchDogItem.ScheduleID = WatchDogScheduleObject.ID 
	WHERE WatchDogItem.WatchName = @WatchName

GO
GRANT EXECUTE ON  [dbo].[WatchdogGetScheduleXMLForWatch] TO [public]
GO
