SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_load_assign4_sp] 
	@order_number varchar(12),
	@move varchar(12),
	@lgh_Num varchar(12),
	@Flags varchar(22),
    @sTargetTZ varchar(3),
    @sTargetTZDSTCode varchar(2),
    @sTargetTZMin varchar(2)

AS

-- 07/11/07 DWG: Created tmail_load_assign5_sp 

exec tmail_load_assign5_sp 
	@order_number,
	@move,
	@lgh_Num,
	@Flags,
    @sTargetTZ,
    @sTargetTZDSTCode,
    @sTargetTZMin,
	'',
	''
GO
GRANT EXECUTE ON  [dbo].[tmail_load_assign4_sp] TO [public]
GO
