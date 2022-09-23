SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_login_alias_mapping] 
( @user_id char(20) )
AS
BEGIN

    SELECT 
        usr_userid,
        usr_userid_alias
    FROM alias_mapping
    WHERE usr_userid = 
        CASE @user_id WHEN 'SHOWALL' THEN usr_userid ELSE @user_id END

END

GO
GRANT EXECUTE ON  [dbo].[d_login_alias_mapping] TO [public]
GO
