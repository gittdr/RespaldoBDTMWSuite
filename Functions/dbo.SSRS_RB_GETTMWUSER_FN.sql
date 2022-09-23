SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE FUNCTION  [dbo].[SSRS_RB_GETTMWUSER_FN] ()
RETURNS varchar(255)

AS 
BEGIN
	DECLARE @user varchar(255)
	DECLARE @temp_user varchar(255)

	SELECT @temp_user = suser_sname()

	IF charindex ('\', @temp_user) > 0 BEGIN
		SELECT @user = Max (usr_userid)
		FROM ttsusers
		WHERE usr_windows_userid = suser_sname()

		IF @user IS NULL or @user= '' BEGIN
			SELECT @user = @temp_user
		END 
	END
	ELSE BEGIN
		SELECT @user = @temp_user	
	END

	SELECT @user = Right (@user, 20)
	SELECT @user = Rtrim (@user)

	RETURN @user
END

GO
