SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Procedure [dbo].[d_stlmnt_det_final_PH_by_LegalEntity_sp] (@phnum INT, @type CHAR(6), @id CHAR(13), @paydate DATETIME)
AS

Set NoCount On

/* Revision History:
	Date		Name		Label	Description
	-----------	---------------	-------	------------------------------------------------------------------------------------
	
	3/28/2012	JSwindell	PTS 60458   Created.	
	6/5/2012    Total Re-write:   60458.QAFix  5/25/12 
	11/12/2012	JSwindell	PTS 65823.BugFix	
	12/14/12	JSwindell	PTS 61351:  REMOVE any parent-child table updates and use d_StlFinalPayDetails_custom_sp		
	1/03/2013	PTS 66293	Correct Error Condition Handling to prevent row/column mismatch errors on dwo.
	1/21/2013   PTS 66293-2: QA identified proc issue
	1/28/2013	PTS 66293-3: QA (Invalid data needs to be handled better)
	3/06/2014	PTS 75701:	 fix call to another-custom stored proc. 
*/

if @phnum = -99 set @phnum = -1

declare @LglEntityCount		int
declare @LglEntityList		varchar(256)
declare @distinctPHCount	int
declare @ThisAssets_allocation_Entity varchar(6)
declare @ThisAssets_branch varchar(12)
set		@LglEntityCount		= 0
set		@LglEntityList		= ''
set		@distinctPHCount	= 0
set		@ThisAssets_allocation_Entity = ''
set		@ThisAssets_branch = ''
declare @MultiPHCount		int
declare @tmp_PHNbr			int
declare @tmp_LoopCnt		int
declare @brnvalidcnt		int
declare @LglEvalidcnt		int
declare @FinalAllocation_branch varchar(12)  -- PTS 61351
declare @FinalAllocation_entity varchar(6)	 -- PTS 61351
declare @UNK1				varchar(12) 
declare @UNK2				varchar(12) 
set	@UNK1 = 'UNK'
set @UNK2 = 'UNKNOWN'

declare @CustomGISet		char(1)
set @CustomGISet = 'N' 
if exists (select 1 from generalinfo where gi_name = 'StlUseBranchPerPYHNumber' and gi_string1 = 'Y')  
	begin
		set @CustomGISet = 'Y'
	end 

Declare @DistinctMultiPH TABLE (pyh_pyhnumber int null,  MPHIdentity int identity(1,1) NOT NULL)
Insert  @DistinctMultiPH(pyh_pyhnumber)
select distinct(pyh_pyhnumber) 
		from payheader 
		where asgn_id = @id
		and asgn_type = @type
		and pyh_payperiod = @paydate

set @MultiPHCount = (select count(*)  from @DistinctMultiPH)
	 
-- this temp table is populated by the resultset of d_stlmnt_det_final_sp as of 4/5/2012. 
Create Table #tmp_PHbyPayto (	
					pyd_number			int null, 			--	1
					pyh_number			int null, 			--	2
					lgh_number			int null, 			--	3
					asgn_number			int null, 			--	4
					asgn_type			varchar(6) null, 	--	5
					asgn_id				varchar(13) null, 	--	6
					ivd_number			int	null, 			--	7
					pyd_prorap			char(1) null, 		--	8
					pyd_payto			varchar(12) null, 	--	9
					pyt_itemcode		varchar(6) null, 	--	10
					pyd_description		varchar(100) null, 	--	11
					pyr_ratecode		varchar(6) null, 	--	12
					pyd_quantity		float null,			--	13
					pyd_rateunit		varchar(6) null, 	--	14
					pyd_unit			varchar(6) null, 	--	15
					pyd_pretax			char(1) null, 		--	16
					pyd_glnum			varchar(32) null, 	--	17
					pyd_status			varchar(6) null, 	--	18
					pyd_refnumtype		varchar(6) null, 	--	19
					pyd_refnum			varchar(30) null, 	--	20
					pyh_payperiod		datetime null,		--	21
					lgh_startpoint		varchar(8) null, 	--	22
					lgh_startcity		int null, 			--	23
					lgh_endpoint		varchar(8) null, 	--	24
					lgh_endcity			int null, 			--	25
					ivd_payrevenue		money null, 		--	26
					mov_number			int null, 			--	27
					pyd_minus			int null, 			--	28
					pyd_workperiod		datetime null,		--	29
					pyd_sequence		int null, 			--	30
					pyd_rate			money null, 		--	31
					pyd_amount			money null, 		--	32
					pyd_revenueratio	float null,			--	33
					pyd_lessrevenue		money null, 		--	34
					pyd_payrevenue		money null, 		--	35
					std_number			int null, 			--	36
					pyd_loadstate		varchar(6) null, 	--	37
					pyd_transdate		datetime null,		--	38
					pyd_xrefnumber		int null, 			--	39
					ord_hdrnumber		int null, 			--	40
					pyt_basis			varchar(6) null, 	--	41
					pyt_fee1			money null, 		--	42
					pyt_fee2			money null, 		--	43
					pyd_grossamount		money null, 		--	44
					psd_id				int null, 			--	45
					dummydate			datetime null,		--	46
					pyd_updatedby		varchar(20) null, 	--	47
					pyd_adj_flag		char(1) null, 		--	48
					pyd_exportstatus	varchar(6) null, 	--	49
					pyd_releasedby		varchar(20) null, 	--	50
					ord_number			varchar(12) null, 	--	51
					pyd_billedweight	int null, 			--	52
					cht_itemcode		varchar(6) null, 	--	53
					tar_tarriffnumber	varchar(12) null, 	--	54
					psd_batch_id		varchar(16) null, 	--	55
					ord_revtype1		varchar(6) null, 	--	56
					revtype1_name		varchar(20) null, 	--	57
					inv_statuscode		int null, 			--	58
					pyd_updatedon		datetime null,		--	59
					pyd_currency		varchar(6) null, 	--	60
					pyd_currencydate	datetime null,		--	61
					pyd_updsrc			char(1) null, 		--	62
					pyd_changed			int null, 			--	63
					pyt_agedays			int null, 			--	64
					pyd_ivh_hdrnumber	int null, 			--	65
					pyt_group			varchar(6) null, 	--	66
					pyd_ref_invoice		varchar(15) null, 	--	67
					pyd_ref_invoicedate	datetime null,		--	68
					calc				char(1) null, 		--	69
					edit_status			char(1) null, 		--	70
					psh_number			int null, 			--	71
					pyd_authcode		varchar(30) null, 	--	72
					pyd_maxquantity_used char(1) null, 		--	73
					pyd_maxcharge_used	 char(1) null, 		--	74
					dummy_pyh_paystatus	varchar(60) null, 	--	75
					pyd_carinvnum		varchar(30) null, 	--	76
					pyd_carinvdate		datetime null,		--	77
					std_number_adj		int null, 			--	78
					pyd_vendortopay		varchar(12) null, 	--	79
					pyt_editindispatch	int null, 			--	80
					pyd_remarks			varchar(254) null, 	--	81
					pyt_exclude_guaranteed_pay	 char(1) null, 	--	82
					stp_number			int null, 			--	83
					stp_mfh_sequence	int null, 			--	84
					pyd_perdiem_exceeded	 char(1) null, 	--	85
					stp_number_pacos	int null, 			--	86
					pyd_createdby		varchar(20) null, 	--	87
					pyd_createdon		datetime null,		--	88
					pyd_gst_amount		money null, 		--	89
					pyd_gst_flag		int null, 			--	90
					pyd_mileagetable	varchar(2) null, 	--	91
					pyd_mbtaxableamount	money null, 		--	92
					pyd_nttaxableamount	money null, 		--	93
					pyt_otflag			char(1) null, 		--	94
					pyt_basisunit		varchar(6) null, 	--	95
					otflag_workfield	char(1) null, 		--	96
					pyh_lgh_number		int null, 			--	97
					cc_xfer_ckbox		int null, 			--	98
					pyd_min_period		datetime null,		--	99
					pyd_workcycle_status	varchar(30) null, 		--	100
					pyd_workcycle_description	varchar(75) null, 	--	101
					pyt_taxable			char(1) null, 		--	102
					pyd_advstdnum		int null, 			--	103
					leg_mpp_type1		varchar(6) null, 	--	104
					leg_mpp_type2		varchar(6) null, 	--	105
					leg_mpp_type3		varchar(6) null, 	--	106
					leg_mpp_type4		varchar(6) null, 	--	107
					leg_trc_type1		varchar(6) null, 	--	108
					leg_trc_type2		varchar(6) null, 	--	109
					leg_trc_type3		varchar(6) null, 	--	110
					leg_trc_type4		varchar(6) null, 	--	111
					mpp_type1			varchar(6) null, 	--	112
					mpp_type2			varchar(6) null, 	--	113
					mpp_type3			varchar(6) null, 	--	114
					mpp_type4			varchar(6) null, 	--	115
					trc_type1			varchar(6) null, 	--	116
					trc_type2			varchar(6) null, 	--	117
					trc_type3			varchar(6) null, 	--	118
					trc_type4			varchar(6) null, 	--	119
					DrvType1			varchar(8) null ,	--	120
					DrvType2			varchar(8) null , 	--	121
					DrvType3			varchar(8) null , 	--	122
					DrvType4			varchar(8) null , 	--	123
					trctype1_t			varchar(8) null, 	--	124
					trctype2_t			varchar(8) null, 	--	125
					trctype3_t			varchar(8) null, 	--	126
					trctype4_t			varchar(8) null, 	--	127
					pyd_thirdparty_split_percent	float null,		--	128
					lgh_startdate		datetime null,		--	129
					stp_arrivaldate		datetime null,		--	130
					cc_itemsection		int null, 			--	131
					pyd_coowner_split_percent	float null,	--	132
					pyd_coowner_split_adj	 char(1) null, 	--	133
					pyd_report_quantity	money null, 		--	134
					pyd_report_rate		money null, 		--	135
					pyt_tax1			varchar(6) null, 	--	136
					pyt_tax2			varchar(6) null, 	--	137
					pyt_tax3			varchar(6) null, 	--	138
					pyt_tax4			varchar(6) null, 	--	139
					pyt_tax5			varchar(6) null, 	--	140
					pyt_tax6			varchar(6) null, 	--	141
					pyt_tax7			varchar(6) null, 	--	142
					pyt_tax8			varchar(6) null, 	--	143
					pyt_tax9			varchar(6) null, 	--	144
					pyt_tax10			varchar(6) null, 	--	145
					std_purchase_date	datetime null,		--	146
					std_purchase_tax_state	varchar(6) null, 		--	147
					pyd_tax_originator_pyd_number	 int null		--	148
					,pyd_tprsplit_number	 int null				--	149		--PTS 65823
					,pyd_tprdiffbtw_number	int null				--  150		--PTS 65823					
)

---========================================================================== -- PTS 66293 1-30-13
Create Table #tmp_resultsOut	 (	
					pyd_number			int null, 			--	1
					pyh_number			int null, 			--	2
					lgh_number			int null, 			--	3
					asgn_number			int null, 			--	4
					asgn_type			varchar(6) null, 	--	5
					asgn_id				varchar(13) null, 	--	6
					ivd_number			int	null, 			--	7
					pyd_prorap			char(1) null, 		--	8
					pyd_payto			varchar(12) null, 	--	9
					pyt_itemcode		varchar(6) null, 	--	10
					pyd_description		varchar(100) null, 	--	11
					pyr_ratecode		varchar(6) null, 	--	12
					pyd_quantity		float null,			--	13
					pyd_rateunit		varchar(6) null, 	--	14
					pyd_unit			varchar(6) null, 	--	15
					pyd_pretax			char(1) null, 		--	16
					pyd_glnum			varchar(32) null, 	--	17
					pyd_status			varchar(6) null, 	--	18
					pyd_refnumtype		varchar(6) null, 	--	19
					pyd_refnum			varchar(30) null, 	--	20
					pyh_payperiod		datetime null,		--	21
					lgh_startpoint		varchar(8) null, 	--	22
					lgh_startcity		int null, 			--	23
					lgh_endpoint		varchar(8) null, 	--	24
					lgh_endcity			int null, 			--	25
					ivd_payrevenue		money null, 		--	26
					mov_number			int null, 			--	27
					pyd_minus			int null, 			--	28
					pyd_workperiod		datetime null,		--	29
					pyd_sequence		int null, 			--	30
					pyd_rate			money null, 		--	31
					pyd_amount			money null, 		--	32
					pyd_revenueratio	float null,			--	33
					pyd_lessrevenue		money null, 		--	34
					pyd_payrevenue		money null, 		--	35
					std_number			int null, 			--	36
					pyd_loadstate		varchar(6) null, 	--	37
					pyd_transdate		datetime null,		--	38
					pyd_xrefnumber		int null, 			--	39
					ord_hdrnumber		int null, 			--	40
					pyt_basis			varchar(6) null, 	--	41
					pyt_fee1			money null, 		--	42
					pyt_fee2			money null, 		--	43
					pyd_grossamount		money null, 		--	44
					psd_id				int null, 			--	45
					dummydate			datetime null,		--	46
					pyd_updatedby		varchar(20) null, 	--	47
					pyd_adj_flag		char(1) null, 		--	48
					pyd_exportstatus	varchar(6) null, 	--	49
					pyd_releasedby		varchar(20) null, 	--	50
					ord_number			varchar(12) null, 	--	51
					pyd_billedweight	int null, 			--	52
					cht_itemcode		varchar(6) null, 	--	53
					tar_tarriffnumber	varchar(12) null, 	--	54
					psd_batch_id		varchar(16) null, 	--	55
					ord_revtype1		varchar(6) null, 	--	56
					revtype1_name		varchar(20) null, 	--	57
					inv_statuscode		int null, 			--	58
					pyd_updatedon		datetime null,		--	59
					pyd_currency		varchar(6) null, 	--	60
					pyd_currencydate	datetime null,		--	61
					pyd_updsrc			char(1) null, 		--	62
					pyd_changed			int null, 			--	63
					pyt_agedays			int null, 			--	64
					pyd_ivh_hdrnumber	int null, 			--	65
					pyt_group			varchar(6) null, 	--	66
					pyd_ref_invoice		varchar(15) null, 	--	67
					pyd_ref_invoicedate	datetime null,		--	68
					calc				char(1) null, 		--	69
					edit_status			char(1) null, 		--	70
					psh_number			int null, 			--	71
					pyd_authcode		varchar(30) null, 	--	72
					pyd_maxquantity_used char(1) null, 		--	73
					pyd_maxcharge_used	 char(1) null, 		--	74
					dummy_pyh_paystatus	varchar(60) null, 	--	75
					pyd_carinvnum		varchar(30) null, 	--	76
					pyd_carinvdate		datetime null,		--	77
					std_number_adj		int null, 			--	78
					pyd_vendortopay		varchar(12) null, 	--	79
					pyt_editindispatch	int null, 			--	80
					pyd_remarks			varchar(254) null, 	--	81
					pyt_exclude_guaranteed_pay	 char(1) null, 	--	82
					stp_number			int null, 			--	83
					stp_mfh_sequence	int null, 			--	84
					pyd_perdiem_exceeded	 char(1) null, 	--	85
					stp_number_pacos	int null, 			--	86
					pyd_createdby		varchar(20) null, 	--	87
					pyd_createdon		datetime null,		--	88
					pyd_gst_amount		money null, 		--	89
					pyd_gst_flag		int null, 			--	90
					pyd_mileagetable	varchar(2) null, 	--	91
					pyd_mbtaxableamount	money null, 		--	92
					pyd_nttaxableamount	money null, 		--	93
					pyt_otflag			char(1) null, 		--	94
					pyt_basisunit		varchar(6) null, 	--	95
					otflag_workfield	char(1) null, 		--	96
					pyh_lgh_number		int null, 			--	97
					cc_xfer_ckbox		int null, 			--	98
					pyd_min_period		datetime null,		--	99
					pyd_workcycle_status	varchar(30) null, 		--	100
					pyd_workcycle_description	varchar(75) null, 	--	101
					pyt_taxable			char(1) null, 		--	102
					pyd_advstdnum		int null, 			--	103
					leg_mpp_type1		varchar(6) null, 	--	104
					leg_mpp_type2		varchar(6) null, 	--	105
					leg_mpp_type3		varchar(6) null, 	--	106
					leg_mpp_type4		varchar(6) null, 	--	107
					leg_trc_type1		varchar(6) null, 	--	108
					leg_trc_type2		varchar(6) null, 	--	109
					leg_trc_type3		varchar(6) null, 	--	110
					leg_trc_type4		varchar(6) null, 	--	111
					mpp_type1			varchar(6) null, 	--	112
					mpp_type2			varchar(6) null, 	--	113
					mpp_type3			varchar(6) null, 	--	114
					mpp_type4			varchar(6) null, 	--	115
					trc_type1			varchar(6) null, 	--	116
					trc_type2			varchar(6) null, 	--	117
					trc_type3			varchar(6) null, 	--	118
					trc_type4			varchar(6) null, 	--	119
					DrvType1			varchar(8) null ,	--	120
					DrvType2			varchar(8) null , 	--	121
					DrvType3			varchar(8) null , 	--	122
					DrvType4			varchar(8) null , 	--	123
					trctype1_t			varchar(8) null, 	--	124
					trctype2_t			varchar(8) null, 	--	125
					trctype3_t			varchar(8) null, 	--	126
					trctype4_t			varchar(8) null, 	--	127
					pyd_thirdparty_split_percent	float null,		--	128
					lgh_startdate		datetime null,		--	129
					stp_arrivaldate		datetime null,		--	130
					cc_itemsection		int null, 			--	131
					pyd_coowner_split_percent	float null,	--	132
					pyd_coowner_split_adj	 char(1) null, 	--	133
					pyd_report_quantity	money null, 		--	134
					pyd_report_rate		money null, 		--	135
					pyt_tax1			varchar(6) null, 	--	136
					pyt_tax2			varchar(6) null, 	--	137
					pyt_tax3			varchar(6) null, 	--	138
					pyt_tax4			varchar(6) null, 	--	139
					pyt_tax5			varchar(6) null, 	--	140
					pyt_tax6			varchar(6) null, 	--	141
					pyt_tax7			varchar(6) null, 	--	142
					pyt_tax8			varchar(6) null, 	--	143
					pyt_tax9			varchar(6) null, 	--	144
					pyt_tax10			varchar(6) null, 	--	145
					std_purchase_date	datetime null,		--	146
					std_purchase_tax_state	varchar(6) null, 		--	147
					pyd_tax_originator_pyd_number	 int null,		--	148
					pyd_tprsplit_number	 int null,				--	149		--PTS 65823
					pyd_tprdiffbtw_number	int null,				--  150		--PTS 65823							
					ord_booked_revtype1	varchar(12)	null,
					lgh_booked_revtype1	varchar(12)	null,
					Allocation_Entity	varchar(12)	null,
					Lgl_Entity_outstanding_balance	decimal(9,2) null				
)	
---========================================================================== -- PTS 66293 1-30-13

If @MultiPHCount < 1 set @MultiPHCount = 1 
If @MultiPHCount >= 1 
	begin 	
			-- Created custom proc for this exec: PTS 61351			
			INSERT INTO #tmp_PHbyPayto
			execute  dbo.[d_StlFinalPayDetails_custom_sp] @phnum, @type , @id, @paydate						
	end 

--   Error condition / Validation / if No-Paydetails Error then Return...
IF ( select count(pyh_number) from #tmp_PHbyPayto )  <= 0 
begin
	--Insert #tmp_PHbyPayto (asgn_type, asgn_id, pyd_description, pyh_number, pyh_payperiod)
	--	Values (@type, @id, 'ERROR: Data not found', -1, @paydate)	
	
	Insert #tmp_resultsOut (asgn_type, asgn_id, pyd_description, pyh_number, pyh_payperiod,
							ord_booked_revtype1, lgh_booked_revtype1, Allocation_Entity, Lgl_Entity_outstanding_balance )
	Values (@type, @id, 'ERROR: No PayDetail Data', -1, @paydate, 'NoData', 'NoData', 'NoData', CONVERT(decimal(9,2),0) )
	
	Set @ThisAssets_branch = 'ERROR'
	Set @LglEntityCount = 1
	Set @LglEntityList   = 'ERROR'
	Set @distinctPHCount = 0
	
	select 			pyd_number,	pyh_number,	lgh_number,	asgn_number,	asgn_type,	asgn_id,	
					ivd_number,	pyd_prorap,	pyd_payto,	pyt_itemcode,	pyd_description,		
					pyr_ratecode,	pyd_quantity,	pyd_rateunit,	pyd_unit,	pyd_pretax,	
					pyd_glnum,	pyd_status,	pyd_refnumtype,	pyd_refnum,	pyh_payperiod,	
					lgh_startpoint,		lgh_startcity,	lgh_endpoint,	lgh_endcity,	ivd_payrevenue,	
					mov_number,	pyd_minus,	pyd_workperiod,	pyd_sequence,	pyd_rate,	pyd_amount,					
					pyd_revenueratio,	pyd_lessrevenue,	pyd_payrevenue,	std_number,	pyd_loadstate,	
					pyd_transdate,	pyd_xrefnumber,		ord_hdrnumber,	pyt_basis,	pyt_fee1,		pyt_fee2,	
					pyd_grossamount,	psd_id,	dummydate,	pyd_updatedby,	pyd_adj_flag,	pyd_exportstatus,	
					pyd_releasedby,	ord_number,	pyd_billedweight,			cht_itemcode,	tar_tarriffnumber,	
					psd_batch_id,	ord_revtype1,	revtype1_name,	inv_statuscode,	pyd_updatedon,	pyd_currency,	
					pyd_currencydate,			pyd_updsrc,	pyd_changed,	pyt_agedays,	pyd_ivh_hdrnumber,	
					pyt_group,	pyd_ref_invoice,	pyd_ref_invoicedate,	calc,	edit_status,	psh_number,		
					pyd_authcode,	pyd_maxquantity_used,	pyd_maxcharge_used,	dummy_pyh_paystatus,	
					pyd_carinvnum,	pyd_carinvdate,	std_number_adj,	pyd_vendortopay,			
					pyt_editindispatch,	pyd_remarks,	pyt_exclude_guaranteed_pay,	stp_number,	
					stp_mfh_sequence,	pyd_perdiem_exceeded,	stp_number_pacos,	pyd_createdby,		
					pyd_createdon,	pyd_gst_amount,	pyd_gst_flag,	pyd_mileagetable,	pyd_mbtaxableamount,	
					pyd_nttaxableamount,	pyt_otflag,	pyt_basisunit,					otflag_workfield,	
					pyh_lgh_number,	cc_xfer_ckbox,	pyd_min_period,	pyd_workcycle_status,	pyd_workcycle_description,	
					pyt_taxable,	pyd_advstdnum,			leg_mpp_type1,	leg_mpp_type2,	leg_mpp_type3,	leg_mpp_type4,	
					leg_trc_type1,	leg_trc_type2,	leg_trc_type3,	leg_trc_type4,	mpp_type1,	mpp_type2,			
					mpp_type3,	mpp_type4,	trc_type1,	trc_type2,	trc_type3,	trc_type4,	DrvType1,	DrvType2,	
					DrvType3,	DrvType4,	trctype1_t,	trctype2_t,	trctype3_t,		trctype4_t,	pyd_thirdparty_split_percent,	
					lgh_startdate,	stp_arrivaldate,	cc_itemsection,	pyd_coowner_split_percent,	pyd_coowner_split_adj,
					pyd_report_quantity,	pyd_report_rate,	
					pyt_tax1,	pyt_tax2,	pyt_tax3,	pyt_tax4,	pyt_tax5,	pyt_tax6,	pyt_tax7,	pyt_tax8,	pyt_tax9,	pyt_tax10,
					std_purchase_date, 	std_purchase_tax_state,	pyd_tax_originator_pyd_number,
					ord_booked_revtype1, lgh_booked_revtype1, Allocation_Entity, Lgl_Entity_outstanding_balance,	
					@ThisAssets_branch 'ThisAssets_branch', @LglEntityCount 'LglEntityCount', 
					@LglEntityList 'LglEntityList' , @distinctPHCount 'distinctPHCount' from #tmp_resultsOut
	-- No Paydetails so GET OUT		  
	RETURN
end
---========================================================================== -- PTS 66293 1-30-13
	

If @MultiPHCount > 1
Begin	
	set @tmp_LoopCnt = 0
	While 	@tmp_LoopCnt <= @MultiPHCount
	Begin	
			set @tmp_LoopCnt = @tmp_LoopCnt + 1
			If @tmp_LoopCnt	> @MultiPHCount BREAK
			
			set @tmp_PHNbr = (select pyh_pyhnumber from  @DistinctMultiPH where @tmp_LoopCnt = MPHIdentity  and pyh_pyhnumber <> @phnum )	
			if @tmp_PHNbr is null select @tmp_PHNbr = 0	
					
			If @tmp_PHNbr > 0 
			
				begin
					INSERT INTO #tmp_PHbyPayto
					execute  dbo.[d_StlFinalPayDetails_custom_sp] @tmp_PHNbr, @type , @id, @paydate		
					-- PTS 75701 3-6-14 fix
					--execute  dbo.[d_stlmnt_det_final_sp] @tmp_PHNbr, @type , @id, @paydate	
				end			
	End
End

update #tmp_PHbyPayto set lgh_number = 0 where lgh_number IS NULL
--=========================  done with above set up =====================


--==========  Calculation Process ==============
		-- Compute Asset Branch and Legal Entity <start>	
		--  if there are any lgh_numbers = 0 need to populate those with asset branch

if ( select count(pyd_number) from #tmp_PHbyPayto ) > 0 
begin

select @distinctPHCount =  ( select count(Distinct(pyh_number))  from  #tmp_PHbyPayto ) 

if @distinctPHCount is Null set @distinctPHCount = 0


Declare @tmp_worktbl TABLE (
		 pyd_number				int null
		,pyd_payto				varchar(12) null
		,pto_type1				varchar(6) null		
		,brn_id					varchar(12) null
		,brn_legalentity		varchar(6) null
		,cc_allocation			varchar(12) null
		,lgh_booked_revtype1	varchar(12) null		
		,Allocation_Entity		varchar(6) null
		,ord_booked_revtype1	varchar(12)	null	
)

Declare @tmp_DistinctEntity TABLE ( Allocation_Entity varchar(6) Null )

--PTS 66293-2: QA identified proc issue -- re-work table retrieve/update
Insert  @tmp_worktbl(	 pyd_number						
						,pyd_payto
						,pto_type1
						,brn_id
						
						,lgh_booked_revtype1
						,brn_legalentity
						,cc_allocation
						
						,Allocation_Entity
						,ord_booked_revtype1 )
Select			#tmp_PHbyPayto.pyd_number,			
				#tmp_PHbyPayto.pyd_payto,
				CONVERT(varchar(6), 'UNK' ),	-- 'pto_type1'
				CONVERT(varchar(12), 'UNKNOWN' ),	-- 'brn_id'				
				legheader.lgh_booked_revtype1,	--as 'lgh_booked_revtype1'	
				CONVERT(varchar(6), 'UNK' ),	-- 'brn_legalentity'
				CONVERT(varchar(12), 'UNKNOWN' ),	-- 'cc_allocation'				
				CONVERT(varchar(6), 'UNK' ),	-- Allocation_Entity
				o.ord_booked_revtype1								
from	#tmp_PHbyPayto
left join legheader on (  #tmp_PHbyPayto.lgh_number = legheader.lgh_number and #tmp_PHbyPayto.lgh_number > 0 ) 
left join orderheader o on (#tmp_PHbyPayto.ord_hdrnumber = o.ord_hdrnumber)	

update @tmp_worktbl
set ord_booked_revtype1 = 'UNKNOWN' 
where LTRIM(RTRIM(ord_booked_revtype1))  = ''

update @tmp_worktbl
set lgh_booked_revtype1 = 'UNKNOWN' 
where LTRIM(RTRIM(lgh_booked_revtype1))  = ''

-- figure out the branch then the legal entity
-- set leg branch overrides order branch 
		update @tmp_worktbl
		set ord_booked_revtype1 = lgh_booked_revtype1 
		where ( lgh_booked_revtype1 is not NULL and lgh_booked_revtype1 NOT IN ( @UNK1, @UNK2 ) ) 
		
		-- allocation first is orderbranch
		update @tmp_worktbl
		set cc_allocation = ord_booked_revtype1 
		where ( ord_booked_revtype1 is not NULL and ord_booked_revtype1 NOT IN ( @UNK1, @UNK2 ) )
		and ord_booked_revtype1 in ( select min(brn_id) from branch where ( ord_booked_revtype1 NOT IN ( @UNK1, @UNK2 ) and ord_booked_revtype1 = brn_id  ) )		
		
		-- if leg branch is set it ALWAYS overrides orderbranch
		-- update the cc_allocation col
		update @tmp_worktbl
		set cc_allocation = lgh_booked_revtype1 
		where ( lgh_booked_revtype1 is not NULL and lgh_booked_revtype1 NOT IN ( @UNK1, @UNK2 ) ) 
		and lgh_booked_revtype1 in ( select min(brn_id) from branch where ( lgh_booked_revtype1 NOT IN ( @UNK1, @UNK2 ) and lgh_booked_revtype1 = brn_id  ) )	
				
		update @tmp_worktbl
		set Allocation_Entity = (select Min(distinct(branch.brn_legalentity)) 
									from branch 
									where branch.brn_id = IsNull(cc_allocation, 'UNKNOWN') 
									AND IsNull(cc_allocation, 'UNKNOWN') NOT IN ( @UNK1, @UNK2)  )
		where IsNull(Allocation_Entity, 'UNK') = @UNK1
		and IsNull(cc_allocation, 'UNKNOWN') NOT IN ( @UNK1, @UNK2)

	-- write data to new output result set	--PTS 66293
		insert into #tmp_resultsOut
		select	#tmp_PHbyPayto.* ,
				IsNull(cctmp.ord_booked_revtype1, 'UNKNOWN') 'ord_booked_revtype1',
				IsNull(cctmp.lgh_booked_revtype1, 'UNKNOWN') 'lgh_booked_revtype1',
				IsNull(cctmp.Allocation_Entity, 'UNKNOWN') 'Allocation_Entity',				
				CONVERT(decimal(9,2), 0) 'Lgl_Entity_outstanding_balance' 	
		from #tmp_PHbyPayto left join @tmp_worktbl cctmp on #tmp_PHbyPayto.pyd_number = cctmp.pyd_number		
end
	
	
--select count(lgh_number) from #tmp_PHbyPayto where lgh_number = 0 ) > 0 
-- If Needed: Compute Asset Branch and Legal Entity <start>
-- determine which asset type + ID & populate generic 'asset branch / allocation entity '

if @ThisAssets_allocation_Entity is NULL OR LTRIM(RTRIM(@ThisAssets_allocation_Entity)) = 0  set @ThisAssets_allocation_Entity = 'UNK'

IF ( @ThisAssets_allocation_Entity = 'UNK' 	OR 
		( select count(lgh_number) from #tmp_PHbyPayto where lgh_number = 0 ) > 0   OR 
			( select count(*) from #tmp_resultsOut where ( Allocation_Entity is NULL  OR Allocation_Entity = 'UNK' )  ) > 0  )
BEGIN
	set @ThisAssets_allocation_Entity = 'UNK' 	
			If @type = 'PTO'
			begin
					set @ThisAssets_branch = ( select brn_id from payto where pto_id = @id ) 
					If  ( @ThisAssets_branch is not null ) and LTrim(RTrim(@ThisAssets_branch)) <> '' and  Substring(@ThisAssets_branch, 1,3) <> 'UNK'
						begin
							Set @ThisAssets_allocation_Entity =  ( select min(brn_legalentity) 
																	from branch where brn_id = @ThisAssets_branch ) 	
						end 
					Else 
					Begin
						if @CustomGISet = 'Y' 
							begin
								set @ThisAssets_allocation_Entity = ( select pto_type1 from payto where pto_id = @id ) 
							end 	
					End 
			end
					
			If @type = 'TRC'  
			begin
					set @ThisAssets_branch = ( select trc_branch from tractorprofile where trc_number = @id )
					If  ( @ThisAssets_branch is not null ) and LTrim(RTrim(@ThisAssets_branch)) <> '' and  Substring(@ThisAssets_branch, 1,3) <> 'UNK'
						begin							
							Set @ThisAssets_allocation_Entity =  ( select min(brn_legalentity) 
																	from branch where brn_id = @ThisAssets_branch ) 	
						end 
					Else 
					Begin	
						if @CustomGISet = 'Y' 
							begin
								Set @ThisAssets_allocation_Entity = ( select MIN(trc_type2) from #tmp_PHbyPayto 
												where trc_type2 is not null and trc_type2 <> 'UNK' )	
							end 
					End
			end
		
			If @type = 'TRL'  
			begin
					set @ThisAssets_branch = ( select trl_branch from trailerprofile where trl_number = @id ) 
					If  ( @ThisAssets_branch is not null ) and LTrim(RTrim(@ThisAssets_branch)) <> '' and  Substring(@ThisAssets_branch, 1,3) <> 'UNK'
						begin
							Set @ThisAssets_allocation_Entity =  ( select min(brn_legalentity) 
																	from branch where brn_id = @ThisAssets_branch ) 	
						end 
					Else 
					Begin	
						if @CustomGISet = 'Y' 
							begin
								set @ThisAssets_allocation_Entity = ( select MIN(trl_type2)		
																		from trailerprofile 
																		where trl_type2 is not null and trl_type2 <> 'UNK' )
							end									
					END 
			end
				
			If @type = 'DRV'
			begin
				set @ThisAssets_branch = ( select mpp_branch from manpowerprofile where mpp_id = @id ) 
				If  ( @ThisAssets_branch is not null ) and LTrim(RTrim(@ThisAssets_branch)) <> '' and  Substring(@ThisAssets_branch, 1,3) <> 'UNK'
						begin
							Set @ThisAssets_allocation_Entity =  ( select min(brn_legalentity) 
																	from branch where brn_id = @ThisAssets_branch ) 	
						end 
					Else 
					Begin	
						if @CustomGISet = 'Y' 
							begin		
								set @ThisAssets_allocation_Entity = ( select MIN(mpp_type2) 
																	from #tmp_PHbyPayto 
																	where mpp_type2 is not null and mpp_type2 <> 'UNK' )
							end 
					END
			end
			
			If @type = 'CAR'
			 begin
				set @ThisAssets_branch = ( select car_branch from carrier where car_id = @id ) 	
				If  ( @ThisAssets_branch is not null ) and LTrim(RTrim(@ThisAssets_branch)) <> '' and  Substring(@ThisAssets_branch, 1,3) <> 'UNK'
						begin
							Set @ThisAssets_allocation_Entity =  ( select min(brn_legalentity) 
																	from branch where brn_id = @ThisAssets_branch ) 	
						end 
					Else 
					Begin	
						if @CustomGISet = 'Y' 
							begin	
								set @ThisAssets_allocation_Entity  = ( select min(carrier.pto_id) from carrier
																	   left join payto on carrier.pto_id = payto.pto_id
																	   where car_id =  @id )
							end										   
					END								
			end		
									
			If @type = 'TPR'
			begin 
				declare @tpr_revtype1 varchar(6)
				declare @tpr_pto_type1 varchar(6)
				
					set @ThisAssets_branch = ( select tpr_branch from thirdpartyprofile where tpr_id = @id ) 	
					select  @tpr_revtype1 = thirdpartyprofile.tpr_revtype1, 
							@tpr_pto_type1 = payto.pto_type1						
					from thirdpartyprofile
					left join payto on thirdpartyprofile.tpr_payto = payto.pto_id
				
				If  ( @ThisAssets_branch is not null ) and LTrim(RTrim(@ThisAssets_branch)) <> '' and  Substring(@ThisAssets_branch, 1,3) <> 'UNK'
						begin
							Set @ThisAssets_allocation_Entity =  ( select min(brn_legalentity) 
																	from branch where brn_id = @ThisAssets_branch ) 	
						end 
					Else 
					Begin	
						if @CustomGISet = 'Y' 
							begin				
								set @ThisAssets_allocation_Entity  = ( select case IsNull( @tpr_revtype1, 'UNK' )
																	   when 'UNK' then @tpr_pto_type1
																	   else @tpr_revtype1
																	   end )	
							end 
					End							
			end


	--  Validate the Asset's branch and legal entity data --		
	If ( @ThisAssets_branch IS NULL  OR @ThisAssets_branch = 'UNKNOWN' ) 
		begin
			Set @ThisAssets_branch = 'UNK'
		end 	

	IF ( @ThisAssets_allocation_Entity IS NULL  OR @ThisAssets_allocation_Entity = 'UNKNOWN' ) 
		begin
			Set @ThisAssets_allocation_Entity = 'UNK'
		end		
	
	set @brnvalidcnt = 0
	IF ( @ThisAssets_branch <> 'UNK' )
	Begin
		set @brnvalidcnt = ( select count(brn_id) from branch where brn_id = @ThisAssets_branch )
		if @brnvalidcnt is null set @brnvalidcnt = 0
	End 
	
	IF @brnvalidcnt = 0 
	begin
		Set @ThisAssets_branch = 'xxBRxx'
	end 		
		
	set @LglEvalidcnt = 0	
	IF ( @ThisAssets_allocation_Entity 	<> 'UNK'  )
	BEGIN
		set @LglEvalidcnt = ( select count(le_id) from legal_entity where le_id = @ThisAssets_allocation_Entity ) 
		if @LglEvalidcnt is null set @LglEvalidcnt = 0
	END
	
	if @LglEvalidcnt = 0 
	begin
		Set @ThisAssets_allocation_Entity = 'INVLID'
		IF @ThisAssets_branch <> 'xxBRxx' set @ThisAssets_branch = 'xxLExx'
		IF @ThisAssets_branch = 'xxBRxx' set @ThisAssets_branch = 'xBRLEx'				
	end
								
	update #tmp_resultsOut 
	set ord_booked_revtype1 = @ThisAssets_branch,
	    Allocation_Entity = @ThisAssets_allocation_Entity 
	where #tmp_resultsOut.lgh_number = 0
	
	
END
			
	--  Final Validations --			
	if ( select count(*) from #tmp_resultsOut where ( Allocation_Entity is NULL  OR Allocation_Entity = 'UNK' 
													  OR Allocation_Entity =  'INVLID' )  ) > 0  
		--OR @ThisAssets_branch = 'INVLID'  OR  @ThisAssets_allocation_Entity = 'INVLID' 
			begin
				update #tmp_resultsOut
				set Allocation_Entity = 'ERROR'	where ( Allocation_Entity is NULL  OR Allocation_Entity = 'UNK' 
														OR Allocation_Entity =  'INVLID' )		
			end
			
  		
IF ( ( select count(*) from #tmp_resultsOut where Allocation_Entity in ( 'ERROR', 'UNK', 'INVLID' ))  = 0 ) 
	begin
		Insert @tmp_DistinctEntity (Allocation_Entity)
		select distinct(Allocation_Entity) from #tmp_resultsOut		
		
		set @LglEntityCount = (select count(*) from  @tmp_DistinctEntity) 
		If ( @LglEntityCount )  > 0 
		begin	
			select 	@LglEntityList =  @LglEntityList + Allocation_Entity + ', ' from  @tmp_DistinctEntity
		end		
	end 
IF ( ( select count(*) from #tmp_resultsOut where Allocation_Entity in ( 'ERROR', 'UNK', 'INVLID' ))  > 0 ) 
		OR @ThisAssets_branch = 'xBRLEx'  OR @ThisAssets_branch = 'xxLExx'  OR @ThisAssets_branch = 'xxBRxx'
	begin
		SET @LglEntityCount = 1
		SET @LglEntityList = 'ERROR'		
	end	

-- PTS 66293:  add label.
--LabelPrepareFinalResults:
	
select 	pyd_number,
		pyh_number,
		lgh_number,
		asgn_number,
		asgn_type,
		asgn_id,
		ivd_number,
		pyd_prorap,
		pyd_payto,
		pyt_itemcode,
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
		lgh_startcity,
		lgh_endpoint,
		lgh_endcity,
		ivd_payrevenue,
		mov_number,
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
		ord_hdrnumber,
		pyt_basis,
		pyt_fee1,
		pyt_fee2,
		pyd_grossamount,
		psd_id,
		dummydate,
		pyd_updatedby,
		pyd_adj_flag,
		pyd_exportstatus,
		pyd_releasedby,
		ord_number,
		pyd_billedweight,
		cht_itemcode,
		tar_tarriffnumber,
		psd_batch_id,
		ord_revtype1,
		revtype1_name,
		inv_statuscode,
		pyd_updatedon,
		pyd_currency,
		pyd_currencydate,
		pyd_updsrc,
		pyd_changed,
		pyt_agedays,
		pyd_ivh_hdrnumber,
		pyt_group,
		pyd_ref_invoice,
		pyd_ref_invoicedate,
		calc,
		edit_status,
		psh_number,
		pyd_authcode,
		pyd_maxquantity_used,
		pyd_maxcharge_used,
		dummy_pyh_paystatus,
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
		pyd_createdby,
		pyd_createdon,
		pyd_gst_amount,
		pyd_gst_flag,
		pyd_mileagetable,
		pyd_mbtaxableamount,
		pyd_nttaxableamount,
		pyt_otflag,
		pyt_basisunit,
		otflag_workfield,
		pyh_lgh_number,
		cc_xfer_ckbox,
		pyd_min_period,
		pyd_workcycle_status,
		pyd_workcycle_description,
		pyt_taxable,
		pyd_advstdnum,
		leg_mpp_type1,
		leg_mpp_type2,
		leg_mpp_type3,
		leg_mpp_type4,
		leg_trc_type1,
		leg_trc_type2,
		leg_trc_type3,
		leg_trc_type4,
		mpp_type1,
		mpp_type2,
		mpp_type3,
		mpp_type4,
		trc_type1,
		trc_type2,
		trc_type3,
		trc_type4,
		DrvType1,
		DrvType2,
		DrvType3,
		DrvType4,
		trctype1_t,
		trctype2_t,
		trctype3_t,
		trctype4_t,
		pyd_thirdparty_split_percent,
		lgh_startdate,
		stp_arrivaldate,
		cc_itemsection,
		pyd_coowner_split_percent,
		pyd_coowner_split_adj,
		pyd_report_quantity,
		pyd_report_rate,
		pyt_tax1,
		pyt_tax2,
		pyt_tax3,
		pyt_tax4,
		pyt_tax5,
		pyt_tax6,
		pyt_tax7,
		pyt_tax8,
		pyt_tax9,
		pyt_tax10,
		std_purchase_date,
		std_purchase_tax_state,
		pyd_tax_originator_pyd_number,
		ord_booked_revtype1,
		lgh_booked_revtype1,
		Allocation_Entity,
		--CONVERT(decimal(9,2),  Lgl_Entity_outstanding_balance) 'Lgl_Entity_outstanding_balance',
		Lgl_Entity_outstanding_balance,
		@ThisAssets_branch 'ThisAssets_branch', 
		@LglEntityCount 'LglEntityCount', 
		@LglEntityList 'LglEntityList' , 
		@distinctPHCount 'distinctPHCount' 
				---INTO #tmp_FinalResults		-- PTS 66293
		from #tmp_resultsOut

-- pts 66293 (remove )
--select *, @ThisAssets_branch 'ThisAssets_branch', @LglEntityCount 'LglEntityCount', 
--				  @LglEntityList 'LglEntityList' , @distinctPHCount 'distinctPHCount' from #tmp_FinalResults
		  

IF OBJECT_ID(N'tempdb..#tmp_PHbyPayto', N'U') IS NOT NULL 
DROP TABLE #tmp_PHbyPayto
IF OBJECT_ID(N'tempdb..#tmp_resultsOut', N'U') IS NOT NULL 
DROP TABLE #tmp_resultsOut

RETURN


GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_det_final_PH_by_LegalEntity_sp] TO [public]
GO
