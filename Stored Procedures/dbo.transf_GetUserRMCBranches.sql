SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_GetUserRMCBranches]
	(
		@transf_user_id int
		, @rmf_rm_name varchar(20)
	)
AS

set nocount on
	SELECT  b.brn_id
		, brn_name
		, rmf_value
		, rmf_name
	FROM    branch b 
		JOIN (select * from transf_UserBranches where transf_user_id = @transf_user_id)ub
			ON b.brn_id = ub.brn_id
		left outer join (select * from transf_RMFilter where transf_user_id = @transf_user_id and rmf_rm_name=@rmf_rm_name and rmf_name = 'BRANCH') r
			on r.rmf_value = b.brn_id 
	WHERE     (ub.transf_user_id = @transf_user_id)
	order by b.brn_id

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_GetUserRMCBranches] TO [public]
GO
