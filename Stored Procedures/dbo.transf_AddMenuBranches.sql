SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_AddMenuBranches]
	(
		@menu_id int,
		@brn_ids varchar(8000)	--comman delimited list
	)
AS

set nocount on
	--delete the branches for the  menu id then insert new ones
	delete from transf_MenuBranches where menu_id = @menu_id
	
	insert into transf_MenuBranches (menu_id, brn_id, create_dt, edit_dt)
		select	@menu_id, brn_id, getdate(), getdate()
		from	branch
		where	brn_id <> 'UNKNOWN'
			and (brn_id in (select convert(varchar(12), value) from transf_parseListToTable (@brn_ids, ','))
				or @brn_ids = '*'
			)

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_AddMenuBranches] TO [public]
GO
