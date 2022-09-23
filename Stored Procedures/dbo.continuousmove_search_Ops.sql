SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[continuousmove_search_Ops]
	@carrierFilterViewId		VARCHAR(6),
	@servicerating				VARCHAR(6),
	@carid						VARCHAR(8),
	@carname					VARCHAR(64),
	@origin						INTEGER,
 	@oradius					INTEGER, 	
    @expdate					INTEGER,
    @lgh_number					INTEGER,
	@equipment_type				VARCHAR(25),
	@equipment_type_value		VARCHAR(6),
	@equipment_type_group		VARCHAR(25),
	@MaxHoursVariance	INTEGER
as

SET NOCOUNT ON

CREATE TABLE #temp_filteredcarriers (
	fcr_carrier 		VARCHAR(8), 
	fcr_car_city 		INTEGER,
	fcr_omiles_dom 		DECIMAL(12,6) NULL,
	fcr_dmiles_dom 		DECIMAL(12,6) NULL,
	fcr_dom_lat 		DECIMAL(12,6) NULL,
	fcr_dom_long 		DECIMAL(12,6) NULL,		
	fcr_domicile_state 	CHAR(6),
	fcr_origdomicile 	CHAR(1),
	fcr_destdomicile 	CHAR(1),
 	keepfromfilter 		CHAR(1)
	)


create table #temp1 (
	temp1_id 			INTEGER identity,
	trk_number 			VARCHAR(50) NULL,
	trk_carrier 			VARCHAR(8) NULL,
	car_name			VARCHAR(64) NULL,
	cty_code			INTEGER NULL,
    cty_state			VARCHAR(6) NULL,
	earliest		DATETIME NULL,
	latest			DATETIME NULL,
	[hours]			INTEGER NULL,
    distance_to_origin		INT	NULL,
	qualification_list_drv		varchar(255)	null,
	qualification_list_trc		varchar(255)	null,
	qualification_list_trl		varchar(255)	null,
	load_requirements	CHAR(1)
    )

--PTS52011 MBR 04/20/10 added zip to table
CREATE TABLE #tempinbound (
        airdistance     FLOAT NULL, 
        cty_code        INTEGER NULL, 
        cty_nmstct      VARCHAR(30) NULL,
	cty_zip		VARCHAR(10) NULL
)

--PTS62447 MBR 05/02/12
CREATE TABLE #loadrequirements (
	lrq_equip_type	VARCHAR(6) NULL,
	lrq_type	VARCHAR(6) NULL,
	lrq_quantity	INTEGER
)
	
DECLARE 
	@orig_lat 		DECIMAL(12,4),
	@orig_long 		DECIMAL(12,4),
	@ls_ocity 		VARCHAR(50),
	@ls_ostate 		VARCHAR(20),
	@where 			VARCHAR(4000),
	@sql			NVARCHAR(4000),
        @ls_ocounty		VARCHAR(3),
	@ll_oradius_count	INTEGER,
	@ls_ozip		VARCHAR(10),
	@mov_number		INTEGER,
	@lrq_count		INTEGER,
	@lrq_equip_type		VARCHAR(6),
	@lrq_type		VARCHAR(6),
	@lrq_quantity		INTEGER,
	@ord_hdrnumber		INTEGER

DECLARE 	@cartype1				VARCHAR(6),
			@cartype2				VARCHAR(6),
			@cartype3				VARCHAR(6),
			@cartype4				VARCHAR(6),
			@liabilitylimit				MONEY,
			@cargolimit				MONEY,
	@rateonly				CHAR(1),
	@insurance				CHAR(1),
	@w9					CHAR(1),
	@contract				CHAR(1),
	@history				CHAR(1),
	@branch					VARCHAR(12),
	@ratesonly				CHAR(1),
	@stp_departure_dt			DATETIME

IF @carrierFilterViewId != 'UNK'
BEGIN
SELECT 
	@cartype1 = caf_car_type1, 
	@cartype2=caf_car_type2, 
	@cartype3=caf_car_type3, 
	@cartype4=caf_car_type4, 
	@liabilitylimit=caf_liability_limit, 
	@cargolimit=caf_cargo_limit, 
	@servicerating=caf_service_rating,
	@rateonly = caf_rate,
	@insurance = caf_ins_cert,
	@w9 = caf_w9,
	@contract = caf_contract,
	@history = caf_history_only,
	@branch = caf_branch,
	@ratesonly = caf_RateOnFile_only 
FROM carrierfilter WHERE caf_viewid = @carrierFilterViewId
 
 END
--PTS 51570 JJF 20100510
declare @rowsecurity char(1)
--END PTS 51570 JJF 20100510

--PTS 51570 JJF 20100510
SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'
	
IF @ratesonly IS NULL OR @ratesonly = ''
   SET @ratesonly = 'N'

IF @carid = 'UNKNOWN'
   SET @carid = '' 

SET @stp_departure_dt = GETDATE()


-- Get first list of carriers for #temp_filteredcarriers.
INSERT #temp_filteredcarriers (fcr_carrier, fcr_car_city, fcr_dom_lat, fcr_dom_long,
                               fcr_domicile_state, fcr_origdomicile, fcr_destdomicile,
                               keepfromfilter)
   SELECT car_id, c.cty_code, cty_latitude, cty_longitude, cty_state, 'N', 'N','Y'
     FROM carrier c WITH (NOLOCK)JOIN city WITH (NOLOCK) ON c.cty_code = city.cty_code AND
                                                            city.cty_code > 0
    WHERE (ISNULL(@cartype1, '') = '' OR @cartype1 = 'UNK' OR  c.car_type1 = @cartype1) AND
          (ISNULL(@cartype2, '') = '' OR @cartype2 = 'UNK' OR  c.car_type2 = @cartype2) AND
          (ISNULL(@cartype3, '') = '' OR @cartype3 = 'UNK' OR  c.car_type3 = @cartype3) AND
          (ISNULL(@cartype4, '') = '' OR @cartype4 = 'UNK' OR  c.car_type4 = @cartype4) AND
          (ISNULL(@liabilitylimit, 0) = 0 OR @liabilitylimit <= c.car_ins_liabilitylimits) AND
          (ISNULL(@cargolimit, 0) = 0 OR @cargolimit <= c.car_ins_cargolimits) AND
          (ISNULL(@servicerating, '') = '' OR @servicerating = 'UNK' OR c.car_rating = @servicerating) AND
          (ISNULL(@carname, '') = '' OR c.car_name like @carname + '%') AND
          ((ISNULL(@carid, '') = '' OR (c.car_id like @carid + '%'))) AND
          (c.car_status <> 'OUT') AND  
          (ISNULL(@insurance, '') = '' OR car_ins_certificate = @insurance or @insurance = 'N') AND
          (ISNULL(@w9, '') = '' OR car_ins_w9 = @w9 or @w9 = 'N') AND
          (ISNULL(@contract, '') = '' OR car_ins_contract = @contract OR @contract = 'N') AND
          (ISNULL(@branch, '') = '' OR @branch = 'UNK' OR @branch = 'UNKNOWN' OR c.car_branch = @branch) AND
          --PTS 51570 JJF 20100510
          EXISTS	(	SELECT	*  
						FROM	RowRestrictValidAssignments_carrier_fn() rsva 
						WHERE	c.rowsec_rsrv_id = rsva.rowsec_rsrv_id
								OR rsva.rowsec_rsrv_id = 0
					)	

-- Delete from carrier list if equipment type qualifications are not met
IF LEN(@equipment_type_value) > 0 
BEGIN
   SET @where = NULL
   
   IF @equipment_type_value = 'ITEM'
   BEGIN 
      SET @where = 'EXISTS(SELECT caq_id FROM carrierqualifications WHERE caq_id = car_id AND ' +
                   'ISNULL(caq_expire_flag, ''N'') <> ''Y'' AND caq_expire_date >= GETDATE() AND ' +
                   '((caq_type = ''' + @equipment_type + ''') OR (caq_type IN (SELECT abbr FROM ' +
                   'labelfile WHERE labeldefinition = ''CarQual'' AND label_extrastring1 = ''' + @equipment_type_group + ''' AND ' +
                   'label_extrastring2 = ''ANY''))))'
      END

   IF @equipment_type_value = 'GROUP'
   BEGIN
      SET @where = 'EXISTS(SELECT caq_id FROM carrierqualifications WHERE caq_id = car_id AND ' +
                   'ISNULL(caq_expire_flag, ''N'') <> ''Y'' AND caq_expire_date >= GETDATE() AND ' +
                   'caq_type IN (SELECT abbr FROM labelfile WHERE labeldefinition = ''ExtEquipmentType'' AND ' + 
                   'label_extrastring1 = ''' + @equipment_type + '''))'
   END

   SET @sql = 'DELETE #temp_filteredcarriers WHERE fcr_carrier NOT IN (' + 
              'SELECT car_id FROM carrier WITH (NOLOCK) WHERE ' + @where + ')'
   
   EXECUTE sp_executesql @sql
END

SELECT 
	@ls_ocity = cty_name,
	@ls_ostate = cty_state,
	@ls_ocounty = cty_county,
    @orig_lat = ISNULL(cty_latitude, 0),
    @orig_long = ISNULL(cty_longitude, 0),
    @ls_ozip = cty_zip
FROM city with (nolock)
WHERE cty_code = @origin

IF @origin > 0 AND @oradius > 0
BEGIN
   IF @orig_lat > 0 AND @orig_long > 0
   BEGIN
      INSERT INTO #tempinbound
         EXEC tmw_citieswithinradius_sp @orig_lat, @orig_long, @oradius
      SELECT @ll_oradius_count = COUNT(*)
        FROM #tempinbound
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


-- FIND ALL INBOUND CARRIERS
	INSERT INTO #temp1 (
	trk_number,
	trk_carrier,
	car_name,
	cty_code,
    cty_state,
	earliest,
	latest,
	[hours]
	) 
	SELECT DISTINCT
		convert(varchar(50), lgh_carrier_truck),
		convert(varchar(8), lgh_carrier),
		convert(varchar(64), car_name),
		lgh_endcity,
		lgh_endstate,
		lgh_schdtearliest,
		lgh_schdtlatest,
		ABS(DATEDIFF(hh, lgh_enddate, (SELECT lgh_startdate FROM legheader WHERE lgh_number=@lgh_number)))
    FROM
		legheader_active 
	left outer join
		legheader_brokered 
	ON 
		legheader_active.lgh_number = legheader_brokered.lgh_number
	join 
		#tempinbound 
	ON 
		legheader_active.lgh_endcity = #tempinbound.cty_code 
	join 
		carrier 
	ON 
		(legheader_active.lgh_carrier = carrier.car_id
		and carrier.car_status = 'ACT' 
        AND (CHARINDEX(',' + ISNULL(carrier.car_branch, 'UNKNOWN') + ',', ',' + ISNULL(@branch, '') + ',') > 0 OR ISNULL(@branch, '') = ''))
	JOIN
		#temp_filteredcarriers
	ON
		legheader_active.lgh_carrier = #temp_filteredcarriers.fcr_carrier
    WHERE 	(	(	@equipment_type = 'ALL') OR
				(	legheader_active.ord_trl_type1 IS NULL) OR
				(	(	@equipment_type = 'GROUP') AND
					(	legheader_active.ord_trl_type1 IN	(	SELECT	abbr
																FROM	labelfile
																WHERE	(labeldefinition = 'ExtEquipmentType') AND 
																		(label_extrastring1 = @equipment_type_group)
															)
					)
				) OR
				(	@equipment_type = 'ITEM'
					AND CHARINDEX(',' + legheader_active.ord_trl_type1 + ',', ',' + @equipment_type_value + ',') > 0
				)
			)
			AND	legheader_active.lgh_carrier <> 'UNKNOWN' 
			AND legheader_active.lgh_outstatus in ('DSP','STD','CMP')
			AND @MaxHoursVariance > ABS(DATEDIFF(hh, lgh_enddate, (SELECT lgh_startdate FROM legheader WHERE lgh_number=@lgh_number))) 

UPDATE	#temp1
SET distance_to_origin = dbo.tmw_airdistance_fn(@orig_lat, @orig_long, ISNULL(cty_latitude, 0), ISNULL(cty_longitude, 0)) 
FROM #temp1 result INNER JOIN city ON city.cty_code = result.cty_code
--END PTS 49332 JJF 20091008

DECLARE @AssetsToInclude varchar(60)
DECLARE @DisplayQualifications varchar(1)
DECLARE @Delimiter varchar(1)
DECLARE @IncludeAssetPrefix int
DECLARE @IncludeLabelName int

SELECT	@DisplayQualifications = ISNULL(gi_string1, 'N'),
		@AssetsToInclude = ',' + ISNULL(gi_string2, '') + ',',
		@Delimiter = ISNULL(gi_string3, '*'),
		@IncludeAssetPrefix = ISNULL(gi_integer1, 0),
		@IncludeLabelName = ISNULL(gi_integer2, 0)
FROM	generalinfo
WHERE gi_name = 'QualListCarrierPlan'

IF @DisplayQualifications = 'Y' BEGIN
	IF @AssetsToInclude = ',,' BEGIN
		SET @AssetsToInclude = ',CAR,'
	END

	UPDATE #temp1
	SET qualification_list_drv = dbo.QualificationsToCSV_fn	(	NULL, 
																NULL, 
																NULL, 
																NULL, 
																NULL, 
																CASE CHARINDEX(',CAR,', @AssetsToInclude) WHEN 0 THEN 'UNKNOWN' ELSE trk_carrier END, 
																CASE CHARINDEX(',CAR,', @AssetsToInclude) WHEN 0 THEN 'UNKNOWN' ELSE trk_carrier END, 
																NULL, 
																NULL, 
																NULL, 
																NULL,
																@IncludeAssetPrefix,
																@IncludeLabelName,
																@Delimiter
															),
		qualification_list_trc = dbo.QualificationsToCSV_fn	(	NULL, 
																NULL, 
																NULL, 
																NULL, 
																NULL, 
																NULL, 
																NULL, 
																CASE CHARINDEX(',CAR,', @AssetsToInclude) WHEN 0 THEN 'UNKNOWN' ELSE trk_carrier END,
																NULL, 
																NULL, 
																NULL,
																@IncludeAssetPrefix,
																@IncludeLabelName,
																@Delimiter
															),
	
		qualification_list_trl = dbo.QualificationsToCSV_fn	(	NULL, 
																NULL, 
																NULL, 
																NULL, 
																NULL, 
																NULL, 
																NULL, 
																NULL, 
																CASE CHARINDEX(',CAR,', @AssetsToInclude) WHEN 0 THEN 'UNKNOWN' ELSE trk_carrier END,
																NULL, 
																NULL,
																@IncludeAssetPrefix,
																@IncludeLabelName,
																@Delimiter
															)
															

															
															
	FROM #temp1 
END 

--PTS62447 MBR 05/02/12 See which carriers meet the load requirements for the passed in lgh_number
IF @lgh_number > 0
BEGIN

   SELECT @mov_number = mov_number, @ord_hdrnumber = ord_hdrnumber
     FROM legheader
    WHERE lgh_number = @lgh_number

   INSERT INTO #loadrequirements
      SELECT lrq_equip_type, lrq_type, lrq_quantity
        FROM loadrequirement
       WHERE mov_number = @mov_number AND 
             lrq_not = 'Y'

   SELECT @lrq_count = COUNT(*)
     FROM #loadrequirements

   IF @lrq_count > 0
   BEGIN
      DECLARE lrq_cursor CURSOR FOR
         SELECT lrq_equip_type, lrq_type, lrq_quantity
           FROM #loadrequirements

      OPEN lrq_cursor

      FETCH NEXT FROM lrq_cursor
       INTO @lrq_equip_type, @lrq_type, @lrq_quantity

      WHILE @@FETCH_STATUS = 0
      BEGIN

         IF @lrq_equip_type = 'CAR'
         BEGIN
            IF @where IS NULL
               SET @where = 'EXISTS(SELECT caq_id FROM carrierqualifications WITH (NOLOCK) WHERE caq_id = car_id AND ' +
                            'ISNULL(caq_expire_flag, ''N'') <> ''Y'' AND ' +
                            'caq_expire_date >= GETDATE() AND caq_type = ''' + @lrq_type + ''' AND ' +
                            'caq_quantity >= ' + CAST(@lrq_quantity AS VARCHAR(5)) + ')'
            ELSE
               SET @where = @where + ' AND ' + 'EXISTS(SELECT caq_id FROM carrierqualifications WITH (NOLOCK) WHERE caq_id = car_id AND ' +
                            'ISNULL(caq_expire_flag, ''N'') <> ''Y'' AND ' +
                            'caq_expire_date >= GETDATE() AND caq_type = ''' + @lrq_type + ''' AND ' +
                            'caq_quantity >= ' + CAST(@lrq_quantity AS VARCHAR(5)) + ')'
         END
	
         IF @lrq_equip_type = 'DRV'
         BEGIN
            IF @where IS NULL
               SET @where = 'EXISTS(SELECT drq_id FROM driverqualifications WITH (NOLOCK) where drq_id = car_id AND ' +
                            'drq_source = ''CAR'' AND ISNULL(drq_expire_flag, ''N'') <> ''Y'' AND ' + 
                            'drq_expire_date >= GETDATE() AND drq_type = ''' + @lrq_type + ''' AND ' +
                            'drq_quantity >= ' + CAST(@lrq_quantity AS VARCHAR(5)) + ')'
            ELSE
               SET @where = @where + ' AND ' + 'EXISTS(SELECT drq_id FROM driverqualifications WITH (NOLOCK) where drq_id = car_id AND ' +
                            'drq_source = ''CAR'' AND ISNULL(drq_expire_flag, ''N'') <> ''Y'' AND ' + 
                            'drq_expire_date >= GETDATE() AND drq_type = ''' + @lrq_type + ''' AND ' +
                            'drq_quantity >= ' + CAST(@lrq_quantity AS VARCHAR(5)) + ')'
         END

         IF @lrq_equip_type = 'TRL'
         BEGIN
            IF @where IS NULL
               SET @where = 'EXISTS(SELECT ta_trailer FROM trlaccessories WITH (NOLOCK) WHERE ta_trailer = car_id AND ' +
                            'ta_source = ''CAR'' AND ISNULL(ta_expire_flag, ''N'') <> ''Y'' AND ' +
                            'ta_expire_date >= GETDATE() AND ta_type = ''' + @lrq_type + ''' AND ' +
                            'ta_quantity >= ' + CAST(@lrq_quantity AS VARCHAR(5)) + ')'
            ELSE
               SET @where = @where + ' AND ' + 'EXISTS(SELECT ta_trailer FROM trlaccessories WITH (NOLOCK) WHERE ta_trailer = car_id AND ' +
                            'ta_source = ''CAR'' AND ISNULL(ta_expire_flag, ''N'') <> ''Y'' AND ' +
                            'ta_expire_date >= GETDATE() AND ta_type = ''' + @lrq_type + ''' AND ' +
                            'ta_quantity >= ' + CAST(@lrq_quantity AS VARCHAR(5)) + ')'
         END

         IF @lrq_equip_type = 'TRC'
         BEGIN
            IF @where IS NULL
               SET @where = 'EXISTS(SELECT tca_tractor FROM tractoraccesories WITH (NOLOCK) WHERE tca_tractor = car_id AND ' +
                            'tca_source = ''CAR'' AND ISNULL(tca_expire_flag, ''N'') <> ''Y'' AND ' +
                            'tca_expire_date >= GETDATE() AND tca_type = ''' + @lrq_type + ''' AND ' +
                            'tca_quantitiy >= ' + CAST(@lrq_quantity AS VARCHAR(5)) + ')'
            ELSE
               SET @where = @where + ' AND ' + 'EXISTS(SELECT tca_tractor FROM tractoraccesories WITH (NOLOCK) WHERE tca_tractor = car_id AND ' +
                            'tca_source = ''CAR'' AND ISNULL(tca_expire_flag, ''N'') <> ''Y'' AND ' +
                            'tca_expire_date >= GETDATE() AND tca_type = ''' + @lrq_type + ''' AND ' +
                            'tca_quantitiy >= ' + CAST(@lrq_quantity AS VARCHAR(5)) + ')'
         END

         FETCH NEXT FROM lrq_cursor
          INTO @lrq_equip_type, @lrq_type, @lrq_quantity

      END

      CLOSE lrq_cursor
      DEALLOCATE lrq_cursor

      SET @sql = 'UPDATE #temp1 SET load_requirements = ''Y'' WHERE trk_carrier IN (' +
                 'SELECT car_id FROM carrier WITH (NOLOCK) WHERE ' + @where + ')'
      EXECUTE sp_executesql @sql

   END
END

--PTS 53571 KMM/JJF 20100818 - DON'T RETURN RESULTS IF THERE IS ZERO CRITERIA
ENDPROC:
  

SELECT ISNULL(trk_number,'') trk_number, 
       ISNULL(trk_carrier,'') trk_carrier,
       ISNULL(car_name,'') car_name,
       ISNULL(#temp1.cty_code, 0) cty_code,
	   ISNULL(c.cty_nmstct,'') as cty_nmstct,
       ISNULL(#temp1.cty_state, 'UNK') cty_state,
	   ISNULL(earliest, '1950-01-01') earliest,
	   ISNULL(latest, '2014-12-31') latest,
       ISNULL(distance_to_origin, 0) as distance_to_origin,
	   ISNULL(hours,0) hours,
       ISNULL(qualification_list_drv,'') qualification_list_drv,
       ISNULL(qualification_list_trc,'') qualification_list_trc,
       ISNULL(qualification_list_trl,'') qualification_list_trl,
	   ISNULL(load_requirements, 'N') load_requirements
  FROM #temp1	
  JOIN city c ON #temp1.cty_code = c.cty_code
 WHERE #temp1.trk_carrier IN (SELECT car_id 
                                FROM carrier WITH (NOLOCK) 
                               WHERE car_status <> 'OUT' OR car_id = 'UNKNOWN')
GO
GRANT EXECUTE ON  [dbo].[continuousmove_search_Ops] TO [public]
GO
