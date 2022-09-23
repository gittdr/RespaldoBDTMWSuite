SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_settingRetrieve]
	@setting_sourceName varchar(255),
    @setting_sectionName varchar(255),
	@setting_itemName varchar(255),
	@setting_userName varchar(20),
	@setting_machineName varchar(255),
	@setting_runtimeConfigName varchar(255),
	@setting_userGroupName varchar(20),
	@setting_scopeType int,
	@setting_ignoreLocks bit
AS
SELECT TOP 1
	v.ID as setting_settingID,
	s.Name as setting_sourceName,
	x.Name as setting_sectionName,
	v.TypeUpdatedBy as setting_settingsClassTypeName,
	i.Name as setting_itemName,
	v.LongValue as setting_serializedValue,
	v.ScopeType as setting_scopeType,
	v.ScopeName as setting_scopeName,
	v.MachineName as setting_machineName,
	v.ScopeLocked as setting_scopeLocked,
	v.CreatedOn as setting_createdOn,
	v.CreatedBy as setting_createdBy,
	v.UpdatedOn as setting_updatedOn,
	v.UpdatedBy as setting_updatedBy,
	i.RetiredOn as setting_retiredOn
FROM settings_value v
	INNER JOIN settings_item i on i.ID = v.ItemID
	INNER JOIN settings_item a on a.AliasOfItemID = i.ID
	INNER JOIN settings_section x on x.ID = a.SectionID
	INNER JOIN settings_source s on s.ID = x.SourceID
WHERE
	s.Name = @setting_sourceName and 
	x.Name = @setting_sectionName and
	a.Name = @setting_itemName and
	v.ScopeType >= @setting_scopeType and
	v.ScopeName = 
		CASE v.ScopeType
			WHEN 0 THEN @setting_userName
			WHEN 10 THEN @setting_runtimeConfigName
			WHEN 20 THEN @setting_userGroupName
			ELSE ''
		END
		and
	v.MachineName in (@setting_machineName, '') and
	(i.RetiredOn is null and a.RetiredOn is null and x.RetiredOn is null and s.RetiredOn is null)
	
ORDER BY
	[dbo].[setting_getPrecedence](
		ScopeType, 
		CASE @setting_ignoreLocks WHEN 1 THEN 0 ELSE ScopeLocked END, 
		v.MachineName
		) DESC	
GO
GRANT EXECUTE ON  [dbo].[core_settingRetrieve] TO [public]
GO
