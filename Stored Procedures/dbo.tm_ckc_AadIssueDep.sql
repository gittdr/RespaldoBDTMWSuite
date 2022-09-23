SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_ckc_AadIssueDep] (
	@stpSeq int,
	@depTime datetime,
	@depConfidence int,
	@ckcTime datetime,
	@ckcLat decimal(12,4),
	@ckcLong decimal(12,4),
	@ckcTripStatus int,
	@clearLater int,
	@sysOffSET int,
	@currStopSeq int,
	@lastStopSeq int
	)
AS

DECLARE @stp_mfh_sequence int,
	@stp_arv_status varchar(6),
	@stp_arv_time datetime,
	@stp_aad_arvTime datetime,
	@stp_aad_arvckc_time datetime,
	@stp_aad_arvckc_lat decimal(12,4),
	@stp_aad_arvckc_long decimal(12,4),
	@stp_aad_arvckc_tripStatus int,
	@tmp_time datetime
	
/*
print 'AadIssueDep:' + isnull(convert(varchar(30),@stpSeq),'NULL') + '|' 
	+ isnull(convert(varchar(30),@depTime),'NULL') + '|' 
	+ isnull(convert(varchar(30),@depConfidence),'NULL') + '|' 
	+ isnull(convert(varchar(30),@ckcTime),'NULL') + '|' 
	+ isnull(convert(varchar(30),@ckcLat),'NULL') + '|' 
	+ isnull(convert(varchar(30),@ckcLong),'NULL') + '|' 
	+ isnull(convert(varchar(30),@ckcTripStatus),'NULL') + '|' 
	+ isnull(convert(varchar(30),@clearLater),'NULL') + '|' 
	+ isnull(convert(varchar(30),@sysOffSET),'NULL') + '|'
*/

SELECT 
	@stp_mfh_sequence = stp_mfh_sequence,
	@stp_arv_status = stp_arv_status,
	@stp_arv_time = stp_arv_time,
	@stp_aad_arvTime = stp_aad_arvTime, 
	@stp_aad_arvckc_time = stp_aad_arvckc_time,
	@stp_aad_arvckc_lat = stp_aad_arvckc_lat,
	@stp_aad_arvckc_long = stp_aad_arvckc_long,
	@stp_aad_arvckc_tripStatus = stp_aad_arvckc_tripStatus
FROM #stops_ckc_AadMain 
WHERE stp_mfh_sequence = @stpSeq

IF @stp_mfh_sequence > @lastStopSeq
	-- Not arrived.
	IF isnull(@stp_aad_arvckc_lat,0) <> 0 or isnull(@stp_aad_arvckc_long,0) <> 0 
		-- Arrive position exists.
		BEGIN
		SET @tmp_time = dateadd(minute, - @sysOffSET, @stp_aad_arvckc_time)
		exec dbo.tm_ckc_AadIssueArv @stp_mfh_sequence, @tmp_time, 0, 
			@stp_aad_arvckc_time, @stp_aad_arvckc_lat, @stp_aad_arvckc_long, @stp_aad_arvckc_tripStatus, 0, @sysOffSET, @currStopSeq, @lastStopSeq
		END
	ELSE		
		IF @stp_arv_time > @depTime
			exec dbo.tm_ckc_AadIssueArv @stp_mfh_sequence, @depTime, 0, 
				@ckcTime, @ckcLat, @ckcLong, @ckcTripStatus, 0, @sysOffSET, @currStopSeq, @lastStopSeq
		ELSE
			exec dbo.tm_ckc_AadIssueArv @stp_mfh_sequence, @stp_arv_time, 0, 
				@ckcTime, @ckcLat, @ckcLong, @ckcTripStatus, 0, @sysOffSET, @currStopSeq, @lastStopSeq

update #stops_ckc_AadMain SET
	stp_aad_depckc_time = @ckcTime,
	stp_aad_depckc_lat = @ckcLat,
	stp_aad_depckc_long = @ckcLong,
	stp_aad_depckc_tripStatus = @ckcTripStatus,
	stp_aad_depTime = @depTime,
	stp_aad_depConfidence = @depConfidence,
	tmpstp_issueDepart = 1,
	tmpstp_updateStop = 1
	WHERE stp_mfh_sequence = @stpSeq

IF @clearLater = 1 
	BEGIN
		SELECT @stp_mfh_sequence = min(stp_mfh_sequence) 
		FROM #stops_ckc_AadMain 
		WHERE stp_mfh_sequence > @stpSeq
	
		SET @stp_mfh_sequence = isnull(@stp_mfh_sequence,0)
	while (@stp_mfh_sequence <> 0)
		BEGIN
			update #stops_ckc_AadMain SET
			stp_aad_arvckc_time = null, stp_aad_arvckc_lat = null, stp_aad_arvckc_long = null, stp_aad_arvckc_tripStatus = null,
			stp_aad_depckc_time = null, stp_aad_depckc_lat = null, stp_aad_depckc_long = null, stp_aad_depckc_tripStatus = null,
			tmpstp_updateStop = 1
			WHERE stp_mfh_sequence = @stp_mfh_sequence
			
			SELECT @stp_mfh_sequence = min(stp_mfh_sequence) 
			FROM #stops_ckc_AadMain 
			WHERE stp_mfh_sequence > @stp_mfh_sequence
			SET @stp_mfh_sequence = isnull(@stp_mfh_sequence,0)
		END		
	END			

GO
GRANT EXECUTE ON  [dbo].[tm_ckc_AadIssueDep] TO [public]
GO
