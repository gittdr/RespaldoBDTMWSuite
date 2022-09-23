SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 Create Proc [dbo].[d_ordaccessorial_sp] @p_ordhdrnumber int 
As  
/*   
PTS 58090 DPETE created 9/27/11
PTS 60377 DPETE created 12/1/11 customer with window authentication are faing ot get anything back from this proc
*/ 
declare @tmwuser varchar(255)
exec gettmwuser @tmwuser output
 
-- if there is no invoice by MON or MOVCON already created for this order...
If not exists (select 1 from invoicemaster where ord_hdrnumber = @p_ordhdrnumber)
 
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
			invoicedetail.ivd_tariff_type,	
			invoicedetail.ivd_taxid,
			chargetype.gp_Tax,
			invoicedetail.ivd_charge_type, 
         invoicedetail.cht_lh_prn ,
			invoicedetail.ivd_revtype1,
			'RevType1' RevType1_t,
         'ChrgTypeClass' chrgtypeclass,
         IsNull(invoiceheader.ivh_invoicenumber,'') ivh_invoicenumber,
         IsNUll(invoiceheader.ivh_definition,'') ivh_definition,
			IsNUll(ivd_hide,'N') ivd_hide, 
			IsNUll(usr_supervisor,'N') usr_supervisor,
            invoicedetail.fgt_number
   FROM  invoicedetail 
   left outer join company on invoicedetail.cmp_id =  company.cmp_id  
   left outer join chargetype on chargetype.cht_itemcode = invoicedetail.cht_itemcode
   left outer join commodity on commodity.cmd_code = invoicedetail.cmd_code
   left outer join tariffheader on invoicedetail.tar_number = tariffheader.tar_number 
   left outer join invoiceheader on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber 
   left outer join ttsusers on ttsusers.usr_userid = @tmwuser --suser_sname()
   WHERE (invoicedetail.ord_hdrnumber = @p_ordhdrnumber) and	
	(chargetype.cht_primary = 'N' or 
	(invoicedetail.cht_itemcode = 'MIN' and invoicedetail.tar_tariffnumber = 'COMPANY') OR
	(chargetype.cht_primary = 'Y' and chargetype.cht_basis = 'ACC' and chargetype.cht_itemcode <> 'MIN') OR
	(invoicedetail.cht_itemcode = 'MIN' and ivd_fromord = 'P') or 
	( IsNull(tar_tblratingoption,'') = 'INCRMT') OR (chargetype.cht_basisunit = 'COST')) 
	and invoicedetail.ivd_type = 'LI' 
	
ELSE

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
			invoicedetail.ivd_tariff_type,	
			invoicedetail.ivd_taxid,
			chargetype.gp_Tax,
			invoicedetail.ivd_charge_type, 
         invoicedetail.cht_lh_prn ,
			invoicedetail.ivd_revtype1,
			'RevType1' RevType1_t,
         'ChrgTypeClass' chrgtypeclass,
         IsNull(invoiceheader.ivh_invoicenumber,'') ivh_invoicenumber,
         IsNUll(invoiceheader.ivh_definition,'') ivh_definition,
			IsNUll(ivd_hide,'N') ivd_hide, 
			IsNUll(usr_supervisor,'N') usr_supervisor,
            invoicedetail.fgt_number
   FROM  invoicemaster
   left outer join invoicedetail on invoicemaster.ivm_invoiceordhdrnumber = invoicedetail.ord_hdrnumber 
   left outer join orderheader on invoicemaster.ord_hdrnumber = orderheader.ord_hdrnumber
   left outer join company on invoicedetail.cmp_id =  company.cmp_id  
   left outer join chargetype on chargetype.cht_itemcode = invoicedetail.cht_itemcode
   left outer join commodity on commodity.cmd_code = invoicedetail.cmd_code
   left outer join tariffheader on invoicedetail.tar_number = tariffheader.tar_number 
   left outer join invoiceheader on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber 
   join ttsusers on ttsusers.usr_userid =  @tmwuser -- suser_sname()
   WHERE (invoicemaster.ord_hdrnumber = @p_ordhdrnumber) and
	 orderheader.ord_number = invoicedetail.ivd_ord_number and -- this is how we get accessorials only for this order on the blended invoice
	(chargetype.cht_primary = 'N' or 
	(invoicedetail.cht_itemcode = 'MIN' and invoicedetail.tar_tariffnumber = 'COMPANY') OR
	(chargetype.cht_primary = 'Y' and chargetype.cht_basis = 'ACC' and chargetype.cht_itemcode <> 'MIN') OR
	(invoicedetail.cht_itemcode = 'MIN' and ivd_fromord = 'P') or 
	( IsNull(tar_tblratingoption,'') = 'INCRMT') OR (chargetype.cht_basisunit = 'COST')) 
	and invoicedetail.ivd_type = 'LI' 
GO
GRANT EXECUTE ON  [dbo].[d_ordaccessorial_sp] TO [public]
GO
