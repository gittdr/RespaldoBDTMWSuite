SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_general_info_setting]	
						@sName varchar(100),
						@sFlags varchar(12)
AS
	DECLARE	@iFlags int

	if ISNULL(@sName, '') = ''
		BEGIN
		RAISERROR ('tmail_get_general_info_setting:Name must be passed in.', 16, 1)
		RETURN
		END

	SET @iFlags = CONVERT(int, @sFlags)

	SELECT gi_name, gi_datein, gi_string1, gi_string2, gi_string3, gi_string4, gi_integer1, gi_integer2, gi_integer3, gi_integer4, gi_date1, gi_date2, gi_appid, gi_description
	FROM generalinfo (NOLOCK)
	WHERE gi_name =  @sName

GO
GRANT EXECUTE ON  [dbo].[tmail_get_general_info_setting] TO [public]
GO
