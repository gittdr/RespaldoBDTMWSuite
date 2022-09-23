SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_OttUpdateTractorProfileRec]
	@trc_id					AS VARCHAR(13),
	@trc_gps_desc			AS VARCHAR(255), 
	@trc_gps_date			AS DATETIME,
	@trc_gps_latitude		AS INT,
	@trc_gps_longitude		AS INT,
	@updatedBy				AS VARCHAR(20)

AS

-- =============================================================================
-- Stored Proc: tmail_OttUpdateTractorProfileRec
-- Author     :	RWolfe (based off proc by Sensabaugh, Virgil)
-- Create date: 2014.04.01
-- Description:
--      This procedure will update the gps values on the tractorprofile record.
--      
--      Outputs:
--      ------------------------------------------------------------------------
--      Result set containing the applicable record.
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @trc_id				VARCHAR(13)
--		002 - @trc_gps_desc			VARCHAR(255) 
--		003 - @trc_gps_date			DATETIME
--		004 - @trc_gps_latitude		INT
--		005 - @trc_gps_longitude	INT
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
	-- Verify that the record to modified exists in tractorprofile table
	IF EXISTS( SELECT trc_number
			     FROM dbo.tractorprofile
			    WHERE trc_number = @trc_id)
		------------------------------------------------------------------------
		-- Record found for updating
		BEGIN

			UPDATE dbo.tractorprofile
			   SET trc_gps_desc			= @trc_gps_desc, 
			       trc_gps_date			= @trc_gps_date,
				   trc_gps_latitude		= @trc_gps_latitude,
				   trc_gps_longitude	= @trc_gps_longitude,
				   trc_updatedby		= @updatedBy,
				   trc_updatedon		= @UpdatedOn
			WHERE 
				   trc_number = @trc_id

		END

END

GO
GRANT EXECUTE ON  [dbo].[tmail_OttUpdateTractorProfileRec] TO [public]
GO
