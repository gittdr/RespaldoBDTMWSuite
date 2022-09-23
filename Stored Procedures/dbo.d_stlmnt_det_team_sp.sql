SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[d_stlmnt_det_team_sp] (@type CHAR(6), @id CHAR(13), @lghnumber INT, @ordnum INT)
AS


/* Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	------------------------------------------------------------------------------------

   01/23/02    PETE         PTS 12840 add pyt_group to return set to allow standing deduction by pay type group
   01/20/05    DJM	PTS 24118 - Added columns pyd_maxquantity_used and pyd_maxcharge_used to indicate that 
				Maximum rate was applied.
   2/24/05 DPETE 26030 add pyh_paystatus
	LOR	PTS# 35742	add stp_number, stp_mfh_sequence
	vjh	39284 add stp_number_pacos
 * 11/06/2007.01 ? PTS40186 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 01/11/2008 JDS PTS 38870 -- Add pyd_createdby and pyd_createdon columns.
					pyd_createdby		CHAR(20)	NULL,	-- PTS 38870
					pyd_createdon		datetime	NULL	-- PTS 38870
 *	LOR	PTS# 40714	added pyd_mileagetable
 * DPETE 40260 recode Pauls Hauling 4/19/08
 *	LOR	PTS# 41366	added pyt_otflag, pyt_basisunit
 *	LOR	PTS# 44775	added otflag_workfield
 *  3/27/2009 JSwindell PTS45170: New PayHeader col:  pyh_lgh_number * note - this proc has TWO areas it can return from *
 *  4/24/2009	DJM PTS 43873	Added pyd_min_period field.		
 *  7/7/2009  JSwindell  PTS 48160: When Thirdparty on get error.
 *  7-23-2009 PTS 47021 ********  Add WorkCycle Columns.  pyd_workcycle_status   x30  pyd_workcycle_description   x75
 *  4/28/2010 vjh 42282 add pyd_advstdnum to tie otgether the advance/offset/standingdeduction set
 *  6/3/2008  DJM 48237 Add fields to support searching by Driver and/or Tractor type.
 *	LOR	PTS# 52563	add pyd_thirdparty_split_percent
 *  10/1/2010	PTS52811	- ( new requires ) (add: lgh_startdate,stp_arrivaldate,cc_itemsection)
 *	05/12/2011	vjh	Add pyd_coowner_split_percent, pyd_coowner_split_adj, pyd_report_quantity, pyd_report_rate
 *  3/28/2014 nloke Created for PTS 63945
 *  05/15/14  nqiao PTS76582 - added 2 more outputs: pyd_fixedrate, pyd_fixedamount
 *  02/28/2015 NQIAO PTS63702 - add 3 new outputs: pyd_orig_currency, pyd_orig_amount, pyd_cex_rate
 *	03/13/2015	vjh	85922 - add pyt_requireaudit
*/

CREATE TABLE #temp_pay(
	pyd_number			INTEGER		NULL, 
	pyh_number			INTEGER		NULL, 
	lgh_number			INTEGER		NULL, 
	asgn_number			INTEGER		NULL, 
	asgn_type			VARCHAR(6)	NULL, 
	asgn_id				VARCHAR(8)	NULL, 
	ivd_number			INTEGER		NULL, 
	pyd_prorap			CHAR(1)		NULL, 
	pyd_payto			VARCHAR(12)	NULL, 
	pyt_itemcode		VARCHAR(6)	NULL, 
	pyd_description		VARCHAR(75)	NULL, 
	pyr_ratecode		VARCHAR(6)	NULL, 
	pyd_quantity		FLOAT		NULL, 
	pyd_rateunit		VARCHAR(6)	NULL, 
	pyd_unit			VARCHAR(6)	NULL, 
	pyd_pretax			CHAR(1)		NULL, 
	pyd_glnum			VARCHAR(32)	NULL, 
	pyd_status			VARCHAR(6)	NULL, 
	pyd_refnumtype		VARCHAR(6)	NULL, 
	pyd_refnum			VARCHAR(30)	NULL, 
	pyh_payperiod		DATETIME	NULL, 
	lgh_startpoint		VARCHAR(8)	NULL, 
	lgh_startcity		INTEGER		NULL, 
	lgh_endpoint		VARCHAR(8)	NULL, 
	lgh_endcity			INTEGER		NULL, 
	ivd_payrevenue		MONEY		NULL, 
	mov_number			INTEGER		NULL, 
	pyd_minus			INTEGER		NULL, 
	pyd_workperiod		DATETIME	NULL, 
	pyd_sequence		INTEGER		NULL, 
	pyd_rate			MONEY		NULL, 
	pyd_amount			MONEY		NULL, 
	pyd_revenueratio	FLOAT		NULL, 
	pyd_lessrevenue		MONEY		NULL,  
	pyd_payrevenue		MONEY		NULL, 
	std_number			INTEGER		NULL, 
	pyd_loadstate		VARCHAR(6)	NULL, 
	pyd_transdate		DATETIME	NULL, 
	pyd_xrefnumber		INTEGER		NULL, 
	ord_hdrnumber		INTEGER		NULL, 
	pyt_basis			VARCHAR(6)	NULL, 
	pyt_fee1			MONEY		NULL, 
	pyt_fee2			MONEY		NULL, 
	pyd_grossamount		MONEY		NULL, 
	psd_id				INTEGER		NULL, 
	dummydate			DATETIME	NULL, 
	pyd_updatedby		VARCHAR(20)	NULL, 
	pyd_adj_flag		CHAR(1)		NULL, 
	pyd_exportstatus	VARCHAR(6)	NULL, 
	pyd_releasedby		VARCHAR(20)	NULL, 
	ord_number			VARCHAR(12)	NULL, 
	pyd_billedweight	INTEGER		NULL, 
	cht_itemcode		VARCHAR(6)	NULL, 
	tar_tarriffnumber	VARCHAR(12)	NULL, 
	psd_batch_id		VARCHAR(16)	NULL, 
	ord_revtype1		VARCHAR(6)	NULL, 
	revtype1_name		VARCHAR(20)	NULL, 
	inv_statuscode		INTEGER		NULL,
	pyd_updatedon		DATETIME	NULL, 
	pyd_currency		VARCHAR(6)	NULL, 
	pyd_currencydate	DATETIME	NULL, 
	pyd_updsrc			CHAR(1)		NULL, 
	changed				INTEGER		NULL,
	pyt_agedays			INTEGER		NULL,
	pyd_ivh_hdrnumber	INTEGER		NULL,
	pyt_group			VARCHAR(6)	NULL,
	pyd_ref_invoice		VARCHAR(15)	NULL,
	pyd_ref_invoicedate	DATETIME	NULL, 
	calc				CHAR(1)		NULL, 
	edit_status 		CHAR(1)		NULL,
	psh_number			INTEGER		NULL,
	pyd_authcode		VARCHAR(30)	NULL,
	pyd_maxquantity_used	char(1) NULL,
	pyd_maxcharge_used	char(1)		NULL,
  	pyh_paystatus		varchar(6)	NULL,
	pyd_carinvnum		varchar(30)	NULL,
	pyd_carinvdate		datetime	NULL,
	std_number_adj		int			NULL, 
	pyd_vendortopay		varchar(12) null ,
	pyt_editindispatch	integer		null,
	pyd_remarks			varchar(254) null,
	pyt_exclude_guaranteed_pay char(1) null,
	stp_number			INTEGER		NULL,
	stp_mfh_sequence	INTEGER		NULL,
	pyd_perdiem_exceeded  CHAR(1)	NULL,
	stp_number_pacos	int			null,
	pyd_createdby		CHAR(20)	NULL,	-- PTS 38870
	pyd_createdon		datetime	NULL,	-- PTS 38870
	pyd_gst_amount		money		NULL,	-- vjh PTS 39688
	pyd_gst_flag		int			NULL,	-- vjh PTS 39688
	pyd_mileagetable	char(2)		null,
	pyd_mbtaxableamount	money null,             --40260
	pyd_nttaxableamount money null,             --40260
	pyt_otflag	char(1) null,
	pyt_basisunit	varchar(6) null,
	otflag_workfield	char(1) null,
	pyh_lgh_number		INTEGER		NULL,	-- 45170
	cc_xfer_ckbox		INTEGER		NULL,	-- 45170	
	pyd_min_period		datetime	NULL,	-- PTS 43873
	pyd_workcycle_status		VARCHAR(30)	NULL,   -- PTS 47021 
	pyd_workcycle_description   VARCHAR(75)	NULL,   -- PTS 47021 
	pyt_taxable			char(1)		null,
	pyd_advstdnum		integer		null,	--vjh 42282
	leg_mpp_type1		Varchar(6)	null,			-- PTS 48237
	leg_mpp_type2		Varchar(6)	null,			-- PTS 48237
	leg_mpp_type3		Varchar(6)	null,			-- PTS 48237
	leg_mpp_type4		Varchar(6)	null,			-- PTS 48237
	leg_trc_type1		Varchar(6)	null,			-- PTS 48237
	leg_trc_type2		Varchar(6)	null,			-- PTS 48237
	leg_trc_type3		Varchar(6)	null,			-- PTS 48237
	leg_trc_type4		Varchar(6)	null,			-- PTS 48237
	mpp_type1			Varchar(6)	null,			-- PTS 48237
	mpp_type2			Varchar(6)	null,			-- PTS 48237
	mpp_type3			Varchar(6)	null,			-- PTS 48237
	mpp_type4			Varchar(6)	null,			-- PTS 48237
	trc_type1			Varchar(6)	null,			-- PTS 48237
	trc_type2			Varchar(6)	null,			-- PTS 48237
	trc_type3			Varchar(6)	null,			-- PTS 48237
	trc_type4			Varchar(6)	null,			-- PTS 48237
	mpp_type1_t			Varchar(10)	null,			-- PTS 48237
	mpp_type2_t			Varchar(10)	null,			-- PTS 48237
	mpp_type3_t			Varchar(10)	null,			-- PTS 48237
	mpp_type4_t			Varchar(10)	null,			-- PTS 48237
	Trctype1_t			Varchar(10)	null,			-- PTS 48237
	Trctype2_t			Varchar(10)	null,			-- PTS 48237
	Trctype3_t			Varchar(10)	null,			-- PTS 48237
	Trctype4_t			Varchar(10)	null,			-- PTS 48237
	pyd_thirdparty_split_percent	float	 null,
	lgh_startdate		datetime	null, 
	stp_arrivaldate		datetime	null, 
	cc_itemsection		INTEGER		NULL,
	pyd_coowner_split_percent	float	NULL,		-- PTS 54402
	pyd_coowner_split_adj char(1)	NULL,			-- PTS 54402
	pyd_report_quantity	money		NULL,			-- PTS 54402
	pyd_report_rate		money		NULL,			-- PTS 54402
	pyt_tax1			Varchar(1)	NULL,
	pyt_tax2			Varchar(1)	NULL,
	pyt_tax3			Varchar(1)	NULL,
	pyt_tax4			Varchar(1)	NULL,
	pyt_tax5			Varchar(1)	NULL,
	pyt_tax6			Varchar(1)	NULL,
	pyt_tax7			Varchar(1)	NULL,
	pyt_tax8			Varchar(1)	NULL,
	pyt_tax9			Varchar(1)	NULL,
	pyt_tax10			Varchar(1)	NULL,
	std_purchase_date               DATETIME    NULL, -- PTS 51492
	std_purchase_tax_state          VARCHAR(6)  NULL,  -- PTS 51492
	pyd_tax_originator_pyd_number   INT         NULL,  -- PTS 51492
	pyd_tprsplit_number				int			null,
	pyd_tprdiffbtw_number			int			null,
  	pyt_garnishmentclassification	varchar(12) NULL,  -- vjh 63106
	pyd_RemitToVendorID				varchar(12) NULL,  -- vjh 63106
	pyd_atd_id						INT			NULL, --PTS62995 SPN
	pyt_AdjustWithNegativePay		VARCHAR(12)	NULL,	--vjh 71977
	pyt_sth_abbr					VARCHAR(12)	NULL,	--vjh 71977
	sth_priority					INT			NULL,	--vjh 71977
	pyt_sth_priority				INT			NULL,	--vjh 71977
	pyd_pair						INT			NULL,	--vjh 71977
	pyd_branch						varchar(12)	NULL,	--vjh 71977
	pyd_fixedrate					char(1)		NULL,	--nqiao	76582
	pyd_fixedamount					char(1)		NULL,	--nqiao	76582	
	pyd_orig_currency				varchar(6)	NULL,	--nqiao 63702
	pyd_orig_amount					money		NULL,	--nqiao 63702
	pyd_cex_rate					money		NULL,	--nqiao 63702
	pyt_requireaudit				char(1)		NULL	--vjh 85922
) 
-- Used on D_STLMNT_DET which shares with D_STLMNT_DET_ALL (another proc) and D_STLMNT_ADTNL_DET (SQL in dw)
IF @lghnumber > 0 
	SELECT @ordnum = 0


IF @lghnumber > 0 
BEGIN
INSERT INTO #temp_pay
	SELECT	pyd_number, 
		pyh_number, 
		paydetail.lgh_number,		--PTS 48160 specifiy table
		asgn_number = paydetail.asgn_number, 
		asgn_type = paydetail.asgn_type, 
		asgn_id = paydetail.asgn_id, 
		ivd_number, 
		pyd_prorap, 
		pyd_payto, 
		paydetail.pyt_itemcode, 
		pyd_description, 
		pyr_ratecode, 
		pyd_quantity, 
		pyd_rateunit, 
		pyd_unit, 
		pyd_pretax, 
		pyd_glnum, 
		pyd_status, 
		pyd_refnumtype, 
		pyd_refnum, 
		pyh_payperiod = paydetail.pyh_payperiod, 
		lgh_startpoint, 
		legheader.lgh_startcity, 
		lgh_endpoint, 
		legheader.lgh_endcity, 
		ivd_payrevenue, 
		paydetail.mov_number, 
		pyd_minus, 
		pyd_workperiod, 
		pyd_sequence, 
		pyd_rate, 
		pyd_amount, 
		pyd_revenueratio, 
		pyd_lessrevenue,  
		pyd_payrevenue, 
		std_number, 
		pyd_loadstate, 
		pyd_transdate, 
		pyd_xrefnumber, 
		paydetail.ord_hdrnumber, 
		paytype.pyt_basis, 
		paydetail.pyt_fee1, 
		paydetail.pyt_fee2, 
		pyd_grossamount, 
		psd_id, 
		CONVERT(datetime, NULL) dummydate, 
		pyd_updatedby, 
		pyd_adj_flag, 
		pyd_exportstatus, 
		pyd_releasedby, 
		CONVERT(varchar(12), ISNULL(ord_number, '0')) ord_number, 
		pyd_billedweight, 
		paydetail.cht_itemcode, 
		paydetail.tar_tarriffnumber, 
		psd_batch_id, 
		CONVERT(varchar(6), ISNULL(ord_revtype1, 'UNK')) ord_revtype1, 
		CONVERT(varchar(20), 'RevType1') revtype1_name, 
		0 inv_statuscode,
		pyd_updatedon, 
		pyd_currency, 
		pyd_currencydate, 
		pyd_updsrc, 
		CONVERT(INT, 0) changed,
		pyt_agedays,
		pyd_ivh_hdrnumber,
		IsNUll(paytype.pyt_group,'UNK') pyt_group,
		pyd_ref_invoice,
		pyd_ref_invoicedate, 
		'N' as calc, 
		'N' as edit_status,
		psh_number,
		pyd_authcode,
		isNull(pyd_maxquantity_used,'N') pyd_maxquantity_used,
		isNull(pyd_maxcharge_used,'N') pyd_maxcharge_used,
		pyh_paystatus = IsNull(payheader.pyh_paystatus,'') ,
		pyd_carinvnum,
		pyd_carinvdate, 
		std_number_adj, 
		pyd_vendortopay,
		pyt_editindispatch,
		pyd_remarks,
		pyt_exclude_guaranteed_pay,
		stp_number,
		stp_mfh_sequence,
		pyd_perdiem_exceeded,
		stp_number_pacos,
		pyd_createdby, -- PTS 38870 
		pyd_createdon,		-- PTS 38870
		pyd_gst_amount,		-- vjh PTS 39688
		pyd_gst_flag,		-- vjh PTS 39688
		pyd_mileagetable,
		pyd_mbtaxableamount,
		pyd_nttaxableamount,
		paydetail.pyt_otflag,
		paytype.pyt_basisunit, 
		otflag_workfield = paydetail.pyt_otflag,
		ISNULL(pyh_lgh_number, 0) pyh_lgh_number,	-- 45170
		0,						-- cc_xfer_ckbox	-- 45170	
		pyd_min_period,	-- PTS 43873
		pyd_workcycle_status,       -- PTS 47021 
		pyd_workcycle_description,    -- PTS 47021 
		isnull(paytype.pyt_taxable, 'Y') pyt_taxable,  --MRH 45723
		pyd_advstdnum,				--vjh 42282
		legheader.mpp_type1 leg_mpp_type1,
		legheader.mpp_type2 leg_mpp_type2,
		legheader.mpp_type3 leg_mpp_type3,
		legheader.mpp_type4 leg_mpp_type4,
		legheader.trc_type1 leg_trc_type1,
		legheader.trc_type2 leg_trc_type2,
		legheader.trc_type3 leg_trc_type3,
		legheader.trc_type4 leg_trc_type4,
		ISNULL(manpowerprofile.mpp_type1, 'UNK') mpp_type1,
		ISNULL(manpowerprofile.mpp_type2, 'UNK') mpp_type2,
		ISNULL(manpowerprofile.mpp_type3, 'UNK') mpp_type3, 
		ISNULL(manpowerprofile.mpp_type4, 'UNK') mpp_type4,
		ISNULL(tractorprofile.trc_type1, 'UNK') trc_type1,
		ISNULL(tractorprofile.trc_type2, 'UNK') trc_type2,
		ISNULL(tractorprofile.trc_type3, 'UNK') trc_type3,
		ISNULL(tractorprofile.trc_type4, 'UNK')	trc_type4,	
		'DrvType1',   
		'DrvType2',   
		'DrvType3',   
		'DrvType4',   
		'TrcType1' trctype1_t,   
		'TrcType2' trctype2_t,   
		'TrcType3' trctype3_t,   
		'TrcType4' trctype4_t ,
		IsNull(pyd_thirdparty_split_percent, 0) pyd_thirdparty_split_percent,
		(select min(lgh_startdate) 	FROM legheader where  legheader.lgh_number = paydetail.lgh_number), --lgh_startdate	
		(select stp_arrivaldate from stops where stp_number = ( select max(stp_number) from stops where mov_number = paydetail.mov_number ) ), -- stp_arrivaldate		
		Case WHEN ( paydetail.pyt_itemcode = 'MN+'  OR paydetail.pyt_itemcode = 'MN-' ) THEN 4
			WHEN ( pyd_pretax = 'N' and pyd_minus = 1 ) THEN 2  
			WHEN ( pyd_pretax = 'N' and pyd_minus = -1 ) THEN 3						
			ELSE 0
		End, -- cc_itemsection	  
		pyd_coowner_split_percent,		-- PTS 54402
		pyd_coowner_split_adj,			-- PTS 54402
		pyd_report_quantity,			-- PTS 54402
		pyd_report_rate,				-- PTS 54402
		isnull(pyt_tax1, 'N') pyt_tax1,
		isnull(pyt_tax2, 'N') pyt_tax2,
		isnull(pyt_tax3, 'N') pyt_tax3,
		isnull(pyt_tax4, 'N') pyt_tax4,
		isnull(pyt_tax5, 'N') pyt_tax5,
		isnull(pyt_tax6, 'N') pyt_tax6,
		isnull(pyt_tax7, 'N') pyt_tax7,
		isnull(pyt_tax8, 'N') pyt_tax8,
		isnull(pyt_tax9, 'N') pyt_tax9,
		isnull(pyt_tax10, 'N') pyt_tax10,
		paydetail.std_purchase_date,             -- PTS 51492
		paydetail.std_purchase_tax_state,        -- PTS 51492
		paydetail.pyd_tax_originator_pyd_number, -- PTS 51492
		pyd_tprsplit_number,	
		pyd_tprdiffbtw_number,
		pyt_garnishmentclassification,			-- vjh 63106
		pyd_RemitToVendorID	,					-- vjh 63106
		paydetail.pyd_atd_id,						--PTS62995 SPN
		pyt_AdjustWithNegativePay,				-- vjh 71977
		pyt_sth_abbr,							-- vjh 71977
		sh.sth_priority,						-- vjh 71977
		pyt_sth_priority,						-- vjh 71977
		pyd_pair,								-- vjh 71977
		pyd_branch,								-- vjh 71977
		pyd_fixedRate,							-- nqiao 76582
		pyd_fixedamount,						-- nqiao 76582
		pyd_orig_currency,						-- nqiao 63702
		pyd_orig_amount,						-- nqiao 63702
		pyd_cex_rate,							-- nqiao 63702
		pyt_requireaudit						--vjh 85922	
FROM  paydetail  
		LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber   
		LEFT OUTER JOIN  purchaseservicedetail  ON  paydetail.psd_number  = purchaseservicedetail.psd_number   
		LEFT OUTER JOIN  payheader  ON  payheader.pyh_pyhnumber  = paydetail.pyh_number 
		Left Outer join legheader on paydetail.lgh_number = legheader.lgh_number
		LEFT OUTER JOIN manpowerprofile on paydetail.asgn_id = manpowerprofile.mpp_id and paydetail.asgn_type = 'DRV'
		LEFT OUTER JOIN tractorprofile on paydetail.asgn_id = tractorprofile.trc_number and paydetail.asgn_type = 'TRC',
		paytype 
		LEFT OUTER JOIN paytypetax ON paytype.pyt_number = paytypetax.pyt_number
		LEFT OUTER JOIN stdhierarchy sh ON sh.sth_abbr = paytype.pyt_sth_abbr
		--PTS 48160 specifiy table below for lgh_number
 WHERE	paydetail.lgh_number = @lghnumber AND
		--paydetail.asgn_id = @id AND 
		paydetail.asgn_type = @type  AND 
		paydetail.pyt_itemcode = paytype.pyt_itemcode

-- lookup the minimum invoice status for each pay detail for the current order number
UPDATE	#temp_pay 
   SET	inv_statuscode = (SELECT	ISNULL(MIN(code) , 0)
							FROM	labelfile, invoiceheader 
						   WHERE	invoiceheader.ord_hdrnumber = #temp_pay.ord_hdrnumber AND
									invoiceheader.ivh_invoicestatus = labelfile.abbr AND 
									labelfile.labeldefinition = 'InvoiceStatus')


-- PTS 45170 <<start>>	-- calculate the cc_xfer_ckbox IF GI setting is ON. 
If exists (select gi_string1 from generalinfo where gi_name = 'STLRELXFER' and gi_string1 = 'WHLTRP')
BEGIN
	Update #temp_pay 
	SET cc_xfer_ckbox = 1
	where pyh_paystatus = 'XFR'
	----where pyh_lgh_number <> 0 AND pyh_paystatus = 'XFR'
	
	Update #temp_pay 
	SET cc_xfer_ckbox = 0
	where cc_xfer_ckbox <> 1
END
-- PTS 45170 <<end>>

	SELECT * FROM #temp_pay

	DROP TABLE #temp_pay
END
---------------------------------------------------------------------
IF @ordnum > 0 
BEGIN
INSERT INTO #temp_pay
	SELECT	pyd_number, 
		pyh_number, 
		paydetail.lgh_number,	--PTS 48160 specifiy table
		asgn_number = paydetail.asgn_number, 
		asgn_type = paydetail.asgn_type, 
		asgn_id = paydetail.asgn_id, 
		ivd_number, 
		pyd_prorap, 
		pyd_payto, 
		paydetail.pyt_itemcode, 
		pyd_description, 
		pyr_ratecode, 
		pyd_quantity, 
		pyd_rateunit, 
		pyd_unit, 
		pyd_pretax, 
		pyd_glnum, 
		pyd_status, 
		pyd_refnumtype, 
		pyd_refnum, 
		pyh_payperiod = paydetail.pyh_payperiod, 
		lgh_startpoint, 
		legheader.lgh_startcity, 
		lgh_endpoint, 
		legheader.lgh_endcity, 
		ivd_payrevenue, 
		paydetail.mov_number, 
		pyd_minus, 
		pyd_workperiod, 
		pyd_sequence, 
		pyd_rate, 
		pyd_amount, 
		pyd_revenueratio, 
		pyd_lessrevenue,  
		pyd_payrevenue, 
		std_number, 
		pyd_loadstate, 
		pyd_transdate, 
		pyd_xrefnumber, 
		paydetail.ord_hdrnumber, 
		paytype.pyt_basis, 
		paydetail.pyt_fee1, 
		paydetail.pyt_fee2, 
		pyd_grossamount, 
		psd_id, 
		CONVERT(datetime, NULL) dummydate, 
		pyd_updatedby, 
		pyd_adj_flag, 
		pyd_exportstatus, 
		pyd_releasedby, 
		CONVERT(varchar(12), ISNULL(ord_number, '0')) ord_number, 
		pyd_billedweight, 
		paydetail.cht_itemcode, 
		paydetail.tar_tarriffnumber, 
		psd_batch_id, 
		CONVERT(varchar(6), ISNULL(ord_revtype1, 'UNK')) ord_revtype1, 
		CONVERT(varchar(20), 'RevType1') revtype1_name, 
		0 inv_statuscode,
		pyd_updatedon, 
		pyd_currency, 
		pyd_currencydate, 
		pyd_updsrc, 
		CONVERT(INT, 0) changed,
		pyt_agedays,
		pyd_ivh_hdrnumber, --16433 JD match result sets.
		IsNUll(paytype.pyt_group,'UNK') pyt_group,
		pyd_ref_invoice,
		pyd_ref_invoicedate, 
		'N' as calc, 
		'N' as edit_status,
		psh_number,
		pyd_authcode ,
		isNull(pyd_maxquantity_used,'N') pyd_maxquantity_used,
		isNull(pyd_maxcharge_used,'N') pyd_maxcharge_used,
		pyh_paystatus = IsNull(payheader.pyh_paystatus,''),
		pyd_carinvnum,
		pyd_carinvdate, 
		std_number_adj, 
		pyd_vendortopay,
		pyt_editindispatch,
		pyd_remarks,
		pyt_exclude_guaranteed_pay,
		stp_number,
		stp_mfh_sequence,
		pyd_perdiem_exceeded,
		stp_number_pacos,
		pyd_createdby, -- PTS 38870 
		pyd_createdon,		-- PTS 38870
		pyd_gst_amount,		-- vjh PTS 39688
		pyd_gst_flag,		-- vjh PTS 39688
		pyd_mileagetable,
		pyd_mbtaxableamount,
		pyd_nttaxableamount,
		paydetail.pyt_otflag,
		paytype.pyt_basisunit,
		otflag_workfield = paydetail.pyt_otflag,
		ISNULL(pyh_lgh_number, 0) pyh_lgh_number,	-- 45170
		0,						-- cc_xfer_ckbox	-- 45170	
		pyd_min_period,		-- PTS 43873
		pyd_workcycle_status,       -- PTS 47021 
		pyd_workcycle_description,    -- PTS 47021 
		isnull(paytype.pyt_taxable, 'Y') pyt_taxable,  --MRH 45723
		pyd_advstdnum,				--vjh 42282
		legheader.mpp_type1 leg_mpp_type1,
		legheader.mpp_type2 leg_mpp_type2,
		legheader.mpp_type3 leg_mpp_type3,
		legheader.mpp_type4 leg_mpp_type4,
		legheader.trc_type1 leg_trc_type1,
		legheader.trc_type2 leg_trc_type2,
		legheader.trc_type3 leg_trc_type3,
		legheader.trc_type4 leg_trc_type4,
		ISNULL(manpowerprofile.mpp_type1, 'UNK') mpp_type1,
		ISNULL(manpowerprofile.mpp_type2, 'UNK') mpp_type2,
		ISNULL(manpowerprofile.mpp_type3, 'UNK') mpp_type3, 
		ISNULL(manpowerprofile.mpp_type4, 'UNK') mpp_type4,
		ISNULL(tractorprofile.trc_type1, 'UNK') trc_type1,
		ISNULL(tractorprofile.trc_type2, 'UNK') trc_type2,
		ISNULL(tractorprofile.trc_type3, 'UNK') trc_type3,
		ISNULL(tractorprofile.trc_type4, 'UNK')	trc_type4,	
		'DrvType1',   
		'DrvType2',   
		'DrvType3',   
		'DrvType4',   
		'TrcType1' ,   
		'TrcType2' ,   
		'TrcType3' ,   
		'TrcType4'  ,
		IsNull(pyd_thirdparty_split_percent, 0) pyd_thirdparty_split_percent,
		(select min(lgh_startdate) 	FROM legheader where  legheader.lgh_number = paydetail.lgh_number), --lgh_startdate	
		(select stp_arrivaldate from stops where stp_number = ( select max(stp_number) from stops where mov_number = paydetail.mov_number ) ), -- stp_arrivaldate		
		Case WHEN ( paydetail.pyt_itemcode = 'MN+'  OR paydetail.pyt_itemcode = 'MN-' ) THEN 4
			WHEN ( pyd_pretax = 'N' and pyd_minus = 1 ) THEN 2  
			WHEN ( pyd_pretax = 'N' and pyd_minus = -1 ) THEN 3						
			ELSE 0
		End, -- cc_itemsection	    
		pyd_coowner_split_percent,		-- PTS 54402
		pyd_coowner_split_adj,			-- PTS 54402
		pyd_report_quantity,			-- PTS 54402
		pyd_report_rate,				-- PTS 54402
		isnull(pyt_tax1, 'N') pyt_tax1,
		isnull(pyt_tax2, 'N') pyt_tax2,
		isnull(pyt_tax3, 'N') pyt_tax3,
		isnull(pyt_tax4, 'N') pyt_tax4,
		isnull(pyt_tax5, 'N') pyt_tax5,
		isnull(pyt_tax6, 'N') pyt_tax6,
		isnull(pyt_tax7, 'N') pyt_tax7,
		isnull(pyt_tax8, 'N') pyt_tax8,
		isnull(pyt_tax9, 'N') pyt_tax9,
		isnull(pyt_tax10, 'N') pyt_tax10,
		paydetail.std_purchase_date,             -- PTS 51492
		paydetail.std_purchase_tax_state,        -- PTS 51492
		paydetail.pyd_tax_originator_pyd_number, -- PTS 51492
		pyd_tprsplit_number,	
		pyd_tprdiffbtw_number,
		pyt_garnishmentclassification,			-- vjh 63106
		pyd_RemitToVendorID,						-- vjh 63106
		paydetail.pyd_atd_id,						--PTS62995 SPN
		pyt_AdjustWithNegativePay,				-- vjh 71977
		pyt_sth_abbr,							-- vjh 71977
		sh.sth_priority,						-- vjh 71977
		pyt_sth_priority,						-- vjh 71977
		pyd_pair,								-- vjh 71977
		pyd_branch,								-- vjh 71977
		pyd_fixedRate,							-- nqiao 76582
		pyd_fixedamount,						-- nqiao 76582
		pyd_orig_currency,						-- nqiao 63702
		pyd_orig_amount,						-- nqiao 63702
		pyd_cex_rate,							-- nqiao 63702	
		pyt_requireaudit						--vjh 85922	
FROM  paydetail  
		LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber   
		LEFT OUTER JOIN  purchaseservicedetail  ON  paydetail.psd_number  = purchaseservicedetail.psd_number   
		LEFT OUTER JOIN  payheader  ON  payheader.pyh_pyhnumber  = paydetail.pyh_number 
		Left Outer join legheader on paydetail.lgh_number = legheader.lgh_number
		LEFT OUTER JOIN manpowerprofile on paydetail.asgn_id = manpowerprofile.mpp_id and paydetail.asgn_type = 'DRV'
		LEFT OUTER JOIN tractorprofile on paydetail.asgn_id = tractorprofile.trc_number and paydetail.asgn_type = 'TRC',
		paytype 
		LEFT OUTER JOIN paytypetax ON paytype.pyt_number = paytypetax.pyt_number
		LEFT OUTER JOIN stdhierarchy sh ON sh.sth_abbr = paytype.pyt_sth_abbr
 WHERE  paydetail.ord_hdrnumber = @ordnum AND
        paydetail.asgn_id = @id AND 
        paydetail.asgn_type = @type AND 
        paydetail.pyt_itemcode = paytype.pyt_itemcode 

-- lookup the minimum invoice status for each pay detail for the current order number
UPDATE 	#temp_pay 
   SET 	inv_statuscode = (SELECT	ISNULL(MIN(code) , 0)
							FROM	labelfile, invoiceheader 
						   WHERE	invoiceheader.ord_hdrnumber = #temp_pay.ord_hdrnumber AND
									invoiceheader.ivh_invoicestatus = labelfile.abbr AND 
									labelfile.labeldefinition = 'InvoiceStatus')

-- PTS 45170 <<start>>	-- calculate the cc_xfer_ckbox IF GI setting is ON. 
If exists (select gi_string1 from generalinfo where gi_name = 'STLRELXFER' and gi_string1 = 'WHLTRP')
BEGIN
	Update #temp_pay 
	SET cc_xfer_ckbox = 1
	where pyh_paystatus = 'XFR'
	----where pyh_lgh_number <> 0 AND pyh_paystatus = 'XFR'
	
	Update #temp_pay 
	SET cc_xfer_ckbox = 0
	where cc_xfer_ckbox <> 1
END
-- PTS 45170 <<end>>


SELECT * FROM #temp_pay

DROP TABLE #temp_pay
END	
GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_det_team_sp] TO [public]
GO
