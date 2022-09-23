SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_AddMenuGroups]
	(
		@menu_id int,
		@group_names varchar(8000)	--comman delimited list
	)
AS

set nocount on
	--delete the Groups for the  menu id then insert new ones
	delete from transf_MenuGroups where menu_id = @menu_id
	
	insert into transf_MenuGroups (menu_id, group_id, create_dt, edit_dt)
		select	@menu_id, group_id, getdate(), getdate()
		from	transf_groups
		where	group_name <> 'UNKNOWN'
			and (group_name in (select convert(varchar(20), value) from transf_parseListToTable (@group_names, ','))
				or @group_names = '*'
			)

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_AddMenuGroups] TO [public]
GO
