SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[invoice_template80_sp](@p_invoice_nbr   int,@p_copies  int)  
as

/**
 * 
 * NAME:
 * dbo.invoice_template80_sp
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
 * 
 *
 * REVISION HISTORY:
 * 03/01/2005.01 – PTSnnnnn - AuthorName – Revision Description
 * 02/02/1999 add cmp_altid from useasbillto company to return set  
 * 01/05/2000 PTS6469 dpete if you have an UNKNOWN consignee or shipper (origin or dest) use the city name in the city table  
 * 06/29/2001 PTS 10870 Vern Jewett  vmj1 : not returning copy # correctly.  
 * 04/22/2002 Jyang add terms_name to return set  
 * 12/05/2003 16314 DPETE use company settings to control terms and linehaul restricitons on mail to  
 * 03/26/2003 16739 DPETE Add cmp_contact for billto company, shipper_geoloc, cons geoloc  to return set for format 41  
 **/  
  
declare 
 @p_temp_name   varchar(100) ,  
 @p_temp_addr   varchar(100) ,  
 @p_temp_addr2  varchar(100),  
 @p_temp_nmstct varchar(30),  
 @p_temp_altid  varchar(25),  
 @p_counter    int,  
 @p_ret_value  int,  
 @p_temp_terms    varchar(20),  
 @p_varchar50 varchar(50)  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @p_ret_value = 1  

CREATE TABLE #invtemp_tbl
(ivh_invoicenumber varchar(12) not null ,     
 ivh_hdrnumber int null,   
 ivh_billto varchar(8) null,   
 ivh_billto_name varchar(100) null,  
 ivh_billto_addr varchar(100) null,  
 ivh_billto_addr2 varchar(100)null,           
 ivh_billto_nmctst varchar(30)null,  
 ivh_terms char(3) null,      
 ivh_totalcharge money null,     
 ivh_shipper varchar(8) null,     
 shipper_name varchar(100) null ,  
 shipper_addr varchar(100) null,  
 shipper_addr2 varchar(100) null,  
 shipper_nmctst varchar(30) null,  
 ivh_consignee varchar(8) null,     
 consignee_name varchar(100) null,  
 consignee_addr varchar(100) null,  
 consignee_addr2 varchar(100) null ,  
 consignee_nmctst varchar(30) null,  
 ivh_originpoint varchar(8)null,     
 originpoint_name varchar(100) null,  
 origin_addr varchar(100) null,  
 origin_addr2 varchar(100) null,  
 origin_nmctst varchar(30) null,  
 ivh_destpoint varchar(8) null,     
 destpoint_name varchar(100) null,  
 dest_addr varchar(100) null,  
 dest_addr2 varchar(100) null,  
 dest_nmctst varchar(30) null,
 ivh_invoicestatus varchar(6) null,     
 ivh_origincity int null,     
 ivh_destcity int null,     
 ivh_originstate char(2) null,     
 ivh_deststate char(2) null,  
 ivh_originregion1 varchar(6) null,     
 ivh_destregion1 varchar(6) null,     
 ivh_supplier varchar(8)null,     
 ivh_shipdate datetime null,     
 ivh_deliverydate datetime null,     
 ivh_revtype1 varchar(6) null,     
 ivh_revtype2 varchar(6) null,     
 ivh_revtype3 varchar(6) null,     
 ivh_revtype4 varchar(6) null,
 ivh_totalweight float null,     
 ivh_totalpieces float null,     
 ivh_totalmiles float null,     
 ivh_currency varchar(6) null,     
 ivh_currencydate datetime null ,     
 ivh_totalvolume float null,     
 ivh_taxamount1 money null,     
 ivh_taxamount2 money null,     
 ivh_taxamount3 money null,     
 ivh_taxamount4 money null,     
 ivh_transtype varchar(6) null,     
 ivh_creditmemo char(1) null,     
 ivh_applyto varchar(12)null,     
 ivh_printdate datetime null,     
 ivh_billdate datetime null,     
 ivh_lastprintdate datetime null,     
 ivh_originregion2 varchar(6) null,     
 ivh_originregion3 varchar(6) null,     
 ivh_originregion4 varchar(6) null,     
 ivh_destregion2 varchar(6) null,     
 ivh_destregion3 varchar(6) null,     
 ivh_destregion4 varchar(6) null,     
 mfh_hdrnumber int null,     
 ivh_remark varchar(254) null,     
 ivh_driver varchar(8) null,     
 ivh_tractor varchar(8) null,     
 ivh_trailer varchar(13),     
 ivh_user_id1 char(20) null,     
 ivh_user_id2 char(20) null,     
 ivh_ref_number varchar(30) null,     
 ivh_driver2 varchar(8) null,     
 mov_number int null,     
 ivh_edi_flag char(30) null,     
 ord_hdrnumber int null,    
 ivd_number int null,     
 stp_number int null,     
 ivd_description varchar(254) null,     
 cht_itemcode varchar(6) null,     
 ivd_quantity float null,     
 ivd_rate money null,     
 ivd_charge money null,  
 ivd_taxable1 char(1) null, 
 ivd_taxable2 char(1) null, 
 ivd_taxable3 char(1) null, 
 ivd_taxable4 char(1) null, 
 ivd_unit char(6) null,     
 cur_code char(6) null,     
 ivd_currencydate datetime null,     
 ivd_glnum char(32) null,     
 ivd_type char(6) null,     
 ivd_rateunit char(6) null,     
 ivd_billto char(8) null,     
 ivd_billto_name varchar(100) null,  
 ivd_billto_addr varchar(100) null,  
 ivd_billto_addr2 varchar(100) null,  
 ivd_billto_nmctst varchar(30) null,  
 ivd_itemquantity float null,     
 ivd_subtotalptr int null,     
 ivd_allocatedrev money null,     
 ivd_sequence int null,     
 ivd_refnum varchar(30)null,     
 cmd_code varchar(8) null,     
 cmp_id varchar(8) null,     
 stop_name varchar(100) null,  
 stop_addr varchar(100) null,  
 stop_addr2 varchar(100) null,  
 stop_nmctst varchar(30) null,  
 ivd_distance float null,     
 ivd_distunit varchar(6) null,     
 ivd_wgt float null,     
 ivd_wgtunit varchar(6) null,     
 ivd_count decimal(10,2) null,     
 ivd_countunit char(6) null,     
 evt_number int null,     
 ivd_reftype varchar(6) null,     
 ivd_volume float null,     
 ivd_volunit char(6) null,     
 ivd_orig_cmpid char(8) null,     
 ivd_payrevenue money null,  
 ivh_freight_miles float null,  
 tar_tarriffnumber varchar(12) null,  
 tar_tariffitem varchar(12) null,  
 copies int null,  
 cht_basis varchar(6)null,  
 cht_description varchar(30) null,  
 cmd_name varchar(60),  
 cmp_altid varchar(25) null,  
 ivh_hideshipperaddr char(1) null,  
 ivh_hideconsignaddr char(1) null,  
 ivh_showshipper varchar(8) null,  
 ivh_showcons varchar(8) null,  
 terms_name varchar(20) null,  
 ivh_charge money null,  
 ivh_billto_addr3 varchar(100) null,  
 cmp_contact varchar(50) null,  
 shipper_geoloc varchar(50) null,  
 cons_geoloc varchar(50) null)
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/
 INSERT INTO #invtemp_tbl     
 SELECT  invoiceheader.ivh_invoicenumber,     
         invoiceheader.ivh_hdrnumber,   
  	 invoiceheader.ivh_billto,   
  	 @p_temp_name ivh_billto_name ,  
 	 @p_temp_addr  ivh_billto_addr,  
  	 @p_temp_addr2 ivh_billto_addr2,           
 	 @p_temp_nmstct ivh_billto_nmctst,  
         invoiceheader.ivh_terms,      
         invoiceheader.ivh_totalcharge,     
  	 invoiceheader.ivh_shipper,     
  	 @p_temp_name shipper_name,  
  	 @p_temp_addr shipper_addr,  
         @p_temp_addr2 shipper_addr2,  
	 @p_temp_nmstct shipper_nmctst,  
         invoiceheader.ivh_consignee,     
	 @p_temp_name consignee_name,  
	 @p_temp_addr consignee_addr,  
	 @p_temp_addr2 consignee_addr2,  
	 @p_temp_nmstct consignee_nmctst,  
         invoiceheader.ivh_originpoint,     
	 @p_temp_name originpoint_name,  
	 @p_temp_addr origin_addr,  
	 @p_temp_addr2 origin_addr2,  
	 @p_temp_nmstct origin_nmctst,  
         invoiceheader.ivh_destpoint,     
         @p_temp_name destpoint_name,  
	 @p_temp_addr dest_addr,  
	 @p_temp_addr2 dest_addr2,  
	 @p_temp_nmstct dest_nmctst,  
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
         ivd_taxable1 =IsNull(chargetype.cht_taxtable1,invoicedetail.ivd_taxable1),   -- taxable flags not set on ivd for gst,pst,etc    
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
	 @p_temp_name ivd_billto_name,  
	 @p_temp_addr ivd_billto_addr,  
	 @p_temp_addr2 ivd_billto_addr2,  
	 @p_temp_nmstct ivd_billto_nmctst,  
         invoicedetail.ivd_itemquantity,     
         invoicedetail.ivd_subtotalptr,     
         invoicedetail.ivd_allocatedrev,     
         invoicedetail.ivd_sequence,     
         invoicedetail.ivd_refnum,     
         invoicedetail.cmd_code,     
         invoicedetail.cmp_id,     
	 @p_temp_name stop_name,  
	 @p_temp_addr stop_addr,  
	 @p_temp_addr2 stop_addr2,  
	 @p_temp_nmstct stop_nmctst,  
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
         @p_temp_altid cmp_altid,  
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
         @p_temp_terms terms_name,  
         IsNull(ivh_charge,0) ivh_charge,  
         @p_temp_addr2    ivh_billto_addr3,  
         @p_varchar50 cmp_contact,  
         @p_varchar50 shipper_geoloc,  
         @p_varchar50 cons_geoloc 
     FROM invoicedetail JOIN invoiceheader ON ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) 
          RIGHT OUTER JOIN chargetype ON (chargetype.cht_itemcode = invoicedetail.cht_itemcode)
          LEFT OUTER JOIN commodity  ON (invoicedetail.cmd_code = commodity.cmd_code)
    WHERE invoiceheader.ivh_hdrnumber = @p_invoice_nbr    
     --FROM invoiceheader, invoicedetail, chargetype, commodity  
    --WHERE (invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and  
    --      (chargetype.cht_itemcode =* invoicedetail.cht_itemcode) and  
    --      (invoicedetail.cmd_code *= commodity.cmd_code) and  
    --      invoiceheader.ivh_hdrnumber = @p_invoice_nbr  
   
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
if (select count(*) from #invtemp_tbl) = 0  
 begin  
 select @p_ret_value = 0    
 GOTO ERROR_END  
 end  
  
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
    from #invtemp_tbl JOIN company ON ( company.cmp_id = #invtemp_tbl.ivh_billto  ) 
    --from #invtemp_tbl, company  
   --where company.cmp_id = #invtemp_tbl.ivh_billto  
 Else   
  update #invtemp_tbl  
     set ivh_billto_name = company.cmp_mailto_name,  
         ivh_billto_addr =  company.cmp_mailto_address1 ,  
         ivh_billto_addr2 = company.cmp_mailto_address2,     
         ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + IsNull(company.cmp_mailto_zip,''),  
         #invtemp_tbl.cmp_altid = company.cmp_altid ,  
         cmp_contact = company.cmp_contact 
    from #invtemp_tbl JOIN company ON ( company.cmp_id = #invtemp_tbl.ivh_billto  ) 
    --from #invtemp_tbl, company  
   --where company.cmp_id = #invtemp_tbl.ivh_billto  

  update #invtemp_tbl  
     set originpoint_name = company.cmp_name,  
         origin_addr = company.cmp_address1,  
         origin_addr2 = company.cmp_address2,  
         origin_nmctst = substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip ,'')  
    from #invtemp_tbl JOIN company ON ( company.cmp_id = #invtemp_tbl.ivh_originpoint ) 
         JOIN city ON (city.cty_code = #invtemp_tbl.ivh_origincity )
    --from #invtemp_tbl, company, city  
    --where company.cmp_id = #invtemp_tbl.ivh_originpoint  
    --     and city.cty_code = #invtemp_tbl.ivh_origincity     
      
  update #invtemp_tbl  
     set destpoint_name = company.cmp_name,  
         dest_addr = company.cmp_address1,  
         dest_addr2 = company.cmp_address2,  
         dest_nmctst =substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'')   
    from #invtemp_tbl JOIN company ON ( company.cmp_id = #invtemp_tbl.ivh_destpoint  ) 
         JOIN city ON (city.cty_code = #invtemp_tbl.ivh_destcity )
    --from #invtemp_tbl, company, city  
    --where company.cmp_id = #invtemp_tbl.ivh_destpoint  
    --      and city.cty_code =  #invtemp_tbl.ivh_destcity   
  
  update #invtemp_tbl  
     set shipper_name = company.cmp_name,  
         shipper_addr = Case ivh_hideshipperaddr when 'Y' then ''  
                        else company.cmp_address1  
                        end,  
         shipper_addr2 = Case ivh_hideshipperaddr when 'Y' then ''  
                        else company.cmp_address2  
                        end,  
        shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),  
        Shipper_geoloc = IsNull(cmp_geoloc,'')  
   from #invtemp_tbl JOIN company ON (company.cmp_id = #invtemp_tbl.ivh_showshipper  )  
   --from #invtemp_tbl, company  
   --where company.cmp_id = #invtemp_tbl.ivh_showshipper 
   --where company.cmp_id = #invtemp_tbl.ivh_shipper      
  
-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct    
 update #invtemp_tbl  
    set shipper_nmctst = origin_nmctst  
   from #invtemp_tbl  
  where #invtemp_tbl.ivh_shipper = 'UNKNOWN'  

      
 update #invtemp_tbl  
    set consignee_name = company.cmp_name,  
        consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +IsNull(company.cmp_zip, ''), 
        consignee_addr = Case ivh_hideconsignaddr when 'Y' then ''  
                         else company.cmp_address1  
                         end,      
        consignee_addr2 = Case ivh_hideconsignaddr when 'Y' then ''  
                          else company.cmp_address2  
                          end,  
            cons_geoloc = IsNull(cmp_geoloc,'') 
   from #invtemp_tbl JOIN company ON (company.cmp_id = #invtemp_tbl.ivh_showcons)   
   --from #invtemp_tbl, company  
   --where company.cmp_id = #invtemp_tbl.ivh_showcons
   --where company.cmp_id = #invtemp_tbl.ivh_consignee   
      
   
-- There is no consignee city, so if the consignee is UNKNOWN, use the dest city to get the nmstct    
 update #invtemp_tbl  
    set consignee_nmctst = dest_nmctst  
   from #invtemp_tbl  
  where #invtemp_tbl.ivh_consignee = 'UNKNOWN'   
    
 update #invtemp_tbl  
    set stop_name = company.cmp_name,  
        stop_addr = company.cmp_address1,  
        stop_addr2 = company.cmp_address2 
   from #invtemp_tbl JOIN company ON (company.cmp_id = #invtemp_tbl.cmp_id) 
   --from #invtemp_tbl, company  
  --where company.cmp_id = #invtemp_tbl.cmp_id  
  
-- dpete for UNKNOWN companies with cities must get city name from city table pts5319   
 update #invtemp_tbl  
    set stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +IsNull(city.cty_zip,'')   
   from  stops JOIN #invtemp_tbl ON (stops.stp_number = #invtemp_tbl.stp_number) 
         RIGHT OUTER JOIN city ON (city.cty_code = stops.stp_city )
   where #invtemp_tbl.stp_number IS NOT NULL 
  --from #invtemp_tbl, stops,city 
  --where #invtemp_tbl.stp_number IS NOT NULL  
  --      and stops.stp_number =  #invtemp_tbl.stp_number  
  --      and city.cty_code =* stops.stp_city  
  
 update #invtemp_tbl  
    set terms_name = la.name  
   from labelfile la JOIN #invtemp_tbl ON (la.abbr = #invtemp_tbl.ivh_terms) 
  where la.labeldefinition = 'creditterms' 
  --from labelfile la  
  --where la.labeldefinition = 'creditterms' and  
  --      la.abbr = #invtemp_tbl.ivh_terms  
      
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
SELECT @p_counter = 1  
WHILE @p_counter <>  @p_copies  
 BEGIN  
   SELECT @p_counter = @p_counter + 1  
   INSERT INTO #invtemp_tbl  
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
     @p_counter,  
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
         --@counter,  
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
IF @@ERROR != 0 select @p_ret_value = @@ERROR   
return @p_ret_value  
GO
GRANT EXECUTE ON  [dbo].[invoice_template80_sp] TO [public]
GO
