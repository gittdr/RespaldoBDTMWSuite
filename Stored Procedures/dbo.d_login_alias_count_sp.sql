SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_login_alias_count_sp] 
( @user_id char(20) )
AS
BEGIN

    DECLARE @count int

    SELECT @count = COUNT(1)
    FROM alias_mapping
    WHERE usr_userid = @user_id
    
    Return @count

END

GO
GRANT EXECUTE ON  [dbo].[d_login_alias_count_sp] TO [public]
GO
