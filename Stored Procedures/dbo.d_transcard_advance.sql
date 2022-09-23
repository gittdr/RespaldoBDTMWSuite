SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_transcard_advance] @driver_id    VARCHAR(8),
                                         @pay_type     VARCHAR(6)
AS
DECLARE @begin_date        DATETIME,
        @end_date          DATETIME,
        @minlgh            INTEGER,
        @stp_number        INTEGER,
        @stp_arrivaldate   DATETIME,
        @stp_city          INTEGER,
        @orig_lat          DECIMAL(12,4),
        @orig_long         DECIMAL(12,4),
        @ckc_city          INTEGER,
        @dest_lat          DECIMAL(12,4),
        @dest_long         DECIMAL(12,4),
        @distance          INTEGER,
        @advance_rate      MONEY,
        @cty_name          VARCHAR(18),
        @cty_state         VARCHAR(6),
        @cityname          VARCHAR(30),
        @Driver_solo_rate  MONEY,
        @driver_team_rate  MONEY,
        @default_solo_rate MONEY,
        @default_team_rate MONEY,
        @solo_rate         MONEY,
        @team_rate         MONEY

CREATE TABLE #legs (
   lgh_number            INTEGER NULL,
   lgh_driver1           VARCHAR(8) NULL,
   lgh_driver2           VARCHAR(8) NULL,
   lgh_outstatus         VARCHAR(6) NULL,
   lgh_startdate         DATETIME NULL,
   lgh_miles             INTEGER NULL,
   lgh_miles_completed   INTEGER NULL,
   stp_city              VARCHAR(50) NULL,
   stp_latitude          DECIMAL(12,4) NULL,
   stp_longitude         DECIMAL(12,4) NULL,
   ckc_city              INTEGER NULL,
   ckc_latitude          DECIMAL(12,4) NULL,
   ckc_longitude         DECIMAL(12,4) NULL,
   lgh_checkcall_miles   INTEGER NULL,
   advance_rate          MONEY NULL,
   amount_taken          MONEY NULL,
   authorized_amount     MONEY NULL,
   applied_amount        MONEY NULL,
   cash_card             VARCHAR(20),
   ord_hdrnumber         INTEGER NULL
)

SELECT @driver_solo_rate = ISNULL(mpp_advance_rate_solo, 0),
       @driver_team_rate = ISNULL(mpp_advance_rate_team, 0)
  FROM manpowerprofile
 WHERE mpp_id = @driver_id

SELECT @default_solo_rate = CAST(gi_string2 AS MONEY),
       @default_team_rate = CAST(gi_string3 AS MONEY)
  FROM generalinfo
 WHERE gi_name = 'AdvanceRateProcess'

IF @driver_solo_rate = 0
BEGIN
   SET @solo_rate = @default_solo_rate
END
ELSE
BEGIN
   SET @solo_rate = @driver_solo_rate
END

IF @driver_team_rate = 0
BEGIN
   SET @team_rate = @default_team_rate
END
ELSE
BEGIN
   SET @team_rate = @driver_team_rate
END

IF @advance_rate = 0
BEGIN
   SELECT @advance_rate = CAST(gi_string2 AS MONEY)
     FROM generalinfo
    WHERE gi_name = 'AdvanceRateProcess'
END

SET @end_date = GETDATE()
SET @begin_date = DATEADD(day, -10, @end_date)

INSERT INTO #legs
   SELECT lgh_number,
          lgh_driver1,
          ISNULL(lgh_driver2, 'UNKNOWN'),
          lgh_outstatus,
          lgh_startdate,
         (SELECT ISNULL(SUM(stp_lgh_mileage), 0) 
            FROM stops 
           WHERE stops.lgh_number = legheader.lgh_number),
         (SELECT ISNULL(SUM(stp_lgh_mileage), 0)
            FROM stops
           WHERE stops.lgh_number = legheader.lgh_number AND
                 stops.stp_status = 'DNE'),
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
         (SELECT ISNULL(SUM(pyd_amount + ISNULL(pyt_fee1,0)), 0)
            FROM paydetail
           WHERE paydetail.lgh_number = legheader.lgh_number AND
                 paydetail.asgn_type = 'DRV' AND
                 paydetail.asgn_id = @driver_id AND
                 paydetail.pyt_itemcode = @pay_type),
          0,
          0,
          '',
          ISNULL(legheader.ord_hdrnumber, 0)
     FROM legheader
    WHERE lgh_driver1 = @driver_id AND
          lgh_outstatus IN ('CMP', 'STD') AND
          lgh_startdate BETWEEN @begin_date AND @end_date AND
         (SELECT COUNT(*)
            FROM paperwork
           WHERE paperwork.ord_hdrnumber = legheader.ord_hdrnumber AND
                 pw_received = 'N') > 0 AND
          legheader.lgh_number NOT IN (SELECT assetassignment.lgh_number
                                         FROM assetassignment
                                        WHERE assetassignment.lgh_number = legheader.lgh_number AND
                                              assetassignment.asgn_type = 'DRV' AND
                                              assetassignment.asgn_id = @driver_id AND
                                              assetassignment.pyd_status = 'PPD')
	UNION
	   SELECT lgh_number,
          lgh_driver1,
          ISNULL(lgh_driver2, 'UNKNOWN'),
          lgh_outstatus,
          lgh_startdate,
         (SELECT ISNULL(SUM(stp_lgh_mileage), 0) 
            FROM stops 
           WHERE stops.lgh_number = legheader.lgh_number),
         (SELECT ISNULL(SUM(stp_lgh_mileage), 0)
            FROM stops
           WHERE stops.lgh_number = legheader.lgh_number AND
                 stops.stp_status = 'DNE'),
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
         (SELECT ISNULL(SUM(pyd_amount + ISNULL(pyt_fee1,0)), 0)
            FROM paydetail
           WHERE paydetail.lgh_number = legheader.lgh_number AND
                 paydetail.asgn_type = 'DRV' AND
                 paydetail.asgn_id = @driver_id AND
                 paydetail.pyt_itemcode = @pay_type),
          0,
          0,
          '',
          ISNULL(legheader.ord_hdrnumber, 0)
     FROM legheader
    WHERE lgh_driver2 = @driver_id AND
          lgh_outstatus IN ('CMP', 'STD') AND
          lgh_startdate BETWEEN @begin_date AND @end_date AND
         (SELECT COUNT(*)
            FROM paperwork
           WHERE paperwork.ord_hdrnumber = legheader.ord_hdrnumber AND
                 pw_received = 'N') > 0 AND
          legheader.lgh_number NOT IN (SELECT assetassignment.lgh_number
                                         FROM assetassignment
                                        WHERE assetassignment.lgh_number = legheader.lgh_number AND
                                              assetassignment.asgn_type = 'DRV' AND
                                              assetassignment.asgn_id = @driver_id AND
                                              assetassignment.pyd_status = 'PPD')

SET @minlgh = 0
WHILE 1=1
BEGIN
   SELECT @minlgh = MIN(lgh_number)
     FROM #legs
    WHERE lgh_number > @minlgh AND
          lgh_outstatus = 'STD'

   IF @minlgh is null
      BREAK

   SELECT @stp_number = stp_number
     FROM stops
    WHERE stops.lgh_number = @minlgh AND
          stops.stp_status = 'DNE' AND
          stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                                      FROM stops
                                     WHERE stops.lgh_number = @minlgh AND
                                           stops.stp_status = 'DNE')
   
   SELECT @stp_arrivaldate = stp_arrivaldate,
          @stp_city = stp_city
     FROM stops
    WHERE stp_number = @stp_number

   SELECT @cty_name = cty_name,
          @cty_state = cty_state
     FROM city
    WHERE cty_code = @stp_city
   IF Len(@cty_name) > 0 AND LEN(@cty_state) > 0
   BEGIN
      SET @cityname = RTRIM(@cty_name) + ', ' + RTRIM(@cty_state)
   END

   SELECT @orig_lat = cty_latitude,
          @orig_long = cty_longitude
     FROM city
    WHERE city.cty_code = @stp_city

   SELECT @dest_lat = ckc_latseconds/3600.0000,
          @dest_long = ckc_longseconds/3600.0000,
          @ckc_city = ISNULL(ckc_city, 0)
     FROM checkcall
    WHERE ckc_lghnumber = @minlgh AND
          ckc_date = (SELECT MAX(ckc_date)
                        FROM checkcall
                       WHERE ckc_lghnumber = @minlgh AND
                             ckc_date > @stp_arrivaldate)

   IF @orig_lat > 0 AND @orig_long > 0 AND @dest_lat > 0 AND @dest_long > 0
   BEGIN
      SET @distance = dbo.tmw_airdistance_fn (@orig_lat, @orig_long, @dest_lat, @dest_long)
      IF @distance > 0
      BEGIN
        UPDATE #legs
           SET stp_city = @cityname,
               stp_latitude = @orig_lat,
               stp_longitude = @orig_long,
               ckc_city = @ckc_city,
               ckc_latitude = @dest_lat,
               ckc_longitude = @dest_long, 
               lgh_checkcall_miles = @distance
         WHERE #legs.lgh_number = @minlgh
      END
   END
END

UPDATE #legs
   SET advance_rate = @solo_rate
 WHERE lgh_driver1 = @driver_id AND
       lgh_driver2 = 'UNKNOWN'

UPDATE #legs
   SET advance_rate = @team_rate
 WHERE (lgh_driver1 = @driver_id OR lgh_driver2 = @driver_id) AND
        lgh_driver2 <> 'UNKNOWN'

SELECT lgh_number,
       lgh_driver1,
       lgh_driver2,
       lgh_outstatus,
       lgh_startdate,
       lgh_miles,
       lgh_miles_completed,
       stp_city,
       stp_latitude,
       stp_longitude,
       ckc_city,
       ckc_latitude,
       ckc_longitude,
       lgh_checkcall_miles,
       advance_rate,
       amount_taken,
       authorized_amount,
       applied_amount,
       ROUND((lgh_miles * advance_rate), 0) total_available,
       CASE WHEN lgh_outstatus = 'CMP' THEN ROUND((lgh_miles * advance_rate), 0)
            ELSE ROUND(((lgh_checkcall_miles + lgh_miles_completed) * advance_rate), 0)
       END miles_available,
       CASE WHEN lgh_outstatus = 'CMP' THEN ROUND(((lgh_miles * advance_rate) + amount_taken), 0)
            ELSE ROUND((((lgh_checkcall_miles + lgh_miles_completed) * advance_rate) + amount_taken), 0)
       END amount_left,
       cash_card,
       ord_hdrnumber
  FROM #legs
 
GO
GRANT EXECUTE ON  [dbo].[d_transcard_advance] TO [public]
GO
