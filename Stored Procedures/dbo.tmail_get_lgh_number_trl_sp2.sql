SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_lgh_number_trl_sp2]
	@order_number varchar(12),
	@move varchar(12),
	@tractor varchar(13),
	@flags varchar(11),
	@lgh_num varchar(12) OUT

AS
	DECLARE @TMStatus varchar(500)
	SELECT @TMStatus = ''
	exec dbo.tmail_get_lgh_number_trl_sp
		@order_number,
		@move,
		@tractor,
		@flags,
		@TMStatus,
		@lgh_num OUT,
		''

GRANT EXECUTE ON dbo.tmail_get_lgh_number_trl_sp2 TO PUBLIC
GO
