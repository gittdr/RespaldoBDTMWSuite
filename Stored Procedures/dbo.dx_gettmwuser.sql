SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_gettmwuser] @user varchar (255) OUTPUT
 AS 

/*******************************************************************************************************************  
  Object Description:
  dx_gettmwuser

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

DECLARE @temp_user varchar (255)

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

GO
GRANT EXECUTE ON  [dbo].[dx_gettmwuser] TO [public]
GO
