SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetLoadAssignmentLegs]
	@order varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@driver varchar(12),
	@TMStatus varchar(500),
	@SearchStatuses varchar(20),
	@flags varchar(22)
AS

DECLARE @WorkFlags bigint = 4096 + 1048576,
		@lgh bigint

	IF ISNUMERIC(@flags) <> 0
		SET @WorkFlags = (CONVERT(bigint, @flags) | 4096) ^ 1048576

	SET @WorkFlags = @WorkFlags | 134217728  --add Return All Legs flag
	set @flags = CONVERT(Varchar(22), @WorkFlags)

	EXEC dbo.tmail_GetLoadAssignmentLeg3 @order, @move, @tractor, @driver, @flags, @TMStatus, @lgh OUT, @SearchStatuses

GO
GRANT EXECUTE ON  [dbo].[tmail_GetLoadAssignmentLegs] TO [public]
GO
