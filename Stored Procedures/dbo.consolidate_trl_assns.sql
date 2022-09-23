SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[consolidate_trl_assns] @mov int AS
DECLARE @minasgn int,
	@id char (13),
	@start_asgn int,
	@start_mfh int,
	@start_stop int,
	@end_asgn int,
	@end_mfh int,
	@end_stop int,
	@check_asgn int,
	@check_mfh int,
	@check_stop int,
	@check_asgn_status int,
	@check_succeeded int
-- Clear all current consolidations.
UPDATE assetassignment 
	SET asgn_trl_first_asgn = 0, 
		asgn_trl_last_asgn = 0 
	FROM stops 
	WHERE stops.lgh_number = assetassignment.lgh_number AND 
		stops.mov_number = @mov AND
		assetassignment.asgn_type = 'TRL'

WHILE ( SELECT COUNT(*) FROM assetassignment, stops
	WHERE stops.lgh_number = assetassignment.lgh_number AND 
		stops.mov_number = @mov AND
		assetassignment.asgn_type = 'TRL' AND
		assetassignment.asgn_trl_first_asgn = 0 AND
		ISNULL(assetassignment.asgn_id, '') <> '') > 0
BEGIN
	-- Find an undone assignment.
	SELECT @minasgn = MIN ( asgn_number )
	FROM assetassignment, stops
	WHERE stops.lgh_number = assetassignment.lgh_number AND 
		stops.mov_number = @mov AND
		assetassignment.asgn_type = 'TRL' AND
		assetassignment.asgn_trl_first_asgn = 0 AND
		ISNULL(assetassignment.asgn_id, '') <> ''
	-- Collect info from this assignment.
	SELECT 	@id = MIN ( asgn_id ),
		@start_asgn = @minasgn ,
		@end_asgn = @minasgn ,
		@start_mfh = MIN ( stp_mfh_sequence ),
		@end_mfh = MAX ( stp_mfh_sequence )
	FROM assetassignment, stops, event
	WHERE asgn_number = @minasgn AND
		stops.lgh_number = assetassignment.lgh_number AND
		stops.stp_number = event.stp_number AND
		( event.evt_trailer1 = assetassignment.asgn_id OR
			event.evt_trailer2 = assetassignment.asgn_id )

	-- Look for prior assignments to consolidate with.
	WHILE 1 = 1
	BEGIN
		-- Get current starting stop number for the trailer.
		SELECT @start_stop = stp_number
		FROM stops
		WHERE mov_number = @mov AND
			stp_mfh_sequence = @start_mfh

		SELECT @check_mfh = 0

		SELECT @check_mfh = MAX ( stp_mfh_sequence )
		FROM stops, event
		WHERE stops.mov_number = @mov AND
			stops.stp_mfh_sequence < @start_mfh AND
			stops.stp_number = event.stp_number AND
			( event.evt_trailer1 = @id OR
				event.evt_trailer2 = @id )

		if isnull( @check_mfh, 0 ) = 0
			BREAK	-- No more prior activity, save what we've found.

		-- Found a prior assignment for this trailer, check if it's already done.
		SELECT @check_asgn = asgn_number,
			@check_stop = stp_number,
			@check_asgn_status = asgn_trl_first_asgn
		FROM stops, assetassignment
		WHERE stops.mov_number = @mov AND
			stops.stp_mfh_sequence = @check_mfh AND
			stops.lgh_number = assetassignment.lgh_number AND
			asgn_type = 'TRL' AND
			asgn_id = @id
		IF isnull(@check_asgn_status, -1) = -1
			BREAK	-- Assetassignment missing for some reason.  Don't let
				-- 	this condition confuse the stored proc.
		IF @check_asgn_status > 0
			BREAK 	-- Prior activity already checked, so can't be with this.

		-- Prior activity is not already checked, so let's check it now.
		SELECT @check_succeeded = 0	-- assume check fails.

		-- Does the current assignment start loaded?
		IF ( SELECT COUNT( evt_number )
			FROM event
			WHERE event.stp_number = @start_stop AND
				event.evt_eventcode = 'HLT'  AND
				( event.evt_trailer1 = @id OR
					event.evt_trailer2 = @id )
			) > 0
		BEGIN
			-- Starts with an HLT
			IF ( SELECT COUNT( evt_number )
			FROM event
			WHERE event.stp_number = @start_stop AND
				event.evt_eventcode = 'PLD'  AND
				( event.evt_trailer1 = @id OR
					event.evt_trailer2 = @id )
			) = 0
			BEGIN
				-- and there is no preload, so the trailer is starting loaded.
				SELECT @check_succeeded = 1
			END
		END

		IF @check_succeeded = 0	
		BEGIN
			-- Current legheader does not start loaded.
			-- Does the prior one end loaded?
			IF ( SELECT COUNT( evt_number )
				FROM event
				WHERE event.stp_number = @check_stop AND
					event.evt_eventcode = 'DLT'  AND
					( event.evt_trailer1 = @id OR
						event.evt_trailer2 = @id )
				) > 0
			BEGIN
				-- It ends with an HLT
				IF ( SELECT COUNT( evt_number )
				FROM event
				WHERE event.stp_number = @check_stop AND
					event.evt_eventcode = 'PUL'  AND
					( event.evt_trailer1 = @id OR
						event.evt_trailer2 = @id )
				) = 0
				BEGIN
					-- and No post unload, so the trailer is ending loaded.
					SELECT @check_succeeded = 1
				END
			END
		END
		
		IF @check_succeeded = 0
			BREAK	-- Check failed, don't consolidate.
		
		-- This can be consolidated.  Change start info accordingly.
		SELECT @start_asgn = @check_asgn,
			@start_mfh = MIN ( stp_mfh_sequence )
		FROM assetassignment, stops, event
		WHERE asgn_number = @check_asgn AND
			stops.lgh_number = assetassignment.lgh_number AND
			stops.stp_number = event.stp_number AND
			( event.evt_trailer1 = assetassignment.asgn_id OR
				event.evt_trailer2 = assetassignment.asgn_id )
		
		-- Now repeat prior legheader check.
	END

	-- Done with prior legheaders, now look for later ones.
	WHILE 1 = 1
	BEGIN
		-- Get current ending stop number for the trailer.
		SELECT @end_stop = stp_number
		FROM stops
		WHERE mov_number = @mov AND
			stp_mfh_sequence = @end_mfh

		SELECT @check_mfh = MIN ( stp_mfh_sequence )
		FROM stops, event
		WHERE stops.mov_number = @mov AND
			stops.stp_mfh_sequence > @end_mfh AND
			stops.stp_number = event.stp_number AND
			( event.evt_trailer1 = @id OR
				event.evt_trailer2 = @id )

		if isnull( @check_mfh, 0 ) = 0
			BREAK	-- No more later activity, save what we've found.

		-- Found a later assignment for this trailer, check if it's already done.
		SELECT @check_asgn = asgn_number,
			@check_stop = stp_number,
			@check_asgn_status = asgn_trl_first_asgn
		FROM stops, assetassignment
		WHERE stops.mov_number = @mov AND
			stops.stp_mfh_sequence = @check_mfh AND
			stops.lgh_number = assetassignment.lgh_number AND
			asgn_type = 'TRL' AND
			asgn_id = @id
		IF isnull(@check_asgn_status, -1) = -1
			BREAK	-- Assetassignment missing for some reason.  Don't let
				-- 	this condition confuse the stored proc.
		IF @check_asgn_status > 0
			BREAK 	-- Later activity already checked, so can't be with this.

		-- Later activity not already checked, so let's check it now.
		SELECT @check_succeeded = 0	-- assume check fails.

		-- Does the later assignment start loaded?
		IF ( SELECT COUNT( evt_number )
		FROM event
		WHERE event.stp_number = @check_stop AND
			event.evt_eventcode = 'HLT'  AND
			( event.evt_trailer1 = @id OR
				event.evt_trailer2 = @id )
		) > 0
		BEGIN
			-- Starts with an HLT
			IF ( SELECT COUNT( evt_number )
			FROM event
			WHERE event.stp_number = @check_stop AND
				event.evt_eventcode = 'PLD'  AND
				( event.evt_trailer1 = @id OR
					event.evt_trailer2 = @id )
			) = 0
			BEGIN
				-- and there is no preload, so the trailer is starting loaded.
				SELECT @check_succeeded = 1
			END
		END

		IF @check_succeeded = 0	
		BEGIN
			-- Later legheader does not start loaded.
			-- Does the current one end loaded?
			IF ( SELECT COUNT( evt_number )
			FROM event
			WHERE event.stp_number = @end_stop AND
				event.evt_eventcode = 'DLT'  AND
				( event.evt_trailer1 = @id OR
					event.evt_trailer2 = @id )
			) > 0
			BEGIN
				-- It ends with an HLT
				IF ( SELECT COUNT( evt_number )
				FROM event
				WHERE event.stp_number = @end_stop AND
					event.evt_eventcode = 'PUL'  AND
					( event.evt_trailer1 = @id OR
						event.evt_trailer2 = @id )
				) = 0
				BEGIN
					-- and post unload, so the trailer is ending loaded.
					SELECT @check_succeeded = 1
				END
			END
		END
		
		IF @check_succeeded = 0
			BREAK	-- Check failed, don't consolidate.
				
		-- This can be consolidated.  Change end info accordingly.
		SELECT @end_asgn = @check_asgn,
			@end_mfh = MAX ( stp_mfh_sequence )
		FROM assetassignment, stops, event
		WHERE asgn_number = @check_asgn AND
			stops.lgh_number = assetassignment.lgh_number AND
			stops.stp_number = event.stp_number AND
			( event.evt_trailer1 = assetassignment.asgn_id OR
				event.evt_trailer2 = assetassignment.asgn_id )
		
		-- Now repeat later legheader check.
	END

	-- Full consolidation info retrieved, now save it.
	UPDATE assetassignment 
	SET asgn_trl_first_asgn = @start_asgn,
		asgn_trl_last_asgn = @end_asgn
	FROM stops
	WHERE assetassignment.lgh_number = stops.lgh_number AND
		assetassignment.asgn_type = 'TRL' AND
		assetassignment.asgn_id = @id AND
		stops.mov_number = @mov AND
		stops.stp_mfh_sequence >= @start_mfh AND
		stops.stp_mfh_sequence <= @end_mfh
	
-- Done with this assetassignment record, see if there are any left.
END
RETURN

GO
GRANT EXECUTE ON  [dbo].[consolidate_trl_assns] TO [public]
GO
