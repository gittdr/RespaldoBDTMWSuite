SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_OttUpdateTrailerProfileRec]
	@trl_id					AS VARCHAR(13),
	@trl_gps_desc			AS VARCHAR(255), 
	@trl_gps_date			AS DATETIME,
	@trl_gps_latitude		AS INT,
	@trl_gps_longitude		AS INT,
	@updatedBy				AS VARCHAR(20)

AS

-- =============================================================================
-- Stored Proc: tmail_OttUpdateTrailerProfileRec
-- Author     :	Sensabaugh, Virgil
-- Create date: 2014.03.25
-- Description:
--      This procedure will update the gps values on the trailerprofile record.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      Result set containing the applicable record.
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @trl_id				VARCHAR(13)
--		002 - @trl_gps_desc			VARCHAR(255) 
--		003 - @trl_gps_date			DATETIME
--		004 - @trl_gps_latitude		INT
--		005 - @trl_gps_longitude	INT
--		006 - @updatedBy			VARCHAR(20)
--
--      ------------------------------------------------------------------------
/*
Used for testing proc
EXEC 
*/
-- =============================================================================

BEGIN
	DECLARE @UpdatedOn				AS DATETIME
	SELECT @UpdatedOn = GETDATE()
	----------------------------------------------------------------------------
	-- Verify that the record to modified exists in trailerprofile table
	IF EXISTS( SELECT trl_id
			     FROM dbo.trailerprofile
			    WHERE trl_id = @trl_id)
		------------------------------------------------------------------------
		-- Record found for updating
		BEGIN

			UPDATE dbo.trailerprofile
			   SET trl_gps_desc			= @trl_gps_desc, 
			       trl_gps_date			= @trl_gps_date,
				   trl_gps_latitude		= @trl_gps_latitude,
				   trl_gps_longitude	= @trl_gps_longitude,
				   trl_updatedby		= @updatedBy,
				   trl_updateon			= @UpdatedOn
			WHERE 
				   trl_id = @trl_id

		END

END

GO
GRANT EXECUTE ON  [dbo].[tmail_OttUpdateTrailerProfileRec] TO [public]
GO
