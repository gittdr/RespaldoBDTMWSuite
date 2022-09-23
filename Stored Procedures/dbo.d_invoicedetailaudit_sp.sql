SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create procedure [dbo].[d_invoicedetailaudit_sp] 
	(@pl_ivd_number int) 
as

/* d_invoicedetailaudit_sp

	Retrieves invoicedetailaudit & invoicedetail rows to get a full audit of activity 
	on the invoicedetail table.

	Parameters:	@pl_ivd_number		The InvoiceDetail key to search by.

	Returns:	none (result set)

	Revision History:
	Date		Name			Label	Description
	-----------	---------------	-------	---------------------------------------------
	05/24/2001	Vern Jewett		(none)	Original
*/

/*PTS 36955 JJF 20080625
/* invoicedetail contains most recent info..	*/
select	ivd_number
		,0 as audit_sequence
		,'' as audit_status
		,'' as audit_user
		,getdate() as audit_date
		,cht_itemcode
		,ivd_quantity
		,ivd_rate
		,ivd_charge
		,tar_number
		,ivh_hdrnumber
		,ord_hdrnumber
  from	invoicedetail
  where	ivd_number = @pl_ivd_number

/* invoicedetailaudit contains previous versions..	*/
union
select	ivd_number
		,audit_sequence
		,audit_status
		,audit_user
		,audit_date
		,cht_itemcode
		,ivd_quantity
		,ivd_rate
		,ivd_charge
		,tar_number
		,ivh_hdrnumber
		,ord_hdrnumber
  from	invoicedetailaudit
  where	ivd_number = @pl_ivd_number
*/
	SELECT 'B' as RecordOrigin
			,ivd_number
			,audit_sequence
			,audit_status
			,audit_user
			,audit_date
			,cht_itemcode
			,ivd_quantity
			,ivd_rate
			,ivd_charge
			,tar_number
			,ivh_hdrnumber
			,ord_hdrnumber
			,audit_app
			,stp_number
			,ivd_description
			,ivd_taxable1
			,ivd_taxable2
			,ivd_taxable3
			,ivd_taxable4
			,ivd_unit
			,cur_code
			,ivd_currencydate
			,ivd_glnum
			,ivd_type
			,ivd_rateunit
			,ivd_billto
			,ivd_itemquantity
			,ivd_subtotalptr
			,ivd_allocatedrev
			,ivd_sequence
			,ivd_invoicestatus
			,mfh_hdrnumber
			,ivd_refnum
			,cmd_code
			,cmp_id
			,ivd_distance
			,ivd_distunit
			,ivd_wgt
			,ivd_wgtunit
			,ivd_count
			,ivd_countunit
			,evt_number
			,ivd_reftype
			,ivd_volume
			,ivd_volunit
			,ivd_orig_cmpid
			,ivd_payrevenue
			,ivd_sign
			,ivd_length
			,ivd_lengthunit
			,ivd_width
			,ivd_widthunit
			,ivd_height
			,ivd_heightunit
			,ivd_exportstatus
			,cht_basisunit
			,ivd_remark
			,tar_tariffnumber
			,tar_tariffitem
			,ivd_fromord
			,ivd_zipcode
			,ivd_quantity_type
			,cht_class
			,ivd_mileagetable
			,ivd_charge_type
			,ivd_trl_rent
			,ivd_trl_rent_start
			,ivd_trl_rent_end
			,ivd_rate_type
			,last_updateby
			,last_updatedate
			,cht_lh_min
			,cht_lh_rev
			,cht_lh_stl
			,cht_lh_rpt
			,cht_rollintolh
			,cht_lh_prn
			,fgt_number
			,ivd_paylgh_number
			,ivd_tariff_type
			,ivd_taxid
			,ivd_ordered_volume
			,ivd_ordered_loadingmeters
			,ivd_ordered_count
			,ivd_ordered_weight
			,ivd_loadingmeters
			,ivd_loadingmeters_unit
			,ivd_revtype1
			,ivd_hide
			,ivd_baserate
			,ivd_rawcharge
			,ivd_oradjustment
			,ivd_cbadjustment
			,ivd_fsc
			,ivd_splitbillratetype
			,ivd_bolid
			,ivd_shared_wgt
			,ivd_miscmoney1
			,ivd_tollcost
			,ivd_ARTaxAuth
			,ivd_paid_indicator
			,ivd_paid_amount
			,ivd_actual_quantity
			,ivd_actual_unit
			,ivd_tax_basis
			,fgt_supplier
			,ivd_loaded_distance
			,ivd_empty_distance
			,ivd_MaskFromRating 
			,ivd_car_key 
			,ivd_leaseassetid 
			,ivd_showas_cmpid 
	FROM	invoicedetailaudit
	WHERE	ivd_number = @pl_ivd_number

	UNION

	SELECT 'A' as RecordOrigin
			,ivd_number
			,0 as audit_sequence
			,'N' as audit_status
			,'' as audit_user
			,getdate() as audit_date
			,cht_itemcode
			,ivd_quantity
			,ivd_rate
			,ivd_charge
			,tar_number
			,ivh_hdrnumber
			,ord_hdrnumber
			,'' as audit_app
			,stp_number
			,ivd_description
			,ivd_taxable1
			,ivd_taxable2
			,ivd_taxable3
			,ivd_taxable4
			,ivd_unit
			,cur_code
			,ivd_currencydate
			,ivd_glnum
			,ivd_type
			,ivd_rateunit
			,ivd_billto
			,ivd_itemquantity
			,ivd_subtotalptr
			,ivd_allocatedrev
			,ivd_sequence
			,ivd_invoicestatus
			,mfh_hdrnumber
			,ivd_refnum
			,cmd_code
			,cmp_id
			,ivd_distance
			,ivd_distunit
			,ivd_wgt
			,ivd_wgtunit
			,ivd_count
			,ivd_countunit
			,evt_number
			,ivd_reftype
			,ivd_volume
			,ivd_volunit
			,ivd_orig_cmpid
			,ivd_payrevenue
			,ivd_sign
			,ivd_length
			,ivd_lengthunit
			,ivd_width
			,ivd_widthunit
			,ivd_height
			,ivd_heightunit
			,ivd_exportstatus
			,cht_basisunit
			,ivd_remark
			,tar_tariffnumber
			,tar_tariffitem
			,ivd_fromord
			,ivd_zipcode
			,ivd_quantity_type
			,cht_class
			,ivd_mileagetable
			,ivd_charge_type
			,ivd_trl_rent
			,ivd_trl_rent_start
			,ivd_trl_rent_end
			,ivd_rate_type
			,last_updateby
			,last_updatedate
			,cht_lh_min
			,cht_lh_rev
			,cht_lh_stl
			,cht_lh_rpt
			,cht_rollintolh
			,cht_lh_prn
			,fgt_number
			,ivd_paylgh_number
			,ivd_tariff_type
			,ivd_taxid
			,ivd_ordered_volume
			,ivd_ordered_loadingmeters
			,ivd_ordered_count
			,ivd_ordered_weight
			,ivd_loadingmeters
			,ivd_loadingmeters_unit
			,ivd_revtype1
			,ivd_hide
			,ivd_baserate
			,ivd_rawcharge
			,ivd_oradjustment
			,ivd_cbadjustment
			,ivd_fsc
			,ivd_splitbillratetype
			,ivd_bolid
			,ivd_shared_wgt
			,ivd_miscmoney1
			,ivd_tollcost
			,ivd_ARTaxAuth
			,ivd_paid_indicator
			,ivd_paid_amount
			,ivd_actual_quantity
			,ivd_actual_unit
			,ivd_tax_basis
			,fgt_supplier
			,ivd_loaded_distance
			,ivd_empty_distance
			,ivd_MaskFromRating = null
			,ivd_car_key = null
			,ivd_leaseassetid = null
			,ivd_showas_cmpid = null
	FROM	invoicedetail
	WHERE	ivd_number = @pl_ivd_number


GO
GRANT EXECUTE ON  [dbo].[d_invoicedetailaudit_sp] TO [public]
GO
