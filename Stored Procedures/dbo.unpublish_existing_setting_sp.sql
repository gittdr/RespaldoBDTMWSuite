SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[unpublish_existing_setting_sp] (@ps_sectionname varchar(255), @ps_setting varchar(255)) as
-- PROCEDURE unpublishes an existing ini setting in the db. Created by: Jude Date:4/25/08

If exists 
(	select     * 
	from  ini_xref_file_section_item c	     
	     inner join ini_xref_file_section d
	        on d.file_section_id = c.file_section_id
	     inner join ini_item e
	        on e.item_id = c.item_id
	     inner join ini_file f
	        on f.file_id = d.file_id
	     inner join ini_section g
	        on g.section_id = d.section_id
		where 
			f.[file_name] = 'TTS50.INI' and
			g.section_name = @ps_sectionname and
			e.item_name = @ps_setting and
			IsNull(e.unpublished_setting,'N') = 'N')

BEGIN
	update e
	set e.unpublished_setting = 'Y'
	from  ini_xref_file_section_item c	     
	     inner join ini_xref_file_section d
	        on d.file_section_id = c.file_section_id
	     inner join ini_item e
	        on e.item_id = c.item_id
	     inner join ini_file f
	        on f.file_id = d.file_id
	     inner join ini_section g
	        on g.section_id = d.section_id
	where 
			f.[file_name] = 'TTS50.INI' and
			g.section_name = @ps_sectionname and
			e.item_name = @ps_setting


END	

if exists (select * from ini_master_tmw where ini_filename = 'TTS50.INI' and ini_section = @ps_sectionname and ini_item = @ps_setting and isnull(unpublished_setting,'N') = 'N')
	update ini_master_tmw set unpublished_setting = 'Y' where ini_filename = 'TTS50.INI' and ini_section = @ps_sectionname and ini_item = @ps_setting 


GO
GRANT EXECUTE ON  [dbo].[unpublish_existing_setting_sp] TO [public]
GO
