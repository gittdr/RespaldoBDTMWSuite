SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetLoadAssignmentLeg] 
	@order varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@driver varchar(12),
	@flags varchar(11),
	@lgh varchar(12) OUT
AS

	DECLARE @TMStatus varchar(500)
	SET @TMStatus = ''

	EXEC dbo.tmail_GetLoadAssignmentLeg2 @order, @move, @tractor, @driver, @flags, @TMStatus, @lgh OUT

GO
GRANT EXECUTE ON  [dbo].[tmail_GetLoadAssignmentLeg] TO [public]
GO
