SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create procedure [dbo].[d_paydetailaudit_sp] 
	(@pl_pyd_number int) 
as

/* d_paydetailaudit_sp

	Retrieves paydetailaudit & paydetail rows to get a full audit of activity on the
	paydetail table.

	Parameters:	@pl_pyd_number		The PayDetail key to search by.

	Returns:	none (result set)

	Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	---------------------------------------------
	05/24/2001	Vern Jewett		(none)	Original
LOR	PTS# 32400	add delete reason
*/

--PTS 36955 JJF 20080626
/*
/* paydetail contains most recent info..	*/
select	0 as audit_sequence
		,'' as audit_status
		,pyd_updatedby as audit_user
		--,getdate() as audit_date
		,pyd_updatedon as audit_date
		,pyd_number
		,pyh_number
		,lgh_number
		,asgn_number
		,asgn_type
		,asgn_id
		,pyr_ratecode
		,pyd_quantity
		,pyd_rateunit
		,pyd_unit
		,pyd_rate
		,pyd_amount
		,pyd_revenueratio
		,pyd_lessrevenue
		,pyd_payrevenue
		,pyt_fee1
		,pyt_fee2
		,pyd_grossamount
		,pyd_status
		,pyd_transdate
		,pyh_payperiod
		,pyd_workperiod
		,pyd_transferdate
		,pyd_currencydate
		,pyd_updatedby		--duplicate w/audit_user (won't hurt anything)
		,pyd_updatedon
		,pyt_itemcode,
		'      ' del_reason
  from	paydetail
  where	pyd_number = @pl_pyd_number

/* paydetailaudit contains previous versions..	*/
union
select	audit_sequence
		,audit_status
		,audit_user
		,audit_date
		,pyd_number
		,pyh_number
		,lgh_number
		,asgn_number
		,asgn_type
		,asgn_id
		,pyr_ratecode
		,pyd_quantity
		,pyd_rateunit
		,pyd_unit
		,pyd_rate
		,pyd_amount
		,pyd_revenueratio
		,pyd_lessrevenue
		,pyd_payrevenue
		,pyt_fee1
		,pyt_fee2
		,pyd_grossamount
		,pyd_status
		,pyd_transdate
		,pyh_payperiod
		,pyd_workperiod
		,pyd_transferdate
		,pyd_currencydate
		,pyd_updatedby
		,pyd_updatedon
		,pyt_itemcode,
		audit_reason_del_canc del_reason
  from	paydetailaudit
  where	pyd_number = @pl_pyd_number
*/

SELECT 'B' as RecordOrigin
		,audit_sequence
      ,audit_status
      ,audit_user
      ,audit_date
      ,pyd_number
      ,pyh_number
      ,lgh_number
      ,asgn_number
      ,asgn_type
      ,asgn_id
      ,pyr_ratecode
      ,pyd_quantity
      ,pyd_rateunit
      ,pyd_unit
      ,pyd_rate
      ,pyd_amount
      ,pyd_revenueratio
      ,pyd_lessrevenue
      ,pyd_payrevenue
      ,pyt_fee1
      ,pyt_fee2
      ,pyd_grossamount
      ,pyd_status
      ,pyd_transdate
      ,pyh_payperiod
      ,pyd_workperiod
      ,pyd_transferdate
      ,pyd_currencydate
      ,pyd_updatedby
      ,pyd_updatedon
      ,pyt_itemcode
      ,std_number_adj
      ,pyd_vendortopay
      ,audit_reason_del_canc
      ,pyd_createdby
      ,pyd_createdon
      ,ivd_number
      ,pyd_prorap
      ,pyd_payto
      ,mov_number
      ,pyd_description
      ,pyd_pretax
      ,pyd_glnum
      ,pyd_currency
      ,pyd_refnumtype
      ,pyd_refnum
      ,lgh_startpoint
      ,lgh_startcity
      ,lgh_endpoint
      ,lgh_endcity
      ,ivd_payrevenue
      ,pyd_minus
      ,pyd_sequence
      ,std_number
      ,pyd_loadstate
      ,pyd_xrefnumber
      ,ord_hdrnumber
      ,pyd_adj_flag
      ,psd_id
      ,pyd_exportstatus
      ,pyd_releasedby
      ,cht_itemcode
      ,pyd_billedweight
      ,tar_tarriffnumber
      ,psd_batch_id
      ,pyd_updsrc
      ,pyd_offsetpay_number
      ,pyd_credit_pay_flag
      ,pyd_ivh_hdrnumber
      ,psd_number
      ,pyd_ref_invoice
      ,pyd_ref_invoicedate
      ,pyd_authcode
      ,pyd_PostProcSource
      ,pyd_GPTrans
      ,cac_id
      ,ccc_id
      ,pyd_hourlypaydate
      ,pyd_isdefault
      ,pyd_maxquantity_used
      ,pyd_maxcharge_used
      ,pyd_mbtaxableamount
      ,pyd_nttaxableamount
      ,pyd_carinvnum
      ,pyd_carinvdate
      ,pyd_vendorpay
      ,pyd_remarks
      ,stp_number
      ,stp_mfh_sequence
      ,pyd_perdiem_exceeded
      ,pyd_carrierinvoice_aprv
      ,pyd_carrierinvoice_rjct
      ,pyd__aprv_rjct_comment
      ,pyd_paid_indicator
      ,pyd_paid_amount
      ,pyd_payment_date
      ,pyd_payment_doc_number
      ,stp_number_pacos
      ,pyd_expresscode
      ,pyd_gst_amount
      ,pyd_gst_flag
      ,pyd_mileagetable
      ,bill_override
      ,not_billed_reason
      ,pyd_reg_time_qty
  FROM paydetailaudit
  WHERE pyd_number = @pl_pyd_number

UNION

SELECT 'A' as RecordOrigin
		,0 as audit_sequence
      ,'N' as audit_status
      ,pyd_updatedby as audit_user
      ,pyd_updatedon as audit_date
      ,pyd_number
      ,pyh_number
      ,lgh_number
      ,asgn_number
      ,asgn_type
      ,asgn_id
      ,pyr_ratecode
      ,pyd_quantity
      ,pyd_rateunit
      ,pyd_unit
      ,pyd_rate
      ,pyd_amount
      ,pyd_revenueratio
      ,pyd_lessrevenue
      ,pyd_payrevenue
      ,pyt_fee1
      ,pyt_fee2
      ,pyd_grossamount
      ,pyd_status
      ,pyd_transdate
      ,pyh_payperiod
      ,pyd_workperiod
      ,pyd_transferdate
      ,pyd_currencydate
      ,pyd_updatedby
      ,pyd_updatedon
      ,pyt_itemcode
      ,std_number_adj
      ,pyd_vendortopay
      ,'      ' as audit_reason_del_canc
      ,pyd_createdby
      ,pyd_createdon
      ,ivd_number
      ,pyd_prorap
      ,pyd_payto
      ,mov_number
      ,pyd_description
      ,pyd_pretax
      ,pyd_glnum
      ,pyd_currency
      ,pyd_refnumtype
      ,pyd_refnum
      ,lgh_startpoint
      ,lgh_startcity
      ,lgh_endpoint
      ,lgh_endcity
      ,ivd_payrevenue
      ,pyd_minus
      ,pyd_sequence
      ,std_number
      ,pyd_loadstate
      ,pyd_xrefnumber
      ,ord_hdrnumber
      ,pyd_adj_flag
      ,psd_id
      ,pyd_exportstatus
      ,pyd_releasedby
      ,cht_itemcode
      ,pyd_billedweight
      ,tar_tarriffnumber
      ,psd_batch_id
      ,pyd_updsrc
      ,pyd_offsetpay_number
      ,pyd_credit_pay_flag
      ,pyd_ivh_hdrnumber
      ,psd_number
      ,pyd_ref_invoice
      ,pyd_ref_invoicedate
      ,pyd_authcode
      ,pyd_PostProcSource
      ,pyd_GPTrans
      ,cac_id
      ,ccc_id
      ,pyd_hourlypaydate
      ,pyd_isdefault
      ,pyd_maxquantity_used
      ,pyd_maxcharge_used
      ,pyd_mbtaxableamount
      ,pyd_nttaxableamount
      ,pyd_carinvnum
      ,pyd_carinvdate
      ,pyd_vendorpay
      ,pyd_remarks
      ,stp_number
      ,stp_mfh_sequence
      ,pyd_perdiem_exceeded
      ,pyd_carrierinvoice_aprv
      ,pyd_carrierinvoice_rjct
      ,pyd__aprv_rjct_comment
      ,pyd_paid_indicator
      ,pyd_paid_amount
      ,pyd_payment_date
      ,pyd_payment_doc_number
      ,stp_number_pacos
      ,pyd_expresscode
      ,pyd_gst_amount
      ,pyd_gst_flag
      ,pyd_mileagetable
      ,bill_override
      ,not_billed_reason
      ,null --pyd_reg_time_qty
	FROM paydetail
	WHERE pyd_number = @pl_pyd_number

GO
GRANT EXECUTE ON  [dbo].[d_paydetailaudit_sp] TO [public]
GO
