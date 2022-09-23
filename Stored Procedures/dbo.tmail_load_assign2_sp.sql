SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_load_assign2_sp] 
	@order_number varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@lgh_Num varchar(12),
	@Flags varchar(22) 

AS
DECLARE @legFlags varchar(22)

IF ISNUMERIC(ISNULL(@flags, '')) = 0 
	Set @flags = '0';
	
Set @legFlags = CONVERT(varchar(22), Convert(bigint, @flags) ^ 2816);

EXEC dbo.tmail_GetLoadAssignmentLeg @order_number, @move, @tractor, '', @legFlags, @lgh_Num out;

EXEC dbo.tmail_load_assign3_sp 	@order_number, @move, @lgh_Num, @Flags;

GO
GRANT EXECUTE ON  [dbo].[tmail_load_assign2_sp] TO [public]
GO
