SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*
MODIFICATION LOG

DPETE PTS 14283 Display primary accessorial charges in the accessorial maint window
DPETE 18198 Show linehaul MIN charges for commodity totals 
DPETE 13958 make sure incremental line haul charges show up in rate by total
*/
create proc [dbo].[d_ord_accessorials_by_mov_format02_sp] @mov int 
as
  SELECT invoicedetail.cht_itemcode,   
         invoicedetail.ivd_description,   
         invoicedetail.cmp_id,   
         company.cmp_name,   
         company.cty_nmstct,   
         invoicedetail.ivd_quantity,   
         invoicedetail.ivd_rate,   
         invoicedetail.ivd_charge,   
         invoicedetail.ivd_billto,   
         invoicedetail.ivh_hdrnumber,   
         invoicedetail.ivd_number,   
         invoicedetail.ord_hdrnumber,   
         invoicedetail.ivd_glnum,   
         invoicedetail.ivd_type,   
         invoicedetail.ivd_unit,   
         invoicedetail.cur_code,   
         invoicedetail.ivd_currencydate,   
         invoicedetail.ivd_rateunit,   
         invoicedetail.ivd_sequence,   
         invoicedetail.ivd_invoicestatus,   
         invoicedetail.ivd_refnum,   
         invoicedetail.cmd_code,   
         invoicedetail.ivd_reftype,   
         invoicedetail.ivd_sign,   
         chargetype.cht_basis,
			invoicedetail.cht_basisunit,   
         commodity.cmd_taxtable1,   
         commodity.cmd_taxtable2,   
         commodity.cmd_taxtable3,   
         commodity.cmd_taxtable4,   
         invoicedetail.ivd_taxable1,   
         invoicedetail.ivd_taxable2,   
         invoicedetail.ivd_taxable3,   
         invoicedetail.ivd_taxable4,
         invoicedetail.ivd_fromord,
         invoicedetail.tar_number,
         invoicedetail.tar_tariffnumber,
         invoicedetail.tar_tariffitem,
         invoicedetail.ivd_remark,
         invoicedetail.stp_number,
         invoicedetail.cht_class,
         chargetype.cht_rateprotect,
         chargetype.cht_primary,
         invoicedetail.cht_rollintolh,
         invoicedetail.cht_lh_rev,
         invoicedetail.cht_lh_min,
         invoicedetail.cht_lh_stl,
         invoicedetail.cht_lh_rpt,
         invoicedetail.ivd_paylgh_number,
         invoicedetail.ivd_tariff_type,
         invoicedetail.ivd_taxid,
         chargetype.gp_tax,
         invoicedetail.ivd_charge_type, 
         invoicedetail.cht_lh_prn,
	invoicedetail.ivd_wgt,
	invoicedetail.ivd_wgtunit,
	invoicedetail.ivd_count,
	invoicedetail.ivd_countunit,
	invoicedetail.ivd_volume,
	invoicedetail.ivd_volunit,
	invoicedetail.ivd_distance,
	invoicedetail.ivd_distunit ,
	invoicedetail.ivd_revtype1,
	'RevType1' deptno_label,
         'ChrgTypeClass' chrgtypeclass
    FROM company,   
         invoicedetail,   
         chargetype,   
         commodity, (SELECT DISTINCT stops.ord_hdrnumber 
                     FROM stops 
                     WHERE stops.mov_number = @mov and stops.ord_hdrnumber > 0) ordlist ,
         tariffheader 
   WHERE ( company.cmp_id =* invoicedetail.cmp_id) and  
         ( chargetype.cht_itemcode = invoicedetail.cht_itemcode ) and  
         ( commodity.cmd_code = invoicedetail.cmd_code ) and  
         (invoicedetail.ord_hdrnumber = ordlist.ord_hdrnumber)  and 
       tariffheader.tar_number =* invoicedetail.tar_number and
		(chargetype.cht_primary = 'N'       
			OR (chargetype.cht_primary = 'Y' AND chargetype.cht_rollintolh = 1) 
			OR (invoicedetail.cht_itemcode = 'MIN' AND invoicedetail.tar_tariffnumber = 'COMPANY') 
			OR (chargetype.cht_primary = 'Y' and chargetype.cht_basis = 'ACC' and chargetype.cht_itemcode <> 'MIN')
			 Or (invoicedetail.cht_itemcode = 'MIN' and ivd_fromord = 'P') or 
        ( IsNull(tar_tblratingoption,'') = 'INCRMT')) and
        invoicedetail.ivd_type = 'LI'


GO
GRANT EXECUTE ON  [dbo].[d_ord_accessorials_by_mov_format02_sp] TO [public]
GO
