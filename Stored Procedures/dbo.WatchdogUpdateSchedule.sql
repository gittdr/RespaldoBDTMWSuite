SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogUpdateSchedule](@ScheduleName varchar(255), @ObjDescription varchar(400), @ObjectXML varchar(4000) )
AS
	UPDATE WatchdogScheduleObject 
	SET objDescription = @ObjDescription, ObjectXML = @ObjectXML WHERE ScheduleName = @ScheduleName
GO
GRANT EXECUTE ON  [dbo].[WatchdogUpdateSchedule] TO [public]
GO
