SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sv_import_cadec_actuals_sp] (@mov_number_char	VARCHAR(32))
AS
DECLARE @STOPS	TABLE(
	stops_id			INTEGER		IDENTITY(1,1),
	stp_number			INTEGER		NOT NULL,
	stp_event			VARCHAR(6)	NOT NULL,
	stp_type			VARCHAR(6)	NULL,
	cmp_id				VARCHAR(8)	NOT NULL,
	stp_arrivaldate		DATETIME	NOT NULL,
	stp_est_activity	INTEGER		NULL)
	

DECLARE	@CADEC	TABLE(
	cadec_id			INTEGER		IDENTITY(1,1),
	imp_batch			INTEGER		NOT NULL,
	imp_id				INTEGER 	NOT NULL,
	dist_center			INTEGER 	NOT NULL,
	record_type			CHAR(1)		NOT NULL,
	trip_date			DATETIME	NOT NULL,
	trip_num			INTEGER		NOT NULL,
	event_type			VARCHAR(2)	NOT NULL,
	event_start_date	DATETIME	NOT NULL,
	event_end_date		DATETIME	NOT NULL,
	event_duration		INTEGER		NOT NULL,
	driver				VARCHAR(8)	NOT NULL,
	location			VARCHAR(20)	NULL,
	stp_number			INTEGER		NULL)

DECLARE	@trip_start				DATETIME,
		@max_cadec				INTEGER, 
		@max_stops				INTEGER,
		@error					VARCHAR(254),
		@cadec_row				INTEGER,
		@event_start_date		DATETIME,
		@event_duration			INTEGER,
		@event_type				VARCHAR(2),
		@prev_event_type		VARCHAR(2),
		@location				VARCHAR(8),
		@prev_location			VARCHAR(8),
		@stp_number				INTEGER,
		@prev_stp_number		INTEGER,
		@stops_id				INTEGER,
		@prev_stops_id			INTEGER,
		@stp_type				VARCHAR(6),
		@null_count				INTEGER,
		@long_count				INTEGER,
		@late_count				INTEGER,
		@late_start				INTEGER,
		@trip_start_tolerance	INTEGER,
		@stop_arrival_tolerance	INTEGER,
		@duration_tolerance		INTEGER,
		@stp_arrivaldate		DATETIME,
		@stp_est_activity		INTEGER,
		@tolerances				VARCHAR(20),
		@dc						VARCHAR(8),
		@pos					INTEGER,
		@count					INTEGER,
		@not_number				INTEGER,
		@not_sequence			INTEGER,
		@mov_number				INTEGER,
		@max_batch_id			INTEGER

SET NOCOUNT ON

SELECT	@max_batch_id = MAX(imp_batch)
  FROM	sv_import_cadec_actual_route
 WHERE	trip_num = @mov_number_char

INSERT INTO @CADEC
	(imp_batch,
	 imp_id,
	 dist_center,
	 record_type,
	 trip_date,
	 trip_num,
	 event_type,
	 event_start_date,
	 event_end_date,
	 event_duration,
	 driver,
	 location)
	SELECT	imp_batch,
			imp_id,
			dist_center,
			record_type,
			trip_date,
			RTRIM(trip_num),
			event_type,
			CONVERT(DATETIME, RIGHT('20' + RTRIM(field5), 8) + ' ' + LEFT(RTRIM(field6), 2) + ':' + RIGHT(RTRIM(field6), 2)) event_start_date,
			CONVERT(DATETIME, RIGHT('20' + RTRIM(field7), 8) + ' ' + LEFT(RTRIM(field8), 2) + ':' + RIGHT(RTRIM(field8), 2)) event_end_date,
			CONVERT(INTEGER, RTRIM(field9)) event_duration,
			CASE 
				WHEN ISNUMERIC(RTRIM(field10)) = 1 THEN CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field10)))
				ELSE CONVERT(VARCHAR(8), RTRIM(field10)) 
			END driver,
			CASE event_type
				WHEN '03' THEN CASE
								   WHEN ISNUMERIC(RTRIM(field11)) = 1 THEN CASE
																		WHEN dist_center = 19 THEN '20190002'
																		ELSE '1' + RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 3) + '0001'
																	END
								   ELSE	RTRIM(field11)
							   END
				WHEN '30' THEN CASE
								   WHEN ISNUMERIC(RTRIM(field12)) = 1 THEN CASE
																		WHEN CONVERT(INTEGER, field12)= 1 THEN '1' + RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 3) + '0001'
																		WHEN CONVERT(INTEGER, field12)= 2  THEN '20190002'
																		WHEN dist_center = 19 THEN '0018' + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field12))), 4)
																		ELSE RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 4) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field12))), 4)
																	END
								   ELSE	RTRIM(field12)
							   END
				WHEN '35' THEN CASE
								   WHEN ISNUMERIC(RTRIM(field12)) = 1 THEN CASE
																		WHEN CONVERT(INTEGER, field12)= 1 THEN '1' + RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 3) + '0001'
																		WHEN CONVERT(INTEGER, field12)= 2  THEN '20190002'
																		WHEN dist_center = 19 THEN '0018' + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field12))), 4)
																		ELSE RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 4) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field12))), 4)
																	END
								   ELSE	RTRIM(field12)
							   END
				WHEN '39' THEN CASE
								   WHEN ISNUMERIC(RTRIM(field11)) = 1 THEN CASE
																		WHEN CONVERT(INTEGER, field11)= 1 THEN '1' + RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 3) + '0001'
																		WHEN CONVERT(INTEGER, field11)= 2  THEN '20190002'
																		WHEN dist_center = 19 THEN '0018' + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field11))), 4)
																		ELSE RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 4) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field11))), 4)
																	END
								   ELSE	RTRIM(field11)
							   END
				WHEN '93' THEN CASE
								   WHEN ISNUMERIC(RTRIM(field12)) = 1 THEN CASE
																		WHEN CONVERT(INTEGER, field12)= 1 THEN '1' + RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 3) + '0001'
																		WHEN CONVERT(INTEGER, field12)= 2  THEN '20190002'
																		WHEN dist_center = 19 THEN '0018' + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field12))), 4)
																		ELSE RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 4) + RIGHT('000' + CONVERT(VARCHAR(8), CONVERT(INTEGER, RTRIM(field12))), 4)
																	END
								   ELSE	RTRIM(field12)
							   END
				WHEN '97' THEN CASE
								   WHEN ISNUMERIC(RTRIM(field11)) = 1 THEN CASE
																		WHEN dist_center = 19 THEN '20190002'
																		ELSE '1' + RIGHT('000' + CONVERT(VARCHAR(8), dist_center), 3) + '0001'
																	END
								   ELSE	RTRIM(field11)
							   END
				ELSE NULL
			END location
	  FROM	sv_import_cadec_actual_route
	 WHERE	event_type IN ('03', '30', '35', '39', '93', '97') AND
			trip_num = @mov_number_char AND
			imp_batch = @max_batch_id
	ORDER BY event_start_date

SELECT	@count = 0

SELECT @mov_number = CONVERT(INTEGER, RTRIM(@mov_number_char))

SELECT	@count = COUNT(*)
  FROM	legheader
 WHERE	lgh_outstatus IN ('PLN', 'DSP', 'STD') AND
		mov_number = @mov_number

SELECT	@count = ISNULL(@count, 0)

IF @count = 0
BEGIN
	SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'Invalid trip status for CADEC update, trip must be in PLN, DSP or STD status.'
	GOTO PROCESS_ERROR
END

SELECT	@count = 0

SELECT	@count = COUNT(*)
  FROM	legheader
 WHERE	lgh_driver1 IN (SELECT driver FROM @CADEC) AND
		mov_number = @mov_number

SELECT	@count = ISNULL(@count, 0)

IF @count = 0
BEGIN
	SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'Driver on trip does not match driver on CADEC data.'
	GOTO PROCESS_ERROR
END

INSERT INTO @STOPS
	(stp_number,
	 stp_event,
	 stp_type,
	 cmp_id,
	 stp_arrivaldate,
	 stp_est_activity)
	SELECT	stp_number,
			stp_event,
			stp_type,
			cmp_id,
			stp_arrivaldate,
			DATEDIFF(mi, stp_arrivaldate, stp_departuredate) stp_est_activity
	  FROM	stops
	 WHERE	mov_number = @mov_number
	ORDER BY stp_mfh_sequence

SELECT	@max_stops = MAX(stops_id)
  FROM	@STOPS

SELECT	@max_cadec = MAX(cadec_id)
  FROM	@CADEC

IF @max_cadec < @max_stops
BEGIN
	SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + '1 or more stops on move do not exist in CADEC data.'
	GOTO PROCESS_ERROR
END

SET	@trip_start_tolerance = 0
SET	@stop_arrival_tolerance = 0
SET	@duration_tolerance = 0

SELECT	@dc = location
  FROM	@CADEC
 WHERE	cadec_id = 1

SELECT	@tolerances = name
  FROM	labelfile l,
		company c
 WHERE	c.cmp_id = @dc AND
		c.cmp_othertype1 = l.abbr AND
		l.labeldefinition = 'OtherTypes1'

SELECT	@tolerances = ISNULL(LTRIM(RTRIM(@tolerances)), '0,0,0')

SELECT	@pos = CHARINDEX(',', @tolerances)

SELECT	@count = 1

WHILE @pos > 0
BEGIN
	IF @count = 1
	BEGIN
		SELECT	@trip_start_tolerance = CONVERT(INTEGER, ISNULL(SUBSTRING(@tolerances, 1, @pos - 1), '0'))
	END
	ELSE IF @count = 2
	BEGIN
		SELECT	@stop_arrival_tolerance = CONVERT(INTEGER, ISNULL(SUBSTRING(@tolerances, 1, @pos - 1), '0'))
	END
	ELSE IF @count = 3
	BEGIN
		SELECT	@duration_tolerance = CONVERT(INTEGER, ISNULL(SUBSTRING(@tolerances, 1, @pos - 1), '0'))
	END

	SELECT	@tolerances = ISNULL(SUBSTRING(@tolerances, @pos + 1, 255), '0')
	SELECT	@pos = CHARINDEX(',', @tolerances)
	SELECT	@count = @count + 1
END

IF @tolerances <> ''
	SELECT	@duration_tolerance = CONVERT(INTEGER, @tolerances)

SELECT	@cadec_row = 1

WHILE @cadec_row <= @max_cadec
BEGIN
	SELECT	@event_type = event_type,
			@location = location,
			@event_start_date = event_start_date,
			@event_duration = event_duration
	  FROM	@CADEC
	 WHERE	cadec_id = @cadec_row

	IF @cadec_row = 1
	BEGIN
		IF @event_type <> '03'
		BEGIN
			SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'Unexpected event sequence encountered.'
			GOTO PROCESS_ERROR
		END
		ELSE
		BEGIN
			SELECT	@stops_id = 1

			SELECT	@stp_number = stp_number,
					@stp_arrivaldate = stp_arrivaldate,
					@stp_est_activity = stp_est_activity
			  FROM	@STOPS
			 WHERE	stops_id = @stops_id AND
					cmp_id = @location

			SELECT @stp_number = ISNULL(@stp_number, 0)

			IF @stp_number = 0
			BEGIN
				SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + '1 or more CADEC stops out of sequence with stops on the move.'
				GOTO PROCESS_ERROR
			END
			ELSE
			BEGIN
				UPDATE	@CADEC
				   SET	stp_number = @stp_number
				 WHERE	cadec_id = @cadec_row
			END
		END
	END
	ELSE IF @cadec_row = @max_cadec
	BEGIN
		IF @event_type <> '93' AND @event_type <> '97' 
		BEGIN
			SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'Unexpected event sequence encountered.'
			GOTO PROCESS_ERROR
		END
		ELSE
		BEGIN
			SELECT	@stops_id = @max_stops

			SELECT	@stp_number = stp_number
			  FROM	@STOPS
			 WHERE	stops_id = @stops_id AND
					cmp_id = @location

			SELECT @stp_number = ISNULL(@stp_number, 0)

			IF @stp_number = 0
			BEGIN
				SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + '1 or more CADEC stops out of sequence with stops on the move.'
				GOTO PROCESS_ERROR
			END
			ELSE
			BEGIN
				UPDATE	@CADEC
				   SET	stp_number = @stp_number
				 WHERE	cadec_id = @cadec_row
			END
		END
	END
	ELSE
	BEGIN
		IF @event_type = @prev_event_type AND @location = @prev_location
		BEGIN
			SELECT	@stp_number = @prev_stp_number

			UPDATE	@CADEC
			   SET	stp_number = @stp_number
			 WHERE	cadec_id = @cadec_row
		END
		ELSE
		BEGIN
			SELECT	@stp_number = stp_number,
					@stops_id = stops_id,
					@stp_type = stp_type
			  FROM	@STOPS
			 WHERE	stops_id = (@prev_stops_id + 1) AND
					cmp_id = @location

			SELECT @stp_number = ISNULL(@stp_number, 0)

			IF @stp_number = 0
			BEGIN
				SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + '1 or more CADEC stops out of sequence with stops on the move.'
				GOTO PROCESS_ERROR
			END

			IF @event_type = '30'
			BEGIN
				IF @stops_id = @max_stops AND @dc = @location
				BEGIN
					UPDATE	@CADEC
					   SET	stp_number = @stp_number
					 WHERE	cadec_id = @cadec_row
				END
				ELSE IF @stp_type <> 'DRP' OR @stops_id = @max_stops
				BEGIN
					SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + '1 or more CADEC stops out of sequence with stops on the move.'
					GOTO PROCESS_ERROR
				END
				ELSE
				BEGIN
					UPDATE	@CADEC
					   SET	stp_number = @stp_number
					 WHERE	cadec_id = @cadec_row
				END
			END
			ElSE IF @event_type = '35'
			BEGIN
				IF @stp_type <> 'PUP' OR @stops_id = @max_stops
				BEGIN
					SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + '1 or more CADEC stops out of sequence with stops on the move.'
					GOTO PROCESS_ERROR
				END
				ELSE
				BEGIN
					UPDATE	@CADEC
					   SET	stp_number = @stp_number
					 WHERE	cadec_id = @cadec_row
				END
			END
			ELSE IF @event_type = '39'
			BEGIN
				SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'Event Type (' + @event_type + ') not handled at this time.'
				GOTO PROCESS_ERROR
			END
			ELSE
			BEGIN
				SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'Event Type (' + @event_type + ') not handled at this time.'
				GOTO PROCESS_ERROR
			END
		END
	END

	SELECT	@cadec_row = @cadec_row + 1,
			@prev_location = @location,
			@prev_stp_number = @stp_number,
			@prev_event_type = @event_type,
			@prev_stops_id = @stops_id,
			@stp_number = NULL
END

SELECT	@null_count = COUNT(*)
  FROM	@CADEC
 WHERE	stp_number IS NULL

IF @null_count > 0 
BEGIN
	SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + '1 or more CADEC stops do not exist on move.'
	GOTO PROCESS_ERROR
END

SELECT	@late_start = COUNT(*)
  FROM	@STOPS s
 WHERE	DATEDIFF(mi, stp_arrivaldate, (SELECT MIN(event_start_date) FROM @CADEC WHERE stp_number = s.stp_number)) > @trip_start_tolerance AND
		stops_id = 1

IF ISNULL(@late_start, 0) > 0
BEGIN
	SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + 'Trip start delayed outside of tolerance level.'
END

SELECT	@late_count = COUNT(*)
  FROM	@STOPS s
 WHERE	DATEDIFF(mi, stp_arrivaldate, (SELECT MIN(event_start_date) FROM @CADEC WHERE stp_number = s.stp_number)) > @stop_arrival_tolerance AND
		stops_id <> 1 AND
		stops_id <> @max_stops

IF ISNULL(@late_count, 0) > 0
BEGIN
	IF LEN(@error) > 0
		SELECT	@error = @error + CHAR(13) + CHAR(10) + '1 or more deliveries delayed outside of tolerance level.'
	ELSE
		SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + '1 or more deliveries delayed outside of tolerance level.'
END

SELECT	@long_count = COUNT(*)
  FROM	@STOPS s
 WHERE	DATEDIFF(mi, (SELECT MIN(event_start_date) FROM @CADEC WHERE stp_number = s.stp_number), (SELECT	MAX(event_end_date) FROM @CADEC WHERE stp_number = s.stp_number)) > (stp_est_activity + @duration_tolerance) AND
		stops_id <> 1 AND
		stops_id <> @max_stops

IF ISNULL(@long_count, 0) > 0
BEGIN
	IF LEN(@error) > 0
		SELECT	@error = @error + CHAR(13) + CHAR(10) + '1 or more delivery durations outside of tolerance level.'
	ELSE
		SELECT	@error = 'CADEC DATA ERROR' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) + '1 or more delivery durations outside of tolerance level.'
END

IF (ISNULL(@late_start, 0) + ISNULL(@late_count, 0) + ISNULL(@long_count, 0)) > 0
	GOTO PROCESS_ERROR

SELECT	@stp_number = MIN(stp_number)
  FROM	stops 
 WHERE	mov_number = @mov_number

SELECT	@stp_number = ISNULL(@stp_number, 0)

WHILE @stp_number > 0
BEGIN
	UPDATE	stops
	   SET	stp_status = 'DNE',
			stp_arrivaldate = (SELECT MIN(event_start_date) FROM @CADEC WHERE stp_number = @stp_number),
			stp_departuredate = (SELECT	MAX(event_end_date) FROM @CADEC WHERE stp_number = @stp_number)
	 WHERE	stp_number = @stp_number

	SELECT	@stp_number = MIN(stp_number)
	  FROM	stops 
	 WHERE	mov_number = @mov_number AND
			stp_number > @stp_number

	SELECT	@stp_number = ISNULL(@stp_number, 0)
END

UPDATE	legheader
   SET	lgh_tm_status = 'NOSENT'
 WHERE	mov_number = @mov_number

EXEC dbo.update_move @mov_number

EXEC dbo.update_ord @mov_number, 'CMP'

SET NOCOUNT OFF

RETURN

PROCESS_ERROR:
	EXEC @not_number = dbo.getsystemnumber 'NOTES', NULL

	SELECT	@not_sequence = MAX(ISNULL(not_sequence,0))
	  FROM	notes
	 WHERE	ntb_table = 'move' AND
			nre_tablekey = @mov_number

	SELECT	@not_sequence = ISNULL(@not_sequence, 0) + 1
     
	INSERT INTO notes
		(not_number, 
		 not_text,
		 not_type,
		 not_urgent,
		 not_expires,
		 ntb_table,
		 nre_tablekey,
		 not_sequence,
		 last_updatedby,
		 last_updatedatetime)
	VALUES
		(@not_number, 
		 @error,
		 'CADEC',
		 'A',
		 '12-31-49 23:59',
		 'movement',
		 @mov_number,
		 @not_sequence,
		 'CADEC IMPORT',
		 getdate())

	UPDATE	legheader
	   SET	lgh_tm_status = 'ERROR'
	 WHERE	mov_number = @mov_number

	SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sv_import_cadec_actuals_sp] TO [public]
GO
