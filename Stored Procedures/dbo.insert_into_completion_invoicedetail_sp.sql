SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[insert_into_completion_invoicedetail_sp] (@p_ivd_number int) 

AS
/**
 * 
 * NAME:
 * insert_into_completion_invoicedetail_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: 1 If All Deletes/Inserts Succeed
 *			-1 If there are any delete/insert failures
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: @p_ivd_number		int	Order Header Number To Create
 *
 * REVISION HISTORY:
 * 2/20/2007.01 ? PTS33397 - Dan Hudec ? Created Procedure
 **/

DECLARE	@v_return_code	int

INSERT INTO completion_invoicedetail(
	ivh_hdrnumber, 
	ivd_number, 
	stp_number, 
	ivd_description, 
	cht_itemcode, 
	ivd_quantity, 
	ivd_rate, 
	ivd_charge, 
	ivd_taxable1, 
	ivd_taxable2, 
	ivd_taxable3, 
	ivd_taxable4, 
	ivd_unit, 
	cur_code, 
	ivd_currencydate,
	ivd_glnum, 
	ord_hdrnumber, 
	ivd_type, 
	ivd_rateunit, 
	ivd_billto, 
	ivd_itemquantity, 
	ivd_subtotalptr, 
	ivd_allocatedrev, 
	ivd_sequence, 
	ivd_invoicestatus, 
	mfh_hdrnumber, 
	ivd_refnum, 
	cmd_code, 
	cmp_id, 
	ivd_distance, 
	ivd_distunit, 
	ivd_wgt, 
	ivd_wgtunit, 
	ivd_count, 
	ivd_countunit, 
	evt_number, 
	ivd_reftype, 
	ivd_volume, 
	ivd_volunit, 
	ivd_orig_cmpid,  
	ivd_payrevenue, 
	ivd_sign, 
	ivd_length, 
	ivd_lengthunit, 
	ivd_width, 
	ivd_widthunit, 
	ivd_height, 
	ivd_heightunit, 
	ivd_exportstatus, 
	cht_basisunit, 
	ivd_remark, 
	tar_number, 
	tar_tariffnumber, 
	tar_tariffitem, 
	ivd_fromord, 
	ivd_zipcode, 
	ivd_quantity_type, 
	cht_class, 
	ivd_mileagetable, 
	ivd_charge_type, 
	ivd_trl_rent, 
	ivd_trl_rent_start, 
	ivd_trl_rent_end, 
	ivd_rate_type, 
	cht_lh_min, 
	cht_lh_rev, 
	cht_lh_stl, 
	cht_lh_rpt, 
	cht_rollintolh, 
	cht_lh_prn, 
	fgt_number, 
	ivd_paylgh_number, 
	ivd_tariff_type, 
	ivd_taxid, 
	ivd_ordered_volume, 
	ivd_ordered_loadingmeters, 
	ivd_ordered_count,
	ivd_ordered_weight, 
	ivd_loadingmeters, 
	ivd_loadingmeters_unit,
	last_updateby, 
	last_updatedate, 
	ivd_revtype1, 
	ivd_hide, 
	ivd_baserate, 
	ivd_oradjustment, 
	ivd_cbadjustment, 
	ivd_fsc, 
	ivd_splitbillratetype, 
	ivd_rawcharge, 
	ivd_bolid, 
	ivd_shared_wgt,
	ivd_completion_billable_flag)

SELECT	0,					--ivh_hdrnumber
	ivd_number, 
	stp_number, 
	ivd_description, 
	cht_itemcode, 
	ivd_quantity, 
	IsNull(ivd_rate, 0),						
	IsNull(ivd_charge, 0),					
	ivd_taxable1, 
	ivd_taxable2, 
	ivd_taxable3, 
	ivd_taxable4, 
	ivd_unit, 
	cur_code, 
	ivd_currencydate,
	ivd_glnum, 
	ord_hdrnumber, 
	ivd_type, 
	ivd_rateunit, 
	ivd_billto, 
	ivd_itemquantity, 
	ivd_subtotalptr, 
	ivd_allocatedrev, 
	999,  --ivd_sequence for accessorials is 999
	ivd_invoicestatus, 
	mfh_hdrnumber, 
	ivd_refnum, 
	cmd_code, 
	'UNKNOWN',				--cmp_id (this is for accessorials - this may change)
	ivd_distance, 
	ivd_distunit, 
	ivd_wgt, 
	ivd_wgtunit, 
	ivd_count, 
	ivd_countunit, 
	evt_number, 
	ivd_reftype, 
	ivd_volume, 
	ivd_volunit, 
	ivd_orig_cmpid,  
	ivd_payrevenue, 
	ivd_sign, 
	ivd_length, 
	ivd_lengthunit, 
	ivd_width, 
	ivd_widthunit, 
	ivd_height, 
	ivd_heightunit, 
	ivd_exportstatus, 
	(SELECT chargetype.cht_basisunit FROM chargetype 
		WHERE chargetype.cht_itemcode = invoicedetail.cht_itemcode) cht_basisunit, 
	ivd_remark, 
	tar_number, 
	tar_tariffnumber, 
	tar_tariffitem, 
	'Y',					--ivd_fromord
	ivd_zipcode, 
	ivd_quantity_type, 
	cht_class, 
	ivd_mileagetable, 
	ivd_charge_type, 
	ivd_trl_rent, 
	ivd_trl_rent_start, 
	ivd_trl_rent_end, 
	ivd_rate_type, 
	(SELECT chargetype.cht_lh_min FROM chargetype 
		WHERE chargetype.cht_itemcode = invoicedetail.cht_itemcode) cht_lh_min, 
	(SELECT chargetype.cht_lh_rev FROM chargetype 
		WHERE chargetype.cht_itemcode = invoicedetail.cht_itemcode) cht_lh_rev, 
	(SELECT chargetype.cht_lh_stl FROM chargetype 
		WHERE chargetype.cht_itemcode = invoicedetail.cht_itemcode) cht_lh_stl, 
	(SELECT chargetype.cht_lh_rpt FROM chargetype 
		WHERE chargetype.cht_itemcode = invoicedetail.cht_itemcode) cht_lh_rpt, 
	(SELECT chargetype.cht_rollintolh FROM chargetype 
		WHERE chargetype.cht_itemcode = invoicedetail.cht_itemcode) cht_rollintolh, 
	(SELECT chargetype.cht_lh_prn FROM chargetype 
		WHERE chargetype.cht_itemcode = invoicedetail.cht_itemcode) cht_lh_prn, 
	fgt_number, 
	ivd_paylgh_number, 
	ivd_tariff_type, 
	ivd_taxid, 
	ivd_ordered_volume, 
	ivd_ordered_loadingmeters, 
	ivd_ordered_count,
	ivd_ordered_weight, 
	ivd_loadingmeters, 
	ivd_loadingmeters_unit,
	last_updateby, 
	last_updatedate, 
	ivd_revtype1, 
	ivd_hide, 
	ivd_baserate, 
	ivd_oradjustment, 
	ivd_cbadjustment, 
	ivd_fsc, 
	ivd_splitbillratetype, 
	ivd_rawcharge, 
	ivd_bolid, 
	ivd_shared_wgt,
	ivd_billable_flag
FROM	invoicedetail
WHERE	invoicedetail.ivd_number = @p_ivd_number

SET @v_return_code = @@error

If @v_return_code <> 0
 BEGIN
	Rollback Tran
	Return - 1
 END

Return 1
GO
GRANT EXECUTE ON  [dbo].[insert_into_completion_invoicedetail_sp] TO [public]
GO
