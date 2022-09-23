SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_ckc_AadMain] @ckcnum int

AS

SET NOCOUNT ON

DECLARE 
	@ckc_asgnid varchar(13),
	@ckc_lat decimal(12,4),
	@ckc_long decimal(12,4),
	@ckc_latseconds int,
	@ckc_longseconds int,
	@ckc_time datetime,
	@ckc_tripStatus int,
	@ckc_ignition char(1),	-- Y/N
	@cty_latitude decimal(12,4),
	@cty_longitude decimal(12,4),
	@cmp_id varchar(25), --PTS 61189 INCREASE LENGTH TO 25
	@cmp_latseconds int,
	@cmp_longseconds int,
	@lgh_number int,
	@mov_number int,
	@msd_seq int,
	@sqlmsg_id int,			-- TMSQLMessage row identity column value
	@stp_number int,
	@stp_mfh_sequence int,
	@stp_event char(6),
	@stp_city int,
	@stp_arv_status varchar(6),
	@stp_dep_status varchar(6),
	@stp_gfc_lat decimal(12,4),
	@stp_gfc_long decimal(12,4),
	@stp_gfc_arv_radiusMiles decimal(7,2),
	@stp_gfc_arv_flags int,		-- 2 = ReadOnly (no UPDATE)
	@stp_gfc_dep_radiusMiles decimal(7,2),
	@stp_gfc_dep_flags int,		-- 1 = HoldDpt, 2 = ReadOnly (no UPDATE)
	@stp_arv_time datetime,
	@stp_dep_time datetime,
	@stp_aad_arvConfidence int,	
	@stp_aad_depConfidence int,	
	@stp_aad_arvTime datetime,
	@stp_aad_depTime datetime,
	@stp_aad_arvckc_lat decimal(12,4),
	@stp_aad_arvckc_long decimal(12,4),
	@stp_aad_depckc_lat decimal(12,4),
	@stp_aad_depckc_long decimal(12,4),
	@stp_tz_hours int,
	@stp_tz_mins int,
	@stp_tz_dstCode int,
	@tmpstp_ckc_airmiles decimal(12,4),
	@tmpstp_UPDATEStop int,	-- 0=no; 1=yes
	@tmpstp_issueArrive int,	-- 0=no; 1=yes
	@tmpstp_issueDepart int,	-- 0=no; 1=yes
	@sys_aadOn varchar(60),
	@sys_timeout int,
	@sys_offset int,
	@sys_formsInStopTz char(1), -- Y/N form fields in terms of stop TZ (only IF stop TZ is enabled)
	@sys_fid_arv int,			-- GFC_ARRIVED form ID
	@sys_fid_dep int,			-- GFC_DEPARTED form ID
	@sys_MakeTZAdjusts char(1),
	@sys_tz int,
	@sys_tzMins int,
	@sys_DstCode int,
	@sys_currStopByAad char(1),
	@sys_lastStopByAad char(1),
    	
	@tractor_id varchar(8),
	
	@closestStop_seq int,
	@currStop_seq int,
	@lastStop_seq int,
	@nextStop_seq int,
	@nextNextStop_seq int,
	
	@airDist decimal(12,4),
	@arvRadius decimal(7,2),
	@depRadius decimal(7,2),
	@lat decimal(12,4),
	@long decimal(12,4),
	@time datetime,
	@dumDate datetime,
	@ckc_previous_checkcall int,
	@ckc_time_previous datetime,
	@ckc_asgntype varchar(6),
	@PrimaryID varchar(50)

		
-- Clean out work table
DELETE FROM #stops_ckc_AadMain 

/*** Set system vars ***/

SELECT @sys_AadOn = gi_string1, @sys_formsInStopTz = gi_string2, 
    @sys_currStopByAad = gi_string3,
	@sys_lastStopByAad = gi_string4,
	@sys_timeout = gi_integer1, @sys_offset = gi_integer2
FROM generalinfo (NOLOCK)
WHERE gi_name = 'TMailCkcAAD'

IF upper(isnull(@sys_AadOn,'N')) <> 'Y' return

SELECT @sys_fid_arv = gi_integer1
FROM generalinfo (NOLOCK)
WHERE gi_name = 'FA_GFCARRIVE'	

SELECT @sys_fid_dep = gi_integer1
FROM generalinfo (NOLOCK)
WHERE gi_name = 'FA_GFCDEPART'	

SELECT @sys_timeout = isnull(@sys_timeout,10),
	@sys_offset = isnull(@sys_offset,@sys_timeout/2),
	@sys_fid_arv = isnull(@sys_fid_arv,0),
    @sys_fid_dep = isnull(@sys_fid_dep,0)
IF upper(isnull(@sys_formsInStopTz,'N')) = 'Y'
	SELECT @sys_formsInStopTz = 'Y'
ELSE
	SELECT @sys_formsInStopTz = 'N'
IF upper(isnull(@sys_lastStopByAad,'Y')) = 'N'
	SELECT @sys_lastStopByAad = 'N'
ELSE
	SELECT @sys_lastStopByAad = 'Y'
IF upper(isnull(@sys_currStopByAad,'Y')) = 'N'
	SELECT @sys_currStopByAad = 'N'
ELSE
	SELECT @sys_currStopByAad = 'Y'

IF @sys_fid_arv = 0 OR @sys_fid_dep = 0
	BEGIN
	RAISERROR ('AAD GeoFencing turned on (generalinfo TMGFCCheckcall=1), but the Arrival (generalinfo FA_GFCARRIVE) and Departure (generalinfo FA_GFCDEPART) forms are not both set', 16, 1)
	RETURN
	END


/*** Set check call vars ***/

SELECT @lgh_number=isnull(ckc_lghnumber,0), 
	@ckc_time = ckc_date, 
	@ckc_latseconds = isnull(ckc_latseconds,0),
	@ckc_longseconds = isnull(ckc_longseconds,0),
	@ckc_ignition = upper(isnull(ckc_vehicleignition,'N')),
	@ckc_tripStatus = isnull(tripStatus, 0),
	@tractor_id = isnull(ckc_tractor,''),
	@ckc_asgnid = ckc_asgnid,
	@ckc_asgntype = ckc_asgntype
FROM checkcall (NOLOCK)
WHERE ckc_number=@ckcnum

IF @ckc_asgntype = 'TRL' --Trailer Checkcall
	BEGIN
	SELECT @ckc_time_previous = max(ckc_date) 
	FROM checkcall (NOLOCK)
	WHERE @ckc_asgnid = ckc_asgnid
		AND ckc_number <@ckcnum
	SET @PrimaryID = 'TRL:' + @ckc_asgnid
	END
ELSE
	BEGIN
	SELECT @ckc_time_previous = max(ckc_date) 
	FROM checkcall (NOLOCK) 
	WHERE ckc_tractor = @tractor_id
		AND ckc_number <@ckcnum
	SET @PrimaryID = @tractor_id
	END

IF DATEDIFF(minute,@ckc_time,@ckc_time_previous) > 0 
	BEGIN
	return
	END

IF @ckc_latseconds = 0 and @ckc_longseconds = 0 return

EXEC dbo.tm_cvtGeoCoord 'checkcall', @ckc_latseconds, @ckc_lat out
EXEC dbo.tm_cvtGeoCoord 'checkcall', @ckc_longseconds, @ckc_long out
	
IF @lgh_number = 0 return


/*** Create stops temp table ***/

INSERT INTO #stops_ckc_AadMain (
	stp_number,
	stp_mfh_sequence,
	stp_event, 
	stp_arv_status, 
	stp_dep_status,
	stp_arv_time,     
	stp_dep_Time,   
	cmp_id,
	stp_city,
  	stp_gfc_arv_radiusMiles,        
	stp_gfc_dep_radiusMiles,        
	stp_gfc_lat,
	stp_gfc_long,
	stp_aad_arvTime,
	stp_aad_arvConfidence,
	stp_aad_depTime,
	stp_aad_depConfidence,
	stp_aad_lastckc_lat,         
	stp_aad_lastckc_long,           
	stp_aad_lastckc_time,          
	stp_aad_lastckc_tripStatus,
	stp_aad_laststartckc_lat,    
	stp_aad_laststartckc_long,      
	stp_aad_laststartckc_time,     
	stp_aad_laststartckc_tripStatus,
	stp_aad_arvckc_lat,
	stp_aad_arvckc_long,            
	stp_aad_arvckc_time,           
	stp_aad_arvckc_tripStatus,      
	stp_aad_depckc_lat,
	stp_aad_depckc_long,
	stp_aad_depckc_time,           
	stp_aad_depckc_tripStatus,
	tmpstp_ckc_airmiles,
	stp_tz_hours,
	stp_tz_mins,
	stp_tz_dstCode,
	stp_gfc_arv_flags,
	stp_gfc_dep_flags,
	tmpstp_UPDATEStop,
	tmpstp_issueArrive,
	tmpstp_issueDepart,
    tmpstp_matchstop)
SELECT stp_number,
	stp_mfh_sequence,
	stp_event, 
	isnull(stp_status,''), --stp_arv_status, 
	isnull(stp_departure_status,''), --stp_dep_status,
	stp_arrivaldate, --stp_arv_time,
	stp_departuredate, --stp_dep_Time,
	cmp_id,
	stp_city,
  	stp_gfc_arv_radiusMiles,        
	stp_gfc_dep_radiusMiles,        
	stp_gfc_lat,
	stp_gfc_long,
	stp_aad_arvTime,
	stp_aad_arvConfidence,
	stp_aad_depTime,
	stp_aad_depConfidence,
	stp_aad_lastckc_lat,         
	stp_aad_lastckc_long,           
	stp_aad_lastckc_time,          
	stp_aad_lastckc_tripStatus,
	stp_aad_laststartckc_lat,    
	stp_aad_laststartckc_long,      
	stp_aad_laststartckc_time,     
	stp_aad_laststartckc_tripStatus,
	stp_aad_arvckc_lat,
	stp_aad_arvckc_long,            
	stp_aad_arvckc_time,           
	stp_aad_arvckc_tripStatus,      
	stp_aad_depckc_lat,
	stp_aad_depckc_long,
	stp_aad_depckc_time,           
	stp_aad_depckc_tripStatus,
	CONVERT(decimal(12,4),0), -- tmpstp_ckc_airmiles,
	0, -- stp_tz_hours,
	0, -- stp_tz_mins,
	0, -- stp_tz_dstCode,
	0, -- stp_gfc_arv_flags,
	0, -- stp_gfc_dep_flags,
	0, -- tmpstp_UPDATEStop,
	0, -- tmpstp_issueArrive,
	0, -- tmpstp_issueDepart,
    0 -- tmpstp_matchstop
FROM stops (NOLOCK)
WHERE lgh_number = @lgh_number 
ORDER BY stp_mfh_sequence

IF not exists (SELECT stp_number 
				FROM #stops_ckc_AadMain) 
	BEGIN
	return
	END


/*** Set legheader vars ***/

SELECT @mov_number = mov_number 
FROM legheader (NOLOCK)
WHERE lgh_number = @lgh_number

SELECT @mov_number=isnull(@mov_number,0)


/*** UPDATE temp stops with geofence data ***/

SELECT @stp_mfh_sequence = min(stp_mfh_sequence) 
FROM #stops_ckc_AadMain 

SELECT @stp_mfh_sequence = isnull(@stp_mfh_sequence, 0)			
WHILE (@stp_mfh_sequence <> 0)
	BEGIN
		SELECT 
		@stp_number = stp_number,
		@cmp_id = cmp_id,
		@stp_gfc_lat= stp_gfc_lat,
		@stp_gfc_long = stp_gfc_long,
		@stp_gfc_arv_radiusMiles = stp_gfc_arv_radiusMiles,        
		@stp_gfc_dep_radiusMiles = stp_gfc_dep_radiusMiles,
		@stp_city = stp_city
		FROM #stops_ckc_AadMain 
		WHERE stp_mfh_sequence = @stp_mfh_sequence
	
		SELECT 
		@stp_gfc_lat = isnull(@stp_gfc_lat,0),
		@stp_gfc_long = isnull(@stp_gfc_long,0),
		@stp_gfc_arv_radiusMiles = isnull(@stp_gfc_arv_radiusMiles,-2),
		@stp_gfc_dep_radiusMiles = isnull(@stp_gfc_dep_radiusMiles,-2),
		@cmp_id = isnull(@cmp_id,'')
	
		SELECT @lat = 0, @long = 0, @cmp_latseconds = isnull(cmp_latseconds,0), @cmp_longseconds = isnull(cmp_longseconds,0) 
		FROM company (NOLOCK) 
		WHERE cmp_id = @cmp_id
		
		IF (@cmp_latseconds <> 0) or (@cmp_longseconds <> 0)
			BEGIN
				EXEC dbo.tm_cvtGeoCoord 'company', @cmp_latseconds, @lat out
				EXEC dbo.tm_cvtGeoCoord 'company', @cmp_longseconds, @long out
			END
		ELSE
		BEGIN
				SELECT @cty_latitude = cty_latitude, @cty_longitude = cty_longitude 
				FROM city (NOLOCK)
				WHERE cty_code = @stp_city
				SELECT @cty_latitude = isnull(@cty_latitude,0),
					@cty_longitude = isnull(@cty_longitude,0)
			IF (@cty_latitude <> 0) or (@cty_longitude <> 0)
				BEGIN			
					EXEC dbo.tm_cvtGeoCoord 'city', @cty_latitude, @lat out
					EXEC dbo.tm_cvtGeoCoord 'city', @cty_longitude, @long out
				END
		END
		IF @lat = 0 and @long = 0 
			SELECT @lat = @stp_gfc_lat, @long = @stp_gfc_long
		IF @lat = 0 and @long = 0 
		BEGIN
			SELECT @stp_mfh_sequence = min(stp_mfh_sequence) 
			FROM #stops_ckc_AadMain 
			WHERE stp_mfh_sequence > @stp_mfh_sequence
			
			SELECT @stp_mfh_sequence = isnull(@stp_mfh_sequence, 0)
			continue
		END
		
		EXEC dbo.TM_CKC_getGeoRadius @stp_number, 'ARVED', @arvRadius out, @stp_gfc_arv_flags out
		EXEC dbo.TM_CKC_getGeoRadius @stp_number, 'DEPED', @depRadius out, @stp_gfc_dep_flags out
		SELECT @arvRadius = isnull(@arvRadius, 0)
		SELECT @depRadius = isnull(@depRadius, 0)
		-- Algorithm cannot handle either arrival or departure radius alone.  So IF departure radius
		--	only, set arrival radius to a minimal value.
		IF @depRadius > 0 and @arvRadius <= 0
		SELECT @arvRadius = .1
		-- Algorithm cannot handle an arrival radius that is not less than departure radius.  So IF 
		--	arrrival radius is set and not less than the departure radius, then reset departure 
		--  radius to a minimal amount greater than the arrival radius.
		IF @arvRadius > 0 and @depRadius <= @arvRadius
			SELECT @depRadius = @arvRadius + .1

		EXEC dbo.tmail_AirDistance @ckc_lat, @ckc_long, @lat, @long, @tmpstp_ckc_airmiles out

		IF @lat <> @stp_gfc_lat or @long <> @stp_gfc_long 
			or @arvRadius <> @stp_gfc_arv_radiusMiles or @depRadius <> @stp_gfc_dep_radiusMiles
			SELECT @tmpstp_UPDATEStop = 1
		ELSE
			SELECT @tmpstp_UPDATEStop = 0
	
		UPDATE #stops_ckc_AadMain
			set stp_gfc_lat = @lat, 
			stp_gfc_long = @long,
			stp_gfc_arv_radiusMiles = @arvRadius,
			stp_gfc_dep_radiusMiles = @depRadius,
			stp_gfc_arv_flags = @stp_gfc_arv_flags,
			stp_gfc_dep_flags = @stp_gfc_dep_flags,
			tmpstp_ckc_airmiles = @tmpstp_ckc_airmiles,
			tmpstp_UPDATEStop = @tmpstp_UPDATEStop
			WHERE stp_mfh_sequence = @stp_mfh_sequence

		SELECT @stp_mfh_sequence = min(stp_mfh_sequence) 
		FROM #stops_ckc_AadMain 
		WHERE stp_mfh_sequence > @stp_mfh_sequence
	
		SELECT @stp_mfh_sequence = isnull(@stp_mfh_sequence, 0)				 			
	END


/*** Filter out consecutive same-location stops and those that do not have geofences. ***/

/*IF EXISTS (SELECT * FROM sysobjects WHERE name = 'dump_stops_ckc_aadmain' AND type = 'U') drop table dump_stops_ckc_aadmain -- debug
SELECT * into dump_stops_ckc_aadmain FROM #stops_ckc_AadMain -- debug*/
-- IF Stop is identical to the preceding stop, then consolidate the two stops.
UPDATE #stops_ckc_AadMain set tmpstp_matchstop = 0
UPDATE #stops_ckc_AadMain set tmpstp_matchstop = 1 
	FROM #stops_ckc_AadMain NextStop 
		inner join #Stops_ckc_AadMain 
			ON #Stops_ckc_AadMain.stp_mfh_sequence + 1 = NextStop.stp_mfh_sequence 
	WHERE NextStop.stp_gfc_lat = #Stops_ckc_AadMain.stp_gfc_lat
      and NextStop.stp_gfc_long = #Stops_ckc_AadMain.stp_gfc_long
/*drop table dump_stops_ckc_aadmain -- debug
SELECT * into dump_stops_ckc_aadmain FROM #stops_ckc_AadMain -- debug*/
UPDATE #stops_ckc_AadMain 
	Set tmpstp_matchstop = 
		(SELECT min(Sub.stp_mfh_sequence) 
			FROM #stops_ckc_AadMain Sub 
			WHERE #stops_ckc_AadMain.stp_mfh_sequence < Sub.stp_mfh_sequence
			  AND Sub.tmpstp_matchstop = 0)
	WHERE tmpstp_matchstop <> 0
/*drop table dump_stops_ckc_aadmain -- debug
SELECT * into dump_stops_ckc_aadmain FROM #stops_ckc_AadMain -- debug*/
--Copy radii off stops that will be DELETEd IF they are not on stops that will remain
UPDATE #stops_ckc_AadMain 
	set 
		stp_gfc_arv_radiusMiles = 
			(SELECT max(stp_gfc_arv_radiusMiles) 
				FROM #stops_ckc_AadMain WilliamZap 
				WHERE WilliamZap.tmpstp_matchstop = #stops_ckc_AadMain.stp_mfh_sequence
				 or WilliamZap.stp_mfh_sequence = #stops_ckc_AadMain.stp_mfh_sequence),
		stp_gfc_dep_radiusMiles = 
			(SELECT max(stp_gfc_dep_radiusMiles) 
				FROM #stops_ckc_AadMain WilliamZap 
				WHERE WilliamZap.tmpstp_matchstop = #stops_ckc_AadMain.stp_mfh_sequence 
				 or WilliamZap.stp_mfh_sequence = #stops_ckc_AadMain.stp_mfh_sequence)
	FROM #stops_ckc_AadMain 
		inner join #stops_ckc_AadMain WillZap 
			ON #stops_ckc_AadMain.stp_mfh_sequence = WillZap.tmpstp_matchstop
	WHERE #stops_ckc_AadMain.stp_gfc_arv_radiusMiles <= 0
	  and #stops_ckc_AadMain.tmpstp_matchstop = 0
/*drop table dump_stops_ckc_aadmain -- debug
SELECT * into dump_stops_ckc_aadmain FROM #stops_ckc_AadMain -- debug*/
--Set Arrival status IF any of the consolidated stops have arrived.  Set time to earliest time.
UPDATE #stops_ckc_AadMain 
	set 
		stp_arv_time = 
			(SELECT min(stp_arv_time) 
				FROM #stops_ckc_AadMain WilliamZap 
				WHERE (WilliamZap.tmpstp_matchstop = #stops_ckc_AadMain.stp_mfh_sequence 
				 or WilliamZap.stp_mfh_sequence = #stops_ckc_AadMain.stp_mfh_sequence)
				 and WilliamZap.stp_arv_status = 'DNE'),
		stp_arv_status = 'DNE'
	FROM #stops_ckc_AadMain 
		inner join #stops_ckc_AadMain WillZap 
			ON #stops_ckc_AadMain.stp_mfh_sequence = WillZap.tmpstp_matchstop
			 and WillZap.stp_arv_status = 'DNE'
	WHERE #stops_ckc_AadMain.tmpstp_matchstop = 0
/*drop table dump_stops_ckc_aadmain -- debug
SELECT * into dump_stops_ckc_aadmain FROM #stops_ckc_AadMain -- debug*/
--Set Departure status IF any of the consolidated stops have departed.  Set time to latest time.
UPDATE #stops_ckc_AadMain 
	set 
		stp_dep_time = 
			(SELECT max(stp_dep_time) 
				FROM #stops_ckc_AadMain WilliamZap 
				WHERE (WilliamZap.tmpstp_matchstop = #stops_ckc_AadMain.stp_mfh_sequence 
				 or WilliamZap.stp_mfh_sequence = #stops_ckc_AadMain.stp_mfh_sequence)
				 and WilliamZap.stp_dep_status = 'DNE'),
		stp_dep_status = 'DNE'
	FROM #stops_ckc_AadMain 
		inner join #stops_ckc_AadMain WillZap 
			ON #stops_ckc_AadMain.stp_mfh_sequence = WillZap.tmpstp_matchstop
			 and WillZap.stp_dep_status = 'DNE'
	WHERE #stops_ckc_AadMain.tmpstp_matchstop = 0
/*drop table dump_stops_ckc_aadmain -- debug
SELECT * into dump_stops_ckc_aadmain FROM #stops_ckc_AadMain -- debug*/
--Set AAD arrive time IF any of the consolidated stops have arrived by AAD.  Set time to earliest time.
UPDATE #stops_ckc_AadMain 
	set stp_aad_arvConfidence =
		(SELECT max(stp_aad_arvConfidence) 
			FROM #stops_ckc_AadMain WilliamZap 
			WHERE (WilliamZap.tmpstp_matchstop = #stops_ckc_AadMain.stp_mfh_sequence 
			 or WilliamZap.stp_mfh_sequence = #stops_ckc_AadMain.stp_mfh_sequence)
   			 and not (WilliamZap.stp_aad_arvTime is null))
	FROM #stops_ckc_AadMain 
		inner join #stops_ckc_AadMain WillZap 
			ON #stops_ckc_AadMain.stp_mfh_sequence = WillZap.tmpstp_matchstop
			 and not (WillZap.stp_aad_arvTime is null)
	WHERE #stops_ckc_AadMain.tmpstp_matchstop = 0
UPDATE #stops_ckc_AadMain 
	set stp_aad_arvTime = 
		(SELECT min(stp_aad_arvTime) 
			FROM #stops_ckc_AadMain WilliamZap 
			WHERE (WilliamZap.tmpstp_matchstop = #stops_ckc_AadMain.stp_mfh_sequence 
			 or WilliamZap.stp_mfh_sequence = #stops_ckc_AadMain.stp_mfh_sequence)
			 and not (WilliamZap.stp_aad_arvTime is null)
			 and WilliamZap.stp_aad_arvConfidence = #stops_ckc_AadMain.stp_aad_arvConfidence)
	FROM #stops_ckc_AadMain 
		inner join #stops_ckc_AadMain WillZap 
			ON #stops_ckc_AadMain.stp_mfh_sequence = WillZap.tmpstp_matchstop
			 and not (WillZap.stp_aad_arvTime is null)
	WHERE #stops_ckc_AadMain.tmpstp_matchstop = 0

/*drop table dump_stops_ckc_aadmain -- debug
SELECT * into dump_stops_ckc_aadmain FROM #stops_ckc_AadMain -- debug*/
--Set AAD depart time IF any of the consolidated stops have departed by AAD.  Set time to latest time.
UPDATE #stops_ckc_AadMain 
	set stp_aad_depConfidence =
		(SELECT max(stp_aad_depConfidence) 
			FROM #stops_ckc_AadMain WilliamZap 
			WHERE (WilliamZap.tmpstp_matchstop = #stops_ckc_AadMain.stp_mfh_sequence 
			 or WilliamZap.stp_mfh_sequence = #stops_ckc_AadMain.stp_mfh_sequence)
   			 and not (WilliamZap.stp_aad_depTime is null))
	FROM #stops_ckc_AadMain 
		inner join #stops_ckc_AadMain WillZap 
			ON #stops_ckc_AadMain.stp_mfh_sequence = WillZap.tmpstp_matchstop
			 and not (WillZap.stp_aad_depTime is null)
	WHERE #stops_ckc_AadMain.tmpstp_matchstop = 0
UPDATE #stops_ckc_AadMain 
	set stp_aad_depTime = 
		(SELECT max(stp_aad_depTime) 
			FROM #stops_ckc_AadMain WilliamZap 
			WHERE (WilliamZap.tmpstp_matchstop = #stops_ckc_AadMain.stp_mfh_sequence 
			 or WilliamZap.stp_mfh_sequence = #stops_ckc_AadMain.stp_mfh_sequence)
			 and not (WilliamZap.stp_aad_depTime is null)
			 and WilliamZap.stp_aad_depConfidence = #stops_ckc_AadMain.stp_aad_depConfidence)
	FROM #stops_ckc_AadMain 
		inner join #stops_ckc_AadMain WillZap 
			ON #stops_ckc_AadMain.stp_mfh_sequence = WillZap.tmpstp_matchstop
			 and not (WillZap.stp_aad_depTime is null)
	WHERE #stops_ckc_AadMain.tmpstp_matchstop = 0

/*drop table dump_stops_ckc_aadmain -- debug
SELECT * into dump_stops_ckc_aadmain FROM #stops_ckc_AadMain -- debug*/
-- IF Stop has no Lat/Long or IF arrival radius is not set (which by the above implies 
--	departure radius is also unset), then ignore the stop.
DELETE FROM #stops_ckc_AadMain WHERE 
	(stp_gfc_lat = 0 and stp_gfc_long = 0) or 
	(stp_gfc_arv_radiusMiles <= 0)

/*drop table dump_stops_ckc_aadmain -- debug
SELECT * into dump_stops_ckc_aadmain FROM #stops_ckc_AadMain -- debug*/
-- Zap
DELETE 
FROM #stops_ckc_AadMain 
WHERE tmpstp_matchstop <> 0

/*drop table dump_stops_ckc_aadmain -- debug
SELECT * into dump_stops_ckc_aadmain FROM #stops_ckc_AadMain -- debug
drop table dump_stops_ckc_aadmain -- debug*/

/*** CONVERT stop times to dispatch office time zone IF needed. ***/

SELECT @sys_MakeTZAdjusts = UPPER(ISNULL(gi_string1, 'N'))
FROM generalinfo (NOLOCK) 
WHERE gi_name = 'MakeTZAdjustments'
IF @sys_MakeTZAdjusts = 'Y'
	BEGIN
		SELECT @sys_TZ = ISNULL(CONVERT(int, gi_string1), -15)
		FROM generalinfo (NOLOCK)
		WHERE gi_name = 'SysTZ'
		
		SELECT @sys_TZMins = ISNULL(CONVERT(int, gi_string1), 0)  -- Default to no additional minutes
		FROM generalinfo (NOLOCK)
		WHERE gi_name = 'SysTZMins'
		
		SELECT @sys_DSTCode = ISNULL(CONVERT(int, gi_string1), 0)  -- Default to no DST
		FROM generalinfo (NOLOCK)
		WHERE gi_name = 'SysDSTCode'
		
		SELECT @stp_mfh_sequence = min(stp_mfh_sequence) 
		FROM #stops_ckc_AadMain 
		
		SELECT @stp_mfh_sequence = isnull(@stp_mfh_sequence, 0)			
		WHILE (@stp_mfh_sequence <> 0)
		BEGIN
			SELECT 
				@stp_number = stp_number
			FROM #stops_ckc_AadMain 
			WHERE stp_mfh_sequence = @stp_mfh_sequence
			EXEC dbo.stp_cvtToSysTZ @stp_number, @stp_arv_time out, @stp_dep_time out, @dumDate, @dumDate, @dumDate, @dumDate, @stp_tz_hours out, @stp_tz_mins out, @stp_tz_dstCode out
			UPDATE #stops_ckc_AadMain
				set stp_arv_time = @stp_arv_time, -- this field does NOT get written back to stops table.
					stp_dep_time = @stp_dep_time, -- this field does NOT get written back to stops table.
					stp_tz_hours = @stp_tz_hours,
					stp_tz_mins = @stp_tz_mins,
					stp_tz_dstCode = @stp_tz_dstCode
			WHERE stp_mfh_sequence = @stp_mfh_sequence
			
			SELECT @stp_mfh_sequence = min(stp_mfh_sequence) 
			FROM #stops_ckc_AadMain 
			WHERE stp_mfh_sequence > @stp_mfh_sequence
			
			SELECT @stp_mfh_sequence = isnull(@stp_mfh_sequence, 0)				 			
		END
	END
		
	
/*** Find last, current, next, nextNext, closest stops ***/

SELECT @lastStop_seq = max(stp_mfh_sequence) 
FROM #stops_ckc_AadMain 
WHERE not (stp_aad_arvTime is null) 
	 or not (stp_aad_depTime is null)
	 or stp_arv_status = 'DNE'

IF @sys_lastStopByAad = 'Y'
	IF exists (SELECT stp_mfh_sequence 
				FROM #stops_ckc_AadMain 
				WHERE stp_mfh_sequence = @lastStop_seq
					and (stp_aad_arvTime is null and stp_aad_depTime is null and stp_dep_status <> 'DNE'))
			SELECT @lastStop_seq = (SELECT max(stp_mfh_sequence) 
									FROM #stops_ckc_AadMain 
									WHERE stp_mfh_sequence < @lastStop_seq)
SELECT @lastStop_seq = isnull(@lastStop_seq, 0)		

IF @sys_currStopByAad = 'Y'
	SELECT @currStop_seq = stp_mfh_sequence 
	FROM #stops_ckc_AadMain 
	WHERE stp_mfh_sequence = @lastStop_seq
		 and stp_aad_depTime is null
ELSE
	SELECT @currStop_seq = stp_mfh_sequence 
	FROM #stops_ckc_AadMain 
	WHERE stp_mfh_sequence = @lastStop_seq
		 and (stp_aad_depTime is null and stp_dep_status <> 'DNE')

SELECT @currStop_seq = isnull(@currStop_seq, 0)				


SELECT @nextStop_seq = min(stp_mfh_sequence) 
FROM #stops_ckc_AadMain
WHERE stp_mfh_sequence > @lastStop_seq 

SELECT @nextStop_seq = isnull(@nextStop_seq, 0)				

SELECT @nextNextStop_seq = min(stp_mfh_sequence) 
FROM #stops_ckc_AadMain
WHERE stp_mfh_sequence > @nextStop_seq and @nextStop_seq > 0

SELECT @nextNextStop_seq = isnull(@nextNextStop_seq, 0)				

SELECT @airDist = min(isnull(tmpstp_ckc_airmiles,0)) 
FROM #stops_ckc_AadMain
WHERE stp_mfh_sequence = @lastStop_seq
		or stp_mfh_sequence = @nextStop_seq
		or stp_mfh_sequence = @nextNextStop_seq

SELECT @closestStop_seq = min(stp_mfh_sequence) 
FROM #stops_ckc_AadMain
WHERE (stp_mfh_sequence = @lastStop_seq
		or stp_mfh_sequence = @nextStop_seq
		or stp_mfh_sequence = @nextNextStop_seq)
		and isnull(tmpstp_ckc_airmiles,0) = @airDist

SELECT @closestStop_seq = isnull(@closestStop_seq,0)

IF @closestStop_seq = 0 
	BEGIN
		return -- No relevant stops to apply check call to (last, next, or nextNext).
	END

/*** DELETE stops prior to LastStop; we don't want to ripple back AAD messages that far. ***/

DELETE 
FROM #stops_ckc_AadMain 
WHERE stp_mfh_sequence < @lastStop_seq


-- Clear any approach information for later stops.

UPDATE #stops_ckc_AadMain Set 
	stp_aad_arvTime =NULL,
	stp_aad_arvConfidence =NULL,
	stp_aad_depTime = NULL,
	stp_aad_depConfidence = NULL,
	stp_aad_lastckc_lat = NULL,
	stp_aad_lastckc_long = NULL,      
	stp_aad_lastckc_time = NULL,    
	stp_aad_lastckc_tripStatus = NULL,
	stp_aad_laststartckc_lat = NULL,
	stp_aad_laststartckc_long = NULL, 
	stp_aad_laststartckc_time = NULL,
	stp_aad_laststartckc_tripStatus = NULL,
	stp_aad_arvckc_lat = NULL,
	stp_aad_arvckc_long = NULL,       
	stp_aad_arvckc_time = NULL,     
	stp_aad_arvckc_tripStatus = NULL,
	stp_aad_depckc_lat = NULL,
	stp_aad_depckc_long = NULL,
	stp_aad_depckc_time = NULL,     
	stp_aad_depckc_tripStatus = NULL,
    tmpstp_UPDATEStop = 1
	FROM #stops_ckc_AadMain 
	WHERE stp_mfh_sequence > @closestStop_seq

/*** Decide automatic arrives and departs for check call. ***/

EXEC dbo.tm_ckc_AadDecideArvDep 
	@sys_timeout, @sys_offset, 
	@ckc_lat, @ckc_long, @ckc_time, @ckc_tripStatus, @ckc_ignition,			
	@closestStop_Seq, @currStop_Seq, @lastStop_seq, @nextStop_seq, @nextNextStop_seq


/*** Cut arrive and depart macros and UPDATE stops FROM temp. ***/		

SELECT @stp_mfh_sequence = min(stp_mfh_sequence) 
FROM #stops_ckc_AadMain 

SELECT @stp_mfh_sequence = isnull(@stp_mfh_sequence, 0)			
WHILE (@stp_mfh_sequence <> 0)
	BEGIN
		SELECT 
		@stp_number = stp_number,          
		@stp_event = stp_event,
		@stp_aad_arvTime = stp_aad_arvTime,     
		@stp_aad_depTime = stp_aad_depTime,     
		@stp_aad_arvckc_lat = stp_aad_arvckc_lat,
		@stp_aad_arvckc_long = stp_aad_arvckc_long,
		@stp_aad_depckc_lat = stp_aad_depckc_lat,
		@stp_aad_depckc_long = stp_aad_depckc_long,
		@stp_tz_hours = stp_tz_hours,
		@stp_tz_mins = stp_tz_mins,
		@stp_tz_dstCode = stp_tz_dstCode,
		@stp_gfc_arv_flags = stp_gfc_arv_flags,
		@stp_gfc_dep_flags = stp_gfc_dep_flags,
		@cmp_id = cmp_id,
		@tmpstp_issueArrive = tmpstp_issueArrive,
		@tmpstp_issueDepart = tmpstp_issueDepart,
		@tmpstp_UPDATEStop = tmpstp_UPDATEStop
		FROM #stops_ckc_AadMain 
		WHERE stp_mfh_sequence = @stp_mfh_sequence
	
		IF @sys_MakeTZAdjusts = 'Y' and @sys_formsInStopTz = 'Y'
		-- CONVERT times to stop time zone.
		BEGIN
			EXEC dbo.ChangeTZ_7 @stp_aad_arvTime, @sys_tz, @sys_tzMins, @sys_dstCode, @stp_tz_hours, @stp_tz_mins, @stp_tz_dstCode, @time out
			SELECT @stp_arv_time = @time
			EXEC dbo.ChangeTZ_7 @stp_aad_depTime, @sys_tz, @sys_tzMins, @sys_dstCode, @stp_tz_hours, @stp_tz_mins, @stp_tz_dstCode, @time out
			SELECT @stp_dep_time = @time
		END
		ELSE
		SELECT @stp_arv_time = @stp_aad_arvTime,
			@stp_dep_time = @stp_aad_depTime

		IF @tmpstp_IssueArrive = 1
		-- Do Arrive macro.

		BEGIN
		BEGIN TRANSACTION

		INSERT INTO TMSQLMessage(msg_date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_FROM, msg_FROMType, msg_Subject)
		  VALUES(
		  @ckc_time, 
		  @sys_fid_arv, 
		  '', 
		  0, 
		  'AADARV:' + CONVERT(varchar(10),@stp_number), 
		  30, 
		  @PrimaryID, --@tractor_id
		  9, 
		  'AUTO ARRIVED'
		  )

		SELECT @sqlmsg_id = @@IDENTITY
	
		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  1, 			
		  'StopNumber', 		
		  CONVERT(varchar(10),@stp_number)
		  )
	
		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  2, 			
		  'ArrivalDate', 		
		  CONVERT(varchar(8),@stp_arv_time,1)
		  )
	
		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  3, 			
		  'ArrivalTime', 		
		  CONVERT(varchar(8),@stp_arv_time,8)
		  )
		
		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  4, 			
		  'LghNum', 		
		  CONVERT(varchar(10),@lgh_number)
		  )
	  
		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  5, 			
		  'CompanyID', 		
		  @cmp_id
		  )
		  
		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  6, 			
		  'MoveNumber', 		
		  @mov_number
		  )

	  	INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  7, 			
		  'Event', 		
		  @stp_event
		  )
		  
		SELECT @msd_seq = 7
		IF @sys_MakeTZAdjusts = 'Y' and @sys_formsInStopTz = 'Y'  
			BEGIN
			SELECT @msd_seq = @msd_seq + 1
	  		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
			  VALUES(
			  @sqlmsg_id, 
			  @msd_seq, 			
			  'TZFlags', 		
			  1  -- don't adjust arrive time for stop time zone (it's already done)
			  )
			END
		
		IF @stp_gfc_arv_flags & 2 <> 0 
			BEGIN
			SELECT @msd_seq = @msd_seq + 1
	  		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
			  VALUES(
			  @sqlmsg_id, 
			  @msd_seq, 			
			  'UPDATEFlags', 		
			  4  -- don't UPDATE trip
			  )
			END
			
  		SELECT @msd_seq = @msd_seq + 1
  		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  @msd_seq, 			
		  'TMLatitude', 		
		  @stp_aad_arvckc_lat
		  )
		
		SELECT @msd_seq = @msd_seq + 1
  		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  @msd_seq, 			
		  'TMLongitude', 		
		  @stp_aad_arvckc_long   
		  )

	
		COMMIT TRANSACTION
		END

	IF @tmpstp_IssueDepart = 1
		BEGIN
		BEGIN TRANSACTION
		INSERT INTO TMSQLMessage(msg_date, msg_FormID, msg_To, msg_ToType, msg_FilterData, msg_FilterDataDupWaitSeconds, msg_FROM, msg_FROMType, msg_Subject)
		  VALUES(
		  @ckc_time, 
		  @sys_fid_dep, 
		  '', 
		  0, 
		  'AADDEP:' + CONVERT(varchar(10),@stp_number),
		  30, 
		  @PrimaryID,  --@tractor_id
		  9, 
		  'AUTO DEPARTED'
		  )
	
		SELECT @sqlmsg_id = @@IDENTITY
	
		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  1, 			
		  'StopNumber', 		
		  CONVERT(varchar(10),@stp_number)
		  )

		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  2,
		  'DepartDate',
		  CONVERT(varchar(8),@stp_dep_time,1)
		  )

		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  3, 			
		  'DepartTime', 		
		  CONVERT(varchar(8),@stp_dep_time,8)
		  )
		
		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  4, 			
		  'LghNum', 		
		  CONVERT(varchar(10),@lgh_number)
		  )
	  
		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  5, 			
		  'CompanyID', 		
		  @cmp_id
		  )
	
		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  6, 			
		  'MoveNumber', 		
		  @mov_number
		  )

	  	INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  7, 			
		  'Event', 		
		  @stp_event
		  )
  	
  		SELECT @msd_seq = 7
  		IF @sys_MakeTZAdjusts = 'Y' and @sys_formsInStopTz = 'Y'  
	  		BEGIN
			SELECT @msd_seq = @msd_seq + 1
	  		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
			  VALUES(
			  @sqlmsg_id, 
			  @msd_seq, 			
			  'TZFlags', 		
			  2		-- don't adjust depart time for stop time zone (it's already done)
			  )
			END
		
		IF @stp_gfc_dep_flags & 2 <> 0 
			BEGIN
			SELECT @msd_seq = @msd_seq + 1
	  		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
			  VALUES(
			  @sqlmsg_id, 
			  @msd_seq, 			
			  'UPDATEFlags', 		
			  4  -- don't UPDATE trip
			  )
			END
	
		SELECT @msd_seq = @msd_seq + 1
  		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  @msd_seq, 			
		  'TMLatitude', 		
		  @stp_aad_depckc_lat
		  )
		
		SELECT @msd_seq = @msd_seq + 1
  		INSERT INTO TMSQLMessageData(msg_ID, msd_Seq, msd_FieldName, msd_FieldValue)
		  VALUES(
		  @sqlmsg_id, 
		  @msd_seq, 			
		  'TMLongitude', 		
		  @stp_aad_depckc_long   
		  )
	
		COMMIT TRANSACTION	  
		END

	IF @tmpstp_UPDATEStop = 1
		UPDATE stops
			set	stp_gfc_arv_radiusMiles = ss.stp_gfc_arv_radiusMiles,
				stp_gfc_dep_radiusMiles = ss.stp_gfc_dep_radiusMiles,
	 			stp_gfc_lat = ss.stp_gfc_lat,
				stp_gfc_long = ss.stp_gfc_long,
				stp_aad_arvTime = ss.stp_aad_arvTime,
				stp_aad_arvConfidence = ss.stp_aad_arvConfidence,
				stp_aad_depTime = ss.stp_aad_depTime,
				stp_aad_depConfidence = ss.stp_aad_depConfidence,
				stp_aad_lastckc_lat = ss.stp_aad_lastckc_lat,
				stp_aad_lastckc_long = ss.stp_aad_lastckc_long,
				stp_aad_lastckc_time = ss.stp_aad_lastckc_time,
				stp_aad_lastckc_tripStatus = ss.stp_aad_lastckc_tripStatus,
				stp_aad_lastStartckc_lat = ss.stp_aad_lastStartckc_lat,
				stp_aad_lastStartckc_long = ss.stp_aad_lastStartckc_long,
				stp_aad_lastStartckc_time = ss.stp_aad_lastStartckc_time,
				stp_aad_lastStartckc_tripStatus = ss.stp_aad_lastStartckc_tripStatus,
				stp_aad_arvckc_lat = ss.stp_aad_arvckc_lat,
				stp_aad_arvckc_long = ss.stp_aad_arvckc_long,
				stp_aad_arvckc_time = ss.stp_aad_arvckc_time,
				stp_aad_arvckc_tripStatus = ss.stp_aad_arvckc_tripStatus,
				stp_aad_depckc_lat = ss.stp_aad_depckc_lat,
				stp_aad_depckc_long = ss.stp_aad_depckc_long,
				stp_aad_depckc_time = ss.stp_aad_depckc_time,
				stp_aad_depckc_tripStatus = ss.stp_aad_depckc_tripStatus
		 	FROM stops s, #stops_ckc_AadMain ss
		 	WHERE ss.stp_number = @stp_number
		 			and s.stp_number = ss.stp_number
	SELECT @stp_mfh_sequence = min(stp_mfh_sequence) 
		FROM #stops_ckc_AadMain 
		WHERE stp_mfh_sequence > @stp_mfh_sequence
	SELECT @stp_mfh_sequence = isnull(@stp_mfh_sequence, 0)				 			
	END


/*** Clean up. ***/

GO
GRANT EXECUTE ON  [dbo].[tm_ckc_AadMain] TO [public]
GO
