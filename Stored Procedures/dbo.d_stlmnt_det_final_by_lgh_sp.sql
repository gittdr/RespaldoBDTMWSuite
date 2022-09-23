SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create  Procedure [dbo].[d_stlmnt_det_final_by_lgh_sp] (@phnum INT, @type CHAR(6), @id CHAR(13), @paydate DATETIME, @lgh_number int)
AS

/* Revision History:
	Date		Name		Label	Description
	-----------	---------------	-------	------------------------------------------------------------------------------------
	
	3/27/2009	JSwindell	PTS 45170   Created.
	7-23-2009   JSwindell   PTS 47021   Add WorkCycle Columns.  pyd_workcycle_status   x30  pyd_workcycle_description   x75
*/

DECLARE	@v_PerDiemPaytype	varchar(60),
		-- PTS 31375 -- BL (start)
		@paydatecheck char(1)
		-- PTS 31375 -- BL (end)
		, @termcode varchar(8)  --PTS 76865
SELECT  @v_PerDiemPaytype = IsNull(gi_string1, '')
FROM	generalinfo
WHERE	gi_name = 'PerDiemPaytype'

-- PTS 31375 -- BL (start)
SELECT @paydatecheck = LEFT(upper(IsNull(gi_string1, 'N')), 1)
FROM	generalinfo
WHERE	gi_name = 'UseTransDateInCollect'
-- PTS 31375 -- BL (end)
-- PTS 76865 nloke  
select @termcode = ISNULL (termcode,'')  
from assetassignment  
where lgh_number = @lgh_number  
-- end 76865 

	SELECT	pyd_number, 
			pyh_number, 
			lgh_number, 
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
			Case (select Isnull(cmp_invoicetype, 'INV') from company where orderheader.ord_billto = company.cmp_id) 
				when 'MAS' then
						(SELECT	ISNULL(MIN(code) , 0)
				   		FROM	labelfile, invoiceheader 
				  		WHERE	invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber AND
								invoiceheader.ivh_mbstatus = labelfile.abbr AND 
								labelfile.labeldefinition = 'InvoiceStatus')
				else 	(SELECT	ISNULL(MIN(code) , 0)
				   		FROM	labelfile, invoiceheader 
				  		WHERE	invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber AND
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
			pyd_createdby,		-- PTS 38870
			pyd_createdon,		-- PTS 38870
			pyd_gst_amount,		-- vjh PTS 39688
			pyd_gst_flag,		-- vjh PTS 39688
			pyd_mileagetable,
			pyd_mbtaxableamount,
			pyd_nttaxableamount,
	--		IsNull(paydetail.pyt_otflag, paytype.pyt_otflag),
			paydetail.pyt_otflag,
			paytype.pyt_basisunit, 
			otflag_workfield = paydetail.pyt_otflag,

			0 as 'pyh_lgh_number',	-- pyh_lgh_number,	-- 45170
			0 as 'cc_xfer_ckbox',	-- cc_xfer_ckbox	-- 45170	

			pyd_workcycle_status,		-- PTS 47021 
			pyd_workcycle_description   -- PTS 47021 	
			,@termcode as termcode  --PTS 76865
	  FROM  paydetail  LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber   
					   LEFT OUTER JOIN  purchaseservicedetail  ON  paydetail.psd_number  = purchaseservicedetail.psd_number ,
	        paytype 
	 WHERE	pyh_number = 0 AND
			 asgn_id = @id AND
			 asgn_type = @type AND	
			 pyd_status = 'PND' AND 			 
			 lgh_number = @lgh_number and
			 paydetail.pyt_itemcode = paytype.pyt_itemcode 

GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_det_final_by_lgh_sp] TO [public]
GO
