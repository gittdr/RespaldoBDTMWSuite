SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[invoice_template98](@p_invoice_nbr int,@p_copies  int)  
as  

/*
 * 
 * NAME:invoice_template98
 * dbo.
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return SET of all the invoices details
 * based on the invoice SELECTed.
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
 * 001 - @p_invoice_nbr, int, input, NULL;
 *       Invoice number
 * 002 - @p_copies, int, input, NULL;
 *       number of copies to print
 * REFERENCES: (called by AND calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 - PTSnnnnn - AuthorName -Revision Description 
 * 2/2/99                               -add cmp_altid FROM useasbillto company to return SET  
 * 1/5/00       - PTS6469 - dpete       -IF you have an UNKNOWN consignee or shipper (origin or dest) use the city name in the city table  
 * 06/29/2001   - PTS 10870 - Vern Jewett -NOT returning copy # correctly.  
 * 04/22/2002   -           - Jyang       -add terms_name to return SET  
 * 12/5/2       - PTS16314  - DPETE       -use company SETtings to control terms AND linehaul restricitons on mail to  
 * 3/26/03      - 16739     - DPETE       -Add cmp_contact for billto company, shipper_geoloc, cons geoloc  to return SET for format 41  
 * 04/10/2006 - PTS 24796 & 24915 - Imari Bremer - Create new invoice formats for Arrow Trucking
 **/

  
DECLARE 
	@v_temp_name   	VARCHAR(100) ,  
	@v_temp_addr   	VARCHAR(100) ,  
	@v_temp_addr2  	VARCHAR(100),  
	@v_temp_nmstct 	VARCHAR(30),
	@v_temp_zip	VARCHAR(10),
	@v_temp_country	VARCHAR(50),  
	@v_temp_altid  	VARCHAR(25),  
	@v_counter    INT,  
	@v_ret_value  INT,  
	@v_temp_terms   VARCHAR(20),  
	@v_varchar50 	VARCHAR(50),
	@v_tarIFfkey_startdate	DATETIME,--24796
	@v_ord_hdrnumber	INT, -- 27614 JD
	@v_MINShipperCountry 	VARCHAR (50),
	@v_MINConsCountry 	VARCHAR(50),
	@v_MINBilltoCountry 	VARCHAR(50),
	@v_varchar10 	VARCHAR(10),
	@li_pos		INT,
	@ls_cty		VARCHAR(100),
	
	-- 26-JUL-2006 SWJ - PTS 33592
	@v_varchar255	VARCHAR(255),
	@ls_consignee_full VARCHAR(255)

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
SELECT @v_ret_value = 1  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
SELECT @v_ret_value = 1  
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  
  
 SELECT  DISTINCT invoiceheader.ivh_invoicenumber,     
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
		ivd_description = IsNULL(invoicedetail.ivd_description, chargetype.cht_description), 
		invoicedetail.cht_itemcode,     
		invoicedetail.ivd_quantity,     
		invoicedetail.ivd_rate,     
		invoicedetail.ivd_charge,  
		ivd_taxable1 =  IsNULL(chargetype.cht_taxtable1,invoicedetail.ivd_taxable1),   -- taxable flags NOT SET on ivd for gst,pst,etc    
		ivd_taxable2 =IsNULL(chargetype.cht_taxtable2,invoicedetail.ivd_taxable2),  
		ivd_taxable3 =IsNULL(chargetype.cht_taxtable3,invoicedetail.ivd_taxable3),  
		ivd_taxable4 =IsNULL(chargetype.cht_taxtable4,invoicedetail.ivd_taxable4),  
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
		IsNULL(invoicedetail.ivd_wgt,0)ivd_wgt,     
		invoicedetail.ivd_wgtunit,     
		IsNULL(invoicedetail.ivd_count,0)ivd_count,     
		invoicedetail.ivd_countunit,     
		invoicedetail.evt_number,     
		invoicedetail.ivd_reftype,     
		invoicedetail.ivd_volume,     
		invoicedetail.ivd_volunit,     
		invoicedetail.ivd_orig_cmpid,     
		invoicedetail.ivd_payrevenue,  
		invoiceheader.ivh_freight_miles,  
		invoiceheader.tar_tarrIFfnumber,  
		invoiceheader.tar_tarIFfitem,  
		1 copies,  
		chargetype.cht_basis,  
		chargetype.cht_description,  
		commodity.cmd_name,  
		@v_temp_altid cmp_altid,  
		ivh_hideshipperaddr,  
		ivh_hideconsignaddr,  
		(CASE ivh_showshipper   
			WHEN 'UNKNOWN' THEN invoiceheader.ivh_shipper  
			ELSE IsNULL(ivh_showshipper,invoiceheader.ivh_shipper)  END) ivh_showshipper,  
		(CASE ivh_showcons   
			WHEN 'UNKNOWN' THEN invoiceheader.ivh_consignee  
			ELSE IsNULL(ivh_showcons,invoiceheader.ivh_consignee) END) ivh_showcons,  
		@v_temp_terms terms_name,  
		IsNULL(ivh_charge,0) ivh_charge,  
		@v_temp_addr2    ivh_billto_addr3,
		invoiceheader.tar_number,
		@v_tarIFfkey_startdate tarIFfkey_startdate,
		@v_temp_addr2 shipper_addr3,  
		@v_temp_addr2 consignee_addr3,  
		@v_varchar50 billto_country,
		@v_varchar50 shipper_country,
		@v_varchar50 consignee_country,
		freightdetail.fgt_length,
		freightdetail.fgt_height,
		freightdetail.fgt_width,
		0 balance_due,
		0 total_paid,
		@v_temp_terms revtype1_desc,
		@v_temp_terms revtype2_desc,
		@v_varchar10 shipper_zip,
		@v_varchar10 consignee_zip,
		@v_varchar10 billto_zip,
		-- 25-JUL-2006 SWJ - PTS 33592
		@v_temp_name orderby_name,  
		@v_temp_addr orderby_addr,  
		@v_temp_addr2 orderby_addr2,  
		@v_temp_nmstct orderby_nmctst, 
		@v_varchar50 orderby_zip,
		@v_varchar50 orderby_country,
		@v_varchar255	consignee_full
INTO 		#invtemp_tbl  

FROM 		invoiceheader JOIN invoicedetail AS invoicedetail ON ( invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )
		RIGHT OUTER JOIN chargetype AS chargetype ON (chargetype.cht_itemcode = invoicedetail.cht_itemcode)
		LEFT OUTER JOIN commodity AS commodity ON (invoicedetail.cmd_code = commodity.cmd_code) 
		LEFT OUTER JOIN freightdetail AS freightdetail ON (invoicedetail.stp_number = freightdetail.stp_number)

WHERE  		invoiceheader.ivh_hdrnumber = @p_invoice_nbr 
 

/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
IF (SELECT count(*) FROM #invtemp_tbl) = 0  
BEGIN  
	SELECT @v_ret_value = 0    
 	GOTO ERROR_END  
END  
  
IF NOT EXISTS (SELECT 	cmp_mailto_name 
		FROM 	company c, #invtemp_tbl t 
		WHERE 	c.cmp_id = t.ivh_billto  
   			AND Rtrim(IsNULL(cmp_mailto_name, '')) > ''  
   			AND t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3,   
    				CASE IsNULL(cmp_mailtoTermsMatchFlag,'Y') WHEN 'Y' THEN '^^' ELSE t.ivh_terms END)  
  			AND t.ivh_charge <> CASE IsNULL(cmp_MailtToForLinehaulFlag,'Y') WHEN 'Y' THEN 0.00 ELSE ivh_charge + 1.00 END )   
BEGIN
	-- 23-AUG-2006 SWJ - PTS 33592 - Added logic for li_pos to prevent illegal SUBSTRING
	SELECT	@ls_cty = company.cty_nmstct
	FROM 	#invtemp_tbl, 
		company  
	WHERE 	company.cmp_id = #invtemp_tbl.ivh_billto 
	
	IF @ls_cty IS NOT NULL
		SET @li_pos = CHARINDEX('/', @ls_cty)
	
	IF @li_pos IS NULL OR @li_pos = 0
		SET @li_pos = LEN(@ls_cty)

	UPDATE 	#invtemp_tbl  
	SET 	ivh_billto_name = company.cmp_name,  
		ivh_billto_nmctst = SUBSTRING(company.cty_nmstct,1, @li_pos - 1) + ' ' + IsNULL(company.cmp_zip, ''),  
		#invtemp_tbl.cmp_altid = company.cmp_altid,  
		ivh_billto_addr = company.cmp_address1,  
		ivh_billto_addr2 = company.cmp_address2,  
		ivh_billto_addr3 = company.cmp_address3,  
		billto_country = company.cmp_country ,
		billto_zip = IsNULL(company.cmp_zip, '') 		
	FROM 	#invtemp_tbl, 
		company  
	WHERE 	company.cmp_id = #invtemp_tbl.ivh_billto 
END 
ELSE   
BEGIN
	-- 23-AUG-2006 SWJ - PTS 33592 - Added logic for li_pos to prevent illegal SUBSTRING
	SELECT	@ls_cty = company.mailto_cty_nmstct
	FROM 	#invtemp_tbl, 
		company  
	WHERE 	company.cmp_id = #invtemp_tbl.ivh_billto  
	
	IF @ls_cty IS NOT NULL
		SET @li_pos = CHARINDEX('/', @ls_cty)
	
	IF @li_pos IS NULL OR @li_pos = 0
		SET @li_pos = LEN(@ls_cty)

	UPDATE 	#invtemp_tbl  
	SET 	ivh_billto_name = company.cmp_mailto_name,  
		ivh_billto_addr =  company.cmp_mailto_address1 ,  
		ivh_billto_addr2 = company.cmp_mailto_address2,     
		ivh_billto_nmctst = SUBSTRING(company.mailto_cty_nmstct,1, @li_pos - 1)+ ' ' + IsNULL(company.cmp_mailto_zip, ''),  
		#invtemp_tbl.cmp_altid = company.cmp_altid ,  
		billto_country = company.cmp_country , 
		billto_zip = IsNULL(company.cmp_zip, '')     
	FROM 	#invtemp_tbl, 
		company  
	WHERE 	company.cmp_id = #invtemp_tbl.ivh_billto  
END 

--PTS# 27139 ILB 04/14/2005
SELECT 	@v_MINBilltoCountry = IsNULL(cmp_country, '')	       
FROM 	company, 
	#invtemp_tbl
WHERE 	company.cmp_id = #invtemp_tbl.ivh_billto
 
IF UPPER(@v_MINBilltoCountry) = 'MX' or UPPER(@v_MINBilltoCountry) = 'MEX' or UPPER(@v_MINBilltoCountry) = 'MEXICO'
BEGIN
	UPDATE 	#invtemp_tbl  
	SET 	ivh_billto_nmctst = city.alk_city + ',' + IsNULL(cmp.cmp_state, '')
	FROM 	#invtemp_tbl,
		city, 
		company cmp    
	WHERE 	cmp.cmp_id = #invtemp_tbl.ivh_billto AND
	 	cmp.cmp_city = cty_code AND
	 	cmp.cmp_country IN ('MX','MEX','MEXICO')      	
END		

-- 23-AUG-2006 SWJ - PTS 33592 - Added logic for li_pos to prevent illegal SUBSTRING
SELECT	@ls_cty = city.cty_nmstct
FROM 	#invtemp_tbl, 
	company, 
	city  
WHERE 	company.cmp_id = #invtemp_tbl.ivh_originpoint  
 	AND city.cty_code = #invtemp_tbl.ivh_origincity    

IF @ls_cty IS NOT NULL
	SET @li_pos = CHARINDEX('/', @ls_cty)

IF @li_pos IS NULL OR @li_pos = 0
	SET @li_pos = LEN(@ls_cty)

UPDATE	#invtemp_tbl  
SET 	originpoint_name = company.cmp_name,  
	origin_addr = company.cmp_address1,  
	origin_addr2 = company.cmp_address2,  
	origin_nmctst = SUBSTRING(city.cty_nmstct,1, @li_pos - 1) + ' ' + IsNULL(city.cty_zip , '')  
FROM 	#invtemp_tbl, 
	company, 
	city  
WHERE 	company.cmp_id = #invtemp_tbl.ivh_originpoint  
 	AND city.cty_code = #invtemp_tbl.ivh_origincity     

-- 23-AUG-2006 SWJ - PTS 33592 - Added logic for li_pos to prevent illegal SUBSTRING
SELECT	@ls_cty = city.cty_nmstct
FROM 	#invtemp_tbl, 
	company, 
	city  
WHERE 	company.cmp_id = #invtemp_tbl.ivh_destpoint  
	AND city.cty_code =  #invtemp_tbl.ivh_destcity    

IF @ls_cty IS NOT NULL
	SET @li_pos = CHARINDEX('/', @ls_cty)

IF @li_pos IS NULL OR @li_pos = 0
	SET @li_pos = LEN(@ls_cty)
      
UPDATE	#invtemp_tbl  
SET 	destpoint_name = company.cmp_name,  
	dest_addr = company.cmp_address1,  
	dest_addr2 = company.cmp_address2,  
	dest_nmctst =SUBSTRING(city.cty_nmstct,1, @li_pos - 1)+ ' ' + IsNULL(city.cty_zip, '')   
FROM 	#invtemp_tbl, 
	company, 
	city  
WHERE 	company.cmp_id = #invtemp_tbl.ivh_destpoint  
	AND city.cty_code =  #invtemp_tbl.ivh_destcity   

-- 23-AUG-2006 SWJ - PTS 33592 - Added logic for li_pos to prevent illegal SUBSTRING
SELECT	@ls_cty = company.cty_nmstct
FROM 	#invtemp_tbl, 
	company  
WHERE 	company.cmp_id = #invtemp_tbl.ivh_showshipper  

IF @ls_cty IS NOT NULL
	SET @li_pos = CHARINDEX('/', @ls_cty)

IF @li_pos IS NULL OR @li_pos = 0
	SET @li_pos = LEN(@ls_cty)
  
UPDATE 	#invtemp_tbl  
SET 	shipper_name = company.cmp_name,  
 	shipper_addr = CASE ivh_hideshipperaddr WHEN 'Y'   
    			THEN ''  
    			ELSE company.cmp_address1 END,  
	shipper_addr2 = CASE ivh_hideshipperaddr WHEN 'Y'   
    			THEN ''  
    			ELSE company.cmp_address2 END,  
	shipper_addr3 = IsNULL(cmp_address3, ''),
	shipper_nmctst = SUBSTRING(company.cty_nmstct, 1, @li_pos - 1),
	Shipper_country = company.cmp_country,
	Shipper_zip = IsNULL(company.cmp_zip, '')     
FROM 	#invtemp_tbl, 
	company  
WHERE 	company.cmp_id = #invtemp_tbl.ivh_showshipper  
  

-- There is no shipper city, so IF the shipper is UNKNOWN, use the origin city to get the nmstct    
UPDATE	#invtemp_tbl  
SET 	shipper_nmctst = origin_nmctst  
FROM 	#invtemp_tbl  
WHERE 	#invtemp_tbl.ivh_shipper = 'UNKNOWN'  

SELECT 	@v_MINShipperCountry = IsNULL(cmp_country, '')
  FROM 	company, 
	#invtemp_tbl
 WHERE 	company.cmp_id = #invtemp_tbl.ivh_showshipper
 
IF UPPER(@v_MINShipperCountry) = 'MX' or UPPER(@v_MINShipperCountry) = 'MEX' or UPPER(@v_MINShipperCountry) = 'MEXICO'
BEGIN
	UPDATE 	#invtemp_tbl  
	SET 	shipper_nmctst = city.alk_city + ',' + IsNULL(cmp.cmp_state, '')
	FROM 	#invtemp_tbl,
		city, 
		company cmp    
	WHERE 	cmp.cmp_id = #invtemp_tbl.ivh_showshipper 
		AND cmp.cmp_city = cty_code 
		AND cmp.cmp_country IN ('MX','MEX','MEXICO')      	
END		

SELECT 	@ls_cty = company.cty_nmstct
FROM	#invtemp_tbl,
	company,
	invoiceheader,
	orderheader
WHERE	company.cmp_id = orderheader.ord_company
	AND invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
	AND invoiceheader.ivh_hdrnumber = #invtemp_tbl.ivh_hdrnumber

IF @ls_cty IS NOT NULL
	SET @li_pos = CHARINDEX('/', @ls_cty)

IF @li_pos IS NULL OR @li_pos = 0
	SET @li_pos = LEN(@ls_cty)
	 

-- 25-JUL-2006 SWJ - PTS 33592
UPDATE	#invtemp_tbl
SET	orderby_name = company.cmp_name,
	orderby_nmctst = SUBSTRING(company.cty_nmstct, 1, @li_pos - 1),
	orderby_addr = company.cmp_address1,
	orderby_addr2 = company.cmp_address2,
	orderby_country = company.cmp_country,
	orderby_zip = company.cmp_zip
FROM	#invtemp_tbl,
	company,
	invoiceheader,
	orderheader
WHERE	company.cmp_id = orderheader.ord_company
	AND invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
	AND invoiceheader.ivh_hdrnumber = #invtemp_tbl.ivh_hdrnumber

-- 23-AUG-2006 SWJ - PTS 33592 - Added logic for li_pos to prevent illegal SUBSTRING
SELECT	@ls_cty = company.cty_nmstct
FROM 	#invtemp_tbl, company  
WHERE 	company.cmp_id = #invtemp_tbl.ivh_showcons 

IF @ls_cty IS NOT NULL
	SET @li_pos = CHARINDEX('/', @ls_cty)

IF @li_pos IS NULL OR @li_pos = 0
	SET @li_pos = LEN(@ls_cty)
	
UPDATE 	#invtemp_tbl  
SET 	consignee_name = company.cmp_name,  
	consignee_nmctst = SUBSTRING(company.cty_nmstct,1, @li_pos - 1), 
	consignee_addr = CASE ivh_hideconsignaddr when 'Y'   
				THEN ''  
				ELSE company.cmp_address1 END,      
	consignee_addr2 = CASE ivh_hideconsignaddr when 'Y'   
				THEN ''  
				ELSE company.cmp_address2 END,  
	consignee_addr3 = IsNULL(cmp_address3, ''),
	consignee_country = company.cmp_country  ,
	consignee_zip = IsNULL(company.cmp_zip, '')
FROM 	#invtemp_tbl, company  
WHERE 	company.cmp_id = #invtemp_tbl.ivh_showcons 
   
-- There is no consignee city, so IF the consignee is UNKNOWN, use the dest city to get the nmstct    
UPDATE 	#invtemp_tbl  
SET 	consignee_nmctst = dest_nmctst  
FROM 	#invtemp_tbl  
WHERE 	#invtemp_tbl.ivh_consignee = 'UNKNOWN'   

--PTS# 27139 ILB 04/14/2005
SELECT 	@v_MINConsCountry = IsNULL(cmp_country, '')	       
FROM 	company, #invtemp_tbl
WHERE 	company.cmp_id = #invtemp_tbl.ivh_showcons 
 
IF UPPER(@v_MINConsCountry) = 'MX' or UPPER(@v_MINConsCountry) = 'MEX' or UPPER(@v_MINConsCountry) = 'MEXICO'
BEGIN
	UPDATE 	#invtemp_tbl  
	SET 	consignee_nmctst = city.alk_city+','+IsNULL(cmp.cmp_state, '')
	FROM 	#invtemp_tbl,
		city, 
		company cmp     
	WHERE 	cmp.cmp_id = #invtemp_tbl.ivh_showcons AND
		cmp.cmp_city = cty_code AND
		cmp.cmp_country IN ('MX','MEX','MEXICO')      	
END		
    
UPDATE 	#invtemp_tbl  
SET 	stop_name = company.cmp_name,  
	stop_addr = company.cmp_address1,  
	stop_addr2 = company.cmp_address2  
FROM 	#invtemp_tbl, 
	company  
WHERE 	company.cmp_id = #invtemp_tbl.cmp_id  
  
-- dpete for UNKNOWN companies with cities must get city name FROM city table pts5319  
-- 23-AUG-2006 SWJ - PTS 33592 - Added logic for li_pos to prevent illegal SUBSTRING
SELECT	@ls_cty = city.cty_nmstct
FROM 	#invtemp_tbl JOIN stops AS stops ON (stops.stp_number =  #invtemp_tbl.stp_number)         
     	RIGHT OUTER JOIN city AS city ON (city.cty_code = stops.stp_city) 
WHERE  	#invtemp_tbl.stp_number IS NOT NULL  

IF @ls_cty IS NOT NULL
	SET @li_pos = CHARINDEX('/', @ls_cty)

IF @li_pos IS NULL OR @li_pos = 0
	SET @li_pos = LEN(@ls_cty)
 
UPDATE	#invtemp_tbl  
SET  	stop_nmctst = SUBSTRING(city.cty_nmstct, 1, @li_pos - 1) + ' ' + IsNULL(city.cty_zip, '')   
FROM 	#invtemp_tbl JOIN stops AS stops ON (stops.stp_number =  #invtemp_tbl.stp_number)         
     	RIGHT OUTER JOIN city AS city ON (city.cty_code = stops.stp_city)
WHERE  	#invtemp_tbl.stp_number IS NOT NULL  
  
UPDATE 	#invtemp_tbl  
SET 	terms_name = la.name  
FROM 	labelfile la  
WHERE 	la.labeldefinition = 'creditterms' 
	AND la.abbr = #invtemp_tbl.ivh_terms  

--24796
UPDATE 	#invtemp_tbl
SET 	#invtemp_tbl.tarIFfkey_startdate = tar.trk_startdate
FROM 	#invtemp_tbl, 
	tarIFfkey tar
WHERE 	#invtemp_tbl.tar_number = tar.tar_number
--24796
      
--27139
UPDATE 	#invtemp_tbl
SET 	revtype1_desc = l.name
FROM 	#invtemp_tbl invtmp
	INNER JOIN labelfile l ON invtmp.ivh_revtype1 = l.abbr
WHERE 	UPPER(l.labeldefinition) = 'REVTYPE1'

UPDATE 	#invtemp_tbl
SET 	revtype2_desc = l.name
FROM 	#invtemp_tbl invtmp
	INNER JOIN labelfile l on invtmp.ivh_revtype2 = l.abbr
WHERE 	UPPER(l.labeldefinition) = 'REVTYPE2'
--27139

--27614
SELECT	@v_ord_hdrnumber = MIN(ord_hdrnumber) 
FROM 	#invtemp_tbl 
WHERE 	ord_hdrnumber > 0 

IF @v_ord_hdrnumber IS NOT NULL
BEGIN
	IF EXISTS ( SELECT * FROM orderheader WHERE ord_hdrnumber = @v_ord_hdrnumber AND (ord_length > 0 or ord_width > 0 or ord_height > 0))
	BEGIN
		UPDATE	#invtemp_tbl 
		SET 	fgt_length = ord_length , 
			fgt_width = ord_width, 
			fgt_height = ord_height
		FROM  	orderheader 
		WHERE 	orderheader.ord_hdrnumber = @v_ord_hdrnumber 
			AND #invtemp_tbl.ord_hdrnumber = @v_ord_hdrnumber
	END
END
-- END 27614 JD 04/07/05

-- 26-JUL-2006 SWJ - PTS 33592
-- Check the consignee country for Mexico to make sure it's in the correct format
UPDATE	#invtemp_tbl
SET	consignee_country = 'Mexico'
WHERE	consignee_country IN ('MX', 'MEXICO', 'MEX')

-- Create the consignee full address
SELECT 	@v_temp_name	= consignee_name, 
	@v_temp_addr 	= consignee_addr, 
	@v_temp_addr2 	= consignee_addr2, 
	@v_temp_nmstct 	= consignee_nmctst, 
	@v_temp_zip 	= consignee_zip
FROM	#invtemp_tbl
WHERE	#invtemp_tbl.ord_hdrnumber = @v_ord_hdrnumber

IF @v_temp_name <> '' AND @v_temp_name IS NOT NULL AND @v_temp_name <> 'UNKNOWN'
	SET @ls_consignee_full = @v_temp_name

IF @v_temp_addr <> '' AND @v_temp_addr IS NOT NULL AND @v_temp_addr <> 'UNKNOWN'
	IF @ls_consignee_full IS NOT NULL
		SET @ls_consignee_full = @ls_consignee_full + ', ' + @v_temp_addr
	ELSE
		SET @ls_consignee_full = @v_temp_addr

IF @v_temp_addr2 <> '' AND @v_temp_addr2 IS NOT NULL
	IF @ls_consignee_full IS NOT NULL
		SET @ls_consignee_full = @ls_consignee_full + ', ' + @v_temp_addr2
	ELSE
		SET @ls_consignee_full = @v_temp_addr2

IF @v_temp_nmstct <> '' AND @v_temp_nmstct IS NOT NULL
	IF @ls_consignee_full IS NOT NULL
		SET @ls_consignee_full = @ls_consignee_full + ', ' + @v_temp_nmstct
	ELSE
		SET @ls_consignee_full = @v_temp_nmstct

IF @v_temp_zip <> '' AND @v_temp_zip IS NOT NULL
	IF @ls_consignee_full IS NOT NULL
		SET @ls_consignee_full = @ls_consignee_full + ', ' + @v_temp_zip
	ELSE
		SET @ls_consignee_full = @v_temp_zip

UPDATE	#invtemp_tbl
SET	consignee_full = @ls_consignee_full

/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
SELECT 	@v_counter = 1  
WHILE 	@v_counter <> @p_copies  
BEGIN  
	SELECT @v_counter = @v_counter + 1  
	INSERT INTO #invtemp_tbl  
	SELECT  ivh_invoicenumber,     
		ivh_hdrnumber,   
		ivh_billto,   
		ivh_billto_name ,  
		ivh_billto_addr,  
		ivh_billto_addr2,          
		ivh_billto_nmctst,  
		ivh_terms,      
		ivh_totalcharge,     
		ivh_shipper,		--10     
		shipper_name,  
		shipper_addr,  
		shipper_addr2,  
		shipper_nmctst,  
		ivh_consignee,     
		consignee_name,  
		consignee_addr,  
		consignee_addr2,  
		consignee_nmctst,  
		ivh_originpoint,	--20     
		originpoint_name,  
		origin_addr,  
		origin_addr2,  
		origin_nmctst,  
		ivh_destpoint,     
		destpoint_name,  
		dest_addr,  
		dest_addr2,  
		dest_nmctst,  
		ivh_invoicestatus,	--30     
		ivh_origincity,     
		ivh_destcity,     
		ivh_originstate,     
		ivh_deststate,     
		ivh_originregion1,     
		ivh_destregion1,     
		ivh_supplier,     
		ivh_shipdate,     
		ivh_deliverydate,     
		ivh_revtype1,    	--40
		ivh_revtype2,     
		ivh_revtype3,     
		ivh_revtype4,     
		ivh_totalweight,     
		ivh_totalpieces,     
		ivh_totalmiles,     
		ivh_currency,     
		ivh_currencydate,     
		ivh_totalvolume,   
		ivh_taxamount1,   	--50  
		ivh_taxamount2,     
		ivh_taxamount3,     
		ivh_taxamount4,     
		ivh_transtype,     
		ivh_creditmemo,     
		ivh_applyto,     
		ivh_printdate,     
		ivh_billdate,     
		ivh_lastprintdate,     
		ivh_originregion2, 	--60     
		ivh_originregion3,     
		ivh_originregion4,     
		ivh_destregion2,     
		ivh_destregion3,     
		ivh_destregion4,     
		mfh_hdrnumber,     
		ivh_remark,     
		ivh_driver,     
		ivh_tractor,     
		ivh_trailer,    	--70 
		ivh_user_id1,     
		ivh_user_id2,     
		ivh_ref_number,     
		ivh_driver2,     
		mov_number,     
		ivh_edi_flag,     
		ord_hdrnumber,     
		ivd_number,     
		stp_number,     
		ivd_description, 	--80     
		cht_itemcode,     
		ivd_quantity,     
		ivd_rate,     
		ivd_charge,     
		ivd_taxable1,     
		ivd_taxable2,     
		ivd_taxable3,     
		ivd_taxable4,     
		ivd_unit,     
		cur_code,     		--90
		ivd_currencydate,     
		ivd_glnum,     
		ivd_type,     
		ivd_rateunit,     
		ivd_billto,    
		ivd_billto_name,  
		ivd_billto_addr,  
		ivd_billto_addr2,  
		ivd_billto_nmctst,  
		ivd_itemquantity, 	--100     
		ivd_subtotalptr,     
		ivd_allocatedrev,     
		ivd_sequence,     
		ivd_refnum,     
		cmd_code,   
		cmp_id,     
		stop_name,  
		stop_addr,  
		stop_addr2,  
		stop_nmctst,		--110  
		ivd_distance,     
		ivd_distunit,     
		ivd_wgt,     
		ivd_wgtunit,     
		ivd_count,     
		ivd_countunit,     
		evt_number,     
		ivd_reftype,     
		ivd_volume,     
		ivd_volunit, 		--120    
		ivd_orig_cmpid,     
		ivd_payrevenue,  
		ivh_freight_miles,  
		tar_tarrIFfnumber,  
		tar_tarIFfitem,  
		@v_counter,  
		cht_basis,  
		cht_description,  
		cmd_name,  
		cmp_altid, 		--130 
		ivh_hideshipperaddr,  
		ivh_hideconsignaddr,  
		ivh_showshipper,  
		ivh_showcons,  
		terms_name,  
		IsNULL(ivh_charge,0) ivh_charge,  
		ivh_billto_addr3,
		tar_number, 
		tarIFfkey_startdate, 
		shipper_addr3, 
		consignee_addr3,
		IsNULL(billto_country, '') billto_country,
		IsNULL(shipper_country, '') shipper_country, 		--140
		IsNULL(consignee_country, '') consignee_country,
		IsNULL(fgt_length, 0) fgt_length,
		IsNULL(fgt_height, 0) fgt_height,
		IsNULL(fgt_width, 0) fgt_width,
		balance_due,
		total_paid,
		revtype1_desc, 
		revtype2_desc,
		shipper_zip,
		consignee_zip, 		--150
		billto_zip,
		-- 25-JUL-2006 SWJ - PTS 33592
		consignee_full,
		orderby_name,
		orderby_addr,
		orderby_addr2,
		orderby_nmctst,
		orderby_zip,		
		orderby_country
	FROM 	#invtemp_tbl  
	WHERE 	copies = 1     
END   
                                                                
ERROR_END:  
/* FINAL SELECT - FORMS RETURN SET */  
SELECT	ivh_invoicenumber,     
	ivh_hdrnumber,   
	ivh_billto,   
	ivh_billto_name ,  
	ivh_billto_addr,  
	ivh_billto_addr2,           
	ivh_billto_nmctst,  
	ivh_terms,      
	ivh_totalcharge,     
	ivh_shipper,     	--10
	shipper_name,  		
	shipper_addr,  
	shipper_addr2,  
	shipper_nmctst,  
	ivh_consignee,     
	consignee_name,  
	consignee_addr,  
	consignee_addr2,  
	consignee_nmctst,  
	ivh_originpoint,	--20     
	originpoint_name,  
	origin_addr,  
	origin_addr2,  
	origin_nmctst,  
	ivh_destpoint,     
	destpoint_name,  
	dest_addr,  
	dest_addr2,  
	dest_nmctst,  
	ivh_invoicestatus,     	--30     
	ivh_origincity,
	ivh_destcity,     
	ivh_originstate,     
	ivh_deststate,     
	ivh_originregion1,     
	ivh_destregion1,     
	ivh_supplier,     
	ivh_shipdate,     
	ivh_deliverydate,     
	ivh_revtype1,     	--40     
	ivh_revtype2,
	ivh_revtype3,     
	ivh_revtype4,     
	ivh_totalweight,     
	ivh_totalpieces,     
	ivh_totalmiles,     
	ivh_currency,     
	ivh_currencydate,     
	ivh_totalvolume,   
	ivh_taxamount1,   	--50     
	ivh_taxamount2,
	ivh_taxamount3,     
	ivh_taxamount4,     
	ivh_transtype,     
	ivh_creditmemo,     
	ivh_applyto,     
	ivh_printdate,     
	ivh_billdate,     
	ivh_lastprintdate,     
	ivh_originregion2,	--60     
	ivh_originregion3,     
	ivh_originregion4,     
	ivh_destregion2,     
	ivh_destregion3,     
	ivh_destregion4,     
	mfh_hdrnumber,     
	ivh_remark,     
	ivh_driver,     
	ivh_tractor,     
	ivh_trailer,		--70
	ivh_user_id1,  
	ivh_user_id2,     
	ivh_ref_number,     
	ivh_driver2,     
	mov_number,     
	ivh_edi_flag,     
	ord_hdrnumber,     
	ivd_number,     
	stp_number,     
	ivd_description,    	--80    
	cht_itemcode,  
	ivd_quantity,     
	ivd_rate,     
	ivd_charge,     
	ivd_taxable1,     
	ivd_taxable2,     
	ivd_taxable3,     
	ivd_taxable4,     
	ivd_unit,     
	cur_code,		--90     
	ivd_currencydate,     
	ivd_glnum,     
	ivd_type,     
	ivd_rateunit,     
	ivd_billto,    
	ivd_billto_name,  
	ivd_billto_addr,  
	ivd_billto_addr2,  
	ivd_billto_nmctst,  
	ivd_itemquantity,	--100     
	ivd_subtotalptr,     
	ivd_allocatedrev,     
	ivd_sequence,     
	ivd_refnum,     
	cmd_code,   
	cmp_id,     
	stop_name,  
	stop_addr,  
	stop_addr2,  
	stop_nmctst,		--110  
	ivd_distance,     
	ivd_distunit,     
	ivd_wgt,     
	ivd_wgtunit,     
	ivd_count,     
	ivd_countunit,     
	evt_number,     
	ivd_reftype,     
	ivd_volume,     
	ivd_volunit,   		--120  
	ivd_orig_cmpid,     
	ivd_payrevenue,  
	ivh_freight_miles,  
	tar_tarrIFfnumber,  
	tar_tarIFfitem,  
	copies,  
	cht_basis,  
	cht_description,  
	cmd_name,  
	cmp_altid,  		--130
	ivh_showshipper,  
	ivh_showcons,  
	terms_name,  
	ivh_billto_addr3, 
	tar_number,
	tarIFfkey_startdate,
	shipper_addr3,
	consignee_addr3,
	IsNULL(billto_country, '')billto_country,
	IsNULL(shipper_country, '')shipper_country,		--140
	IsNULL(consignee_country, '')consignee_country,
	IsNULL(fgt_length,0)fgt_length,
	IsNULL(fgt_height,0)fgt_height,
	IsNULL(fgt_width,0)fgt_width,
	balance_due,
	total_paid,
	revtype1_desc,
	revtype2_desc,
	shipper_zip,
	consignee_zip,		--150
	billto_zip,
	-- 25-JUL-2006 SWJ - PTS 33592
	consignee_full,
	orderby_name,
	orderby_addr,
	orderby_addr2,
	orderby_nmctst,
	orderby_zip,		
	orderby_country
FROM 	#invtemp_tbl  
--WHERE	stop_name <> consignee_name
ORDER BY ivd_sequence, cht_itemcode
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  

IF @@ERROR != 0 SELECT @v_ret_value = @@ERROR   
RETURN @v_ret_value  

GO
GRANT EXECUTE ON  [dbo].[invoice_template98] TO [public]
GO
