SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[tmw_getactivelegsbyradius] (@origin varchar(58), @oradius integer, @destination varchar(58), @dradius integer, @equipmentlist varchar(255), @startdate datetime=null, @enddate datetime=null)
AS
BEGIN

-- SAMPLE CALL
-- exec tmw_getactivelegsbyradius 'Rockport, IN', 500, 'Z1MIINZ4', 0 , 'VR,53V', '1753-1-1', '9999-12-31'


CREATE TABLE #origin_states (
      origin_state      VARCHAR(6)
      )

CREATE TABLE #destination_states (
      destination_state  VARCHAR(6)
      )

DECLARE     @orig_lat         DECIMAL(12,4),
            @orig_long        DECIMAL(12,4),
            @dest_lat         DECIMAL(12,4),
            @dest_long        DECIMAL(12,4),
            @ls_ocity         VARCHAR(50),
            @ls_ostate        VARCHAR(20),
            @ete_commapos           INTEGER,
            @ll_ocity         INTEGER,
            @ls_dcity         VARCHAR(50),
            @ls_dstate        VARCHAR(20),      
            @ll_dcity         INTEGER,
            @use_ocityonly          CHAR(1),
            @state_piece            CHAR(2),
            @use_origzones          VARCHAR(100),
            @origzonestouse   VARCHAR(100),
            @use_origstates   CHAR(1),
            @origstatestouse  VARCHAR(100),
            @use_dcityonly          char(1),
            @use_destzones          VARCHAR(100),
            @destzonestouse   VARCHAR(100),
            @use_deststates   CHAR(1),
            @deststatestouse VARCHAR(100),
            @workingOrigin          VARCHAR(58),
            @workingDestination     VARCHAR(58),
        @parse                VARCHAR(50),
        @pos                  INTEGER,
            @ll_ostates       INTEGER,
            @ll_dstates             INTEGER,
            @slashpos         SMALLINT,
        @ls_ocounty           VARCHAR(3),
        @ls_dcounty           VARCHAR(3),
            @ll_oradius_count INTEGER,
            @ll_dradius_count INTEGER,
                  @ll_ocitycount          INTEGER,
                  @ll_dcitycount          INTEGER

SET @ll_ocity = 0
SET @ll_ostates = 0
SET @ll_dcity = 0
SET @ll_dstates = 0

if IsNull(@equipmentlist, '') = ''
            set @equipmentlist = 'ALL'
      ELSE
            set @equipmentlist = ',' + @equipmentlist + ','



SET @origin = UPPER(LTRIM(RTRIM(@origin)))

IF LEN(@origin) > 0
BEGIN
   SET @ete_commapos = CHARINDEX(',', @origin)
   SET @slashpos = CHARINDEX('/', @origin)
   IF @slashpos = LEN(@origin)
   BEGIN
     SET @slashpos = 0
	 SET @origin = SUBSTRING(@origin, 1, LEN(@origin)-1)
   END
   IF @ete_commapos > 0
   BEGIN
      IF @slashpos > 0
      BEGIN
         SET @ls_ocity = RTRIM(LTRIM(LEFT(@origin, (@ete_commapos - 1))))
         SET @ls_ostate = RTRIM(LTRIM(SUBSTRING(@origin, (@ete_commapos + 1), (@slashpos - (@ete_commapos + 1)))))
         SET @ls_ocounty = RTRIM(LTRIM(RIGHT(@origin, (LEN(@origin) - @slashpos))))
         SET @ls_ocounty = SUBSTRING(@ls_ocounty, 1, 3)
      
              SELECT @ll_ocitycount = count(*)
           FROM city with (nolock)
          WHERE cty_name = @ls_ocity AND
                cty_state = @ls_ostate AND
                cty_county = @ls_ocounty
                  
                  IF @ll_ocitycount < 1 
                    BEGIN
                        SELECT @ll_ocity = -1
                    END
                  ELSE
                    BEGIN
                        SELECT @ll_ocity = isnull(cty_code, -1),
                            @orig_lat = ISNULL(cty_latitude, 0),
                                    @orig_long = ISNULL(cty_longitude, 0)
                    FROM      city with (nolock)
                        WHERE cty_name = @ls_ocity AND
                            cty_state = @ls_ostate AND
                                    cty_county = @ls_ocounty
                    END

         IF @ll_ocity IS NULL
            SET @ll_ocity = -1
      END
      ELSE
      BEGIN
        SET @ls_ocity = RTRIM(LTRIM(LEFT(@origin, (@ete_commapos - 1))))
        SET @ls_ostate = RTRIM(LTRIM(RIGHT(@origin, (LEN(@origin) - @ete_commapos))))

                  SELECT      @ll_ocitycount = count(*)
                  FROM  city with (nolock)
                  WHERE cty_name = @ls_ocity AND
                              cty_state = @ls_ostate 

                  IF @ll_ocitycount < 1 
                    BEGIN
                        SELECT @ll_ocity = -1
                    END
                  ELSE
                    BEGIN
                        SELECT @ll_ocity = cty_code,
                                    @orig_lat = ISNULL(cty_latitude, 0),
                                    @orig_long = ISNULL(cty_longitude, 0)
                        FROM  city with (Nolock)
                        WHERE cty_name = @ls_ocity AND
                            cty_state = @ls_ostate
                    END

         IF @ll_ocity IS NULL
            SET @ll_ocity = -1
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
                 FROM transcore_zones with (nolock)
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

--If origin is not a city and the radius is set, zero the radius
if @ll_ocity <= 0 
   SET @oradius = 0

SET @destination = UPPER(LTRIM(RTRIM(@destination)))

IF LEN(@destination) > 0
BEGIN
   SET @ete_commapos = CHARINDEX(',', @destination)
   SET @slashpos = CHARINDEX('/', @destination)
   IF @slashpos = LEN(@destination)
   BEGIN
     SET @slashpos = 0
	 SET @destination = SUBSTRING(@destination, 1, LEN(@destination)-1)
   END
   IF @ete_commapos > 0
   BEGIN
      IF @slashpos > 0
      BEGIN
         SET @ls_dcity = RTRIM(LTRIM(LEFT(@destination, (@ete_commapos - 1))))
         SET @ls_dstate = RTRIM(LTRIM(SUBSTRING(@destination, (@ete_commapos + 1), (@slashpos - (@ete_commapos + 1)))))
         SET @ls_dcounty = RTRIM(LTRIM(RIGHT(@destination, (LEN(@destination) - @slashpos))))
         SET @ls_dcounty = SUBSTRING(@ls_dcounty, 1, 3)

              SELECT @ll_dcitycount = count(*)
           FROM city with (nolock)
          WHERE cty_name = @ls_dcity AND
                cty_state = @ls_dstate AND
                cty_county = @ls_dcounty
                  
                  IF @ll_dcitycount < 1 
                    BEGIN
                        SELECT @ll_dcity = -1
                    END
                  ELSE
                    BEGIN
                        SELECT @ll_dcity = isnull(cty_code, -1),
                            @dest_lat = ISNULL(cty_latitude, 0),
                                    @dest_long = ISNULL(cty_longitude, 0)
                    FROM      city with (nolock)
                        WHERE cty_name = @ls_dcity AND
                            cty_state = @ls_dstate AND
                                    cty_county = @ls_dcounty
                    END

         IF @ll_dcity IS NULL
            SET @ll_dcity = 0
      END
      ELSE
      BEGIN
         SET @ls_dcity = RTRIM(LTRIM(LEFT(@destination, (@ete_commapos - 1))))
         SET @ls_dstate = RTRIM(LTRIM(RIGHT(@destination, (LEN(@destination) - @ete_commapos))))


                  SELECT      @ll_dcitycount = count(*)
                  FROM  city with (nolock)
                  WHERE cty_name = @ls_dcity AND
                              cty_state = @ls_dstate 

                  IF @ll_dcitycount < 1 
                    BEGIN
                        SELECT @ll_dcity = -1
                    END
                  ELSE
                    BEGIN
                        SELECT @ll_dcity = cty_code,
                                    @dest_lat = ISNULL(cty_latitude, 0),
                                    @dest_long = ISNULL(cty_longitude, 0)
                        FROM  city with (Nolock)
                        WHERE cty_name = @ls_dcity AND
                            cty_state = @ls_dstate
                    END

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
                  BEGIN
                     INSERT INTO #destination_states
               SELECT tcz_state
                 FROM transcore_zones with (nolock)
                WHERE tcz_zone = @state_piece
                  END
         ELSE
            INSERT INTO #destination_states (destination_state)
                                VALUES (@state_piece)

         SET @destination = RIGHT(@destination, (LEN(@destination) - 2))
      END
      SELECT @ll_dstates = COUNT(DISTINCT destination_state)
        FROM #destination_states
   END
END



--If destination is not a city, zero the dradius
IF @ll_dcity = 0
   SET @dradius = 0

SELECT       TOP 1000 la.lgh_number --, 
--                            b.brn_primary_contact,
--                            b.brn_phone,
--                  co.cty_nmstct, 
--                  la.lgh_startstate, 
--                  cd.cty_nmstct, 
--                  la.lgh_endstate,
--                            la.trl_type1_name, 
--                  dbo.tmw_airdistance_fn(@orig_lat, @orig_long, co.cty_latitude, co.cty_longitude) AS 'Origin Distance',
--                  dbo.tmw_airdistance_fn(@dest_lat, @dest_long, cd.cty_latitude, cd.cty_longitude) AS 'Destination Distance'
FROM        legheader_active la with (nolock)
                  inner join city co with (nolock) on co.cty_code = la.lgh_startcity
                  inner join city cd with (nolock) on cd.cty_code = la.lgh_endcity
                              left outer join branch b with (nolock) on b.brn_id = la.lgh_booked_revtype1
WHERE             ((@oradius = 0 AND
                        (@ll_ocity = 0 OR 
                                          la.lgh_startcity = @ll_ocity) AND
                    (@ll_ostates = 0 OR la.lgh_startstate IN (SELECT DISTINCT origin_state
                                                          FROM #origin_states))) OR
                              (@oradius > 0 AND
                              dbo.tmw_airdistance_fn(@orig_lat, @orig_long, co.cty_latitude, co.cty_longitude) <= @oradius)) AND
                  ((@dradius = 0 AND
                   (@ll_dcity = 0 OR la.lgh_endcity = @ll_dcity) AND
                   (@ll_dstates = 0 OR la.lgh_endstate IN (SELECT DISTINCT destination_state
                                                                                FROM #destination_states))) OR
                   (@dradius > 0 AND
                    dbo.tmw_airdistance_fn(@dest_lat, @dest_long, cd.cty_latitude, cd.cty_longitude) <= @dradius)) AND
                  (la.lgh_outstatus = 'AVL') AND
                              (@equipmentlist = 'ALL' OR charindex(la.ord_trl_type1, @equipmentlist, 1) > 0)
							  AND ((ISNULL(@startdate,0)=0) or (lgh_startdate > @startdate))
							 AND ((ISNULL(@enddate,0)=0) or (lgh_enddate < @enddate))
END
GO
GRANT EXECUTE ON  [dbo].[tmw_getactivelegsbyradius] TO [public]
GO
