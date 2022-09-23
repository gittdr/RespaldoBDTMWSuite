SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[d_stlmnt_det_all_sp] (@ordnum INT, @type varchar(6))
AS


/**
 *
 * NAME:
 * dbo.d_stlmnt_det_all_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns settlements details
 *
 * RETURNS:
 * n/a
 *
 * RESULT SETS:
 * 001 - pyd_number,
 * 002 - pyh_number,
 * 003 - lgh_number,
 * 004 - asgn_number,
 * 005 - asgn_type,
 * 006 - asgn_id,
 * 007 - ivd_number,
 * 008 - pyd_prorap,
 * 009 - pyd_payto,
 * 010 - pyt_itemcode,
 * 011 - pyd_description,
 * 012 - pyr_ratecode,
 * 013 - pyd_quantity,
 * 014 - pyd_rateunit,
 * 015 - pyd_unit,
 * 016 - pyd_pretax,
 * 017 - pyd_glnum,
 * 018 - pyd_status,
 * 019 - pyd_refnumtype,
 * 020 - pyd_refnum,
 * 021 - pyh_payperiod,
 * 022 - lgh_startpoint,
 * 023 - lgh_startcity,
 * 024 - lgh_endpoint,
 * 025 - lgh_endcity,
 * 026 - ivd_payrevenue,
 * 027 - mov_number,
 * 028 - pyd_minus,
 * 029 - pyd_workperiod,
 * 030 - pyd_sequence,
 * 031 - pyd_rate,
 * 032 - pyd_amount,
 * 033 - pyd_revenueratio,
 * 034 - pyd_lessrevenue,
 * 035 - pyd_payrevenue,
 * 036 - std_number,
 * 037 - pyd_loadstate,
 * 038 - pyd_transdate,
 * 039 - pyd_xrefnumber,
 * 040 - ord_hdrnumber,
 * 041 - pyt_basis,
 * 042 - pyt_fee1,
 * 043 - pyt_fee2,
 * 044 - pyd_grossamount,
 * 045 - psd_id,
 * 046 - dummydate,
 * 047 - pyd_updatedby,
 * 048 - pyd_adj_flag,
 * 049 - pyd_exportstatus,
 * 050 - pyd_releasedby,
 * 051 - ord_number,
 * 052 - pyd_billedweight,
 * 053 - cht_itemcode,
 * 054 - tar_tarriffnumber,
 * 055 - psd_batch_id,
 * 056 - ord_revtype1,
 * 057 - revtype1_name,
 * 058 - inv_statuscode,
 * 059 - pyd_updatedon,
 * 060 - pyd_currency,
 * 061 - pyd_currencydate,
 * 062 - pyd_updsrc,
 * 063 - changed,
 * 064 - pyt_agedays,
 * 065 - pyd_ivh_hdrnumber,
 * 066 - pyt_group,
 * 067 - pyd_ref_invoice,
 * 068 - pyd_ref_invoicedate,
 * 069 - 'N' as calc,
 * 070 - 'N' as edit_status ,
 * 071 - psh_number, --17834 Jd
 * 072 - pyd_authcode * 07 - ,
 * 073 - pyd_maxquantity_used,
 * 074 - pyd_maxcharge_used,
 * 075 - pyh_paystatus,
 * 076 - pyd_carinvnum,
 * 077 - pyd_carinvdate,
 * 078 - std_number_adj,
 * 079 - pyd_vendortopay,
 * 080 - pyt_editindispatch, - the Edit in Dispatch flag form the paytype
 * 081 - pyd_remarks
 * 082 - pyt_exclude_guaranteed_pay
 * 083 -
 * 084 -
 * 085 -
 * 086 - stp_number_pacos
 * 087 - pyd_createdby     CHAR(20) NULL, -- PTS 38870
 * 088 - pyd_createdon     datetime NULL  -- PTS 38870
 * undocumented columns
 * 103 - pyd_advstdnum     int         null  -- vjh 42282
 * undocumented columns
 * 151 - pyt_garnishmentclassification	varchar(12) NULL	-- vjh 63106
 * 152 - pyd_RemitToVendorID			varchar(12) NULL	-- vjh 63106 
 * 153 - pyd_atd_id
 * 154 - pyt_AdjustWithNegativePay		VARCHAR(12)	NULL,	--vjh 71977
 * 155 - pyt_sth_abbr					VARCHAR(12)	NULL,	--vjh 71977
 * 156 - sth_priority					INT			NULL,	--vjh 71977
 * 157 - pyt_sth_priority				INT			NULL,	--vjh 71977
 * 158 - pyd_pair						INT			NULL	--vjh 71977
 *
 * PARAMETERS:
 * 001 - @ordnum INT - the ordernumber or move number
 * 002 - @type varchar(6) - 'ORDNUM' for order based pay details or
 *          'MOVE' for move based pay details
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * JET - 7/6/99 - PTS #5987, pulled the code for this option out of d_stlmnt_det_all_sp
 *   01/20/05    DJM PTS 24118 - Added columns pyd_maxquantity_used and pyd_maxcharge_used to indicate that
 *             Maximum rate was applied.
 * DPETE 26871 Return the payheader status
 * 08/08/2005.01 ? PTS25060 - Vince Herman ? return editindispatch from paytype to support filtering and protection
 * 08/17/2006      PTS32221 - Jason Bauwin - return pyt_exclude_guaranteed_pay
 *  LOR  PTS# 35742  add stp_number, stp_mfh_sequence
 * vhg 39284 add stp_number_pacos
 * 11/06/2007.01 ? PTS40186 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 01/11/2008  JDS   PTS 38870   - Add pyd_createdby and pyd_createdon columns.
 *       pyd_createdby     CHAR(20) NULL, -- PTS 38870
 *       pyd_createdon     datetime NULL  -- PTS 38870
 * 4/19/08 40260 recode Pauls Hauling
 * LOR   PTS# 41366  added pyt_otflag, pyt_basisunit
 * LOR   PTS# 44775  added otflag_workfield
 * 3/27/2009 JSwindell PTS45170: New PayHeader col:  pyh_lgh_number
 *  4/24/2009  DJM PTS 43873  Added pyd_min_period field.
 *  7/7/2009  JSwindell  PTS 48160: When Thirdparty on get error.
 *  7-23-2009 PTS 47021 ********  Add WorkCycle Columns.  pyd_workcycle_status   x30  pyd_workcycle_description   x75
 * LOR   PTS# 52563  add pyd_thirdparty_split_percent
 * 10/1/2010  PTS52811 - ( new requires ) (add: lgh_startdate,stp_arrivaldate,cc_itemsection)
 * 05/12/2011  vjh   Add pyd_coowner_split_percent, pyd_coowner_split_adj, pyd_report_quantity, pyd_report_rate
 * LOR	PTS# 62520	added pyd_tprsplit_number, pyd_tprdiffbtw_number
 * 11/14/2012	vjh 63106 add pyt_garnishmentclassification and pyd_RemitToVendorID
 * 10/02/2012 PTS62995 SPN - add col pyd_atd_id (Tour Detail ID)
 * 10/29/2013	vjh	71977 add pyt_AdjustWithNegativePay, pyt_sth_abbr, sth_priority, pyt_sth_priority, pyd_pair
 * 05/15/2014 NQIAO PTS76582 - add 3 new outputs: pyd_fixedrate, pyd_fixedamount
 
 * 03/13/2015	vjh	85922 add pyt_requireaudit
**/

--PTS 62031 NLOKE changes from Mindy to enhance performance
Set nocount on
set transaction isolation level read uncommitted
--end 62031

declare @ll_ivhhdrnum int
declare @v_EditInDispatchGI varchar(60)
Create table #temp (
   pyd_number		int         not null,
   pyh_number		int         not null,
   lgh_number		int         null,
   asgn_number		int         null,
   asgn_type		varchar(6)  null,
   asgn_id			varchar(13) null,
   ivd_number		int         null,
   pyd_prorap		char(1)     null,
   pyd_payto		varchar(12) null,
   pyt_itemcode		varchar(6)  null,
   pyd_description	varchar(75)   null,
   pyr_ratecode		varchar(6)  null,
   pyd_quantity		decimal (12,4) null,
   pyd_rateunit		varchar(6)  null,
   pyd_unit			varchar(6)  null,
   pyd_pretax		char(1)     null,
   pyd_glnum		varchar(32) null,
   pyd_status		varchar(6)  null,
   pyd_refnumtype	varchar(6)  null,
   pyd_refnum		varchar(30) null,
   pyh_payperiod	datetime null,
   lgh_startpoint	varchar(8)  null,
   lgh_startcity	int         null,
   lgh_endpoint		varchar(8)  null,
   lgh_endcity		int         null,
   ivd_payrevenue	money    null,
   mov_number		int         null,
   pyd_minus		int         null,
   pyd_workperiod	datetime null,
   pyd_sequence		int         null,
   pyd_rate			decimal (12,4) null,
   pyd_amount		decimal (12,4) null,
   pyd_revenueratio decimal (12,4) null,
   pyd_lessrevenue  money    null,
   pyd_payrevenue	money    null,
   std_number		int         null,
   pyd_loadstate	varchar(6)  null,
   pyd_transdate	datetime null,
   pyd_xrefnumber	int         null,
   ord_hdrnumber	int         null,
   pyt_basis		varchar(6)  null,
   pyt_fee1			money    null,
   pyt_fee2			money    null,
   pyd_grossamount	money    null,
   psd_id			int         null,
   dummydate		datetime null ,--CONVERT(datetime, NULL) dummydate,
   pyd_updatedby	char(20) null,
   pyd_adj_flag		char(1)     null,
   pyd_exportstatus char(6)   null,
   pyd_releasedby	char(20) null,
   ord_number		varchar(12) null,--CONVERT(varchar(12), ISNULL(ord_number, '0')) ord_number,
   pyd_billedweight int    null,
   cht_itemcode		varchar(6)  null,
   tar_tarriffnumber varchar(12) null,
   psd_batch_id		varchar(16) null,
   ord_revtype1		varchar(6)  null,--CONVERT(varchar(6), ISNULL(ord_revtype1, 'UNK')) ord_revtype1,
   revtype1_name	varchar(20) null, --CONVERT(varchar(20), 'RevType1') revtype1_name,
   inv_statuscode    int         null,--0 inv_statuscode,
   pyd_updatedon     datetime null,
   pyd_currency      varchar(6)  null,    --60
   pyd_currencydate  datetime null,
   pyd_updsrc        char(1)     null,
   changed           int         null ,--CONVERT(INT, 0) changed,
   pyt_agedays       int         null,
   pyd_ivh_hdrnumber int         null,
   pyt_group         varchar(6)  null,
   pyd_ref_invoice      varchar(15) null,
   pyd_ref_invoicedate  datetime null,
   psh_number        integer     null,
   pyd_authcode      varchar(30) null,
   pyd_maxquantity_used char(1),
   pyd_maxcharge_used   char(1),
   pyh_paystatus     varchar(6)  NULL,
   pyd_carinvnum     varchar(30) NULL,
   pyd_carinvdate    datetime NULL,
   std_number_adj    int         null,
   pyd_vendortopay      varchar(12) null,
   pyt_editindispatch   integer     null,
   pyd_remarks       varchar(254) null,
   pyt_exclude_guaranteed_pay char(1) null,
   stp_number        INTEGER     NULL,
   stp_mfh_sequence  INTEGER     NULL,
   pyd_perdiem_exceeded CHAR(1)  NULL,
   stp_number_pacos  int         null,
   pyd_createdby     CHAR(20) NULL, -- PTS 38870
   pyd_createdon     datetime NULL, -- PTS 38870,
   pyd_gst_amount  money null,
   pyd_gst_flag      int null,
   pyd_mileagetable  char(2) null,
   pyd_mbtaxableamount money null,
   pyd_nttaxableamount money null,
   pyt_otflag  char(1) null,
   pyt_basisunit  varchar(6) null,
   otflag_workfield  char(1) null,
   pyh_lgh_number    INTEGER     NULL, -- 45170
   cc_xfer_ckbox     INTEGER     NULL, -- 45170
   pyd_min_period    datetime NULL, -- PTS 43873
   pyd_workcycle_status   VARCHAR(30)  NULL,   -- PTS 47021
   pyd_workcycle_description  VARCHAR(75) NULL,   -- PTS 47021
   pyt_taxable       char(1)     null, --MRH 45723
   pyd_advstdnum     integer, --vjh 42282
   leg_mpp_type1     Varchar(6)  null,       -- PTS 48237
   leg_mpp_type2     Varchar(6)  null,       -- PTS 48237
   leg_mpp_type3     Varchar(6)  null,       -- PTS 48237
   leg_mpp_type4     Varchar(6)  null,       -- PTS 48237
   leg_trc_type1     Varchar(6)  null,       -- PTS 48237
   leg_trc_type2     Varchar(6)  null,       -- PTS 48237
   leg_trc_type3     Varchar(6)  null,       -- PTS 48237
   leg_trc_type4     Varchar(6)  null,       -- PTS 48237
   mpp_type1         Varchar(6)  null,       -- PTS 48237
   mpp_type2         Varchar(6)  null,       -- PTS 48237
   mpp_type3         Varchar(6)  null,       -- PTS 48237
   mpp_type4         Varchar(6)  null,       -- PTS 48237
   trc_type1         Varchar(6)  null,       -- PTS 48237
   trc_type2         Varchar(6)  null,       -- PTS 48237
   trc_type3         Varchar(6)  null,       -- PTS 48237
   trc_type4         Varchar(6)  null,       -- PTS 48237
   mpp_type1_t       Varchar(10) null,       -- PTS 48237
   mpp_type2_t       Varchar(10) null,       -- PTS 48237
   mpp_type3_t       Varchar(10) null,       -- PTS 48237
   mpp_type4_t       Varchar(10) null,       -- PTS 48237
   Trctype1_t        Varchar(10) null,       -- PTS 48237
   Trctype2_t        Varchar(10) null,       -- PTS 48237
   Trctype3_t        Varchar(10) null,       -- PTS 48237
   Trctype4_t        Varchar(10) null,       -- PTS 48237
   pyd_thirdparty_split_percent  float  null,
   lgh_startdate     datetime null,
   stp_arrivaldate      datetime null,
   cc_itemsection    INTEGER     NULL,
   pyd_coowner_split_percent  float NULL,    -- PTS 54402
   pyd_coowner_split_adj char(1) NULL,       -- PTS 54402
   pyd_report_quantity  money    NULL,       -- PTS 54402
   pyd_report_rate      money    NULL,       -- PTS 54402
   pyt_tax1       Varchar(1)  NULL,
   pyt_tax2       Varchar(1)  NULL,
   pyt_tax3       Varchar(1)  NULL,
   pyt_tax4       Varchar(1)  NULL,
   pyt_tax5       Varchar(1)  NULL,
   pyt_tax6       Varchar(1)  NULL,
   pyt_tax7       Varchar(1)  NULL,
   pyt_tax8       Varchar(1)  NULL,
   pyt_tax9       Varchar(1)  NULL,
	pyt_tax10         Varchar(1)  NULL,
	std_purchase_date               DATETIME    NULL,  -- PTS 51492
	std_purchase_tax_state          VARCHAR(6)  NULL,  -- PTS 51492
	pyd_tax_originator_pyd_number   INT         NULL,  -- PTS 51492
	pyd_tprsplit_number	int null,
	pyd_tprdiffbtw_number int null,
	pyt_garnishmentclassification	varchar(12) NULL,  -- vjh 63106
	pyd_RemitToVendorID				varchar(12) NULL,  -- vjh 63106
	pyd_atd_id    INT NULL, --PTS62995 SPN
	pyt_AdjustWithNegativePay		VARCHAR(12)	NULL,	--vjh 71977
	pyt_sth_abbr					VARCHAR(12)	NULL,	--vjh 71977
	sth_priority					INT			NULL,	--vjh 71977
	pyt_sth_priority				INT			NULL,	--vjh 71977
	pyd_pair						INT			NULL,	--vjh 71977
	pyd_branch						varchar(12)	NULL,	--vjh 71977
	pyd_fixedrate					char(1)		NULL,	-- nqiao 76582
	pyd_fixedamount					char(1)		NULL,	-- nqiao 76582
	pyd_orig_currency				varchar(6)	NULL,	-- nqiao 63702
	pyd_orig_amount					money		NULL,	-- nqiao 63702
	pyd_cex_rate					money		NULL,	-- nqiao 63702
	pyt_requireaudit				char(1)		NULL
)

-- Used on D_STLMNT_DET_ALL which shares with D_STLMNT_DET (another proc) and D_STLMNT_ADTNL_DET (SQL in dw)
If @ordnum > 0
   Insert into #temp
   SELECT pyd_number,
      pyh_number,
      paydetail.lgh_number,      -- pts 48160 (specify table)
      asgn_number,
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
      pyd_currency,     --60
      pyd_currencydate,
      pyd_updsrc,
      CONVERT(INT, 0) changed,
      pyt_agedays,
      pyd_ivh_hdrnumber,   --65
      pyt_group,
      pyd_ref_invoice,
      pyd_ref_invoicedate,
      psh_number,
      pyd_authcode,
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
      pyd_createdby,       -- PTS 38870
      pyd_createdon,       -- PTS 38870
      pyd_gst_amount,
      pyd_gst_flag,
      pyd_mileagetable,
      pyd_mbtaxableamount,
      pyd_nttaxableamount,
--    IsNull(paydetail.pyt_otflag, paytype.pyt_otflag),
      paydetail.pyt_otflag,
      paytype.pyt_basisunit,
      otflag_workfield = paydetail.pyt_otflag,
      ISNULL(pyh_lgh_number, 0) pyh_lgh_number, -- 45170
      0,                -- cc_xfer_ckbox  -- 45170
      isNull(pyd_min_period, paydetail.pyh_payperiod) pyd_min_period,      -- PTS 43873
      pyd_workcycle_status,       -- PTS 47021
      pyd_workcycle_description,    -- PTS 47021
      isnull(pyt_taxable, 'Y') pyt_taxable,
      pyd_advstdnum,          --vjh 42282
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
      ISNULL(tractorprofile.trc_type4, 'UNK')   trc_type4,
      'DrvType1',
      'DrvType2',
      'DrvType3',
      'DrvType4',
      'TrcType1' trctype1_t,
      'TrcType2' trctype2_t,
      'TrcType3' trctype3_t,
      'TrcType4' trctype4_t ,
      IsNull(pyd_thirdparty_split_percent, 0) pyd_thirdparty_split_percent,
      (select min(lgh_startdate)    FROM legheader where  legheader.lgh_number = paydetail.lgh_number), --lgh_startdate
      (select stp_arrivaldate from stops where stp_number = ( select max(stp_number) from stops where mov_number = paydetail.mov_number ) ), -- stp_arrivaldate
      Case WHEN ( paydetail.pyt_itemcode = 'MN+'  OR paydetail.pyt_itemcode = 'MN-' ) THEN 4
                  WHEN ( pyd_pretax = 'N' and pyd_minus = 1 ) THEN 2
                  WHEN ( pyd_pretax = 'N' and pyd_minus = -1 ) THEN 3
                  ELSE 0
      End, -- cc_itemsection
      pyd_coowner_split_percent,    -- PTS 54402
      pyd_coowner_split_adj,        -- PTS 54402
      pyd_report_quantity,       -- PTS 54402
      pyd_report_rate,           -- PTS 54402
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
		paydetail.pyd_atd_id,  --PTS62995 SPN
		pyt_AdjustWithNegativePay,				-- vjh 71977
		pyt_sth_abbr,							-- vjh 71977
		sh.sth_priority,						-- vjh 71977
		pyt_sth_priority,						-- vjh 71977
		pyd_pair,								-- vjh 71977
		pyd_branch,								-- vjh 71977
		pyd_fixedrate,							-- nqiao 76582
		pyd_fixedamount,						-- nqiao 76582
		pyd_orig_currency,						-- nqiao 63702
		pyd_orig_amount,						-- nqiao 63702
		pyd_cex_rate,							-- nqiao 63702
		pyt_requireaudit						-- vjh 85922
     FROM  paydetail
         LEFT OUTER JOIN  purchaseservicedetail  ON  paydetail.psd_number  = purchaseservicedetail.psd_number
         LEFT OUTER JOIN  payheader  ON  payheader.pyh_pyhnumber  = paydetail.pyh_number /*-- RE - 4/30/04 - PTS #22646*/
         Left Outer join legheader on paydetail.lgh_number = legheader.lgh_number
         LEFT OUTER JOIN manpowerprofile on paydetail.asgn_id = manpowerprofile.mpp_id and paydetail.asgn_type = 'DRV'
         LEFT OUTER JOIN tractorprofile on paydetail.asgn_id = tractorprofile.trc_number and paydetail.asgn_type = 'TRC',
           paytype
         LEFT OUTER JOIN paytypetax ON paytype.pyt_number = paytypetax.pyt_number
         LEFT OUTER JOIN stdhierarchy sh ON sh.sth_abbr = paytype.pyt_sth_abbr,
           orderheader
    WHERE paydetail.pyt_itemcode = paytype.pyt_itemcode AND
      paydetail.ord_hdrnumber = orderheader.ord_hdrnumber AND
      ((paydetail.ord_hdrnumber = @ordnum AND @type = 'ORDNUM') OR
      (paydetail.mov_number = @ordnum AND @type = 'MOVE'))

-- RE - 4/30/04 - PTS #22646
ELSE IF @ordnum < 0
   BEGIN
      select @ll_ivhhdrnum = @ordnum * -1
      Insert into #temp
      SELECT pyd_number,
         pyh_number,
         paydetail.lgh_number,   -- pts 48160 (specify table)
         asgn_number,
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
         '0' ord_number,
         pyd_billedweight,
         paydetail.cht_itemcode,
         paydetail.tar_tarriffnumber,
         psd_batch_id,
         'UNK' ord_revtype1,
         CONVERT(varchar(20), 'RevType1') revtype1_name,
         0 inv_statuscode,
         pyd_updatedon,
         pyd_currency,        --60
         pyd_currencydate,
         pyd_updsrc,
         CONVERT(INT, 0) changed,
         pyt_agedays,
         pyd_ivh_hdrnumber,      --65
         pyt_group,
         pyd_ref_invoice,
         pyd_ref_invoicedate,
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
         pyd_createdby,       -- PTS 38870
         pyd_createdon,       -- PTS 38870
         pyd_gst_amount,
         pyd_gst_flag,
         pyd_mileagetable,
           pyd_mbtaxableamount,
         pyd_nttaxableamount,
--       IsNull(paydetail.pyt_otflag, paytype.pyt_otflag),
         paydetail.pyt_otflag,
         paytype.pyt_basisunit,
         otflag_workfield = paydetail.pyt_otflag,
         ISNULL(pyh_lgh_number, 0) pyh_lgh_number, -- 45170
         0,                -- cc_xfer_ckbox  -- 45170
         isNull(pyd_min_period, paydetail.pyh_payperiod) pyd_min_period,      -- PTS 43873
         pyd_workcycle_status,       -- PTS 47021
         pyd_workcycle_description,    -- PTS 47021
         isnull(pyt_taxable, 'Y') pyt_taxable,
         pyd_advstdnum,          --vjh 42282
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
         ISNULL(tractorprofile.trc_type4, 'UNK')   trc_type4,
         'DrvType1',
         'DrvType2',
         'DrvType3',
         'DrvType4',
         'TrcType1' trctype1_t,
         'TrcType2' trctype2_t,
         'TrcType3' trctype3_t,
         'TrcType4' trctype4_t ,
         IsNull(pyd_thirdparty_split_percent, 0) pyd_thirdparty_split_percent,
         (select min(lgh_startdate)    FROM legheader where  legheader.lgh_number = paydetail.lgh_number), --lgh_startdate
         (select stp_arrivaldate from stops where stp_number = ( select max(stp_number) from stops where mov_number = paydetail.mov_number ) ), -- stp_arrivaldate
         Case WHEN ( paydetail.pyt_itemcode = 'MN+'  OR paydetail.pyt_itemcode = 'MN-' ) THEN 4
                  WHEN ( pyd_pretax = 'N' and pyd_minus = 1 ) THEN 2
                  WHEN ( pyd_pretax = 'N' and pyd_minus = -1 ) THEN 3
                  ELSE 0
         End, -- cc_itemsection
         pyd_coowner_split_percent,    -- PTS 54402
         pyd_coowner_split_adj,        -- PTS 54402
         pyd_report_quantity,       -- PTS 54402
         pyd_report_rate,           -- PTS 54402
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
			pyd_RemitToVendorID,					-- vjh 63106
			paydetail.pyd_atd_id,					--PTS62995 SPN
			pyt_AdjustWithNegativePay,				-- vjh 71977
			pyt_sth_abbr,							-- vjh 71977
			sh.sth_priority,						-- vjh 71977
			pyt_sth_priority,						-- vjh 71977
			pyd_pair,								-- vjh 71977
			pyd_branch,								-- vjh 71977			
			pyd_fixedrate,							-- nqiao 76582
			pyd_fixedamount,						-- nqiao 76582			
			pyd_orig_currency,						-- nqiao 63702
			pyd_orig_amount,						-- nqiao 63702
			pyd_cex_rate,							-- nqiao 63702
			pyt_requireaudit						-- vjh 85922
        --pts40186 jguo outer join conversion
        FROM  paydetail
			LEFT OUTER JOIN  purchaseservicedetail  ON  paydetail.psd_number  = purchaseservicedetail.psd_number
			LEFT OUTER JOIN  payheader  ON  payheader.pyh_pyhnumber  = paydetail.pyh_number
			Left Outer join legheader on paydetail.lgh_number = legheader.lgh_number
			LEFT OUTER JOIN manpowerprofile on paydetail.asgn_id = manpowerprofile.mpp_id and paydetail.asgn_type = 'DRV'
			LEFT OUTER JOIN tractorprofile on paydetail.asgn_id = tractorprofile.trc_number and paydetail.asgn_type = 'TRC',
			paytype
			LEFT OUTER JOIN paytypetax ON paytype.pyt_number = paytypetax.pyt_number
			LEFT OUTER JOIN stdhierarchy sh ON sh.sth_abbr = paytype.pyt_sth_abbr
       WHERE paydetail.pyt_itemcode = paytype.pyt_itemcode AND
         paydetail.pyd_ivh_hdrnumber = @ll_ivhhdrnum
   END

-- lookup the minimum invoice status for each pay detail for the current order number
UPDATE #temp
   SET inv_statuscode = (SELECT ISNULL(MIN(code), 0)
                           FROM labelfile, invoiceheader
                          WHERE invoiceheader.ord_hdrnumber = #temp.ord_hdrnumber AND
                                invoiceheader.ivh_invoicestatus = labelfile.abbr AND
                                labelfile.labeldefinition = 'InvoiceStatus')

-- vjh 25060 clear the EditInDispatch flags if the GI setting is not on
select @v_EditInDispatchGI = gi_string1
                 from generalinfo
                where gi_name = 'EnforceEditInDispatch'
select @v_EditInDispatchGI = isnull(left(upper(@v_EditInDispatchGI),1),'N')
if @v_EditInDispatchGI <> 'Y' update #temp set pyt_editindispatch = 0


-- PTS 45170 <<start>>  -- calculate the cc_xfer_ckbox IF GI setting is ON.
If exists (select gi_string1 from generalinfo where gi_name = 'STLRELXFER' and gi_string1 = 'WHLTRP')
BEGIN
   Update #temp
   SET cc_xfer_ckbox = 1
   where pyh_paystatus = 'XFR'
   ----where pyh_lgh_number <> 0 AND pyh_paystatus = 'XFR'

   Update #temp
   SET cc_xfer_ckbox = 0
   where cc_xfer_ckbox <> 1
END
-- PTS 45170 <<end>>

--vmj1+  PTS 13030   01/23/2002  Add a column which is used by PayDetailCorrection window to
-- indicate which rows need to be deleted before the Calc is run..
SELECT pyd_number,
	pyh_number,
	lgh_number,
	asgn_number,
	asgn_type,
	asgn_id,
	ivd_number,
	pyd_prorap,
	pyd_payto,
	pyt_itemcode,		--10
	pyd_description,
	pyr_ratecode,
	pyd_quantity,
	pyd_rateunit,
	pyd_unit,
	pyd_pretax,
	pyd_glnum,
	pyd_status,
	pyd_refnumtype,
	pyd_refnum,			--20
	pyh_payperiod,
	lgh_startpoint,
	lgh_startcity,
	lgh_endpoint,
	lgh_endcity,
	ivd_payrevenue,
	mov_number,
	pyd_minus,
	pyd_workperiod,
	pyd_sequence,		--30
	pyd_rate,
	pyd_amount,
	pyd_revenueratio,
	pyd_lessrevenue,
	pyd_payrevenue,
	std_number,
	pyd_loadstate,
	pyd_transdate,
	pyd_xrefnumber,
	ord_hdrnumber,		--40
	pyt_basis,
	pyt_fee1,
	pyt_fee2,
	pyd_grossamount,
	psd_id,
	dummydate,
	pyd_updatedby,
	pyd_adj_flag,
	pyd_exportstatus,
	pyd_releasedby,		--50
	ord_number,
	pyd_billedweight,
	cht_itemcode,
	tar_tarriffnumber,
	psd_batch_id,
	ord_revtype1,
	revtype1_name,
	inv_statuscode,
	pyd_updatedon,
	pyd_currency,        --60
	pyd_currencydate,
	pyd_updsrc,
	changed,
	pyt_agedays,
	pyd_ivh_hdrnumber,
	pyt_group,
	pyd_ref_invoice,
	pyd_ref_invoicedate,
	'N' as calc,
	'N' as edit_status , --70
	psh_number, --17834 Jd
	pyd_authcode   ,
	pyd_maxquantity_used,
	pyd_maxcharge_used,
	pyh_paystatus,
	pyd_carinvnum,
	pyd_carinvdate,
	std_number_adj,
	pyd_vendortopay,
	pyt_editindispatch,	--80
	pyd_remarks,
	pyt_exclude_guaranteed_pay,
	stp_number,
	stp_mfh_sequence,
	pyd_perdiem_exceeded,
	stp_number_pacos,
	pyd_createdby,
	pyd_createdon,
	pyd_gst_amount,
	pyd_gst_flag,		--90
	pyd_mileagetable,
	pyd_mbtaxableamount,
	pyd_nttaxableamount,
	pyt_otflag,
	pyt_basisunit,
	otflag_workfield,
	pyh_lgh_number,   -- 45170
	cc_xfer_ckbox, -- 45170
	pyd_min_period,   -- PTS 43873
	pyd_workcycle_status,       -- PTS 47021  --100
	pyd_workcycle_description,    -- PTS 47021
	pyt_taxable,
	pyd_advstdnum,
	leg_mpp_type1,
	leg_mpp_type2,
	leg_mpp_type3,
	leg_mpp_type4,
	leg_trc_type1,
	leg_trc_type2,
	leg_trc_type3,		--110
	leg_trc_type4,
	mpp_type1,
	mpp_type2,
	mpp_type3,
	mpp_type4,
	trc_type1,
	trc_type2,
	trc_type3,
	trc_type4,
	'DrvType1',			--120
	'DrvType2',
	'DrvType3',
	'DrvType4',
	'TrcType1' trctype1_t,
	'TrcType2' trctype2_t,
	'TrcType3' trctype3_t,
	'TrcType4' trctype4_t ,
	pyd_thirdparty_split_percent,
	lgh_startdate,
	stp_arrivaldate,		--130
	cc_itemsection,
	pyd_coowner_split_percent,    -- PTS 54402
	pyd_coowner_split_adj,        -- PTS 54402
	pyd_report_quantity,       -- PTS 54402
	pyd_report_rate,              -- PTS 54402
	pyt_tax1,
	pyt_tax2,
	pyt_tax3,
	pyt_tax4,
	pyt_tax5,			--140
	pyt_tax6,
	pyt_tax7,
	pyt_tax8,
	pyt_tax9,
	pyt_tax10,
	std_purchase_date,
	std_purchase_tax_state,
	pyd_tax_originator_pyd_number,
	pyd_tprsplit_number,
	pyd_tprdiffbtw_number,	--150
	pyt_garnishmentclassification,	-- vjh 63106	--151
	pyd_RemitToVendorID,			-- vjh 63106	--152
	pyd_atd_id,						--PTS62995 SPN
	pyt_AdjustWithNegativePay,		-- vjh 71977	--154
	pyt_sth_abbr,					-- vjh 71977	--155
	sth_priority,					-- vjh 71977	--156
	pyt_sth_priority,				-- vjh 71977	--157
	pyd_pair,						-- vjh 71977	--158
	pyd_branch,						-- vjh 71977	--159
	pyd_fixedrate,					-- nqiao 76582	--160
	pyd_fixedamount,				-- nqiao 76582	--161
	pyd_orig_currency,				-- nqiao 63702	--162
	pyd_orig_amount,				-- nqiao 63702	--163
	pyd_cex_rate,					-- nqiao 63702	--164
	pyt_requireaudit				-- vjh 85922
FROM #temp

GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_det_all_sp] TO [public]
GO
