SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[carrier_search_sp]
	@cartype1				VARCHAR(6),
	@cartype2				VARCHAR(6),
	@cartype3				VARCHAR(6),
	@cartype4				VARCHAR(6),
	@liabilitylimit			MONEY,
	@cargolimit				MONEY,
	@servicerating			VARCHAR(6),
	@carid					VARCHAR(8),
	@carname				VARCHAR(64),
	@rateonly				CHAR(1),
	@origin					VARCHAR(58),
	@destination			VARCHAR(58),
	@insurance				CHAR(1),
	@w9						CHAR(1),
	@contract				CHAR(1),
	@history				CHAR(1),	
	@domicile				INTEGER,
	@contact				VARCHAR(30),
	@trcaccess				VARCHAR(1000),
	@trlaccess				VARCHAR(1000),
	@drvqual				VARCHAR(1000),
	@carqual				VARCHAR(1000),
	@stp_departure_dt		DATETIME,
 	@oradius				INTEGER, 	
	@dradius				INTEGER,
	@returntariffs			CHAR(1),
	@branch					VARCHAR(12),
	@ratesonly				CHAR(1),
    @expdate				INTEGER,
    @lgh_number				INTEGER,
	@equipment_type			VARCHAR(25),
	@equipment_type_value	VARCHAR(6),
	@equipment_type_group	VARCHAR(25),
	@stp_start_dt			DATETIME
	
as
/*
ARGS:
@rateonly - used in ACS filter, "Show Rate" on the front end.  This will include extra results for carriers with state to state rates setup. 

@ratesonly - Used in the Planning Wksht filter views and appear on both External Equipment and Co. Carrier tabs.  "Only Carriers with Rates On File:" on the front end.
	Excludes carriers from the Co. Carrier result set unless they have rates on file.

@expdate  - expdate ini setting to determine if an expiration is coming soon

*/

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

CREATE TABLE #origin_states (
	origin_state	VARCHAR(6)
	)

CREATE TABLE #destination_states (
	destination_state  VARCHAR(6)
	)

CREATE TABLE #tariffdata (
	tar_number	INTEGER NULL,
	trk_carrier	VARCHAR(8) NULL,
	tar_rowbasis	VARCHAR(6) NULL,
	tar_colbasis	VARCHAR(6) NULL,
	trc_rowcolumn	CHAR(1) NULL,
	trc_matchvalue	VARCHAR(10) NULL,
        cty_code	INTEGER NULL,
	cty_state	VARCHAR(6) NULL
	)

create table #temp1 (
	temp1_id 			INTEGER identity,
	trk_number 			INTEGER NULL,
	tar_number 			INTEGER NULL,
	tar_rate 			DECIMAL(9,4) NULL,
	trk_carrier 			VARCHAR(8) NULL,
	Crh_Total 			INTEGER NULL,
	Crh_OnTime			INTEGER NULL,
	cht_itemcode 			VARCHAR(6) NULL,
	cht_description 		VARCHAR(30) NULL,
	Crh_percent			INTEGER NULL,
	Crh_AveFuel			MONEY NULL,
	Crh_AveTotal			MONEY NULL,
	Crh_AveAcc			MONEY NULL,
	car_name			VARCHAR(64) NULL,
	car_address1			VARCHAR(64) NULL,
	car_address2			VARCHAR(64) NULL,
	car_scac			VARCHAR(64) NULL,
	car_phone1			VARCHAR(10) NULL,
	car_phone2			VARCHAR(10) NULL,
	car_contact			VARCHAR(25) NULL,
	defaultContactFirstName	VARCHAR(40) NULL,
	defaultContactLastName	VARCHAR(40) NULL,									  
	car_phone3			VARCHAR(10) NULL,
	car_email			VARCHAR(128) NULL,
	car_currency			VARCHAR(6) NULL,
	cht_currunit			VARCHAR(6) NULL,
	car_rating			VARCHAR(20) NULL,
	exp_priority1 			INTEGER NULL,
	exp_priority2 			INTEGER NULL,
	cty_nmstct			VARCHAR(30) NULL,
   	cartype1_t			VARCHAR(20) NULL,
    	cartype2_t			VARCHAR(20) NULL,
    	cartype3_t			VARCHAR(20) NULL,
    	cartype4_t			VARCHAR(20) NULL,
	car_type1			VARCHAR(6) NULL,
	car_type2			VARCHAR(6) NULL,
	car_type3			VARCHAR(6) NULL,
	car_type4			VARCHAR(6) NULL,
	totalordersfiltered		INTEGER NULL,
	ontimeordersfiltered 		INTEGER NULL,
	percentontimefiltered 		INTEGER NULL,
	keepfromfilter 			CHAR(1) NULL,
	orig_domicile 			CHAR(1) NULL,
	dest_domicile 			CHAR(1) NULL,
	rateonfileorigin 		CHAR(1) NULL,
	rateonfiledest 			CHAR(1)NULL,
	haspaymenthist 			CHAR(1) NULL,
	PayHistAtOrigin 		CHAR(1) NULL,
	PayHistAtDest 			CHAR(1) NULL,
	RatePaidAtOrigin 		CHAR(1) NULL,
	RatePaidAtDest 			CHAR(1) NULL,
	orig_domicile_comb 		CHAR(1) NULL,
	dest_domicile_comb 		CHAR(1) NULL,
	rateonfileorigin_comb 		CHAR(1) NULL,
	rateonfiledest_comb 		CHAR(1)NULL,
	haspaymenthist_comb 		CHAR(1) NULL,
	PayHistAtOrigin_comb 		CHAR(1) NULL,
	PayHistAtDest_comb 		CHAR(1) NULL,
	RatePaidAtOrigin_comb 		CHAR(1) NULL,
	RatePaidAtDest_comb 		CHAR(1) NULL,
	MatchResult 			VARCHAR(1000) NULL,
	CombinedMatchResult 		VARCHAR (1000) NULL, 
	test 				char(1) NULL,
	totalordersfiltered_comb	INTEGER NULL,
	ontimeordersfiltered_comb	INTEGER NULL,
	percentontimefiltered_comb	INTEGER NULL,
	pri1expsoon			INTEGER NULL,
	pri2expsoon			INTEGER NULL,
    	car_exp1date			DATETIME NULL,
    	car_exp2date			DATETIME NULL,
        last_chd_id			INTEGER NULL,
	last_used_date			DATETIME NULL,
        last_billed			MONEY NULL,
        last_paid			MONEY NULL,
	total_billed			MONEY NULL,
        pay_linehaul			MONEY NULL,
        pay_accessorial			MONEY NULL,
        pay_fsc				MONEY NULL,
	cty_code			INTEGER NULL,
        cty_state			VARCHAR(6) NULL,
	total_trips			INTEGER NULL,
        total_late			INTEGER NULL,
        min_chd_id			INTEGER NULL,
        min_billed			MONEY NULL,
        min_paid			MONEY NULL,
        max_chd_id                      INTEGER NULL,
        max_billed                      MONEY NULL,
        max_paid                        MONEY NULL,
        distance_to_origin		INT	NULL,
        distance_to_destination		INT	NULL,
        min_margin_amount		MONEY NULL,
	min_margin_percent		Decimal (13, 4) NULL,
	max_margin_amount		MONEY NULL,
	max_margin_percent		Decimal (13, 4) NULL,
	preferred_lane			CHAR(1) NULL,  --PTS52011 MBR 04/23/10
	qualification_list_drv		varchar(255)	null,
	qualification_list_trc		varchar(255)	null,
	qualification_list_trl		varchar(255)	null,
	load_requirements		CHAR(1),
	offer				CHAR(1),
	offer_linehaul			MONEY NULL,
	offer_fuel			MONEY NULL,
	offer_other			MONEY NULL,
	offer_amount			MONEY NULL,
	offer_contact			VARCHAR(255),
	offer_award_status		VARCHAR(6),
	offer_margin		MONEY NULL,
	offer_margin_percent	DECIMAL(13,4) NULL,
	offer_user		VARCHAR(50) NULL
        )

--PTS 49964 JJF 20091221 sqlserver2008 workaround
create table #temp2 (
	temp1_id 			INTEGER identity,
	trk_number 			INTEGER NULL,
	tar_number 			INTEGER NULL,
	tar_rate 			DECIMAL(9,4) NULL,
	trk_carrier 			VARCHAR(8) NULL,
	Crh_Total 			INTEGER NULL,
	Crh_OnTime			INTEGER NULL,
	cht_itemcode 			VARCHAR(6) NULL,
	cht_description 		VARCHAR(30) NULL,
	Crh_percent			INTEGER NULL,
	Crh_AveFuel			MONEY NULL,
	Crh_AveTotal			MONEY NULL,
	Crh_AveAcc			MONEY NULL,
	car_name			VARCHAR(64) NULL,
	car_address1			VARCHAR(64) NULL,
	car_address2			VARCHAR(64) NULL,
	car_scac			VARCHAR(64) NULL,
	car_phone1			VARCHAR(10) NULL,
	car_phone2			VARCHAR(10) NULL,
	car_contact			VARCHAR(25) NULL,
	defaultContactFirstName	VARCHAR(40) NULL,
	defaultContactLastName	VARCHAR(40) NULL,
	car_phone3			VARCHAR(10) NULL,
	car_email			VARCHAR(128) NULL,
	car_currency			VARCHAR(6) NULL,
	cht_currunit			VARCHAR(6) NULL,
	car_rating			VARCHAR(20) NULL,
	exp_priority1 			INTEGER NULL,
	exp_priority2 			INTEGER NULL,
	cty_nmstct			VARCHAR(30) NULL,
   	cartype1_t			VARCHAR(20) NULL,
    	cartype2_t			VARCHAR(20) NULL,
    	cartype3_t			VARCHAR(20) NULL,
    	cartype4_t			VARCHAR(20) NULL,
	car_type1			VARCHAR(6) NULL,
	car_type2			VARCHAR(6) NULL,
	car_type3			VARCHAR(6) NULL,
	car_type4			VARCHAR(6) NULL,
	totalordersfiltered		INTEGER NULL,
	ontimeordersfiltered 		INTEGER NULL,
	percentontimefiltered 		INTEGER NULL,
	keepfromfilter 			CHAR(1) NULL,
	orig_domicile 			CHAR(1) NULL,
	dest_domicile 			CHAR(1) NULL,
	rateonfileorigin 		CHAR(1) NULL,
	rateonfiledest 			CHAR(1)NULL,
	haspaymenthist 			CHAR(1) NULL,
	PayHistAtOrigin 		CHAR(1) NULL,
	PayHistAtDest 			CHAR(1) NULL,
	RatePaidAtOrigin 		CHAR(1) NULL,
	RatePaidAtDest 			CHAR(1) NULL,
	orig_domicile_comb 		CHAR(1) NULL,
	dest_domicile_comb 		CHAR(1) NULL,
	rateonfileorigin_comb 		CHAR(1) NULL,
	rateonfiledest_comb 		CHAR(1)NULL,
	haspaymenthist_comb 		CHAR(1) NULL,
	PayHistAtOrigin_comb 		CHAR(1) NULL,
	PayHistAtDest_comb 		CHAR(1) NULL,
	RatePaidAtOrigin_comb 		CHAR(1) NULL,
	RatePaidAtDest_comb 		CHAR(1) NULL,
	MatchResult 			VARCHAR(1000) NULL,
	CombinedMatchResult 		VARCHAR (1000) NULL, 
	test 				char(1) NULL,
	totalordersfiltered_comb	INTEGER NULL,
	ontimeordersfiltered_comb	INTEGER NULL,
	percentontimefiltered_comb	INTEGER NULL,
	pri1expsoon			INTEGER NULL,
	pri2expsoon			INTEGER NULL,
    	car_exp1date			DATETIME NULL,
    	car_exp2date			DATETIME NULL,
        last_chd_id			INTEGER NULL,
	last_used_date			DATETIME NULL,
        last_billed			MONEY NULL,
        last_paid			MONEY NULL,
	total_billed			MONEY NULL,
        pay_linehaul			MONEY NULL,
        pay_accessorial			MONEY NULL,
        pay_fsc				MONEY NULL,
	cty_code			INTEGER NULL,
        cty_state			VARCHAR(6) NULL,
	total_trips			INTEGER NULL,
        total_late			INTEGER NULL,
        min_chd_id			INTEGER NULL,
        min_billed			MONEY NULL,
        min_paid			MONEY NULL,
        max_chd_id                      INTEGER NULL,
        max_billed                      MONEY NULL,
        max_paid                        MONEY NULL,
        distance_to_origin		INT	NULL,
        distance_to_destination	INT	NULL,
        preferred_lane			CHAR(1) NULL,  --PTS52011 MBR 04/23/10
	qualification_list_drv		VARCHAR(255)	null,
	qualification_list_trc		VARCHAR(255)	null,
	qualification_list_trl		VARCHAR(255)	null
)
--END PTS 49964 JJF 20091221 sqlserver2008 workaround

--PTS52011 MBR 04/20/10 added zip to table
CREATE TABLE #temporigin (
        airdistance     FLOAT NULL, 
        cty_code        INTEGER NULL, 
        cty_nmstct      VARCHAR(30) NULL,
	cty_zip		VARCHAR(10) NULL
)

--PTS52011 MBR 04/20/10 added zip to table
CREATE TABLE #tempdest (
        airdistance     FLOAT NULL, 
        cty_code        INTEGER NULL, 
        cty_nmstct      VARCHAR(30) NULL,
	cty_zip		VARCHAR(10) NULL
)

--PTS52011 MBR 04/15/10
CREATE TABLE #originlanes (
	laneid		INTEGER NULL
)

CREATE TABLE #lanes (
	laneid		INTEGER NULL
)

CREATE TABLE #lanecarriers (
	car_id		VARCHAR(8) NULL
)

--PTS62447 MBR 05/02/12
CREATE TABLE #loadrequirements (
	lrq_equip_type	VARCHAR(6) NULL,
	lrq_type	VARCHAR(6) NULL,
	lrq_quantity	INTEGER
)
	

/*PTS 50712 CGK 3/31/2010*/
  CREATE TABLE #tempCarrierHistoryDetail (
	chd_id int NULL,
	ord_hdrnumber int NULL,
	ord_origincity int NULL,
	ord_originstate varchar(6) NULL,
	ord_destcity int NULL,
	ord_deststate varchar(6) NULL,
	crh_carrier varchar(8) NULL,
	lgh_pay money NULL,
	lgh_accessorial money NULL,
	lgh_fsc money NULL,
	lgh_billed money NULL,
	lgh_paid money NULL,
	lgh_enddate datetime NULL,
	orders_late int NULL,
	margin money NULL,
	lgh_number int NULL)

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
	@ll_dradius_count	INTEGER,
	@ls_ostates		VARCHAR(200),
	@ls_dstates		VARCHAR(200),
	@ls_cursorstate		VARCHAR(6),
	@ls_ozip		VARCHAR(10),
	@ls_dzip		VARCHAR(10),
	@ll_lanescount		INTEGER,
	@mov_number		INTEGER,
	@lrq_count		INTEGER,
	@lrq_equip_type		VARCHAR(6),
	@lrq_type		VARCHAR(6),
	@lrq_quantity		INTEGER,
	@ord_hdrnumber		INTEGER

--PTS 51570 JJF 20100510
declare @rowsecurity char(1)
--END PTS 51570 JJF 20100510

--PTS 53571 KMM/JJF 20100818
If	@cartype1 = '' AND
	@cartype2 = '' AND
	@cartype3 = '' AND
	@cartype4 = '' AND
	@liabilitylimit <= 0 AND
	@cargolimit <= 0 AND
	isnull(@servicerating, '') = '' AND
	(@carid = 'UNKNOWN' OR ISNULL(@carid, '') = '') AND
	isnull(@carname, '') ='' AND
	@rateonly = '' AND
	isnull(@origin, '') = '' AND
	isnull(@destination, '') = '' AND
	@insurance = '' AND
	@w9 = '' AND
	@contract = '' AND
	@history = 'N' AND
	@domicile = 0 AND
	isnull(@contact, '') = '' AND
	@trcaccess = '' AND
	@trlaccess = '' AND
	@drvqual = '' ANd
	@carqual = '' AND
	@stp_departure_dt <= '19000101' AND
	@returntariffs = 'N' AND
	@branch = '' AND
	@ratesonly = 'N' BEGIN
		-- insert a dummy record
		insert #temp1 (trk_carrier, car_name) values ('UNKNOWN', 'Please supply either origin or destination and try again.')
		GOTO ENDPROC
END
--END PTS 53571 KMM/JJF 20100818


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
          ((@returntariffs = 'N' AND ISNULL(@carid, '') = '' OR 
           (@returntariffs = 'N' AND c.car_id like @carid + '%')) OR 
           (@returntariffs = 'Y' AND c.car_id = @carid)) AND
          (c.car_status <> 'OUT') AND  
          (ISNULL(@contact, '') = '' or c.car_contact like @contact + '%') AND 	
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

 /*     SET @where = 'EXISTS(SELECT caq_id FROM carrierqualifications WHERE caq_id = car_id AND ' +
                   'ISNULL(caq_expire_flag, ''N'') <> ''Y'' AND caq_expire_date >= GETDATE() AND ' + 
                   '((caq_type IN (SELECT abbr FROM labelfile WHERE labeldefinition = ''CarQual'' AND ' +
                   'label_extrastring1 = ''' + @equipment_type_group + ''')) OR (caq_type IN (SELECT abbr FROM ' +
                   'labelfile WHERE labeldefinition = ''CarQual'' AND label_extrastring1 = ''' + @equipment_type_group + ''' AND ' +
                   'label_extrastring2 = ''ANY''))))' */
   END

   SET @sql = 'DELETE #temp_filteredcarriers WHERE fcr_carrier NOT IN (' + 
              'SELECT car_id FROM carrier WITH (NOLOCK) WHERE ' + @where + ')'
   
   EXECUTE sp_executesql @sql
END

/* BEGIN 88113 */

/******* TRAILER ***********/
IF @trlaccess <> ''
BEGIN
   Select @trlaccess = replace(@trlaccess,',',') and (')
   SET @where = NULL
   SET @sql = NULL

   SET @where = 'EXISTS(SELECT ta_trailer FROM trlaccessories WITH (NOLOCK) WHERE ta_trailer = car_id AND ' +
				'ta_source = ''CAR'' AND ISNULL(ta_expire_flag, ''N'') <> ''Y'' AND ' +
				'ta_expire_date >= GETDATE() AND (' + @trlaccess + '))'
				
	SET @sql = 'DELETE #temp_filteredcarriers WHERE fcr_carrier NOT IN (' + 
              'SELECT car_id FROM carrier WITH (NOLOCK) WHERE ' + @where + ')'
      
    EXECUTE sp_executesql @sql     
END


/********** TRACTOR ***********/
IF @trcaccess <> ''
BEGIN
   Select @trcaccess = replace(@trcaccess,',',') and (')
   SET @where = NULL
   SET @sql = NULL

	SET @where = 'EXISTS(SELECT tca_tractor FROM tractoraccesories WITH (NOLOCK) WHERE tca_tractor = car_id AND ' +
                'tca_source = ''CAR'' AND ISNULL(tca_expire_flag, ''N'') <> ''Y'' AND ' +
                'tca_expire_date >= GETDATE() AND (' + @trcaccess + '))'
				
	SET @sql = 'DELETE #temp_filteredcarriers WHERE fcr_carrier NOT IN (' + 
              'SELECT car_id FROM carrier WITH (NOLOCK) WHERE ' + @where + ')'
      
    EXECUTE sp_executesql @sql     
END

/********** DRIVER ***********/
IF @drvqual <> ''
BEGIN
   Select @drvqual = replace(@drvqual,',',') and (')
   SET @where = NULL
   SET @sql = NULL

	SET @where = 'EXISTS(SELECT drq_id FROM driverqualifications WITH (NOLOCK) where drq_id = car_id AND ' +
                            'drq_source = ''CAR'' AND ISNULL(drq_expire_flag, ''N'') <> ''Y'' AND ' + 
                            'drq_expire_date >= GETDATE() AND (' + @drvqual + '))'
				
	SET @sql = 'DELETE #temp_filteredcarriers WHERE fcr_carrier NOT IN (' + 
              'SELECT car_id FROM carrier WITH (NOLOCK) WHERE ' + @where + ')'
      
    EXECUTE sp_executesql @sql     
END

/********** CARRIER ***********/
IF @carqual <> ''
BEGIN
   Select @carqual = replace(@carqual,',',') and (')
   SET @where = NULL
   SET @sql = NULL

   SET @where = 'EXISTS(SELECT caq_id FROM carrierqualifications WITH (NOLOCK) WHERE caq_id = car_id AND ' +
		            'ISNULL(caq_expire_flag, ''N'') <> ''Y'' AND ' +
                    'caq_expire_date >= GETDATE() AND (' + @carqual + '))'
				
	SET @sql = 'DELETE #temp_filteredcarriers WHERE fcr_carrier NOT IN (' + 
              'SELECT car_id FROM carrier WITH (NOLOCK) WHERE ' + @where + ')'
      
    EXECUTE sp_executesql @sql     
END


 
               






/* END 88113 */




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
         --PTS 53571 KMM/JJF 20100818 add nolock
         SELECT @ll_ocity = cty_code,
                @orig_lat = ISNULL(cty_latitude, 0),
                @orig_long = ISNULL(cty_longitude, 0),
                @ls_ozip = cty_zip
           FROM city with (nolock)
          WHERE cty_name = @ls_ocity AND
                cty_state = @ls_ostate AND
				--PTS 49405 JJF 20091009
				--cty_county = @ls_ocounty
				(cty_county = @ls_ocounty or isnull(@ls_ocounty, '') = '')
				--END PTS 49405 JJF 20091009
         IF @ll_ocity IS NULL
            SET @ll_ocity = 0
      END
      ELSE
      BEGIN
         SET @ls_ocity = RTRIM(LTRIM(LEFT(@origin, (@ete_commapos - 1))))
         SET @ls_ostate = RTRIM(LTRIM(RIGHT(@origin, (LEN(@origin) - @ete_commapos))))
         --PTS 53571 KMM/JJF 20100818 add nolock
         SELECT @ll_ocity = cty_code,
		@orig_lat = ISNULL(cty_latitude, 0),
                @orig_long = ISNULL(cty_longitude, 0),
                @ls_ozip = cty_zip
           FROM city with (nolock)
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
				--PTS 53571 KMM/JJF 20100818 add nolock
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
         --PTS 53571 KMM/JJF 20100818 add nolock
         SELECT @ll_dcity = cty_code,
                @dest_lat = ISNULL(cty_latitude, 0),
                @dest_long = ISNULL(cty_longitude, 0),
                @ls_dzip = cty_zip
           FROM city with (nolock)
          WHERE cty_name = @ls_dcity AND
                cty_state = @ls_dstate AND
   				--PTS 49405 JJF 20091009
				--cty_county = @@ls_dcounty
				(cty_county = @ls_dcounty or isnull(@ls_dcounty, '') = '')
				--END PTS 49405 JJF 20091009
         IF @ll_dcity IS NULL
            SET @ll_dcity = 0
      END
      ELSE
      BEGIN
         SET @ls_dcity = RTRIM(LTRIM(LEFT(@destination, (@ete_commapos - 1))))
         SET @ls_dstate = RTRIM(LTRIM(RIGHT(@destination, (LEN(@destination) - @ete_commapos))))
         --PTS 53571 KMM/JJF 20100818 add nolock
         SELECT @ll_dcity = cty_code,
                @dest_lat = ISNULL(cty_latitude, 0),
                @dest_long = ISNULL(cty_longitude, 0),
                @ls_dzip = cty_zip
           FROM city with (nolock)
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
			--PTS 53571 KMM/JJF 20100818 add nolock
            INSERT INTO #destination_states
               SELECT tcz_state
                 FROM transcore_zones with (nolock)
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

IF @ll_ostates > 0
BEGIN
   SET @ls_ostates = ','
   
   DECLARE origin_cursor CURSOR FOR
      SELECT DISTINCT origin_state
        FROM #origin_states

   OPEN origin_cursor

   FETCH NEXT FROM origin_cursor
    INTO @ls_cursorstate

   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @ls_ostates = @ls_ostates + @ls_cursorstate + ','   

      FETCH NEXT FROM origin_cursor
       INTO @ls_cursorstate

   END

   CLOSE origin_cursor
   DEALLOCATE origin_cursor

END

IF @ll_dstates > 0
BEGIN
   SET @ls_dstates = ','
   
   DECLARE dest_cursor CURSOR FOR
      SELECT DISTINCT destination_state
        FROM #destination_states

   OPEN dest_cursor

   FETCH NEXT FROM dest_cursor
    INTO @ls_cursorstate

   WHILE @@FETCH_STATUS = 0
   BEGIN
      SET @ls_dstates = @ls_dstates + @ls_cursorstate + ','   

      FETCH NEXT FROM dest_cursor
       INTO @ls_cursorstate

   END

   CLOSE dest_cursor
   DEALLOCATE dest_cursor

END

/*PTS 50712 CGK 3/31/2010*/
--PTS 53571 KMM/JJF 20100818 add nolock
INSERT INTO #tempcarrierhistorydetail (chd_id, ord_hdrnumber, ord_origincity, ord_originstate, ord_destcity, ord_deststate, crh_carrier, 
									lgh_pay, lgh_accessorial, lgh_fsc, lgh_billed, lgh_paid, lgh_enddate, orders_late, margin, lgh_number)
SELECT chd.chd_id, chd.ord_hdrnumber, chd.ord_origincity, chd.ord_originstate, chd.ord_destcity, chd.ord_deststate, chd.Crh_Carrier, 
		chd.lgh_pay, chd.lgh_accessorial, chd.lgh_fsc, chd.lgh_billed, chd.lgh_paid, chd.lgh_enddate, chd.orders_late, chd.margin, chd.lgh_number
FROM carrierhistorydetail chd with (nolock), #temp_filteredcarriers
WHERE chd.crh_carrier = #temp_filteredcarriers.fcr_carrier
 AND ((@oradius = 0 AND  
   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
   (@oradius > 0 AND  
    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
  ((@dradius = 0 AND  
   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates ) > 0)) OR  
   (@dradius > 0 AND  
    chd.ord_destcity IN (select cty_code from #tempdest)))    

--Retrieve Carriers based on what is in the history table for the entered origin
--and destination criteria
--PTS 53571 KMM/JJF 20100818 add nolock
INSERT INTO #temp1 (trk_carrier, crh_total, crh_ontime, crh_percent, crh_avefuel,
                    crh_avetotal, crh_aveacc, car_name,	car_address1, car_address2,
                    car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                    car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                    cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                    cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile,
                    dest_domicile, rateonfileorigin, total_billed, pay_linehaul,
                    pay_accessorial, pay_fsc, last_chd_id, total_trips, total_late,
                    min_chd_id, max_chd_id, /*PTS 50712 CGK 3/31/2010*/max_billed, max_paid, min_billed, min_paid, 
		    min_margin_amount, max_margin_amount, min_margin_percent, max_margin_percent,
                    preferred_lane, load_requirements, offer)
   SELECT crh_carrier, 
          crh_total, 
          crh_ontime, 
          crh_percent, 
          crh_avefuel,
          crh_avetotal, 
          crh_aveacc,
          ISNULL(carrier.car_name, ''),
          ISNULL(carrier.car_address1, ''),
          ISNULL(carrier.car_address2, ''),
          ISNULL(carrier.car_scac, ''),
          ISNULL(carrier.car_Phone1, ''),
          ISNULL(carrier.car_Phone2, ''),
          ISNULL(carrier.car_contact, ''),
          ISNULL(carrier.car_phone3, ''),
          ISNULL(carrier.car_email, ''),
          ISNULL(carrier.car_currency, ''),
          (SELECT name 
             FROM labelfile with (nolock)
            WHERE labeldefinition = 'CarrierServiceRating' AND
                  abbr = carrier.car_rating),
          (SELECT MAX(cartype1) FROM labelfile_headers with (nolock)),
          (SELECT MAX(cartype2) FROM labelfile_headers with (nolock)),
          (SELECT MAX(cartype3) FROM labelfile_headers with (nolock)),
          (SELECT MAX(cartype4) FROM labelfile_headers with (nolock)),
          carrier.car_type1,
          carrier.car_type2,
          carrier.car_type3,
          carrier.car_type4,
          city.cty_nmstct,
          carrier.cty_code,
          city.cty_state,
          'Y',
          'N',
          'N',
          'N',
		/*Start PTS 50712 CGK 3/31/2010*/
          (SELECT ISNULL(SUM(lgh_billed), 0)  
             FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
            WHERE chd.crh_carrier = carrierhistory.crh_carrier AND  
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest)))), 
           (SELECT ISNULL(SUM(lgh_pay), 0)  
             FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
            WHERE chd.crh_carrier = carrierhistory.crh_carrier AND  
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest)))),  
           (SELECT ISNULL(SUM(lgh_accessorial), 0)  
             FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
            WHERE chd.crh_carrier = carrierhistory.crh_carrier AND  
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest)))),
           (SELECT ISNULL(SUM(lgh_fsc), 0)  
             FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
            WHERE chd.crh_carrier = carrierhistory.crh_carrier AND  
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest)))),  
           (SELECT TOP 1 ISNULL(chd_id, 0)  
              FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
             WHERE chd.crh_carrier = carrierhistory.crh_carrier AND  
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest)))  
            ORDER BY chd.lgh_enddate DESC),  
           (SELECT COUNT(*)  
              FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
             WHERE chd.crh_carrier = carrierhistory.crh_carrier AND  
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest)))),  
           (SELECT COUNT(*)  
              FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
             WHERE chd.crh_carrier = carrierhistory.crh_carrier AND  
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest))) AND  
                   orders_late > 0),  
            0,
            0,
           (SELECT MAX(chd.lgh_billed)
              FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
             WHERE chd.crh_carrier = carrierhistory.crh_carrier AND  
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates ) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest)))
            GROUP BY chd.crh_carrier),
           (SELECT MAX(chd.lgh_paid)
              FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
             WHERE chd.crh_carrier = carrierhistory.crh_carrier AND  
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates ) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest)))
            GROUP BY chd.crh_carrier),
           (SELECT MIN(chd.lgh_billed)
              FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
             WHERE chd.crh_carrier = carrierhistory.crh_carrier AND  
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates ) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest)))
            GROUP BY chd.crh_carrier),
           (SELECT MIN(chd.lgh_paid)
              FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
             WHERE chd.crh_carrier = carrierhistory.crh_carrier AND  
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates ) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest)))
            GROUP BY chd.crh_carrier),
           (SELECT MIN(lgh_billed - lgh_paid)
              FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
             WHERE chd.crh_carrier = carrierhistory.crh_carrier AND
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates ) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest)))
            GROUP BY chd.crh_carrier),
	   (SELECT MAX(lgh_billed - lgh_paid)
              FROM #tempcarrierhistorydetail chd WITH (NOLOCK)  
             WHERE chd.crh_carrier = carrierhistory.crh_carrier AND  
                  ((@oradius = 0 AND  
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND  
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR  
                   (@oradius > 0 AND  
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND  
                  ((@dradius = 0 AND  
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND  
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates ) > 0)) OR  
                   (@dradius > 0 AND  
                    chd.ord_destcity IN (select cty_code from #tempdest)))
            GROUP BY chd.crh_carrier),
 		/*End PTS 50712 CGK 3/31/2010*/
           (SELECT MIN(margin)
              FROM carrierhistorydetail chd WITH (NOLOCK)
             WHERE chd.crh_carrier = carrierhistory.crh_carrier AND
                   ISNULL(chd.margin, 0) <> 0 AND
                  ((@oradius = 0 AND
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR
                   (@oradius > 0 AND
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND
                  ((@dradius = 0 AND
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0)) OR
                   (@dradius > 0 AND
                    chd.ord_destcity IN (select cty_code from #tempdest)))),
           (SELECT MAX(margin)
              FROM carrierhistorydetail chd WITH (NOLOCK)
             WHERE chd.crh_carrier = carrierhistory.crh_carrier AND
                   ISNULL(chd.margin, 0) <> 0 AND
                  ((@oradius = 0 AND
                   (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND
                   (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR
                   (@oradius > 0 AND
                    chd.ord_origincity IN (select cty_code from #temporigin))) AND
                  ((@dradius = 0 AND
                   (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND
                   (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_ostates) > 0)) OR
                   (@dradius > 0 AND
                    chd.ord_destcity IN (select cty_code from #tempdest)))),
            'N',
            'N',
	    'N'               
     FROM carrierhistory WITH (NOLOCK) LEFT OUTER JOIN carrier WITH (NOLOCK) ON carrierhistory.crh_carrier = carrier.car_id
                         JOIN city WITH (NOLOCK) ON carrier.cty_code = city.cty_code
                         JOIN #temp_filteredcarriers ON carrierhistory.crh_carrier = #temp_filteredcarriers.fcr_carrier
    WHERE crh_carrier IN (SELECT DISTINCT crh_carrier
                            FROM carrierhistorydetail chd with (nolock)
                           WHERE ((@oradius = 0 AND
                                  (@ll_ocity = 0 OR chd.ord_origincity = @ll_ocity) AND
                                  (@ll_ostates = 0 OR CHARINDEX(',' + chd.ord_originstate + ',', @ls_ostates) > 0)) OR
                                  (@oradius > 0 AND
                                   chd.ord_origincity IN (select cty_code from #temporigin))) AND
                                 ((@dradius = 0 AND
                                  (@ll_dcity = 0 OR chd.ord_destcity = @ll_dcity) AND
                                  (@ll_dstates = 0 OR CHARINDEX(',' + chd.ord_deststate + ',', @ls_dstates) > 0)) OR
                                  (@dradius > 0 AND
                                   chd.ord_destcity IN (select cty_code from #tempdest))))
                                   
--PTS 53571 KMM/JJF 20100818 add nolock
UPDATE #temp1
   SET last_used_date = chd.lgh_enddate,
       last_billed = chd.lgh_billed,
       last_paid = ISNULL(chd.lgh_paid,0)
  FROM carrierhistorydetail chd with (nolock)
 WHERE #temp1.last_chd_id = chd.chd_id AND
       #temp1.last_chd_id > 0

/*Start PTS 50712 CGK 3/31/2010*/
--UPDATE #temp1
--   SET min_billed = chd.lgh_billed,
--       min_paid = chd.lgh_paid
--  FROM carrierhistorydetail chd
-- WHERE #temp1.min_chd_id = chd.chd_id AND
--       #temp1.min_chd_id > 0
--
--UPDATE #temp1
--   SET max_billed = chd.lgh_billed,
--       max_paid = chd.lgh_paid
--  FROM carrierhistorydetail chd
-- WHERE #temp1.max_chd_id = chd.chd_id AND
--       #temp1.max_chd_id > 0
/*End PTS 50712 CGK 3/31/2010*/

--PTS52011 MBR 04/20/10 Added this section to find carriers tied to a lane that corresponds
--to the origin and destination criteria

--Find lanes by the origin criteria
if @ll_ocity > 0 and @oradius = 0
BEGIN
   IF @ls_ozip IS NOT NULL AND @ls_ozip <> '' AND @ls_ozip <> '00000'
   BEGIN
      INSERT INTO #originlanes
         SELECT DISTINCT laneid
           FROM core_lanelocation cll
          WHERE cll.isorigin = 1 AND
              ((cll.type = 2 AND
                cll.citycode = @ll_ocity) OR
               (cll.type = 5 AND
                cll.stateabbr IN (SELECT city.cty_state
                                    FROM city
                                   WHERE city.cty_code = @ll_ocity)) OR
               (cll.type = 3 AND
                cll.zippart = @ls_ozip) OR
               (cll.type = 3 AND
                cll.zippart = SUBSTRING(@ls_ozip, 1, 3)))
   END
   ELSE
   BEGIN
      INSERT INTO #originlanes
         SELECT DISTINCT laneid
           FROM core_lanelocation cll
          WHERE cll.isorigin = 1 AND
              ((cll.type = 2 AND
                cll.citycode = @ll_ocity) OR
               (cll.type = 5 AND
                cll.stateabbr IN (SELECT city.cty_state
                                    FROM city
                                   WHERE city.cty_code = @ll_ocity)))
   END
END

IF @ll_ocity > 0 and @oradius > 0
BEGIN
   INSERT INTO #originlanes
      SELECT DISTINCT laneid
        FROM core_lanelocation cll
       WHERE cll.isorigin = 1 AND
           ((cll.type = 2 AND
             cll.citycode IN (SELECT cty_code
                               FROM #temporigin)) OR
            (cll.type = 5 AND
             cll.stateabbr IN (SELECT cty_state
                                 FROM city
                                WHERE cty_code = @ll_ocity)) OR
            (cll.type = 3 AND
             cll.zippart IN (SELECT cty_zip
                               FROM #temporigin
                              WHERE cty_zip IS NOT NULL AND
                                    cty_zip <> '' AND
                                    cty_zip <> '00000')) OR
            (cll.type = 3 AND
             cll.zippart IN (SELECT SUBSTRING(cty_zip, 1, 3)
                               FROM #temporigin
                              WHERE cty_zip IS NOT NULL AND
                                    cty_zip <> '' AND
                                    cty_zip <> '00000')))
END

IF @ll_ostates > 0 
BEGIN
   INSERT INTO #originlanes
      SELECT DISTINCT laneid
        FROM core_lanelocation cll
       WHERE cll.isorigin = 1 AND
           ((cll.type = 5 AND
             cll.stateabbr IN (SELECT origin_state
                                 FROM #origin_states)) OR
            (cll.type = 2 AND
             cll.citycode IN (SELECT city.cty_code
                                FROM city
                               WHERE city.cty_state IN (SELECT origin_state
                                                          FROM #origin_states))) OR
            (cll.type = 3 AND
             cll.zippart IN (SELECT city.cty_zip
                               FROM city
                              WHERE city.cty_state IN (SELECT origin_state
                                                         FROM #origin_states))) OR
            (cll.type = 3 AND
             cll.zippart IN (SELECT SUBSTRING(city.cty_zip, 1, 3)
                               FROM city
                              WHERE city.cty_state IN (SELECT origin_state
                                                         FROM #origin_states))))

END

--Set count of lanes found using the origin criteria
SET @ll_lanescount = 0
SELECT @ll_lanescount = COUNT(*)
  FROM #originlanes

--Find lanes using the destination criteria.  If origin lanes were already found using the 
--origin criteria, find lanes with the destination criteria and join to the origin lanes.
if @ll_dcity > 0 and @dradius = 0
BEGIN
   IF @ls_dzip IS NOT NULL AND @ls_dzip <> '' AND @ls_dzip <> '00000'
   BEGIN
      IF @ll_lanescount = 0
      BEGIN
         INSERT INTO #lanes
            SELECT DISTINCT cll.laneid
              FROM core_lanelocation cll
             WHERE cll.isorigin = 2 AND
                 ((cll.type = 2 AND
                   cll.citycode = @ll_dcity) OR
                  (cll.type = 5 AND
                   cll.stateabbr IN (SELECT city.cty_state
                                       FROM city
                                      WHERE city.cty_code = @ll_dcity)) OR
                  (cll.type = 3 AND
                   cll.zippart = @ls_dzip) OR
                  (cll.type = 3 AND
                   cll.zippart = SUBSTRING(@ls_dzip, 1, 3)))
      END
      ELSE
      BEGIN
        INSERT INTO #lanes
            SELECT DISTINCT cll.laneid
              FROM core_lanelocation cll JOIN #originlanes ON cll.laneid = #originlanes.laneid
             WHERE cll.isorigin = 2 AND
                 ((cll.type = 2 AND
                   cll.citycode = @ll_dcity) OR
                  (cll.type = 5 AND
                   cll.stateabbr IN (SELECT city.cty_state
                                       FROM city
                                      WHERE city.cty_code = @ll_dcity)) OR
                  (cll.type = 3 AND
                   cll.zippart = @ls_dzip) OR
                  (cll.type = 3 AND
                   cll.zippart = SUBSTRING(@ls_dzip, 1, 3)))
      END
   END
   ELSE
   BEGIN
      IF @ll_lanescount = 0
      BEGIN
         INSERT INTO #lanes
            SELECT DISTINCT cll.laneid
              FROM core_lanelocation cll
             WHERE cll.isorigin = 2 AND
                 ((cll.type = 2 AND
                   cll.citycode = @ll_dcity) OR
                  (cll.type = 5 AND
                   cll.stateabbr IN (SELECT city.cty_state
                                       FROM city
                                      WHERE city.cty_code = @ll_dcity)))
      END
      ELSE
      BEGIN
         INSERT INTO #lanes
            SELECT DISTINCT cll.laneid
              FROM core_lanelocation cll JOIN #originlanes ON cll.laneid = #originlanes.laneid
             WHERE cll.isorigin = 2 AND
                 ((cll.type = 2 AND
                   cll.citycode = @ll_dcity) OR
                  (cll.type = 5 AND
                   cll.stateabbr IN (SELECT city.cty_state
                                       FROM city
                                      WHERE city.cty_code = @ll_dcity)))

      END
   END
END

IF @ll_dcity > 0 and @dradius > 0
BEGIN
   IF @ll_lanescount = 0
   BEGIN
      INSERT INTO #lanes
         SELECT DISTINCT cll.laneid
           FROM core_lanelocation cll
          WHERE cll.isorigin = 2 AND
              ((cll.type = 2 AND
                cll.citycode IN (SELECT cty_code
                                   FROM #tempdest)) OR
               (cll.type = 5 AND
                cll.stateabbr IN (SELECT cty_state
                                    FROM city
                                   WHERE cty_code = @ll_dcity)) OR
               (cll.type = 3 AND
                cll.zippart IN (SELECT cty_zip
                                  FROM #tempdest
                                 WHERE cty_zip IS NOT NULL AND
                                       cty_zip <> '' AND
                                       cty_zip <> '00000')) OR
               (cll.type = 3 AND
                cll.zippart IN (SELECT SUBSTRING(cty_zip, 1, 3)
                                  FROM #tempdest
                                 WHERE cty_zip IS NOT NULL AND
                                       cty_zip <> '' AND
                                       cty_zip <> '00000')))
   END
   ELSE
   BEGIN
      INSERT INTO #lanes
         SELECT DISTINCT cll.laneid
           FROM core_lanelocation cll JOIN #originlanes ON cll.laneid = #originlanes.laneid
          WHERE cll.isorigin = 2 AND
              ((cll.type = 2 AND
                cll.citycode IN (SELECT cty_code
                                   FROM #tempdest)) OR
               (cll.type = 5 AND
                cll.stateabbr IN (SELECT cty_state
                                    FROM city
                                   WHERE cty_code = @ll_dcity)) OR
               (cll.type = 3 AND
                cll.zippart IN (SELECT cty_zip
                                  FROM #tempdest
                                 WHERE cty_zip IS NOT NULL AND
                                       cty_zip <> '' AND
                                       cty_zip <> '00000')) OR
               (cll.type = 3 AND
                cll.zippart IN (SELECT SUBSTRING(cty_zip, 1, 3)
                                  FROM #tempdest
                                 WHERE cty_zip IS NOT NULL AND
                                       cty_zip <> '' AND
                                       cty_zip <> '00000')))
   END
END

IF @ll_dstates > 0 
BEGIN
   IF @ll_lanescount = 0
   BEGIN
      INSERT INTO #lanes
         SELECT DISTINCT cll.laneid
           FROM core_lanelocation cll
          WHERE cll.isorigin = 2 AND
              ((cll.type = 5 AND
                cll.stateabbr IN (SELECT destination_state
                                    FROM #destination_states)) OR
               (cll.type = 2 AND
                cll.citycode IN (SELECT city.cty_code
                                   FROM city
                                  WHERE city.cty_state IN (SELECT destination_state
                                                             FROM #destination_states))) OR
               (cll.type = 3 AND
                cll.zippart IN (SELECT city.cty_zip
                                  FROM city
                                 WHERE city.cty_state IN (SELECT destination_state
                                                            FROM #destination_states))) OR
               (cll.type = 3 AND
                cll.zippart IN (SELECT SUBSTRING(city.cty_zip, 1, 3)
                                  FROM city
                                 WHERE city.cty_state IN (SELECT destination_state
                                                            FROM #destination_states))))
   END
   ELSE
   BEGIN
      INSERT INTO #lanes
         SELECT DISTINCT cll.laneid
           FROM core_lanelocation cll JOIN #originlanes ON cll.laneid = #originlanes.laneid
          WHERE cll.isorigin = 2 AND
              ((cll.type = 5 AND
                cll.stateabbr IN (SELECT destination_state
                                    FROM #destination_states)) OR
               (cll.type = 2 AND
                cll.citycode IN (SELECT city.cty_code
                                   FROM city
                                  WHERE city.cty_state IN (SELECT destination_state
                                                             FROM #destination_states))) OR
               (cll.type = 3 AND
                cll.zippart IN (SELECT city.cty_zip
                                  FROM city
                                 WHERE city.cty_state IN (SELECT destination_state
                                                            FROM #destination_states))) OR
               (cll.type = 3 AND
                cll.zippart IN (SELECT SUBSTRING(city.cty_zip, 1, 3)
                                  FROM city
                                 WHERE city.cty_state IN (SELECT destination_state
                                                            FROM #destination_states))))
   END
END

--If origin lanes were found using the origin criteria and no destination criteria was entered,
--move the rows from the #originlanes table into the #lanes table.
IF @ll_lanescount > 0 AND @ll_dcity = 0 AND @ll_dstates = 0
BEGIN
   INSERT INTO #lanes
      SELECT laneid
        FROM #originlanes
END

--If no origin or destination criteria was entered, load all distinct lanes into the #lanes table.
IF @ll_ocity = 0 AND @ll_ostates = 0 AND @ll_dcity = 0 AND @ll_dstates = 0
BEGIN
   INSERT INTO #lanes
      SELECT DISTINCT laneid
        FROM core_lanelocation
END

--Find all of the distinct carriers that are assigned to the lanes from the #lanes table.
INSERT INTO #lanecarriers
   SELECT DISTINCT car_id
     FROM core_carrierlanecommitment JOIN #lanes ON core_carrierlanecommitment.laneid = #lanes.laneid

--Update #temp1's preferred_lane column for the carrier found in #lanecarriers
UPDATE #temp1
   SET #temp1.preferred_lane = 'Y'
 WHERE #temp1.trk_carrier IN (SELECT car_id
                                FROM #lanecarriers)

--Insert a row into #temp1 for carriers not already in #temp1 from #lanecarriers
--PTS51809 MBR 04/27/10 Added carrierhistory columns
INSERT INTO #temp2 (trk_carrier, car_name, car_address1, car_address2,
	            car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                    car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                    cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                    cty_nmstct, cty_code, cty_state, orig_domicile, dest_domicile,
                    haspaymenthist, rateonfileorigin, preferred_lane, crh_total,
                    crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
      SELECT carrier.car_id,
             ISNULL(carrier.car_name, ''),
             ISNULL(carrier.car_address1, ''),
             ISNULL(carrier.car_address2, ''),
             ISNULL(carrier.car_scac, ''),
             ISNULL(carrier.car_Phone1, ''),
             ISNULL(carrier.car_Phone2, ''),
             ISNULL(carrier.car_contact, ''),
             ISNULL(carrier.car_phone3, ''),
             ISNULL(carrier.car_email, ''),
             ISNULL(carrier.car_currency, ''),
             (SELECT name 
                FROM labelfile WITH (NOLOCK)
               WHERE labeldefinition = 'CarrierServiceRating' AND
                     abbr = carrier.car_rating),
             (SELECT MAX(cartype1) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype2) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype3) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype4) FROM labelfile_headers WITH (NOLOCK)),
             carrier.car_type1,
             carrier.car_type2,
             carrier.car_type3,
             carrier.car_type4,
             city.cty_nmstct,
             carrier.cty_code,
             city.cty_state,
             'N',
             'N',
             'N',
             'N',
             'Y',
             --PTS51809 MBR 04/27/10
             ISNULL(carrierhistory.crh_total, 0),
             ISNULL(carrierhistory.crh_ontime, 0),
             ISNULL(carrierhistory.crh_percent, 0),
             ISNULL(carrierhistory.crh_avefuel, 0),
             ISNULL(carrierhistory.crh_avetotal, 0),
             ISNULL(carrierhistory.crh_aveacc, 0)
        FROM #lanecarriers JOIN carrier WITH (NOLOCK) ON #lanecarriers.car_id = carrier.car_id
                           JOIN city WITH (NOLOCK) ON carrier.cty_code = city.cty_code
                           LEFT OUTER JOIN carrierhistory WITH (NOLOCK) ON #lanecarriers.car_id = carrierhistory.crh_carrier
       WHERE #lanecarriers.car_id NOT IN (SELECT trk_carrier
                                            FROM #temp1) AND
             #lanecarriers.car_id IN (SELECT fcr_carrier
                                        FROM #temp_filteredcarriers)

--PTS51809 MBR 04/27/10 Added carrierhistory columns
INSERT INTO #temp1 (trk_carrier, tar_number, car_name, car_address1, car_address2,
                    car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                    car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                    cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                    cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, 
                    dest_domicile, rateonfileorigin, preferred_lane, crh_total, 
                    crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
   SELECT trk_carrier, tar_number, car_name, car_address1, car_address2,
          car_scac, car_phone1, car_phone2, car_contact, car_phone3,
          car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
          cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
          cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, 
          dest_domicile, rateonfileorigin, preferred_lane, crh_total,
          crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc
     FROM #temp2

DELETE FROM #temp2

--Check for origin and destination domiciles.  Scan through all carriers already inserted into #temp1
--and update the origin and destination domicile flags if applicable.  Then grab any carriers not in
--#temp1 and insert if origin or destination domicile match.

IF @ll_ocity > 0
BEGIN
   UPDATE #temp1
      SET orig_domicile = 'Y'
    WHERE ((@oradius = 0 AND #temp1.cty_code = @ll_ocity) OR
           (@oradius > 0 AND #temp1.cty_code IN (SELECT cty_code 
                                                      FROM #temporigin)))

   --PTS 49964 JJF 20091221 sqlserver2008 workaround
   --INSERT INTO #temp1 (trk_carrier, car_name, car_address1, car_address2,
   --PTS51809 MBR 04/27/10 Added carrierhistory columns
   INSERT INTO #temp2 (trk_carrier, car_name, car_address1, car_address2,
	               car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                       car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                       cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                       cty_nmstct, cty_code, cty_state, orig_domicile, dest_domicile,
                       haspaymenthist, rateonfileorigin, preferred_lane, crh_total,
                       crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
      SELECT carrier.car_id,
             ISNULL(carrier.car_name, ''),
             ISNULL(carrier.car_address1, ''),
             ISNULL(carrier.car_address2, ''),
             ISNULL(carrier.car_scac, ''),
             ISNULL(carrier.car_Phone1, ''),
             ISNULL(carrier.car_Phone2, ''),
             ISNULL(carrier.car_contact, ''),
             ISNULL(carrier.car_phone3, ''),
             ISNULL(carrier.car_email, ''),
             ISNULL(carrier.car_currency, ''),
             (SELECT name 
                FROM labelfile WITH (NOLOCK)
               WHERE labeldefinition = 'CarrierServiceRating' AND
                     abbr = carrier.car_rating),
             (SELECT MAX(cartype1) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype2) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype3) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype4) FROM labelfile_headers WITH (NOLOCK)),
             carrier.car_type1,
             carrier.car_type2,
             carrier.car_type3,
             carrier.car_type4,
             city.cty_nmstct,
             carrier.cty_code,
             city.cty_state,
             'Y',
             'N',
             'N',
             'N',
             'N',
             --PTS51809 MBR 04/27/10
             ISNULL(carrierhistory.crh_total, 0),
             ISNULL(carrierhistory.crh_ontime, 0),
             ISNULL(carrierhistory.crh_percent, 0),
             ISNULL(carrierhistory.crh_avefuel, 0),
             ISNULL(carrierhistory.crh_avetotal, 0),
             ISNULL(carrierhistory.crh_aveacc, 0)
        FROM carrier WITH (NOLOCK) JOIN city WITH (NOLOCK) ON carrier.cty_code = city.cty_code
                                   LEFT OUTER JOIN carrierhistory WITH (NOLOCK) ON carrier.car_id = carrierhistory.crh_carrier
       WHERE ((@oradius = 0 AND carrier.cty_code = @ll_ocity) OR
              (@oradius > 0 AND carrier.cty_code IN (SELECT cty_code 
                                                      FROM #temporigin)))  AND
             carrier.car_id NOT IN (SELECT trk_carrier
                                      FROM #temp1) AND
             carrier.car_id IN (SELECT fcr_carrier
                                  FROM #temp_filteredcarriers) 

   --PTS 49964 JJF 20091221 sqlserver2008 workaround
   --PTS51809 MBR 04/27/10 Added carrierhistory columns
   INSERT INTO #temp1 (trk_carrier, tar_number, car_name, car_address1, car_address2,
                       car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                       car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                       cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                       cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, 
                       dest_domicile, rateonfileorigin, preferred_lane, crh_total, 
                       crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
      SELECT trk_carrier, tar_number, car_name, car_address1, car_address2,
             car_scac, car_phone1, car_phone2, car_contact, car_phone3,
             car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
             cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
             cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, 
             dest_domicile, rateonfileorigin, preferred_lane, crh_total,
             crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc
        FROM #temp2

   DELETE FROM #temp2
   --PTS 49964 JJF 20091221 sqlserver2008 workaround
                                  
END


IF @ll_ostates > 0
BEGIN
   UPDATE #temp1
      SET orig_domicile = 'Y'
    WHERE #temp1.cty_state IN (SELECT origin_state
                                 FROM #origin_states)

   --PTS 49964 JJF 20091221 sqlserver2008 workaround
   --INSERT INTO #temp1 (trk_carrier, car_name, car_address1, car_address2,
   --PTS51809 MBR 04/27/10 Added carrierhistory columns
   INSERT INTO #temp2 (trk_carrier, car_name, car_address1, car_address2,
	               car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                       car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                       cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                       cty_nmstct, cty_code, cty_state, orig_domicile, dest_domicile, 
                       haspaymenthist, rateonfileorigin, preferred_lane, crh_total,
                       crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
      SELECT carrier.car_id,
             ISNULL(carrier.car_name, ''),
             ISNULL(carrier.car_address1, ''),
             ISNULL(carrier.car_address2, ''),
             ISNULL(carrier.car_scac, ''),
             ISNULL(carrier.car_Phone1, ''),
             ISNULL(carrier.car_Phone2, ''),
             ISNULL(carrier.car_contact, ''),
             ISNULL(carrier.car_phone3, ''),
             ISNULL(carrier.car_email, ''),
             ISNULL(carrier.car_currency, ''),
             (SELECT name 
                FROM labelfile WITH (NOLOCK)
               WHERE labeldefinition = 'CarrierServiceRating' AND
                     abbr = carrier.car_rating),
             (SELECT MAX(cartype1) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype2) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype3) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype4) FROM labelfile_headers WITH (NOLOCK)),
             carrier.car_type1,
             carrier.car_type2,
             carrier.car_type3,
             carrier.car_type4,
             city.cty_nmstct,
             carrier.cty_code,
             city.cty_state,
             'Y',
             'N',
             'N',
             'N',
             'N',
             --PTS51809 MBR 04/27/10
             ISNULL(carrierhistory.crh_total, 0),
             ISNULL(carrierhistory.crh_ontime, 0),
             ISNULL(carrierhistory.crh_percent, 0),
             ISNULL(carrierhistory.crh_avefuel, 0),
             ISNULL(carrierhistory.crh_avetotal, 0),
             ISNULL(carrierhistory.crh_aveacc, 0)
        FROM carrier WITH (NOLOCK) JOIN city WITH (NOLOCK) ON carrier.cty_code = city.cty_code AND
                                        city.cty_state IN (SELECT origin_state
                                                             FROM #origin_states)
                                   LEFT OUTER JOIN carrierhistory WITH (NOLOCK) ON carrier.car_id = carrierhistory.crh_carrier
       WHERE carrier.car_id NOT IN (SELECT trk_carrier
                                      FROM #temp1) AND
             carrier.car_id IN (SELECT fcr_carrier
                                  FROM #temp_filteredcarriers)

   --PTS 49964 JJF 20091221 sqlserver2008 workaround
   --PTS51809 MBR 04/27/10 Added carrierhistory columns
   INSERT INTO #temp1 (trk_carrier, tar_number, car_name, car_address1, car_address2,
                       car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                       car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                       cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                       cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, 
                       dest_domicile, rateonfileorigin, preferred_lane, crh_total, 
                       crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
      SELECT trk_carrier, tar_number, car_name, car_address1, car_address2,
             car_scac, car_phone1, car_phone2, car_contact, car_phone3,
             car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
             cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
             cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, 
             dest_domicile, rateonfileorigin, preferred_lane, crh_total,
             crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc
        FROM #temp2

   DELETE FROM #temp2
   --END PTS 49964 JJF 20091221 sqlserver2008 workaround

END

IF @ll_dcity > 0
BEGIN
   UPDATE #temp1
      SET dest_domicile = 'Y'
    WHERE ((@dradius = 0 AND #temp1.cty_code = @ll_dcity) OR
           (@dradius > 0 AND #temp1.cty_code IN (SELECT cty_code
                                                   FROM #tempdest)))

	--PTS 49964 JJF 20091221 sqlserver2008 workaround
   --INSERT INTO #temp1 (trk_carrier, car_name, car_address1, car_address2,
   --PTS51809 MBR 04/27/10 Added carrierhistory columns
   INSERT INTO #temp2 (trk_carrier, car_name, car_address1, car_address2,
                       car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                       car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                       cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                       cty_nmstct, cty_code, cty_state, dest_domicile, orig_domicile,
                       haspaymenthist, rateonfileorigin, preferred_lane, crh_total,
                       crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
      SELECT carrier.car_id,
             ISNULL(carrier.car_name, ''),
             ISNULL(carrier.car_address1, ''),
             ISNULL(carrier.car_address2, ''),
             ISNULL(carrier.car_scac, ''),
             ISNULL(carrier.car_Phone1, ''),
             ISNULL(carrier.car_Phone2, ''),
             ISNULL(carrier.car_contact, ''),
             ISNULL(carrier.car_phone3, ''),
             ISNULL(carrier.car_email, ''),
             ISNULL(carrier.car_currency, ''),
             (SELECT name 
                FROM labelfile WITH (NOLOCK)
               WHERE labeldefinition = 'CarrierServiceRating' AND
                     abbr = carrier.car_rating),
             (SELECT MAX(cartype1) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype2) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype3) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype4) FROM labelfile_headers WITH (NOLOCK)),
             carrier.car_type1,
             carrier.car_type2,
             carrier.car_type3,
             carrier.car_type4,
             city.cty_nmstct,
             carrier.cty_code,
             city.cty_state,
             'Y',
             'N',
             'N',
             'N',
             'N',
             --PTS51809 MBR 04/27/10
             ISNULL(carrierhistory.crh_total, 0),
             ISNULL(carrierhistory.crh_ontime, 0),
             ISNULL(carrierhistory.crh_percent, 0),
             ISNULL(carrierhistory.crh_avefuel, 0),
             ISNULL(carrierhistory.crh_avetotal, 0),
             ISNULL(carrierhistory.crh_aveacc, 0)
        FROM carrier WITH (NOLOCK) JOIN city WITH (NOLOCK) ON carrier.cty_code = city.cty_code
                                   LEFT OUTER JOIN carrierhistory WITH (NOLOCK) ON carrier.car_id = carrierhistory.crh_carrier
       WHERE ((@dradius = 0 AND carrier.cty_code = @ll_dcity) OR
              (@dradius > 0 AND carrier.cty_code IN (SELECT cty_code 
                                                      FROM #tempdest))) AND
             carrier.car_id NOT IN (SELECT trk_carrier
                                      FROM #temp1) AND
             carrier.car_id IN (SELECT fcr_carrier
                                  FROM #temp_filteredcarriers)

   --PTS 49964 JJF 20091221 sqlserver2008 workaround
   --PTS51809 MBR 04/27/10 Added carrierhistory columns
   INSERT INTO #temp1 (trk_carrier, tar_number, car_name, car_address1, car_address2,
                       car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                       car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                       cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                       cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, 
                       dest_domicile, rateonfileorigin, preferred_lane, crh_total, 
                       crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
      SELECT trk_carrier, tar_number, car_name, car_address1, car_address2,
             car_scac, car_phone1, car_phone2, car_contact, car_phone3,
             car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
             cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
             cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, 
             dest_domicile, rateonfileorigin, preferred_lane, crh_total,
             crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc
        FROM #temp2

   DELETE FROM #temp2
   --END PTS 49964 JJF 20091221 sqlserver2008 workaround
                                  
END

IF @ll_dstates > 0
BEGIN
   UPDATE #temp1
      SET dest_domicile = 'Y'
    WHERE #temp1.cty_state IN (SELECT destination_state
                                 FROM #destination_states)

   --PTS 49964 JJF 20091221 sqlserver2008 workaround
   --INSERT INTO #temp1 (trk_carrier, car_name, car_address1, car_address2,
   --PTS51809 MBR 04/27/10 Added carrierhistory columns
   INSERT INTO #temp2 (trk_carrier, car_name, car_address1, car_address2,
                       car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                       car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                       cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                       cty_nmstct, cty_code, cty_state, dest_domicile, orig_domicile,
                       haspaymenthist, rateonfileorigin, preferred_lane, crh_total,
                       crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
      SELECT carrier.car_id,
             ISNULL(carrier.car_name, ''),
             ISNULL(carrier.car_address1, ''),
             ISNULL(carrier.car_address2, ''),
             ISNULL(carrier.car_scac, ''),
             ISNULL(carrier.car_Phone1, ''),
             ISNULL(carrier.car_Phone2, ''),
             ISNULL(carrier.car_contact, ''),
             ISNULL(carrier.car_phone3, ''),
             ISNULL(carrier.car_email, ''),
             ISNULL(carrier.car_currency, ''),
             (SELECT name 
                FROM labelfile WITH (NOLOCK)
               WHERE labeldefinition = 'CarrierServiceRating' AND
                     abbr = carrier.car_rating),
             (SELECT MAX(cartype1) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype2) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype3) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype4) FROM labelfile_headers WITH (NOLOCK)),
             carrier.car_type1,
             carrier.car_type2,
             carrier.car_type3,
             carrier.car_type4,
             city.cty_nmstct,
             carrier.cty_code,
             city.cty_state,
             'Y',
             'N',
             'N',
             'N',
             'N',
             --PTS51809 MBR 04/27/10
             ISNULL(carrierhistory.crh_total, 0),
             ISNULL(carrierhistory.crh_ontime, 0),
             ISNULL(carrierhistory.crh_percent, 0),
             ISNULL(carrierhistory.crh_avefuel, 0),
             ISNULL(carrierhistory.crh_avetotal, 0),
             ISNULL(carrierhistory.crh_aveacc, 0)
        FROM carrier WITH (NOLOCK) JOIN city WITH (NOLOCK) ON carrier.cty_code = city.cty_code AND
                                        city.cty_state IN (SELECT destination_state
                                                             FROM #destination_states)
                                   LEFT OUTER JOIN carrierhistory WITH (NOLOCK) ON carrier.car_id = carrierhistory.crh_carrier
       WHERE carrier.car_id NOT IN (SELECT trk_carrier
                                      FROM #temp1) AND
             carrier.car_id IN (SELECT fcr_carrier
                                  FROM #temp_filteredcarriers)

   --PTS 49964 JJF 20091221 sqlserver2008 workaround
   --PTS51809 MBR 04/27/10 Added carrierhistory columns
   INSERT INTO #temp1 (trk_carrier, tar_number, car_name, car_address1, car_address2,
                       car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                       car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                       cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                       cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, 
                       dest_domicile, rateonfileorigin, preferred_lane, crh_total, 
                       crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
      SELECT trk_carrier, tar_number, car_name, car_address1, car_address2,
             car_scac, car_phone1, car_phone2, car_contact, car_phone3,
             car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
             cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
             cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, 
             dest_domicile, rateonfileorigin, preferred_lane, crh_total,
             crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc
        FROM #temp2

   DELETE FROM #temp2
   --END PTS 49964 JJF 20091221 sqlserver2008 workaround
END

--If there is no origin or destination criteria, get all carriers from #temp_filteredcarriers
--that were not already inserted into #temp1 because of history detail.
IF @ll_ocity = 0 AND @ll_ostates = 0 AND @ll_dcity = 0 AND @ll_dstates = 0 
BEGIN
   --PTS 49964 JJF 20091221 sqlserver2008 workaround
   --INSERT INTO #temp1 (trk_carrier, car_name, car_address1, car_address2,
   --PTS51809 MBR 04/27/10 Added carrierhistory columns
   INSERT INTO #temp2 (trk_carrier, car_name, car_address1, car_address2,
	               car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                       car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                       cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                       cty_nmstct, cty_code, cty_state, dest_domicile, orig_domicile,
                       haspaymenthist, rateonfileorigin, preferred_lane, crh_total,
                       crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
      SELECT carrier.car_id,
             ISNULL(carrier.car_name, ''),
             ISNULL(carrier.car_address1, ''),
             ISNULL(carrier.car_address2, ''),
             ISNULL(carrier.car_scac, ''),
             ISNULL(carrier.car_Phone1, ''),
             ISNULL(carrier.car_Phone2, ''),
             ISNULL(carrier.car_contact, ''),
             ISNULL(carrier.car_phone3, ''),
             ISNULL(carrier.car_email, ''),
             ISNULL(carrier.car_currency, ''),
             (SELECT name 
                FROM labelfile WITH (NOLOCK)
               WHERE labeldefinition = 'CarrierServiceRating' AND
                     abbr = carrier.car_rating),
             (SELECT MAX(cartype1) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype2) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype3) FROM labelfile_headers WITH (NOLOCK)),
             (SELECT MAX(cartype4) FROM labelfile_headers WITH (NOLOCK)),
             carrier.car_type1,
             carrier.car_type2,
             carrier.car_type3,
             carrier.car_type4,
             city.cty_nmstct,
             carrier.cty_code,
             city.cty_state,
             'N',
             'N',
             'N',
             'N',
             'N',
             --PTS51809 MBR 04/27/10
             ISNULL(carrierhistory.crh_total, 0),
             ISNULL(carrierhistory.crh_ontime, 0),
             ISNULL(carrierhistory.crh_percent, 0),
             ISNULL(carrierhistory.crh_avefuel, 0),
             ISNULL(carrierhistory.crh_avetotal, 0),
             ISNULL(carrierhistory.crh_aveacc, 0)
        FROM carrier WITH (NOLOCK) JOIN city WITH (NOLOCK) ON carrier.cty_code = city.cty_code
                                   LEFT OUTER JOIN carrierhistory WITH (NOLOCK) ON carrier.car_id = carrierhistory.crh_carrier
       WHERE carrier.car_id NOT IN (SELECT trk_carrier
                                      FROM #temp1) AND
             carrier.car_id IN (SELECT fcr_carrier
                                  FROM #temp_filteredcarriers)
                                  
   --PTS 49964 JJF 20091221 sqlserver2008 workaround
   --PTS51809 MBR 04/27/10 Added carrierhistory columns
   INSERT INTO #temp1 (trk_carrier, tar_number, car_name, car_address1, car_address2,
                       car_scac, car_phone1, car_phone2, car_contact, car_phone3,
                       car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
                       cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
                       cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, 
                       dest_domicile, rateonfileorigin, preferred_lane, crh_total, 
                       crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc)
      SELECT  trk_carrier, tar_number, car_name, car_address1, car_address2,
              car_scac, car_phone1, car_phone2, car_contact, car_phone3,
              car_email, car_currency, car_rating, cartype1_t, cartype2_t, 
              cartype3_t, cartype4_t, car_type1, car_type2, car_type3, car_type4, 
              cty_nmstct, cty_code, cty_state, haspaymenthist, orig_domicile, 
              dest_domicile, rateonfileorigin, preferred_lane, crh_total,
              crh_ontime, crh_percent, crh_avefuel, crh_avetotal, crh_aveacc
        FROM #temp2

   DELETE FROM #temp2
   --END PTS 49964 JJF 20091221 sqlserver2008 workaround

END

IF @stp_start_dt = '1950-01-01 00:00:00'
SET @stp_start_dt = GETDATE()

update #temp1
   set car_exp1date = car_exp1_date,
       car_exp2date = car_exp2_date
  from carrier WITH (NOLOCK)
 where carrier.car_id = #temp1.trk_carrier

UPDATE #temp1
   SET pri1expsoon = CASE WHEN car_exp1date <= dateadd(dd, @expdate, getdate()) 
                             THEN 1
                          ELSE 0
                      END,
       pri2expsoon = CASE WHEN car_exp2date <= dateadd(dd, @expdate, getdate()) 
                             THEN 1
                          ELSE 0
                     END

DECLARE @trk_carrier varchar(8)
DECLARE carrier_cursor CURSOR FAST_FORWARD FOR   

SELECT trk_carrier  
FROM #temp1
  
OPEN carrier_cursor  
  
FETCH NEXT FROM carrier_cursor   
INTO @trk_carrier 
  
WHILE @@FETCH_STATUS = 0  
BEGIN                      
	IF  (select count(0) from expiration with (nolock) 
		where exp_id = @trk_carrier 
			and exp_idtype = 'CAR'
			and exp_priority = 1  
			and exp_completed = 'N'  
			and @stp_start_dt > exp_expirationdate) > 0
		update #temp1 set exp_priority1 = 2 WHERE trk_carrier = @trk_carrier
	ELSE IF (select count(0) from expiration with (nolock)  
		where exp_idtype = 'CAR'  
			and exp_id = @trk_carrier  
			and exp_priority = 1  
			and exp_completed = 'N'  
			and @stp_start_dt > dateadd(dd, - @expdate, exp_expirationdate)) > 0
		update #temp1 set exp_priority1 = 1 WHERE trk_carrier = @trk_carrier
	ELSE
		update #temp1 set exp_priority1 = 0 WHERE trk_carrier = @trk_carrier

	IF  (select count(0) from expiration with (nolock)  
		where exp_id = @trk_carrier 
			and exp_idtype = 'CAR' 
			and exp_priority > 1  
			and exp_completed = 'N'  
			and @stp_start_dt > exp_expirationdate) > 0
		update #temp1 set exp_priority2 = 1 WHERE trk_carrier = @trk_carrier
	ELSE
		update #temp1 set exp_priority2 = 0 WHERE trk_carrier = @trk_carrier

	 FETCH NEXT FROM carrier_cursor INTO @trk_carrier
END 

CLOSE carrier_cursor  
DEALLOCATE carrier_cursor                     

--PTS 49332 JJF 20091008
UPDATE	#temp1
SET distance_to_origin = dbo.tmw_airdistance_fn(@orig_lat, @orig_long, fcr_dom_lat, fcr_dom_long),
	distance_to_destination = dbo.tmw_airdistance_fn(@dest_lat, @dest_long, fcr_dom_lat, fcr_dom_long) 
FROM #temp1 result INNER JOIN #temp_filteredcarriers fcr on result.trk_carrier = fcr.fcr_carrier
--END PTS 49332 JJF 20091008

--PTS 51918 JJF 20110210
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
																last_used_date, 
																last_used_date,
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
																last_used_date, 
																last_used_date,
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
																last_used_date, 
																last_used_date,
																@IncludeAssetPrefix,
																@IncludeLabelName,
																@Delimiter
															)
															

															
															
	FROM #temp1 
END 
--END PTS 51918 JJF 20110210

--PTS62447 MBR 05/02/12 See which carriers meet the load requirements for the passed in lgh_number
IF @lgh_number > 0
BEGIN
   UPDATE #temp1 
      SET load_requirements = 'N'

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
   ELSE
   BEGIN
      UPDATE #temp1
         SET load_requirements = 'Y'
   END
END
ELSE
BEGIN
   UPDATE #temp1
      SET load_requirements = 'Y'
END

--PTS62466 MBR 07/13/12 Look for offers for any of the carriers if the lgh_number passed in is > 0
IF @lgh_number > 0
BEGIN
   DECLARE @revenue MONEY
   SET @revenue = 0
   If EXISTS (SELECT 1 FROM invoicedetail WHERE ord_hdrnumber=@ord_hdrnumber)
		SET @revenue = (SELECT SUM(ivd_charge) FROM invoicedetail WHERE ord_hdrnumber=@ord_hdrnumber)
		
   UPDATE #temp1
      SET offer = 'Y',
          offer_linehaul = cb.cb_reply_linehaul,
          offer_fuel = cb.cb_reply_fuelamount,
          offer_other = cb.cb_reply_otheramount,
          offer_amount = cb.cb_reply_amount,
          offer_contact = cb.cb_contact,
          offer_award_status = cb.cb_award_status,
          offer_margin = (@revenue - cb.cb_reply_amount),
          offer_margin_percent = (CASE WHEN @revenue > 0 THEN ((@revenue - cb.cb_reply_amount) / @revenue) * 100 ELSE 0 END),
          offer_user = cb.created_user
     FROM carrierbids cb JOIN carrierauctions ca ON cb.ca_id = ca.ca_id AND
                              ca.lgh_number = @lgh_number
    WHERE cb.car_id = #temp1.trk_carrier AND
          cb.cb_id = (SELECT MAX(cb_id) 
                        FROM carrierbids cb JOIN carrierauctions ca ON cb.ca_id = ca.ca_id AND
                                                 ca.lgh_number = @lgh_number 
                       WHERE cb.car_id = #temp1.trk_carrier)
END



DECLARE @IsCarrierContacts AS CHAR(1)

SELECT	@IsCarrierContacts = ISNULL(gi_string1, 'N')		
FROM	generalinfo
WHERE gi_name = 'CarrierMgmtSystem'

IF @IsCarrierContacts ='Y'
	BEGIN
--PTS 82374
	Update #temp1
	SET
	car_phone1 = CASE WHEN ISNULL(car_phone1,'') = '' THEN(SELECT Top 1 cc_phone1 FROM carriercontacts ce WHERE ce.car_id = #temp1.trk_carrier  and cc_default_carrier_addr = 'Y')ELSE car_phone1 END ,
	car_phone2 =CASE WHEN ISNULL(car_phone2,'') = '' THEN (SELECT Top 1 cc_phone2 FROM carriercontacts ce WHERE ce.car_id = #temp1.trk_carrier  and cc_default_carrier_addr = 'Y') ELSE car_phone2 END,
	car_phone3 = CASE WHEN ISNULL(car_phone3,'') = '' THEN(SELECT Top 1 cc_cell FROM carriercontacts ce WHERE ce.car_id = #temp1.trk_carrier  and cc_default_carrier_addr = 'Y')ELSE car_phone3 END ,
	car_email =  CASE WHEN ISNULL(car_email,'') = '' THEN(SELECT Top 1 cc_email FROM carriercontacts ce WHERE ce.car_id = #temp1.trk_carrier  and cc_default_carrier_addr = 'Y') ELSE car_email END,
	car_contact = CASE WHEN ISNULL(car_contact,'') = '' THEN (SELECT Top 1 cc_lname FROM carriercontacts ce WHERE ce.car_id =#temp1.trk_carrier  and cc_default_carrier_addr = 'Y') ELSE car_contact END,
	defaultContactFirstName = COALESCE((SELECT Top 1 cc_fname FROM carriercontacts ce WHERE ce.car_id = #temp1.trk_carrier  and cc_default_carrier_addr = 'Y'), ''),
	defaultContactLastName = COALESCE((SELECT Top 1 cc_lname FROM carriercontacts ce WHERE ce.car_id = #temp1.trk_carrier  and cc_default_carrier_addr = 'Y'), '')
----PTS 53571 KMM/JJF 20100818 - DON'T RETURN RESULTS IF THERE IS ZERO CRITERIA
	END
ELSE
	BEGIN
	Update #temp1
	SET
	car_phone1 = CASE WHEN ISNULL(car_phone1,'') = '' THEN(SELECT Top 1 ce_phone1 FROM companyemail WHERE cmp_id = #temp1.trk_carrier and ce_defaultcontact = 'Y' and ce_source = 'CAR') ELSE car_phone1 END,
	car_phone2 = CASE WHEN ISNULL(car_phone2,'') = '' THEN (SELECT Top 1 ce_phone2 FROM companyemail WHERE cmp_id = #temp1.trk_carrier  and ce_defaultcontact = 'Y' and ce_source = 'CAR') ELSE car_phone2 END,
	car_phone3 = CASE WHEN ISNULL(car_phone3,'') = '' THEN (SELECT Top 1 ce_mobilenumber FROM companyemail WHERE cmp_id = #temp1.trk_carrier  and ce_defaultcontact = 'Y' and ce_source = 'CAR') ELSE car_phone3 END,
	car_email = CASE WHEN ISNULL(car_email,'') = '' THEN (SELECT Top 1 email_address FROM companyemail WHERE cmp_id = #temp1.trk_carrier  and ce_defaultcontact = 'Y' and ce_source = 'CAR') ELSE car_email END,
	car_contact = CASE WHEN ISNULL(car_contact,'') = '' THEN (SELECT Top 1 contact_name FROM companyemail WHERE cmp_id =#temp1.trk_carrier  and ce_defaultcontact = 'Y' and ce_source = 'CAR') ELSE car_contact END,
	defaultContactFirstName = COALESCE((SELECT Top 1 ce_fname FROM companyemail WHERE cmp_id =#temp1.trk_carrier  and ce_defaultcontact = 'Y' and ce_source = 'CAR'), ''),
	defaultContactLastName = COALESCE((SELECT Top 1 contact_name FROM companyemail WHERE cmp_id =#temp1.trk_carrier  and ce_defaultcontact = 'Y' and ce_source = 'CAR'), '')
	END


--PTS 53571 KMM/JJF 20100818 - DON'T RETURN RESULTS IF THERE IS ZERO CRITERIA

ENDPROC:
-- End PTS 87096 PR

SELECT ISNULL(trk_number,'') trk_number, 
       ISNULL(tar_number,0) tar_number,
       ISNULL(tar_rate,0) tar_rate, 
       ISNULL(trk_carrier,'') trk_carrier,
       ISNULL(Crh_Total,0) crh_total,
       ISNULL(Crh_OnTime,0) crh_ontime,
       ISNULL(cht_itemcode,'') cht_itemcode,
       ISNULL(cht_description,'') cht_description,
       ISNULL(crh_percent,'') crh_percent,
       ISNULL(Crh_AveFuel,0) crh_avefuel,
       ISNULL(Crh_AveTotal,0) crh_avetotal,
       ISNULL(Crh_AveAcc,0) crh_aveacc,
       ISNULL(car_name,'') car_name,
       ISNULL(car_address1,'') car_address1,
       ISNULL(car_address2,'') car_address2,
       ISNULL(car_scac,'') car_scac,
       ISNULL(car_phone1,'') car_phone1,
       ISNULL(car_phone2,'') car_phone2,
       ISNULL(car_contact,'') car_contact,
	   defaultContactFirstName,
	   defaultContactLastName,
       ISNULL(car_phone3,'') car_phone3,
       ISNULL(car_email,'') car_email,
       ISNULL(car_currency, '') car_currency,
       ISNULL(cht_currunit, '') cht_currunit,
       ISNULL(car_rating, '') car_rating,
       ISNULL(exp_priority1, 0) exp_priority1,		
       ISNULL(exp_priority2, 0) exp_priority2,
       ISNULL(cty_nmstct, 0) cty_nmstct,
       ISNULL(totalordersfiltered, 0) totalordersfiltered,
       ISNULL(ontimeordersfiltered, 0) ontimeordersfiltered,
       ISNULL(percentontimefiltered, 0) percentontimefiltered,
       ISNULL(orig_domicile, '') orig_domicile,
       ISNULL(dest_domicile, '') dest_domicile,
       ISNULL(rateonfileorigin, '') rateonfileorigin, 
       ISNULL(rateonfiledest, '') rateonfiledest, 
       ISNULL(haspaymenthist, '') haspaymenthist, 
       ISNULL(PayHistAtOrigin, '') payhistatorigin, 
       ISNULL(PayHistAtDest, '') payhistatdest,
       ISNULL(MatchResult, '') matchresult, 
       ISNULL(RatePaidAtOrigin, '') ratepaidatorigin,
       ISNULL(RatePaidAtDest, '') ratepaidatdest, 
       ISNULL(cartype1_t, 'Car Type1') cartype1_t,
       ISNULL(cartype2_t, 'Car Type2') cartype2_t,
       ISNULL(cartype3_t, 'Car Type3') cartype3_t,
       ISNULL(cartype4_t, 'Car Type4') cartype4_t,
       ISNULL(car_type1, 'UNK') car_type1,
       ISNULL(car_type2, 'UNK') car_type2,
       ISNULL(car_type3, 'UNK') car_type3,
       ISNULL(car_type4, 'UNK') car_type4,
       ISNULL(pri1expsoon, 0)		pri1expsoon,
       ISNULL(pri2expsoon,0)		pri2expsoon,
       last_chd_id,
       --PTS 53884 JJF 20100928 set date to max so that real dates bubble to the top for sorting
       --last_used_date,
       isnull(last_used_date, '19500101') as last_used_date,
       --PTS 53884 JJF 20100928 set date to max so that real dates bubble to the top for sorting
       ISNULL(last_billed, 0) last_billed,
       ISNULL(last_paid, 0) last_paid,
       ISNULL(total_billed, 0) total_billed,
       ISNULL(pay_linehaul, 0) pay_linehaul,
       ISNULL(pay_accessorial, 0) pay_accessorial,
       ISNULL(pay_fsc, 0) pay_fsc,
       cty_code,
       cty_state,
       ISNULL(total_trips, 0) total_trips,
       ISNULL(total_late, 0) total_late,
       min_chd_id,
       ISNULL(min_billed, 0) min_billed,
       ISNULL(min_paid, 0) min_paid,
       max_chd_id,
       ISNULL(max_billed, 0) max_billed,
       ISNULL(max_paid, 0) max_paid,
       CASE WHEN crh_total <> 0 THEN ISNULL(ROUND((CAST(crh_ontime AS MONEY)/CAST(crh_total AS MONEY)), 4), 0)
            ELSE 0
       END history_ontime,
       CASE WHEN total_trips <> 0 THEN ISNULL(ROUND(((CAST(total_trips AS MONEY) - CAST(total_late AS MONEY))/CAST(total_trips AS MONEY)), 4), 0)
            ELSE 0
       END on_time_percent,
       ISNULL(total_trips - total_late, 0) on_time,
       CASE WHEN total_trips <> 0 THEN ISNULL(ROUND((pay_linehaul/total_trips), 2), 0) 
            ELSE 0
       END avg_total,
       CASE WHEN total_trips <> 0 THEN ISNULL(ROUND((pay_fsc/total_trips), 2), 0)
            ELSE 0
       END avg_fuel,
       CASE WHEN total_trips <> 0 THEN ISNULL(ROUND((pay_accessorial/total_trips), 2), 0)
            ELSE 0
       END avg_acc,
       CASE WHEN last_billed <> 0 THEN ISNULL(ROUND(((last_billed - last_paid)/last_billed), 4), 0)
            ELSE 0
       END last_margin_percent,
       ISNULL(ROUND((last_billed - last_paid), 2), 0) last_margin_amount,
       CASE WHEN total_billed <> 0 THEN ISNULL(ROUND(((total_billed - (pay_linehaul + pay_accessorial + pay_fsc))/total_billed), 4), 0)
            ELSE 0
       END lane_margin_percent,
       ISNULL(ROUND(total_billed - (pay_linehaul + pay_accessorial + pay_fsc), 2), 0) lane_margin_amount,
       ISNULL((pay_linehaul + pay_accessorial + pay_fsc), 0) total_paid,
		min_margin_percent, /*PTS 57012 CGK 3/31/2010*/ 
--       CASE WHEN min_billed <> 0 THEN ISNULL(ROUND(((min_billed - min_paid)/min_billed), 4), 0)
--            ELSE 0
--       END min_margin_percent,
		min_margin_amount,       /*PTS 57012 CGK 3/31/2010*/ 
--		ISNULL(ROUND((min_billed - min_paid), 2), 0) min_margin_amount,	
		max_margin_percent,       /*PTS 57012 CGK 3/31/2010*/ 
--       CASE WHEN max_billed <> 0 THEN ISNULL(ROUND(((max_billed - max_paid)/max_billed), 4), 0)
--            ELSE 0
--       END max_margin_percent,
		max_margin_amount,       /*PTS 57012 CGK 3/31/2010*/ 
--       ISNULL(ROUND((max_billed - max_paid), 2), 0) max_margin_amount,
        ISNULL(distance_to_origin, 0) as distance_to_origin,
       ISNULL(distance_to_destination, 0) as distance_to_destination,
       ISNULL(preferred_lane, '') preferred_lane,
       qualification_list_drv,
       qualification_list_trc,
       qualification_list_trl,
       ISNULL(load_requirements, 'N') load_requirements,
       ISNULL(offer, 'N') offer,
       offer_linehaul,
       offer_fuel,
       offer_other,
       offer_amount, 
       offer_contact,
       offer_award_status,
       offer_margin,
	   offer_margin_percent,
	   offer_user,
	   car_exp1date,
       car_exp2date

  FROM #temp1	
 WHERE #temp1.trk_carrier IN (SELECT car_id 
                                FROM carrier WITH (NOLOCK) 
								--PTS 53571 KMM/JJF 20100818 add car_id unknown to return empty result message
                               WHERE car_status <> 'OUT' OR car_id = 'UNKNOWN')
	
GO
GRANT EXECUTE ON  [dbo].[carrier_search_sp] TO [public]
GO
