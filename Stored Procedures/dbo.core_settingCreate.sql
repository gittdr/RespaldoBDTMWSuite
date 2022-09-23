SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[core_settingCreate]
	@setting_sourceName varchar(255),
	@setting_sectionName varchar(255),
	@setting_itemName varchar(255),
	@setting_scopeType int,
	@setting_scopeName varchar(255),	
	@setting_machineName varchar(255),
	@setting_serializedValue text,
	@setting_scopeLocked bit,
	@setting_settingsClassTypeName varchar(255)
AS

DECLARE @now AS datetime
SET @now = getdate()

DECLARE @itemID int
SET @itemID = 0

SELECT @itemID = i.ID FROM settings_item i
	INNER JOIN settings_item a ON a.AliasOfItemID = i.ID
	INNER JOIN settings_section x ON x.ID = a.SectionID
	INNER JOIN settings_source s on s.ID = x.SourceID
	WHERE s.[Name] = @setting_sourceName 
		AND x.[Name] = @setting_sectionName 
		AND a.[Name] = @setting_itemName

IF @itemID = 0
	BEGIN
	RAISERROR('Setting item %s.%s.%s not on file.', 16, 1, @setting_sourceName, @setting_sectionName, @setting_itemName)
	RETURN
	END

INSERT INTO [settings_value] (
	ItemID,
	ScopeType,
	ScopeName,
	MachineName,
	LongValue,
	ShortValue,
	ScopeLocked,
	TypeUpdatedBy,
	CreatedOn,
	UpdatedOn
)
VALUES (
	@itemID,
	@setting_scopeType,
	@setting_scopeName,
	@setting_machineName,
	@setting_serializedValue,
	convert(varchar(255), @setting_serializedValue),
	@setting_scopeLocked,
	@setting_settingsClassTypeName,
	@now,
	@now
)

SELECT
	ID AS setting_SettingID,
	UpdatedBy AS setting_UpdatedBy, 
	UpdatedOn AS setting_UpdatedOn
FROM [settings_value]
WHERE
	ID = SCOPE_IDENTITY()

GO
GRANT EXECUTE ON  [dbo].[core_settingCreate] TO [public]
GO
