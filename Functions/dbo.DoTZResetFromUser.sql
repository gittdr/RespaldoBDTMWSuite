SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[DoTZResetFromUser] (@SourceDate datetime, @LoginName varchar(20))
RETURNS DATETIME
BEGIN
    DECLARE @SystemTZ int, @SystemDSTCode int, @SystemTZMins int
    DECLARE @UserTZ int, @UserDSTCode int, @UserTZMins int
    exec dbo.GetSystemTZ @SystemTZ out, @SystemDSTCode out, @SystemTZMins out
    exec dbo.GetUserTZ @LoginName, @UserTZ out, @UserDSTCode out, @UserTZMins out
    return dbo.ChangeTZ (@SourceDate, @UserTZ, @UserDSTCode, @UserTZMins, @SystemTZ, @SystemDSTCode, @SystemTZMins)
END
GO
GRANT EXECUTE ON  [dbo].[DoTZResetFromUser] TO [public]
GO
