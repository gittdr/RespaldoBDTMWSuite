SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[Get_Profile_String]
(
	@filename	as varchar(255),
	@section	as varchar(255),
	@field		as varchar(255),
	@userid		as varchar(20),
	@default	as varchar(255)
)
RETURNS varchar(255)

AS
/**
 * 
 * NAME:
 * dbo.Get_Profile_String
 *
 * TYPE:
 * UDF
 *
 * DESCRIPTION:
 * Retrieves a value from the database version of the ini file
 * 
 *
 * RETURNS:
 * 0: string
 * RESULT SETS: 
 * None
 *
 * 
 **/

BEGIN
	DECLARE @Result varchar(255)

	select @Result = ini_values.value_setting
	from ini_values
		inner join ini_xref_file_section_item on ini_values.file_section_item_id = ini_xref_file_section_item.file_section_item_id
		inner join ini_xref_file_section on ini_xref_file_section_item.file_section_id = ini_xref_file_section.file_section_id
		inner join ini_section on ini_xref_file_section.section_id = ini_section.section_id  inner join ini_item on ini_xref_file_section_item.item_id = ini_item.item_id  inner join ini_file on ini_xref_file_section.file_id = ini_file.file_id 
	where ini_values.active = 'Y'
		and ini_values.usr_userid = @userid
		and ini_xref_file_section_item.active = 'Y'
		and ini_item.item_name = @field
		and ini_item.active = 'Y'
		and ini_xref_file_section.active = 'Y'
		and ini_file.file_name = @filename
		and ini_file.active = 'Y'
		and ini_section.section_name = @section
		and ini_section.active = 'Y'

	
	RETURN COALESCE(@Result, @default)
	
END
GO
GRANT EXECUTE ON  [dbo].[Get_Profile_String] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Get_Profile_String] TO [public]
GO
