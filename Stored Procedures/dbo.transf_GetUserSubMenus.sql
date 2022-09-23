SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_GetUserSubMenus]
	(
		@transf_user_id int
		,@brn_id varchar(12)	--comman delimited list
		,@parent_menu_id int
	)
AS

set nocount on
	SELECT distinct m.* 
	FROM	transf_MenuItem AS m 
		JOIN transf_MenuGroups AS mg ON m.menu_id = mg.menu_id 
			and mg.group_id in 
			(
				select group_id
				from transf_UserGroups
				where transf_user_id = @transf_user_id
			)
		JOIN transf_MenuBranches AS mb ON m.menu_id = mb.menu_id
			and mb.brn_id in 
			(
				select brn_id
				from transf_UserBranches
				where transf_user_id = @transf_user_id
					and (brn_id=@brn_id or brn_id =isnull(@brn_id, brn_id))
			)
	WHERE   parent_menu_id = @parent_menu_id
	order by m.sequence

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_GetUserSubMenus] TO [public]
GO
