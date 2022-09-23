SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[copy_inv_det_sp] 
	(@p_neword  integer,    
	 @p_oldord  integer)    
AS  

/**
 *
 * NAME:
 * dbo.copy_inv_det_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure deletes deletes all invoice details for the
 * new order, and copies invoice details from the old order,
 * assigning new ivd_number (and the new ord_hdrnumber)
 *
 * RETURNS:
 * none
 *
 * RESULT SETS:
 * none.
 *
 * PARAMETERS:
 * 001 - @p_neword, integer, input;
 *       The order to which to copy invoice details
 * 002 - @p_oldord, integer, input;
 *       The order from which to copy invoice details
 *
 * REFERENCES: 
 * CalledBy001 ? d_inv_edit_detail_sp
 *
 * REVISION HISTORY:
 * 05/16/2006.01 ? PTS32979 - vjh ? New proc
 *
 **/

declare @v_newivd_number integer
declare @v_oldivd_number integer
--select @neword=158270
--select @oldord=143144

delete invoicedetail where ord_hdrnumber=@p_neword

select @v_oldivd_number=min(ivd_number)
from invoicedetail
where ord_hdrnumber=@p_oldord

while (@v_oldivd_number is not null) begin
	execute @v_newivd_number = getsystemnumber 'INVDET',''
	insert invoicedetail (
		ord_hdrnumber, ivd_number,
		ivh_hdrnumber, stp_number, ivd_description, cht_itemcode, 
		ivd_quantity, ivd_rate, ivd_charge, ivd_taxable1, ivd_taxable2, 
		ivd_taxable3, ivd_taxable4, ivd_unit, cur_code, ivd_currencydate, 
		ivd_glnum, ivd_type, ivd_rateunit, ivd_billto, ivd_itemquantity, 
		ivd_subtotalptr, ivd_allocatedrev, ivd_sequence, ivd_invoicestatus, mfh_hdrnumber, 
		ivd_refnum, cmd_code, cmp_id, ivd_distance, ivd_distunit, 
		ivd_wgt, ivd_wgtunit, ivd_count, ivd_countunit, evt_number, 
		ivd_reftype, ivd_volume, ivd_volunit, ivd_orig_cmpid, ivd_payrevenue, 
		ivd_sign, ivd_length, ivd_lengthunit, ivd_width, ivd_widthunit, 
		ivd_height, ivd_heightunit, ivd_exportstatus, cht_basisunit, ivd_remark, 
		tar_number, tar_tariffnumber, tar_tariffitem, ivd_fromord, ivd_zipcode, 
		ivd_quantity_type, cht_class, ivd_mileagetable, ivd_charge_type, ivd_trl_rent, 
		ivd_trl_rent_start, ivd_trl_rent_end, ivd_rate_type, last_updateby, last_updatedate, 
		cht_lh_min, cht_lh_rev, cht_lh_stl, cht_lh_rpt, cht_rollintolh, 
		cht_lh_prn, fgt_number, ivd_paylgh_number, ivd_tariff_type, ivd_taxid, 
		ivd_ordered_volume, ivd_ordered_loadingmeters, ivd_ordered_count, ivd_ordered_weight, ivd_loadingmeters, 
		ivd_loadingmeters_unit, ivd_revtype1, ivd_hide, ivd_baserate, ivd_rawcharge, 
		ivd_oradjustment, ivd_cbadjustment, ivd_fsc, ivd_splitbillratetype, ivd_bolid
	)
	select
		@p_neword, @v_newivd_number,
		ivh_hdrnumber, stp_number, ivd_description, cht_itemcode, 
		ivd_quantity, ivd_rate, ivd_charge, ivd_taxable1, ivd_taxable2, 
		ivd_taxable3, ivd_taxable4, ivd_unit, cur_code, ivd_currencydate, 
		ivd_glnum, ivd_type, ivd_rateunit, ivd_billto, ivd_itemquantity, 
		ivd_subtotalptr, ivd_allocatedrev, ivd_sequence, ivd_invoicestatus, mfh_hdrnumber, 
		ivd_refnum, cmd_code, cmp_id, ivd_distance, ivd_distunit, 
		ivd_wgt, ivd_wgtunit, ivd_count, ivd_countunit, evt_number, 
		ivd_reftype, ivd_volume, ivd_volunit, ivd_orig_cmpid, ivd_payrevenue, 
		ivd_sign, ivd_length, ivd_lengthunit, ivd_width, ivd_widthunit, 
		ivd_height, ivd_heightunit, ivd_exportstatus, cht_basisunit, ivd_remark, 
		tar_number, tar_tariffnumber, tar_tariffitem, ivd_fromord, ivd_zipcode, 
		ivd_quantity_type, cht_class, ivd_mileagetable, ivd_charge_type, ivd_trl_rent, 
		ivd_trl_rent_start, ivd_trl_rent_end, ivd_rate_type, last_updateby, last_updatedate, 
		cht_lh_min, cht_lh_rev, cht_lh_stl, cht_lh_rpt, cht_rollintolh, 
		cht_lh_prn, fgt_number, ivd_paylgh_number, ivd_tariff_type, ivd_taxid, 
		ivd_ordered_volume, ivd_ordered_loadingmeters, ivd_ordered_count, ivd_ordered_weight, ivd_loadingmeters, 
		ivd_loadingmeters_unit, ivd_revtype1, ivd_hide, ivd_baserate, ivd_rawcharge, 
		ivd_oradjustment, ivd_cbadjustment, ivd_fsc, ivd_splitbillratetype, ivd_bolid
	from invoicedetail
	where ivd_number = @v_oldivd_number

	select @v_oldivd_number=min(ivd_number)
	from invoicedetail
	where ord_hdrnumber=@p_oldord
	and ivd_number > @v_oldivd_number
end

GO
GRANT EXECUTE ON  [dbo].[copy_inv_det_sp] TO [public]
GO
