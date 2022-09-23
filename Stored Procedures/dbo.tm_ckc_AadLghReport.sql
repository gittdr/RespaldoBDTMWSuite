SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_ckc_AadLghReport] (@lgh_number int)

AS

SET NOCOUNT ON

DECLARE
	@stp_mfh_sequence int,
	@stp_number int,
	@stp_arv_status varchar(6),
	@stp_arv_time datetime,
	@stp_dep_status varchar(6),
	@stp_dep_time datetime,
	@stp_gfc_lat decimal(12,4), 
	@stp_gfc_long decimal(12,4), 
	@stp_aad_arvTime datetime,
	@stp_aad_arvConfidence int,
	@stp_aad_depTime datetime,
	@stp_aad_DepConfidence int,
	@stp_aad_lastckc_lat decimal(12,4), 
	@stp_aad_lastckc_long decimal(12,4), 
	@stp_aad_laststartckc_lat decimal(12,4), 
	@stp_aad_laststartckc_long decimal(12,4), 
	@stp_aad_arvckc_lat decimal(12,4), 
	@stp_aad_arvckc_long decimal(12,4), 
	@stp_aad_depckc_lat decimal(12,4), 
	@stp_aad_depckc_long decimal(12,4), 
	@lastckc_dist decimal(12,4),
	@laststartckc_dist decimal(12,4),
	@arvckc_dist decimal(12,4),
	@depckc_dist decimal(12,4),
	@dum_time datetime,
	@dum_tz_hours int,
	@dum_tz_mins int,
	@dum_tz_dstCode int
	
select 
	@lastckc_dist = 0.0,
	@laststartckc_dist = 0.0,
	@arvckc_dist = 0.0,
	@depckc_dist = 0.0

select stp_mfh_sequence Seq, stp_number StopNum, cmp_id Company, 
	'       ' ArrivedBy,
	ArriveDIFf = convert(int,0),
	'       ' DepartedBy,
	DepartDIFf = convert(int,0),
	stp_status ArvStatus, 
	left(convert(varchar,stp_arrivaldate,20),16) ArvTime,
	stp_departure_status DepStatus,
	left(convert(varchar,stp_departuredate,20),16) DepTime,
	left(convert(varchar,stp_aad_arvTime,20),16) AadArvTime, 
	stp_aad_arvConfidence AadArvConf, 
	left(convert(varchar,stp_aad_depTime,20),16) AadDepTime, 
	stp_aad_depConfidence AadDepConf,
	stp_gfc_arv_radiusMiles ArvRadius, stp_gfc_dep_radiusMiles DepRadius,
	stp_gfc_lat Latitude, stp_gfc_long Longitude,
	left(convert(varchar,stp_aad_lastckc_time,20),16) LastCkcTime, 
	@lastckc_dist LastCkcDist, stp_aad_lastckc_lat LastCkcLat, stp_aad_lastckc_long LastCkcLong,
	stp_aad_lastckc_tripStatus LastCkcStatus, 
	left(convert(varchar,stp_aad_laststartckc_time,20),16) LastStartCkcTime, 
	@laststartckc_dist LastStartCkcDist, stp_aad_laststartckc_lat LastStartCkcLat, stp_aad_laststartckc_long LastStartCkcLong,
	stp_aad_laststartckc_tripStatus LastStartCkcStatus,
	left(convert(varchar,stp_aad_arvckc_time,20),16) ArvCkcTime, 
	@arvckc_dist ArvCkcDist, stp_aad_arvckc_lat ArvCkcLat, stp_aad_arvckc_long ArvCkcLong,
	stp_aad_arvckc_tripStatus ArvCkcStatus,
	left(convert(varchar,stp_aad_depckc_time,20),16) DepCkcTime, 
	@depckc_dist DepCkcDist, stp_aad_depckc_lat DepCkcLat, stp_aad_depckc_long DepCkcLong,
	stp_aad_depckc_tripStatus DepCkcStatus
	INTO #stops
	FROM stops 
	WHERE lgh_number = @lgh_number
	ORDER BY stp_mfh_sequence

select @stp_mfh_sequence = min(Seq) from #stops
select @stp_mfh_sequence = isnull(@stp_mfh_sequence,0)
while (@stp_mfh_sequence <> 0)
	BEGIN
	select
		@stp_number = StopNum,
		@stp_arv_status = ArvStatus, 
		@stp_aad_arvTime = AadArvTime, @stp_aad_arvConfidence = AadArvConf,
		@stp_dep_status = DepStatus, 
		@stp_aad_depTime = AadDepTime, @stp_aad_depConfidence = AadDepConf,
		@stp_gfc_lat = Latitude, @stp_gfc_long = Longitude,
		@stp_aad_lastckc_lat = LastCkcLat, @stp_aad_lastckc_long = LastCkcLong,
		@stp_aad_laststartckc_lat = LastStartCkcLat, @stp_aad_laststartckc_long = LastStartCkcLong,
		@stp_aad_arvckc_lat = ArvCkcLat, @stp_aad_arvckc_long = ArvCkcLong,
		@stp_aad_depckc_lat = DepCkcLat, @stp_aad_depckc_long = DepCkcLong
		FROM #stops 
		WHERE Seq = @stp_mfh_sequence
	
	-- Convert stop arv and dep times to system time zone for comparison with checkcall times.
	-- Note: Proc gets stop times FROM stops table.
	EXEC dbo.stp_cvtToSysTZ @stp_number, @stp_arv_time out, @stp_dep_time out, @dum_time, @dum_time, @dum_time, @dum_time, @dum_tz_hours, @dum_tz_mins, @dum_tz_dstCode

	EXEC dbo.tmail_AirDistance @stp_aad_lastckc_lat, @stp_aad_lastckc_long, @stp_gfc_lat, @stp_gfc_long, @lastckc_dist out
	EXEC dbo.tmail_AirDistance @stp_aad_laststartckc_lat, @stp_aad_laststartckc_long, @stp_gfc_lat, @stp_gfc_long, @laststartckc_dist out
	EXEC dbo.tmail_AirDistance @stp_aad_arvckc_lat, @stp_aad_arvckc_long, @stp_gfc_lat, @stp_gfc_long, @arvckc_dist out
	EXEC dbo.tmail_AirDistance @stp_aad_depckc_lat, @stp_aad_depckc_long, @stp_gfc_lat, @stp_gfc_long, @depckc_dist out
		
	UPDATE #stops SET
		ArrivedBy = case 
			WHEN isnull(@stp_arv_status,'OPN') = 'DNE' and isnull(@stp_aad_arvConfidence,-1) <> -1
				and left(convert(varchar,@stp_aad_arvTime,20),16) = left(convert(varchar,@stp_arv_time,20),16) then 'Auto'
			WHEN isnull(@stp_arv_status,'OPN') = 'DNE' then 'Drv/Dsp'
			ELSE 'No'
			END,
		ArriveDIFf = datedIFf(minute,@stp_arv_time,@stp_aad_arvTime),
		DepartedBy = case 
			WHEN isnull(@stp_dep_status,'OPN') = 'DNE' and isnull(@stp_aad_depConfidence,-1) <> -1
				and left(convert(varchar,@stp_aad_depTime,20),16) = left(convert(varchar,@stp_dep_time,20),16) then 'Auto'
			WHEN isnull(@stp_dep_status,'OPN') = 'DNE' then 'Drv/Dsp'
			ELSE 'No'
			END,
		DepartDIFf = datedIFf(minute,@stp_dep_time,@stp_aad_depTime),
		LastCkcDist = @lastckc_dist,
		LastStartCkcDist = @laststartckc_dist,
		ArvCkcDist = @arvckc_dist,
		DepCkcDist = @depckc_dist
		WHERE Seq = @stp_mfh_sequence
		
	select @stp_mfh_sequence = min(Seq) from #stops
		WHERE Seq > @stp_mfh_sequence
	select @stp_mfh_sequence = isnull(@stp_mfh_sequence,0)
	END

select * from #stops

GO
GRANT EXECUTE ON  [dbo].[tm_ckc_AadLghReport] TO [public]
GO
