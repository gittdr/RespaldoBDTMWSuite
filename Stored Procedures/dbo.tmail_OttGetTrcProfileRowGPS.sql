SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_OttGetTrcProfileRowGPS]
	@trc_id				VARCHAR(13)

AS

-- =============================================================================
-- Stored Proc: tmail_OttGetTrcProfileRowGPS
-- Author     :	Rwolfe (based off proc by Sensabaugh, Virgil)
-- Create date: 2014.04.01
-- Description:
--      This procedure will pull the desired tractorprofile record with gps data.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      Result set containing the applicable record.
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @trc_id			VARCHAR(13)
--
--
--      ------------------------------------------------------------------------
/*
Used for testing proc
EXEC 
*/
-- =============================================================================

BEGIN 

	SELECT 
		ISNULL(trc_gps_desc, '') AS trl_gps_desc,
		ISNULL(trc_gps_date, '19500101 00:01') AS trl_gps_date,
		ISNULL(trc_gps_latitude, 0) AS trl_gps_latitude,
		ISNULL(trc_gps_longitude, 0) AS trl_gps_longitude
	FROM dbo.tractorprofile (NOLOCK)
	WHERE trc_number = @trc_id

	-- If no records are found and empty dataset will be returned.
	
END	

GO
GRANT EXECUTE ON  [dbo].[tmail_OttGetTrcProfileRowGPS] TO [public]
GO
