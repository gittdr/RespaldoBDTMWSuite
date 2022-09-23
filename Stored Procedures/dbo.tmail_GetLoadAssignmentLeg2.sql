SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/* 09/11/02 MZ:  Created   */

CREATE PROCEDURE [dbo].[tmail_GetLoadAssignmentLeg2]
	@order varchar(12),
	@move varchar(12),
	@tractor varchar(12),
	@driver varchar(12),
	@flags varchar(22),
	@TMStatus varchar(500),
	@lgh varchar(12) OUT
AS
	EXEC dbo.tmail_GetLoadAssignmentLeg3 @order, @move, @tractor, @driver, @flags, @TMStatus, @lgh OUT, ''
GO
GRANT EXECUTE ON  [dbo].[tmail_GetLoadAssignmentLeg2] TO [public]
GO
