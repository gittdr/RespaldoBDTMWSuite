SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_ckc_AadDecideArvDep] (
-- In:
	@sys_timeout int,	-- suppression time in minutes used by QC to reduce messaging volume;
						-- When a message or position report is sent, another position report will not occur until this time has lapsed.
	@sys_offset int, 	-- minutes to adjust position time; usually 1/2 of sysTimeout
	@ckc_lat decimal(12,4), 
	@ckc_long decimal(12,4), 
	@ckc_time datetime, 
	@ckc_tripStatus int,	-- 0 = not "in trip", stopped; 1 = "in trip", moving.
	@ckc_ign char(1),		-- 'Y'/'N'
	
	@closestStop_seq int,
	@currStop_seq int,
	@lastStop_seq int,
	@nextStop_seq int,
	@nextNextStop_seq int
	)
-- In/Out: 
--	#stops_ckc_AadMain	-- Contains stops for legheader, ordered by stp_mfh_sequence.
	
AS

SET NOCOUNT ON 

declare
	@stp_arv_status varchar(6),
	@stp_arv_time datetime,
	@stp_gfc_lat decimal(12,4),
	@stp_gfc_long decimal(12,4),
	@stp_gfc_arv_radiusMiles decimal(7,2),
	@stp_gfc_dep_radiusMiles decimal(7,2),
	@stp_gfc_dep_flags int,
	@stp_mfh_sequence int,
	@stp_aad_arvTime datetime,
	@stp_aad_lastckc_lat decimal(12,4),
	@stp_aad_lastckc_long decimal(12,4),
	@stp_aad_lastckc_time datetime,
	@stp_aad_laststartckc_lat decimal(12,4),
	@stp_aad_laststartckc_long decimal(12,4),
	@stp_aad_laststartckc_time datetime,
	@stp_aad_laststartckc_tripStatus int,
	@stp_aad_arvckc_lat decimal(12,4),
	@stp_aad_arvckc_long decimal(12,4),
	@stp_aad_arvckc_time datetime,
	@stp_aad_arvckc_tripStatus int,
	@stp_aad_depckc_lat decimal(12,4),
	@stp_aad_depckc_long decimal(12,4),
	@stp_aad_depckc_time datetime,
	@stp_aad_depckc_tripStatus int,
	@tmpstp_ckc_airmiles decimal(12,4),
	@sys_moveDistance decimal(12,4),
	@tmp_airmiles decimal(12,4),
	@tmp_time datetime,
	@tmp_do int,
	@nextstp_ckc_airmiles decimal(12,4),
	@nextstp_aad_arvckc_lat decimal(12,4),
	@nextstp_aad_arvckc_long decimal(12,4),
	@nextstp_aad_arvckc_time datetime,
	@nextstp_aad_arvckc_tripStatus int,
	@nextstp_aad_depckc_lat decimal(12,4),
	@nextstp_aad_depckc_long decimal(12,4),
	@nextstp_aad_depckc_time datetime,
	@nextstp_aad_depckc_tripStatus int,
	@nextstp_gfc_arv_radiusMiles decimal(7,2),
	@nextstp_gfc_dep_radiusMiles decimal(7,2)

set @sys_moveDistance = 0.3  -- miles away to be considered a different position. 0.3 is the resolution for QC's Casper GPS.

if isnull(@closestStop_seq,0) = 0
	begin
	RAISERROR ('PROGRAM ERROR: No closest stop passed to tm_ckc_AadDecideArvDep', 16, 1)
	return
	end

if @currStop_seq > 0
	begin
	select @tmpstp_ckc_airmiles = tmpstp_ckc_airmiles,
		@stp_aad_arvckc_lat = stp_aad_arvckc_lat,
		@stp_aad_arvckc_long = stp_aad_arvckc_long,
		@stp_aad_arvckc_time = stp_aad_arvckc_time,
		@stp_aad_arvckc_tripStatus = stp_aad_arvckc_tripStatus,
		@stp_aad_depckc_lat = stp_aad_depckc_lat,
		@stp_aad_depckc_long = stp_aad_depckc_long,
		@stp_aad_depckc_time = stp_aad_depckc_time,
		@stp_aad_depckc_tripStatus = stp_aad_depckc_tripStatus,
		@stp_gfc_dep_radiusMiles = stp_gfc_dep_radiusMiles,
		@stp_gfc_dep_flags = stp_gfc_dep_flags
		from #stops_ckc_AadMain 
		where stp_mfh_sequence = @currStop_seq

	set @tmp_airmiles = -999999
	if isnull(@stp_aad_arvckc_lat,0) <> 0 or isnull(@stp_aad_arvckc_long,0) <> 0 
		exec dbo.tmail_AirDistance @ckc_lat, @ckc_long, @stp_aad_arvckc_lat, @stp_aad_arvckc_long, @tmp_airmiles out
	if @tmp_airmiles > @stp_gfc_dep_radiusMiles  
		-- Moved beyond depart radius (re-centered to aad arrival location).
		-- BOT (beginning of trip) was suppressed.
		if isnull(@stp_aad_depckc_lat,0) <> 0 or isnull(@stp_aad_depckc_long,0) <> 0 
			begin
				set @tmp_time = dateadd(minute, @sys_offset, @stp_aad_depckc_time)
				--print 'exec AadIssueDep 1'
				exec dbo.tm_ckc_AadIssueDep @currStop_seq, @tmp_time, 1, 
				@stp_aad_depckc_time, @stp_aad_depckc_lat, @stp_aad_depckc_long, @stp_aad_depckc_tripStatus, 1, @sys_offset, @currStop_seq, @lastStop_seq
			end
		else
			begin
				set @tmp_time = dateadd(minute, @sys_offset, @stp_aad_arvckc_time)
				--print 'exec AadIssueDep 2'
				exec dbo.tm_ckc_AadIssueDep @currStop_seq, @tmp_time, 0, 
				@stp_aad_arvckc_time, @stp_aad_arvckc_lat, @stp_aad_arvckc_long, @stp_aad_arvckc_tripStatus, 1, @sys_offset, @currStop_seq, @lastStop_seq
			end
	else
		if (@ckc_tripStatus & 1) <> 0
			-- moving; this is a BOT
			if @stp_gfc_dep_flags & 1 <> 0 
				-- Hold depart until outside depart radius
				update #stops_ckc_AadMain set
					tmpstp_updateStop = 1,
					stp_aad_depckc_lat = @ckc_lat,
					stp_aad_depckc_long = @ckc_long,
					stp_aad_depckc_time = dateadd(minute, - @sys_offset, @ckc_time),	-- will be actual ckc time after issuing process adds 5 minutes
					stp_aad_depckc_tripStatus = @ckc_tripStatus
				where stp_mfh_sequence = @currStop_seq
			else
				begin
					--print 'exec AadIssueDep 3'
					exec dbo.tm_ckc_AadIssueDep @currStop_seq, @ckc_time, 1, 
					@ckc_time, @ckc_lat, @ckc_long, @ckc_tripStatus, 1, @sys_offset, @currStop_seq, @lastStop_seq
				end
		else
			-- not moving
			-- Save position in case this supresses the BOT.
			update #stops_ckc_AadMain set
				tmpstp_updateStop = 1,
				stp_aad_depckc_lat = @ckc_lat,
				stp_aad_depckc_long = @ckc_long,
				stp_aad_depckc_time = @ckc_time,
				stp_aad_depckc_tripStatus = @ckc_tripStatus
				where stp_mfh_sequence = @currStop_seq
	end	

select @tmpstp_ckc_airmiles = tmpstp_ckc_airmiles,
	@stp_arv_status = stp_arv_status,
	@stp_arv_time = stp_arv_time,
	@stp_aad_arvTime = stp_aad_arvTime,
	@stp_aad_arvckc_lat = stp_aad_arvckc_lat,
	@stp_aad_arvckc_long = stp_aad_arvckc_long,
	@stp_aad_arvckc_time = stp_aad_arvckc_time,
	@stp_aad_depckc_lat = stp_aad_depckc_lat,
	@stp_aad_depckc_long = stp_aad_depckc_long,
	@stp_aad_depckc_time = stp_aad_depckc_time,
	@stp_aad_laststartckc_lat = stp_aad_laststartckc_lat,
	@stp_aad_laststartckc_long = stp_aad_laststartckc_long,
	@stp_aad_laststartckc_time = stp_aad_laststartckc_time,
	@stp_aad_laststartckc_tripStatus = stp_aad_laststartckc_tripStatus,
	@stp_gfc_arv_radiusMiles = stp_gfc_arv_radiusMiles, -- Used as inner fence.
	@stp_gfc_dep_radiusMiles = stp_gfc_dep_radiusMiles	-- Used as outer fence.
from #stops_ckc_AadMain 
where stp_mfh_sequence = @closestStop_seq

if @tmpstp_ckc_airmiles <= @stp_gfc_arv_radiusMiles
	-- within fence
	begin
	if @nextNextStop_seq = @closestStop_seq
		begin
		select @nextstp_ckc_airmiles = tmpstp_ckc_airmiles,
			@nextstp_aad_arvckc_lat = stp_aad_arvckc_lat,
			@nextstp_aad_arvckc_long = stp_aad_arvckc_long,
			@nextstp_aad_arvckc_time = stp_aad_arvckc_time,
			@nextstp_aad_arvckc_tripStatus = stp_aad_arvckc_tripstatus,
			@nextstp_aad_depckc_lat = stp_aad_depckc_lat,
			@nextstp_aad_depckc_long = stp_aad_depckc_long,
			@nextstp_aad_depckc_time = stp_aad_depckc_time,
			@nextstp_aad_depckc_tripStatus = stp_aad_depckc_tripStatus,
			@nextstp_gfc_arv_radiusMiles = stp_gfc_arv_radiusMiles, -- Used as inner fence.
			@nextstp_gfc_dep_radiusMiles = stp_gfc_dep_radiusMiles	-- Used as outer fence.
		from #stops_ckc_AadMain 
		where stp_mfh_sequence = @nextStop_seq
		if isnull(@nextstp_aad_arvckc_lat,0) <> 0 or isnull(@nextstp_aad_arvckc_long,0) <> 0 
			begin
			if @nextstp_ckc_airmiles > @nextstp_gfc_dep_radiusMiles
				-- Beyond outer fence
				if isnull(@nextstp_aad_depckc_lat,0) <> 0 or isnull(@nextstp_aad_depckc_long,0) <> 0 
					begin
						--print 'exec AadIssueDep 8'
						exec dbo.tm_ckc_AadIssueDep @nextStop_seq, @nextstp_aad_depckc_time, 0, 
						@nextstp_aad_depckc_time, @nextstp_aad_depckc_lat, @nextstp_aad_depckc_long, @nextstp_aad_depckc_tripStatus, 1, @sys_offset, @currStop_seq, @lastStop_seq
					end
				else
					begin
						set @tmp_time = dateadd(minute, @sys_offset, @nextstp_aad_arvckc_time)
						--print 'exec AadIssueDep 9'
						exec dbo.tm_ckc_AadIssueDep @nextStop_seq, @tmp_time, 0, 
						@nextstp_aad_arvckc_time, @nextstp_aad_arvckc_lat, @nextstp_aad_arvckc_long, @nextstp_aad_arvckc_tripStatus, 1, @sys_offset, @currStop_seq, @lastStop_seq
					end
			end
		end
	if @closestStop_seq > @lastStop_seq
		-- not arrived
		if (@ckc_tripStatus & 1) <> 0
			-- moving
			if isnull(@stp_aad_arvckc_lat,0) <> 0 or isnull(@stp_aad_arvckc_long,0) <> 0 
				begin
					exec dbo.tmail_AirDistance @stp_gfc_lat, @stp_gfc_long, @stp_aad_arvckc_lat, @stp_aad_arvckc_long, @tmp_airmiles out				
					if @tmp_airmiles > @tmpstp_ckc_airmiles
					-- new position is closer to stop
					update #stops_ckc_AadMain set
						tmpstp_UpdateStop = 1,
						stp_aad_arvckc_time = @ckc_time,
						stp_aad_arvckc_lat = @ckc_lat,
						stp_aad_arvckc_long = @ckc_long,
						stp_aad_arvckc_tripStatus = @ckc_tripStatus,
						stp_aad_depckc_time = null,
						stp_aad_depckc_lat = null,
						stp_aad_depckc_long = null,
						stp_aad_depckc_tripStatus = null
						where stp_mfh_sequence = @closestStop_seq
				else 
					if isnull(@stp_aad_depckc_lat,0) = 0 and isnull(@stp_aad_depckc_long,0) = 0
						update #stops_ckc_AadMain set
							tmpstp_updateStop = 1,
							stp_aad_depckc_time = @ckc_time,
							stp_aad_depckc_lat = @ckc_lat,
							stp_aad_depckc_long = @ckc_long,
							stp_aad_depckc_tripStatus = @ckc_tripStatus
							where stp_mfh_sequence = @closestStop_seq
				end
			else
				update #stops_ckc_AadMain set
					tmpstp_updateStop = 1,
					stp_aad_arvckc_time = @ckc_time,
					stp_aad_arvckc_lat = @ckc_lat,
					stp_aad_arvckc_long = @ckc_long,
					stp_aad_arvckc_tripStatus = @ckc_tripStatus,
					stp_aad_depckc_time = null,
					stp_aad_depckc_lat = null,
					stp_aad_depckc_long = null,
					stp_aad_depckc_tripStatus = null
					where stp_mfh_sequence = @closestStop_seq
		else
			-- not moving
			begin
			set @tmp_airmiles = 999999.0
			if isnull(@stp_aad_lastckc_lat,0) <> 0 or isnull(@stp_aad_lastckc_long,0) <> 0 
				exec dbo.tmail_AirDistance @ckc_lat, @ckc_long, @stp_aad_lastckc_lat, @stp_aad_lastckc_long, @tmp_airmiles out
			if @tmp_airmiles < @sys_moveDistance	
				-- Prior activity was at same location, so probably suppressed the true EOT.  Cut Arrival 
				--    based on whichever of the following would give the earliest time:
				--    1. Prior activity Start - 5 mins (placing the EOT suppression event in the midst of the 
				--		supression period).
				--    2. If Ignition = "Y" then Posn.Date - 10 mins (if ignition on, must have been at least 
				--		10 mins or status would not have changed)
				--    3. If Ignition = "N" then Posn.Date (Which must be greater than the option 1, since 
				--		Prior Activity, by definition, occurred BEFORE the current position time, so the
				--		following does not even bother to check for this case).
				begin
					set @tmp_do = 0
					if isnull(@stp_aad_laststartckc_lat,0) <> 0 or isnull(@stp_aad_laststartckc_long,0) <> 0
						if (dateadd(minute, - @sys_offset, @stp_aad_laststartckc_time) < dateadd(minute, - @sys_timeout, @ckc_time))
						set @tmp_do = 1
					if @tmp_do = 1					
					begin
						set @tmp_time = dateadd(minute, - @sys_offset, @stp_aad_laststartckc_time)
						--print 'exec AadIssueArv 4'
						exec dbo.tm_ckc_AadIssueArv @closestStop_seq, @tmp_time, 1, 
						@stp_aad_laststartckc_time, @stp_aad_laststartckc_lat, @stp_aad_laststartckc_long, @stp_aad_laststartckc_tripStatus, 1, @sys_offset, @currStop_seq, @lastStop_seq
					end
				else
					begin
						set @tmp_time = dateadd(minute, - @sys_timeout, @ckc_time)
						--print 'exec AadIssueArv 5'
						exec dbo.tm_ckc_AadIssueArv @closestStop_seq, @tmp_time, 1, 
						@ckc_time, @ckc_lat, @ckc_long, @ckc_tripStatus, 1, @sys_offset, @currStop_seq, @lastStop_seq
					end
				end
			else
				-- true EOT
			if (@ckc_ign = 'Y') AND (ISNULL(@stp_aad_lastckc_lat,0) <> 0 or ISNULL(@stp_aad_lastckc_long,0) <> 0) AND (@lastStop_seq = 0)
			--if @ckc_ign = 'Y' 
				begin
					set @tmp_time = dateadd(minute, - @sys_timeout, @ckc_time)
					--print 'exec AadIssueArv 6'
					exec dbo.tm_ckc_AadIssueArv @closestStop_seq, @tmp_time, 1,	@ckc_time, @ckc_lat, @ckc_long, 
												@ckc_tripStatus, 1, @sys_offset, @currStop_seq, @lastStop_seq
				end
			else
				begin
					--print 'exec AadIssueArv 7'
					exec dbo.tm_ckc_AadIssueArv @closestStop_seq, @ckc_time, 1, @ckc_time, @ckc_lat, @ckc_long, 
												@ckc_tripStatus, 1, @sys_offset, @currStop_seq, @lastStop_seq
				end
			end	
	end
else
	-- not within fence
	if @nextStop_seq > 0
		begin
		select @nextstp_ckc_airmiles = tmpstp_ckc_airmiles,
			@nextstp_aad_arvckc_lat = stp_aad_arvckc_lat,
			@nextstp_aad_arvckc_long = stp_aad_arvckc_long,
			@nextstp_aad_arvckc_time = stp_aad_arvckc_time,
			@nextstp_aad_arvckc_tripStatus = stp_aad_arvckc_tripstatus,
			@nextstp_aad_depckc_lat = stp_aad_depckc_lat,
			@nextstp_aad_depckc_long = stp_aad_depckc_long,
			@nextstp_aad_depckc_time = stp_aad_depckc_time,
			@nextstp_aad_depckc_tripStatus = stp_aad_depckc_tripStatus,
			@nextstp_gfc_arv_radiusMiles = stp_gfc_arv_radiusMiles, -- Used as inner fence.
			@nextstp_gfc_dep_radiusMiles = stp_gfc_dep_radiusMiles	-- Used as outer fence.
			from #stops_ckc_AadMain where stp_mfh_sequence = @nextStop_seq
		if isnull(@nextstp_aad_arvckc_lat,0) <> 0 or isnull(@nextstp_aad_arvckc_long,0) <> 0 
			if @nextstp_ckc_airmiles > @nextstp_gfc_dep_radiusMiles
				begin
				-- Beyond outer fence
				if isnull(@nextstp_aad_depckc_lat,0) <> 0 or isnull(@nextstp_aad_depckc_long,0) <> 0 
					begin
					--print 'exec AadIssueDep 8'
					exec dbo.tm_ckc_AadIssueDep @nextStop_seq, @nextstp_aad_depckc_time, 0, 
						@nextstp_aad_depckc_time, @nextstp_aad_depckc_lat, @nextstp_aad_depckc_long, @nextstp_aad_depckc_tripStatus, 1, @sys_offset, @currStop_seq, @lastStop_seq
					end
				else
					begin
					set @tmp_time = dateadd(minute, @sys_offset, @nextstp_aad_arvckc_time)
					--print 'exec AadIssueDep 9'
					exec dbo.tm_ckc_AadIssueDep @nextStop_seq, @tmp_time, 0, 
						@nextstp_aad_arvckc_time, @nextstp_aad_arvckc_lat, @nextstp_aad_arvckc_long, @nextstp_aad_arvckc_tripStatus, 1, @sys_offset, @currStop_seq, @lastStop_seq
					end
				end
			else
				if isnull(@stp_aad_depckc_lat,0) = 0 and isnull(@stp_aad_depckc_long,0) = 0
					update #stops_ckc_AadMain set
						tmpstp_updateStop = 1,
						stp_aad_depckc_time = @ckc_time,
						stp_aad_depckc_lat = @ckc_lat,
						stp_aad_depckc_long = @ckc_long,
						stp_aad_depckc_tripStatus = @ckc_tripStatus
						where stp_mfh_sequence = @nextStop_seq
		end

select @stp_aad_lastckc_lat = stp_aad_lastckc_lat,
	@stp_aad_lastckc_long = stp_aad_lastckc_long
from #stops_ckc_AadMain 
where stp_mfh_sequence = @closestStop_seq

set @tmp_airmiles = 999999
if isnull(@stp_aad_laststartckc_lat,0) <> 0 or isnull(@stp_aad_laststartckc_long,0) <> 0
	exec dbo.tmail_AirDistance @ckc_lat, @ckc_long, @stp_aad_laststartckc_lat, @stp_aad_laststartckc_long, @tmp_airmiles out
if @tmp_airmiles > @sys_moveDistance
	-- moved from last position; set new last position start
	update #stops_ckc_AadMain set
		tmpstp_updateStop = 1,
		stp_aad_laststartckc_lat = @ckc_lat,
		stp_aad_laststartckc_long = @ckc_long,
		stp_aad_laststartckc_time = @ckc_time,
		stp_aad_laststartckc_tripStatus = @ckc_tripStatus
		where stp_mfh_sequence = @closestStop_seq

update #stops_ckc_AadMain set
	tmpstp_updateStop = 1,
	stp_aad_lastckc_lat = @ckc_lat,
	stp_aad_lastckc_long = @ckc_long,
	stp_aad_lastckc_time = @ckc_time,
	stp_aad_lastckc_tripStatus = @ckc_tripStatus
	where stp_mfh_sequence = @closestStop_seq
	
GO
GRANT EXECUTE ON  [dbo].[tm_ckc_AadDecideArvDep] TO [public]
GO
