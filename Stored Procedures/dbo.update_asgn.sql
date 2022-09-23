SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[update_asgn] @lgh int AS

DECLARE @minasgn int,
	@type char (6),
	@id char (13),
	@code smallint,
	@start datetime,
	@end datetime,
	@stat1 char (6),
	@stat2 char (6),
	@evt int  


SELECT @minasgn = 0


	WHILE ( SELECT COUNT(*) FROM assetassignment, stops, event
		WHERE stops.lgh_number = @lgh AND
			assetassignment.evt_number = event.evt_number AND 
			stops.stp_number = event.stp_number AND
			asgn_number + 0 > @minasgn) > 0
	BEGIN

	SELECT @minasgn = MIN ( asgn_number )
	FROM assetassignment, event, stops
	WHERE stops.lgh_number = @lgh AND
		assetassignment.evt_number = event.evt_number AND 
		event.stp_number = stops.stp_number AND
		asgn_number + 0 > @minasgn /* add zero to asgn_num so wont use asgn_num key */

	/*********************************************************************************/
	/* asgn_type abbr < 100 means asset defines the trip segment, e.g., trc/drv/car	 */
	/* asgnt_type abbr >= 100 means asset can be switched on/off during the trip seg */
	/* e.g., trailer, dolly, container, chassis					 */
	/*********************************************************************************/
	SELECT @type = asgn_type,
		@code = code,
		@id = asgn_id,
		@evt = evt_number
	FROM assetassignment, labelfile
	WHERE asgn_number = @minasgn AND
		labeldefinition = 'AssType' AND
		abbr = asgn_type 

	/* delete this if is a duplicate for the legheader */
	IF EXISTS ( SELECT asgn_number
				FROM assetassignment, stops, event
				WHERE stops.lgh_number = @lgh AND
					stops.stp_number = event.stp_number AND
					event.evt_number = assetassignment.evt_number AND
					asgn_type +'' = @type AND
					asgn_id +'' = @id AND
					event.evt_number < @evt )
		DELETE assetassignment
		WHERE asgn_number = @minasgn
		
	IF @code < 100
	BEGIN


		UPDATE assetassignment
		SET asgn_status = lgh_outstatus,
			asgn_date = lgh_startdate,
			asgn_enddate = lgh_enddate, 
                        mov_number = legheader.mov_number
 		FROM legheader
		WHERE legheader.lgh_number = @lgh AND
			asgn_number = @minasgn 
 
	END
	ELSE 
		IF @type = 'TRL' 
		BEGIN

/* 11/24/98 - TD: VJ's changes will also make it ignore valid startdates just because 
**	the enddate is apocalypse.  Comments were getting too complicated, so retyped.
** \* modify date 01/21/97 - VJ. added aditional filter to check for *\
** \* apocalypse date and reject evt_enddate > 20491231 *\
** 			SELECT @start = MIN ( evt_startdate ),
** \* commented out by VJ - 01/07/97 @end = MAX ( evt_startdate ),  *\
** 				@end = MAX ( evt_enddate ),
**				@stat1 = MIN ( evt_status ),
**				@stat2 = MAX ( evt_status )
**			FROM stops, event
**			WHERE stops.stp_number = event.stp_number AND
**                              event.evt_enddate < '20491231' AND
**			stops.mov_number = ( SELECT DISTINCT mov_number 
**						FROM stops 
**						WHERE lgh_number = @lgh ) AND
**			( event.evt_trailer1 = @id OR event.evt_trailer2 = @id ) AND
**			stops.lgh_number = @lgh
**			
** added additional code to check if @end is null - VJ 01/21/97 
**			IF (@end = null)
**			   SELECT @end = @start 
** add ends here - VJ 01/21/97
** 11/24/98 - TD: Now my new form */
			SELECT @start = MIN ( evt_startdate ),
				@end = MAX(
					CASE
						WHEN isnull( evt_enddate, '20491231' ) < '20491231' THEN evt_enddate
						ELSE evt_startdate
					END ),
				@stat1 = MIN ( evt_status ),
				@stat2 = MAX ( evt_status )
			FROM stops, event
			WHERE stops.stp_number = event.stp_number AND
			( event.evt_trailer1 = @id OR event.evt_trailer2 = @id ) AND
			stops.lgh_number = @lgh
-- 11/24/98 - TD: End new form.

			IF @stat1 = 'DNE' AND @stat2 = 'DNE' 
				SELECT @stat1 = 'CMP'
			ELSE 
			IF @stat1 = 'OPN' 
/* 11/24/98 - TD: 
** All of this was to lock in primary trailer after move was started.
**		This functionality is now in consolidate_trl_assns and get_cur_activity.
**				BEGIN \* if move is started, lock all trailers in started status *\
**				SELECT @stat1 = MIN ( stp_status )
**				FROM stops 
**				WHERE mov_number = ( SELECT DISTINCT mov_number 
**						FROM stops 
**						WHERE lgh_number = @lgh ) 
**				IF @stat1 = 'OPN' */
					SELECT @stat1 = 'PLN'
/*				ELSE
**					SELECT @stat1 = 'STD'
**				END */
			ELSE
				SELECT @stat1 = 'STD'

			UPDATE assetassignment
			SET asgn_date = @start,
				asgn_enddate = @end,
				asgn_status = @stat1
			WHERE asgn_number = @minasgn

	END


	END
RETURN

GO
GRANT EXECUTE ON  [dbo].[update_asgn] TO [public]
GO
