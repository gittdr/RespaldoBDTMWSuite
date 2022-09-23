SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_ckc_AadIssueArv] (
	@stpSeq int,
	@arvTime datetime,
	@arvConfidence int,
	@ckcTime datetime,
	@ckcLat decimal(12,4),
	@ckcLong decimal(12,4),
	@ckcTripStatus int,
	@clearLater int,
	@sysOffset int,
	@currStopSeq int,
	@lastStopSeq int
	)
AS

SET NOCOUNT ON 

declare @stp_mfh_sequence int,
	@stp_dep_status varchar(6),
	@stp_dep_time datetime,
	@stp_aad_depTime datetime,
	@stp_aad_depckc_time datetime,
	@stp_aad_depckc_lat decimal(12,4),
	@stp_aad_depckc_long decimal(12,4),
	@stp_aad_depckc_tripStatus int,
	@tmp_time datetime
	
/*
print 'AadIssueArv:' + isnull(convert(varchar(30),@stpSeq),'NULL') + '|' 
	+ isnull(convert(varchar(30),@arvTime),'NULL') + '|' 
	+ isnull(convert(varchar(30),@arvConfidence),'NULL') + '|' 
	+ isnull(convert(varchar(30),@ckcTime),'NULL') + '|' 
	+ isnull(convert(varchar(30),@ckcLat),'NULL') + '|' 
	+ isnull(convert(varchar(30),@ckcLong),'NULL') + '|' 
	+ isnull(convert(varchar(30),@ckcTripStatus),'NULL') + '|' 
	+ isnull(convert(varchar(30),@clearLater),'NULL') + '|' 
	+ isnull(convert(varchar(30),@sysOffset),'NULL') + '|'
*/

select @stp_mfh_sequence = max(stp_mfh_sequence) 
from #stops_ckc_AadMain 
where stp_mfh_sequence < @stpSeq

set @stp_mfh_sequence = isnull(@stp_mfh_sequence,0)
if @stp_mfh_sequence <> 0
	-- Prior stop exists
	begin
	select 
		@stp_dep_status = stp_dep_status,
		@stp_dep_time = stp_dep_time,
		@stp_aad_depTime = stp_aad_depTime,
		@stp_aad_depckc_time = stp_aad_depckc_time,
		@stp_aad_depckc_lat = stp_aad_depckc_lat,
		@stp_aad_depckc_long = stp_aad_depckc_long,
		@stp_aad_depckc_tripStatus = stp_aad_depckc_tripStatus
	from #stops_ckc_AadMain 
	where stp_mfh_sequence = @stp_mfh_sequence
	
	if @stp_mfh_sequence = @currStopSeq or @stp_mfh_sequence > @lastStopSeq
		-- Prior stop is not departed
		if isnull(@stp_aad_depckc_lat,0) <> 0 or isnull(@stp_aad_depckc_long,0) <> 0 
			begin
			set @tmp_time = dateadd(minute, - @sysOffset, @stp_aad_depckc_time)
			exec dbo.tm_ckc_AadIssueDep @stp_mfh_sequence, @tmp_time, 0, 
				@stp_aad_depckc_time, @stp_aad_depckc_lat, @stp_aad_depckc_long, @stp_aad_depckc_tripStatus, 0, @sysOffset, @currStopSeq, @lastStopSeq
			end
		else
			if @stp_dep_time > @arvTime
				exec dbo.tm_ckc_AadIssueDep @stp_mfh_sequence, @arvTime, 0, 
					@ckcTime, @ckcLat, @ckcLong, @ckcTripStatus, 0, @sysOffset, @currStopSeq, @lastStopSeq
			else
				exec dbo.tm_ckc_AadIssueDep @stp_mfh_sequence, @stp_dep_time, 0, 
					@ckcTime, @ckcLat, @ckcLong, @ckcTripStatus, 0, @sysOffset, @currStopSeq, @lastStopSeq
	end

update #stops_ckc_AadMain set
	stp_aad_arvckc_time = @ckcTime,
	stp_aad_arvckc_lat = @ckcLat,
	stp_aad_arvckc_long = @ckcLong,
	stp_aad_arvckc_tripStatus = @ckcTripStatus,
	stp_aad_arvTime = @arvTime,
	stp_aad_arvConfidence = @arvConfidence,
	tmpstp_issueArrive = 1,
	tmpstp_updateStop = 1
	where stp_mfh_sequence = @stpSeq

if @clearLater = 1 
	begin
	update #stops_ckc_AadMain set
		stp_aad_depckc_time = null, stp_aad_depckc_lat = null, stp_aad_depckc_long = null, stp_aad_depckc_tripStatus = null,
		tmpstp_updateStop = 1
		where stp_mfh_sequence = @stpSeq
	
	select @stp_mfh_sequence = min(stp_mfh_sequence) 
	from #stops_ckc_AadMain 
	where stp_mfh_sequence > @stpSeq
	
	set @stp_mfh_sequence = isnull(@stp_mfh_sequence,0)
	while (@stp_mfh_sequence <> 0)
		begin
		update #stops_ckc_AadMain set
			stp_aad_arvckc_time = null, stp_aad_arvckc_lat = null, stp_aad_arvckc_long = null, stp_aad_arvckc_tripStatus = null,
			stp_aad_depckc_time = null, stp_aad_depckc_lat = null, stp_aad_depckc_long = null, stp_aad_depckc_tripStatus = null,
			tmpstp_updateStop = 1
			where stp_mfh_sequence = @stp_mfh_sequence
		select @stp_mfh_sequence = min(stp_mfh_sequence) 
		from #stops_ckc_AadMain 
		where stp_mfh_sequence > @stp_mfh_sequence
		
		set @stp_mfh_sequence = isnull(@stp_mfh_sequence,0)
		end		
	end			

GO
GRANT EXECUTE ON  [dbo].[tm_ckc_AadIssueArv] TO [public]
GO
