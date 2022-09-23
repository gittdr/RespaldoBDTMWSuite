SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[invoice_template81](@p_invoice_nbr   int,@p_copies  int)  
as
/**
 * 
 * NAME:
 * dbo.invoice_template81
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoice detail records 
 * based on the invoice number selected in the interface.
 *
 * RETURNS:
 * 0 - IF NO DATA WAS FOUND  
 * 1 - IF SUCCESFULLY EXECUTED  
 * @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_invoice_nbr, int, input, null;
 *       This parameter indicates the INVOICE NUMBER(ie.ivh_hdrnumber)
 *       for which the invoice will be printed. The value must be 
 *       non-null and non-empty.
 * 002 - @p_copies, int, input, null;
 *       This parameter indicates the number of hard copies 
 *       to print. The value must be non-null and 
 *       non-empty. 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 *
 * REVISION HISTORY:
 * 03/01/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * 02/02/1999 add cmp_altid from useasbillto company to return set  
 * 01/05/2000 PTS6469 dpete if you have an UNKNOWN consignee or shipper (origin or dest) use the city name in the city table  
 * 06/29/2001 PTS 10870 Vern Jewett  vmj1 : not returning copy # correctly.  
 * 04/22/2002 Jyang add terms_name to return set  
 * 12/05/2003 16314 DPETE use company settings to control terms and linehaul restricitons on mail to  
 * 03/26/2003 16739 DPETE Add cmp_contact for billto company, shipper_geoloc, cons geoloc  to return set for format 41  
 * 12/22/2005 - PTS29626 - Imari bremer - New format for Saratoga 
 * 11/14/2007.01 ? PTS40188 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 **/  
  

declare 
 @v_temp_name   varchar(100) ,  
 @v_temp_addr   varchar(100) ,  
 @v_temp_addr2  varchar(100),  
 @v_temp_nmstct varchar(30),  
 @v_temp_altid  varchar(25),  
 @v_counter    int,  
 @v_ret_value  int,  
 @v_temp_terms    varchar(20),  
 @v_varchar50 varchar(50)  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @v_ret_value = 1  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @v_ret_value = 1  
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  
  
 SELECT  invoiceheader.ivh_invoicenumber,     
         invoiceheader.ivh_hdrnumber,   
  invoiceheader.ivh_billto,   
  @v_temp_name ivh_billto_name ,  
  @v_temp_addr  ivh_billto_addr,  
  @v_temp_addr2 ivh_billto_addr2,           
  @v_temp_nmstct ivh_billto_nmctst,  
         invoiceheader.ivh_terms,      
         invoiceheader.ivh_totalcharge,     
  invoiceheader.ivh_shipper,     
  @v_temp_name shipper_name,  
  @v_temp_addr shipper_addr,  
  @v_temp_addr2 shipper_addr2,  
  @v_temp_nmstct shipper_nmctst,  
         invoiceheader.ivh_consignee,     
  @v_temp_name consignee_name,  
  @v_temp_addr consignee_addr,  
  @v_temp_addr2 consignee_addr2,  
  @v_temp_nmstct consignee_nmctst,  
         invoiceheader.ivh_originpoint,     
  @v_temp_name originpoint_name,  
  @v_temp_addr origin_addr,  
  @v_temp_addr2 origin_addr2,  
  @v_temp_nmstct origin_nmctst,  
         invoiceheader.ivh_destpoint,     
  @v_temp_name destpoint_name,  
  @v_temp_addr dest_addr,  
  @v_temp_addr2 dest_addr2,  
  @v_temp_nmstct dest_nmctst,  
         invoiceheader.ivh_invoicestatus,     
         invoiceheader.ivh_origincity,     
         invoiceheader.ivh_destcity,     
         invoiceheader.ivh_originstate,     
         invoiceheader.ivh_deststate,  
         invoiceheader.ivh_originregion1,     
         invoiceheader.ivh_destregion1,     
         invoiceheader.ivh_supplier,     
         invoiceheader.ivh_shipdate,     
         invoiceheader.ivh_deliverydate,     
         invoiceheader.ivh_revtype1,     
         invoiceheader.ivh_revtype2,     
         invoiceheader.ivh_revtype3,     
         invoiceheader.ivh_revtype4,     
         invoiceheader.ivh_totalweight,     
         invoiceheader.ivh_totalpieces,     
         invoiceheader.ivh_totalmiles,     
         invoiceheader.ivh_currency,     
         invoiceheader.ivh_currencydate,     
         invoiceheader.ivh_totalvolume,     
         invoiceheader.ivh_taxamount1,     
         invoiceheader.ivh_taxamount2,     
         invoiceheader.ivh_taxamount3,     
         invoiceheader.ivh_taxamount4,     
         invoiceheader.ivh_transtype,     
         invoiceheader.ivh_creditmemo,     
         invoiceheader.ivh_applyto,     
         invoiceheader.ivh_printdate,     
         invoiceheader.ivh_billdate,     
         invoiceheader.ivh_lastprintdate,     
         invoiceheader.ivh_originregion2,     
         invoiceheader.ivh_originregion3,     
         invoiceheader.ivh_originregion4,     
         invoiceheader.ivh_destregion2,     
         invoiceheader.ivh_destregion3,     
         invoiceheader.ivh_destregion4,     
         invoiceheader.mfh_hdrnumber,     
         invoiceheader.ivh_remark,     
         invoiceheader.ivh_driver,     
         invoiceheader.ivh_tractor,     
invoiceheader.ivh_trailer,     
         invoiceheader.ivh_user_id1,     
         invoiceheader.ivh_user_id2,     
         invoiceheader.ivh_ref_number,     
         invoiceheader.ivh_driver2,     
         invoiceheader.mov_number,     
         invoiceheader.ivh_edi_flag,     
         invoiceheader.ord_hdrnumber,     
         invoicedetail.ivd_number,     
         invoicedetail.stp_number,     
         invoicedetail.ivd_description,     
         invoicedetail.cht_itemcode,     
         invoicedetail.ivd_quantity,     
         invoicedetail.ivd_rate,     
         invoicedetail.ivd_charge,  
   --invoicedetail.ivd_taxable1,     
         --invoicedetail.ivd_taxable2,     
 -- invoicedetail.ivd_taxable3,     
         --invoicedetail.ivd_taxable4,   
   ivd_taxable1 =  IsNull(chargetype.cht_taxtable1,invoicedetail.ivd_taxable1),   -- taxable flags not set on ivd for gst,pst,etc    
   ivd_taxable2 =IsNull(chargetype.cht_taxtable2,invoicedetail.ivd_taxable2),  
   ivd_taxable3 =IsNull(chargetype.cht_taxtable3,invoicedetail.ivd_taxable3),  
   ivd_taxable4 =IsNull(chargetype.cht_taxtable4,invoicedetail.ivd_taxable4),  
         invoicedetail.ivd_unit,     
         invoicedetail.cur_code,     
         invoicedetail.ivd_currencydate,     
         invoicedetail.ivd_glnum,     
         invoicedetail.ivd_type,     
         invoicedetail.ivd_rateunit,     
         invoicedetail.ivd_billto,     
  @v_temp_name ivd_billto_name,  
  @v_temp_addr ivd_billto_addr,  
  @v_temp_addr2 ivd_billto_addr2,  
  @v_temp_nmstct ivd_billto_nmctst,  
         invoicedetail.ivd_itemquantity,     
         invoicedetail.ivd_subtotalptr,     
         invoicedetail.ivd_allocatedrev,     
         invoicedetail.ivd_sequence,     
         invoicedetail.ivd_refnum,     
         invoicedetail.cmd_code,     
         invoicedetail.cmp_id,     
  @v_temp_name stop_name,  
  @v_temp_addr stop_addr,  
  @v_temp_addr2 stop_addr2,  
  @v_temp_nmstct stop_nmctst,  
         invoicedetail.ivd_distance,     
         invoicedetail.ivd_distunit,     
         invoicedetail.ivd_wgt,     
         invoicedetail.ivd_wgtunit,     
         invoicedetail.ivd_count,     
  invoicedetail.ivd_countunit,     
         invoicedetail.evt_number,     
         invoicedetail.ivd_reftype,     
         invoicedetail.ivd_volume,     
         invoicedetail.ivd_volunit,     
         invoicedetail.ivd_orig_cmpid,     
         invoicedetail.ivd_payrevenue,  
  invoiceheader.ivh_freight_miles,  
  invoiceheader.tar_tarriffnumber,  
  invoiceheader.tar_tariffitem,  
  1 copies,  
  chargetype.cht_basis,  
  chargetype.cht_description,  
  commodity.cmd_name,  
 @v_temp_altid cmp_altid,  
 ivh_hideshipperaddr,  
 ivh_hideconsignaddr,  
 (Case ivh_showshipper   
  when 'UNKNOWN' then invoiceheader.ivh_shipper  
  else IsNull(ivh_showshipper,invoiceheader.ivh_shipper)   
 end) ivh_showshipper,  
 (Case ivh_showcons   
  when 'UNKNOWN' then invoiceheader.ivh_consignee  
  else IsNull(ivh_showcons,invoiceheader.ivh_consignee)   
 end) ivh_showcons,  
 @v_temp_terms terms_name,  
 IsNull(ivh_charge,0) ivh_charge,  
        @v_temp_addr2    ivh_billto_addr3,  
    @v_varchar50 cmp_contact,  
 @v_varchar50 shipper_geoloc,  
 @v_varchar50 cons_geoloc  
    into #invtemp_tbl  
    FROM chargetype  RIGHT OUTER JOIN  invoicedetail  ON  chargetype.cht_itemcode  = invoicedetail.cht_itemcode   
			LEFT OUTER JOIN  commodity  ON  invoicedetail.cmd_code  = commodity.cmd_code ,
		invoiceheader   
   WHERE ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and  
		 invoiceheader.ivh_hdrnumber = @p_invoice_nbr  
--  ( invoiceheader.ivh_hdrnumber between @invoice_no_lo and @invoice_no_hi) AND  
--     ( @invoice_status  in ('ALL', invoiceheader.ivh_invoicestatus)) and  
--  ( @revtype1 in('UNK', invoiceheader.ivh_revtype1)) and  
--  ( @revtype2 in('UNK', invoiceheader.ivh_revtype2)) and       
--         ( @revtype3 in('UNK', invoiceheader.ivh_revtype3)) and    
--         ( @revtype4 in('UNK', invoiceheader.ivh_revtype4)) and  
--  ( @billto in ('UNKNOWN',invoiceheader.ivh_billto)) and  
--  ( @shipper in ('UNKNOWN', invoiceheader.ivh_shipper)) and  
--  ( @consignee in ('UNKNOWN',invoiceheader.ivh_consignee)) and  
--  (invoiceheader.ivh_shipdate between @shipdate1 and @shipdate2 ) and  
--         (invoiceheader.ivh_deliverydate between @deldate1 and @deldate2) and  
--  ((invoiceheader.ivh_billdate between @billdate1 and @billdate2) or  
--  (invoiceheader.ivh_billdate IS null))  
   
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
if (select count(*) from #invtemp_tbl) = 0  
 begin  
 select @v_ret_value = 0    
 GOTO ERROR_END  
 end  
/* RETRIEVE COMPANY DATA */                         
--if @useasbillto = 'BLT'  
-- begin  
  /*  
 -- LOR PTS#4789(SR# 7160)   
 If ((select count(*)   
  from company c, #invtemp_tbl t  
  where c.cmp_id = t.ivh_billto and  
   c.cmp_mailto_name = '') > 0 or  
      (select count(*)   
  from company c, #invtemp_tbl t  
  where c.cmp_id = t.ivh_billto and  
   c.cmp_mailto_name is null) > 0 or  
      (select count(*)  
  from #invtemp_tbl t, chargetype ch, company c  
  where c.cmp_id = t.ivh_billto and  
   ch.cht_itemcode = t.cht_itemcode and  
   ch.cht_primary = 'Y' and ch.cht_basis='SHP') = 0 or  
      (select count(*)   
  from company c, chargetype ch, #invtemp_tbl t  
  where c.cmp_id = t.ivh_billto and  
   c.cmp_mailto_name is not null and  
   c.cmp_mailto_name not in ('') and  
   ch.cht_itemcode = t.cht_itemcode and  
   ch.cht_primary = 'Y' and  
   ch.cht_basis='SHP' and  
   t.ivh_terms not in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3)) > 0)  
  */  
  
  If Not Exists (Select cmp_mailto_name From company c, #invtemp_tbl t  
        Where c.cmp_id = t.ivh_billto  
   And Rtrim(IsNull(cmp_mailto_name,'')) > ''  
   And t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3,   
    Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)  
   And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End )   
  
  update #invtemp_tbl  
  set ivh_billto_name = company.cmp_name,  
   ivh_billto_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),  
   #invtemp_tbl.cmp_altid = company.cmp_altid,  
    ivh_billto_addr = company.cmp_address1,  
    ivh_billto_addr2 = company.cmp_address2,  
                         ivh_billto_addr3 = company.cmp_address3,  
   cmp_contact = company.cmp_contact  
  from #invtemp_tbl, company  
  where company.cmp_id = #invtemp_tbl.ivh_billto  
 Else   
  update #invtemp_tbl  
  set ivh_billto_name = company.cmp_mailto_name,  
    ivh_billto_addr =  company.cmp_mailto_address1 ,  
    ivh_billto_addr2 = company.cmp_mailto_address2,     
   ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + IsNull(company.cmp_mailto_zip,''),  
   #invtemp_tbl.cmp_altid = company.cmp_altid ,  
   cmp_contact = company.cmp_contact  
  from #invtemp_tbl, company  
  where company.cmp_id = #invtemp_tbl.ivh_billto  
 --end  
/*     
if @useasbillto = 'ORD'  
 begin  
 update #invtemp_tbl  
  set ivh_billto_name = company.cmp_name,  
    ivh_billto_addr = company.cmp_address1,  
    ivh_billto_addr2 = company.cmp_address2,    
    ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip ,  
   #invtemp_tbl.cmp_altid = company.cmp_altid   
  from #invtemp_tbl, company, invoiceheader  
  where #invtemp_tbl.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and 
    company.cmp_id = invoiceheader.ivh_order_by  
 end     
if @useasbillto = 'SHP'  
 begin  
 update #invtemp_tbl  
  
  set ivh_billto_name = company.cmp_name,  
    ivh_billto_addr = company.cmp_address1,  
    ivh_billto_addr2 = company.cmp_address2,    
    ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip ,  
   #invtemp_tbl.cmp_altid = company.cmp_altid   
  from #invtemp_tbl, company  
  where company.cmp_id = #invtemp_tbl.ivh_shipper  
 end     
*/     
update #invtemp_tbl  
set originpoint_name = company.cmp_name,  
 origin_addr = company.cmp_address1,  
 origin_addr2 = company.cmp_address2,  
 origin_nmctst = substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip ,'')  
from #invtemp_tbl, company, city  
where company.cmp_id = #invtemp_tbl.ivh_originpoint  
 and city.cty_code = #invtemp_tbl.ivh_origincity     
      
update #invtemp_tbl  
set destpoint_name = company.cmp_name,  
 dest_addr = company.cmp_address1,  
 dest_addr2 = company.cmp_address2,  
 dest_nmctst =substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'')   
from #invtemp_tbl, company, city  
where company.cmp_id = #invtemp_tbl.ivh_destpoint  
 and city.cty_code =  #invtemp_tbl.ivh_destcity   
  
update #invtemp_tbl  
set shipper_name = company.cmp_name,  
 shipper_addr = Case ivh_hideshipperaddr when 'Y'   
    then ''  
    else company.cmp_address1  
   end,  
 shipper_addr2 = Case ivh_hideshipperaddr when 'Y'   
    then ''  
    else company.cmp_address2  
   end,  
 shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),  
 Shipper_geoloc = IsNull(cmp_geoloc,'')  
from #invtemp_tbl, company  
--where company.cmp_id = #invtemp_tbl.ivh_shipper   
where company.cmp_id = #invtemp_tbl.ivh_showshipper  
  
-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct    
update #invtemp_tbl  
set shipper_nmctst = origin_nmctst  
from #invtemp_tbl  
-- PTS 28466 -- BL (start)  
-- ONLY show stop city/state if the show shipper city/state has no value
--where #invtemp_tbl.ivh_shipper = 'UNKNOWN'  
where rtrim(isnull(#invtemp_tbl.shipper_nmctst, ''))  = ''  
-- PTS 28466 -- BL (end)  
      
update #invtemp_tbl  
set consignee_name = company.cmp_name,  
 consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +IsNull(company.cmp_zip, ''), 
 consignee_addr = Case ivh_hideconsignaddr when 'Y'   
    then ''  
    else company.cmp_address1  
   end,      
 consignee_addr2 = Case ivh_hideconsignaddr when 'Y'   
    then ''  
    else company.cmp_address2  
   end,  
 cons_geoloc = IsNull(cmp_geoloc,'')  
from #invtemp_tbl, company  
--where company.cmp_id = #invtemp_tbl.ivh_consignee   
where company.cmp_id = #invtemp_tbl.ivh_showcons     
   
-- There is no consignee city, so if the consignee is UNKNOWN, use the dest city to get the nmstct    
update #invtemp_tbl  
set consignee_nmctst = dest_nmctst  
from #invtemp_tbl  
-- PTS 28466 -- BL (start)  
-- ONLY show stop city/state if the show consignee city/state has no value
--where #invtemp_tbl.ivh_consignee = 'UNKNOWN'   
where rtrim(isnull(#invtemp_tbl.consignee_nmctst, ''))  = ''  
-- PTS 28466 -- BL (end)  
    
update #invtemp_tbl  
set stop_name = company.cmp_name,  
 stop_addr = company.cmp_address1,  
 stop_addr2 = company.cmp_address2  
from #invtemp_tbl, company  
where company.cmp_id = #invtemp_tbl.cmp_id  
  
-- dpete for UNKNOWN companies with cities must get city name from city table pts5319   
update #invtemp_tbl  
set  stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +IsNull(city.cty_zip,'')   
from  #invtemp_tbl, city  RIGHT OUTER JOIN  stops  ON  city.cty_code  = stops.stp_city --pts40188 outer join conversion 
where  #invtemp_tbl.stp_number IS NOT NULL  
 and stops.stp_number =  #invtemp_tbl.stp_number  
  
update #invtemp_tbl  
set terms_name = la.name  
from labelfile la  
where la.labeldefinition = 'creditterms' and  
     la.abbr = #invtemp_tbl.ivh_terms  
      
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
select @v_counter = 1  
while @v_counter <>  @p_copies  
 begin  
 select @v_counter = @v_counter + 1  
  insert into #invtemp_tbl  
  SELECT   
     ivh_invoicenumber,     
         ivh_hdrnumber,   
  ivh_billto,   
  ivh_billto_name ,  
  ivh_billto_addr,  
  ivh_billto_addr2,          
  ivh_billto_nmctst,  
         ivh_terms,      
         ivh_totalcharge,     
  ivh_shipper,     
  shipper_name,  
  shipper_addr,  
  shipper_addr2,  
  shipper_nmctst,  
         ivh_consignee,     
  consignee_name,  
  consignee_addr,  
  consignee_addr2,  
  consignee_nmctst,  
         ivh_originpoint,     
  originpoint_name,  
  origin_addr,  
  origin_addr2,  
  origin_nmctst,  
         ivh_destpoint,     
  destpoint_name,  
  dest_addr,  
  dest_addr2,  
  dest_nmctst,  
         ivh_invoicestatus,     
         ivh_origincity,     
         ivh_destcity,     
         ivh_originstate,     
         ivh_deststate,     
         ivh_originregion1,     
         ivh_destregion1,     
         ivh_supplier,     
         ivh_shipdate,     
         ivh_deliverydate,     
         ivh_revtype1,     
         ivh_revtype2,     
         ivh_revtype3,     
         ivh_revtype4,     
         ivh_totalweight,     
         ivh_totalpieces,     
         ivh_totalmiles,     
         ivh_currency,     
         ivh_currencydate,     
         ivh_totalvolume,   
         ivh_taxamount1,     
         ivh_taxamount2,     
         ivh_taxamount3,     
         ivh_taxamount4,     
         ivh_transtype,     
         ivh_creditmemo,     
         ivh_applyto,     
         ivh_printdate,     
         ivh_billdate,     
         ivh_lastprintdate,     
         ivh_originregion2,     
         ivh_originregion3,     
         ivh_originregion4,     
         ivh_destregion2,     
         ivh_destregion3,     
         ivh_destregion4,     
         mfh_hdrnumber,     
         ivh_remark,     
         ivh_driver,     
         ivh_tractor,     
         ivh_trailer,     
         ivh_user_id1,     
         ivh_user_id2,     
         ivh_ref_number,     
         ivh_driver2,     
         mov_number,     
         ivh_edi_flag,     
         ord_hdrnumber,     
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
         ivd_type,     
         ivd_rateunit,     
         ivd_billto,    
  ivd_billto_name,  
  ivd_billto_addr,  
  ivd_billto_addr2,  
  ivd_billto_nmctst,  
         ivd_itemquantity,     
         ivd_subtotalptr,     
         ivd_allocatedrev,     
         ivd_sequence,     
         ivd_refnum,     
         cmd_code,   
         cmp_id,     
  stop_name,  
  stop_addr,  
  stop_addr2,  
  stop_nmctst,  
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
  ivh_freight_miles,  
  tar_tarriffnumber,  
  tar_tariffitem,  
  @v_counter,  
  cht_basis,  
  cht_description,  
  cmd_name,  
  cmp_altid,  
 ivh_hideshipperaddr,  
 ivh_hideconsignaddr,  
 ivh_showshipper,  
 ivh_showcons,  
 terms_name,  
 IsNull(ivh_charge,0) ivh_charge,  
        ivh_billto_addr3,  
 cmp_contact,  
 shipper_geoloc,  
 cons_geoloc  
 from #invtemp_tbl  
 where copies = 1     
 end   
                                                                
ERROR_END:  
/* FINAL SELECT - FORMS RETURN SET */  
--select *  
--from #invtemp_tbl  
  SELECT   
     ivh_invoicenumber,     
         ivh_hdrnumber,   
  ivh_billto,   
  ivh_billto_name ,  
  ivh_billto_addr,  
  ivh_billto_addr2,           
  ivh_billto_nmctst,  
         ivh_terms,      
         ivh_totalcharge,     
  ivh_shipper,     
  shipper_name,  
  shipper_addr,  
  shipper_addr2,  
  shipper_nmctst,  
         ivh_consignee,     
  consignee_name,  
  consignee_addr,  
  consignee_addr2,  
  consignee_nmctst,  
         ivh_originpoint,     
  originpoint_name,  
  origin_addr,  
  origin_addr2,  
  origin_nmctst,  
         ivh_destpoint,     
  destpoint_name,  
  dest_addr,  
  dest_addr2,  
  dest_nmctst,  
         ivh_invoicestatus,     
         ivh_origincity,     
         ivh_destcity,     
         ivh_originstate,     
         ivh_deststate,     
         ivh_originregion1,     
         ivh_destregion1,     
         ivh_supplier,     
         ivh_shipdate,     
         ivh_deliverydate,     
         ivh_revtype1,     
         ivh_revtype2,     
         ivh_revtype3,     
         ivh_revtype4,     
         ivh_totalweight,     
         ivh_totalpieces,     
         ivh_totalmiles,     
         ivh_currency,     
         ivh_currencydate,     
         ivh_totalvolume,   
         ivh_taxamount1,     
         ivh_taxamount2,     
         ivh_taxamount3,     
         ivh_taxamount4,     
         ivh_transtype,     
         ivh_creditmemo,     
         ivh_applyto,     
         ivh_printdate,     
         ivh_billdate,     
         ivh_lastprintdate,     
         ivh_originregion2,     
         ivh_originregion3,     
         ivh_originregion4,     
         ivh_destregion2,     
         ivh_destregion3,     
         ivh_destregion4,     
         mfh_hdrnumber,     
         ivh_remark,     
         ivh_driver,     
         ivh_tractor,     
         ivh_trailer,     
         ivh_user_id1,     
         ivh_user_id2,     
         ivh_ref_number,     
         ivh_driver2,     
         mov_number,     
         ivh_edi_flag,     
         ord_hdrnumber,     
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
         ivd_type,     
         ivd_rateunit,     
         ivd_billto,    
  ivd_billto_name,  
  ivd_billto_addr,  
  ivd_billto_addr2,  
  ivd_billto_nmctst,  
         ivd_itemquantity,     
         ivd_subtotalptr,     
         ivd_allocatedrev,     
         ivd_sequence,     
         ivd_refnum,     
         cmd_code,   
         cmp_id,     
  stop_name,  
  stop_addr,  
  stop_addr2,  
  stop_nmctst,  
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
  ivh_freight_miles,  
  tar_tarriffnumber,  
  tar_tariffitem,  
  --vmj1+ @counter is constant for all rows!  
  copies,  
--  @counter,  
  --vmj1-  
  cht_basis,  
  cht_description,  
  cmd_name,  
  cmp_altid,  
  ivh_showshipper,  
  ivh_showcons,  
  terms_name,  
         ivh_billto_addr3,  
 cmp_contact,  
 shipper_geoloc,  
 cons_geoloc  
 from #invtemp_tbl  

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @v_ret_value = @@ERROR   
return @v_ret_value
GO
GRANT EXECUTE ON  [dbo].[invoice_template81] TO [public]
GO
