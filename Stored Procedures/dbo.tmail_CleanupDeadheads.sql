SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* This routine finds the specified stop and verifies that the specified stop could be
arrived at the specified time except for uncompleted deadhead activity.  If this is 
found to be the case, then any such deadhead activity will be completed as of one 
minute before the specified time. If this is not found to be the case, then an error 
will be thrown describing the problemmatic activity. 

Current version does not allow any sort of equipment changes between prior activity 
and the target stop (including trailer changes).  Thus this currently cannot work for 
the second half of a split or even an HPL.

Also, will not ripple times forward past the end of the leg, so can be problemmatic for the 
first half of a split if the time is so late that the HLT/HCT for the second half of the split
would need to be rippled. */
create proc [dbo].[tmail_CleanupDeadheads](@stp_number integer, @AsOfDate datetime, @InvWhen varchar(20))
as
BEGIN
declare @Drv1 varchar(8), @Drv2 varchar(8), @Trc varchar(8), @Trl varchar(13), @Car varchar(8)
declare @testStop int, @Move int, @StpEvent varchar(6), @PriorStops int, @testMove int
declare @Lgh int, @WorkDate datetime, @Seq int, @testLgh int
declare @Drv1StdLgh int, @Drv1EMTStops int
declare @Drv2StdLgh int, @Drv2EMTStops int
declare @TrcStdLgh int, @TrcEMTStops int
declare @TrlStdLgh int, @TrlEMTStops int
declare @AsOfDateText varchar(30), @PriorMove int
declare @PDrv1 varchar(8), @PDrv2 varchar(8), @PTrc varchar(8), @PTrl varchar(13)
declare @LghStatus varchar(6), @FirstStop int
declare @LastStopStatus varchar(6), @LastStopSeq int, @WorkSeq int
declare @PreProcessor varchar(30), @PostProcessor varchar(30), @execText varchar(60)

IF NOT EXISTS (SELECT * FROM stops where stp_number= @stp_number)
	BEGIN
	RAISERROR ('Stop Number %u not found', 16, 1, @stp_number)
	RETURN
	END
IF NOT EXISTS (SELECT * FROM stops inner join legheader on stops.lgh_number = legheader.lgh_number where stp_number= @stp_number)
	BEGIN
	RAISERROR ('Leg for stop number %u not found', 16, 1, @stp_number)
	RETURN
	END

SELECT 
	@Drv1 = ISNULL(legheader.lgh_driver1, 'UNKNOWN'), 
	@Drv2 = ISNULL(legheader.lgh_driver2, 'UNKNOWN'),
	@Trc = ISNULL(legheader.lgh_tractor, 'UNKNOWN'),
	@Trl = ISNULL(stops.trl_id, 'UNKNOWN'),
	@Car = ISNULL(legheader.lgh_carrier, 'UNKNOWN'),
	@Move = stops.mov_number,
	@Lgh = stops.lgh_number,
	@StpEvent = stops.stp_event,
	@Seq = stp_mfh_sequence,
	@LghStatus = legheader.lgh_outstatus
FROM stops inner join legheader on stops.lgh_number = legheader.lgh_number
where stops.stp_number = @stp_number

-- If the legheader has already been started, this routine isn't needed.
IF @LghStatus = 'STD' OR @LghStatus = 'CMP' RETURN 0
IF @LghStatus <> 'PLN' AND @LghStatus <> 'DSP'
	BEGIN
	RAISERROR ('Leg %u in unexpected status (%s)', 16, 1, @Lgh, @LghStatus)
	RETURN
	END

IF @Drv1 = '' SELECT @Drv1 = 'UNKNOWN'
IF @Drv2 = '' SELECT @Drv2 = 'UNKNOWN'
IF @Trc = '' SELECT @Trc = 'UNKNOWN'
IF @Car = '' SELECT @Car = 'UNKNOWN'
IF @Trl = '' SELECT @Trl = 'UNKNOWN'

IF @Drv1 = 'UNKNOWN' AND @Car = 'UNKNOWN'
	BEGIN
	RAISERROR ('No Driver on stop number %u', 16, 1, @stp_number)
	RETURN
	END
IF @Trc = 'UNKNOWN' AND @Car = 'UNKNOWN'
	BEGIN
	RAISERROR ('No Tractor on stop number %u', 16, 1, @stp_number)
	RETURN
	END
IF @Trl = 'UNKNOWN' AND @Car = 'UNKNOWN'
	BEGIN
	RAISERROR ('No Trailer on stop number %u', 16, 1, @stp_number)
	RETURN
	END

SELECT @PriorStops = COUNT(DISTINCT srch.stp_number) 
	FROM stops srch INNER JOIN stops main 
	ON srch.mov_number = main.mov_number AND srch.stp_mfh_sequence < main.stp_mfh_sequence
	WHERE main.stp_number = @stp_number

IF @PriorStops > 0
	BEGIN
	SELECT @testStop=srch.stp_mfh_sequence FROM stops srch INNER JOIN stops main 
		ON srch.mov_number = main.mov_number AND srch.stp_mfh_sequence < main.stp_mfh_sequence
		WHERE (ISNULL(srch.ord_hdrnumber, 0) <> 0 or 
			srch.stp_event not in ('BMT', 'IBMT', 'BBT', 'IBBT', 'TRP', 'RTP')) and
			srch.stp_status = 'OPN' AND
			main.stp_number = @stp_number
	IF ISNULL(@testStop, 0)<>0
		BEGIN
		RAISERROR ('Cannot arrive move %u, stop %u (on leg %u).  Unarrived prior non-deadhead activity found at stop %u.', 16, 1, @Move, @Seq, @Lgh, @testStop)
		RETURN
		END
	END

-- Following assertion is sanity check.  It is not valid if this routine ever starts
-- supporting splits.
IF @Seq <> @PriorStops + 1
	BEGIN
	RAISERROR ('Assertion failed: Prior stops count (%u) does not correlate to Sequence (%u)', 16, 1, @PriorStops, @Seq)
	RETURN
	END

SELECT @AsOfDateText = convert(varchar(30),@AsOfDate)

IF @Drv1 <> 'UNKNOWN' 
	BEGIN 
	SELECT top 1 @testMove = s.mov_number, @testStop = s.stp_mfh_sequence, @testLgh = s.lgh_number
		FROM assetassignment a INNER JOIN stops s ON a.lgh_number = s.lgh_number
		WHERE asgn_type = 'DRV' AND asgn_id=@Drv1 and asgn_status ='STD' AND
			s.stp_status = 'OPN' AND 
			s.stp_event not in ('EMT', 'IEMT', 'EBT', 'IEBT', 'TRP', 'RTP') AND
			a.lgh_number<>@Lgh
		order by s.mov_number, s.stp_mfh_sequence
	IF ISNULL(@testMove, 0)<> 0 
		BEGIN
		RAISERROR ('Cannot arrive move %u, stop %u (on leg %u).  Unfinished prior Non-deadhead activity found for Driver %s at Move %u, stop %u (on Leg %u)', 16, 1, @Move, @Seq, @Lgh, @Drv1, @testMove, @testStop, @testLgh)
		RETURN
		END
	SELECT @Drv1StdLgh= ISNULL(min(s.lgh_number), 0), @Drv1EMTStops = COUNT(s.stp_number)
		FROM assetassignment a INNER JOIN stops s ON a.lgh_number = s.lgh_number
		WHERE asgn_type = 'DRV' AND asgn_id=@Drv1 and asgn_status ='STD' AND
			s.stp_status = 'OPN' AND 
			s.stp_event in ('EMT', 'IEMT', 'EBT', 'IEBT', 'TRP', 'RTP') AND
			a.lgh_number<>@Lgh
	SELECT @WorkDate = DATEADD(mi, -(@Drv1EMTStops+@PriorStops), @AsOfDate)
	SELECT top 1 @testMove = s.mov_number, @testStop = s.stp_mfh_sequence, @testLgh = s.lgh_number
		FROM assetassignment a INNER JOIN stops s ON a.lgh_number = s.lgh_number
		WHERE a.asgn_type = 'DRV' AND a.asgn_id=@Drv1 and a.asgn_status in ('STD', 'CMP') AND
			a.asgn_enddate >= @WorkDate AND
			s.stp_status = 'DNE' AND 
			(s.stp_arrivaldate >=@WorkDate OR 
				(s.stp_departuredate >=@WorkDate and s.stp_departure_status = 'DNE'))
		ORDER BY s.mov_number, s.stp_mfh_sequence
	IF ISNULL(@testMove, 0)<> 0 
		BEGIN
		RAISERROR ('Cannot arrive Move %u stop %u (on Leg %u) as of %s.  The activity for Driver %s on Move %u, stop %u (on Leg %u) finishes too late.', 16, 1, @Move, @Seq, @Lgh, @AsOfDateText, @Drv1, @testMove, @testStop, @testLgh)
		RETURN
		END
	IF ISNULL(@Drv1StdLgh, 0)> 0
		BEGIN
		SELECT @PDrv1 = lgh_driver1, @PDrv2 = lgh_driver2, @PTrc = lgh_tractor, 
			@PriorMove = mov_number FROM legheader WHERE lgh_number	= @Drv1StdLgh
		IF ISNULL(@PDrv1, '') = '' SELECT @PDrv1 = 'UNKNOWN'
		IF ISNULL(@PDrv2, '') = '' SELECT @PDrv2 = 'UNKNOWN'
		IF ISNULL(@PTrc, '') = '' SELECT @PTrc = 'UNKNOWN'
		IF @Drv1 <> @PDrv1 OR @Drv2 <> @PDrv2 OR @Trc <> @PTrc
			BEGIN
			RAISERROR ('Cannot start leg %u, equipment relationships changed between it and Driver 1''s prior leg (%u).', 16, 1, @Lgh, @Drv1StdLgh)
			RETURN
			END
		END
	END

IF @Drv2 <> 'UNKNOWN' 
	BEGIN 
	SELECT top 1 @testMove = s.mov_number, @testStop = s.stp_mfh_sequence, @TestLgh = s.lgh_number
		FROM assetassignment a INNER JOIN stops s ON a.lgh_number = s.lgh_number
		WHERE asgn_type = 'DRV' AND asgn_id=@Drv2 and asgn_status ='STD' AND
			s.stp_status = 'OPN' AND 
			s.stp_event not in ('EMT', 'IEMT', 'EBT', 'IEBT', 'TRP', 'RTP') AND
			a.lgh_number<>@Lgh
		order by s.mov_number, s.stp_mfh_sequence
	IF ISNULL(@testMove, 0)<> 0 
		BEGIN
		RAISERROR ('Cannot arrive move %u, stop %u (on Leg %u).  Unfinished prior Non-deadhead activity found for Driver %s at Move %u, stop %u (on Leg %u)', 16, 1, @Move, @Seq, @Lgh, @Drv2, @testMove, @testStop, @testLgh)
		RETURN
		END
	SELECT @Drv2StdLgh= ISNULL(min(s.lgh_number), 0), @Drv2EMTStops = COUNT(s.stp_number)
		FROM assetassignment a INNER JOIN stops s ON a.lgh_number = s.lgh_number
		WHERE asgn_type = 'DRV' AND asgn_id=@Drv2 and asgn_status ='STD' AND
			s.stp_status = 'OPN' AND 
			s.stp_event in ('EMT', 'IEMT', 'EBT', 'IEBT', 'TRP', 'RTP') AND
			a.lgh_number<>@Lgh
	SELECT @WorkDate = DATEADD(mi, -(@Drv2EMTStops+@PriorStops), @AsOfDate)
	SELECT top 1 @testMove = s.mov_number, @testStop = s.stp_mfh_sequence, @testLgh = s.lgh_number
		FROM assetassignment a INNER JOIN stops s ON a.lgh_number = s.lgh_number
		WHERE a.asgn_type = 'DRV' AND a.asgn_id=@Drv2 and a.asgn_status in ('STD', 'CMP') AND
			a.asgn_enddate >= @WorkDate AND
			s.stp_status = 'DNE' AND 
			(s.stp_arrivaldate >=@WorkDate OR 
				(s.stp_departuredate >=@WorkDate and s.stp_departure_status = 'DNE'))
		ORDER BY s.mov_number, s.stp_mfh_sequence
	IF ISNULL(@testMove, 0)<> 0 
		BEGIN
		RAISERROR ('Cannot arrive Move %u stop %u (on Leg %u) as of %s.  The activity for Driver %s on Move %u, stop %u (on Leg %u) finishes too late.', 16, 1, @Move, @Seq, @Lgh, @AsOfDateText, @Drv2, @testMove, @testStop, @testLgh)
		RETURN
		END
	IF ISNULL(@Drv2StdLgh, 0) <>  ISNULL(@Drv1StdLgh, 0)
		BEGIN
		RAISERROR ('Cannot start leg %u, equipment relationships changed between it and driver 2''s prior leg (%u).', 16, 1, @Lgh, @Drv2StdLgh)
		RETURN
		END
	END

IF @Trc <> 'UNKNOWN' 
	BEGIN 
	SELECT top 1 @testMove = s.mov_number, @testStop = s.stp_mfh_sequence, @testLgh = s.lgh_number
		FROM assetassignment a INNER JOIN stops s ON a.lgh_number = s.lgh_number
		WHERE asgn_type = 'TRC' AND asgn_id=@Trc and asgn_status ='STD' AND
			s.stp_status = 'OPN' AND 
			s.stp_event not in ('EMT', 'IEMT', 'EBT', 'IEBT', 'TRP', 'RTP') AND
			a.lgh_number<>@Lgh
		order by s.mov_number, s.stp_mfh_sequence
	IF ISNULL(@testMove, 0)<> 0 
		BEGIN
		RAISERROR ('Cannot arrive move %u, stop %u (on Leg %u).  Unfinished prior Non-deadhead activity found for Tractor %s at Move %u, stop %u (on Leg %u)', 16, 1, @Move, @Seq, @Lgh, @Trc, @testMove, @testStop, @testLgh)
		RETURN
		END
	SELECT @TrcStdLgh= ISNULL(min(s.lgh_number), 0), @TrcEMTStops = COUNT(s.stp_number)
		FROM assetassignment a INNER JOIN stops s ON a.lgh_number = s.lgh_number
		WHERE asgn_type = 'TRC' AND asgn_id=@Trc and asgn_status ='STD' AND
			s.stp_status = 'OPN' AND 
			s.stp_event in ('EMT', 'IEMT', 'EBT', 'IEBT', 'TRP', 'RTP') AND
			a.lgh_number<>@Lgh
	SELECT @WorkDate = DATEADD(mi, -(@TrcEMTStops+@PriorStops), @AsOfDate)
	SELECT top 1 @testMove = s.mov_number, @testStop = s.stp_mfh_sequence, @testLgh = s.lgh_number
		FROM assetassignment a INNER JOIN stops s ON a.lgh_number = s.lgh_number
		WHERE a.asgn_type = 'TRC' AND a.asgn_id=@Trc and a.asgn_status in ('STD', 'CMP') AND
			a.asgn_enddate >= @WorkDate AND
			s.stp_status = 'DNE' AND 
			(s.stp_arrivaldate >=@WorkDate OR 
				(s.stp_departuredate >=@WorkDate and s.stp_departure_status = 'DNE'))
		ORDER BY s.mov_number, s.stp_mfh_sequence
	IF ISNULL(@testMove, 0)<> 0 
		BEGIN
		RAISERROR ('Cannot arrive Move %u stop %u (on Leg %u) as of %s.  The activity for Tractor %s on Move %u, stop %u (on Leg %u) finishes too late.', 16, 1, @Move, @Seq, @Lgh, @AsOfDateText, @Trc, @testMove, @testStop, @testLgh)
		RETURN
		END
	IF ISNULL(@TrcStdLgh, 0) <>  ISNULL(@Drv1StdLgh, 0)
		BEGIN
		RAISERROR ('Cannot start leg %u, equipment relationships changed between it and the tractor''s prior leg (%u).', 16, 1, @Lgh, @TrcStdLgh)
		RETURN
		END
	END

IF @Trl <> 'UNKNOWN' 
	BEGIN 
	SELECT top 1 @testMove = s.mov_number, @testStop = s.stp_mfh_sequence, @testLgh = s.lgh_number
		FROM assetassignment a 
			INNER JOIN 
				(stops f INNER JOIN event fe ON f.stp_number = fe.stp_number)
				ON a.evt_number = fe.evt_number
			INNER JOIN 
				(stops l INNER JOIN event le ON l.stp_number = le.stp_number)
				ON a.last_evt_number = le.evt_number
			INNER JOIN stops s ON 
				s.mov_number = f.mov_number and 
				s.stp_mfh_sequence >= f.stp_mfh_sequence and 
				s.stp_mfh_sequence <= l.stp_mfh_sequence
		WHERE asgn_type = 'TRL' AND asgn_id=@Trl and asgn_status ='STD' AND
			s.stp_status = 'OPN' AND 
			s.stp_event not in ('EMT', 'IEMT', 'EBT', 'IEBT', 'TRP', 'RTP') AND
			a.mov_number<>@Move
		order by s.mov_number, s.stp_mfh_sequence
	IF ISNULL(@testMove, 0)<> 0 
		BEGIN
		RAISERROR ('Cannot arrive move %u, stop %u (on Leg %u).  Unfinished prior Non-deadhead activity found for Trailer %s at Move %u, stop %u (on Leg %u)', 16, 1, @Move, @Seq, @Lgh, @Trl, @testMove, @testStop, @testLgh)
		RETURN
		END
	SELECT @TrlStdLgh= ISNULL(min(s.lgh_number), 0), @TrlEMTStops = COUNT(s.stp_number)
		FROM assetassignment a 
			INNER JOIN 
				(stops f INNER JOIN event fe ON f.stp_number = fe.stp_number)
				ON a.evt_number = fe.evt_number
			INNER JOIN 
				(stops l INNER JOIN event le ON l.stp_number = le.stp_number)
				ON a.last_evt_number = le.evt_number
			INNER JOIN stops s ON 
				s.mov_number = f.mov_number and 
				s.stp_mfh_sequence >= f.stp_mfh_sequence and 
				s.stp_mfh_sequence <= l.stp_mfh_sequence
		WHERE asgn_type = 'TRL' AND asgn_id=@Trl and asgn_status ='STD' AND
			s.stp_status = 'OPN' AND 
			s.stp_event in ('EMT', 'IEMT', 'EBT', 'IEBT', 'TRP', 'RTP') AND
			a.mov_number<>@Move
	SELECT @WorkDate = DATEADD(mi, -(@TrlEMTStops+@PriorStops), @AsOfDate)
	SELECT top 1 @testMove = s.mov_number, @testStop = s.stp_mfh_sequence, @testLgh = s.lgh_number
		FROM assetassignment a 
			INNER JOIN 
				(stops f INNER JOIN event fe ON f.stp_number = fe.stp_number)
				ON a.evt_number = fe.evt_number
			INNER JOIN 
				(stops l INNER JOIN event le ON l.stp_number = le.stp_number)
				ON a.last_evt_number = le.evt_number
			INNER JOIN stops s ON 
				s.mov_number = f.mov_number and 
				s.stp_mfh_sequence >= f.stp_mfh_sequence and 
				s.stp_mfh_sequence <= l.stp_mfh_sequence
		WHERE a.asgn_type = 'TRL' AND a.asgn_id=@Trl and a.asgn_status in ('STD', 'CMP') AND
			a.asgn_enddate >= @WorkDate AND
			s.stp_status = 'DNE' AND 
			(s.stp_arrivaldate >=@WorkDate OR 
				(s.stp_departuredate >=@WorkDate and s.stp_departure_status = 'DNE'))
		ORDER BY s.mov_number, s.stp_mfh_sequence
	IF ISNULL(@testMove, 0)<> 0 
		BEGIN
		RAISERROR ('Cannot arrive Move %u stop %u (on Leg %u) as of %s.  The activity for Trailer %s on Move %u, stop %u (on Leg %u) finishes too late.', 16, 1, @Move, @Seq, @Lgh, @AsOfDateText, @Trl, @testMove, @testStop, @testLgh)
		RETURN
		END
	IF ISNULL(@TrlStdLgh, 0) <>  ISNULL(@Drv1StdLgh, 0) OR ISNULL(@TrlEMTStops, 0) <> ISNULL(@Drv1EMTStops, 0)
		BEGIN
		RAISERROR ('Cannot start leg %u, equipment relationships changed between it and the trailer''s prior leg (%u).', 16, 1, @Lgh, @TrlStdLgh)
		RETURN
		END
	END

-- If no stops to target, we can leave.
IF @PriorStops + @Drv1EMTStops = 0 return

-- If we get here, we can actualize the stops.
SELECT @PreProcessor = ISNULL(min(isnull(gi_string2, '')), '') FROM generalinfo where gi_name = 'DispatchPreLghProcessing' and gi_string1 = 'Y'
SELECT @PostProcessor = ISNULL(min(isnull(gi_string2, '')), '') FROM generalinfo where gi_name = 'DispatchPostLghProcessing' and gi_string1 = 'Y'

IF ISNULL(@Drv1EMTStops, 0) <> 0
	BEGIN
	SELECT top 1 @FirstStop = stp_mfh_sequence FROM stops where 
		stops.lgh_number = @Drv1StdLgh and stops.stp_status = 'OPN'
		ORDER BY stp_mfh_sequence
	IF ISNULL(@FirstStop, 0) > 1
		BEGIN
		SELECT @LastStopStatus = 'DNE'
		SELECT TOP 1 @LastStopStatus = stp_departure_status, @LastStopSeq = stp_mfh_sequence
		FROM stops
		WHERE stops.lgh_number = @Drv1StdLgh AND stp_mfh_sequence < @FirstStop
		ORDER BY stp_mfh_sequence desc
		IF ISNULL(@LastStopStatus, '') = '' SELECT @LastStopStatus = 'OPN'
		IF @LastStopStatus = 'OPN'
			UPDATE stops SET
				stp_departuredate = DATEADD(mi, -(@PriorStops+@Drv1EMTStops+1), @AsOfDate),
				stp_departure_status = 'DNE'
		WHERE lgh_number = @Drv1StdLgh AND stp_mfh_sequence = @LastStopSeq
		END
	SELECT @WorkSeq = @FirstStop
	WHILE ISNULL(@WorkSeq, 0) > 0
		BEGIN
		UPDATE stops SET
			stp_arrivaldate = DATEADD(mi, -(@PriorStops+@Drv1EMTStops+@FirstStop-stp_mfh_sequence), @AsOfDate),
			stp_departuredate = DATEADD(mi, -(@PriorStops+@Drv1EMTStops+@FirstStop-stp_mfh_sequence), @AsOfDate),
			stp_status = 'DNE',
			stp_departure_status = 'DNE'
		WHERE lgh_number = @Drv1StdLgh AND stp_mfh_sequence = @WorkSeq
		SELECT @WorkSeq = MIN(stp_mfh_sequence) FROM stops WHERE lgh_number = @Drv1StdLgh AND stp_mfh_sequence > @WorkSeq
		END
	exec dbo.update_assetassignment @PriorMove
	if @PreProcessor<>''
		BEGIN
		SELECT @execText = @PreProcessor + ' ' +CONVERT(varchar(30), @PriorMove)
		exec (@execText)
		END
	exec dbo.update_move_light @PriorMove
	if @PostProcessor<>''
		BEGIN
		SELECT @execText = @PostProcessor + ' ' +CONVERT(varchar(30), @PriorMove)
		exec (@execText)
		END	
	exec dbo.update_ord @PriorMove, @InvWhen
	END

IF ISNULL(@PriorStops, 0)> 0
	BEGIN
	SELECT @WorkSeq = 1
	WHILE ISNULL(@WorkSeq, 0) > 0
		BEGIN
		UPDATE stops SET
			stp_arrivaldate = DATEADD(mi, -(@PriorStops+1-stp_mfh_sequence), @AsOfDate),
			stp_departuredate = DATEADD(mi, -(@PriorStops+1-stp_mfh_sequence), @AsOfDate),
			stp_status = 'DNE',
			stp_departure_status = 'DNE'
		WHERE mov_number = @Move AND stp_mfh_sequence = @WorkSeq
		SELECT @WorkSeq = MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @Move AND stp_mfh_sequence > @WorkSeq AND stp_mfh_sequence < @Seq
		END
	WHILE @AsOfDate > (SELECT ISNULL(MIN(stp_arrivaldate), @AsOfDate) FROM stops WHERE lgh_number = @Lgh AND stp_mfh_sequence = @Seq)
		BEGIN
		IF @AsOfDate > (SELECT stp_departuredate FROM stops WHERE lgh_number = @Lgh AND stp_mfh_sequence = @Seq)
			UPDATE stops SET
				stp_arrivaldate = @AsOfDate,
				stp_departuredate = @AsOfDate
			WHERE mov_number = @Move AND stp_mfh_sequence = @Seq
		ELSE
			UPDATE stops SET
				stp_arrivaldate = @AsOfDate
			WHERE mov_number = @Move AND stp_mfh_sequence = @Seq
		SELECT @Seq = @Seq + 1, @AsOfDate = DATEADD(mi, 1, @AsOfDate)
		END

	exec dbo.update_assetassignment @Move
	if @PreProcessor<>''
		BEGIN
		SELECT @execText = @PreProcessor + ' ' +CONVERT(varchar(30), @Move)
		exec (@execText)
		END
	exec dbo.update_move_light @Move
	if @PostProcessor<>''
		BEGIN
		SELECT @execText = @PostProcessor + ' ' +CONVERT(varchar(30), @Move)
		exec (@execText)
		END	
	exec dbo.update_ord @PriorMove, @InvWhen
	END
END
GO
GRANT EXECUTE ON  [dbo].[tmail_CleanupDeadheads] TO [public]
GO
