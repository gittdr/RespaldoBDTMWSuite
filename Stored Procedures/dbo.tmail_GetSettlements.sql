SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_GetSettlements]   @sPayPeriod varchar(25),
					@AssignId varchar(13),
					@AssignType varchar(6),
					@Collected char(1),
					@PayStatus varchar(6)

AS


EXEC dbo.tmail_GetSettlements2 @SPayPeriod, @AssignID, @AssignType, @Collected, @PayStatus, ''
--added MoveNumber PTS 22135

GO
GRANT EXECUTE ON  [dbo].[tmail_GetSettlements] TO [public]
GO
