SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Procedure [dbo].[d_stlmnt_det_final_sp] (@phnum INT, @type CHAR(6), @id CHAR(13), @paydate DATETIME)
AS
/* Revision History:
   Date     Name     Label Description
   ----------- ---------------   -------  ------------------------------------------------------------------------------------
   12/20/2001  Vern Jewett vmj1  PTS 11668: When you Collect in final Settlements, the On Hold Pay Details should not
                              disappear from the detail list

   01/23/02    PETE         PTS 12840 add pyt_group to return set to allow standing deduction by pay type group
   01/20/05    DJM   PTS 24118 - Added columns pyd_maxquantity_used and pyd_maxcharge_used to indicate that
            Maximum rate was applied.
   02/25/05 DPETE 26030 added pyh_paystatus (dummy)  to satisfy share with allother d_stlmnt datawindows
   01/18/06 DPH 31343 - Used dummy_pyh_paystatus column to return generalinfo setting 'PerDiemPaytype' for use in window
 * 08/17/2006      PTS32221 - Jason Bauwin - return pyt_exclude_guaranteed_pay for shares
 *  LOR  PTS# 35742  add stp_number, stp_mfh_sequence
 * vjh 39284 add stp_number_pacos
 * 11/06/2007.01 ? PTS40186 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 01/11/2008  JDS   PTS 38870   - Add pyd_createdby and pyd_createdon columns.
 *       pyd_createdby     CHAR(20) NULL, -- PTS 38870
 *       pyd_createdon     datetime NULL  -- PTS 38870
 * 02/04/2008  vjh   PTS   39688 - add pyd_gst_amount and pyd_gst_flag columns
 * LOR   PTS# 40714  added pyd_mileagetable
 * DPETE PTS40260 Pauls recode add mb and nt tax 24081
 * LOR   PTS# 41366  added pyt_otflag, pyt_basisunit
 * LOR   PTS# 44775  added otflag_workfield
 *  3/27/2009 JSwindell PTS45170: New PayHeader col:  pyh_lgh_number
 *  4/24/2009  DJM PTS 43873  Added pyd_min_period field.
 *  7-23-2009 PTS 47021 ********  Add WorkCycle Columns.  pyd_workcycle_status   x30  pyd_workcycle_description   x75
 *  4/28/2010 vjh 42282 add pyd_advstdnum to tie the advance/offset/standing deduction together
 * LOR   PTS# 52563  add pyd_thirdparty_split_percent
 *  10/1/2010  PTS52811 - ( new requires ) (add: lgh_startdate,stp_arrivaldate,cc_itemsection)
  *   05/12/2011  vjh   Add pyd_coowner_split_percent, pyd_coowner_split_adj, pyd_report_quantity, pyd_report_rate
 *	LOR	PTS# 62520	added pyd_tprsplit_number, pyd_tprdiffbtw_number
 * 11/14/2012	vjh 63106 add pyt_garnishmentclassification and pyd_RemitToVendorID
 * 10/02/2012 PTS62995 SPN - add col pyd_atd_id (Tour Detail ID)
 * vjh 66177 use 23:59
 * 05/14/2014 NQIAO PTS 76582 - add 2 new outputs: pyd_fixedrate, pyd_fixedamount 
 * 07/10/2014 PTS 73326;  Fix column-mismatch bug.
 * 02/20/2015 NQIAO PTS63702 - add 3 new outputs: pyd_orig_currency, pyd_orig_amount, pyd_cex_rate
 * 03/13/2015 vjh 85922 add pyt_requireaudit
*/

SET NOCOUNT ON
DECLARE	@v_PerDiemPaytype varchar(60),
		@paydatecheck char(1),		-- PTS 31375 -- BL
		@CollectDate2359 char(1),	-- vjh 66177
		@UseSettlementAudit char(1)	-- vjh 85922

SELECT  @v_PerDiemPaytype = IsNull(gi_string1, '')
FROM  generalinfo
WHERE gi_name = 'PerDiemPaytype'

-- PTS 31375 -- BL 
SELECT @paydatecheck = LEFT(upper(IsNull(gi_string1, 'N')), 1)
FROM  generalinfo
WHERE gi_name = 'UseTransDateInCollect'

--vjh 66177
SELECT	@CollectDate2359 = LEFT(upper(gi_string1), 1)
FROM	generalinfo
WHERE	gi_name = 'CollectDate2359'
if @CollectDate2359 IS null select @CollectDate2359 = 'N'
if @CollectDate2359 = 'Y' select @paydate = CONVERT(VARCHAR(10), @paydate, 101) + ' 23:59:59'

--vjh 85922
SELECT  @UseSettlementAudit = IsNull(gi_string1, '')
FROM  generalinfo
WHERE gi_name = 'UseSettlementAudit'
if @UseSettlementAudit IS null select @UseSettlementAudit = 'N'

IF @phnum > 0
	SELECT   pyd_number,
		pyh_number,
		legheader.lgh_number,
		asgn_number,
		asgn_type,
		asgn_id,
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
		pyd_refnum,			--20
		pyh_payperiod,
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
		paydetail.ord_hdrnumber,	--40
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
		Case (select Isnull(cmp_invoicetype, 'INV') from company where orderheader.ord_billto = company.cmp_id)
			when 'MAS' then
				(SELECT  ISNULL(MIN(code) , 0)
				FROM  labelfile, invoiceheader
				WHERE invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber AND
				invoiceheader.ivh_mbstatus = labelfile.abbr AND
				labelfile.labeldefinition = 'InvoiceStatus')
			else  (SELECT  ISNULL(MIN(code) , 0)
				FROM  labelfile, invoiceheader
				WHERE invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber AND
				invoiceheader.ivh_invoicestatus = labelfile.abbr AND
				labelfile.labeldefinition = 'InvoiceStatus')
		End inv_statuscode,
		pyd_updatedon,
		pyd_currency,			--60
		pyd_currencydate,
		pyd_updsrc,
		0 pyd_changed,
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
		@v_PerDiemPaytype dummy_pyh_paystatus,-- used to return PerDiemPaytype generalinfo setting (not used otherwise)
		pyd_carinvnum,
		pyd_carinvdate,
		std_number_adj,
		pyd_vendortopay,
		pyt_editindispatch,			--80
		pyd_remarks,
		isnull(paytype.pyt_exclude_guaranteed_pay ,'N') pyt_exclude_guaranteed_pay,
		stp_number,
		stp_mfh_sequence,
		pyd_perdiem_exceeded,
		stp_number_pacos,
		pyd_createdby,    -- PTS 38870
		pyd_createdon,    -- PTS 38870
		pyd_gst_amount,      -- vjh PTS 39688
		pyd_gst_flag,     -- vjh PTS 39688
		pyd_mileagetable,
		pyd_mbtaxableamount,
		pyd_nttaxableamount  ,
		--       IsNull(paydetail.pyt_otflag, paytype.pyt_otflag),
		paydetail.pyt_otflag,
		paytype.pyt_basisunit,
		otflag_workfield = paydetail.pyt_otflag,
		0 as 'pyh_lgh_number',  -- pyh_lgh_number,   -- 45170
		0 as 'cc_xfer_ckbox',   -- cc_xfer_ckbox  -- 45170
		pyd_min_period,         -- PTS 43873
		pyd_workcycle_status,      -- PTS 47021			--100
		pyd_workcycle_description,   -- PTS 47021
		paytype.pyt_taxable,
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
		'DrvType1',			-- 120
		'DrvType2',
		'DrvType3',
		'DrvType4',
		'TrcType1' trctype1_t,
		'TrcType2' trctype2_t,
		'TrcType3' trctype3_t,
		'TrcType4' trctype4_t,
		IsNull(pyd_thirdparty_split_percent, 0) pyd_thirdparty_split_percent,
		(select min(lgh_startdate)    FROM legheader where  legheader.lgh_number = paydetail.lgh_number)      as 'lgh_startdate',
		(select stp_arrivaldate from stops where stp_number = ( select max(stp_number) from stops where mov_number = paydetail.mov_number ) ) as 'stp_arrivaldate',
		Case WHEN ( paydetail.pyt_itemcode = 'MN+'  OR paydetail.pyt_itemcode = 'MN-' ) THEN 4
			WHEN ( pyd_pretax = 'N' and pyd_minus = 1 ) THEN 2
			WHEN ( pyd_pretax = 'N' and pyd_minus = -1 ) THEN 3
			ELSE 0
		End as 'cc_itemsection' ,
		pyd_coowner_split_percent,    -- PTS 54402
		pyd_coowner_split_adj,        -- PTS 54402
		pyd_report_quantity,       -- PTS 54402
		pyd_report_rate,           -- PTS 54402
		isnull(pyt_tax1, 'N') pyt_tax1,
		isnull(pyt_tax2, 'N') pyt_tax2,
		isnull(pyt_tax3, 'N') pyt_tax3,
		isnull(pyt_tax4, 'N') pyt_tax4,
		isnull(pyt_tax5, 'N') pyt_tax5,		--140
		isnull(pyt_tax6, 'N') pyt_tax6,
		isnull(pyt_tax7, 'N') pyt_tax7,
		isnull(pyt_tax8, 'N') pyt_tax8,
		isnull(pyt_tax9, 'N') pyt_tax9,
		isnull(pyt_tax10, 'N') pyt_tax10,
		paydetail.std_purchase_date,             -- PTS 51492
		paydetail.std_purchase_tax_state,        -- PTS 51492
		paydetail.pyd_tax_originator_pyd_number, -- PTS 51492
		pyd_tprsplit_number,
		pyd_tprdiffbtw_number,						-- 150
		paytype.pyt_garnishmentclassification,	-- vjh 63106
		pyd_RemitToVendorID,						-- vjh 63106
		paydetail.pyd_atd_id,  --PTS62995 SPN
		pyt_adjustwithnegativepay,			--vjh 71977  -- PTS73326
		pyt_sth_abbr,						--vjh 71977
		sth_priority,						--vjh 71977
		pyt_sth_priority,					--vjh 71977
		pyd_pair,							--vjh 71977
		pyd_branch,						--vjh 71977                                             
		pyd_fixedrate,						-- NQIAO PTS76582
		pyd_fixedamount,					-- NQIAO PTS76582    
		pyd_orig_currency,					-- NQIAO PTS63702
		pyd_orig_amount,					-- NQIAO PTS63702
		pyd_cex_rate,						-- NQIAO PTS63702   
		pyt_requireaudit					--vjh 85922      
	FROM   paydetail  LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber
		LEFT OUTER JOIN  purchaseservicedetail  ON  paydetail.psd_number  = purchaseservicedetail.psd_number
		Left Outer join legheader on paydetail.lgh_number = legheader.lgh_number
		LEFT OUTER JOIN manpowerprofile on paydetail.asgn_id = manpowerprofile.mpp_id and paydetail.asgn_type = 'DRV'
		LEFT OUTER JOIN tractorprofile on paydetail.asgn_id = tractorprofile.trc_number and paydetail.asgn_type = 'TRC',
		paytype
		LEFT OUTER JOIN paytypetax ON paytype.pyt_number = paytypetax.pyt_number
		LEFT OUTER JOIN stdhierarchy sh ON sh.sth_abbr = paytype.pyt_sth_abbr
    WHERE   pyh_number = @phnum AND
         paydetail.pyt_itemcode = paytype.pyt_itemcode

ELSE
IF @type = 'PTO'
	SELECT   pyd_number,
		pyh_number,
		legheader.lgh_number,
		asgn_number,
		asgn_type,
		asgn_id,
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
		pyh_payperiod,
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
		Case (select Isnull(cmp_invoicetype, 'INV') from company where orderheader.ord_billto = company.cmp_id)
			when 'MAS' then
				(SELECT  ISNULL(MIN(code) , 0)
				FROM  labelfile, invoiceheader
				WHERE invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber AND
				invoiceheader.ivh_mbstatus = labelfile.abbr AND
				labelfile.labeldefinition = 'InvoiceStatus')
			else  (SELECT  ISNULL(MIN(code) , 0)
				FROM  labelfile, invoiceheader
				WHERE invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber AND
				invoiceheader.ivh_invoicestatus = labelfile.abbr AND
				labelfile.labeldefinition = 'InvoiceStatus')
		End inv_statuscode,
		pyd_updatedon,
		pyd_currency,
		pyd_currencydate,
		pyd_updsrc,
		0 pyd_changed,
		pyt_agedays,
		pyd_ivh_hdrnumber,
		IsNUll(paytype.pyt_group,'UNK') pyt_group,
		pyd_ref_invoice,
		pyd_ref_invoicedate,
		'N' as calc,
		'N' as edit_status ,
		purchaseservicedetail.psh_number,
		pyd_authcode,
		isNull(pyd_maxquantity_used,'N') pyd_maxquantity_used,
		isNull(pyd_maxcharge_used,'N') pyd_maxcharge_used,
		@v_PerDiemPaytype dummy_pyh_paystatus,-- used to return PerDiemPaytype generalinfo setting (not used otherwise)
		pyd_carinvnum,
		pyd_carinvdate,
		std_number_adj,
		pyd_vendortopay,
		pyt_editindispatch,
		pyd_remarks,
		isnull(paytype.pyt_exclude_guaranteed_pay ,'N') pyt_exclude_guaranteed_pay,
		stp_number,
		stp_mfh_sequence,
		pyd_perdiem_exceeded,
		stp_number_pacos,
		pyd_createdby,    -- PTS 38870
		pyd_createdon,    -- PTS 38870
		pyd_gst_amount,      -- vjh PTS 39688
		pyd_gst_flag,     -- vjh PTS 39688
		pyd_mileagetable,
		pyd_mbtaxableamount,
		pyd_nttaxableamount,
		paydetail.pyt_otflag,
		paytype.pyt_basisunit,
		otflag_workfield = paydetail.pyt_otflag,
		0 as 'pyh_lgh_number',  -- pyh_lgh_number,   -- 45170
		0 as 'cc_xfer_ckbox',   -- cc_xfer_ckbox  -- 45170
		pyd_min_period,      -- PTS 43873
		pyd_workcycle_status,      -- PTS 47021
		pyd_workcycle_description,   -- PTS 47021
		paytype.pyt_taxable,
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
		'TrcType4' trctype4_t,
		IsNull(pyd_thirdparty_split_percent, 0) pyd_thirdparty_split_percent,
		(select min(lgh_startdate)    FROM legheader where  legheader.lgh_number = paydetail.lgh_number)      as 'lgh_startdate',
		( select stp_arrivaldate from stops where stp_number = ( select max(stp_number) from stops where mov_number = paydetail.mov_number ) ) as 'stp_arrivaldate',
		Case WHEN ( paydetail.pyt_itemcode = 'MN+'  OR paydetail.pyt_itemcode = 'MN-' ) THEN 4
			WHEN ( pyd_pretax = 'N' and pyd_minus = 1 ) THEN 2
			WHEN ( pyd_pretax = 'N' and pyd_minus = -1 ) THEN 3
			ELSE 0
		End as 'cc_itemsection',
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
		paytype.pyt_garnishmentclassification,	-- vjh 63106
		pyd_RemitToVendorID,						-- vjh 63106
		paydetail.pyd_atd_id,				--PTS62995 SPN
		pyt_adjustwithnegativepay,			--vjh 71977  -- PTS73326
		pyt_sth_abbr,						--vjh 71977
		sth_priority,						--vjh 71977
		pyt_sth_priority,					--vjh 71977
		pyd_pair,							--vjh 71977
		pyd_branch,							--vjh 71977                                             
		pyd_fixedrate,						-- NQIAO PTS76582
		pyd_fixedamount,					-- NQIAO PTS76582 
		pyd_orig_currency,					-- NQIAO PTS63702
		pyd_orig_amount,					-- NQIAO PTS63702
		pyd_cex_rate,						-- NQIAO PTS63702
		pyt_requireaudit					--vjh 85922      			       
	FROM  paydetail  LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber
		LEFT OUTER JOIN  purchaseservicedetail  ON  paydetail.psd_number  = purchaseservicedetail.psd_number
		Left Outer join legheader on paydetail.lgh_number = legheader.lgh_number
		LEFT OUTER JOIN manpowerprofile on paydetail.asgn_id = manpowerprofile.mpp_id and paydetail.asgn_type = 'DRV'
		LEFT OUTER JOIN tractorprofile on paydetail.asgn_id = tractorprofile.trc_number and paydetail.asgn_type = 'TRC',
		paytype
		LEFT OUTER JOIN paytypetax ON paytype.pyt_number = paytypetax.pyt_number
		LEFT OUTER JOIN stdhierarchy sh ON sh.sth_abbr = paytype.pyt_sth_abbr
    WHERE
		pyh_number = 0 AND
		pyd_payto = @id AND
		(
			(
				pyd_status = 'PND' AND
				pyh_payperiod >= '20491231 00:00:00' AND
				case @paydatecheck when 'Y' Then pyd_transdate else '19500101' end <= @paydate
			) OR (
				pyd_status = 'PND' AND pyh_payperiod = @paydate
			) OR (
				(pyd_status = 'HLD' or (pyd_status = 'AUD' and @UseSettlementAudit = 'P')) AND (pyd_workperiod <= @paydate OR pyd_workperiod >= '20491231 23:59')
			) OR (
				(pyd_status = 'HLD' or (pyd_status = 'AUD' and @UseSettlementAudit = 'P')) AND pyt_agedays > 0 AND DATEADD(day, pyt_agedays, pyd_transdate) < @paydate
			)
		) AND
		paydetail.pyt_itemcode = paytype.pyt_itemcode
ELSE
	SELECT   pyd_number,
		pyh_number,
		legheader.lgh_number,
		asgn_number,
		asgn_type,
		asgn_id,
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
		pyh_payperiod,
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
		Case (select Isnull(cmp_invoicetype, 'INV') from company where orderheader.ord_billto = company.cmp_id)
			when 'MAS' then
				(SELECT  ISNULL(MIN(code) , 0)
				FROM  labelfile, invoiceheader
				WHERE invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber AND
				invoiceheader.ivh_mbstatus = labelfile.abbr AND
				labelfile.labeldefinition = 'InvoiceStatus')
			else  (SELECT  ISNULL(MIN(code) , 0)
				FROM  labelfile, invoiceheader
				WHERE invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber AND
				invoiceheader.ivh_invoicestatus = labelfile.abbr AND
				labelfile.labeldefinition = 'InvoiceStatus')
		End inv_statuscode,
		pyd_updatedon,
		pyd_currency,
		pyd_currencydate,
		pyd_updsrc,
		0 pyd_changed,
		pyt_agedays,
		pyd_ivh_hdrnumber,
		IsNUll(paytype.pyt_group,'UNK') pyt_group,
		pyd_ref_invoice,
		pyd_ref_invoicedate,
		'N' as calc,
		'N' as edit_status ,
		purchaseservicedetail.psh_number,
		pyd_authcode,
		isNull(pyd_maxquantity_used,'N') pyd_maxquantity_used,
		isNull(pyd_maxcharge_used,'N') pyd_maxcharge_used,
		@v_PerDiemPaytype dummy_pyh_paystatus,-- used to return PerDiemPaytype generalinfo setting (not used otherwise)
		pyd_carinvnum,
		pyd_carinvdate,
		std_number_adj,
		pyd_vendortopay,
		pyt_editindispatch,
		pyd_remarks,
		isnull(paytype.pyt_exclude_guaranteed_pay ,'N') pyt_exclude_guaranteed_pay,
		stp_number,
		stp_mfh_sequence,
		pyd_perdiem_exceeded,
		stp_number_pacos,
		pyd_createdby,    -- PTS 38870
		pyd_createdon,    -- PTS 38870
		pyd_gst_amount,      -- vjh PTS 39688
		pyd_gst_flag,     -- vjh PTS 39688
		pyd_mileagetable,
		pyd_mbtaxableamount,
		pyd_nttaxableamount,
		paydetail.pyt_otflag,
		paytype.pyt_basisunit,
		otflag_workfield = paydetail.pyt_otflag,
		0 as 'pyh_lgh_number',  -- pyh_lgh_number,   -- 45170
		0 as 'cc_xfer_ckbox',   -- cc_xfer_ckbox  -- 45170
		pyd_min_period,      -- PTS 43873
		pyd_workcycle_status,      -- PTS 47021
		pyd_workcycle_description,   -- PTS 47021
		paytype.pyt_taxable,
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
		'TrcType4' trctype4_t,
		IsNull(pyd_thirdparty_split_percent, 0) pyd_thirdparty_split_percent,
		(select min(lgh_startdate)    FROM legheader where  legheader.lgh_number = paydetail.lgh_number)      as 'lgh_startdate',
		( select stp_arrivaldate from stops where stp_number = ( select max(stp_number) from stops where mov_number = paydetail.mov_number ) ) as 'stp_arrivaldate',
		Case WHEN ( paydetail.pyt_itemcode = 'MN+'  OR paydetail.pyt_itemcode = 'MN-' ) THEN 4
			WHEN ( pyd_pretax = 'N' and pyd_minus = 1 ) THEN 2
			WHEN ( pyd_pretax = 'N' and pyd_minus = -1 ) THEN 3
			ELSE 0
		End as 'cc_itemsection',
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
		paytype.pyt_garnishmentclassification,	-- vjh 63106
		pyd_RemitToVendorID,						-- vjh 63106
		paydetail.pyd_atd_id,				--PTS62995 SPN
		pyt_adjustwithnegativepay,			--vjh 71977		-- PTS73326
		pyt_sth_abbr,						--vjh 71977
		sth_priority,						--vjh 71977
		pyt_sth_priority,					--vjh 71977
		pyd_pair,							--vjh 71977
		pyd_branch,							--vjh 71977                                             
		pyd_fixedrate,						-- NQIAO PTS76582
		pyd_fixedamount,					-- NQIAO PTS76582 
		pyd_orig_currency,					-- NQIAO PTS63702
		pyd_orig_amount,					-- NQIAO PTS63702
		pyd_cex_rate,						-- NQIAO PTS63702
		pyt_requireaudit					--vjh 85922				
	FROM  paydetail  LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber
		LEFT OUTER JOIN  purchaseservicedetail  ON  paydetail.psd_number  = purchaseservicedetail.psd_number
		Left Outer join legheader on paydetail.lgh_number = legheader.lgh_number
		LEFT OUTER JOIN manpowerprofile on paydetail.asgn_id = manpowerprofile.mpp_id and paydetail.asgn_type = 'DRV'
		LEFT OUTER JOIN tractorprofile on paydetail.asgn_id = tractorprofile.trc_number and paydetail.asgn_type = 'TRC',
		paytype
		LEFT OUTER JOIN paytypetax ON paytype.pyt_number = paytypetax.pyt_number
		LEFT OUTER JOIN stdhierarchy sh ON sh.sth_abbr = paytype.pyt_sth_abbr
    WHERE   
		pyh_number = 0 AND
		asgn_id = @id AND
		asgn_type = @type AND
		(
			(
				pyd_status = 'PND' AND 
				pyh_payperiod >= '20491231 00:00:00' AND
				case @paydatecheck when 'Y' Then pyd_transdate else '19500101' end <= @paydate
			) OR (
				pyd_status = 'PND' AND pyh_payperiod = @paydate
			) OR (
				(pyd_status = 'HLD' or (pyd_status = 'AUD' and @UseSettlementAudit = 'P')) AND (pyd_workperiod <= @paydate OR pyd_workperiod >= '20491231 23:59')
			) OR (
				(pyd_status = 'HLD' or (pyd_status = 'AUD' and @UseSettlementAudit = 'P')) AND pyt_agedays > 0 AND DATEADD(day, pyt_agedays, pyd_transdate) < @paydate
			)
		) AND
		paydetail.pyt_itemcode = paytype.pyt_itemcode

GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_det_final_sp] TO [public]
GO
