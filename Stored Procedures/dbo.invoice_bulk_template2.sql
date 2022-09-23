SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[invoice_bulk_template2](@invoice_no_lo int,
	@invoice_no_hi int,
	@invoice_status	varchar(10),
	@revtype1 varchar(6),
	@revtype2 varchar(6),
	@revtype3 varchar(6),
	@revtype4 varchar(6),
	@billto varchar(8),
	@shipper varchar(8),
	@consignee varchar(8),
	@shipdate1 datetime,
	@shipdate2 datetime,
	@deldate1 datetime,
	@deldate2 datetime,
	@billdate1 datetime,
	@billdate2 datetime,
	@copies int,
	@queue_number int,
	@useasbillto varchar(3))
AS
/**
 * 
 * NAME:
 * dbo.invoice_bulk_template2
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 *      0 - IF NO DATA WAS FOUND
 *	1 - IF SUCCESFULLY EXECUTED
 *	@@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * Original: 11/18/97 wsc - pts#2532 added return data needed for Bulkmatic custom invoice
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 * 11/13/2007.01 ? PTS40188 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @temp_name varchar(30),
	@temp_addr varchar(30),
	@temp_addr2 varchar(30),
	@temp_nmstct varchar(30),
	@temp_contact varchar(30),
	@counter int,
	@ret_value int

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
SELECT @ret_value = 1,
	@temp_contact = ''

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
	ivh.ivh_revtype1,
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
	ord.ord_number,
	@temp_contact ivh_billto_contact
INTO #invtemp_tbl
--pts40188 jguo outer join conversion
FROM invoicedetail ivd  LEFT OUTER JOIN  chargetype cht  ON  ivd.cht_itemcode  = cht.cht_itemcode   
		LEFT OUTER JOIN  commodity cmd  ON  ivd.cmd_code  = cmd.cmd_code ,
	 invoiceheader ivh  LEFT OUTER JOIN  orderheader ord  ON  ivh.ord_hdrnumber  = ord.ord_hdrnumber  
WHERE (ivh.ivh_hdrnumber = ivd.ivh_hdrnumber)
AND (ivh.ivh_hdrnumber between @invoice_no_lo and @invoice_no_hi)
AND (@invoice_status  in ('ALL', ivh.ivh_invoicestatus))
AND (@revtype1 in('UNK', ivh.ivh_revtype1))
AND (@revtype2 in('UNK', ivh.ivh_revtype2))
AND (@revtype3 in('UNK', ivh.ivh_revtype3))
AND (@revtype4 in('UNK', ivh.ivh_revtype4))
AND (@billto in ('UNKNOWN', ivh.ivh_billto))
AND (@shipper in ('UNKNOWN', ivh.ivh_shipper))
AND (@consignee in ('UNKNOWN', ivh.ivh_consignee))
AND (ivh.ivh_shipdate between @shipdate1 and @shipdate2)
AND (ivh.ivh_deliverydate between @deldate1 and @deldate2)
AND ((ivh.ivh_billdate between @billdate1 and @billdate2)
OR (ivh.ivh_billdate IS null))
	
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
IF (SELECT COUNT(*) FROM #invtemp_tbl) = 0
	BEGIN
	SELECT @ret_value = 0  
	GOTO ERROR_END
	END

/* RETRIEVE COMPANY DATA */	                   			
IF @useasbillto = 'BLT'
	BEGIN

	UPDATE #invtemp_tbl
	SET ivh_billto_name = cmp.cmp_name,
		ivh_billto_addr = cmp.cmp_address1,
		ivh_billto_addr2 = cmp.cmp_address2,		
		ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', cmp.cty_nmstct)))+ ' ' + cmp.cmp_zip,
		ivh_billto_contact = cmp.cmp_contact
	FROM #invtemp_tbl, company cmp
	WHERE cmp.cmp_id = #invtemp_tbl.ivh_billto

	END			

IF @useasbillto = 'ORD'
	BEGIN

	UPDATE #invtemp_tbl
	SET ivh_billto_name = cmp.cmp_name,
		ivh_billto_addr = cmp.cmp_address1,
		ivh_billto_addr2 = cmp.cmp_address2,
		ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', cmp.cty_nmstct)))+ ' ' + cmp.cmp_zip,
		ivh_billto_contact = cmp.cmp_contact
	FROM #invtemp_tbl, company cmp, invoiceheader ivh
	WHERE #invtemp_tbl.ivh_hdrnumber = ivh.ivh_hdrnumber
	AND cmp.cmp_id = ivh.ivh_order_by

	END

IF @useasbillto = 'SHP'
	BEGIN

	UPDATE #invtemp_tbl
	SET ivh_billto_name = cmp.cmp_name,
		ivh_billto_addr = cmp.cmp_address1,
		ivh_billto_addr2 = cmp.cmp_address2,
		ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', cmp.cty_nmstct)))+ ' ' + cmp.cmp_zip,
		ivh_billto_contact = cmp.cmp_contact
	FROM #invtemp_tbl, company cmp
	WHERE cmp.cmp_id = #invtemp_tbl.ivh_shipper

	END
			
UPDATE #invtemp_tbl
SET originpoint_name = cmp.cmp_name,
	origin_addr = cmp.cmp_address1,
	origin_addr2 = cmp.cmp_address2,
	origin_nmctst = substring(cmp.cty_nmstct,1, (charindex('/', cmp.cty_nmstct)))+ ' ' +cmp.cmp_zip
FROM #invtemp_tbl, company cmp
WHERE cmp.cmp_id = #invtemp_tbl.ivh_originpoint
				
-- Get destination point company info				
UPDATE #invtemp_tbl
SET destpoint_name = cmp.cmp_name,
	dest_addr = cmp.cmp_address1,
	dest_addr2 = cmp.cmp_address2,
	dest_nmctst = substring(cmp.cty_nmstct,1, (charindex('/', cmp.cty_nmstct)))+ ' ' +cmp.cmp_zip
FROM #invtemp_tbl, company cmp
WHERE cmp.cmp_id = #invtemp_tbl.ivh_destpoint
				
-- Get shipper company info
UPDATE #invtemp_tbl
SET shipper_name = cmp.cmp_name,
	shipper_addr = cmp.cmp_address1,
	shipper_addr2 = cmp.cmp_address2,
	shipper_nmctst = substring(cmp.cty_nmstct,1, (charindex('/', cmp.cty_nmstct))) + ' ' + cmp.cmp_zip
FROM #invtemp_tbl, company cmp
WHERE cmp.cmp_id = #invtemp_tbl.ivh_shipper
				
-- Get consignee company info					
UPDATE #invtemp_tbl
SET consignee_name = cmp.cmp_name,
	 consignee_addr = cmp.cmp_address1,
	 consignee_addr2 = cmp.cmp_address2,
	 consignee_nmctst = substring(cmp.cty_nmstct,1, (charindex('/', cmp.cty_nmstct))) + ' ' + cmp.cmp_zip
FROM #invtemp_tbl, company cmp
WHERE cmp.cmp_id = #invtemp_tbl.ivh_consignee
					
-- Get stop company info
UPDATE #invtemp_tbl
SET stop_name = cmp.cmp_name,
	 stop_addr = cmp.cmp_address1,
	 stop_addr2 = cmp.cmp_address2,
	 stop_nmctst = substring(cmp.cty_nmstct,1, (charindex('/', cmp.cty_nmstct))) + ' ' + cmp.cmp_zip
FROM #invtemp_tbl, company cmp
WHERE cmp.cmp_id = #invtemp_tbl.cmp_id


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
		ord_number,
		ivh_billto_contact
	FROM #invtemp_tbl
	WHERE copies = 1   

	END
	                                                            	

ERROR_END:

/* FINAL SELECT - FORMS RETURN SET */
SELECT *
FROM #invtemp_tbl

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0
	SELECT @ret_value = @@ERROR 


RETURN @ret_value

GO
GRANT EXECUTE ON  [dbo].[invoice_bulk_template2] TO [public]
GO
