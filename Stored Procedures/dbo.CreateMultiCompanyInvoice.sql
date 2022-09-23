SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[CreateMultiCompanyInvoice] 
	@ivh_invoicenumber varchar(30),
	@ivh_hdrnumber integer
AS  

/**
 *
 * NAME:
 * dbo.CreateMultiCompanyInvoice
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This proc creates a new duplicate invoice based on an original invoice.
 * The new invoice is used as an intercompany transfer.
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
 * 
 *
 * REVISION HISTORY:
 * 05/16/2006.01 ? PTS32979 - vjh ? New proc
 * 09/22/2015 - PTS 87141 - MRH, stole proc from Vince, changing to create a copy of an existing  invoice.
 *
 **/

declare @v_newivh_number integer
declare @v_newivd_number integer
declare @v_oldivd_number integer

------------------------------
-- Copy the invoice header.
------------------------------
	execute @v_newivh_number = getsystemnumber 'INVHDR',''
	select @v_newivh_number
	INSERT INTO [invoiceheader]
           ([ivh_invoicenumber]
           ,[ivh_billto]
           ,[ivh_terms]
           ,[ivh_totalcharge]
           ,[ivh_shipper]
           ,[ivh_consignee]
           ,[ivh_originpoint]
           ,[ivh_destpoint]
           ,[ivh_invoicestatus]
           ,[ivh_origincity]
           ,[ivh_destcity]
           ,[ivh_originstate]
           ,[ivh_deststate]
           ,[ivh_originregion1]
           ,[ivh_destregion1]
           ,[ivh_supplier]
           ,[ivh_shipdate]
           ,[ivh_deliverydate]
           ,[ivh_revtype1]
           ,[ivh_revtype2]
           ,[ivh_revtype3]
           ,[ivh_revtype4]
           ,[ivh_totalweight]
           ,[ivh_totalpieces]
           ,[ivh_totalmiles]
           ,[ivh_currency]
           ,[ivh_currencydate]
           ,[ivh_totalvolume]
           ,[ivh_taxamount1]
           ,[ivh_taxamount2]
           ,[ivh_taxamount3]
           ,[ivh_taxamount4]
           ,[ivh_transtype]
           ,[ivh_creditmemo]
           ,[ivh_applyto]
           ,[shp_hdrnumber]
           ,[ivh_printdate]
           ,[ivh_billdate]
           ,[ivh_lastprintdate]
           ,[ivh_hdrnumber]
           ,[ord_hdrnumber]
           ,[ivh_originregion2]
           ,[ivh_originregion3]
           ,[ivh_originregion4]
           ,[ivh_destregion2]
           ,[ivh_destregion3]
           ,[ivh_destregion4]
           ,[mfh_hdrnumber]
           ,[ivh_remark]
           ,[ivh_driver]
           ,[ivh_tractor]
           ,[ivh_trailer]
           ,[ivh_user_id1]
           ,[ivh_user_id2]
           ,[ivh_ref_number]
           ,[ivh_driver2]
           ,[mov_number]
           ,[ivh_edi_flag]
           ,[ivh_freight_miles]
           ,[ivh_priority]
           ,[ivh_low_temp]
           ,[ivh_high_temp]
           ,[ivh_xferdate]
           ,[ivh_order_by]
           ,[tar_tarriffnumber]
           ,[tar_number]
           ,[ivh_bookyear]
           ,[ivh_bookmonth]
           ,[tar_tariffitem]
           ,[ivh_maxlength]
           ,[ivh_maxwidth]
           ,[ivh_maxheight]
           ,[ivh_mbstatus]
           ,[ivh_mbnumber]
           ,[ord_number]
           ,[ivh_quantity]
           ,[ivh_rate]
           ,[ivh_charge]
           ,[cht_itemcode]
           ,[ivh_splitbill_flag]
           ,[ivh_company]
           ,[ivh_carrier]
           ,[ivh_archarge]
           ,[ivh_arcurrency]
           ,[ivh_loadtime]
           ,[ivh_unloadtime]
           ,[ivh_drivetime]
           ,[ivh_totaltime]
           ,[ivh_rateby]
           ,[ivh_revenue_date]
           ,[ivh_batch_id]
           ,[ivh_stopoffs]
           ,[Ivh_quantity_type]
           ,[ivh_charge_type]
           ,[ivh_originzipcode]
           ,[ivh_destzipcode]
           ,[ivh_ratingquantity]
           ,[ivh_ratingunit]
           ,[ivh_unit]
           ,[ivh_mileage_adjustment]
           ,[ivh_definition]
           ,[ivh_hideshipperaddr]
           ,[ivh_hideconsignaddr]
           ,[ivh_paperworkstatus]
           ,[ivh_showshipper]
           ,[ivh_showcons]
           ,[ivh_allinclusivecharge]
           ,[ivh_order_cmd_code]
           ,[ivh_applyto_definition]
           ,[ivh_reftype]
           ,[ivh_attention]
           ,[ivh_rate_type]
           ,[ivh_paperwork_override]
           ,[ivh_cmrbill_link]
           ,[ivh_mbperiod]
           ,[ivh_mbperiodstart]
           ,[ivh_imagestatus]
           ,[ivh_imagestatus_date]
           ,[ivh_imagecount]
           ,[ivh_mbimagestatus]
           ,[ivh_mbimagestatus_date]
           ,[ivh_mbimagecount]
           ,[last_updateby]
           ,[last_updatedate]
           ,[ivh_custdoc]
           ,[ivh_mileage_adj_pct]
           ,[inv_revenue_pay_fix]
           ,[inv_revenue_pay]
           ,[ivh_billto_parent]
           ,[ivh_block_printing]
           ,[ivh_entryport]
           ,[ivh_exitport]
           ,[ivh_paid_amount]
           ,[ivh_pay_status]
           ,[ivh_dimfactor]
           ,[ivh_TrlConfiguration]
           ,[ivh_fuelprice]
           ,[ivh_gp_gl_postdate]
           ,[ivh_charge_type_lh]
           ,[ivh_booked_revtype1]
           ,[ivh_order_source]
           ,[ivh_misc_number]
           ,[ivh_paid_indicator]
           ,[ivh_lastchecknumber]
           ,[ivh_lastcheckamount]
           ,[ivh_totalpaid]
           ,[ivh_lastcheckdate]
           ,[ivh_exchangerate]
           ,[ivh_loaded_distance]
           ,[ivh_empty_distance]
           ,[ivh_BelongsTo]
           ,[ivh_furthestpointconsignee]
           ,[ivh_invoiceby]
           ,[ivh_mbnumber_custom]
           ,[ivh_leaseid]
           ,[ivh_leaseperiodenddate]
           ,[ivh_nomincharges]
           ,[car_key]
           ,[ivh_docnumber]
           ,[ivh_trailer2]
           ,[ivh_reprint]
           ,[ivh_GPDatabase]
           ,[ivh_GPserver]
           ,[ivh_GPTerritory]
           ,[ivh_GPSalesPerson]
           ,[ivh_GPPONumber]
           ,[ivh_GPDocDescription]
           ,[ivh_GPCustNumber]
           ,[ivh_GPDocnumber]
           ,[ivh_GPbachnumbeer]
           ,[ivh_GPbilldate]
           ,[ivh_GPDuedate]
           ,[ivh_GPpostdate]
           ,[rowsec_rsrv_id]
           ,[dbh_id]
           --,[ivh_billing_usedate]
           --,[ivh_billing_usedate_setting]
           ,[ivh_mb_customgroupby]
           ,[ivh_dballocate_flag]
           ,[ivh_dedicated_includedate]
           ,[ivh_donotprint]
           ,[ivh_splitgroup]
          -- ,[ivh_dedicated_invnumber]
           ,[ivh_subcompany])

	SELECT @ivh_invoicenumber
           ,[ivh_billto]
           ,[ivh_terms]
           ,[ivh_totalcharge]
           ,[ivh_shipper]
           ,[ivh_consignee]
           ,[ivh_originpoint]
           ,[ivh_destpoint]
           ,[ivh_invoicestatus]
           ,[ivh_origincity]
           ,[ivh_destcity]
           ,[ivh_originstate]
           ,[ivh_deststate]
           ,[ivh_originregion1]
           ,[ivh_destregion1]
           ,[ivh_supplier]
           ,[ivh_shipdate]
           ,[ivh_deliverydate]
           ,[ivh_revtype1]
           ,[ivh_revtype2]
           ,[ivh_revtype3]
           ,[ivh_revtype4]
           ,[ivh_totalweight]
           ,[ivh_totalpieces]
           ,[ivh_totalmiles]
           ,[ivh_currency]
           ,[ivh_currencydate]
           ,[ivh_totalvolume]
           ,[ivh_taxamount1]
           ,[ivh_taxamount2]
           ,[ivh_taxamount3]
           ,[ivh_taxamount4]
           ,[ivh_transtype]
           ,[ivh_creditmemo]
           ,[ivh_applyto]
           ,[shp_hdrnumber]
           ,[ivh_printdate]
           ,[ivh_billdate]
           ,[ivh_lastprintdate]
           ,@v_newivh_number
           ,[ord_hdrnumber]
           ,[ivh_originregion2]
           ,[ivh_originregion3]
           ,[ivh_originregion4]
           ,[ivh_destregion2]
           ,[ivh_destregion3]
           ,[ivh_destregion4]
           ,[mfh_hdrnumber]
           ,[ivh_remark]
           ,[ivh_driver]
           ,[ivh_tractor]
           ,[ivh_trailer]
           ,[ivh_user_id1]
           ,[ivh_user_id2]
           ,[ivh_ref_number]
           ,[ivh_driver2]
           ,[mov_number]
           ,[ivh_edi_flag]
           ,[ivh_freight_miles]
           ,[ivh_priority]
           ,[ivh_low_temp]
           ,[ivh_high_temp]
           ,[ivh_xferdate]
           ,[ivh_order_by]
           ,[tar_tarriffnumber]
           ,[tar_number]
           ,[ivh_bookyear]
           ,[ivh_bookmonth]
           ,[tar_tariffitem]
           ,[ivh_maxlength]
           ,[ivh_maxwidth]
           ,[ivh_maxheight]
           ,[ivh_mbstatus]
           ,[ivh_mbnumber]
           ,[ord_number]
           ,[ivh_quantity]
           ,[ivh_rate]
           ,[ivh_charge]
           ,[cht_itemcode]
           ,[ivh_splitbill_flag]
           ,[ivh_company]
           ,[ivh_carrier]
           ,[ivh_archarge]
           ,[ivh_arcurrency]
           ,[ivh_loadtime]
           ,[ivh_unloadtime]
           ,[ivh_drivetime]
           ,[ivh_totaltime]
           ,[ivh_rateby]
           ,[ivh_revenue_date]
           ,[ivh_batch_id]
           ,[ivh_stopoffs]
           ,[Ivh_quantity_type]
           ,[ivh_charge_type]
           ,[ivh_originzipcode]
           ,[ivh_destzipcode]
           ,[ivh_ratingquantity]
           ,[ivh_ratingunit]
           ,[ivh_unit]
           ,[ivh_mileage_adjustment]
           ,case [ivh_definition] when 'LH' then 'SUPL' else [ivh_definition] end
           ,[ivh_hideshipperaddr]
           ,[ivh_hideconsignaddr]
           ,[ivh_paperworkstatus]
           ,[ivh_showshipper]
           ,[ivh_showcons]
           ,[ivh_allinclusivecharge]
           ,[ivh_order_cmd_code]
           ,[ivh_applyto_definition]
           ,[ivh_reftype]
           ,[ivh_attention]
           ,[ivh_rate_type]
           ,[ivh_paperwork_override]
           ,[ivh_cmrbill_link]
           ,[ivh_mbperiod]
           ,[ivh_mbperiodstart]
           ,[ivh_imagestatus]
           ,[ivh_imagestatus_date]
           ,[ivh_imagecount]
           ,[ivh_mbimagestatus]
           ,[ivh_mbimagestatus_date]
           ,[ivh_mbimagecount]
           ,[last_updateby]
           ,[last_updatedate]
           ,[ivh_custdoc]
           ,[ivh_mileage_adj_pct]
           ,[inv_revenue_pay_fix]
           ,[inv_revenue_pay]
           ,[ivh_billto_parent]
           ,[ivh_block_printing]
           ,[ivh_entryport]
           ,[ivh_exitport]
           ,[ivh_paid_amount]
           ,[ivh_pay_status]
           ,[ivh_dimfactor]
           ,[ivh_TrlConfiguration]
           ,[ivh_fuelprice]
           ,[ivh_gp_gl_postdate]
           ,[ivh_charge_type_lh]
           ,[ivh_booked_revtype1]
           ,[ivh_order_source]
           ,[ivh_misc_number]
           ,[ivh_paid_indicator]
           ,[ivh_lastchecknumber]
           ,[ivh_lastcheckamount]
           ,[ivh_totalpaid]
           ,[ivh_lastcheckdate]
           ,[ivh_exchangerate]
           ,[ivh_loaded_distance]
           ,[ivh_empty_distance]
           ,[ivh_BelongsTo]
           ,[ivh_furthestpointconsignee]
           ,[ivh_invoiceby]
           ,[ivh_mbnumber_custom]
           ,[ivh_leaseid]
           ,[ivh_leaseperiodenddate]
           ,[ivh_nomincharges]
           ,[car_key]
           ,[ivh_docnumber]
           ,[ivh_trailer2]
           ,[ivh_reprint]
           ,[ivh_GPDatabase]
           ,[ivh_GPserver]
           ,[ivh_GPTerritory]
           ,[ivh_GPSalesPerson]
           ,[ivh_GPPONumber]
           ,[ivh_GPDocDescription]
           ,[ivh_GPCustNumber]
           ,[ivh_GPDocnumber]
           ,[ivh_GPbachnumbeer]
           ,[ivh_GPbilldate]
           ,[ivh_GPDuedate]
           ,[ivh_GPpostdate]
           ,[rowsec_rsrv_id]
           ,[dbh_id]
           --,[ivh_billing_usedate]
           --,[ivh_billing_usedate_setting]
           ,[ivh_mb_customgroupby]
           ,[ivh_dballocate_flag]
           ,[ivh_dedicated_includedate]
           ,[ivh_donotprint]
           ,[ivh_splitgroup]
          -- ,[ivh_dedicated_invnumber]
           ,[ivh_subcompany] 
           FROM [invoiceheader] where ivh_hdrnumber = @ivh_hdrnumber

------------------------------
-- Copy the invoice details.
-- Update the details with the new header number.
------------------------------
select @v_oldivd_number=min(ivd_number)
from invoicedetail
where ivh_hdrnumber = @ivh_hdrnumber

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
		ord_hdrnumber, @v_newivd_number,
		@v_newivh_number, stp_number, ivd_description, cht_itemcode, 
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
	where ivh_hdrnumber = @ivh_hdrnumber
	and ivd_number > @v_oldivd_number
end
Return @v_newivh_number

GO
GRANT EXECUTE ON  [dbo].[CreateMultiCompanyInvoice] TO [public]
GO
