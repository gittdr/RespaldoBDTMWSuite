SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_AddUserBranches]
	(
		@transf_user_id int,
		@brn_ids varchar(8000)	--comman delimited list
	)
AS

set nocount on
	--delete the branches for the  User id then insert new ones
	delete from transf_UserBranches where transf_user_id = @transf_user_id
	
	insert into transf_UserBranches (transf_user_id, brn_id, create_dt, edit_dt)
		select	@transf_user_id, brn_id, getdate(), getdate()
		from	branch
		where	brn_id <> 'UNKNOWN'
			and (brn_id in (select convert(varchar(12), value) from transf_parseListToTable (@brn_ids, ','))
				or @brn_ids = '*'
			)

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_AddUserBranches] TO [public]
GO
