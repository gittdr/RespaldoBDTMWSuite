SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[gettmwuser] @user varchar (255) OUTPUT
 AS 

--PTS 38839 accomodate for aliasing.  This is tracked in spid_tracking against the @@spid

DECLARE @temp_user varchar (255)
DECLARE @alias_user varchar(255)

SELECT @temp_user = suser_sname()

-- RE - PTS #43789 added rdbms_login check
select @alias_user = usr_alias from spid_tracking where spid = @@spid and rdbms_login = @temp_user

if @alias_user is null or ltrim(rtrim(@alias_user)) = ''
BEGIN
    --if the alias is not known (empty string) or is null (@@spid not in tracking table), then resort to original logic that hits ttsusers
    IF charindex ('\', @temp_user) > 0
    BEGIN
        SELECT @user = Max (usr_userid)
        FROM ttsusers
        WHERE usr_windows_userid = suser_sname()
    
        IF @user IS NULL or @user='' SELECT @user = @temp_user
    
    END
    ELSE
    BEGIN
        SELECT @user = @temp_user	
    END
END
ELSE
BEGIN
    select @user = @alias_user
END
--END PTS38839

SELECT @user = Right (@user, 20)
SELECT @user = Rtrim (@user)
GO
GRANT EXECUTE ON  [dbo].[gettmwuser] TO [public]
GO
