SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_load_assign3_sp] 
	@order_number varchar(12),
	@move varchar(12),
	@lgh_Num varchar(12),
	@Flags varchar(22)

AS
-- 8/27/02 MZ: Created tmail_load_assign3_sp 
-- 3/15/06 CH: added TMStatus and leg_outstatus fields
-- 9/07/06 DWG: Called tmail_load_assign4_sp 

EXEC tmail_load_assign4_sp @order_number, @move, @lgh_Num, @Flags, "0", "0", "0"

GO
GRANT EXECUTE ON  [dbo].[tmail_load_assign3_sp] TO [public]
GO
