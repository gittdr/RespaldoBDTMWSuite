SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[invoice_template111] (@invoice_nbr   int, @copies  	int)  
AS  

/*
 * 
 * NAME:dbo.invoice_template111
 * 
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoices details
 * based on the invoice selected.
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
 * 001 - @invoice_nbr, int, input, null;
 *       Invoice number
 * 002 - @copies, int, input, null;
 *       number of copies to print
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/15/2007 - PTS 36191 - Eric Kelly - Created 
 * 04/27/2007 - PTS 36191 - Eric Kelly - Changed IMP,PO and HWE refnumbers to pull from freightdetail
 * 05/18/2007 - PTS 37591 - Eric Kelly - Added more robust retrieval for when shipper or commodity is changed.
 **/

DECLARE	@temp_name	varchar(100),  
 	@temp_addr		varchar(100),  
	@temp_zip		varchar(10),
	@temp_nmstct	varchar(30),  
	@temp_refnum	varchar(30),  
	@first_pup 		varchar (8),
	@temp_int		int,
 	@ret_value  	int,
	@counter    	int,
	--PTS 37591 EMK
	@ord_shipper	varchar(8), 
	@ivh_shipper	varchar(8)

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  

SET @ret_value = 1  

/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  

--PTS 37591 EMK 
SELECT @ord_shipper = o.ord_shipper FROM orderheader o 
	JOIN invoiceheader i ON o.ord_hdrnumber = i.ord_hdrnumber
	WHERE ivh_hdrnumber = @invoice_nbr

SELECT @ivh_shipper = invoiceheader.ivh_shipper FROM invoiceheader 
	WHERE ivh_hdrnumber = @invoice_nbr 
--PTS 37591 EMK 

SELECT ivh.ivh_invoicenumber,     
	ivh.ivh_hdrnumber,
	ivh.ord_hdrnumber,
	ivh.mov_number,
	ivh.ivh_billdate,
    ivh.ivh_shipdate,    
	ivh.ivh_billto,
	ivh.ivh_driver,
	cmp_billto.cmp_name billto_name,  
	cmp_billto.cmp_address1 billto_addr1,  
	cmp_billto.cmp_address2 billto_addr2,           
	cmp_billto.cmp_zip billto_zip,
	CASE charindex('/', cmp_billto.cty_nmstct)
		WHEN 0 THEN cmp_billto.cty_nmstct + IsNull(cmp_billto.cmp_zip,'') 
		ELSE substring(cmp_billto.cty_nmstct,1, (charindex('/', cmp_billto.cty_nmstct)-1))+ ' ' + IsNull(cmp_billto.cmp_zip,'')
	END  billto_nmstct,
	ord.ord_bookedby ord_bookedby,
	ord.ord_number ord_number,
	ord.ord_remark ord_remark,
	ivd.cmp_id stop_id,
	cmp_stop.cmp_name stop_name,  
	cmp_stop.cmp_address1 stop_addr1,  
	cmp_stop.cmp_address2 stop_addr2,           
	cmp_stop.cmp_zip stop_zip,
	CASE charindex('/', cmp_stop.cty_nmstct)
		WHEN 0 THEN cmp_stop.cty_nmstct + IsNull(cmp_stop.cmp_zip,'') 
		ELSE substring(cmp_stop.cty_nmstct,1, (charindex('/', cmp_stop.cty_nmstct)-1))+ ' ' + IsNull(cmp_stop.cmp_zip,'')
	END  stop_nmstct,
	--fgt.fgt_number,
	ivd.fgt_number,
--PTS 37591 EMK 
	--fgt.fgt_shipper shipper_id,
	CASE fgt_shipper 
		WHEN 'UNKNOWN' THEN fgt_shipper
		WHEN @ord_shipper THEN @ivh_shipper
		ELSE fgt_shipper
	END shipper_id,
--PTS 37591 EMK 
	@temp_name shipper_name,
	@temp_addr shipper_addr1,  
	@temp_addr shipper_addr2,           
	@temp_zip shipper_zip,
	@temp_nmstct shipper_nmstct,
	chargetype.cht_itemcode,
	chargetype.cht_basis,  
	chargetype.cht_description,	
	--Reference numbers
	@temp_refnum delivery_po,
 	@temp_refnum delivery_hwe,
	@temp_refnum pickup_imp,
	@temp_refnum bol,
	@temp_refnum bol2,
	@temp_refnum bol3,
	stp.stp_event stp_event,
	ivd.ivd_type,
	ivd.ivd_sequence,     
	ivd.ivd_refnum,   
	ivd.stp_number,
    ivd.ivd_number,
	ivd.ivd_charge,
	ivd.ivd_quantity,     
	ivd.ivd_rate, 
	ivd.ivd_rateunit, 
	ivd.ivd_rate_type,     
	ivd.ivd_volume,     
	ivd.ivd_volunit,
	ivd.ivd_count,     
	ivd.ivd_countunit,   
	ivd.cmd_code,
	ivd.ivd_description,        
	stp.stp_mfh_sequence stp_mfh_sequence,
	@temp_int pickup_stp_number,
	1 copies,
	ivd.ivd_unit,
	ivd.ivd_wgt,
	ivd.ivd_wgtunit,
	ivh.ivh_user_id1,
	ivh.ivh_totalmiles,
	ivh.ivh_remark
INTO #invtemp_tbl 
 
FROM invoiceheader ivh
	JOIN company cmp_billto ON ivh.ivh_billto = cmp_billto.cmp_id	
	JOIN invoicedetail ivd ON ivh.ivh_hdrnumber = ivd.ivh_hdrnumber
	JOIN orderheader ord ON ivh.ord_hdrnumber = ord.ord_hdrnumber
	JOIN company cmp_stop ON ivd.cmp_id = cmp_stop.cmp_id
	LEFT OUTER JOIN stops stp ON stp.stp_number = ivd.stp_number   -- USE FOR ACC TOO
	LEFT OUTER JOIN freightdetail fgt ON ivd.fgt_number = fgt.fgt_number
	JOIN chargetype ON ivd.cht_itemcode = chargetype.cht_itemcode
  WHERE ivh.ivh_hdrnumber = @invoice_nbr
	AND ivd.ivd_type <> 'PUP'

/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
IF (select count(*) from #invtemp_tbl) = 0 BEGIN
	SELECT @ret_value = 0    
	GOTO ERROR_END  
END


--PTS 37591 EMK - Changed logic for shipper consignee pairings.  
-- UPDATE SHIPPER FIELDS
--
-- For null shippers, fill in the stop with the first commodity

CREATE TABLE #stptemp_tbl
			( cmd_code varchar(8) null,
			cmp_id varchar(8) null,
			stp_number int null,
			stp_mfh_sequence int null)

IF (SELECT count(*)  FROM stops stp JOIN invoiceheader ivh ON stp.mov_number = ivh.mov_number
		WHERE ivh.ivh_hdrnumber = @invoice_nbr AND stp_type = 'PUP' AND ivh.ord_hdrnumber = stp.ord_hdrnumber) = 1
	BEGIN
	--If only one pickup, assume all commodities from there
		INSERT INTO #stptemp_tbl(cmd_code,cmp_id,stp_number,stp_mfh_sequence)
		--SELECT f.cmd_code,cmp_id,stp.stp_number,stp_mfh_sequence
		SELECT ivd.cmd_code,ivh.ivh_shipper cmp_id,ivd.stp_number,1   
			FROM invoicedetail ivd, invoiceheader ivh	
			WHERE ivd.ivh_hdrnumber = @invoice_nbr
				and ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
				and cmd_code <> 'UNKNOWN'
	END
ELSE
	BEGIN
		-- Get first pickups with a particular commodity
		INSERT INTO #stptemp_tbl(cmd_code,cmp_id,stp_number,stp_mfh_sequence)
		SELECT fgt.cmd_code,cmp_id,stp.stp_number,stp_mfh_sequence 
		FROM stops stp 
			JOIN invoiceheader ivh ON stp.mov_number = ivh.mov_number
			JOIN freightdetail fgt ON stp.stp_number = fgt.stp_number
		WHERE ivh.ivh_hdrnumber = @invoice_nbr
			AND stp_type = 'PUP'
	END
--PTS 37591 EMK - Changed logic for shipper consignee pairings.  

-- shiptemp_tbl has commodity, first shipper pairing
SELECT s.cmd_code,s.cmp_id,s.stp_number 
INTO #shiptemp_tbl 
FROM #stptemp_tbl s
	JOIN (SELECT  cmd_code,MIN(stp_mfh_sequence) min_seq FROM #stptemp_tbl GROUP BY cmd_code) m1
ON m1.cmd_code = s.cmd_code and m1.min_seq = s.stp_mfh_sequence

-- Make the update to shipper_id that are null or not in the list of company pickup
UPDATE #invtemp_tbl 
SET #invtemp_tbl .shipper_id = s.cmp_id
FROM #invtemp_tbl i 
	JOIN #shiptemp_tbl s ON i.cmd_code = s.cmd_code
	JOIN company c ON s.cmp_id = c.cmp_id
WHERE i.ivd_type = 'DRP'
	AND (shipper_id IS NULL OR shipper_id NOT IN (SELECT distinct cmp_id 
								FROM stops stp JOIN #invtemp_tbl ON stp.mov_number = #invtemp_tbl.mov_number 
								WHERE #invtemp_tbl.ivh_hdrnumber = @invoice_nbr 
								AND stp_type = 'PUP'))
--EMK
-- Set the shipper info
UPDATE #invtemp_tbl 
SET #invtemp_tbl.shipper_name = c.cmp_name, 
	#invtemp_tbl.shipper_addr1 = c.cmp_address1, 
	#invtemp_tbl.shipper_addr2 = c.cmp_address2, 
	#invtemp_tbl.shipper_zip = c.cmp_zip, 
	#invtemp_tbl.shipper_nmstct = 	
		CASE charindex('/', c.cty_nmstct)
			WHEN 0 THEN c.cty_nmstct + IsNull(c.cmp_zip,'') 
			ELSE substring(c.cty_nmstct,1, (charindex('/', c.cty_nmstct)-1))+ ' ' + IsNull(c.cmp_zip,'')
		END
FROM #invtemp_tbl i 
JOIN company c ON i.shipper_id = c.cmp_id
WHERE i.ivd_type = 'DRP'

--Update stp number
UPDATE #invtemp_tbl 
SET #invtemp_tbl.pickup_stp_number = sn1.stp_number
FROM #invtemp_tbl
JOIN (SELECT distinct cmp_id,stp.stp_number 
	FROM stops stp 
	JOIN #invtemp_tbl ON stp.mov_number = #invtemp_tbl.mov_number 
WHERE #invtemp_tbl.ivh_hdrnumber = @invoice_nbr
AND stp_type = 'PUP') sn1 ON sn1.cmp_id = #invtemp_tbl.shipper_id

drop table #shiptemp_tbl

--
-- REFERENCE NUMBERS 
--

-- 4/27/07 EMK - PO, DELT# and IMP# Changed from stops to freightdetail

--PO
UPDATE #invtemp_tbl
SET #invtemp_tbl.delivery_po = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.fgt_number
	 AND r.ref_table = 'freightdetail'
	 AND r.ref_type = 'PO'

--HWE Ticket (DELT#)
UPDATE #invtemp_tbl
SET #invtemp_tbl.delivery_hwe = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.fgt_number
	 AND r.ref_table = 'freightdetail'
	 AND r.ref_type = 'DELT#'

--Import # (IMP#)
UPDATE #invtemp_tbl
SET #invtemp_tbl.pickup_imp = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.fgt_number
	 AND r.ref_table = 'freightdetail'
	 AND r.ref_type = 'IMP#'	

--Bill of Lading (BL#)
UPDATE #invtemp_tbl
SET #invtemp_tbl.bol = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.fgt_number
	 AND r.ref_table = 'freightdetail'
	 AND r.ref_type = 'BL#'	

--Bill of Lading (BL#2)
UPDATE #invtemp_tbl
SET #invtemp_tbl.bol2 = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.fgt_number
	 AND r.ref_table = 'freightdetail'
	 AND r.ref_type = 'BL#2'	

--Bill of Lading (BL#3)
UPDATE #invtemp_tbl
SET #invtemp_tbl.bol3 = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.fgt_number
	 AND r.ref_table = 'freightdetail'
	 AND r.ref_type = 'BL#3'	

--Update Invoice Detail sequence for sorting accessorials and
-- put in dummy stop/shipper to group accessorials in one section.
UPDATE #invtemp_tbl
SET #invtemp_tbl.ivd_sequence = 
	CASE cht_itemcode
		WHEN 'MIN' THEN ivd_sequence + 2000
		WHEN 'FS' THEN ivd_sequence + 3000
		ELSE ivd_sequence + 1000
	END,
	#invtemp_tbl.stop_id = 'ZZZZZZ',
	#invtemp_tbl.shipper_id = 'ZZZZZZ'
WHERE cht_basis = 'ACC'
OR cht_basis = 'TAX' 
	
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */    
SELECT @counter = 1    
WHILE @counter <>  @copies    
BEGIN    
	SELECT @counter = @counter + 1   
	INSERT INTO #invtemp_tbl    
	SELECT     
		ivh_invoicenumber,     
		ivh_hdrnumber,
		ord_hdrnumber,
		mov_number,
		ivh_billdate,
		ivh_shipdate,    
		ivh_billto,
		ivh_driver,
		billto_name,  
		billto_addr1,  
		billto_addr2,           
		billto_zip,
		billto_nmstct,
		ord_bookedby,
		ord_number,
		ord_remark,
		stop_id,
		stop_name,  
		stop_addr1,  
		stop_addr2,           
		stop_zip,
		stop_nmstct,
		fgt_number,
		shipper_id,
		shipper_name,
		shipper_addr1,  
		shipper_addr2,           
		shipper_zip,
		shipper_nmstct,
		cht_itemcode,
		cht_basis,  
		cht_description,	
		delivery_po,
		delivery_hwe,
		pickup_imp,
		bol,
		bol2,
		bol3,
		stp_event,
		ivd_type,
		ivd_sequence,     
		ivd_refnum,   
		stp_number,
		ivd_number,
		ivd_charge,
		ivd_quantity,     
		ivd_rate, 
		ivd_rateunit, 
		ivd_rate_type,     
		ivd_volume,     
		ivd_volunit,
		ivd_count,     
		ivd_countunit,   
		cmd_code,
		ivd_description,        
		stp_mfh_sequence,
		pickup_stp_number,
		@counter,
		ivd_unit,
		ivd_wgt,
		ivd_wgtunit,
		ivh_user_id1,
		ivh_totalmiles,
		ivh_remark
	FROM #invtemp_tbl    
	WHERE copies = 1       
END     
                                                                  
ERROR_END:  
  
/* FINAL SELECT - FORMS RETURN SET */    
SELECT     
	ivh_invoicenumber,     
	ivh_hdrnumber,
	ord_hdrnumber,
	mov_number,
	ivh_billdate,
	ivh_shipdate,    
	ivh_billto,
	ivh_driver,
	billto_name,  
	billto_addr1,  
	billto_addr2,           
	billto_zip,
	billto_nmstct,
	ord_bookedby,
	ord_number,
	ord_remark,
	stop_id,
	stop_name,  
	stop_addr1,  
	stop_addr2,           
	stop_zip,
	stop_nmstct,
	fgt_number,
	shipper_id,
	shipper_name,
	shipper_addr1,  
	shipper_addr2,           
	shipper_zip,
	shipper_nmstct,
	cht_itemcode,
	cht_basis,  
	cht_description,	
	delivery_po,
	delivery_hwe,
	pickup_imp,
	bol,
	bol2,
	bol3,
	stp_event,
	ivd_type,
	ivd_sequence,     
	ivd_refnum,   
	stp_number,
	ivd_number,
	ivd_charge,
	ivd_quantity,     
	ivd_rate, 
	ivd_rateunit, 
	ivd_rate_type,     
	ivd_volume,     
	ivd_volunit,
	ivd_count,     
	ivd_countunit,   
	cmd_code,
	ivd_description,        
	stp_mfh_sequence,
	pickup_stp_number,
	copies,
	ivd_unit,
	ivd_wgt,
	ivd_wgtunit,
	ivh_user_id1,
	ivh_totalmiles,
	ivh_remark
FROM #invtemp_tbl  
ORDER BY ivd_sequence  
    
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */    
--IF @@ERROR != 0 select @ret_value = @@ERROR     
--return @ret_value 

drop table #invtemp_tbl


GO
GRANT EXECUTE ON  [dbo].[invoice_template111] TO [public]
GO
