SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_chk_trc_drv]	@trc varchar(13),
					@drv varchar(8)

AS

SET NOCOUNT ON 

/* 10/21/98 TD: Created to allow easy checking of entered Tractors/
	Drivers by TotalMail Stored Procs. */

DECLARE @lgh int
DECLARE @lgh2 int
DECLARE @sT_1 varchar(200) --Translation string

EXEC dbo.cur_activity 'DRV', @drv, @lgh out
EXEC dbo.cur_activity 'TRC', @trc, @lgh2 out

IF ISNULL(@lgh,-1) <> ISNULL(@lgh2,-2)
	BEGIN
	SELECT @sT_1 = '{TMWERR:1034}Driver %s is not currently driving tractor %s.'
--	EXEC dbo.tm_t_sp @sT_1 out, 1, ''
	RAISERROR (@sT_1,16,-1,@drv,@trc)
	RETURN 1
	END
RETURN 0
GO
GRANT EXECUTE ON  [dbo].[tmail_chk_trc_drv] TO [public]
GO
