SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[WatchdogUpdateScheduleName](@NewName varchar(255), @OldName varchar(255))
AS
	UPDATE WatchDogScheduleObject SET ScheduleName = @NewName WHERE ScheduleName = @OldName
GO
GRANT EXECUTE ON  [dbo].[WatchdogUpdateScheduleName] TO [public]
GO
