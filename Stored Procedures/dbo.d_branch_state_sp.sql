SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_branch_state_sp    Script Date: 6/1/99 11:54:09 AM ******/
create PROCEDURE [dbo].[d_branch_state_sp] (@BranchId	varchar(12))
AS
	select 	branch.brn_state_c 
	from 	branch
	where	branch.brn_id = @BranchId


GO
GRANT EXECUTE ON  [dbo].[d_branch_state_sp] TO [public]
GO
