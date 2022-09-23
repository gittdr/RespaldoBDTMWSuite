SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_lgh_number_sp3]
	@order_number varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@flags varchar(22),
	@TMStatus varchar(500),
	@lgh_num varchar(12) OUT

AS

SET NOCOUNT ON 

exec dbo.tmail_get_lgh_number_sp4 @order_number, @move, @tractor, @flags, @TMStatus, @lgh_num out, ''
GO
GRANT EXECUTE ON  [dbo].[tmail_get_lgh_number_sp3] TO [public]
GO
