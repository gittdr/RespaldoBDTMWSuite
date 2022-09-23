SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROC	[dbo].[d_check_for_incompatible_cmd] @mov_numbers varchar(255)
AS

/************************************************************************************
 NAME:	          d_check_for_incompatible_cmd
 DOS NAME:	      tmwsp_d_check_for_incompatible_cmd.sql
 TYPE:		      stored procedure
 PURPOSE:	      Check the trailers on the move with the previous and the next move
                  to see if there are potential conflicting products.
 DEPENDANCIES:


REVISION LOG

DATE		  WHO	   	REASON
----		  ---	   	------
27-Nov-2002   TJD      	Created.
10-Jan-2003	  PAK	   	Added the order number fields in the results back to PB. 
						Removed commodity description fields and the lgh_number field.
						Added seq_no & ord_hdrnumber to temp table #orig_commodities to handle linked orders.
						Added the retrieval of the departure datetime of the first Live Load event
				        on the original and conflicting orders.
						Added order by clause (orig_ord) to the result set so that the repeated orders
						can be filtered out to the user. 
exec d_check_for_incompatible_cmd '3059980, 3060050, 3060052'

*************************************************************************************/
--10-Jan-2003 PAK: Add orig_ord int, conflict_ord int
-- 		  		   Remove orig_cmd_desc, conflict_cmd_desc, 
--				   conflict_lgh_number
CREATE TABLE #errors(
	orig_mov			int			NULL,
	orig_ord			int			NULL,
	orig_cmd_code		varchar(8)	NULL,
	orig_load_date		datetime	NULL,
	conflict_cmd_code	varchar(8)	NULL,
	conflict_load_date	datetime	NULL,
	conflict_mov		int			NULL,
	conflict_ord		int			NULL
)

CREATE TABLE #orig_trailers(
	orig_trl_id          varchar(12),
	lgh_number           int
)

--10-Jan-2003 PAK: add seq_no & ord_hdrnumber to table
CREATE TABLE #orig_commodities(
	seq_no				numeric(5,0) IDENTITY NOT NULL,
	ord_hdrnumber		int,
	cmd_code			varchar(8)
)

CREATE TABLE #test_commodities(
	tst_cmd_code		varchar(8)
)

CREATE TABLE #tested_moves(
	tst_mov_number		int
)

DECLARE
	@curr_orig_trl		varchar(12),
	@max_orig_trl		varchar(12),
	@curr_move			int,
	@curr_ord			int,			--10-Jan-2003 PAK:
	@curr_move_str		varchar(255),
	@control			int,
	@test_move			int,
	@test_ord			int,			--10-Jan-2003 PAK:
	@curr_end_date		datetime,
	@orig_load_date		datetime,
	@conflict_load_date	datetime,
	@test_date			datetime,
	@curr_orig_cmd		varchar(8),
	@max_orig_cmd		varchar(8),
	@curr_tst_cmd		varchar(8),
	@max_tst_cmd		varchar(8),
	@num_found			int,
	@curr_leg			int,
	@seq_no			 	numeric(5,0) --10-Jan-2003 PAK:

/* Process all move_numbers which are comma delimited */
set @curr_move	= 0
set @curr_move_str = ''

WHILE (@mov_numbers <> @curr_move_str)
BEGIN
	EXEC mbi_parse_str @mov_numbers output, ',', @curr_move_str output

	SELECT @curr_move	= convert(int, @curr_move_str)
	/* Clear out the trailers */
	DELETE FROM #orig_trailers

	/*Clear out the moves tested */
	DELETE FROM #tested_moves

	/* Get all of the trailers on the move */
	INSERT INTO #orig_trailers
	SELECT asgn_id, a.lgh_number
	FROM assetassignment a, 
		legheader 		 l
	WHERE asgn_type 	 = 'TRL'
	AND l.mov_number 	 = @curr_move
	AND l.lgh_number 	 = a.lgh_number


	/* Obtain the last day these assets are used */
	SELECT @curr_end_date	= max(asgn_enddate)
	FROM assetassignment 	a, 
		legheader 			l
	WHERE asgn_type 		= 'TRL'
	AND l.mov_number 		= @curr_move
	AND l.lgh_number 		= a.lgh_number


	DELETE FROM #orig_commodities

	/* Obtain the commodities on the current move */
	INSERT INTO #orig_commodities
	SELECT distinct s.ord_hdrnumber, f.cmd_code	--10-Jan-2003 PAK:
	FROM freightdetail 	f, 
		 stops 			s
	WHERE f.stp_number 	= s.stp_number
	AND s.mov_number 	= @curr_move
	AND f.cmd_code 		<> 'UNKNOWN'

	--10-Jan-2003 PAK: Get the departure datetime of the first Live Load event
	--         on the original order

	SELECT @orig_load_date = min(s.stp_departuredate)
	FROM stops 			s, 
		 legheader 		l
	WHERE l.mov_number 	= @curr_move
	AND l.mov_number 	= s.mov_number
	AND s.stp_event 	= 'LLD'

	/* Loop through the trailers if there are any */
	IF (SELECT count(*) FROM #orig_trailers) > 0
	BEGIN

		SELECT 	@curr_orig_trl 	= min(orig_trl_id),
				@max_orig_trl 	= max(orig_trl_id)
		FROM 	#orig_trailers
		WHILE @curr_orig_trl <= @max_orig_trl
		BEGIN /* Original trailer loop */

			/* Use a variable to determine if we are on the first time through
			   or the second time through.  For the first time through, we want
			   to find the last move the current trailer is on, the second time
			   through, we want the next move the current trailer is on */

			SELECT @control = 1

			WHILE @control <= 2
			BEGIN /* control loop */

				/* Initialize new move number */
				SELECT @test_move = 0

				/* Get previous move number */
				IF @control = 1
				BEGIN

					/* Get the last date (prior to current move)*/
					SELECT @test_date 	 = max(asgn_enddate)
					FROM assetassignment a, 
						 legheader 		 l
					WHERE asgn_type 	 = 'TRL'
					AND asgn_id 		 = @curr_orig_trl
					AND asgn_enddate 	 <= @curr_end_date
					AND l.mov_number 	 <> @curr_move
					AND l.lgh_number 	 = a.lgh_number

					/* We can now obtain the move number based on the date from above */
					SELECT 	@test_move	= l.mov_number,
							@test_ord 	= l.ord_hdrnumber   --10-Jan-2003 PAK: 
					FROM assetassignment a, 
					legheader 			l
					WHERE asgn_type 	= 'TRL'
					AND asgn_id 		= @curr_orig_trl
					AND asgn_enddate	= @test_date
					AND l.lgh_number 	= a.lgh_number

				END -- End if control = 1


				IF @control = 2
				BEGIN

					/* Get the next move, if any that the order is on */
					SELECT @test_date 	= min(asgn_date)
					FROM assetassignment a, 
						legheader 		l
					WHERE asgn_date 	>= @curr_end_date
					AND asgn_type 		= 'TRL'
					AND asgn_id 		= @curr_orig_trl
					AND l.mov_number 	<> @curr_move
					AND l.lgh_number 	= a.lgh_number

					/* We can now obtain the move number based on the date from above */
					SELECT 	@test_move 	= l.mov_number,
							@test_ord 	= l.ord_hdrnumber --10-Jan-2003 PAK: 
					FROM assetassignment a, 
						legheader 		l
					WHERE asgn_type 	= 'TRL'
					AND asgn_id 		= @curr_orig_trl
					AND asgn_date 		= @test_date
					AND l.lgh_number 	= a.lgh_number

				END -- End if control = 2

				/* If we have a new move number, get the commmodites for it */
				DELETE FROM #test_commodities

				IF ISNULL(@test_move, 0) > 0
				/* Also check if we've already tested - no point in doing it again */
				BEGIN /* test move */

					IF (SELECT count(*)
						FROM #tested_moves
						WHERE tst_mov_number = @test_move) <= 0
						BEGIN /* test new move */
							INSERT INTO #test_commodities
							SELECT distinct(f.cmd_code)
							FROM freightdetail f, stops s
							WHERE f.stp_number	= s.stp_number
							AND s.mov_number 	= @test_move
							AND f.cmd_code 		<> 'UNKNOWN'

							--10-Jan-2003 PAK: Get the departure datetime of the first Live Load event
							--         on the conflicting order

							SELECT @conflict_load_date = min(s.stp_departuredate)
							FROM stops s, legheader l
							WHERE l.mov_number	= @test_move
							AND l.mov_number 	= s.mov_number
							AND s.stp_event 	= 'LLD'

							/* For each original commodity, test if the combination
						   of it and the new commodity is in the table, if not,
						   insert into the error table */

						   SELECT @seq_no = 0

						   SELECT @seq_no = ISNULL(MIN(seq_no), 0)
						   FROM #orig_commodities
						   WHERE seq_no > @seq_no

							WHILE @seq_no <> 0
							BEGIN /* original commodities */

							  --10-Jan-2003 PAK: Get the first commodity and order #
					 			SELECT @curr_orig_cmd = cmd_code,
						   			   @curr_ord 	  = ord_hdrnumber
								FROM #orig_commodities
						   		WHERE seq_no 		  = @seq_no

								SELECT @curr_tst_cmd = min(tst_cmd_code),
									   @max_tst_cmd  = max(tst_cmd_code)
                                FROM #test_commodities

								WHILE @curr_tst_cmd <= @max_tst_cmd
								BEGIN /* Test commodities */

									IF (@curr_orig_cmd <> @curr_tst_cmd)
									BEGIN

										SELECT @num_found = count(*)
										FROM compatible_commodities
										WHERE (cc_cmd_code_1 = @curr_orig_cmd AND
											   cc_cmd_code_2 = @curr_tst_cmd) OR
											  (cc_cmd_code_1 = @curr_tst_cmd AND
											   cc_cmd_code_2 = @curr_orig_cmd)

									IF ISNULL(@num_found,0) <= 0
									/* Commodities are not in the table
									   and therefore may not be compatible */
									BEGIN
										--10-Jan-2003 PAK: Add new columns & remove conflict_lgh_number
										INSERT INTO #errors
										(orig_cmd_code,
										 orig_load_date,
										 conflict_cmd_code,
										 conflict_load_date,
										 conflict_mov,
										 conflict_ord,
										 orig_mov,
										 orig_ord)
										SELECT
										 @curr_orig_cmd,
										 @orig_load_date,
										 @curr_tst_cmd,
										 @conflict_load_date,
										 @test_move,
										 @test_ord,
										 @curr_move,
										 @curr_ord
									END -- End if isnull(@num_found,0) <= 0
									END -- End if @curr_orig_cmd <> @curr_tst_cmd

									SELECT @curr_tst_cmd = min(tst_cmd_code)
									FROM #test_commodities
									WHERE tst_cmd_code 	 > @curr_tst_cmd

								END /*Test commodities */

								SELECT @seq_no 	= ISNULL(MIN(seq_no), 0)
								FROM #orig_commodities
								WHERE seq_no 	> @seq_no

							END /* original commodities */

							/* Place move in the already tested table */
							INSERT INTO #tested_moves
							SELECT @test_move

						END /* test new move */
				END /* test move */

				SELECT @control = @control + 1

			END /* control loop */


			SELECT @curr_orig_trl = min(orig_trl_id)
			FROM #orig_trailers
			WHERE orig_trl_id > @curr_orig_trl

		END/* Original trailer loop */

	END -- End if (SELECT count(*) FROM #orig_trailers) > 0
END

 
/* Return the errors as the result set */
SELECT 
	orig_mov,
	orig_ord,
	orig_cmd_code,
	orig_load_date,
	conflict_mov,
	conflict_ord,
	conflict_cmd_code,
	conflict_load_date
FROM #errors
ORDER BY orig_ord

GO
GRANT EXECUTE ON  [dbo].[d_check_for_incompatible_cmd] TO [public]
GO
