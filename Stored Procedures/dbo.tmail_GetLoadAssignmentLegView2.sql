SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetLoadAssignmentLegView2]
	@order varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@driver varchar(12),
	@flags varchar(22),
	@TMStatus varchar(500),
	@lgh varchar(12) OUT

AS

DECLARE @WorkFlags bigint = 4096 + 1048576

	IF ISNUMERIC(@flags) <> 0
		SET @WorkFlags = (CONVERT(bigint, @flags) | 4096) ^ 1048576
	SET @flags = CONVERT(varchar(22), @WorkFlags)

	EXEC dbo.tmail_GetLoadAssignmentLeg2 @order, @move, @tractor, @driver, @WorkFlags, @TMStatus, @lgh OUT
GO
GRANT EXECUTE ON  [dbo].[tmail_GetLoadAssignmentLegView2] TO [public]
GO
