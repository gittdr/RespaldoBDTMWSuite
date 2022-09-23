SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[DoTZResetForUser] (@SourceDate datetime, @LoginName varchar(20))
RETURNS datetime
BEGIN
    DECLARE @SystemTZ int, @SystemDSTCode int, @SystemTZMins int
    DECLARE @UserTZ int, @UserDSTCode int, @UserTZMins int
    exec dbo.GetSystemTZ @SystemTZ out, @SystemDSTCode out, @SystemTZMins out
    exec dbo.GetUserTZ @LoginName, @UserTZ out, @UserDSTCode out, @UserTZMins out
    RETURN dbo.ChangeTZ(@SourceDate, @SystemTZ, @SystemDSTCode, @SystemTZMins, @UserTZ, @UserDSTCode, @UserTZMins)
END
GO
GRANT EXECUTE ON  [dbo].[DoTZResetForUser] TO [public]
GO
