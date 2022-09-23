SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[core_settingKeysRetrieve]
    @setting_propertyName varchar(255)
AS

IF @setting_propertyName = 'EVOLUTION' 
	set @setting_propertyName = @setting_propertyName + '.'

SELECT DISTINCT
	s.Name + '.' + x.Name + '.' + i.Name as setting_propertyName
	FROM settings_item i
		INNER JOIN settings_section x on x.ID = i.SectionID
		INNER JOIN settings_source s on s.ID = x.SourceID
		WHERE (
			s.Name + '.' + x.Name + '.' + i.Name like @setting_propertyName + '%' and
			(i.RetiredOn is null and x.RetiredOn is null and s.RetiredOn is null)
			)
	ORDER BY 
		s.Name + '.' + x.Name + '.' + i.Name
		
GO
GRANT EXECUTE ON  [dbo].[core_settingKeysRetrieve] TO [public]
GO
