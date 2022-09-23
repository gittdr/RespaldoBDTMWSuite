SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[TripsAutoMatch_sp]
(
	@source_id	int,  --used to stamp equipment ID in #matching_trips.  
	@lgh_outstatus_list_csv	varchar(254),
	@earliest_start_date datetime,
	@latest_start_date datetime,
	--PTS 49333 JJF 20091008
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
	--END PTS 49333 JJF 20091008
	@destination_latitude decimal(8, 4),
	@destination_longitude decimal(8, 4), 
	@destination_radius int,
	@destination_states_csv varchar(254)
	
)

AS
/**
 * 
 * NAME:
 * dbo.TripsAutoMatch_sp
 *
 * TYPE:
 * Stored Proc
 *
 * DESCRIPTION:
 * Returns trips that are pickup with n distance of an origin point and drops x distance of a destination point
 * Expects existing temp table #matching_trips, created by caller
 *
 * PTS 46005/46541 JJF 20090428
 *
 **/

BEGIN

	DECLARE @Leg_outstatus	table(
				lgh_outstatus	varchar(6)	NULL
			)

	DECLARE @Destination_state	table(
				state		varchar(6)	NULL
			)

	INSERT	@Leg_outstatus
	SELECT	value 
	FROM	CSVStringsToTable_fn(@lgh_outstatus_list_csv)
	
	--PTS 49333 JJF 20091008
	SELECT @origin_state = isnull(@origin_state, '')
	--END PTS 49333 JJF 20091008

	SELECT @destination_states_csv = isnull(@destination_states_csv, '')
	IF @destination_states_csv <> '' BEGIN
		SELECT @destination_radius = 999999 --radius not used if states specified

		INSERT	@Destination_state
		SELECT	value
		FROM	CSVStringsToTable_fn(@destination_states_csv)
		
		INSERT	@Destination_state
		SELECT	tcz_state
		FROM	transcore_zones tcz
				INNER JOIN @Destination_state ds on tcz.tcz_zone = ds.[state]
		WHERE	LEFT(ds.[state], 1) = 'Z'

		DELETE FROM @Destination_state
		WHERE	LEFT([state], 1) = 'Z'
	END
	ELSE BEGIN
		--Add in one entry if destination states are not in use.
		--This way inner joins can function, and the condition must include @destination_states_csv is null
		INSERT	@Destination_state
		SELECT	'%'
	END
	
	INSERT	#matching_trips
			(
				source_id,
				lgh_number,
				mov_number,
				ord_hdrnumber,
				distance_to_origin,
				distance_to_destination
			)
	SELECT	@source_id,
			lgh_number,
			mov_number,
			ord_hdrnumber, 
			distance_to_origin,
			distance_to_destination
	FROM	(

				SELECT	lgh_number,
						mov_number,			
						ord_hdrnumber,
						dbo.tmw_airdistance_fn(@origin_latitude, @origin_longitude, ord_origin_latitude, ord_origin_longitude) as distance_to_origin,
						dbo.tmw_airdistance_fn(@destination_latitude, @destination_longitude, ord_destination_latitude, ord_destination_longitude) as distance_to_destination
				FROM	(
							SELECT	lgh_number,
									mov_number,			
									ord_hdrnumber, 
									CASE isnull(cmpo_latitude, 0) 
										WHEN 0 THEN ctyo_cty_latitude 
										ELSE cmpo_latitude 
									END as ord_origin_latitude,
									CASE isnull(cmpo_longitude, 0) 
										WHEN 0 THEN ctyo_cty_longitude 
										ELSE cmpo_longitude 
									END as ord_origin_longitude,
									CASE isnull(cmpd_latitude, 0) 
										WHEN 0 THEN ctyd_cty_latitude 
										ELSE cmpd_latitude 
									END as ord_destination_latitude,
									CASE isnull(cmpd_longitude, 0) 
										WHEN 0 THEN ctyd_cty_longitude 
										ELSE cmpd_longitude 
									END as ord_destination_longitude
							FROM	(
										--PTS 48513 JJF 20090824, state list could contain duplicates...add distinct
										SELECT DISTINCT	lgh.lgh_number,
												lgh.mov_number,			
												oh.ord_hdrnumber,
												ROUND( ISNULL( cmpo.cmp_latseconds, 0.0000 ) / 3600.000, 4 ) as cmpo_latitude, 
												ROUND( ISNULL( cmpo.cmp_longseconds, 0.0000 ) / 3600.000, 4 ) as cmpo_longitude,
												ctyo.cty_latitude as ctyo_cty_latitude, 
												ctyo.cty_longitude as ctyo_cty_longitude, 
												ROUND( ISNULL( cmpd.cmp_latseconds, 0.0000 ) / 3600.000, 4 ) as cmpd_latitude, 
												ROUND( ISNULL( cmpd.cmp_longseconds, 0.0000 ) / 3600.000, 4 ) as cmpd_longitude,
												ctyd.cty_latitude as ctyd_cty_latitude, 
												ctyd.cty_longitude as ctyd_cty_longitude
										FROM	legheader_active lgh
												inner join orderheader oh on lgh.ord_hdrnumber = oh.ord_hdrnumber
												inner join @Leg_outstatus ostat on lgh.lgh_outstatus = ostat.lgh_outstatus
												inner join @Destination_state stated on (oh.ord_deststate = stated.state or (@destination_states_csv = ''))
												left outer join company cmpo on lgh.cmp_id_start = cmpo.cmp_id
												left outer join city ctyo on lgh.lgh_startcity = ctyo.cty_code	
												left outer join company cmpd on lgh.cmp_id_end = cmpd.cmp_id
												left outer join city ctyd on lgh.lgh_endcity = ctyd.cty_code	
										WHERE	ISNULL(oh.ord_extequip_automatch, 'Y') = 'Y'
												--PTS 49311 JJF 20091008
												--AND lgh.lgh_schdtearliest >= @earliest_start_date
												--AND lgh.lgh_schdtearliest <= @latest_start_date
												AND lgh.lgh_schdtlatest >= @earliest_start_date
												--PTS 50149 JJF 20091207
												--AND lgh.lgh_schdtlatest <= @latest_start_date
												AND lgh.lgh_schdtearliest <= @latest_start_date
												--END PTS 50149 JJF 20091207
												AND (oh.ord_originstate = @origin_state or @origin_state = '')
												--PTS 49311 JJF 20091008
												
									) dt_orderinfo
						) dt_highestresolution_latlong
			) dt_distance_computed
	WHERE	(distance_to_origin <= @origin_radius or (isnull(@origin_latitude, 0) = 0 AND isnull(@origin_longitude, 0) = 0))
			and (distance_to_destination <= @destination_radius or @destination_states_csv <> '' or (isnull(@destination_latitude, 0) = 0 AND isnull(@destination_longitude, 0) = 0))
	ORDER BY distance_to_origin, distance_to_destination

END
GO
GRANT EXECUTE ON  [dbo].[TripsAutoMatch_sp] TO [public]
GO
