SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  create procedure [dbo].[invoice_template83](@invoice_nbr   int, @copies  int)  
as  
/* PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND  
 1 - IF SUCCESFULLY EXECUTED  
 @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
  
11/1/05 JJF PTS 30061 - based on invoice_template2
*/  
  
DECLARE @temp_name		varchar(100),  
	@temp_addr		varchar(100),
	@temp_addr2		varchar(100),  
	@temp_nmstct		varchar(30),  
	@temp_altid		varchar(25),  
	@counter		int,  
	@ret_value		int,  
	@temp_terms		varchar(20),  
	@varchar50		varchar(50),  
	@GroupChargeTypes	tinyint, 
	@Group1			varchar(60), 
	@Group2			varchar(60), 
	@Group3			varchar(60), 
	@Group4			varchar(60),
	@WorkGroup		varchar(60),
	@cht_itemcode		varchar(6),
	@sequence		int,
	@ivd_rate		money
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
SELECT @ret_value = 1  
  
/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  
 
SELECT    invoiceheader.ivh_invoicenumber, invoiceheader.ivh_hdrnumber, invoiceheader.ivh_billto, @temp_name AS ivh_billto_name, 
                     @temp_addr AS ivh_billto_addr, @temp_addr2 AS ivh_billto_addr2, @temp_nmstct AS ivh_billto_nmctst, 
                     invoiceheader.ivh_terms, invoiceheader.ivh_totalcharge, invoiceheader.ivh_shipper, @temp_name AS shipper_name, 
                     @temp_addr AS shipper_addr, @temp_addr2 AS shipper_addr2, @temp_nmstct AS shipper_nmctst, 
                     invoiceheader.ivh_consignee, @temp_name AS consignee_name, @temp_addr AS consignee_addr, 
                     @temp_addr2 AS consignee_addr2, @temp_nmstct AS consignee_nmctst, invoiceheader.ivh_originpoint, 
                     @temp_name AS originpoint_name, @temp_addr AS origin_addr, @temp_addr2 AS origin_addr2, 
                     @temp_nmstct AS origin_nmctst, invoiceheader.ivh_destpoint, @temp_name AS destpoint_name, @temp_addr AS dest_addr, 
                     @temp_addr2 AS dest_addr2, @temp_nmstct AS dest_nmctst, invoiceheader.ivh_invoicestatus, invoiceheader.ivh_origincity, 
                     invoiceheader.ivh_destcity, invoiceheader.ivh_originstate, invoiceheader.ivh_deststate, invoiceheader.ivh_originregion1, 
                     invoiceheader.ivh_destregion1, invoiceheader.ivh_supplier, invoiceheader.ivh_shipdate, invoiceheader.ivh_deliverydate, 
                     invoiceheader.ivh_revtype1, invoiceheader.ivh_revtype2, invoiceheader.ivh_revtype3, invoiceheader.ivh_revtype4, 
                     invoiceheader.ivh_totalweight, invoiceheader.ivh_totalpieces, invoiceheader.ivh_totalmiles, invoiceheader.ivh_currency, 
                     invoiceheader.ivh_currencydate, invoiceheader.ivh_totalvolume, invoiceheader.ivh_taxamount1, 
                     invoiceheader.ivh_taxamount2, invoiceheader.ivh_taxamount3, invoiceheader.ivh_taxamount4, invoiceheader.ivh_transtype, 
                     invoiceheader.ivh_creditmemo, invoiceheader.ivh_applyto, invoiceheader.ivh_printdate, invoiceheader.ivh_billdate, 
                     invoiceheader.ivh_lastprintdate, invoiceheader.ivh_originregion2, invoiceheader.ivh_originregion3, 
                     invoiceheader.ivh_originregion4, invoiceheader.ivh_destregion2, invoiceheader.ivh_destregion3, 
                     invoiceheader.ivh_destregion4, invoiceheader.mfh_hdrnumber, invoiceheader.ivh_remark, invoiceheader.ivh_driver, 
                     invoiceheader.ivh_tractor, invoiceheader.ivh_trailer, invoiceheader.ivh_user_id1, invoiceheader.ivh_user_id2, 
                     invoiceheader.ivh_ref_number, invoiceheader.ivh_driver2, invoiceheader.mov_number, invoiceheader.ivh_edi_flag, 
                     invoiceheader.ord_hdrnumber, invoicedetail.ivd_number, invoicedetail.stp_number, invoicedetail.ivd_description, 
                     invoicedetail.cht_itemcode, invoicedetail.ivd_quantity, invoicedetail.ivd_rate, invoicedetail.ivd_charge, 
                     ISNULL(chargetype.cht_taxtable1, invoicedetail.ivd_taxable1) AS ivd_taxable1, ISNULL(chargetype.cht_taxtable2, 
                     invoicedetail.ivd_taxable2) AS ivd_taxable2, ISNULL(chargetype.cht_taxtable3, invoicedetail.ivd_taxable3) AS ivd_taxable3, 
                     ISNULL(chargetype.cht_taxtable4, invoicedetail.ivd_taxable4) AS ivd_taxable4, invoicedetail.ivd_unit, invoicedetail.cur_code, 
                     invoicedetail.ivd_currencydate, invoicedetail.ivd_glnum, invoicedetail.ivd_type, invoicedetail.ivd_rateunit, 
                     invoicedetail.ivd_billto, @temp_name AS ivd_billto_name, @temp_addr AS ivd_billto_addr, @temp_addr2 AS ivd_billto_addr2, 
                     @temp_nmstct AS ivd_billto_nmctst, invoicedetail.ivd_itemquantity, invoicedetail.ivd_subtotalptr, 
                     invoicedetail.ivd_allocatedrev, invoicedetail.ivd_sequence, invoicedetail.ivd_refnum, invoicedetail.cmd_code, 
                     invoicedetail.cmp_id, @temp_name AS stop_name, @temp_addr AS stop_addr, @temp_addr2 AS stop_addr2, 
                     @temp_nmstct AS stop_nmctst, invoicedetail.ivd_distance, invoicedetail.ivd_distunit, invoicedetail.ivd_wgt, 
                     invoicedetail.ivd_wgtunit, invoicedetail.ivd_count, invoicedetail.ivd_countunit, invoicedetail.evt_number, 
                     invoicedetail.ivd_reftype, invoicedetail.ivd_volume, invoicedetail.ivd_volunit, invoicedetail.ivd_orig_cmpid, 
                     invoicedetail.ivd_payrevenue, invoiceheader.ivh_freight_miles, invoiceheader.tar_tarriffnumber, invoiceheader.tar_tariffitem, 
                     1 AS copies, chargetype.cht_basis, chargetype.cht_description, commodity.cmd_name, @temp_altid AS cmp_altid, 
                     invoiceheader.ivh_hideshipperaddr, invoiceheader.ivh_hideconsignaddr, 
                     (CASE ivh_showshipper WHEN 'UNKNOWN' THEN invoiceheader.ivh_shipper ELSE IsNull(ivh_showshipper, 
                     invoiceheader.ivh_shipper) END) AS ivh_showshipper, 
                     (CASE ivh_showcons WHEN 'UNKNOWN' THEN invoiceheader.ivh_consignee ELSE IsNull(ivh_showcons, 
                     invoiceheader.ivh_consignee) END) AS ivh_showcons, @temp_terms AS terms_name, ISNULL(invoiceheader.ivh_charge, 0) 
                     AS ivh_charge, @temp_addr2 AS ivh_billto_addr3, @varchar50 AS cmp_contact, @varchar50 AS shipper_geoloc, 
                     @varchar50 AS cons_geoloc
INTO          [#invtemp_tbl]
FROM        invoiceheader INNER JOIN
                     invoicedetail ON invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber RIGHT OUTER JOIN
                     chargetype ON invoicedetail.cht_itemcode = chargetype.cht_itemcode LEFT OUTER JOIN
                     commodity ON invoicedetail.cmd_code = commodity.cmd_code
WHERE    (invoiceheader.ivh_hdrnumber = @invoice_nbr)  
   
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
IF (select count(*) from #invtemp_tbl) = 0 BEGIN
	SELECT @ret_value = 0    
	GOTO ERROR_END  
END
  
IF NOT EXISTS (SELECT    c.cmp_mailto_name
               FROM        company c INNER JOIN
                                    [#invtemp_tbl] t ON c.cmp_id = t.ivh_billto
               WHERE    (RTRIM(ISNULL(c.cmp_mailto_name, '')) > '') AND (t.ivh_terms IN (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, 
                                    c.cmp_mailto_crterm3, CASE IsNull(cmp_mailtoTermsMatchFlag, 'N') WHEN 'Y' THEN '^^' ELSE t.ivh_terms END)) AND 
                                    (t.ivh_charge <> CASE IsNull(cmp_MailtToForLinehaulFlag, 'Y') WHEN 'Y' THEN 0.00 ELSE ivh_charge + 1.00 END) )   
  
	UPDATE #invtemp_tbl  
	SET ivh_billto_name = company.cmp_name,  
		ivh_billto_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),  
		#invtemp_tbl.cmp_altid = company.cmp_altid,  
		ivh_billto_addr = company.cmp_address1,  
		ivh_billto_addr2 = company.cmp_address2,  
		ivh_billto_addr3 = company.cmp_address3,  
		cmp_contact = company.cmp_contact  
	FROM        [#invtemp_tbl] INNER JOIN
	                     company ON [#invtemp_tbl].ivh_billto = company.cmp_id  
	
ELSE
	UPDATE #invtemp_tbl  
	SET ivh_billto_name = company.cmp_mailto_name,  
		ivh_billto_addr =  company.cmp_mailto_address1 ,  
		ivh_billto_addr2 = company.cmp_mailto_address2,     
		ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + IsNull(company.cmp_mailto_zip,''),  
		#invtemp_tbl.cmp_altid = company.cmp_altid ,  
		cmp_contact = company.cmp_contact  
	FROM        [#invtemp_tbl] INNER JOIN
                     company ON [#invtemp_tbl].ivh_billto = company.cmp_id 
  

UPDATE #invtemp_tbl  
SET	originpoint_name = company.cmp_name,  
	origin_addr = company.cmp_address1,  
	origin_addr2 = company.cmp_address2,  
	origin_nmctst = substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip ,'')  
FROM        [#invtemp_tbl] INNER JOIN
                     company ON [#invtemp_tbl].ivh_originpoint = company.cmp_id INNER JOIN
                     city ON [#invtemp_tbl].ivh_origincity = city.cty_code     

UPDATE #invtemp_tbl  
SET	destpoint_name = company.cmp_name,  
	dest_addr = company.cmp_address1,  
	dest_addr2 = company.cmp_address2,  
	dest_nmctst =substring(city.cty_nmstct,1, (charindex('/',city.cty_nmstct)))+ ' ' + ISNULL(city.cty_zip,'')   
FROM        [#invtemp_tbl] INNER JOIN
                     company ON [#invtemp_tbl].ivh_destpoint = company.cmp_id INNER JOIN
                     city ON [#invtemp_tbl].ivh_destcity = city.cty_code   

UPDATE #invtemp_tbl  
SET	shipper_name = company.cmp_name,  
	shipper_addr = Case ivh_hideshipperaddr 
				when 'Y' then ''  
				else company.cmp_address1  
			end,  
	shipper_addr2 = Case ivh_hideshipperaddr 
				when 'Y' then ''  
				else company.cmp_address2  
			end,  
	shipper_nmctst = substring(company.cty_nmstct, 1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,''),  
	Shipper_geoloc = IsNull(cmp_geoloc,'')  
FROM        [#invtemp_tbl] INNER JOIN
                     company ON [#invtemp_tbl].ivh_showshipper = company.cmp_id  

-- There is no shipper city, so if the shipper is UNKNOWN, use the origin city to get the nmstct    
UPDATE #invtemp_tbl  
SET	shipper_nmctst = origin_nmctst  
FROM        [#invtemp_tbl]
WHERE    (RTRIM(ISNULL(shipper_nmctst, '')) = '')  

UPDATE #invtemp_tbl  
SET	consignee_name = company.cmp_name,  
	consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +IsNull(company.cmp_zip, ''), 
	consignee_addr = Case ivh_hideconsignaddr 
				when 'Y' then ''  
				else company.cmp_address1  
			end,      
	consignee_addr2 = Case ivh_hideconsignaddr 
				when 'Y' then ''  
				else company.cmp_address2  
			end,  
	cons_geoloc = IsNull(cmp_geoloc,'')  
FROM        [#invtemp_tbl] INNER JOIN
                     company ON [#invtemp_tbl].ivh_showcons = company.cmp_id     

-- There is no consignee city, so if the consignee is UNKNOWN, use the dest city to get the nmstct    
UPDATE #invtemp_tbl  
SET consignee_nmctst = dest_nmctst  
FROM        [#invtemp_tbl]
WHERE    (RTRIM(ISNULL(consignee_nmctst, '')) = '')  

UPDATE #invtemp_tbl  
SET	stop_name = company.cmp_name,  
	stop_addr = company.cmp_address1,  
	stop_addr2 = company.cmp_address2  
FROM        [#invtemp_tbl] INNER JOIN
                     company ON [#invtemp_tbl].cmp_id = company.cmp_id  

-- dpete for UNKNOWN companies with cities must get city name from city table pts5319   
UPDATE #invtemp_tbl  
SET	stop_nmctst = substring(city.cty_nmstct, 1, (charindex('/', city.cty_nmstct)))+ ' ' + IsNull(city.cty_zip, '')   
FROM        [#invtemp_tbl] INNER JOIN
                     stops ON [#invtemp_tbl].stp_number = stops.stp_number RIGHT OUTER JOIN
                     city ON stops.stp_city = city.cty_code
WHERE    ([#invtemp_tbl].stp_number IS NOT NULL)  

UPDATE #invtemp_tbl  
SET terms_name = la.name  
FROM        labelfile la
WHERE    (labeldefinition = 'creditterms') AND (la.abbr = [#invtemp_tbl].ivh_terms)  

--SELECT * FROM #invtemp_tbl

--Consolidate line items based on group by settings in generalinfo setting: groupchargesoninvoice
SELECT  @GroupChargeTypes = gi_integer1, 
	@Group1 = gi_string1, 
	@Group2 = gi_string2, 
	@Group3 = gi_string3, 
	@Group4 = gi_string4
FROM        generalinfo
WHERE    (gi_name = 'groupchargesoninvoice') 

SELECT SPACE(60) as WorkGroup,* 
INTO #invtemp_tbl_final
FROM #invtemp_tbl
WHERE 1 = 0

--Do grouping logic?
IF @GroupChargeTypes = 1 BEGIN

	--Let's go thru each group
	SELECT @counter = 1  
	WHILE @counter <= 4 BEGIN
		IF @counter = 1 SELECT @WorkGroup = @Group1
		IF @counter = 2 SELECT @WorkGroup = @Group2
		IF @counter = 3 SELECT @WorkGroup = @Group3
		IF @counter = 4 SELECT @WorkGroup = @Group4
		
		IF @WorkGroup IS NOT NULL BEGIN
			--Let's move thru the group looking for 1st member
			DECLARE ivd_cursor CURSOR FOR 
			SELECT * FROM CSVStringsToTable_fn(@WorkGroup)
	
			OPEN ivd_cursor
			FETCH NEXT FROM ivd_cursor INTO @cht_itemcode
			WHILE (@@fetch_status <> -1) BEGIN
				IF (@@fetch_status <> -2) BEGIN
					
					--Is this group element in the invoice?
					WHILE EXISTS (	SELECT * 
							FROM #invtemp_tbl 
							WHERE cht_itemcode = @cht_itemcode) BEGIN
							
						--It exist, use the 1st one found based on sequence
						SET ROWCOUNT 1
						SELECT	@sequence = ivd_sequence,
							@ivd_rate = ivd_rate
						FROM #invtemp_tbl 
						WHERE cht_itemcode = @cht_itemcode
						ORDER BY ivd_sequence
						SET ROWCOUNT 0
						
						--Add the line to final invoice 
						INSERT INTO #invtemp_tbl_final
						SELECT	@WorkGroup AS WorkGroup,
							ivh_invoicenumber, 
							ivh_hdrnumber, 
							ivh_billto, 
							ivh_billto_name, 
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
							1 AS copies, 
							cht_basis, 
							cht_description, 
							cmd_name, 
							cmp_altid, 
							ivh_hideshipperaddr, 
							ivh_hideconsignaddr, 
							ivh_showshipper, 
							ivh_showcons, 
							terms_name, 
							ivh_charge, 
							ivh_billto_addr3, 
							cmp_contact, 
							shipper_geoloc, 
							cons_geoloc
						FROM	[#invtemp_tbl]
						WHERE cht_itemcode = @cht_itemcode 
							AND ivd_sequence = @sequence
						
						--Now get remaining items and consolidate into this group	
						UPDATE #invtemp_tbl_final			
						SET ivd_charge = (SELECT SUM(#invtemp_tbl.ivd_charge)
									FROM #invtemp_tbl
									WHERE cht_itemcode IN (SELECT * FROM CSVStringsToTable_fn(@WorkGroup)) 
										AND #invtemp_tbl.ivd_rate = @ivd_rate),
						ivd_quantity = (SELECT SUM(#invtemp_tbl.ivd_quantity)
									FROM #invtemp_tbl
									WHERE cht_itemcode IN (SELECT * FROM CSVStringsToTable_fn(@WorkGroup)) 
										AND #invtemp_tbl.ivd_rate = @ivd_rate),
						ivd_itemquantity = (SELECT SUM(#invtemp_tbl.ivd_itemquantity)
									FROM #invtemp_tbl
									WHERE cht_itemcode IN (SELECT * FROM CSVStringsToTable_fn(@WorkGroup)) 
										AND #invtemp_tbl.ivd_rate = @ivd_rate),
						ivd_wgt = (SELECT SUM(#invtemp_tbl.ivd_wgt)
									FROM #invtemp_tbl
									WHERE cht_itemcode IN (SELECT * FROM CSVStringsToTable_fn(@WorkGroup)) 
										AND #invtemp_tbl.ivd_rate = @ivd_rate),
						ivd_count = (SELECT SUM(#invtemp_tbl.ivd_count)
									FROM #invtemp_tbl
									WHERE cht_itemcode IN (SELECT * FROM CSVStringsToTable_fn(@WorkGroup)) 
										AND #invtemp_tbl.ivd_rate = @ivd_rate),
						ivd_volume = (SELECT SUM(#invtemp_tbl.ivd_volume)
									FROM #invtemp_tbl
									WHERE cht_itemcode IN (SELECT * FROM CSVStringsToTable_fn(@WorkGroup)) 
										AND #invtemp_tbl.ivd_rate = @ivd_rate)
						WHERE WorkGroup = @WorkGroup
							AND ivd_rate = @ivd_rate
						
						--And delete delete all members of this group from the invoice list
						DELETE FROM #invtemp_tbl 
						WHERE cht_itemcode IN (SELECT * FROM CSVStringsToTable_fn(@WorkGroup))
							AND #invtemp_tbl.ivd_rate = @ivd_rate
					END
						
				END
				FETCH NEXT FROM ivd_cursor INTO @cht_itemcode
			END
			CLOSE ivd_cursor
			DEALLOCATE ivd_cursor
		END
		SELECT @counter = @counter + 1
	END	
END

--Add any invoice items still remaining after grouping to the final invoice
INSERT INTO #invtemp_tbl_final
SELECT	'orphans' AS WorkGroup,
	ivh_invoicenumber, 
	ivh_hdrnumber, 
	ivh_billto, 
	ivh_billto_name, 
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
	ivd_quantity = (CASE cht_itemcode WHEN 'DEL' THEN 0 ELSE ivd_quantity END), 
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
	--PTS 39825 JJF 20071008 restore weight as requested
	--ivd_wgt = (CASE cht_itemcode WHEN 'DEL' THEN 0 ELSE ivd_wgt END),
	ivd_wgt,
	--END PTS 39825 JJF 20071008 restore weight as requested
	ivd_wgtunit, 
	ivd_count = (CASE cht_itemcode WHEN 'DEL' THEN 0 ELSE ivd_count END), 
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
	1 AS copies, 
	cht_basis, 
	cht_description, 
	cmd_name, 
	cmp_altid, 
	ivh_hideshipperaddr, 
	ivh_hideconsignaddr, 
	ivh_showshipper, 
	ivh_showcons, 
	terms_name, 
	ivh_charge, 
	ivh_billto_addr3, 
	cmp_contact, 
	shipper_geoloc, 
	cons_geoloc
FROM	[#invtemp_tbl]
ORDER BY ivd_sequence

/* MAKE COPIES OF INVOICES BASED ON INPUTTED VALUE */  
SELECT @counter = 1  

WHILE @counter <> @copies BEGIN
	SELECT @counter = @counter + 1  
	
	INSERT INTO #invtemp_tbl_final  
	SELECT    WorkGroup, ivh_invoicenumber, ivh_hdrnumber, ivh_billto, ivh_billto_name, ivh_billto_addr, ivh_billto_addr2, ivh_billto_nmctst, ivh_terms, 
			ivh_totalcharge, ivh_shipper, shipper_name, shipper_addr, shipper_addr2, shipper_nmctst, ivh_consignee, consignee_name, 
			consignee_addr, consignee_addr2, consignee_nmctst, ivh_originpoint, originpoint_name, origin_addr, origin_addr2, 
			origin_nmctst, ivh_destpoint, destpoint_name, dest_addr, dest_addr2, dest_nmctst, ivh_invoicestatus, ivh_origincity, 
			ivh_destcity, ivh_originstate, ivh_deststate, ivh_originregion1, ivh_destregion1, ivh_supplier, ivh_shipdate, ivh_deliverydate, 
			ivh_revtype1, ivh_revtype2, ivh_revtype3, ivh_revtype4, ivh_totalweight, ivh_totalpieces, ivh_totalmiles, ivh_currency, 
			ivh_currencydate, ivh_totalvolume, ivh_taxamount1, ivh_taxamount2, ivh_taxamount3, ivh_taxamount4, ivh_transtype, 
			ivh_creditmemo, ivh_applyto, ivh_printdate, ivh_billdate, ivh_lastprintdate, ivh_originregion2, ivh_originregion3, 
			ivh_originregion4, ivh_destregion2, ivh_destregion3, ivh_destregion4, mfh_hdrnumber, ivh_remark, ivh_driver, ivh_tractor, 
			ivh_trailer, ivh_user_id1, ivh_user_id2, ivh_ref_number, ivh_driver2, mov_number, ivh_edi_flag, ord_hdrnumber, ivd_number, 
			stp_number, ivd_description, cht_itemcode, ivd_quantity, ivd_rate, ivd_charge, ivd_taxable1, ivd_taxable2, ivd_taxable3, 
			ivd_taxable4, ivd_unit, cur_code, ivd_currencydate, ivd_glnum, ivd_type, ivd_rateunit, ivd_billto, ivd_billto_name, 
			ivd_billto_addr, ivd_billto_addr2, ivd_billto_nmctst, ivd_itemquantity, ivd_subtotalptr, ivd_allocatedrev, ivd_sequence, 
			ivd_refnum, cmd_code, cmp_id, stop_name, stop_addr, stop_addr2, stop_nmctst, ivd_distance, ivd_distunit, ivd_wgt, 
			ivd_wgtunit, ivd_count, ivd_countunit, evt_number, ivd_reftype, ivd_volume, ivd_volunit, ivd_orig_cmpid, ivd_payrevenue, 
			ivh_freight_miles, tar_tarriffnumber, tar_tariffitem, @counter AS Expr1, cht_basis, cht_description, cmd_name, cmp_altid, 
			ivh_hideshipperaddr, ivh_hideconsignaddr, ivh_showshipper, ivh_showcons, terms_name, ISNULL(ivh_charge, 0) 
			AS ivh_charge, ivh_billto_addr3, cmp_contact, shipper_geoloc, cons_geoloc
	FROM        [#invtemp_tbl_final]
	WHERE    (copies = 1)     
 END   
                                                                
ERROR_END:  
/* FINAL SELECT - FORMS RETURN SET */  
SELECT   --WorkGroup, cht_itemcode, ivd_rate, ivd_number, ivd_sequence,
	ivh_invoicenumber, ivh_hdrnumber, ivh_billto, ivh_billto_name, ivh_billto_addr, ivh_billto_addr2, ivh_billto_nmctst, ivh_terms, 
        ivh_totalcharge, ivh_shipper, shipper_name, shipper_addr, shipper_addr2, shipper_nmctst, ivh_consignee, consignee_name, 
        consignee_addr, consignee_addr2, consignee_nmctst, ivh_originpoint, originpoint_name, origin_addr, origin_addr2, 
        origin_nmctst, ivh_destpoint, destpoint_name, dest_addr, dest_addr2, dest_nmctst, ivh_invoicestatus, ivh_origincity, 
        ivh_destcity, ivh_originstate, ivh_deststate, ivh_originregion1, ivh_destregion1, ivh_supplier, ivh_shipdate, ivh_deliverydate, 
        ivh_revtype1, ivh_revtype2, ivh_revtype3, ivh_revtype4, ivh_totalweight, ivh_totalpieces, ivh_totalmiles, ivh_currency, 
        ivh_currencydate, ivh_totalvolume, ivh_taxamount1, ivh_taxamount2, ivh_taxamount3, ivh_taxamount4, ivh_transtype, 
        ivh_creditmemo, ivh_applyto, ivh_printdate, ivh_billdate, ivh_lastprintdate, ivh_originregion2, ivh_originregion3, 
        ivh_originregion4, ivh_destregion2, ivh_destregion3, ivh_destregion4, mfh_hdrnumber, ivh_remark, ivh_driver, ivh_tractor, 
        ivh_trailer, ivh_user_id1, ivh_user_id2, ivh_ref_number, ivh_driver2, mov_number, ivh_edi_flag, ord_hdrnumber, ivd_number, 
        stp_number, ivd_description, cht_itemcode, ivd_quantity, ivd_rate, ivd_charge, ivd_taxable1, ivd_taxable2, ivd_taxable3, 
        ivd_taxable4, ivd_unit, cur_code, ivd_currencydate, ivd_glnum, ivd_type, ivd_rateunit, ivd_billto, ivd_billto_name, 
        ivd_billto_addr, ivd_billto_addr2, ivd_billto_nmctst, ivd_itemquantity, ivd_subtotalptr, ivd_allocatedrev, ivd_sequence, 
        ivd_refnum, cmd_code, cmp_id, stop_name, stop_addr, stop_addr2, stop_nmctst, ivd_distance, ivd_distunit, ivd_wgt, 
        ivd_wgtunit, ivd_count, ivd_countunit, evt_number, ivd_reftype, ivd_volume, ivd_volunit, ivd_orig_cmpid, ivd_payrevenue, 
        ivh_freight_miles, tar_tarriffnumber, tar_tariffitem, copies, cht_basis, cht_description, cmd_name, cmp_altid, ivh_showshipper, 
        ivh_showcons, terms_name, ivh_billto_addr3, cmp_contact, shipper_geoloc, cons_geoloc
FROM	[#invtemp_tbl_final]  

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 SELECT @ret_value = @@ERROR   
RETURN @ret_value  
  
GO
GRANT EXECUTE ON  [dbo].[invoice_template83] TO [public]
GO
