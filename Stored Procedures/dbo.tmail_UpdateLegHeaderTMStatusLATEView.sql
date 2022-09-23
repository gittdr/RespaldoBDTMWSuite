SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdateLegHeaderTMStatusLATEView] @sLegNum Varchar(10), 
						    	   @sOrderNum Varchar(12), 
						    	   @sMoveNum Varchar(10), 
						    	   @sTractor varchar(13), 
								   @sOutStatus varchar(6)
AS

DECLARE	@lLegNum int,
	@lTourNum int,
	@lMoveNum int

SET @lLegNum = CONVERT(int, @sLegNum)
SET @lMoveNum = CONVERT(int, @sMoveNum)

-- Find the legheader if we don't have one
IF (ISNULL(@lLegNum,0) = 0)
  BEGIN
	EXEC dbo.tmail_GetLoadAssignmentLeg @sOrderNum, 
										@sMoveNum,
										@sTractor,
										'',
										0,			-- GetLegHeader flags.  NEEDS TO BE SET PER CUSTOMER.
										@sLegNum OUT

	SET @lLegNum = CONVERT(int, @sLegNum)
  END

-- tmail_UpdateLegHeaderTMStatus2 will handle if @lLegNum is not set
EXEC dbo.tmail_UpdateLegHeaderTMStatus2 @lLegNum, 'LATE'

GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateLegHeaderTMStatusLATEView] TO [public]
GO
