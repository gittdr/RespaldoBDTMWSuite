SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_get_lgh_number_DRV_sp_help] @DriverID varchar(8)

AS

SET NOCOUNT ON 

/* 10/5/01 TD: Created to workaround Insert/Rowcount issue */
	SET ROWCOUNT 1

	SELECT lgh_number, lgh_OutStatus, lgh_startdate
	FROM legheader (NOLOCK)
	WHERE (lgh_Driver1 = @DriverID OR lgh_Driver2 = @DriverID)
	  AND lgh_outstatus IN ('DSP' ,'PLN')
	ORDER BY lgh_startdate

	SET ROWCOUNT 0 
GO
GRANT EXECUTE ON  [dbo].[tmail_get_lgh_number_DRV_sp_help] TO [public]
GO
