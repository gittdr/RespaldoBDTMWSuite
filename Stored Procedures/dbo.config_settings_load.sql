SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[config_settings_load] @userid varchar (20), @role varchar (8)
	AS 
BEGIN
SET NOCOUNT ON
DECLARE @results TABLE 
	(
	con_id			integer not null primary key,
	con_file		varchar (10) not null,
	con_section		varchar (30) not null, 
	con_key			varchar (255) not null, 
	con_value		varchar (1000) not null, 
	con_sort		integer not null
	)

INSERT INTO @results 
	SELECT con_id, con_file, con_section, con_key, con_value, 1
		FROM config_settings
		WHERE con_userid = @userid and con_role = @role

if @role <> 'UNK'
	INSERT INTO @results
		SELECT con_id, con_file, con_section, con_key, con_value, 2
			FROM config_settings
			WHERE ISNull (con_userid, '') = '' and con_role = @role
		
INSERT INTO @results
	SELECT con_id, con_file, con_section, con_key, con_value, 3
		FROM config_settings
		WHERE IsNull (con_userid, '') = '' and con_role = 'UNK'
		
SELECT con_id, con_file, con_section, con_key, con_value, con_sort 
 FROM @results x
 WHERE con_id = (select top 1 r.con_id
			from @results r
			where r.con_section = x.con_section
			and r.con_file = x.con_file
			and r.con_key  = x.con_key
			ORDER BY r.con_sort )
ORDER BY con_file, con_section, con_key

END
GO
GRANT EXECUTE ON  [dbo].[config_settings_load] TO [public]
GO
