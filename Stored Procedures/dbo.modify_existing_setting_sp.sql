SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[modify_existing_setting_sp] (@ps_sectionname varchar(255), @ps_setting varchar(255), @ps_value varchar(255),@ps_description varchar(6000)) as
-- PROCEDURE modifies existing ini settings in the database. Created by: Jude Date:4/25/08


if exists (select * from ini_master_tmw where ini_filename = 'TTS50.INI' and ini_section = @ps_sectionname and ini_item = @ps_Setting)
	update ini_master_tmw set ini_value = @ps_value, ini_description = @ps_description where ini_filename = 'TTS50.INI' and ini_section = @ps_sectionname and ini_item = @ps_Setting
GO
GRANT EXECUTE ON  [dbo].[modify_existing_setting_sp] TO [public]
GO
