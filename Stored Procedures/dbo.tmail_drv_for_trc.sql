SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_drv_for_trc]	@trc char(8),
					@drv char(8) OUT

AS

DECLARE @lgh int

SELECT @drv = ''	-- Initialize

IF (SELECT isnull(min(gi_string1), 'A') 
		FROM generalinfo (NOLOCK)
		WHERE gi_name = 'TMailTrcDrvBasis')<>'P'
BEGIN
	EXEC dbo.cur_activity 'TRC', @trc, @lgh OUT
	
	SELECT @drv = ISNULL (MIN (asgn_id ), '' )
	FROM assetassignment (NOLOCK)
	WHERE 	lgh_number = @lgh
	  AND	asgn_type = 'DRV'
	  AND	asgn_controlling = 'Y'
	  AND	@lgh > 0
	
END

IF @drv = ''
	SELECT @drv = isnull(trc_driver, '') 
	FROM tractorprofile (NOLOCK)
	WHERE trc_number = @trc

SELECT @drv

GO
GRANT EXECUTE ON  [dbo].[tmail_drv_for_trc] TO [public]
GO
