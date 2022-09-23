SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[nonbillable_invoicedetail_sp]	@p_ord_hdrnumber	int

AS

/**
 * 
 * NAME:
 * nonbillable_invoicedetail_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: NONE
 *
 * REVISION HISTORY:
 * 12/14/2006.01 ? PTS33397 - Dan Hudec ? Created Procedure
 *
 **/

--IF EXISTS (select * from invoiceheader
--		   where  ord_hdrnumber = @p_ord_hdrnumber)	
 BEGIN	
	SELECT	completion_invoicedetail.ivh_hdrnumber, 
			completion_invoicedetail.ivd_number, 
			completion_invoicedetail.stp_number, 
			completion_invoicedetail.ivd_description, 
			completion_invoicedetail.cht_itemcode, 
			completion_invoicedetail.ivd_quantity, 
			completion_invoicedetail.ivd_rate, 
			completion_invoicedetail.ivd_charge, 
			completion_invoicedetail.ivd_taxable1, 
			completion_invoicedetail.ivd_taxable2, 
			completion_invoicedetail.ivd_taxable3, 
			completion_invoicedetail.ivd_taxable4, 
			completion_invoicedetail.ivd_unit, 
			completion_invoicedetail.cur_code, 
			completion_invoicedetail.ivd_currencydate,
			completion_invoicedetail.ivd_glnum, 
			completion_invoicedetail.ord_hdrnumber, 
			completion_invoicedetail.ivd_type, 
			completion_invoicedetail.ivd_rateunit, 
			completion_invoicedetail.ivd_billto, 
			completion_invoicedetail.ivd_itemquantity, 
			completion_invoicedetail.ivd_subtotalptr, 
			completion_invoicedetail.ivd_allocatedrev, 
			completion_invoicedetail.ivd_sequence, 
			completion_invoicedetail.ivd_invoicestatus, 
			completion_invoicedetail.mfh_hdrnumber, 
			completion_invoicedetail.ivd_refnum, 
			completion_invoicedetail.cmd_code, 
			completion_invoicedetail.cmp_id, 
			completion_invoicedetail.ivd_distance, 
			completion_invoicedetail.ivd_distunit, 
			completion_invoicedetail.ivd_wgt, 
			completion_invoicedetail.ivd_wgtunit, 
			completion_invoicedetail.ivd_count, 
			completion_invoicedetail.ivd_countunit, 
			completion_invoicedetail.evt_number, 
			completion_invoicedetail.ivd_reftype, 
			completion_invoicedetail.ivd_volume, 
			completion_invoicedetail.ivd_volunit, 
			completion_invoicedetail.ivd_orig_cmpid, 
			completion_invoicedetail.ivd_payrevenue, 
			completion_invoicedetail.ivd_sign, 
			completion_invoicedetail.ivd_length, 
			completion_invoicedetail.ivd_lengthunit, 
			completion_invoicedetail.ivd_width, 
			completion_invoicedetail.ivd_widthunit, 
			completion_invoicedetail.ivd_height, 
			completion_invoicedetail.ivd_heightunit, 
			completion_invoicedetail.ivd_exportstatus, 
			completion_invoicedetail.cht_basisunit, 
			completion_invoicedetail.ivd_remark, 
			completion_invoicedetail.tar_number, 
			completion_invoicedetail.tar_tariffnumber, 
			completion_invoicedetail.tar_tariffitem, 
			completion_invoicedetail.ivd_fromord, 
			completion_invoicedetail.ivd_zipcode, 
			completion_invoicedetail.ivd_quantity_type, 
			completion_invoicedetail.cht_class, 
			completion_invoicedetail.ivd_mileagetable, 
			completion_invoicedetail.ivd_charge_type, 
			completion_invoicedetail.ivd_trl_rent, 
			completion_invoicedetail.ivd_trl_rent_start, 
			completion_invoicedetail.ivd_trl_rent_end, 
			completion_invoicedetail.ivd_rate_type, 
			completion_invoicedetail.cht_lh_min, 
			completion_invoicedetail.cht_lh_rev, 
			completion_invoicedetail.cht_lh_stl, 
			completion_invoicedetail.cht_lh_rpt, 
			completion_invoicedetail.cht_rollintolh, 
			completion_invoicedetail.cht_lh_prn, 
			completion_invoicedetail.fgt_number, 
			completion_invoicedetail.ivd_paylgh_number, 
			completion_invoicedetail.ivd_tariff_type, 
			completion_invoicedetail.ivd_taxid, 
			completion_invoicedetail.ivd_ordered_volume, 
			completion_invoicedetail.ivd_ordered_loadingmeters, 
			completion_invoicedetail.ivd_ordered_count,
			completion_invoicedetail.ivd_ordered_weight, 
			completion_invoicedetail.ivd_loadingmeters, 
			completion_invoicedetail.ivd_loadingmeters_unit,
			completion_invoicedetail.last_updateby, 
			completion_invoicedetail.last_updatedate, 
			completion_invoicedetail.ivd_revtype1, 
			completion_invoicedetail.ivd_hide, 
			completion_invoicedetail.ivd_baserate,  
			completion_invoicedetail.ivd_oradjustment, 
			completion_invoicedetail.ivd_cbadjustment, 
			completion_invoicedetail.ivd_fsc, 
			completion_invoicedetail.ivd_splitbillratetype, 
			completion_invoicedetail.ivd_rawcharge, 
			completion_invoicedetail.ivd_bolid, 
			completion_invoicedetail.ivd_shared_wgt,
			completion_invoicedetail.ivd_completion_odometer,
			completion_invoicedetail.ivd_completion_billable_flag,
			completion_invoicedetail.ivd_completion_payable_flag,
			completion_invoicedetail.ivd_completion_drv_id,
			completion_invoicedetail.ivd_completion_drv_name,
			completion_invoicedetail.cht_description,
			chargetype.cht_edit_completion_rate,
			chargetype.cht_basis					--LOR	PTS# 48662
	FROM	completion_invoicedetail, chargetype
	WHERE	completion_invoicedetail.ord_hdrnumber = @p_ord_hdrnumber
	  AND	completion_invoicedetail.cht_itemcode = chargetype.cht_itemcode
--	  AND	IsNull(completion_invoicedetail.ivd_completion_billable_flag, 'N') = 'N'
 END 

GO
GRANT EXECUTE ON  [dbo].[nonbillable_invoicedetail_sp] TO [public]
GO
