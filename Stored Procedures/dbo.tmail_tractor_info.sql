SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_tractor_info] (@trc_id varchar(8)) 

AS

SET NOCOUNT ON 

SELECT @trc_id TractorID, trc_driver Driver1, trc_driver2 Driver2, trc_useGeofencing UseGeofencing, trc_division Division, trc_terminal
FROM tractorprofile (NOLOCK)
WHERE trc_number = @trc_id

GO
GRANT EXECUTE ON  [dbo].[tmail_tractor_info] TO [public]
GO
