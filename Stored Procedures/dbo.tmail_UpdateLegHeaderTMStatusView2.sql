SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_UpdateLegHeaderTMStatusView2] @sLegNum Varchar(10), 
						    	   @sOrderNum Varchar(12), 
						    	   @sMoveNum Varchar(10), 
						    	   @sTractor varchar(13), 
								   @sOutStatus varchar(6),
								   @sLghFlags varchar(15),
								   @sNoOverride varchar(15),	-- See definition in tmail_updatelegheadertmstatusview
								   @sFlags varchar(12)
AS

DECLARE	@lLegNum int,
		@lTourNum int,
		@lMoveNum int,
		@lLghFlags int,
		@lNoOverride int,
		@lFlags int

SET @lLegNum = CONVERT(int, @sLegNum)
SET @lMoveNum = CONVERT(int, @sMoveNum)
SET @lLghFlags = 0
SET @lNoOverride = 0
SET @lMoveNum = CONVERT(int, @sFlags)

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

IF (ISNULL(@lLegNum,0) = 0)
  BEGIN
	RAISERROR ('No current activity found for tractor.  TMStatus could not be updated to %s.', 15, 1, @sOutStatus)
	RETURN
  END

-- tmail_UpdateLegHeaderTMStatus3 will handle if @lLegNum is not set
EXEC dbo.tmail_UpdateLegHeaderTMStatus4 @lLegNum, @sOutStatus, @lNoOverride, @sFlags

GO
GRANT EXECUTE ON  [dbo].[tmail_UpdateLegHeaderTMStatusView2] TO [public]
GO
