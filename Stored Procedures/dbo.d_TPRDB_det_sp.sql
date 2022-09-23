SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create Procedure [dbo].[d_TPRDB_det_sp] (@num_parm INT, @type varchar(6), @pyt_itemcode varchar(6) )
AS

Set nocount on 

/*
	Created for PTS 52571
*/

-- @ordnum is now @num_parm

-- PTS 52571 new variables <<start>>
declare @ld_percentage decimal (12,4) 
set @ld_percentage = 100.00
Declare @cnt decimal (12,4) 
declare @ll_ivhhdrnum int
declare @ld_TotalCosts decimal (12,4) 
Declare @asgn_id_count decimal (12,4)
Declare @nbr_orders_cnt decimal (12,4)
Declare @mov_number int

IF @type = 'MOVE'
set @mov_number = @num_parm
IF @type = 'ORDNUM'
set @mov_number = ( select min(mov_number) from orderheader where ord_hdrnumber = @num_parm ) 

-- PTS 52571 new variables <<end>>

declare @v_EditInDispatchGI varchar(60)
Create table #temp (
	pyd_number		int			not null, 
	pyh_number		int			not null, 
	lgh_number		int			null, 
	asgn_number		int			null, 
	asgn_type		varchar(6)	null, 
	asgn_id			varchar(13)	null, 
	ivd_number		int			null, 
	pyd_prorap		char(1)		null, 
	pyd_payto		varchar(12)	null, 
	pyt_itemcode	varchar(6)	null,
	pyd_description varchar(75)	null, 
	pyr_ratecode	varchar(6)	null, 
	pyd_quantity	decimal (12,4) null, 
	pyd_rateunit	varchar(6)	null, 
	pyd_unit		varchar(6)	null, 
	pyd_pretax		char(1)		null, 
	pyd_glnum		varchar(32)	null, 
	pyd_status		varchar(6)	null, 
	pyd_refnumtype	varchar(6)	null, 
	pyd_refnum		varchar(30)	null, 
	pyh_payperiod	datetime	null, 
	lgh_startpoint	varchar(8)	null, 
	lgh_startcity	int			null, 
	lgh_endpoint	varchar(8)	null, 
	lgh_endcity		int			null, 
	ivd_payrevenue	money		null, 
	mov_number		int			null, 
	pyd_minus		int			null, 
	pyd_workperiod	datetime	null, 
	pyd_sequence	int			null, 
	pyd_rate		decimal (12,4) null, 
	pyd_amount		decimal (12,4) null, 
	pyd_revenueratio decimal (12,4) null, 
	pyd_lessrevenue	money		null,  
	pyd_payrevenue	money		null, 
	std_number		int			null, 
	pyd_loadstate	varchar(6)	null, 
	pyd_transdate	datetime	null, 
	pyd_xrefnumber	int			null, 
	ord_hdrnumber	int			null, 
	pyt_basis		varchar(6)	null, 
	pyt_fee1		money		null, 
	pyt_fee2		money		null, 
	pyd_grossamount	money		null, 
	psd_id			int			null, 
	dummydate		datetime	null ,--CONVERT(datetime, NULL) dummydate, 
	pyd_updatedby	char(20)	null, 
	pyd_adj_flag	char(1)		null, 
	pyd_exportstatus char(6)	null, 
	pyd_releasedby	char(20)	null, 
	ord_number		varchar(12)	null,--CONVERT(varchar(12), ISNULL(ord_number, '0')) ord_number, 
	pyd_billedweight int		null, 
	cht_itemcode	varchar(6)	null, 
	tar_tarriffnumber varchar(12) null, 
	psd_batch_id	varchar(16)	null, 
	ord_revtype1	varchar(6)	null,--CONVERT(varchar(6), ISNULL(ord_revtype1, 'UNK')) ord_revtype1, 
	revtype1_name	varchar(20) null, --CONVERT(varchar(20), 'RevType1') revtype1_name, 
	inv_statuscode		int			null,--0 inv_statuscode,
	pyd_updatedon		datetime	null, 
	pyd_currency		varchar(6)	null,		--60
	pyd_currencydate	datetime	null, 
	pyd_updsrc			char(1)		null, 
	changed				int			null ,--CONVERT(INT, 0) changed,
	pyt_agedays			int			null,
	pyd_ivh_hdrnumber	int			null,
	pyt_group			varchar(6)	null,
	pyd_ref_invoice		varchar(15)	null,
	pyd_ref_invoicedate	datetime	null,
	psh_number			integer		null,
	pyd_authcode		varchar(30) null,
	pyd_maxquantity_used char(1),
	pyd_maxcharge_used	char(1),
	pyh_paystatus		varchar(6)	NULL,
	pyd_carinvnum		varchar(30) NULL,
	pyd_carinvdate		datetime	NULL, 
	std_number_adj		int			null, 
	pyd_vendortopay		varchar(12) null,
	pyt_editindispatch	integer		null,
	pyd_remarks			varchar(254) null,
	pyt_exclude_guaranteed_pay char(1) null,
	stp_number			INTEGER		NULL,
	stp_mfh_sequence	INTEGER		NULL,
	pyd_perdiem_exceeded CHAR(1)	NULL,
	stp_number_pacos	int			null,
	pyd_createdby		CHAR(20)	NULL,	-- PTS 38870
	pyd_createdon		datetime	NULL,	-- PTS 38870,
	pyd_gst_amount	 money null,
	pyd_gst_flag		int null,
	pyd_mileagetable	char(2) null,
	pyd_mbtaxableamount money null,
	pyd_nttaxableamount money null,
	pyt_otflag	char(1) null,
	pyt_basisunit	varchar(6) null,
	otflag_workfield	char(1) null,
	pyh_lgh_number		INTEGER		NULL,	-- 45170
	cc_xfer_ckbox		INTEGER		NULL,	-- 45170	
	pyd_min_period		datetime	NULL,	-- PTS 43873
	pyd_workcycle_status   VARCHAR(30)	NULL,   -- PTS 47021 
	pyd_workcycle_description  VARCHAR(75)	NULL,   -- PTS 47021 
	pyt_taxable			char(1)		null,	--MRH 45723
	pyd_advstdnum		integer		null,	--vjh 42282
	ld_percentage		decimal (12,4) null, -- pts 52571
	ld_TotalCosts			decimal (12,4) null,   -- pts 52571
	pyd_thirdparty_split_percent float null ) 

If @num_parm > 0 
	Insert into #temp
	SELECT pyd_number, 
		pyh_number, 
		paydetail.lgh_number,		-- pts 48160 (specify table)
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
		lgh_startcity, 
		lgh_endpoint, 
		lgh_endcity, 
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
		pyd_currency,		--60
		pyd_currencydate, 
		pyd_updsrc, 
		CONVERT(INT, 0) changed,
		pyt_agedays,
		pyd_ivh_hdrnumber,	--65
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
		pyd_createdby,			-- PTS 38870
		pyd_createdon,			-- PTS 38870
		pyd_gst_amount,		
		pyd_gst_flag,		
		pyd_mileagetable,
		pyd_mbtaxableamount,
		pyd_nttaxableamount,
--		IsNull(paydetail.pyt_otflag, paytype.pyt_otflag),
		paydetail.pyt_otflag,
		paytype.pyt_basisunit, 
		otflag_workfield = paydetail.pyt_otflag,
		ISNULL(pyh_lgh_number, 0) pyh_lgh_number,	-- 45170
		0,						-- cc_xfer_ckbox	-- 45170	
		isNull(pyd_min_period, paydetail.pyh_payperiod) pyd_min_period,		-- PTS 43873
		pyd_workcycle_status,       -- PTS 47021 
		pyd_workcycle_description,    -- PTS 47021 
		isnull(pyt_taxable, 'Y') pyt_taxable,
		pyd_advstdnum,				--vjh 42282
		0,						-- ld_percentage  -- pts 52571
		0,						-- ld_TotalCosts  -- pts 52571
		isnull(pyd_thirdparty_split_percent, 0) -- pyd_thirdparty_split_percent
	  FROM  paydetail  LEFT OUTER JOIN  purchaseservicedetail  ON  paydetail.psd_number  = purchaseservicedetail.psd_number   

				LEFT OUTER JOIN  payheader  ON  payheader.pyh_pyhnumber  = paydetail.pyh_number /*-- RE - 4/30/04 - PTS #22646*/ ,
	        paytype,
	        orderheader 
	 WHERE paydetail.pyt_itemcode = paytype.pyt_itemcode AND 
		paydetail.ord_hdrnumber = orderheader.ord_hdrnumber AND 
		((paydetail.ord_hdrnumber = @num_parm AND @type = 'ORDNUM') OR 
		(paydetail.mov_number = @num_parm AND @type = 'MOVE')) 
-- RE - 4/30/04 - PTS #22646
ELSE IF @num_parm < 0
	BEGIN
		select @ll_ivhhdrnum = @num_parm * -1
		Insert into #temp
		SELECT pyd_number, 
			pyh_number, 
			paydetail.lgh_number,	-- pts 48160 (specify table)
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
			lgh_startcity, 
			lgh_endpoint, 
			lgh_endcity, 
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
			pyd_currency,			--60 
			pyd_currencydate, 
			pyd_updsrc, 
			CONVERT(INT, 0) changed,
			pyt_agedays,
			pyd_ivh_hdrnumber,		--65
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
			pyd_createdby,			-- PTS 38870
			pyd_createdon,			-- PTS 38870
			pyd_gst_amount,		
			pyd_gst_flag,		
			pyd_mileagetable,
	        pyd_mbtaxableamount,
			pyd_nttaxableamount,
--			IsNull(paydetail.pyt_otflag, paytype.pyt_otflag),
			paydetail.pyt_otflag,
			paytype.pyt_basisunit,
			otflag_workfield = paydetail.pyt_otflag,
			ISNULL(pyh_lgh_number, 0) pyh_lgh_number,	-- 45170
			0,						-- cc_xfer_ckbox	-- 45170
			isNull(pyd_min_period, paydetail.pyh_payperiod) pyd_min_period,		-- PTS 43873
			pyd_workcycle_status,       -- PTS 47021 
			pyd_workcycle_description,    -- PTS 47021 
			isnull(pyt_taxable, 'Y') pyt_taxable,
			pyd_advstdnum,				--vjh 42282
			0,						-- ld_percentage  -- pts 52571
			0,						-- ld_TotalCosts  -- pts 52571		  
			isnull(pyd_thirdparty_split_percent, 0) -- pyd_thirdparty_split_percent
		  FROM  paydetail  LEFT OUTER JOIN  purchaseservicedetail  ON  paydetail.psd_number  = purchaseservicedetail.psd_number   
						   LEFT OUTER JOIN  payheader  ON  payheader.pyh_pyhnumber  = paydetail.pyh_number ,
	            paytype
		 WHERE paydetail.pyt_itemcode = paytype.pyt_itemcode AND 
	 		paydetail.pyd_ivh_hdrnumber = @ll_ivhhdrnum 
	END
	
	-----------  remove adjusted rows --------------------------------
	Delete from #temp where pyt_itemcode = 'TPRDB' and pyd_minus = -1
	------------------------------------------------------------------
	
	
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


-- PTS 45170 <<start>>	-- calculate the cc_xfer_ckbox IF GI setting is ON. 
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

-- PTS 52571 <<start>>  set new variables & remove un-needed data.

-- In this process we exclude certain codes from the cost.  So remove them from our data.
Delete from #temp where pyt_itemcode in (   select distinct(pt.pyt_itemcode) 
											FROM paytype pt
											left outer join paydetail pd on pd.pyt_itemcode = pt.pyt_itemcode
											where pt.pyt_incexcoth = 1 
											and   pd.mov_number	= @mov_number ) 
											
set @nbr_orders_cnt = ( select count(distinct(ord_hdrnumber)) from #temp )											

-- this is the totalcose on ALL orders 
select @ld_TotalCosts = SUM(pyd_amount) from #temp where pyt_itemcode <> LTRIM(RTRIM(@pyt_itemcode))  -- used in final result set
set @ld_percentage = 100.00	--  not currently used

--IF @nbr_orders_cnt = 1 
--BEGIN
	set @ld_percentage = 100.00
	Delete from #temp where pyt_itemcode <> LTRIM(RTRIM(@pyt_itemcode))
	select @cnt = count(*) from #temp
	If @cnt <= 0 set @cnt = 1
	set @ld_percentage  = @ld_percentage / @cnt
	
	update #temp set ld_percentage = @ld_percentage
	update #temp set ld_TotalCosts = @ld_TotalCosts 
	
--END 

-- 7-30-2010 handle consolidated order having one thirdparty each.
IF @nbr_orders_cnt > 1 
BEGIN
	Create table #temp_multi (  ord_hdrnumber int null, 
								asgn_id varchar(40) null,
								pyd_number int null, 								
								li_nbr_assets int null)								
								
	insert into #temp_multi	( ord_hdrnumber, asgn_id, pyd_number)
	select ord_hdrnumber, asgn_id, pyd_number from #temp where pyt_itemcode =  LTRIM(RTRIM(@pyt_itemcode)) 

	update 	#temp_multi 
	set li_nbr_assets = ( select count(distinct(asgn_id)) from #temp where 	#temp_multi.ord_hdrnumber = #temp.ord_hdrnumber )	
	
	update #temp 
	set ld_percentage = ( select ( 100.00 / li_nbr_assets ) 
						  from #temp_multi 
						  where #temp_multi.pyd_number = #temp.pyd_number) 	
	
END

--  ********  FOR NOW -- leave this at 100% divided by # assets. ******** -----------------------------
----IF @nbr_orders_cnt > 1 
----BEGIN	
--	Create table #temp_multi (  ord_hdrnumber int null, 
--								asgn_id varchar(40) null,
--								pyd_number int null, 
--								ld_asset_pyd_amt decimal (12,4) null, 
--								li_nbr_assets int null,
--								ld_TotalORDERCosts decimal (12,4) null, 								
--								ld_ORDER_percent_per_asset decimal (12,4) null,								
--								ld_GRAND_TOTAL_COsts_all_orders decimal (12,4) null) 
								
--	insert into #temp_multi	( ord_hdrnumber, asgn_id, pyd_number, ld_asset_pyd_amt, ld_GRAND_TOTAL_COsts_all_orders ) 
--	select ord_hdrnumber, asgn_id, pyd_number, pyd_amount, @ld_TotalCosts  from #temp where pyt_itemcode =  LTRIM(RTRIM(@pyt_itemcode)) 
		
--	update  #temp_multi 
--	set ld_TotalORDERCosts  = ( select SUM(pyd_amount) from #temp where pyt_itemcode = LTRIM(RTRIM(@pyt_itemcode)) 
--													   and #temp_multi.ord_hdrnumber = #temp.ord_hdrnumber )
													   
--	update  #temp_multi 	
--	set ld_ORDER_percent_per_asset = (select  ( ld_asset_pyd_amt / ld_TotalORDERCosts) * 100	) 									   
	
--	Delete from #temp where pyt_itemcode <> LTRIM(RTRIM(@pyt_itemcode))
	
--	update 	#temp_multi 
--	set li_nbr_assets = ( select count(distinct(asgn_id)) from #temp where 	#temp_multi.ord_hdrnumber = #temp.ord_hdrnumber )	
		
--	update #temp 
--	set ld_percentage = ( select ld_ORDER_percent_per_asset 
--						  from #temp_multi 
--						  where #temp_multi.pyd_number = #temp.pyd_number) 						  
						  
--	update #temp 	
--	set ld_TotalCosts =  ( select ld_TotalORDERCosts  
--						   from #temp_multi 
--						    where #temp_multi.pyd_number = #temp.pyd_number) 		
									
										
----END	
-- PTS 52571 <<end>>

--vmj1+	PTS 13030	01/23/2002	Add a column which is used by PayDetailCorrection window to
--	indicate which rows need to be deleted before the Calc is run..
SELECT pyd_number, 
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
	pyd_currency,			--60 
	pyd_currencydate, 
	pyd_updsrc, 
	changed,
	pyt_agedays,
	pyd_ivh_hdrnumber,
	pyt_group,
	pyd_ref_invoice,
	pyd_ref_invoicedate, 
	'N' as calc, 
	'N' as edit_status ,	--70
	psh_number, --17834 Jd
	pyd_authcode	,
	pyd_maxquantity_used,
	pyd_maxcharge_used, 
	pyh_paystatus,
	pyd_carinvnum,
	pyd_carinvdate, 
	std_number_adj, 
	pyd_vendortopay,
	pyt_editindispatch,		--80
	pyd_remarks,
	pyt_exclude_guaranteed_pay,
	stp_number,
	stp_mfh_sequence,
	pyd_perdiem_exceeded,
	stp_number_pacos,
	pyd_createdby,			
	pyd_createdon,			
	pyd_gst_amount,
	pyd_gst_flag,			--90
	pyd_mileagetable,
	pyd_mbtaxableamount,
	pyd_nttaxableamount,
	pyt_otflag,
	pyt_basisunit,
	otflag_workfield,
	pyh_lgh_number,	-- 45170
	cc_xfer_ckbox,	-- 45170	
	pyd_min_period,	-- PTS 43873
	pyd_workcycle_status,       -- PTS 47021	--100
	pyd_workcycle_description,    -- PTS 47021 
	pyt_taxable,
	pyd_advstdnum,
	ld_percentage, 	
	ld_TotalCosts,
	isnull(pyd_thirdparty_split_percent, 0) -- pyd_thirdparty_split_percent
  FROM #temp


GO
GRANT EXECUTE ON  [dbo].[d_TPRDB_det_sp] TO [public]
GO
