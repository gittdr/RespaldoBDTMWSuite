SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[drvplan_mileage] 
	(@driver 			VARCHAR(8),
	 @driverplan_number	INTEGER,
	 @first_sequence 	INTEGER)

AS

IF @driverplan_number = 0
BEGIN
SELECT	lgh.lgh_number,
		lgh.lgh_startcity,
		lgh.lgh_endcity,
		lgh.cmp_id_start,
		lgh.cmp_id_end,
		co1.cmp_zip cmp_zip_start,
		co2.cmp_zip cmp_zip_end,
		ci1.cty_zip cty_zip_start,
		ci2.cty_zip cty_zip_end,
		0 total_dh_miles
  FROM	legheader_active lgh,
		company co1,
		company co2,
		city ci1,
		city ci2
 WHERE	lgh.lgh_startcity = ci1.cty_code AND
		lgh.lgh_endcity = ci2.cty_code AND
		lgh.cmp_id_start = co1.cmp_id AND
		lgh.cmp_id_end = co2.cmp_id AND
		lgh.lgh_driver1 = @driver AND
		ISNULL(lgh.mfh_number, -1) >= @first_sequence
ORDER BY lgh.mfh_number
END
ELSE
BEGIN
SELECT	lgh.lgh_number,
		lgh.lgh_startcity,
		lgh.lgh_endcity,
		lgh.cmp_id_start,
		lgh.cmp_id_end,
		co1.cmp_zip cmp_zip_start,
		co2.cmp_zip cmp_zip_end,
		ci1.cty_zip cty_zip_start,
		ci2.cty_zip cty_zip_end,
		0 total_dh_miles
  FROM	legheader_active lgh,
		company co1,
		company co2,
		city ci1,
		city ci2
 WHERE	lgh.lgh_startcity = ci1.cty_code AND
		lgh.lgh_endcity = ci2.cty_code AND
		lgh.cmp_id_start = co1.cmp_id AND
		lgh.cmp_id_end = co2.cmp_id AND
		lgh.drvplan_number = @driverplan_number
ORDER BY lgh.mfh_number
END
GO
GRANT EXECUTE ON  [dbo].[drvplan_mileage] TO [public]
GO
