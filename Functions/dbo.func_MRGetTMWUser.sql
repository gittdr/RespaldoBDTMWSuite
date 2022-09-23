SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create Function [dbo].[func_MRGetTMWUser]()
Returns varchar(255)

As
Begin

DECLARE @temp_user varchar (255)
Declare @user varchar(255)

SELECT @temp_user = suser_sname()

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


SELECT @user = Right (@user, 20)
SELECT @user = Rtrim (@user)

Return @user

End


GO
GRANT EXECUTE ON  [dbo].[func_MRGetTMWUser] TO [public]
GO
GRANT REFERENCES ON  [dbo].[func_MRGetTMWUser] TO [public]
GO
