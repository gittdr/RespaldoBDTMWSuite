SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_settingDelete]
	@setting_settingID int
AS
DELETE settings_value
	where ID = @setting_settingID

GO
GRANT EXECUTE ON  [dbo].[core_settingDelete] TO [public]
GO
