SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_lgh_number_sp] 
	@order_number varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@lgh_num varchar(12) OUT

AS

SET NOCOUNT ON 

	DECLARE @flags varchar(11)
	SELECT @flags = CONVERT(varchar(11), 256+524288)
	exec dbo.tmail_get_lgh_number_sp2
		@order_number,
		@move,
		@tractor,
		@flags,
		@lgh_num OUT
GO
GRANT EXECUTE ON  [dbo].[tmail_get_lgh_number_sp] TO [public]
GO
