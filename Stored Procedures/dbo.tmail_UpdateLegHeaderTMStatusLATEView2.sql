SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdateLegHeaderTMStatusLATEView2] @sLegNum Varchar(10), 
						    	   @sOrderNum Varchar(12), 
						    	   @sMoveNum Varchar(10), 
						    	   @sTractor varchar(13), 
								   @sOutStatus varchar(6),
								   @sLghFlags varchar(15),
								   @sNoOverride varchar(15)
AS

DECLARE	@lLegNum int,
		@lTourNum int,
		@lMoveNum int,
		@lLghFlags int,
		@lNoOverride int

SET @lLegNum = CONVERT(int, @sLegNum)
SET @lMoveNum = CONVERT(int, @sMoveNum)
SET @lLghFlags = 0
SET @lNoOverride = 0

IF (ISNULL(@sNoOverride, '') <> '')
	SET @lNoOverride = CONVERT(int, @sNoOverride)

IF (ISNULL(@sLghFlags,'') <> '')
	SET @lLghFlags = CONVERT(int, @sLghFlags)

-- Find the legheader if we don't have one
IF (ISNULL(@lLegNum,0) = 0)
  BEGIN
	EXEC dbo.tmail_GetLoadAssignmentLeg @sOrderNum, 
										@sMoveNum,
										@sTractor,
										'',
										@lLghFlags,
										@sLegNum OUT

	SET @lLegNum = CONVERT(int, @sLegNum)
  END

-- tmail_UpdateLegHeaderTMStatus3 will handle if @lLegNum is not set
EXEC dbo.tmail_UpdateLegHeaderTMStatus3 @lLegNum, 'LATE', @lNoOverride

GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateLegHeaderTMStatusLATEView2] TO [public]
GO
