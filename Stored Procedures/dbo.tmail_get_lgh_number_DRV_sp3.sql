SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_lgh_number_DRV_sp3] 
	@order_number varchar(12),
	@move varchar(12),
	@DriverID varchar(8),
	@flags varchar(22),
	@TMStatus varchar(500),
	@lgh_num varchar(12) OUT

AS
	exec dbo.tmail_get_lgh_number_DRV_sp4
		@order_number,
		@move,
		@DriverID,
		@flags,
		@TMStatus,
		@lgh_num OUT,
		''
GO
GRANT EXECUTE ON  [dbo].[tmail_get_lgh_number_DRV_sp3] TO [public]
GO
