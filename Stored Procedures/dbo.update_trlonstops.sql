SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.update_trlonstops    Script Date: 5/8/01 1:59:55 PM ******/
CREATE PROC [dbo].[update_trlonstops] @lgh int
/*
	JET added new proc to do what update_trlonlgh used to do, so it could do the update trailer on
	leg header, which it wasn't doing correctly.  This new procedure can be called to make \
	sure the trailers are correct on all the stops during update move.

	PTS 37810 - DJM - Added logic to look for the Mile Type In to find Trailer changes.
*/

AS
/* PTS 3255 removed cursor and used a while loop instead */
DECLARE	@trl 		char (13),
	@pup 		char (13),
	@trl1 		char (13),
	@trl2 		char (13),
	@trlstart 	char(1),
	@trlend 	char(1),
	@trlendprev	char(1),        
	@trllast 	char(1),
	@evt 		int,
	@miletype 	char(6),
	@stp 		int,
	@stpseq 	int,
	@nextpup 	int,
	@nextdmt 	int,
	@evtseq		int,
-- PTS 3359 PG 12/9/97
	@count		int, 
    @splitpup       char(1), 
    @primary_trl    varchar(13), 
	@primary_pup    varchar(13),
-- PTS 37810	DJM		11/20/2008
	@miletypein	varchar(6)


-- JET - 6/20/01 - PTS # 10339 - need to default the trailer variables.
select @primary_trl = '', @primary_pup = ''

SELECT @stpseq = 0, @count = 0

/* loop for all stops in the legheader in a ascending order */
WHILE 1 = 1
BEGIN
	SELECT 	@stpseq = MIN(stp_mfh_sequence)
	FROM 	stops 
	WHERE 	stops.lgh_number = @lgh AND
		stops.stp_mfh_sequence > @stpseq

	IF @stpseq IS NULL
		BREAK

	SELECT 	@stp = stops.stp_number
	FROM 	stops
	WHERE	stops.lgh_number = @lgh AND
		stops.stp_mfh_sequence = @stpseq

	/* 200000 -> a large number */
	SELECT 	@evtseq = 200000

	/* loop for events in the stop in descending order */
	WHILE 2 = 2
	BEGIN
		-- PTS 3359 PG 12/9/97
		SELECT @count = @count + 1
		-- end PTS 3359 PG 12/9/97

		SELECT 	@evtseq = MAX(evt_sequence)
		FROM	event, eventcodetable
		WHERE 	event.evt_sequence < @evtseq AND
			event.stp_number = @stp AND
			event.evt_eventcode = eventcodetable.abbr AND
			( evt_sequence = 1 OR ect_trlstart <> 'N' OR ect_trlend <> 'N' )

		IF @evtseq IS NULL
			BREAK

		SELECT 	@trl = evt_trailer1,
			@pup = evt_trailer2,
			@trlstart = ect_trlstart,
			@trlend = ect_trlend,
			@evt = evt_number,
			@miletype = mile_typ_from_stop,
			@miletypein = mile_typ_to_stop	-- PTS 37810
		FROM 	event, eventcodetable
		WHERE 	event.evt_sequence = @evtseq AND
			event.stp_number = @stp AND
			event.evt_eventcode = eventcodetable.abbr


		-- dsk split pups 4.0  3/5/98
		IF @trlend = '!'
			SELECT 	@splitpup = 'Y'

		-- PTS 3359 PG 12/9/97 Only initialize the first time
		IF @count = 1
			SELECT @trl1 = @trl, @trllast = 'N', @trl2 = @pup, @trlendprev = 'N'
		-- end PTS 3359 PG 12/9/97
	
		IF @miletype = 'LD' AND (@primary_trl = '')
			SELECT 	@primary_trl = @trl,
				@primary_pup = @pup
		ELSE 
			IF @miletype = 'MT' AND @primary_trl = '' AND @trlstart <> 'X' AND @trlend <> 'X' 
			/* if begin empty, see if trailer is dropped at 'PUP' stop */
			/* if not, then this is the primary trailer */
			/* but if is BT, then trl is unknown, so don't set @primary_trl to trl! */

			/* find first pup stop, next end empty or drop empty */
			/* if there is a dmt or emt before there is a pup, */
			/* then this is NOT primary trailer, else, is */

			BEGIN
				SELECT 	@nextpup = MIN ( stp_mfh_sequence )
				FROM 	stops
				WHERE 	stp_type = 'PUP' AND
					lgh_number = @lgh AND
					stp_mfh_sequence > @stpseq 
			
				SELECT 	@nextdmt = ISNULL ( MIN ( stp_mfh_sequence ), 9999 )
				FROM 	stops, event, eventcodetable
				WHERE 	evt_eventcode = abbr AND
					ect_trlend = 'Y' AND
					mile_typ_to_stop = 'MT' AND
					lgh_number = @lgh AND
					stops.stp_number = event.stp_number AND
					stp_mfh_sequence > @stpseq 

				IF @nextpup < @nextdmt 
	 				SELECT 	@primary_trl = @trl,
						@primary_pup = @pup

			END

		IF @trllast <> 'Y' AND ( @trlstart = 'Y' OR @trlend = 'X' )
		BEGIN
			IF @miletype = 'LD'
				SELECT 	@trl1 = @primary_trl, /* may have been passed in from prior lgh */
					@trl2 = @primary_pup
			ELSE				SELECT 	@trl1 = @trl,
					@trl2 = @pup

			UPDATE 	event
			SET 	evt_trailer1 = @trl1,
				evt_trailer2 = @trl2
			FROM 	eventcodetable
			WHERE 	event.stp_number = @stp AND
				event.evt_eventcode = eventcodetable.abbr AND
				eventcodetable.ect_trlstart = 'S' AND
				( evt_trailer1 <> @trl1 OR evt_trailer2 <> @trl2 )
		END

		SELECT @trllast = @trlstart

		IF ( @trlstart = 'X' OR @trlend = 'X' )
			UPDATE 	event
			SET 	evt_trailer1 = 'UNKNOWN',
				evt_trailer2 = 'UNKNOWN'
			WHERE 	evt_number = @evt AND
				( evt_trailer1 <> 'UNKNOWN' OR evt_trailer2 <> 'UNKNOWN' )
		
		-- PTS 37810 - DJM - Must look at more that trailer start and trailer end fields for event
		IF ( @trlstart = 'Y' OR @trlend = 'Y' )
			Begin
				if @miletypein = 'BT' and @stpseq > 1
					-- Set the trailer to the value on the stop since the incoming value of 'BT' indicates 
					--		that the trailer was dropped on the previous stop
					select @trl1 = evt_trailer1,
						@trl2 = evt_trailer2
					from event
					WHERE 	evt_number = @evt 
				else
					UPDATE 	event
					SET 	evt_trailer1 = @trl1,
						evt_trailer2 = @trl2
					WHERE 	evt_number = @evt AND
						( evt_trailer1 <> @trl1 OR evt_trailer2 <> @trl2 )
			end

		/* if the stop is route point or track point or	*/
		/* other non specific trailer activity event	*/
		/* must set the trailer to trailer from previous stop */
		IF ( @trlstart = 'N' AND @trlend = 'N' AND @trlendprev = 'N' )			
			UPDATE 	event
			SET 	evt_trailer1 = @trl1,
				evt_trailer2 = @trl2
			WHERE 	evt_number = @evt AND
				( evt_trailer1 <> @trl1 OR evt_trailer2 <> @trl2 )

		IF @trlend = 'Y'
			UPDATE 	event
			SET 	evt_trailer1 = @trl1,
				evt_trailer2 = @trl2
			FROM 	eventcodetable
			WHERE 	stp_number = @stp AND
				evt_eventcode = abbr AND
				ect_trlend = 'S' AND
				( evt_trailer1 <> @trl1 OR evt_trailer2 <> @trl2 )

		-- dsk split pups 4.0  3/5/98
		-- as soon as split pup event is found, don't copy trailer to next events
		IF @splitpup = 'Y'
			BREAK

	END
	-- dsk split pups 4.0  3/5/98
	IF @splitpup = 'Y'
		BREAK

	SELECT @trlendprev = @trlend
END

IF @primary_trl = ''
	SELECT 	@primary_trl = @trl1,
		@primary_pup = @trl2



GO
GRANT EXECUTE ON  [dbo].[update_trlonstops] TO [public]
GO
