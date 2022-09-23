SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_trc_for_drv]	@drv char(8),
					@trc char(8) OUT

AS

SET NOCOUNT ON 

DECLARE @lgh int

SELECT @trc = ''	-- Initialize

EXEC dbo.cur_activity 'DRV', @drv, @lgh OUT

SELECT @trc = ISNULL (MIN (asgn_id ), '' )
FROM assetassignment (NOLOCK)
WHERE 	lgh_number = @lgh
  AND	asgn_type = 'TRC'
  AND	asgn_controlling = 'Y'
  AND	@lgh > 0

IF @trc = ''
	SELECT @trc = isnull(mpp_tractornumber, '') FROM manpowerprofile WHERE mpp_id = @drv

SELECT @trc

GO
GRANT EXECUTE ON  [dbo].[tmail_trc_for_drv] TO [public]
GO
