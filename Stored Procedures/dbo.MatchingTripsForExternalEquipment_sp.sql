SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[MatchingTripsForExternalEquipment_sp] (
				@ete_id int, 
				@lgh_outstatus_list_csv	varchar(254),
				@available_date datetime,
				--PTS 49333 JJF 20091008
				@expire_date datetime,
				--@origin_cty_code int,
				@origin_city varchar(50),
				--END PTS 49333 JJF 20091008
				@origin_latitude decimal(8, 4), 
				@origin_longitude decimal(8, 4), 
				@origin_radius int, 
				--PTS 49333 JJF 20091008
				@origin_state varchar(2),
				--@destination_cty_code int,
				@destination_city varchar(50),
				--PTS 49333 JJF 20091008
				@destination_latitude decimal(8, 4),
				@destination_longitude decimal(8, 4), 
				@destination_radius int,
				@destination_states_csv varchar(254),
				@car_id varchar(8),
				--PTS 49216 JJF 20090925
				@ete_equipmenttype varchar(25)
				--PTS 49216 JJF 20090925
			)
AS
	--PTS 46005/46541 JJF 20090428

	DECLARE @DEBUG char(1)

	SET @DEBUG = 'N'

	DECLARE	@proc_to_call	varchar(50)
	--PTS 49216 JJF 20090925
	DECLARE @proc_additional_filter	varchar(50)
	--END PTS 49216 JJF 20090925
	
	DECLARE @ete_automatch	char(1)
	DECLARE @destination_statelistraw varchar(100)
	DECLARE @comma varchar(1)
	DECLARE @charptr int

	--Get procedure to call to retrieve qualifying orders.  Parameters will match parameter list for this procedure.
	SELECT	@proc_to_call = isnull(ltrim(rtrim(gi_string1)), ''), 
			--PTS 49216 JJF 20090925
			@proc_additional_filter = isnull(ltrim(rtrim(gi_string4)), '')
			--END PTS 49216 JJF 20090925
	FROM	generalinfo 
	WHERE	gi_name = 'ExternalEquipAutoMatchProc'

	IF @proc_to_call = '' BEGIN
		SELECT @proc_to_call = 'TripsAutoMatch_sp'
	END

	--Table to populate within procedure specified in ExternalEquipAutoMatchProc (generalinfo setting)
	CREATE TABLE #matching_trips(
		mt_id					int				NOT NULL IDENTITY (1, 1),
		source_id				int				NULL,
		lgh_number				int				NULL,
		mov_number				int				NULL,
		ord_hdrnumber			int				NULL,
		distance_to_origin		int				NULL,
		distance_to_destination	int				NULL
	)

	DECLARE @FinalResult table(
				sort_order				int				NULL,
				lgh_number				int				NULL,
				mov_number				int				NULL,
				ord_hdrnumber			int				NULL,
				ord_number				char(12)		NULL,
				distance_to_origin		int				NULL,
				distance_to_destination	int				NULL,
				ord_totalmiles			int				NULL,
				ord_billto				varchar(8)		NULL,
				ord_billto_name			varchar(30)		NULL,
				schdtearliest			datetime		NULL,
				cmp_id_start			varchar(8)		NULL,
				cmp_id_start_name		varchar(30)		NULL,
				startcity				int				NULL,
				startcty_nmstct			varchar(30)		NULL,
				schdtlatest				datetime		NULL,
				cmp_id_end				varchar(8)		NULL,
				cmp_id_end_name			varchar(30)		NULL,
				endcity					int				NULL,
				endcty_nmstct			varchar(30)		NULL,
				revtype1_t				varchar(20)		NULL,
				ord_revtype1			varchar(6)		NULL,
				revtype2_t				varchar(20)		NULL,
				ord_revtype2			varchar(6)		NULL,
				revtype3_t				varchar(20)		NULL,
				ord_revtype3			varchar(6)		NULL,
				revtype4_t				varchar(20)		NULL,
				ord_revtype4			varchar(6)		NULL,
				cmpbillto_cmp_revtype1	varchar(6)		NULL,
				cmpbillto_cmp_revtype2	varchar(6)		NULL,
				cmpbillto_cmp_revtype3	varchar(6)		NULL,
				cmpbillto_cmp_revtype4	varchar(6)		NULL,
				trl_type1_t				varchar(20)		NULL,
				trl_type1				varchar(6)		NULL,
				trl_type2_t				varchar(20)		NULL,
				trl_type2				varchar(6)		NULL,
				trl_type3_t				varchar(20)		NULL,
				trl_type3				varchar(6)		NULL,
				trl_type4_t				varchar(20)		NULL,
				trl_type4				varchar(6)		NULL,
				stop_count				int				NULL
			)	


	IF @proc_to_call <> '' BEGIN
		IF @DEBUG = 'Y' BEGIN
			PRINT 'Using ExternalEquipAutoMatchProc: ' + @proc_to_call
		END

		SELECT @ete_id = ISNULL(@ete_id, 0)
		SELECT @ete_automatch = 'Y'

		/*
		IF @ete_id > 0 BEGIN
			
			SELECT	@origin_latitude = isnull(@origin_latitude, ete.ete_origlatitude),
					@origin_longitude = isnull(@origin_longitude, ete.ete_origlongitude),
					@origin_radius = isnull(@origin_radius, ete.ete_originradius),
					@destination_latitude = isnull(@destination_latitude, ete.ete_destlatitude),
					@destination_longitude = isnull(@destination_longitude, ete_destlongitude),
					@destination_statelistraw = isnull(ete_destcity, ''),
					@destination_radius = isnull(@destination_radius, ete_destradius),
					@available_date = isnull(@available_date, ete_availabledate),
					@ete_automatch = isnull(ete.ete_automatch, 'Y')
			FROM	external_equipment ete
			WHERE	ete.ete_id = @ete_id
			

		END
		*/

		--See if ete_destcity actually contains a 'state list'
		--PTS 48513 JJF 20090824 code never hit
		/*
		IF @destination_statelistraw <> '' BEGIN
			IF CHARINDEX (',', @destination_statelistraw) = 0 BEGIN
				--It's a state list, convert to csv
				SET @charptr = 1
				SET @comma = ''
				SET @destination_states_csv = ''
				WHILE (@charptr <= LEN(@destination_statelistraw)) BEGIN
					SET @destination_states_csv = @destination_states_csv + @comma + SUBSTRING(@destination_statelistraw, @charptr, 2) 
					SET @comma = ','
					SET @charptr = @charptr + 2
				END
			END
		END
		*/
		
		--PTS 49333 JJF 20091009
		--IF isnull(@origin_latitude, 0) = 0 and isnull(@origin_longitude, 0) = 0 and isnull(@destination_latitude, 0) = 0 and isnull(@destination_longitude, 0) = 0 BEGIN
		IF isnull(@origin_latitude, 0) = 0 and isnull(@origin_longitude, 0) = 0 and isnull(@destination_latitude, 0) = 0 and isnull(@destination_longitude, 0) = 0 and isnull(@origin_state, '') = '' and isnull(@destination_states_csv, '') = '' BEGIN
			SET @ete_automatch = 'N'
		END
		--END PTS 49333 JJF 20091009

		IF @DEBUG = 'Y' BEGIN
			PRINT 'Resolved Parm list'
			PRINT '@ete_id: ' + isnull(convert(varchar(30), @ete_id), 'null')
			PRINT '@lgh_outstatus_list_csv: ' + isnull(@lgh_outstatus_list_csv, 'null')
			PRINT '@origin_latitude: ' + isnull(convert(varchar(30), @origin_latitude), 'null')
			PRINT '@origin_longitude: ' + isnull(convert(varchar(30), @origin_longitude), 'null')
			PRINT '@origin_radius: ' + isnull(convert(varchar(30), @origin_radius), 'null')
			PRINT '@origin_state: ' + isnull(convert(varchar(30), @origin_state), 'null')
			PRINT '@destination_latitude: ' + isnull(convert(varchar(30), isnull(@destination_latitude, 0)), 'null')
			PRINT '@destination_longitude: ' + isnull(convert(varchar(30), isnull(@destination_longitude, 0)), 'null')
			PRINT '@destination_radius: ' + isnull(convert(varchar(30), @destination_radius), 'null')
			PRINT '@destination_states_csv: ' + isnull(@destination_states_csv, 'null')
			PRINT '@ete_automatch: ' + isnull(@ete_automatch, 'null')
			PRINT '@available_date: ' + convert(varchar(30), @available_date)
			PRINT ''
		END
		
		IF @ete_automatch = 'Y' BEGIN

			--PTS 50149 - use expiredate
			IF EXISTS(	SELECT * 		
						FROM	generalinfo 
						WHERE	gi_name = 'ExternalEquipAutoMatchExpires'
								AND isnull(ltrim(rtrim(gi_string1)), 'Y') <> 'Y')							BEGIN
								
				SELECT	@expire_date = '9999-01-01'
			END
			--END PTS 50149 - use expiredate
			
			exec @proc_to_call 
						@ete_id,
						@lgh_outstatus_list_csv,
						@available_date,
						--PTS 50149 - use expiredate
						--'9999-01-01',
						@expire_date,
						--END PTS 50149 - use expiredate
						--PTS 49333 JJF 20091008
						--@origin_cty_code,
						@origin_city,
						--END PTS 49333 JJF 20091008
						@origin_latitude,
						@origin_longitude,
						@origin_radius,
						@origin_state,
						--PTS 49333 JJF 20091008
						--@destination_cty_code,
						@destination_city,
						--END PTS 49333 JJF 20091008
						@destination_latitude,
						@destination_longitude,
						@destination_radius,
						@destination_states_csv

			IF @DEBUG = 'Y' BEGIN
				PRINT 'Return from trip retrieval proc:'
				SELECT * FROM #matching_trips
			END

			--PTS 49216 JJF 20090925
			IF ISNULL(@proc_additional_filter, '') <> '' BEGIN
				IF @debug = 'Y' BEGIN
					PRINT ''
					PRINT 'additional filtering...'
				END

				exec @proc_additional_filter
					@ete_id,
					@ete_equipmenttype

				IF @DEBUG = 'Y' BEGIN
					PRINT 'trips remaining after additional filtering:'
					SELECT * 
					FROM #matching_trips
				END
			END
			--END PTS 49216 JJF 20090925
			
			EXEC TripsAutoMatch_FilterRequirements_sp @car_id = @car_id
		END		
	END

	--Build final resultset
	INSERT	@FinalResult
	SELECT	mtrips.mt_id,
			lgh.lgh_number,
			lgh.mov_number,
			oh.ord_hdrnumber,
			oh.ord_number,
			mtrips.distance_to_origin, 
			mtrips.distance_to_destination,
			oh.ord_totalmiles,
			oh.ord_billto,
			cmpbillto.cmp_name as ord_billto_name,
			lgh.lgh_schdtearliest as schdtearliest,
			lgh.cmp_id_start as cmp_id_start,
			cmpstart.cmp_name as cmp_id_start_name,
			lgh.lgh_startcity as startcity,
			lgh.lgh_startcty_nmstct as startcty_nmstct,
			lgh.lgh_schdtlatest as schdtlatest,
			lgh.cmp_id_end  as cmp_id_end,
			cmpend.cmp_name as cmp_id_end_name,
			lgh.lgh_endcity as endcity,
			lgh.lgh_endcty_nmstct as endcty_nmstct,
			'RevType1' as revtype1_t,
			oh.ord_revtype1,
			'RevType2' as revtype2_t,
			oh.ord_revtype2,
			'RevType3' as revtype3_t,
			oh.ord_revtype3,
			'RevType4' as revtype4_t,
			oh.ord_revtype4,
			cmpbillto.cmp_revtype1,
			cmpbillto.cmp_revtype2,
			cmpbillto.cmp_revtype3,
			cmpbillto.cmp_revtype4,
			'TrlType1' as trl_type1_t,
			oh.trl_type1 as trl_type1,
			'TrlType2' as trl_type2_t,
			oh.ord_trl_type2 as trl_type2,
			'TrlType3' as trl_type3_t,
			oh.ord_trl_type3 as trl_type3,
			'TrlType4' as trl_type4_t,
			oh.ord_trl_type4 as trl_type4,
			oh.ord_stopcount as stop_count
	FROM	legheader_active lgh
			inner join #matching_trips mtrips on lgh.lgh_number = mtrips.lgh_number
			inner join orderheader oh on lgh.ord_hdrnumber = oh.ord_hdrnumber
			left outer join company cmpbillto on oh.ord_billto = cmpbillto.cmp_id
			left outer join company cmpstart on lgh.cmp_id_start = cmpstart.cmp_id
			left outer join company cmpend on lgh.cmp_id_end = cmpend.cmp_id
			left outer join city ctyo on oh.ord_origincity = ctyo.cty_code	
			left outer join city ctyd on oh.ord_destcity = ctyd.cty_code
	ORDER BY mtrips.mt_id

	DROP TABLE #matching_trips

	UPDATE	@FinalResult
	SET		revtype1_t = lblh.RevType1,
			revtype2_t = lblh.RevType2,
			revtype3_t = lblh.RevType3,
			revtype4_t = lblh.RevType4,
			trl_type1_t = lblh.TrlType1,
			trl_type2_t = lblh.TrlType2,
			trl_type3_t = lblh.TrlType3,
			trl_type4_t = lblh.TrlType4
	FROM	labelfile_headers lblh

	SELECT  lgh_number,
			mov_number,
			ord_hdrnumber,
			ord_number,
			distance_to_origin,
			distance_to_destination,
			ord_totalmiles,
			ord_billto,
			ord_billto_name,
			schdtearliest,
			cmp_id_start,
			cmp_id_start_name,
			startcity,
			startcty_nmstct,
			schdtlatest,
			cmp_id_end,
			cmp_id_end_name,
			endcity,
			endcty_nmstct,
			revtype1_t,
			ord_revtype1,
			revtype2_t,
			ord_revtype2,
			revtype3_t,
			ord_revtype3,
			revtype4_t,
			ord_revtype4,
			cmpbillto_cmp_revtype1,
			cmpbillto_cmp_revtype2,
			cmpbillto_cmp_revtype3,
			cmpbillto_cmp_revtype4,
			trl_type1_t,
			trl_type1,
			trl_type2_t,
			trl_type2,
			trl_type3_t,
			trl_type3,
			trl_type4_t,
			trl_type4,
			stop_count
	FROM	@FinalResult 
	ORDER BY sort_order

GO
GRANT EXECUTE ON  [dbo].[MatchingTripsForExternalEquipment_sp] TO [public]
GO
