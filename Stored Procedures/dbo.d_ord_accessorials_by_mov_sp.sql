SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
MODIFICATION LOG

DPETE PTS 14283 Display primary accessorial charges in the accessorial maint window
DPETE 18198 Show linehaul MIN charges for commodity totals 
DPETE 13958 make sure incremental line haul charges show up in rate by total
 DPETE 19362 Add invoice number and definition in case accessorials from multiple invoices (Credit,rebill) are pulled
DJM - PTS 17587 - Added the columns to default quantities (distance, pieces, weight, and volume) and units.
 DPETE 19362 Add invoice number and definition in case accessorials from multiple invoices (Credit,rebill) are pulled
* 11/30/2007.01 ? PTS40463 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
* 04/29/2009 pmill Recode Cost+ for TransFreight PTS46676
 * PTS 52087 DPETE add fgt_number to return set
 * PTS58090 DPETE need to accommodate viewing secondary charges on  invoices that were invoiced by MOV or MOVCON not order
 DPETE 61290 not retrieving accessorials for all moves when cross docking 
*/
create proc [dbo].[d_ord_accessorials_by_mov_sp] @mov int 
as
--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
DECLARE @ordlist table (ord_hdrnumber int, ord_number varchar(13), invoiceordhdrnumber int null)
/*
Insert into @ordlist
SELECT DISTINCT ord_hdrnumber ,ord_number,null
FROM orderheader
WHERE mov_number = @mov 
*/
Insert into @ordlist
SELECT DISTINCT s.ord_hdrnumber ,o.ord_number,null
FROM stops s join orderheader o on s.ord_hdrnumber = o.ord_hdrnumber
WHERE s.mov_number = @mov 
and s.ord_hdrnumber > 0

exec gettmwuser @tmwuser output

If not exists (select 1 from invoicemaster where mov_number = @mov)
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
	invoicedetail.ivd_revtype1,
	'RevType1' revtype1_t,
	'ChrgTypeClass' chrgtypeclass_t,
	invoicedetail.ivd_wgt,
	invoicedetail.ivd_wgtunit,
	invoicedetail.ivd_count,
	invoicedetail.ivd_countunit,
	invoicedetail.ivd_volume,
	invoicedetail.ivd_volunit,
	invoicedetail.ivd_distance,
	invoicedetail.ivd_distunit,
	IsNull(ivh_invoicenumber,'') ivh_invoicenumber ,
	IsNull(ivh_definition,'') ivh_definition ,
	c_approved_protect = 0,
	IsNull(ivd_hide, 'N' ) ivd_hide,
	IsNull(usr_supervisor, 'N') usr_supervisor,
	invoicedetail.ivd_payrevenue,
    isnull(invoicedetail.fgt_number,0) invoicedetail_fgt_number
    FROM @ordlist ordlist
    join invoicedetail on ordlist.ord_hdrnumber = invoicedetail.ord_hdrnumber
    left outer join company on invoicedetail.cmp_id = company.cmp_id 
	LEFT OUTER JOIN tariffheader ON tariffheader.tar_number = invoicedetail.tar_number
	LEFT OUTER JOIN invoiceheader ON invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber   
    join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode   
    left outer join commodity on invoicedetail.cmd_code = commodity.cmd_code
    left outer join  ttsusers on ttsusers.usr_userid = @tmwuser
    /*
    , (SELECT DISTINCT stops.ord_hdrnumber 
                     FROM stops 
                     WHERE stops.mov_number = @mov and stops.ord_hdrnumber > 0) ordlist ,
	ttsusers
	*/
   WHERE --( company.cmp_id =* invoicedetail.cmp_id) and  
         --( chargetype.cht_itemcode = invoicedetail.cht_itemcode ) and  
        -- ( commodity.cmd_code = invoicedetail.cmd_code ) and  
        -- (invoicedetail.ord_hdrnumber = ordlist.ord_hdrnumber)  and 
       --tariffheader.tar_number =* invoicedetail.tar_number and
		(chargetype.cht_primary = 'N'       
			OR (chargetype.cht_primary = 'Y' AND chargetype.cht_rollintolh = 1) 
			OR (invoicedetail.cht_itemcode = 'MIN' AND invoicedetail.tar_tariffnumber = 'COMPANY') 
			OR (chargetype.cht_primary = 'Y' and chargetype.cht_basis = 'ACC' and chargetype.cht_itemcode <> 'MIN')
			 Or (invoicedetail.cht_itemcode = 'MIN' and ivd_fromord = 'P') or 
        --( IsNull(tar_tblratingoption,'') = 'INCRMT')) and  46676 pmill
		( IsNull(tar_tblratingoption,'') = 'INCRMT')OR (chargetype.cht_basisunit = 'COST' ) ) and
        invoicedetail.ivd_type = 'LI'
        --and invoiceheader.ivh_hdrnumber =* invoicedetail.ivh_hdrnumber
	--and ttsusers.usr_userid = @tmwuser
ELSE
  BEGIN
         update @ordlist
         set invoiceordhdrnumber = ivm_invoiceordhdrnumber
         from @ordlist olist
         join invoicemaster on olist.ord_hdrnumber = invoicemaster.ord_hdrnumber
         where invoicemaster.mov_number = @mov

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
         isnull(ordlist.ord_hdrnumber,invoicedetail.ord_hdrnumber) ord_hdrnumber,  --invoicedetail.ord_hdrnumber,   
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
	invoicedetail.ivd_revtype1,
	'RevType1' revtype1_t,
	'ChrgTypeClass' chrgtypeclass_t,
	invoicedetail.ivd_wgt,
	invoicedetail.ivd_wgtunit,
	invoicedetail.ivd_count,
	invoicedetail.ivd_countunit,
	invoicedetail.ivd_volume,
	invoicedetail.ivd_volunit,
	invoicedetail.ivd_distance,
	invoicedetail.ivd_distunit,
	IsNull(ivh_invoicenumber,'') ivh_invoicenumber ,
	IsNull(ivh_definition,'') ivh_definition ,
	c_approved_protect = 0,
	IsNull(ivd_hide, 'N' ) ivd_hide,
	IsNull(usr_supervisor, 'N') usr_supervisor,
	invoicedetail.ivd_payrevenue,
    isnull(invoicedetail.fgt_number,0) invoicedetail_fgt_number
    ,ordlist.ord_hdrnumber,invoicedetail.ord_hdrnumber
    FROM @ordlist ordlist
    join invoicedetail on ordlist.ord_number = invoicedetail.ivd_ord_number
    left outer join company on invoicedetail.cmp_id = company.cmp_id 
	LEFT OUTER JOIN tariffheader ON tariffheader.tar_number = invoicedetail.tar_number
	LEFT OUTER JOIN invoiceheader ON invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber   
    join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode   
    left outer join commodity on invoicedetail.cmd_code = commodity.cmd_code
     left outer join ttsusers on ttsusers.usr_userid = @tmwuser
    /*
    , (SELECT DISTINCT stops.ord_hdrnumber 
                     FROM stops 
                     WHERE stops.mov_number = @mov and stops.ord_hdrnumber > 0) ordlist ,
	ttsusers
	*/
   WHERE --( company.cmp_id =* invoicedetail.cmp_id) and  
        -- ( chargetype.cht_itemcode = invoicedetail.cht_itemcode ) and  
        -- ( commodity.cmd_code = invoicedetail.cmd_code ) and  
        -- (invoicedetail.ord_hdrnumber = ordlist.ord_hdrnumber)  and 
       --tariffheader.tar_number =* invoicedetail.tar_number and
		(chargetype.cht_primary = 'N'       
			OR (chargetype.cht_primary = 'Y' AND chargetype.cht_rollintolh = 1) 
			OR (invoicedetail.cht_itemcode = 'MIN' AND invoicedetail.tar_tariffnumber = 'COMPANY') 
			OR (chargetype.cht_primary = 'Y' and chargetype.cht_basis = 'ACC' and chargetype.cht_itemcode <> 'MIN')
			 Or (invoicedetail.cht_itemcode = 'MIN' and ivd_fromord = 'P') or 
        --( IsNull(tar_tblratingoption,'') = 'INCRMT')) and  46676 pmill
		( IsNull(tar_tblratingoption,'') = 'INCRMT')OR (chargetype.cht_basisunit = 'COST' ) ) and
        invoicedetail.ivd_type = 'LI'
        --and invoiceheader.ivh_hdrnumber =* invoicedetail.ivh_hdrnumber
	--and ttsusers.usr_userid = @tmwuser
  END

GO
GRANT EXECUTE ON  [dbo].[d_ord_accessorials_by_mov_sp] TO [public]
GO
