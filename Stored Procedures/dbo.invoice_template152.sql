SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[invoice_template152] (@invoice_nbr	INTEGER,
                                      @copies 		INTEGER)
AS  
DECLARE	@temp_name	VARCHAR(100),  
 	@temp_addr   	VARCHAR(100),  
 	@temp_addr2  	VARCHAR(100),  
 	@temp_nmstct 	VARCHAR(30),  
 	@temp_altid  	VARCHAR(25),  
	@counter    	INTEGER,  
 	@ret_value  	INTEGER,  
	@temp_terms    	VARCHAR(20),  
	@varchar50 	VARCHAR(50),
	@temp_zip	VARCHAR(10),
	@temp_desc	VARCHAR(75),
	@temp_remark	VARCHAR(254),
	@cmd_code	VARCHAR(8)
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
SET @ret_value = 1  
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  
  
SELECT 	invoiceheader.ivh_invoicenumber,     
       	invoiceheader.ivh_hdrnumber,   
       	invoiceheader.ivh_billto,   
       	@temp_name ivh_billto_name ,  
 	@temp_addr  ivh_billto_addr,  
  	@temp_addr2 ivh_billto_addr2,           
 	@temp_nmstct ivh_billto_nmctst,  
        invoiceheader.ivh_terms,      
        invoiceheader.ivh_totalcharge,     
  	invoiceheader.ivh_shipper,     
  	@temp_name shipper_name,  
  	@temp_addr shipper_addr,  
  	@temp_addr2 shipper_addr2,  
  	@temp_nmstct shipper_nmctst,  
        invoiceheader.ivh_consignee,     
  	@temp_name consignee_name,  
  	@temp_addr consignee_addr,  
  	@temp_addr2 consignee_addr2,  
  	@temp_nmstct consignee_nmctst,  
        invoiceheader.ivh_originpoint,     
  	@temp_name originpoint_name,  
  	@temp_addr origin_addr,  
  	@temp_addr2 origin_addr2,  
  	@temp_nmstct origin_nmctst,  
        invoiceheader.ivh_destpoint,     
  	@temp_name destpoint_name,  
  	@temp_addr dest_addr,  
  	@temp_addr2 dest_addr2,  
  	@temp_nmstct dest_nmctst,  
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
        ivd_taxable1 =  ISNULL(chargetype.cht_taxtable1,invoicedetail.ivd_taxable1),    
   	ivd_taxable2 = ISNULL(chargetype.cht_taxtable2,invoicedetail.ivd_taxable2),  
   	ivd_taxable3 = ISNULL(chargetype.cht_taxtable3,invoicedetail.ivd_taxable3),  
   	ivd_taxable4 = ISNULL(chargetype.cht_taxtable4,invoicedetail.ivd_taxable4),  
        invoicedetail.ivd_unit,     
        invoicedetail.cur_code,     
        invoicedetail.ivd_currencydate,     
        invoicedetail.ivd_glnum,     
        invoicedetail.ivd_type,     
        invoicedetail.ivd_rateunit,     
        invoicedetail.ivd_billto,     
 	@temp_name ivd_billto_name,  
  	@temp_addr ivd_billto_addr,  
  	@temp_addr2 ivd_billto_addr2,  
  	@temp_nmstct ivd_billto_nmctst,  
        invoicedetail.ivd_itemquantity,     
        invoicedetail.ivd_subtotalptr,     
        invoicedetail.ivd_allocatedrev,     
        invoicedetail.ivd_sequence,     
        invoicedetail.ivd_refnum,     
        invoicedetail.cmd_code,     
        invoicedetail.cmp_id,     
  	@temp_name stop_name,  
  	@temp_addr stop_addr,  
  	@temp_addr2 stop_addr2,  
 	@temp_nmstct stop_nmctst,  
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
 	@temp_altid cmp_altid,  
 	ivh_hideshipperaddr,  
 	ivh_hideconsignaddr,  
 	CASE ivh_showshipper   
  	   WHEN 'UNKNOWN' THEN invoiceheader.ivh_shipper  
  	   ELSE IsNull(ivh_showshipper,invoiceheader.ivh_shipper)   
 	END ivh_showshipper,  
 	CASE ivh_showcons   
  	   WHEN 'UNKNOWN' then invoiceheader.ivh_consignee  
  	   ELSE IsNull(ivh_showcons,invoiceheader.ivh_consignee)   
 	END ivh_showcons,  
 	@temp_terms terms_name,  
 	IsNull(ivh_charge,0) ivh_charge,  
        @temp_addr2    ivh_billto_addr3,  
    	@varchar50 cmp_contact,  
 	@varchar50 shipper_geoloc,  
 	@varchar50 cons_geoloc,
        invoicedetail.cht_rollintolh,
        chargetype.cht_primary,
	@temp_addr2	shipper_addr3,
	@temp_addr2	consignee_addr3,
	@temp_zip	ivh_billto_zip,
	@temp_zip	shipper_zip,
	@temp_zip	consignee_zip,
	@temp_desc	ord_description,
	ISNULL(invoiceheader.ivh_remark, ' ') ord_remark,
        invoiceheader.ivh_definition
  INTO  #invtemp_tbl
  FROM  invoiceheader JOIN invoicedetail ON invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber AND
                                            invoicedetail.cht_itemcode <> 'DEL'
                      JOIN chargetype ON invoicedetail.cht_itemcode = chargetype.cht_itemcode
                      LEFT OUTER JOIN commodity ON invoicedetail.cmd_code = commodity.cmd_code
 WHERE  invoiceheader.ivh_hdrnumber = @invoice_nbr  
   
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
IF (SELECT COUNT(*)
      FROM #invtemp_tbl) = 0
BEGIN
   SET @ret_value = 0
   GOTO ERROR_END
END  
 
/* RETRIEVE COMPANY DATA */
IF NOT EXISTS (SELECT cmp_mailto_name
                 FROM company c, #invtemp_tbl t
                WHERE c.cmp_id = t.ivh_billto AND
                      RTRIM(ISNULL(cmp_mailto_name, '')) > '' AND
                      t.ivh_terms IN (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, 
                                      c.cmp_mailto_crterm3,CASE ISNULL(cmp_mailtotermsmatchflag, 'N')
                                                              WHEN 'Y' THEN '^^'
                                                              ELSE t.ivh_terms
                                                           END) AND
                      t.ivh_charge <> CASE ISNULL(cmp_MailtToForLinehaulFlag, 'Y')
                                         WHEN 'Y' THEN 0.00
                                         ELSE ivh_charge + 1.00
                                      END)
   UPDATE #invtemp_tbl
      SET ivh_billto_name = company.cmp_name,  
          ivh_billto_nmctst = substring(company.cty_nmstct,1, (CHARINDEX('/', company.cty_nmstct)))+ ' ' + ISNULL(company.cmp_zip,''),  
          #invtemp_tbl.cmp_altid = company.cmp_altid,  
          ivh_billto_addr = company.cmp_address1,  
          ivh_billto_addr2 = company.cmp_address2,  
          ivh_billto_addr3 = company.cmp_address3,  
          cmp_contact = company.cmp_contact,
          ivh_billto_zip = ISNULL(company.cmp_zip, ' ')
     FROM #invtemp_tbl, company  
    WHERE company.cmp_id = #invtemp_tbl.ivh_billto
ELSE                        
   UPDATE #invtemp_tbl
      SET ivh_billto_name = company.cmp_mailto_name,  
          ivh_billto_addr =  company.cmp_mailto_address1 ,  
          ivh_billto_addr2 = company.cmp_mailto_address2,     
          ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (CHARINDEX('/', company.mailto_cty_nmstct)))+ ' ' + ISNULL(company.cmp_mailto_zip,''),  
          #invtemp_tbl.cmp_altid = company.cmp_altid, 
          cmp_contact = company.cmp_contact,
          ivh_billto_zip = ISNULL(company.cmp_mailto_zip, ' ') --PTS 53410 SGB  
     FROM #invtemp_tbl, company  
    WHERE company.cmp_id = #invtemp_tbl.ivh_billto 
  
UPDATE #invtemp_tbl  
   SET originpoint_name = company.cmp_name,  
       origin_addr = company.cmp_address1,  
       origin_addr2 = company.cmp_address2,  
       origin_nmctst = substring(city.cty_nmstct,1, (CHARINDEX('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip ,'')  
  FROM #invtemp_tbl, company, city  
 WHERE company.cmp_id = #invtemp_tbl.ivh_originpoint AND
       city.cty_code = #invtemp_tbl.ivh_origincity    
      
UPDATE #invtemp_tbl  
   SET destpoint_name = company.cmp_name,  
       dest_addr = company.cmp_address1,  
       dest_addr2 = company.cmp_address2,  
       dest_nmctst =substring(city.cty_nmstct,1, (CHARINDEX('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'')   
  FROM #invtemp_tbl, company, city  
 WHERE company.cmp_id = #invtemp_tbl.ivh_destpoint AND
       city.cty_code =  #invtemp_tbl.ivh_destcity   
  
UPDATE #invtemp_tbl  
   SET shipper_name = company.cmp_name,  
       shipper_addr = CASE ivh_hideshipperaddr 
                         WHEN 'Y' THEN ''  
                         ELSE company.cmp_address1  
                      END,  
       shipper_addr2 = CASE ivh_hideshipperaddr 
                          WHEN 'Y' THEN ''  
                          ELSE company.cmp_address2  
                       END,  
       shipper_nmctst = substring(company.cty_nmstct,1, (CHARINDEX('/', company.cty_nmstct)))+ ' ' + ISNULL(company.cmp_zip,''),  
       Shipper_geoloc = IsNull(cmp_geoloc,''),
       shipper_addr3 = company.cmp_address3,
       shipper_zip = ISNULL(company.cmp_zip, ' ')
  FROM #invtemp_tbl, company  
 WHERE company.cmp_id = #invtemp_tbl.ivh_showshipper  
  
UPDATE #invtemp_tbl  
   SET shipper_nmctst = origin_nmctst  
  FROM #invtemp_tbl  
 WHERE RTRIM(ISNULL(#invtemp_tbl.shipper_nmctst, ''))  = ''  
      
UPDATE #invtemp_tbl  
   SET consignee_name = company.cmp_name,  
       consignee_nmctst = substring(company.cty_nmstct,1, (CHARINDEX('/', company.cty_nmstct)))+ ' ' +ISNULL(company.cmp_zip, ''), 
       consignee_addr = CASE ivh_hideconsignaddr 
                           WHEN 'Y' THEN ''  
                           ELSE company.cmp_address1  
                        END,      
       consignee_addr2 = CASE ivh_hideconsignaddr 
                            WHEN 'Y' THEN ''  
                            ELSE company.cmp_address2  
                         END,  
       cons_geoloc = IsNull(cmp_geoloc,''),
       consignee_addr3 = company.cmp_address3,
       consignee_zip = ISNULL(company.cmp_zip, ' ')
  FROM #invtemp_tbl, company  
 WHERE company.cmp_id = #invtemp_tbl.ivh_showcons     
   
UPDATE #invtemp_tbl  
   SET consignee_nmctst = dest_nmctst  
  FROM #invtemp_tbl  
 WHERE RTRIM(ISNULL(#invtemp_tbl.consignee_nmctst, ''))  = ''  
    
UPDATE #invtemp_tbl  
   SET stop_name = company.cmp_name,  
       stop_addr = company.cmp_address1,  
       stop_addr2 = company.cmp_address2  
  FROM #invtemp_tbl, company  
 WHERE company.cmp_id = #invtemp_tbl.cmp_id  
  
UPDATE #invtemp_tbl  
   SET stop_nmctst = SUBSTRING(city.cty_nmstct,1, (CHARINDEX('/', city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'')   
  FROM #invtemp_tbl, city  RIGHT OUTER JOIN  stops  ON  city.cty_code  = stops.stp_city
 WHERE #invtemp_tbl.stp_number IS NOT NULL AND 
       stops.stp_number = #invtemp_tbl.stp_number  
  
UPDATE #invtemp_tbl  
   SET terms_name = la.name  
  FROM labelfile la  
 WHERE la.labeldefinition = 'creditterms' AND  
       la.abbr = #invtemp_tbl.ivh_terms

UPDATE #invtemp_tbl
   SET ord_description = ISNULL(orderheader.ord_description, ' ')
  FROM orderheader
 WHERE orderheader.ord_hdrnumber = #invtemp_tbl.ord_hdrnumber AND
       #invtemp_tbl.ivh_definition <> 'MISC' AND
       #invtemp_tbl.ivh_definition <> 'SUPL'

UPDATE #invtemp_tbl
   SET ord_description = #invtemp_tbl.ivd_description
 WHERE (#invtemp_tbl.ivh_definition = 'SUPL' OR 
        #invtemp_tbl.ivh_definition = 'MISC') AND
       #invtemp_tbl.ivd_description IS NOT NULL AND
       #invtemp_tbl.ivd_description <> 'UNKNOWN'

UPDATE #invtemp_tbl
   SET ord_description = #invtemp_tbl.cht_description
 WHERE (#invtemp_tbl.ivh_definition = 'SUPL' OR 
        #invtemp_tbl.ivh_definition = 'MISC') AND
       (#invtemp_tbl.ivd_description IS NULL OR 
        #invtemp_tbl.ivd_description = 'UNKNOWN')

SELECT @cmd_code = ISNULL(cmd_code, 'UNKNOWN')
  FROM invoicedetail
 WHERE ivh_hdrnumber = @invoice_nbr AND
       ivd_type = 'DRP' AND
       cht_itemcode = 'DEL' AND
       ivd_sequence = (SELECT MAX(ivd_sequence)
                         FROM invoicedetail
                        WHERE ivh_hdrnumber = @invoice_nbr AND
                              ivd_type = 'DRP' AND
                              cht_itemcode = 'DEL')
UPDATE #invtemp_tbl
   SET cmd_code = @cmd_code
 WHERE ivd_type = 'SUB'

UPDATE #invtemp_tbl
   SET cht_rollintolh = 1
 WHERE ivd_type <> 'SUB' and 
       ivh_definition <> 'MISC' AND
       ivh_definition <> 'SUPL'
      
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
SELECT @counter = 1  
WHILE @counter <>  @copies  
BEGIN  
   SELECT @counter = @counter + 1  
   INSERT INTO #invtemp_tbl  
      SELECT ivh_invoicenumber,     
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
             @counter,  
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
             cons_geoloc,
             cht_rollintolh,
             cht_primary,
             shipper_addr3,
	     consignee_addr3,
	     ivh_billto_zip,
	     shipper_zip,
	     consignee_zip,
             ord_description,
             ord_remark,
             ivh_definition
        FROM #invtemp_tbl  
       WHERE copies = 1     
END
                                                                
ERROR_END:  
/* FINAL SELECT - FORMS RETURN SET */  

SELECT ivh_invoicenumber,     
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
       copies,  
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
       cons_geoloc,
       cht_rollintolh,
       cht_primary,
       shipper_addr3,
       consignee_addr3,
       ivh_billto_zip,
       shipper_zip,
       consignee_zip,
       ord_description,
       ord_remark
  FROM #invtemp_tbl

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @ret_value = @@ERROR   
return @ret_value  

GO
GRANT EXECUTE ON  [dbo].[invoice_template152] TO [public]
GO
