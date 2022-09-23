SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_settingUpdate]
	@setting_settingID int,
	@setting_scopeType int,
	@setting_scopeName varchar(255),
	@setting_machineName varchar(255),
	@setting_SerializedValue text,
	@setting_scopeLocked bit,
	@setting_settingsClassTypeName varchar(255)
AS
UPDATE [settings_value]
SET
	ScopeType = @setting_scopeType,
	ScopeName = @setting_scopeName,
	MachineName = @setting_machineName,
	LongValue = @setting_serializedValue,
	ShortValue = convert(varchar(255), @setting_serializedValue),
	ScopeLocked = @setting_scopeLocked,
	TypeUpdatedBy = @setting_settingsClassTypeName,
	UpdatedOn = getdate()
WHERE 
	ID = @setting_settingID

SELECT
	UpdatedBy AS setting_updatedBy, 
	UpdatedOn AS setting_updatedOn
FROM [settings_value]
WHERE
	ID = @setting_settingID

GO
GRANT EXECUTE ON  [dbo].[core_settingUpdate] TO [public]
GO
