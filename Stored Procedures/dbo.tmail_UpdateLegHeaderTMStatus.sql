SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdateLegHeaderTMStatus] 	@lLegNum int, 
							@lTourNum int,
						    @sOrderNum varchar(12), 
						    @lMoveNum int, 
						    @sTractor varchar(13), 
							@sOutStatus varchar(6),
					    	@sNewStatus varchar(6)

AS

EXEC dbo.tmail_UpdateTMStatus @lLegNum, @lTourNum, @sOrderNum, @lMoveNum, @sTractor, 0, @sOutStatus, @sNewStatus, 0
GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateLegHeaderTMStatus] TO [public]
GO
