SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_routesync_AddBlobRecord] 
	@tractor		VARCHAR(8)		= NULL,
	@trailer		VARCHAR(13)		= NULL,
	@driver			VARCHAR(8)		= NULL,
	@move			INT,
	@leg			INT,
	@compliance		INT,
	@distance		DECIMAL (4,1),
	@managedBool	CHAR(1),
	@binary			VARBINARY(MAX)	= NULL,
	@dateCalculated DATETIME

AS
-- =============================================================================
--	Stored Proc:	[dbo].[tmail_routesync_AddBlobRecord]
--	Author     :	Abdullah Binghunaiem
--	Create date:	2015.09.30  - PTS 90589
--	Description:
--
--	Inserts RouteSync row with provided values
--
--	Change Log:
--	2015.09.30	-PTS90589	-AB:	Initial creations
--
--		
--	Returns:
--  NONE
--
-- =============================================================================

	INSERT INTO dbo.lgh_routesync 
	(
		trc_id,
		trl_id,
		mpp_id,
		mov_number,
		lgh_number,
		lrs_compliance,
		lrs_distance,
		lrs_managed,
		lrs_message,
		lrs_date_calculated
	)
	VALUES
	(
		@tractor,
		@trailer,
		@driver,
		@move,
		@leg,
		@compliance,
		@distance,
		@managedBool,
		@binary,
		@dateCalculated
	)
GO
GRANT EXECUTE ON  [dbo].[tmail_routesync_AddBlobRecord] TO [public]
GO
