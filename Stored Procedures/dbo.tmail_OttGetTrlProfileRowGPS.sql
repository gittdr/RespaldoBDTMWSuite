SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_OttGetTrlProfileRowGPS]
	@trl_id				VARCHAR(13)

AS

-- =============================================================================
-- Stored Proc: tmail_OttGetTrlProfileRowGPS
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.03.25
-- Description:
--      This procedure will pull the desired trailerprofile record with gps data.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      Result set containing the applicable record.
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @trl_id			VARCHAR(13)
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
		ISNULL(trl_gps_desc, '') AS trl_gps_desc,
		ISNULL(trl_gps_date, '19500101 00:01') AS trl_gps_date,
		ISNULL(trl_gps_latitude, 0) AS trl_gps_latitude,
		ISNULL(trl_gps_longitude, 0) AS trl_gps_longitude
	FROM trailerprofile (NOLOCK)
	WHERE trl_id = @trl_id

	-- If no records are found and empty dataset will be returned.
	
END	

GO
GRANT EXECUTE ON  [dbo].[tmail_OttGetTrlProfileRowGPS] TO [public]
GO
