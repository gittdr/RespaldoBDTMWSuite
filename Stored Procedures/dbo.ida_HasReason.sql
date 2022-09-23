SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


create proc [dbo].[ida_HasReason] (
	@lgh_number int
) as

If exists (select * from ida_Override (nolock) where lgh_number = @lgh_number)
	Select 1
ELSE
	Select 0

GO
GRANT EXECUTE ON  [dbo].[ida_HasReason] TO [public]
GO
