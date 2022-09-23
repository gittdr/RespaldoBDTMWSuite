SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[get_qualified_trlwash_sp] 
	@cmd_code	VARCHAR(8000), 
	@cmd_class	VARCHAR(8000),
	@drop_loc	INTEGER,
	@next_loc	INTEGER
AS

DECLARE @deg_or_sec	CHAR(1),
		@lat_1		DECIMAL(12,6),
		@long_1		DECIMAL(12,6),
		@lat_2		DECIMAL(12,6),
		@long_2		DECIMAL(12,6),
		@empty_cost	MONEY

DECLARE @cmps TABLE(
	cmp_id		VARCHAR(8),
	latitude	DECIMAL(12,6),
	longitude	DECIMAL(12,6),
	miles1		INTEGER,
	miles2		INTEGER)

SELECT	@empty_cost = CAST((ISNULL(CAST(gi_integer1 AS MONEY), 0)/100) AS MONEY)
  FROM	generalinfo 
 WHERE	gi_name = 'EmptyMileageCost'


SELECT	@deg_or_sec = UPPER(LEFT(gi_string1,1))
  FROM	dbo.generalinfo
 WHERE	gi_name = 'CityLatLongUnits'

SELECT	@lat_1 =	CASE @deg_or_sec
						WHEN 'D' THEN cty_latitude
						WHEN 'S' THEN cty_latitude / 3600
						ELSE cty_latitude
					END,
		@long_1 =	CASE @deg_or_sec
						WHEN 'D' THEN cty_longitude
						WHEN 'S' THEN cty_longitude / 3600
						ELSE cty_longitude
					END
  FROM	dbo.city
 WHERE	cty_code = @drop_loc

SELECT	@lat_2 =	CASE @deg_or_sec
						WHEN 'D' THEN cty_latitude
						WHEN 'S' THEN cty_latitude / 3600
						ELSE cty_latitude
					END,
		@long_2 =	CASE @deg_or_sec
						WHEN 'D' THEN cty_longitude
						WHEN 'S' THEN cty_longitude / 3600
						ELSE cty_longitude
					END
  FROM	dbo.city
 WHERE	cty_code = @next_loc

INSERT INTO @cmps
	(cmp_id, latitude, longitude)
	SELECT	co.cmp_id,
			CASE @deg_or_sec
				WHEN 'D' THEN ci.cty_latitude
				WHEN 'S' THEN ci.cty_latitude / 3600
				ELSE ci.cty_latitude
			END cty_latitude,
			CASE @deg_or_sec
				WHEN 'D' THEN ci.cty_longitude
				WHEN 'S' THEN ci.cty_longitude / 3600
				ELSE ci.cty_longitude
			END cty_longitude
	  FROM	dbo.company co 
				INNER JOIN dbo.city ci ON co.cmp_city = ci.cty_code
	 WHERE	co.cmp_service_location = 'Y' AND
			co.cmp_active = 'Y' AND
			(co.cmp_id NOT IN (SELECT	c.cmp_id
								 FROM	dbo.service_location_qualifications slq 
											INNER JOIN dbo.company	c ON slq.cmp_id = c.cmp_id
											INNER JOIN CSVStringsToTable_fn(@cmd_code) cmd ON cmd.value = slq.cmd_code
								WHERE	c.cmp_service_location = 'Y' AND
										ISNULL(c.cmp_service_location_qual, 'Y') = 'Y'
							   UNION
							   SELECT	c.cmp_id
								 FROM	dbo.service_location_qualifications slq 
											INNER JOIN dbo.company	c ON slq.cmp_id = c.cmp_id
											INNER JOIN CSVStringsToTable_fn(@cmd_class) ccl ON ccl.value = slq.cmd_class
							  	WHERE	c.cmp_service_location = 'Y' AND
										ISNULL(c.cmp_service_location_qual, 'Y') = 'Y'	) OR
			 co.cmp_id IN (SELECT	c.cmp_id
							 FROM	dbo.service_location_qualifications slq 
										INNER JOIN dbo.company	c ON slq.cmp_id = c.cmp_id
										INNER JOIN CSVStringsToTable_fn(@cmd_code) cmd ON cmd.value = slq.cmd_code
							WHERE	c.cmp_service_location = 'Y' AND
									ISNULL(c.cmp_service_location_qual, 'Y') = 'N'
						   UNION
						   SELECT	c.cmp_id
							 FROM	dbo.service_location_qualifications slq 
										INNER JOIN dbo.company	c ON slq.cmp_id = c.cmp_id
											INNER JOIN CSVStringsToTable_fn(@cmd_class) ccl ON ccl.value = slq.cmd_class
							WHERE	c.cmp_service_location = 'Y' AND
									ISNULL(c.cmp_service_location_qual, 'Y') = 'N'))

UPDATE	@cmps
   SET	miles1 = dbo.tmw_airdistance_fn(latitude, longitude, @lat_1, @long_1),
		miles2 = dbo.tmw_airdistance_fn(latitude, longitude, @lat_2, @long_2)

SELECT	0 calc_count,
		cmp.cmp_id,	
		cmp.miles1 miles_to_wash,
		cmp.miles2 miles_from_wash,
		co.cmp_name,
		co.cmp_address1,
		co.cmp_city,
		co.cty_nmstct,
		co.cmp_zip,
		ISNULL(co.cmp_service_location_rating, 'UNK') cmp_service_location_rating,
		co.cmp_openmon,
		co.cmp_opens_mo,
		co.cmp_closes_mo,
		co.cmp_opentue,
		co.cmp_opens_tu,
		co.cmp_closes_tu,
		co.cmp_openwed,
		co.cmp_opens_we,
		co.cmp_closes_we,
		co.cmp_openthu,
		co.cmp_opens_th,
		co.cmp_closes_th,
		co.cmp_openfri,
		co.cmp_opens_fr,
		co.cmp_closes_fr,
		co.cmp_opensat,
		co.cmp_opens_sa,
		co.cmp_closes_sa,
		co.cmp_opensun,
		co.cmp_opens_su,
		co.cmp_closes_su,
		ISNULL(twc.twc_wash_count, 0),
		ISNULL(twc.twc_total_wash_cost, 0),
		@empty_cost empty_mileage_cost,
		ISNULL((SELECT	SUM(ISNULL(cps.cps_estqty, 0) * ISNULL(vps.vps_estrate, 0.00))
				  FROM	commoditypurchaseservices cps
							INNER JOIN CSVStringsToTable_fn(@cmd_code) a ON a.value = cps.cmd_code
							INNER JOIN vendorpurchaseservices vps ON cps.psd_type = vps.psd_type AND vps.cmp_id = cmp.cmp_id), 0) estimated_cost,
		CAST('N' AS CHAR(1)) processed_prior,
		CAST('N' AS CHAR(1)) processed_next
  FROM	@cmps cmp 
			INNER JOIN dbo.company co ON co.cmp_id = cmp.cmp_id
			LEFT OUTER JOIN dbo.trailer_wash_costs twc ON (twc.cmp_id = cmp.cmp_id AND twc.cmd_code IN (SELECT value FROM CSVStringsToTable_fn(@cmd_code)))
GO
GRANT EXECUTE ON  [dbo].[get_qualified_trlwash_sp] TO [public]
GO
