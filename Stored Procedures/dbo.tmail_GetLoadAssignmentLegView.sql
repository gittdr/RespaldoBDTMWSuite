SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetLoadAssignmentLegView]
	@order varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@driver varchar(12),
	@flags varchar(22),
	@lgh varchar(12) OUT

AS

	DECLARE @TMStatus as varchar(500)
	SET @TMStatus = ''
	
	EXEC dbo.tmail_GetLoadAssignmentLegView2 @order, @move, @tractor, @driver, @flags, @TMStatus, @lgh OUT
GO
GRANT EXECUTE ON  [dbo].[tmail_GetLoadAssignmentLegView] TO [public]
GO
