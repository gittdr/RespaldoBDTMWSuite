SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_lgh_number_sp_help] @tractor varchar(12)

AS

SET NOCOUNT ON 

/* 10/5/01 TD: Created to workaround Insert/Rowcount issue */
	SET ROWCOUNT 1

	SELECT lgh_number, lgh_OutStatus, lgh_startdate
	FROM legheader (NOLOCK)
	WHERE lgh_tractor = @tractor
	  AND lgh_outstatus IN ('DSP' ,'PLN')
	ORDER BY lgh_startdate

	SET ROWCOUNT 0 
GO
GRANT EXECUTE ON  [dbo].[tmail_get_lgh_number_sp_help] TO [public]
GO
