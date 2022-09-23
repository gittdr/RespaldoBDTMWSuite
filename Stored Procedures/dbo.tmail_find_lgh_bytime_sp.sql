SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_find_lgh_bytime_sp]
	@p_tractor varchar(8),
	@p_startdate varchar(30),
	@p_enddate varchar(30),
 	@p_which_lgh varchar(6)
AS

declare @ret int

exec @ret = dbo.tmail_find_lgh_bytime_sp2 @p_tractor, @p_startdate, @p_enddate, @p_which_lgh, null

RETURN @ret

GO
GRANT EXECUTE ON  [dbo].[tmail_find_lgh_bytime_sp] TO [public]
GO
