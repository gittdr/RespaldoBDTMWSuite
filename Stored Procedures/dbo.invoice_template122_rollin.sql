SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[invoice_template122_rollin] (@invoice_nbr  	int,@copies int)
AS
/*
*
* 
* NAME:invoice_template122_rollin
* dbo.invoice_template122_rollin
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* original, copied from invoice_template35_rollin, then Format 122 
* changes applied.  
*
* RETURNS:
* 0 - IF NO DATA WAS FOUND  
* 1 - IF SUCCESFULLY EXECUTED  
* @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
*
* RESULT SETS: 
* See Select Below.
*
* PARAMETERS:
* 001 - @invoice_nbr, int, input, NULL;
*       Invoice number
* 002 - @copies, int, input, NULL;
*       number of copies to print
* REFERENCES: (called by AND calling references only, don't 
*              include table/view/object references)
* N/A
* 
* 
* 
* REVISION HISTORY:
* 06/25/07 PTS 36796 - OS - Created
 * 7/14/08 Michalynn changes proc to return VIN for order not freight
*/
DECLARE @temp_name varchar(100),
	@temp_addr varchar(50),
	@temp_addr2 varchar(50),
	@temp_nmstct varchar(36),
	@temp_altid  varchar(8),
	@counter int,
	@ret_value int,
	@temp_terms	varchar(20),
	@temp_refnum	varchar(17)

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
SELECT @ret_value = 1

/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET 
	NOTE: 'COPY' - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/
SELECT ivh.ivh_invoicenumber, 
	ivh.ivh_hdrnumber, 
    ivh.ivh_billto, 
    @temp_name ivh_billto_name, 
    @temp_addr ivh_billto_addr, 
    @temp_addr2 ivh_billto_addr2, 
    @temp_nmstct ivh_billto_nmctst, 
    ivh.ivh_terms, 
    ivh.ivh_totalcharge, 
    ivh.ivh_shipper, 
    @temp_name shipper_name, 
    @temp_addr shipper_addr, 
    @temp_addr2 shipper_addr2, 
    @temp_nmstct shipper_nmctst, 
    ivh.ivh_consignee, 
    @temp_name consignee_name, 
    @temp_addr consignee_addr, 
    @temp_addr2 consignee_addr2, 
    @temp_nmstct consignee_nmctst, 
    ivh.ivh_originpoint, 
    @temp_name originpoint_name, 
    @temp_addr origin_addr, 
    @temp_addr2 origin_addr2, 
    @temp_nmstct origin_nmctst, 
    ivh.ivh_destpoint, 
    @temp_name destpoint_name, 
    @temp_addr dest_addr, 
    @temp_addr2 dest_addr2, 
    @temp_nmstct dest_nmctst, 
    ivh.ivh_invoicestatus, 
    ivh.ivh_origincity, 
    ivh.ivh_destcity, 
    ivh.ivh_originstate, 
    ivh.ivh_deststate, 
    ivh.ivh_originregion1, 
    ivh.ivh_destregion1, 
    ivh.ivh_supplier, 
    ivh.ivh_shipdate, 
    ivh.ivh_deliverydate, 
    isnull(l.name, 'UNKNOWN') ivh_revtype1, 
    ivh.ivh_revtype2, 
    ivh.ivh_revtype3, 
    ivh.ivh_revtype4, 
    ivh.ivh_totalweight, 
    ivh.ivh_totalpieces, 
    ivh.ivh_totalmiles, 
    ivh.ivh_currency, 
    ivh.ivh_currencydate, 
    ivh.ivh_totalvolume, 
    ivh.ivh_taxamount1, 
    ivh.ivh_taxamount2, 
    ivh.ivh_taxamount3, 
    ivh.ivh_taxamount4, 
    ivh.ivh_transtype, 
    ivh.ivh_creditmemo, 
    ivh.ivh_applyto, 
    ivh.ivh_printdate, 
    ivh.ivh_billdate, 
    ivh.ivh_lastprintdate, 
    ivh.ivh_originregion2, 
    ivh.ivh_originregion3, 
    ivh.ivh_originregion4, 
    ivh.ivh_destregion2, 
    ivh.ivh_destregion3, 
    ivh.ivh_destregion4, 
    ivh.mfh_hdrnumber, 
    ivh.ivh_remark, 
    ivh.ivh_driver, 
    ivh.ivh_tractor, 
    ivh.ivh_trailer, 
    ivh.ivh_user_id1, 
    ivh.ivh_user_id2, 
    ivh.ivh_ref_number, 
    ivh.ivh_driver2, 
    ivh.mov_number, 
    ivh.ivh_edi_flag, 
    ivh.ord_hdrnumber, 
    ivd.ivd_number, 
    ivd.stp_number, 
    ivd.ivd_description, 
    ivd.cht_itemcode, 
    ivd.ivd_quantity, 
    ivd.ivd_rate, 
    ivd.ivd_charge, 
    ivd.ivd_taxable1, 
    ivd.ivd_taxable2, 
    ivd.ivd_taxable3, 
    ivd.ivd_taxable4, 
    ivd.ivd_unit, 
    ivd.cur_code, 
    ivd.ivd_currencydate, 
    ivd.ivd_glnum, 
    ivd.ivd_type, 
    ivd.ivd_rateunit, 
    ivd.ivd_billto, 
    @temp_name ivd_billto_name, 
    @temp_addr ivd_billto_addr, 
    @temp_addr2 ivd_billto_addr2, 
    @temp_nmstct ivd_billto_nmctst, 
    ivd.ivd_itemquantity, 
    ivd.ivd_subtotalptr, 
    ivd.ivd_allocatedrev, 
    ivd.ivd_sequence, 
    ivd.ivd_refnum, 
    ivd.cmd_code, 
    ivd.cmp_id, 
    @temp_name stop_name, 
    @temp_addr stop_addr, 
    @temp_addr2 stop_addr2, 
    @temp_nmstct stop_nmctst, 
    ivd.ivd_distance, 
    ivd.ivd_distunit, 
    ivd.ivd_wgt, 
    ivd.ivd_wgtunit, 
    ivd.ivd_count, 
    ivd.ivd_countunit, 
    ivd.evt_number, 
    ivd.ivd_reftype, 
    ivd.ivd_volume, 
    ivd.ivd_volunit,
    ivd.ivd_orig_cmpid, 
    ivd.ivd_payrevenue, 
    ivh.ivh_freight_miles, 
    ivh.tar_tarriffnumber,
    ivh.tar_tariffitem, 
    1 copies, 
    cht.cht_basis, 
    cht.cht_description,
    cmd.cmd_name,
    @temp_altid  cmp_altid,
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	(Case ivh_showshipper 
	when 'UNKNOWN' then ivh.ivh_shipper
	else IsNull(ivh_showshipper,ivh.ivh_shipper) 
	end) ivh_showshipper,
	(Case ivh_showcons 
	when 'UNKNOWN' then ivh.ivh_consignee
	else IsNull(ivh_showcons,ivh.ivh_consignee) 
	end) ivh_showcons,
	@temp_terms terms_name,
	ivh.ivh_carrier,
	IsNull(ivh_charge,0.0) ivh_charge,
	ivh_revtype3_t = 'RevType3',
	@temp_refnum vin_number,
	ivd.fgt_number,
	la.name revtype3_name      
INTO #invtemp_tbl 
FROM invoiceheader ivh join invoicedetail ivd on ivd.ivh_hdrnumber = ivh.ivh_hdrnumber 
	join chargetype cht on cht.cht_itemcode = ivd.cht_itemcode 
	left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code 
	left outer join labelfile l on l.abbr = ivh.ivh_revtype1
	join labelfile la on la.abbr = ivh.ivh_revtype3 and la.labeldefinition = 'RevType3'     
WHERE (IsNull(ivd.cht_rollintolh,0) = 0) 
and ivh.ivh_hdrnumber = @invoice_nbr 
and	l.labeldefinition = 'RevType1'
	
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
IF (SELECT COUNT(*) FROM #invtemp_tbl) = 0
BEGIN
     SELECT @ret_value = 0 
     GOTO ERROR_END 
END

SELECT ivd.ivh_hdrnumber, 
	SUM(ivd.ivd_rate) rate, 
    SUM(ivd.ivd_charge) charge 
INTO #invtemp_tbl2 
FROM invoiceheader ivh join invoicedetail ivd on ivh.ivh_hdrnumber = ivd.ivh_hdrnumber
	join chargetype cht on cht.cht_itemcode = ivd.cht_itemcode 
WHERE (IsNull(ivd.cht_rollintolh,0) = 1) 
and ivh.ivh_hdrnumber = @invoice_nbr 
GROUP BY ivd.ivh_hdrnumber

IF (SELECT COUNT(*) FROM #invtemp_tbl2) > 0	
UPDATE #invtemp_tbl 
SET #invtemp_tbl.ivd_rate = #invtemp_tbl.ivd_rate + #invtemp_tbl2.rate,
    #invtemp_tbl.ivd_charge = #invtemp_tbl.ivd_charge + #invtemp_tbl2.charge 
FROM #invtemp_tbl2 join #invtemp_tbl on #invtemp_tbl.ivh_hdrnumber = #invtemp_tbl2.ivh_hdrnumber 
	join chargetype on #invtemp_tbl.cht_itemcode = chargetype.cht_itemcode
WHERE chargetype.cht_basisunit = 'FLT'
and	chargetype.cht_primary = 'Y'

If Not Exists (Select cmp_mailto_name From company c join #invtemp_tbl t on c.cmp_id = t.ivh_billto 
	Where Rtrim(IsNull(cmp_mailto_name,'')) > ''
	And t.ivh_terms in (c.cmp_mailto_crterm1,	c.cmp_mailto_crterm2,	c.cmp_mailto_crterm3,	
	Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)
	And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End)
	
update #invtemp_tbl
set ivh_billto_name = company.cmp_name,
	ivh_billto_addr = company.cmp_address1,
	ivh_billto_addr2 = company.cmp_address2,		
	ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip,
	#invtemp_tbl.cmp_altid = company.cmp_altid 
from #invtemp_tbl join company on company.cmp_id = #invtemp_tbl.ivh_billto

Else	
update #invtemp_tbl
set ivh_billto_name = company.cmp_mailto_name,
	ivh_billto_addr = company.cmp_mailto_address1,
	ivh_billto_addr2 = company.cmp_mailto_address2,		
	ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct)))+ ' ' + company.cmp_mailto_zip,
	#invtemp_tbl.cmp_altid = company.cmp_altid 	
from #invtemp_tbl join company on company.cmp_id = #invtemp_tbl.ivh_billto

UPDATE #invtemp_tbl 
SET originpoint_name = cmp.cmp_name, 
    origin_addr = cmp.cmp_address1, 
    origin_addr2 = cmp.cmp_address2, 
    origin_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct))) + ' ' + ISNULL(city.cty_zip,'')
FROM #invtemp_tbl join company cmp on cmp.cmp_id = #invtemp_tbl.ivh_originpoint 
	join city on city.cty_code = #invtemp_tbl.ivh_origincity  

UPDATE #invtemp_tbl 
SET destpoint_name = cmp.cmp_name, 
    dest_addr = cmp.cmp_address1, 
    dest_addr2 = cmp.cmp_address2, 
    dest_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct))) + ' ' + ISNULL(city.cty_zip,'') 
FROM #invtemp_tbl join company cmp on cmp.cmp_id = #invtemp_tbl.ivh_destpoint
	join city on city.cty_code = #invtemp_tbl.ivh_destcity

UPDATE #invtemp_tbl 
SET shipper_name = cmp.cmp_name, 
    shipper_addr = Case ivh_hideshipperaddr when 'Y' 
	then ''
	else cmp.cmp_address1
	end,
	shipper_addr2 = Case ivh_hideshipperaddr when 'Y' 
	then ''
	else cmp.cmp_address2
	end,
    shipper_nmctst = substring(cmp.cty_nmstct,1, (charindex('/', cmp.cty_nmstct))) + ' ' + cmp.cmp_zip 
FROM #invtemp_tbl join company cmp on cmp.cmp_id = #invtemp_tbl.ivh_showshipper  

UPDATE #invtemp_tbl 
SET shipper_nmctst = origin_nmctst
WHERE ivh_shipper  = 'UNKNOWN'

UPDATE #invtemp_tbl 
SET consignee_name = cmp.cmp_name, 
    consignee_addr = Case ivh_hideconsignaddr when 'Y' 
	then ''
	else cmp.cmp_address1
	end,			 
	consignee_addr2 = Case ivh_hideconsignaddr when 'Y' 
	then ''
	else cmp.cmp_address2
	end, 
    consignee_nmctst = substring(cmp.cty_nmstct,1, (charindex('/', cmp.cty_nmstct))) + ' ' + cmp.cmp_zip 
FROM #invtemp_tbl join company cmp on cmp.cmp_id = #invtemp_tbl.ivh_showcons  

UPDATE #invtemp_tbl 
SET consignee_nmctst = dest_nmctst
WHERE ivh_consignee   = 'UNKNOWN'

UPDATE #invtemp_tbl 
SET stop_name = cmp.cmp_name, 
    stop_addr = cmp.cmp_address1, 
    stop_addr2 = cmp.cmp_address2 
FROM #invtemp_tbl join company cmp on cmp.cmp_id = #invtemp_tbl.cmp_id  

-- dpete for UNKNOWN companies with cities must get city name from city table	pts5319	
update #invtemp_tbl
set stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct)))+ ' ' +city.cty_zip 
from #invtemp_tbl join stops on stops.stp_number =  #invtemp_tbl.stp_number
	left outer join city on city.cty_code = stops.stp_city
where #invtemp_tbl.stp_number IS NOT NULL

update #invtemp_tbl
set terms_name = la.name
from labelfile la
where la.labeldefinition = 'creditterms' 
and la.abbr = #invtemp_tbl.ivh_terms

--VIN#
UPDATE #invtemp_tbl
SET #invtemp_tbl.vin_number = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.ord_hdrnumber
AND r.ref_table = 'orderheader'
AND r.ref_type = 'VIN'  

/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */
SELECT @counter = 1

WHILE @counter <> @copies
BEGIN
	SELECT @counter = @counter + 1
    INSERT INTO #invtemp_tbl 
	SELECT ivh_invoicenumber, 
		ivh_hdrnumber, 
        ivh_billto, 
        ivh_billto_name, 
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
        ivh_originpoint,		--20 
        originpoint_name, 
        origin_addr, 
        origin_addr2, 
        origin_nmctst, 
        ivh_destpoint, 
        destpoint_name, 
        dest_addr, 
        dest_addr2, 
        dest_nmctst, 
        ivh_invoicestatus,		--30 
        ivh_origincity, 
        ivh_destcity, 
        ivh_originstate, 
        ivh_deststate, 
        ivh_originregion1, 
        ivh_destregion1, 
        ivh_supplier, 
        ivh_shipdate, 
        ivh_deliverydate, 
        ivh_revtype1,		--40 
        ivh_revtype2, 
        ivh_revtype3, 
        ivh_revtype4, 
        ivh_totalweight, 
        ivh_totalpieces, 
        ivh_totalmiles, 
        ivh_currency, 
        ivh_currencydate, 
        ivh_totalvolume, 
        ivh_taxamount1,		--50 
        ivh_taxamount2, 
        ivh_taxamount3, 
        ivh_taxamount4, 
        ivh_transtype, 
        ivh_creditmemo, 
        ivh_applyto, 
        ivh_printdate, 
        ivh_billdate, 
        ivh_lastprintdate, 
        ivh_originregion2,		--60 
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
        ivd_description,		--80 
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
        ivd_itemquantity,		--100 
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
        ivd_volunit,		--120 
        ivd_orig_cmpid, 
        ivd_payrevenue, 
        ivh_freight_miles, 
        tar_tarriffnumber, 
        tar_tariffitem, 
        @counter, 
        cht_basis, 
        cht_description, 
        cmd_name,
		cmp_altid,		--130
		ivh_hideshipperaddr,
		ivh_hideconsignaddr,
		ivh_showshipper,
		ivh_showcons,
		terms_name,
		ivh_carrier,
		ivh_charge,
		ivh_revtype3_t,
		vin_number,
		fgt_number,
		revtype3_name  
	FROM #invtemp_tbl 
	WHERE copies = 1 
END


ERROR_END:

/* FINAL SELECT - FORMS RETURN SET */
SELECT ivh_invoicenumber, 
	ivh_hdrnumber, 
    ivh_billto, 
    ivh_billto_name, 
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
    ivh_originpoint,		--20 
    originpoint_name, 
    origin_addr, 
    origin_addr2, 
    origin_nmctst, 
    ivh_destpoint, 
    destpoint_name, 
    dest_addr, 
    dest_addr2, 
    dest_nmctst, 
    ivh_invoicestatus,		--30 
    ivh_origincity, 
    ivh_destcity, 
    ivh_originstate, 
    ivh_deststate, 
    ivh_originregion1, 
    ivh_destregion1, 
    ivh_supplier, 
    ivh_shipdate, 
    ivh_deliverydate, 
    ivh_revtype1,		--40 
    ivh_revtype2, 
    ivh_revtype3, 
    ivh_revtype4, 
    ivh_totalweight, 
    ivh_totalpieces, 
    ivh_totalmiles, 
    ivh_currency, 
    ivh_currencydate, 
    ivh_totalvolume, 
    ivh_taxamount1,		--50 
    ivh_taxamount2, 
    ivh_taxamount3, 
    ivh_taxamount4, 
    ivh_transtype, 
    ivh_creditmemo, 
    ivh_applyto, 
    ivh_printdate, 
    ivh_billdate, 
    ivh_lastprintdate, 
    ivh_originregion2,		--60 
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
    ivd_description,		--80 
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
    ivd_itemquantity,		--100 
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
    ivd_volunit,		--120 
    ivd_orig_cmpid, 
    ivd_payrevenue, 
    ivh_freight_miles, 
    tar_tarriffnumber, 
    tar_tariffitem, 
	copies,
    cht_basis, 
    cht_description, 
    cmd_name,
	cmp_altid,		--130
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	ivh_showshipper,
	ivh_showcons,
	terms_name,
	ivh_carrier,
	ivh_charge,
	ivh_revtype3_t,
	vin_number,
	fgt_number,
	revtype3_name  
FROM #invtemp_tbl 

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0
SELECT @ret_value = @@ERROR 
RETURN @ret_value

GO
GRANT EXECUTE ON  [dbo].[invoice_template122_rollin] TO [public]
GO
