SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[AssetsAutoMatch_sp]
(
	@source_id	int,  --used to stamp ord_hdrnumber in #matching_assets to support multiple order results
	@earliest_start_date datetime,
	@latest_start_date datetime,
	@origin_state varchar(6),
	@origin_latitude decimal(8, 4), 
	@origin_longitude decimal(8, 4), 
	@destination_state varchar(6),
	@destination_latitude decimal(8, 4),
	@destination_longitude decimal(8, 4)
)

/*
sample: (To test isolated, uncomment temp table creation and final select at bottom)
exec AssetsAutoMatch_sp
	@source_id = 7186,
	@earliest_start_date = 'Jul  1 2009 12:00AM',
	@latest_start_date = '9999-01-01',
	@origin_state = 'CA',
	@origin_latitude = 32.4200,
	@origin_longitude = 117.0800,
	@destination_state = 'OH',
	@destination_latitude = 41.4942,
	@destination_longitude = 81.6856
*/

AS
/**
 * 
 * NAME:
 * dbo.AssetsAutoMatch_sp
 *
 * TYPE:
 * Stored Proc
 *
 * DESCRIPTION:
 * Returns assets that are pickup with n distance of an origin point and drops x distance of a destination point
 * Expects existing temp table #matching_assets, created by caller
 *
 * PTS 46342 JJF 20090818
 *
 **/

BEGIN

	/*
	CREATE TABLE #matching_assets(
		ma_id					int				NOT NULL IDENTITY (1, 1),
		source_id				int				NULL,
		ete_id					int				NULL,
		car_id					varchar(8)		NULL,
		distance_to_origin		int				NULL,
		distance_to_destination	int				NULL
	)
	*/
	
	DECLARE @Origin_Zone	char(2)
	DECLARE @Destination_Zone char(2)

	SELECT	@Origin_Zone = tcz_zone
	FROM	transcore_zones
	WHERE	tcz_state = @origin_state
	
	SELECT @Origin_Zone = ISNULL(@Origin_Zone, '')

	SELECT	@Destination_Zone = tcz_zone
	FROM	transcore_zones
	WHERE	tcz_state = @destination_state
	
	SELECT @Destination_Zone = ISNULL(@Destination_Zone, '')


	INSERT	#matching_assets
			(
				source_id,
				ete_id,
				car_id,
				distance_to_origin,
				distance_to_destination
			)
	SELECT	@source_id,
			ete_id,
			ete_carrierid,
			distance_to_origin,
			distance_to_destination
	FROM	(

				SELECT	ete_id,
						ete_carrierid,
						ete_originradius,
						ete_destradius,
						dbo.tmw_airdistance_fn(@origin_latitude, @origin_longitude, ete_origlatitude, ete_origlongitude) as distance_to_origin,
						dbo.tmw_airdistance_fn(@destination_latitude, @destination_longitude, ete_destlatitude, ete_destlongitude) as distance_to_destination,
						ete_destination_states,
						ete_destlatitude,
						ete_destlongitude
				FROM	(

							SELECT	ete.ete_id,
									ete.ete_carrierid,
									ete_destination_states = CASE CHARINDEX(',', ete.ete_destcity, 1)
																WHEN 0 THEN 
																	CASE 
																		WHEN ete.ete_destcity = 'UNKNOWN' THEN ''
																		ELSE ete.ete_destcity
																	END
															END,
									ete_origlatitude,
									ete_origlongitude,
									ete_destlatitude,
									ete_destlongitude,
									ete_originradius,
									ete_destradius
							FROM	external_equipment ete
							WHERE	ISNULL(ete.ete_automatch, 'Y') = 'Y'
									AND ete.ete_availabledate <= @earliest_start_date
									AND ete.ete_expirationdate  >= getdate()
						) dt_assets
			) dt_distance_computed
	WHERE	distance_to_origin <= ete_originradius
			and (	(distance_to_destination <= ete_destradius) 
					or ((CHARINDEX(@destination_state, ete_destination_states) % 2) = 1 or (CHARINDEX(@Destination_Zone, ete_destination_states) % 2) = 1) 
					or (LEN(ISNULL(ete_destination_states, '')) = 0 and (isnull(ete_destlatitude, 0) = 0 AND isnull(ete_destlongitude, 0) = 0))
				)
	ORDER BY distance_to_origin, distance_to_destination

	/*	
	SELECT	*
	FROM	#matching_assets 
	*/
	
	RETURN 
END
GO
GRANT EXECUTE ON  [dbo].[AssetsAutoMatch_sp] TO [public]
GO
