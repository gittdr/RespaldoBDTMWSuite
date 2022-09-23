SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetLoadAssignmentLegView3]
	@order varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@driver varchar(12),
	@flags varchar(22),
	@TMStatus varchar(500),
	@lgh varchar(12) OUT,
	@SearchStatuses varchar(20)
AS

DECLARE @WorkFlags bigint = 4096 + 1048576

	IF ISNUMERIC(@flags)<> 0
		SET @WorkFlags =(CONVERT(bigint, @flags) | 4096) ^ 1048576
	Set @flags = Convert(varchar(22), @WorkFlags)

	EXEC tmail_GetLoadAssignmentLeg3 @order, @move, @tractor, @driver, @flags, @TMStatus, @lgh OUT, @SearchStatuses
GO
GRANT EXECUTE ON  [dbo].[tmail_GetLoadAssignmentLegView3] TO [public]
GO
