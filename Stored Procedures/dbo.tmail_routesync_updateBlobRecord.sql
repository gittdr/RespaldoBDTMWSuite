SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_routesync_updateBlobRecord] 
	@lrs_id INT,
	@DateTimeSent SMALLDATETIME = NULL,
	@ResponseCode INT = NULL,
	@ErrorText VARCHAR(500) = NULL,
	@ErrorDateTime SMALLDATETIME = NULL,
	@OmnitracsKey VARCHAR(50) = NULL,	--PTS71605
	@Status INT = NULL					--PTS71605
AS
-- =============================================================================
--	Stored Proc:	[dbo].[tmail_routesync_updateBlobRecord]
--	Author     :	Rob Scott
--	Create date:	2013.02.22  - PTS 63996
--	Description:
--
--	Updates RouteSync row with provided values
--
--	Change Log:
--	2013.10.21	-PTS71605	-RRS:	added support for Omnitracs RouteSync by
--
--		
--	Returns:
--  ROWCOUNT including number of affected records
--
-- =============================================================================

	BEGIN
		SET NOCOUNT OFF

		UPDATE dbo.lgh_routesync 
		SET lrs_date_sent		= @DateTimeSent,
			lrs_response_code	= @ResponseCode,
			lrs_error_text		= @ErrorText,
			lrs_error_date		= @ErrorDateTime,
			lrs_omnitracs_key	= @OmnitracsKey,	--PTS71605
			lrs_status			= @Status			--PTS71605
		WHERE lrs_id = @lrs_id 

		RETURN @@ROWCOUNT
	END
GO
GRANT EXECUTE ON  [dbo].[tmail_routesync_updateBlobRecord] TO [public]
GO
