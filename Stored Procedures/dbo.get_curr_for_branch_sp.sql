SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create Procedure [dbo].[get_curr_for_branch_sp] (@BrnchId  varchar(12))
AS
	Select brn_arcurrency
	From branch
	Where brn_id = @BrnchId

GO
GRANT EXECUTE ON  [dbo].[get_curr_for_branch_sp] TO [public]
GO
