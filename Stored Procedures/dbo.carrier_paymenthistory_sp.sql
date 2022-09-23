SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[carrier_paymenthistory_sp]
	@car_id					VARCHAR(8),
	@origin					VARCHAR(58),
	@destination				VARCHAR(58),
	@oradius				INTEGER, 	
	@dradius				INTEGER
AS


SET NOCOUNT ON

CREATE TABLE #origin_states (
	origin_state	VARCHAR(6)
	)

CREATE TABLE #destination_states (
	destination_state  VARCHAR(6)
	)

CREATE TABLE #temp1 (
	crh_carrier			VARCHAR(8) NULL,
	ord_hdrnumber			INTEGER NULL,
	ord_origincity			INTEGER NULL,
	origin_nmstct			VARCHAR(30) NULL,
	ord_destcity			INTEGER NULL,
        dest_nmstct			VARCHAR(30) NULL,
	lgh_pay				MONEY NULL,
	lgh_accessorial			MONEY NULL,
	lgh_fsc				MONEY NULL,
	lgh_billed			MONEY NULL,
	lgh_paid			MONEY NULL,
	margin				DECIMAL(7,2),
        lgh_startdate			DATETIME,
	lgh_enddate			DATETIME,
        margin_amount			MONEY NULL,
        lgh_number			INTEGER NULL
	)

--PTS52011 MBR 04/20/10 Added zip to table
CREATE TABLE #temporigin (
        airdistance     FLOAT NULL, 
        cty_code        INTEGER NULL, 
        cty_nmstct      VARCHAR(30) NULL,
	cty_zip		VARCHAR(10) NULL
)

--PTS52011 MBR 04/20/10 Added zip to table
CREATE TABLE #tempdest (
        airdistance     FLOAT NULL, 
        cty_code        INTEGER NULL, 
        cty_nmstct      VARCHAR(30) NULL,
	cty_zip 	VARCHAR(10) NULL
) 

DECLARE @temp_id 		INTEGER,
	@temp_value 		VARCHAR (20),
	@count 			INTEGER,
	@current_car 		VARCHAR(8),
	@ratematch 		DECIMAL(9,4),
	@min_tar_number 	INTEGER,
	@dhmiles_dest 		INTEGER, 	
	@orig_lat 		DECIMAL(12,4),
	@orig_long 		DECIMAL(12,4),
	@dest_lat 		DECIMAL(12,4),
	@dest_long 		DECIMAL(12,4),
	@ls_ocity 		VARCHAR(50),
	@ls_ostate 		VARCHAR(20),
	@ete_commapos 		INTEGER,
	@ll_ocity 		INTEGER,
	@ls_dcity 		VARCHAR(50),
	@ls_dstate 		VARCHAR(20),	
	@ll_dcity 		INTEGER,
	@use_ocityonly 		CHAR(1),
	@state_piece 		CHAR(2),
	@use_origzones 		VARCHAR(100),
	@origzonestouse 	VARCHAR(100),
	@use_origstates 	CHAR(1),
	@origstatestouse	VARCHAR(100),
	@use_dcityonly 		char(1),
	@use_destzones 		VARCHAR(100),
	@destzonestouse 	VARCHAR(100),
	@use_deststates 	CHAR(1),
	@deststatestouse 	VARCHAR(100),
	@daysback 		INTEGER,
	@currentcar 		VARCHAR(8),
	@hoursslack 		INTEGER,	
	@totalordersfiltered 	INTEGER,
	@ontimeordersfiltered 	INTEGER,
	@crh_percentfiltered 	INTEGER, 
	@workingOrigin 		VARCHAR(58),
	@workingDestination 	VARCHAR(58),
        @parse			VARCHAR(50),
        @pos			INTEGER,
	@where 			VARCHAR(1000),
	@sql			NVARCHAR(1000),
	@ll_ostates		INTEGER,
	@ll_dstates 		INTEGER,
	@slashpos		SMALLINT,
        @ls_ocounty		VARCHAR(3),
        @ls_dcounty		VARCHAR(3),
	@ll_oradius_count	INTEGER,
	@ll_dradius_count	INTEGER
	
-- parse origin and destination args

SET @ll_ocity = 0
SET @ll_ostates = 0
SET @ll_dcity = 0
SET @ll_dstates = 0

SET @origin = UPPER(LTRIM(RTRIM(@origin)))

IF LEN(@origin) > 0
BEGIN
   SET @ete_commapos = CHARINDEX(',', @origin)
   SET @slashpos = CHARINDEX('/', @origin)
   IF @ete_commapos > 0
   BEGIN
      IF @slashpos > 0
      BEGIN
         SET @ls_ocity = RTRIM(LTRIM(LEFT(@origin, (@ete_commapos - 1))))
         SET @ls_ostate = RTRIM(LTRIM(SUBSTRING(@origin, (@ete_commapos + 1), (@slashpos - (@ete_commapos + 1)))))
         SET @ls_ocounty = RTRIM(LTRIM(RIGHT(@origin, (LEN(@origin) - @slashpos))))
         SET @ls_ocounty = SUBSTRING(@ls_ocounty, 1, 3)
         SELECT @ll_ocity = cty_code,
                @orig_lat = ISNULL(cty_latitude, 0),
                @orig_long = ISNULL(cty_longitude, 0)
           FROM city
          WHERE cty_name = @ls_ocity AND
                cty_state = @ls_ostate AND
                cty_county = @ls_ocounty
         IF @ll_ocity IS NULL
            SET @ll_ocity = 0
      END
      ELSE
      BEGIN
         SET @ls_ocity = RTRIM(LTRIM(LEFT(@origin, (@ete_commapos - 1))))
         SET @ls_ostate = RTRIM(LTRIM(RIGHT(@origin, (LEN(@origin) - @ete_commapos))))
         SELECT @ll_ocity = cty_code,
		@orig_lat = ISNULL(cty_latitude, 0),
                @orig_long = ISNULL(cty_longitude, 0)
           FROM city
          WHERE cty_name = @ls_ocity AND
                cty_state = @ls_ostate
         IF @ll_ocity IS NULL
            SET @ll_ocity = 0
      END
   END
   ELSE
   BEGIN
      WHILE LEN(@origin) >= 2
      BEGIN
         SET @state_piece = LEFT(@origin, 2)
         IF LEFT(@state_piece, 1) = 'Z'
            INSERT INTO #origin_states
               SELECT tcz_state
                 FROM transcore_zones
                WHERE tcz_zone = @state_piece
         ELSE
            INSERT INTO #origin_states (origin_state)
                                VALUES (@state_piece)

         SET @origin = RIGHT(@origin, (LEN(@origin) - 2))
      END
      SELECT @ll_ostates = COUNT(DISTINCT origin_state)
        FROM #origin_states
   END
END

--If origin is a city and radius is set and lat/longs found in city file,
--find all cities within radius
IF @ll_ocity > 0 AND @oradius > 0
BEGIN
   IF @orig_lat > 0 AND @orig_long > 0
   BEGIN
      INSERT INTO #temporigin
         EXEC tmw_citieswithinradius_sp @orig_lat, @orig_long, @oradius
      SELECT @ll_oradius_count = COUNT(*)
        FROM #temporigin
      IF @ll_oradius_count IS NULL
         SET @ll_oradius_count = 0
      IF @ll_oradius_count = 0
         SET @oradius = 0
   END
   ELSE
   BEGIN
      SET @oradius = 0
   END
END
--If origin is not a city and the radius is set, zero the radius
if @ll_ocity = 0
   SET @oradius = 0

SET @destination = UPPER(LTRIM(RTRIM(@destination)))

IF LEN(@destination) > 0
BEGIN
   SET @ete_commapos = CHARINDEX(',', @destination)
   SET @slashpos = CHARINDEX('/', @destination)
   IF @ete_commapos > 0
   BEGIN
      IF @slashpos > 0
      BEGIN
         SET @ls_dcity = RTRIM(LTRIM(LEFT(@destination, (@ete_commapos - 1))))
         SET @ls_dstate = RTRIM(LTRIM(SUBSTRING(@destination, (@ete_commapos + 1), (@slashpos - (@ete_commapos + 1)))))
         SET @ls_dcounty = RTRIM(LTRIM(RIGHT(@destination, (LEN(@destination) - @slashpos))))
         SET @ls_dcounty = SUBSTRING(@ls_dcounty, 1, 3)
         SELECT @ll_dcity = cty_code,
                @dest_lat = ISNULL(cty_latitude, 0),
                @dest_long = ISNULL(cty_longitude, 0)
           FROM city
          WHERE cty_name = @ls_dcity AND
                cty_state = @ls_dstate AND
                cty_county = @ls_dcounty
         IF @ll_dcity IS NULL
            SET @ll_dcity = 0
      END
      ELSE
      BEGIN
         SET @ls_dcity = RTRIM(LTRIM(LEFT(@destination, (@ete_commapos - 1))))
         SET @ls_dstate = RTRIM(LTRIM(RIGHT(@destination, (LEN(@destination) - @ete_commapos))))
         SELECT @ll_dcity = cty_code,
                @dest_lat = ISNULL(cty_latitude, 0),
                @dest_long = ISNULL(cty_longitude, 0)
           FROM city
          WHERE cty_name = @ls_dcity AND
                cty_state = @ls_dstate
         IF @ll_dcity IS NULL
            SET @ll_dcity = 0
      END
   END
   ELSE
   BEGIN
      WHILE LEN(@destination) >= 2
      BEGIN
         SET @state_piece = LEFT(@destination, 2)
         IF LEFT(@state_piece, 1) = 'Z'
            INSERT INTO #destination_states
               SELECT tcz_state
                 FROM transcore_zones
                WHERE tcz_zone = @state_piece
         ELSE
            INSERT INTO #destination_states (destination_state)
                                VALUES (@state_piece)

         SET @destination = RIGHT(@destination, (LEN(@destination) - 2))
      END
      SELECT @ll_dstates = COUNT(DISTINCT destination_state)
        FROM #destination_states
   END
END

--If destination is a city and radius is set and lat/longs found in city file,
--find all cities within radius
IF @ll_dcity > 0 AND @dradius > 0
BEGIN
   IF @dest_lat > 0 AND @dest_long > 0
   BEGIN
      INSERT INTO #tempdest
         EXEC tmw_citieswithinradius_sp @dest_lat, @dest_long, @dradius
      SELECT @ll_dradius_count = COUNT(*)
        FROM #tempdest
      IF @ll_dradius_count IS NULL
         SET @ll_dradius_count = 0
      IF @ll_dradius_count = 0
         SET @dradius = 0
   END
   ELSE
   BEGIN
      SET @dradius = 0
   END
END
--If destination is not a city, zero the dradius
IF @ll_dcity = 0
   SET @dradius = 0

--Retrieve Carriers based on what is in the history table for the entered origin
--and destination criteria
INSERT INTO #temp1 (crh_carrier, ord_hdrnumber, ord_origincity,
                    origin_nmstct, ord_destcity, dest_nmstct, lgh_pay, 
                    lgh_accessorial, lgh_fsc, lgh_billed, lgh_paid, margin,
                    lgh_startdate, lgh_enddate, margin_amount, lgh_number)
   SELECT chd.crh_carrier, 
          chd.ord_hdrnumber,
          chd.ord_origincity,
          c1.cty_nmstct,
          chd.ord_destcity,
          c2.cty_nmstct,
          chd.lgh_pay,
          chd.lgh_accessorial,
          chd.lgh_fsc,
          chd.lgh_billed,
          chd.lgh_paid,
          chd.margin,
          legheader.lgh_startdate,
          chd.lgh_enddate,
          ISNULL((chd.lgh_billed - chd.lgh_paid), 0) margin_amount,
          chd.lgh_number
     FROM carrierhistorydetail chd WITH (NOLOCK) LEFT OUTER JOIN city c1 WITH (NOLOCK) ON ord_origincity = c1.cty_code
                                                 LEFT OUTER JOIN city c2 WITH (NOLOCK) ON ord_destcity = c2.cty_code
                                                 JOIN legheader ON chd.lgh_number = legheader.lgh_number
    WHERE crh_carrier = @car_id AND
        ((@oradius = 0 AND
         (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND
         (@ll_ostates = 0 OR chd.ord_originstate IN (SELECT DISTINCT origin_state
                                                       FROM #origin_states))) OR
         (@oradius > 0 AND
          chd.ord_origincity IN (select cty_code from #temporigin))) AND
        ((@dradius = 0 AND
         (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND
         (@ll_dstates = 0 OR chd.ord_deststate IN (SELECT DISTINCT destination_state
                                                     FROM #destination_states))) OR
         (@dradius > 0 AND
          chd.ord_destcity IN (select cty_code from #tempdest)))



SELECT *
  FROM #temp1	
 	

GO
GRANT EXECUTE ON  [dbo].[carrier_paymenthistory_sp] TO [public]
GO
