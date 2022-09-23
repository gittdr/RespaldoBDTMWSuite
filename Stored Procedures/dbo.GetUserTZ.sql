SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[GetUserTZ] @UserName varchar(50), @UserTZ int OUT, @UserDSTCode int OUT, @UserTZMins int OUT

AS

SET NOCOUNT ON

    SELECT @UserTZ = NULL, @UserDSTCode = NULL, @UserTZMins = NULL
    SELECT @UserTZ = TimeZone, @UserDSTCode = DSTCode, @UserTZMins = TZMinutes 
    FROM tblLogin (NOLOCK) 
    WHERE loginname = @UserName
GO
GRANT EXECUTE ON  [dbo].[GetUserTZ] TO [public]
GO
