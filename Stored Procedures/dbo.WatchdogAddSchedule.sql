SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogAddSchedule](@ScheduleName varchar(255), @ObjDescription varchar(400), @ObjectXML varchar(4000) )
AS
	INSERT INTO WatchdogScheduleObject (ScheduleName, objDescription, ObjectXML) 
	SELECT @ScheduleName, @objDescription, @ObjectXML
GO
GRANT EXECUTE ON  [dbo].[WatchdogAddSchedule] TO [public]
GO
