SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [dbo].[d_hourly_input_sp] (@p_start AS DATETIME, @p_end AS DATETIME, 
	@p_drvtype1 AS VARCHAR(6), @p_drvtype2 AS VARCHAR(6), @p_drvtype3 AS VARCHAR(6), @p_drvtype4 AS VARCHAR(6), 
	@p_fleet AS VARCHAR(6), @p_company AS VARCHAR(6), @p_division AS VARCHAR(6), @p_terminal AS VARCHAR(6), @alt AS CHAR(1),
	@p_trctype1 AS VARCHAR(6), @p_trctype2 AS VARCHAR(6), @p_trctype3 AS VARCHAR(6), @p_trctype4 AS VARCHAR(6),
	@p_itemcode AS VARCHAR(6), @p_mppid AS VARCHAR(8), @p_trcnumber AS VARCHAR(8), @p_reftype AS VARCHAR(6), @p_includepaiditems AS CHAR(1), 
    @p_trlnumber AS VARCHAR(8), @p_trltype1 AS VARCHAR(6), @p_trltype2 AS VARCHAR(6), @p_trltype3 AS VARCHAR(6), @p_trltype4 AS VARCHAR(6),
	@brn_id varchar(256),	 -- PTS 41375 GAP 64/82 add branch id
	@G_USERID varchar(14),   -- PTS 41375 GAP 64/82 add user id
	@pyd_status varchar(6),  -- PTS 41375 GAP 64/82 add paydetail status
	@pyd_refnum varchar(30),  -- PTS 41375 GAP 64/82 add paydetail ref number.
	@p_tpr_id varchar(8)	 -- PTS 41375 GAP 64/82 add ThirdParty (will PROBABLY be asked for...)	
)
AS
/*
*   11/04/05  PTS 30489  DPETE Bad data is resulting in error 'attempt to insert null value'  Add cks
*                        to WHERE clause so NULL data is not processed
* vjh pts30624 add pyd_vendorpay
*   07/13/07  PTS 36914  SLM Add Trailer information *** Add @p_trlnumber, @p_trltype1, @p_trltype2, @p_trltype3, @p_trltype4 as arguments
* PTS 41375 GAP 64/82 4/22/2008 JSwindell - Add Branch, Third party and billable Y/N processing.
* PTS 41375 GAP 64/82 5/27/2008 JSwindell - Bug fix.
*	LOR	PTS# 41366	added pyt_otflag, pyt_basisunit
* PTS 55737 SPN - added pyd_clock_start and pyd_clock_end
* PTS 58334 SPN - added pyd_lghtype1
* 05/15/2014 NQIAO PTS76582 - add 3 new fields for the inputs: pyd_fixedrate, pyd_fixedamount
* 02/15/2015 NQIAO PTS63702 - add 3 new fields for the outputs: pyd_orig_currency, pyd_orig_amount, pyd_cex_rate
*/

-- PTS 41375 GAP 64/82 Start
IF @brn_id is NULL or @brn_id = '' or @brn_id  = 'UNK' or @brn_id  =  'UNKNOW'	
	begin
		SELECT @brn_id = 'UNKNOWN'	
	end 
IF @pyd_status is NULL or @pyd_status = '' or @pyd_status = 'UNK' or @pyd_status =  'UNKNOW'	
	begin
		SELECT @pyd_status = 'UNKNOWN'	
	end
IF @pyd_refnum is Null or @pyd_refnum = '' or @pyd_refnum = 'UNK' or @pyd_refnum =  'UNKNOW'	
	begin 
		SELECT @pyd_refnum = 'UNKNOWN'
	end
IF @p_tpr_id is Null or @p_tpr_id = '' or @p_tpr_id = 'UNK' or @p_tpr_id =  'UNKNOW'	
	begin 
		SELECT @p_tpr_id = 'UNKNOWN'
	end


SELECT @brn_id = ',' + LTRIM(RTRIM(ISNULL(@brn_id, '')))  + ','
-- PTS 41375 GAP 64/82 end

DECLARE @cartype1 varchar(25),
        @cartype2 varchar(25),
        @cartype3 varchar(25),
        @cartype4 varchar(25),
        @mpptype1 varchar(25),
        @mpptype2 varchar(25),
        @mpptype3 varchar(25),
        @mpptype4 varchar(25),
        @trctype1 varchar(25),
        @trctype2 varchar(25),
        @trctype3 varchar(25),
        @trctype4 varchar(25), 
        @driver varchar(8),
        @trltype1 varchar(25), --PTS 36914
        @trltype2 varchar(25), --PTS 36914
        @trltype3 varchar(25), --PTS 36914
        @trltype4 varchar(25)  --PTS 36914

SELECT DISTINCT @cartype1 = userlabelname 
  FROM labelfile 
 WHERE labeldefinition = 'CarType1'
SELECT DISTINCT @cartype2 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'CarType2'
SELECT DISTINCT @cartype3 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'CarType3'
SELECT DISTINCT @cartype4 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'CarType4'
SELECT DISTINCT @mpptype1 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'DrvType1'
SELECT DISTINCT @mpptype2 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'DrvType2'
SELECT DISTINCT @mpptype3 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'DrvType3'
SELECT DISTINCT @mpptype4 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'DrvType4'
SELECT DISTINCT @trctype1 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'TrcType1'
SELECT DISTINCT @trctype2 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'TrcType2'
SELECT DISTINCT @trctype3 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'TrcType3'
SELECT DISTINCT @trctype4 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'TrcType4'

--PTS 36914  SLM Add Trailer information
SELECT DISTINCT @trltype1 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'TrlType1'
SELECT DISTINCT @trltype2 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'TrlType2'
SELECT DISTINCT @trltype3 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'TrlType3'
SELECT DISTINCT @trltype4 = userlabelname
  FROM labelfile 
 WHERE labeldefinition = 'TrlType4'

CREATE TABLE #paydetail
   (pyd_number       INT NOT NULL, 
    pyh_number       INT NOT NULL,   
    lgh_number       INT NOT NULL,   
    asgn_number      INT NOT NULL,   
    asgn_type        VARCHAR(6) NOT NULL,   
    asgn_id          VARCHAR(13) NOT NULL,   
    pyd_prorap       CHAR(1) NOT NULL,   
    pyd_payto        VARCHAR(12) NOT NULL,   
    pyt_itemcode     VARCHAR(6) NOT NULL,   
    mov_number       INT NOT NULL,   
    pyd_description  VARCHAR(75) NULL,   
    pyr_ratecode     VARCHAR(6) NULL,   
    pyd_quantity     FLOAT NULL,   
    pyd_rateunit     VARCHAR(6) NULL,   
    pyd_unit         VARCHAR(6) NULL,   
    pyd_rate         MONEY NULL,   
    pyd_amount       MONEY NULL,   
    pyd_pretax       CHAR(1) NULL,   
    pyd_glnum        VARCHAR(66) NULL,   
    pyd_currency     VARCHAR(6) NULL,   
    pyd_currencydate DATETIME NULL,   
    pyd_status       VARCHAR(6) NULL,   
    pyd_refnumtype   VARCHAR(6) NULL,   
    pyd_refnum       VARCHAR(128) NULL,   
    pyh_payperiod    DATETIME NULL,   
    pyd_workperiod   DATETIME NULL,   
    pyd_transdate    DATETIME NULL,   
    pyd_minus        INT NULL,   
    pyd_loadstate    VARCHAR(6) NULL,   
    pyd_sequence     INT NULL,   
    pyt_fee1         MONEY NULL,   
    pyt_fee2         MONEY NULL,   
    pyd_grossamount  MONEY NULL,   
    pyd_updatedby    CHAR(20) NULL,   
    pyd_updatedon    DATETIME NULL,   
    psd_id           INT NULL,
    mpp_teamleader   VARCHAR(6) NULL,
    mpp_domicile     VARCHAR(6) NULL,
    mpp_company      VARCHAR(6) NULL,
    mpp_division     VARCHAR(6) NULL,
    mpp_fleet        VARCHAR(6) NULL,
    mpp_terminal     VARCHAR(6) NULL,
    mpp_type1        VARCHAR(6) NULL,
    mpp_type2        VARCHAR(6) NULL,
    mpp_type3        VARCHAR(6) NULL,
    mpp_type4        VARCHAR(6) NULL,
    trc_company      VARCHAR(6) NULL,
    trc_division     VARCHAR(6) NULL,
    trc_fleet        VARCHAR(6) NULL,
    trc_terminal     VARCHAR(6) NULL,
    trc_type1        VARCHAR(6) NULL,
    trc_type2        VARCHAR(6) NULL,
    trc_type3        VARCHAR(6) NULL,
    trc_type4        VARCHAR(6) NULL, 
    car_type1        VARCHAR(6) NULL,
    car_type2        VARCHAR(6) NULL,
    car_type3        VARCHAR(6) NULL,
    car_type4        VARCHAR(6) NULL, 
    ord_number       VARCHAR(12) NULL, 
    ord_hdrnumber    INT NULL, 
    std_number_adj   INT NULL, 
    pyd_vendortopay  VARCHAR(12) NULL, 
    cht_itemcode	 VARCHAR(6) NULL, 
    pyd_updsrc		 CHAR(1) NULL,
    pyd_vendorpay	 CHAR(1) NULL,
    trl_type1        VARCHAR(6) NULL,--PTS 36914  SLM Add Trailer information
    trl_type2        VARCHAR(6) NULL,--PTS 36914  SLM Add Trailer information
    trl_type3        VARCHAR(6) NULL,--PTS 36914  SLM Add Trailer information
    trl_type4        VARCHAR(6) NULL, --PTS 36914  SLM Add Trailer information
	ord_booked_revtype1  varchar(12) NULL,		-- PTS 41375 GAP 64/82 
	calc_billable_y_n	 VARCHAR(1) NULL,		-- PTS 41375 GAP 64/82	
	calc_bill_code		 VARCHAR(6) NULL, 		-- PTS 41375 GAP 64/82 	
	bill_override		 varchar(1) null,		-- PTS 41375 GAP 64/82 	
	not_billed_reason	 varchar(256) null,		-- PTS 41375 GAP 64/82 	
	tar_tarriffnumber	 varchar(12) NULL, 		-- PTS 41375 GAP 64/82 	
	pyt_otflag char(1) null,
	pyt_basisunit	varchar(6) null
	, pyd_clock_start datetime null			-- PTS 55737 SPN
	, pyd_clock_end	datetime null			-- PTS 55737 SPN
	, pyd_lghtype1		varchar(6) null,	-- PTS 58334 SPN
	pyd_fixedrate		char(1)	NULL,		-- 76582
	pyd_fixedamount		char(1)	NULL,		-- 76582
	pyd_orig_currency	varchar(6) NULL,	-- 63702
	pyd_orig_amount		money NULL,			-- 63702
	pyd_cex_rate		money NULL			-- 63702
	)

IF @p_reftype IS NULL OR RTRIM(@p_reftype) = ''
  SET @p_reftype = 'UNK'
IF @p_includepaiditems IS NULL
  SET @p_includepaiditems = 'N'

-- scrub fields with null data that should have a default (pyh_number)
update paydetail 
   set pyh_number = 0 
 where pyh_number is NULL and 
       pyd_transdate between @p_start and @p_end

-- scrub fields with null data that should have a default (asgn_number)
update paydetail 
   set asgn_number = 0 
 where asgn_number is NULL and 
       pyd_transdate between @p_start and @p_end

-- scrub fields with null data that should have a default (lgh_number)
update paydetail 
   set lgh_number = 0 
 where lgh_number is NULL and 
       pyd_transdate between @p_start and @p_end

-- scrub fields with null data that should have a default (mov_number)
update paydetail 
   set mov_number = 0 
 where mov_number is NULL and 
       pyd_transdate between @p_start and @p_end

-- scrub fields with null data that should have a default (ord_hdrnumber)
update paydetail 
   set ord_hdrnumber = 0 
 where ord_hdrnumber is NULL and 
       pyd_transdate between @p_start and @p_end

-- scrub fields with null data that should have a default (pyd_prorap and pyd_payto for driver)
update paydetail 
   set pyd_prorap = mpp_actg_type, 
       pyd_payto = mpp_payto 
  from manpowerprofile
 where asgn_type = 'DRV' and 
       mpp_id = asgn_id and 
       (pyd_prorap is NULL or 
        pyd_payto is NULL) and 
       pyd_transdate between @p_start and @p_end 

-- scrub fields with null data that should have a default (pyd_prorap and pyd_payto for tractor)
update paydetail 
   set pyd_prorap = trc_actg_type, 
       pyd_payto = trc_owner
  from tractorprofile
 where asgn_type = 'TRC' and 
       trc_number = asgn_id and 
       (pyd_prorap is NULL or 
        pyd_payto is NULL) and 
       pyd_transdate between @p_start and @p_end 

-- scrub fields with null data that should have a default (pyd_prorap and pyd_payto for carrier)
update paydetail 
   set pyd_prorap = car_actg_type, 
       pyd_payto = pto_id 
  from carrier
 where asgn_type = 'CAR' and 
       car_id = asgn_id and 
       (pyd_prorap is NULL or 
        pyd_payto is NULL) and 
       pyd_transdate between @p_start and @p_end 

-- PTS 36914  SLM Add Trailer information
-- scrub fields with null data that should have a default (pyd_prorap and pyd_payto for carrier)
update paydetail 
   set pyd_prorap = trl_actg_type, 
       pyd_payto = trl_owner 
  from trailerprofile
 where asgn_type = 'TRL' and 
       trl_number = asgn_id and 
       (pyd_prorap is NULL or 
        pyd_payto is NULL) and 
       pyd_transdate between @p_start and @p_end 

-- scrub fields with null data that should have a default (asgn_id)
update paydetail 
   set asgn_id = '' 
 where asgn_id is NULL and 
       pyd_transdate between @p_start and @p_end

-- scrub fields with null data that should have a default (asgn_type)
update paydetail 
   set asgn_type = '' 
 where asgn_type is NULL and 
       pyd_transdate between @p_start and @p_end

----------------set rowcount 1500  REMOVED THIS for PTS 41375 GAP 64/82 4/22/2008 JSwindell - if it's here I get NO DATA.

-- PTS 41375 GAP 64/82 	Add bill_override, not_billed_reason, tar_tarriffnumber (ADD Third Party to where clauses)
INSERT INTO #paydetail (pyd_number, pyh_number, lgh_number, asgn_number, asgn_type, asgn_id, pyd_prorap, pyd_payto, pyt_itemcode, mov_number,   
                        pyd_description, pyr_ratecode, pyd_quantity, pyd_rateunit, pyd_unit, pyd_rate, pyd_amount, pyd_pretax, pyd_glnum,   
                        pyd_currency, pyd_currencydate, pyd_status, pyd_refnumtype, pyd_refnum, pyh_payperiod, pyd_workperiod, pyd_transdate, 
                        pyd_minus, pyd_loadstate, pyd_sequence, pyt_fee1, pyt_fee2, pyd_grossamount, pyd_updatedby, pyd_updatedon, psd_id, ord_hdrnumber, 
                        cht_itemcode, pyd_updsrc, std_number_adj, pyd_vendorpay,
						bill_override, not_billed_reason, tar_tarriffnumber, pyt_otflag
						-- BEGIN PTS 55737 SPN
							, pyd_clock_start
							, pyd_clock_end
						-- END PTS 55737 SPN
						-- BEGIN PTS 58334 SPN
						, pyd_lghtype1,
						-- END PTS 58334 SPN
						pyd_fixedrate, pyd_fixedamount,	-- 76582					
						pyd_orig_currency, pyd_orig_amount, pyd_cex_rate	-- 63702
						)
     SELECT pd.pyd_number, pd.pyh_number, pd.lgh_number, pd.asgn_number, pd.asgn_type, pd.asgn_id, pd.pyd_prorap, pd.pyd_payto, pd.pyt_itemcode, pd.mov_number, 
            pd.pyd_description, pd.pyr_ratecode, pd.pyd_quantity, pd.pyd_rateunit, pd.pyd_unit, pd.pyd_rate, pd.pyd_amount, pd.pyd_pretax, pd.pyd_glnum, 
            pd.pyd_currency, pd.pyd_currencydate, pd.pyd_status, pd.pyd_refnumtype, pd.pyd_refnum, pd.pyh_payperiod, pd.pyd_workperiod, pd.pyd_transdate, 
            pd.pyd_minus, pd.pyd_loadstate, pd.pyd_sequence, pd.pyt_fee1, pd.pyt_fee2, pd.pyd_grossamount, pd.pyd_updatedby, pd.pyd_updatedon, pd.psd_id, pd.ord_hdrnumber, 
            pd.cht_itemcode, pd.pyd_updsrc, std_number_adj, pyd_vendorpay, bill_override, not_billed_reason, pd.tar_tarriffnumber, pd.pyt_otflag	 
						-- BEGIN PTS 55737 SPN
							, pd.pyd_clock_start
							, pd.pyd_clock_end
						-- END PTS 55737 SPN
						-- BEGIN PTS 58334 SPN
						, pd.pyd_lghtype1,
						-- END PTS 58334 SPN
			pyd_fixedrate, pyd_fixedamount,	-- 76582						
			pyd_orig_currency, pyd_orig_amount, pyd_cex_rate	-- 63702
       FROM paydetail pd with(index(dk_pyd_transdate)),   
            manpowerprofile  
      WHERE (pd.pyh_number = 0 OR (pd.pyh_number > 0 AND @p_includepaiditems = 'Y')) 
		AND pd.asgn_id = manpowerprofile.mpp_id 
        -- PTS 36914  SLM Add Trailer information
		--AND (pd.asgn_id = @p_mppid OR (@p_trcnumber = 'UNKNOWN' AND @p_mppid = 'UNKNOWN'))
		--AND (pd.asgn_id = @p_mppid OR (@p_trcnumber = 'UNKNOWN' AND @p_mppid = 'UNKNOWN' AND @p_trlnumber='UNKNOWN')) 
        AND (pd.asgn_id = @p_mppid OR (@p_trcnumber = 'UNKNOWN' AND @p_mppid = 'UNKNOWN' AND @p_trlnumber='UNKNOWN' AND @p_tpr_id='UNKNOWN'))		
		AND pd.asgn_type = 'DRV' 
		AND (pd.pyd_status IN ('HLD', 'PND') OR 
              (pd.pyd_status = 'REL' AND @p_includepaiditems = 'Y')) 
		AND (pd.pyd_transdate BETWEEN @p_start AND @p_end) 
		AND (pd.pyt_itemcode = @p_itemcode OR @p_itemcode = 'UNK')
		AND (pd.pyd_refnumtype = 'HRS' OR 
              (@alt = 'Y' AND (pd.pyd_refnumtype = @p_reftype OR @p_reftype = 'UNK')))
		AND (manpowerprofile.mpp_type1 = @p_drvtype1 OR @p_drvtype1 = 'UNK') 
		AND (manpowerprofile.mpp_type2 = @p_drvtype2 OR @p_drvtype2 = 'UNK') 
		AND (manpowerprofile.mpp_type3 = @p_drvtype3 OR @p_drvtype3 = 'UNK') 
		AND (manpowerprofile.mpp_type4 = @p_drvtype4 OR @p_drvtype4 = 'UNK') 
		AND (manpowerprofile.mpp_fleet = @p_fleet OR @p_fleet = 'UNK') 
		AND (manpowerprofile.mpp_company = @p_company OR @p_company = 'UNK') 
		AND (manpowerprofile.mpp_division = @p_division OR @p_division = 'UNK') 
		AND (manpowerprofile.mpp_terminal = @p_terminal OR @p_terminal = 'UNK') 
		AND pyd_number IS NOT NULL 
		AND pyh_number IS NOT NULL 
		AND lgh_number IS NOT NULL 
		AND asgn_number IS NOT NULL 
		AND asgn_type IS NOT NULL 
		AND asgn_id IS NOT NULL 
		AND pyd_prorap IS NOT NULL 
		AND pyd_payto IS NOT NULL 
		AND pyt_itemcode IS NOT NULL 
		AND mov_number IS NOT NULL 
      UNION
     SELECT pd.pyd_number, pd.pyh_number, pd.lgh_number, pd.asgn_number, pd.asgn_type, pd.asgn_id, pd.pyd_prorap, pd.pyd_payto, pd.pyt_itemcode, pd.mov_number, 
            pd.pyd_description, pd.pyr_ratecode, pd.pyd_quantity, pd.pyd_rateunit, pd.pyd_unit, pd.pyd_rate, pd.pyd_amount, pd.pyd_pretax, pd.pyd_glnum, 
            pd.pyd_currency, pd.pyd_currencydate, pd.pyd_status, pd.pyd_refnumtype, pd.pyd_refnum, pd.pyh_payperiod, pd.pyd_workperiod, pd.pyd_transdate, 
            pd.pyd_minus, pd.pyd_loadstate, pd.pyd_sequence, pd.pyt_fee1, pd.pyt_fee2, pd.pyd_grossamount, pd.pyd_updatedby, pd.pyd_updatedon, pd.psd_id, pd.ord_hdrnumber, 
            pd.cht_itemcode, pd.pyd_updsrc, std_number_adj, pyd_vendorpay, bill_override, not_billed_reason, pd.tar_tarriffnumber, pd.pyt_otflag	 
						-- BEGIN PTS 55737 SPN
							, pd.pyd_clock_start
							, pd.pyd_clock_end
						-- END PTS 55737 SPN
						-- BEGIN PTS 58334 SPN
						, pd.pyd_lghtype1,
						-- END PTS 58334 SPN
			pyd_fixedrate, pyd_fixedamount,	-- 76582						
			pyd_orig_currency, pyd_orig_amount, pyd_cex_rate	-- 63702
       FROM paydetail pd with(index(dk_pyd_transdate)),   
            tractorprofile  
      WHERE (pd.pyh_number = 0 OR (pd.pyh_number > 0 AND @p_includepaiditems = 'Y')) 
		AND pd.asgn_id = tractorprofile.trc_number 
		AND pd.asgn_type = 'TRC' 
		AND (pd.pyd_status in ('HLD', 'PND') OR 
		      (pd.pyd_status = 'REL' AND @p_includepaiditems = 'Y')) 
		AND (pd.pyd_transdate between @p_start and @p_end) 
		AND (pd.pyt_itemcode = @p_itemcode OR @p_itemcode = 'UNK') 
		AND (pd.pyd_refnumtype = @p_reftype OR @p_reftype = 'UNK') 
		AND @alt = 'Y' 
        -- PTS 36914  SLM Add Trailer information
		--AND (pd.asgn_id = @p_trcnumber OR (@p_trcnumber = 'UNKNOWN'  AND @p_mppid = 'UNKNOWN')) 
        --AND (pd.asgn_id = @p_trcnumber OR (@p_trcnumber = 'UNKNOWN'  AND @p_mppid = 'UNKNOWN' AND @p_trlnumber = 'UNKNOWN')) 
	    AND (pd.asgn_id = @p_trcnumber OR (@p_trcnumber = 'UNKNOWN' AND @p_mppid = 'UNKNOWN' AND @p_trlnumber='UNKNOWN' AND @p_tpr_id='UNKNOWN'))	
		AND (tractorprofile.trc_type1 = @p_trctype1 OR @p_trctype1 = 'UNK') 
		AND (tractorprofile.trc_type2 = @p_trctype2 OR @p_trctype2 = 'UNK') 
		AND (tractorprofile.trc_type3 = @p_trctype3 OR @p_trctype3 = 'UNK') 
		AND (tractorprofile.trc_type4 = @p_trctype4 OR @p_trctype4 = 'UNK') 
		AND (tractorprofile.trc_fleet = @p_fleet OR @p_fleet = 'UNK') 
		AND (tractorprofile.trc_company = @p_company OR @p_company = 'UNK') 
		AND (tractorprofile.trc_division = @p_division OR @p_division = 'UNK') 
		AND (tractorprofile.trc_terminal = @p_terminal OR @p_terminal = 'UNK') 
		AND pyd_number IS NOT NULL 
		AND pyh_number IS NOT NULL 
		AND lgh_number IS NOT NULL 
		AND asgn_number IS NOT NULL 
		AND asgn_type IS NOT NULL 
		AND asgn_id IS NOT NULL 
		AND pyd_prorap IS NOT NULL 
		AND pyd_payto IS NOT NULL 
		AND pyt_itemcode IS NOT NULL 
		AND mov_number IS NOT NULL 
	  UNION
     SELECT pd.pyd_number, pd.pyh_number, pd.lgh_number, pd.asgn_number, pd.asgn_type, pd.asgn_id, pd.pyd_prorap, pd.pyd_payto, pd.pyt_itemcode, pd.mov_number, 
            pd.pyd_description, pd.pyr_ratecode, pd.pyd_quantity, pd.pyd_rateunit, pd.pyd_unit, pd.pyd_rate, pd.pyd_amount, pd.pyd_pretax, pd.pyd_glnum, 
            pd.pyd_currency, pd.pyd_currencydate, pd.pyd_status, pd.pyd_refnumtype, pd.pyd_refnum, pd.pyh_payperiod, pd.pyd_workperiod, pd.pyd_transdate, 
            pd.pyd_minus, pd.pyd_loadstate, pd.pyd_sequence, pd.pyt_fee1, pd.pyt_fee2, pd.pyd_grossamount, pd.pyd_updatedby, pd.pyd_updatedon, pd.psd_id, pd.ord_hdrnumber, 
            pd.cht_itemcode, pd.pyd_updsrc, std_number_adj, pyd_vendorpay, bill_override, not_billed_reason, pd.tar_tarriffnumber, pd.pyt_otflag	 
						-- BEGIN PTS 55737 SPN
							, pd.pyd_clock_start
							, pd.pyd_clock_end
						-- END PTS 55737 SPN
						-- BEGIN PTS 58334 SPN
						, pd.pyd_lghtype1,
						-- END PTS 58334 SPN
			pyd_fixedrate, pyd_fixedamount,	-- 76582						
			pyd_orig_currency, pyd_orig_amount, pyd_cex_rate	-- 63702
       FROM paydetail pd with(index(dk_pyd_transdate)),   
            carrier   
      WHERE (pd.pyh_number = 0 OR (pd.pyh_number > 0 AND @p_includepaiditems = 'Y')) 
		AND pd.asgn_id = carrier.car_id 
		AND pd.asgn_type = 'CAR' 
		AND (pd.pyd_status IN ('HLD', 'PND') OR 
		      (pd.pyd_status = 'REL' AND @p_includepaiditems = 'Y')) 
		AND (pd.pyd_transdate BETWEEN @p_start AND @p_end) 
		AND (pd.pyt_itemcode = @p_itemcode OR @p_itemcode = 'UNK') 
		AND (pd.pyd_refnumtype = @p_reftype OR @p_reftype = 'UNK') 
		AND @alt = 'Y' 
		AND (@p_mppid = 'UNKNOWN' AND @p_trcnumber = 'UNKNOWN' AND @p_trlnumber = 'UNKNOWN') 
		AND pyd_number IS NOT NULL 
		AND pyh_number IS NOT NULL 
		AND lgh_number IS NOT NULL 
		AND asgn_number IS NOT NULL 
		AND asgn_type IS NOT NULL 
		AND asgn_id IS NOT NULL 
		AND pyd_prorap IS NOT NULL 
		AND pyd_payto IS NOT NULL 
		AND pyt_itemcode IS NOT NULL 
		AND mov_number IS NOT NULL 	  
	UNION
     SELECT pd.pyd_number, pd.pyh_number, pd.lgh_number, pd.asgn_number, pd.asgn_type, pd.asgn_id, pd.pyd_prorap, pd.pyd_payto, pd.pyt_itemcode, pd.mov_number, 
            pd.pyd_description, pd.pyr_ratecode, pd.pyd_quantity, pd.pyd_rateunit, pd.pyd_unit, pd.pyd_rate, pd.pyd_amount, pd.pyd_pretax, pd.pyd_glnum, 
            pd.pyd_currency, pd.pyd_currencydate, pd.pyd_status, pd.pyd_refnumtype, pd.pyd_refnum, pd.pyh_payperiod, pd.pyd_workperiod, pd.pyd_transdate, 
            pd.pyd_minus, pd.pyd_loadstate, pd.pyd_sequence, pd.pyt_fee1, pd.pyt_fee2, pd.pyd_grossamount, pd.pyd_updatedby, pd.pyd_updatedon, pd.psd_id, pd.ord_hdrnumber, 
            pd.cht_itemcode, pd.pyd_updsrc, std_number_adj, pyd_vendorpay, bill_override, not_billed_reason, pd.tar_tarriffnumber, pd.pyt_otflag	 
						-- BEGIN PTS 55737 SPN
							, pd.pyd_clock_start
							, pd.pyd_clock_end
						-- END PTS 55737 SPN
						-- BEGIN PTS 58334 SPN
						, pd.pyd_lghtype1,
						-- END PTS 58334 SPN
			pyd_fixedrate, pyd_fixedamount,	-- 76582						
			pyd_orig_currency, pyd_orig_amount, pyd_cex_rate	-- 63702
       FROM paydetail pd with(index(dk_pyd_transdate)) 
      WHERE pd.pyh_number = 0 
		AND pd.asgn_id IN ('', 'UNKNOWN', 'UNK', 'ALL') 
		AND (pd.pyd_transdate BETWEEN @p_start AND @p_end) 
		AND (pd.pyt_itemcode = @p_itemcode OR @p_itemcode = 'UNK') 
		AND (pd.pyd_refnumtype = @p_reftype OR @p_reftype = 'UNK') 
		AND @alt = 'Y' 
        -- PTS 36914  SLM Add Trailer information
		--AND (@p_mppid = 'UNKNOWN' AND @p_trcnumber = 'UNKNOWN') 
		AND (@p_mppid = 'UNKNOWN' AND @p_trcnumber = 'UNKNOWN' AND @p_trlnumber = 'UNKNOWN') 
		AND pyd_number IS NOT NULL 
		AND pyh_number IS NOT NULL 
		AND lgh_number IS NOT NULL 
		AND asgn_number IS NOT NULL 
		AND asgn_type IS NOT NULL 
		AND asgn_id IS NOT NULL 
		AND pyd_prorap IS NOT NULL 
		AND pyd_payto IS NOT NULL 
		AND pyt_itemcode IS NOT NULL 
		AND mov_number IS NOT NULL 
	  UNION -- PTS 36914  SLM Add Trailer information
      SELECT pd.pyd_number, pd.pyh_number, pd.lgh_number, pd.asgn_number, pd.asgn_type, pd.asgn_id, pd.pyd_prorap, pd.pyd_payto, pd.pyt_itemcode, pd.mov_number, 
            pd.pyd_description, pd.pyr_ratecode, pd.pyd_quantity, pd.pyd_rateunit, pd.pyd_unit, pd.pyd_rate, pd.pyd_amount, pd.pyd_pretax, pd.pyd_glnum, 
            pd.pyd_currency, pd.pyd_currencydate, pd.pyd_status, pd.pyd_refnumtype, pd.pyd_refnum, pd.pyh_payperiod, pd.pyd_workperiod, pd.pyd_transdate, 
            pd.pyd_minus, pd.pyd_loadstate, pd.pyd_sequence, pd.pyt_fee1, pd.pyt_fee2, pd.pyd_grossamount, pd.pyd_updatedby, pd.pyd_updatedon, pd.psd_id, pd.ord_hdrnumber, 
            pd.cht_itemcode, pd.pyd_updsrc, std_number_adj, pyd_vendorpay, bill_override, not_billed_reason, pd.tar_tarriffnumber, pd.pyt_otflag	 
						-- BEGIN PTS 55737 SPN
							, pd.pyd_clock_start
							, pd.pyd_clock_end
						-- END PTS 55737 SPN
						-- BEGIN PTS 58334 SPN
						, pd.pyd_lghtype1,
						-- END PTS 58334 SPN
			pyd_fixedrate, pyd_fixedamount,	-- 76582						
			pyd_orig_currency, pyd_orig_amount, pyd_cex_rate	-- 63702
       FROM paydetail pd with(index(dk_pyd_transdate)),   
            trailerprofile  
      WHERE (pd.pyh_number = 0 OR (pd.pyh_number > 0 AND @p_includepaiditems = 'Y')) 
		AND pd.asgn_id = trailerprofile.trl_number 
		AND pd.asgn_type = 'TRL' 
		AND (pd.pyd_status in ('HLD', 'PND') OR (pd.pyd_status = 'REL' AND @p_includepaiditems = 'Y')) 
		AND (pd.pyd_transdate between @p_start and @p_end) 
		AND (pd.pyt_itemcode = @p_itemcode OR @p_itemcode = 'UNK') 
		AND (pd.pyd_refnumtype = @p_reftype OR @p_reftype = 'UNK') 
		AND @alt = 'Y' 
		AND (pd.asgn_id = @p_trlnumber OR (@p_trlnumber = 'UNKNOWN'  AND @p_mppid = 'UNKNOWN' AND @p_trcnumber = 'UNKNOWN')) 
		AND (trailerprofile.trl_type1 = @p_trltype1 OR @p_trltype1 = 'UNK') 
		AND (trailerprofile.trl_type2 = @p_trltype2 OR @p_trltype2 = 'UNK') 
		AND (trailerprofile.trl_type3 = @p_trltype3 OR @p_trltype3 = 'UNK') 
		AND (trailerprofile.trl_type4 = @p_trltype4 OR @p_trltype4 = 'UNK') 
		AND (trailerprofile.trl_fleet = @p_fleet OR @p_fleet = 'UNK') 
		AND (trailerprofile.trl_company = @p_company OR @p_company = 'UNK') 
		AND (trailerprofile.trl_division = @p_division OR @p_division = 'UNK') 
		AND (trailerprofile.trl_terminal = @p_terminal OR @p_terminal = 'UNK') 
		AND pyd_number IS NOT NULL 
		AND pyh_number IS NOT NULL 
		AND lgh_number IS NOT NULL 
		AND asgn_number IS NOT NULL 
		AND asgn_type IS NOT NULL 
		AND asgn_id IS NOT NULL 
		AND pyd_prorap IS NOT NULL 
		AND pyd_payto IS NOT NULL 
		AND pyt_itemcode IS NOT NULL 
		AND mov_number IS NOT NULL 
		  UNION -- PTS 41375 GAP 64/82  JSwindell Add ThirdParty info  (if a client has no 3rdParty - there'd be NO data anyway.
		  SELECT pd.pyd_number, pd.pyh_number, pd.lgh_number, pd.asgn_number, pd.asgn_type, pd.asgn_id, pd.pyd_prorap, 
				ISNULL(pd.pyd_payto, 'UNKNOWN') 'pyd_payto',  pd.pyt_itemcode, pd.mov_number, 
				pd.pyd_description, pd.pyr_ratecode, pd.pyd_quantity, pd.pyd_rateunit, pd.pyd_unit, pd.pyd_rate, pd.pyd_amount, pd.pyd_pretax, pd.pyd_glnum, 
				pd.pyd_currency, pd.pyd_currencydate, pd.pyd_status, pd.pyd_refnumtype, pd.pyd_refnum, pd.pyh_payperiod, pd.pyd_workperiod, pd.pyd_transdate, 
				pd.pyd_minus, pd.pyd_loadstate, pd.pyd_sequence, pd.pyt_fee1, pd.pyt_fee2, pd.pyd_grossamount, pd.pyd_updatedby, pd.pyd_updatedon, pd.psd_id, pd.ord_hdrnumber, 
				pd.cht_itemcode, pd.pyd_updsrc, std_number_adj, pyd_vendorpay, bill_override, not_billed_reason, tar_tarriffnumber, pd.pyt_otflag
						-- BEGIN PTS 55737 SPN
							, pd.pyd_clock_start
							, pd.pyd_clock_end
						-- END PTS 55737 SPN
						-- BEGIN PTS 58334 SPN
						, pd.pyd_lghtype1,
						-- END PTS 58334 SPN
				pyd_fixedrate, pyd_fixedamount,	-- 76582						
				pyd_orig_currency, pyd_orig_amount, pyd_cex_rate	-- 63702
		   FROM paydetail pd with(index(dk_pyd_transdate)),   
				thirdpartyprofile  
		   WHERE (pd.pyh_number = 0 OR (pd.pyh_number > 0 AND @p_includepaiditems = 'Y')) 
			AND pd.asgn_id = thirdpartyprofile.tpr_id
			-- added this next line only.
			AND (pd.asgn_id = @p_tpr_id OR (@p_trcnumber = 'UNKNOWN' AND @p_mppid = 'UNKNOWN' AND @p_trlnumber='UNKNOWN' AND @p_tpr_id='UNKNOWN'))
			AND pd.asgn_type = 'TPR' 
			AND (pd.pyd_status in ('HLD', 'PND') OR (pd.pyd_status = 'REL' AND @p_includepaiditems = 'Y')) 
			AND (pd.pyd_transdate between @p_start and @p_end) 
			AND (pd.pyt_itemcode = @p_itemcode OR @p_itemcode = 'UNK') 
			AND (pd.pyd_refnumtype = @p_reftype OR @p_reftype = 'UNK') 
			AND @alt = 'Y' 		
			AND pyd_number IS NOT NULL 
			AND pyh_number IS NOT NULL 
			AND lgh_number IS NOT NULL 
			AND asgn_number IS NOT NULL 
			AND asgn_type IS NOT NULL 
			AND asgn_id IS NOT NULL 
			AND pyd_prorap IS NOT NULL 		
			AND pyt_itemcode IS NOT NULL 
			AND mov_number IS NOT NULL 	

UPDATE #paydetail 
   SET ord_number = orderheader.ord_number,
	   ord_booked_revtype1 = orderheader.ord_booked_revtype1 -- PTS 41375 GAP 64/82 (add branch)
  FROM orderheader 
 WHERE orderheader.ord_hdrnumber = #paydetail.ord_hdrnumber 


-- PTS 41375 GAP 64/82  JSwindell Additional Processing START
UPDATE #paydetail 
	SET ord_booked_revtype1 = 'UNKNOWN' 
from #paydetail 
where ord_booked_revtype1 = 'UNK'

-- init.
UPDATE #paydetail 
	SET #paydetail.calc_billable_y_n = 'N'

UPDATE #paydetail 
	SET #paydetail.calc_billable_y_n = 'Y',
		#paydetail.calc_bill_code = paytype.cht_itemcode
FROM paytype, #paydetail  
where paytype.pyt_itemcode = #paydetail.pyt_itemcode
and paytype.cht_itemcode <> 'UNK'	
and paytype.cht_itemcode is not null


--**********  NOTE (Original Proc did not acknowledge branch. so if trackbranch = N then IGNORE brn_id.
--***   PTS 41375 GAP 64/82 5/27/2008 JSwindell - Bug fix.  ***  BUG FIX ADD this section.

If exists (select * from generalinfo where gi_name = 'TrackBranch' and gi_string1 = 'Y') 
BEGIN
	IF @brn_id <> ',UNKNOWN,'
		Delete from #paydetail
		where ord_booked_revtype1 in (select ord_booked_revtype1 from #paydetail
										  where CHARINDEX(',' + ord_booked_revtype1 + ',', @brn_id) = 0 ) 
	ELSE 
		If exists (select * from generalinfo where gi_name = 'BRANCHUSERSECURITY' and gi_string1 = 'Y') 
			DELETE FROM #paydetail
			WHERE ISNULL(ord_booked_revtype1,'UNKNOWN' ) 
			NOT IN ( SELECT brn_id FROM v_branch_assignedtype WHERE bat_type = 'USERS' AND bat_value  = @G_USERID UNION ALL SELECT 'UNKNOWN' )
		
END


--***   PTS 41375 GAP 64/82 5/27/2008 JSwindell - Bug fix.  ***  BUG FIX remove this section.
--If exists (select * from generalinfo where gi_name = 'TrackBranch' and gi_string1 = 'Y') 
--	BEGIN
--		--	 remove any null value records (If TrackBranch = 'Y' remove any null values if any.)
--		Delete from #paydetail where ord_booked_revtype1 IS NULL -- remove any NULL value records.	
--	
--		IF @brn_id <> ',UNKNOWN,'
--			BEGIN
--				Delete from #paydetail
--				where ord_booked_revtype1 in (select ord_booked_revtype1 from #paydetail
--											  where CHARINDEX(',' + ord_booked_revtype1 + ',', @brn_id) = 0 ) 
--			END 
--		ELSE 
--			BEGIN			
--				If exists (select * from generalinfo where gi_name = 'BRANCHUSERSECURITY' and gi_string1 = 'Y') 
--				BEGIN
--							-- if branch security is ON then get data, else, do not delete.
--						    -- if branch id = 'unknown' bring back ALL branch IDs the user is ALLOWED to see.
--							SELECT brn_id
--							INTO #temp_user_branch		
--							FROM branch_assignedtype  
--							WHERE bat_type = 'USERID'
--							and brn_id <> 'UNKNOWN'
--							AND bat_value  =  @G_USERID
--
--							Delete from #paydetail
--							where ord_booked_revtype1 NOT IN ( select brn_id from #temp_user_branch) 	
--				END
--			END 
--	END 

--IF @pyd_status <> 'UNKNOWN'	-- it's 6 char so the word 'unknown' gets trucated!!!
IF @pyd_status <> 'UNKNOW'	
	BEGIN
		Delete from #paydetail WHERE pyd_status <> @pyd_status
	END 


-- remove NULL values the selection misses them...
update #paydetail
	SET pyd_refnum = '' 
	WHERE pyd_refnum is null


IF @pyd_refnum <> 'UNKNOWN'
	BEGIN
		Delete from #paydetail WHERE pyd_refnum <> @pyd_refnum
	END 

update #paydetail
	set	bill_override = calc_billable_y_n
	where calc_billable_y_n <> 'N'
	and bill_override is null
-- PTS 41375 GAP 64/82  JSwindell Additional Processing END 

--	LOR	PTS# 41366
UPDATE #paydetail 
SET #paydetail.pyt_otflag = paytype.pyt_otflag
FROM paytype, #paydetail  
where paytype.pyt_itemcode = #paydetail.pyt_itemcode
	and #paydetail.pyt_otflag is null or #paydetail.pyt_otflag = ''

UPDATE #paydetail 
SET #paydetail.pyt_basisunit = paytype.pyt_basisunit
FROM paytype, #paydetail  
where paytype.pyt_itemcode = #paydetail.pyt_itemcode
--	LOR

SELECT pyd_number, 
       pyh_number, 
       lgh_number, 
       asgn_number, 
       asgn_type, 
       asgn_id, 
       pyd_prorap, 
       pyd_payto, 
       pyt_itemcode, 
       mov_number, 
       pyd_description, 
       pyr_ratecode, 
       pyd_quantity, 
       pyd_rateunit, 
       pyd_unit, 
       pyd_rate, 
       pyd_amount, 
       pyd_pretax, 
       pyd_glnum, 
       pyd_currency, 
       pyd_currencydate, 
       pyd_status, 
       pyd_refnumtype, 
       pyd_refnum, 
       pyh_payperiod, 
       pyd_workperiod, 
       pyd_transdate, 
       pyd_minus, 
       pyd_loadstate, 
       pyd_sequence, 
       pyt_fee1, 
       pyt_fee2, 
       pyd_grossamount, 
       pyd_updatedby, 
       pyd_updatedon, 
       psd_id, 
       mpp_teamleader, 
       mpp_domicile, 
       mpp_company, 
       mpp_division, 
       mpp_fleet, 
       mpp_terminal, 
       mpp_type1, 
       mpp_type2, 
       mpp_type3, 
       mpp_type4, 
       trc_company, 
       trc_division, 
       trc_fleet, 
       trc_terminal, 
       trc_type1, 
       trc_type2, 
       trc_type3, 
       trc_type4, 
       car_type1, 
       car_type2, 
       car_type3, 
       car_type4, 
       @mpptype1 mpp_type1_t, 
       @mpptype2 mpp_type2_t, 
       @mpptype3 mpp_type3_t, 
       @mpptype4 mpp_type4_t, 
       @trctype1 trc_type1_t, 
       @trctype2 trc_type2_t, 
       @trctype3 trc_type3_t, 
       @trctype4 trc_type4_t, 
       @cartype1 car_type1_t, 
       @cartype2 car_type2_t, 
       @cartype3 car_type3_t, 
       @cartype4 car_type4_t, 
       ord_number, 
       ord_hdrnumber, 
       std_number_adj, 
       pyd_vendortopay, 
       cht_itemcode,
       pyd_updsrc,
       pyd_vendorpay,   
       -- PTS 36914  SLM Add Trailer information
       @trltype1 trl_type1_t, 
       @trltype2 trl_type2_t, 
       @trltype3 trl_type3_t, 
       @trltype4 trl_type4_t,
       trl_type1, 
       trl_type2, 
       trl_type3, 
       trl_type4,
		ord_booked_revtype1,   -- PTS 41375 GAP 64/82
		calc_billable_y_n,	   -- PTS 41375 GAP 64/82		
		calc_bill_code,		   -- PTS 41375 GAP 64/82
		bill_override,		   -- PTS 41375 GAP 64/82	   
		not_billed_reason,	   -- PTS 41375 GAP 64/82
		tar_tarriffnumber,	   -- PTS 41375 GAP 64/82
		pyt_otflag,
		pyt_basisunit
	, pyd_clock_start			-- PTS 55737 SPN
	, pyd_clock_end				-- PTS 55737 SPN
	, pyd_lghtype1,				-- PTS 58334 SPN
	pyd_fixedrate,		-- 76582
	pyd_fixedamount,	-- 76582	
	pyd_orig_currency,	-- 63702
	pyd_orig_amount,	-- 63702
	pyd_cex_rate		-- 63702
  FROM #paydetail

DROP TABLE #paydetail 

set rowcount 0
GO
GRANT EXECUTE ON  [dbo].[d_hourly_input_sp] TO [public]
GO
