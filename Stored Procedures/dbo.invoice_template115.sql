SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[invoice_template115] (@invoice_nbr int, @copies int)  
AS  

/*
 * 
 * NAME:dbo.invoice_template115
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
 * 05/07/2007 - PTS 35717 - OS - Created 
 * 8/26/08 DPETE PTS 44168 return ivh_remark instead of ord_remark
 **/

DECLARE	@temp_name	varchar(100),  
 	@temp_addr		varchar(100),  
	@temp_zip		varchar(10),
	@temp_nmstct	varchar(30),
	@temp_city		varchar(30),
	@v_referencenumbers	varchar(32),
	@temp_rbol		varchar(31),
	@temp_refnum	varchar(30),  
	@first_pup 		varchar (8),
	@temp_int		int,
 	@ret_value  	int,
	@counter    	int,
	@v_next int,
	@ord_shipper	varchar(8), 
	@ivh_shipper	varchar(8)

Create table #invtemp_tbl (
ivh_invoicenumber varchar(12) null,     
ivh_hdrnumber int null,
ord_hdrnumber int null,
mov_number int null,
ivh_billdate datetime null,
ivh_shipdate datetime null,    
ivh_billto varchar(8) null,
ivh_driver varchar(8) null,
billto_name varchar(100) null,  
billto_addr1 varchar(100) null,  
billto_addr2 varchar(100) null,           
billto_zip varchar(10) null,
billto_nmstct varchar(30) null,
ord_bookedby varchar(20) null,
ord_number varchar(12) null,
ord_remark varchar(254) null,
stop_id varchar(8) null,
stop_name varchar(100) null,  
stop_addr1 varchar(100) null,  
stop_addr2 varchar(100) null,           
stop_zip varchar(10) null,
stop_nmstct varchar(30) null,
fgt_number int null,
shipper_id varchar(8) null,
shipper_name varchar(100) null,
shipper_addr1 varchar(100) null,  
shipper_addr2 varchar(100) null,           
shipper_zip varchar(10) null,
shipper_nmstct varchar(30) null,
cht_itemcode varchar(6) null,
cht_basis varchar(6) null,  
cht_description varchar(30) null,	
delivery_po varchar(30) null,
delivery_hwe varchar(30) null,
pickup_imp varchar(30) null,
bol varchar(30) null,
bol2 varchar(30) null,
bol3 varchar(30) null,
stp_event varchar(6) null,
ivd_type varchar(6) null,
ivd_sequence int null,     
ivd_refnum varchar(30) null,   
stp_number int null,
ivd_number int null,
ivd_charge money null,
ivd_quantity float null,     
ivd_rate money null, 
ivd_rateunit varchar(6) null, 
ivd_rate_type int null,     
ivd_volume float null,     
ivd_volunit varchar(6) null,
ivd_count decimal null,     
ivd_countunit varchar(6) null,   
cmd_code varchar(8) null,
ivd_description varchar(60) null,        
stp_mfh_sequence int null,
pickup_stp_number int null,
copies int null,
ivd_unit varchar(6) null,
ivd_wgt float null,
ivd_wgtunit varchar(6) null,
ivh_user_id1 varchar(20) null,
ivh_totalmiles float null,
ivh_remark varchar(254) null,
ivh_trailer varchar(13) null,
ivh_tractor varchar(8) null,
ivh_revtype1 varchar(6) null,
ord_shipper varchar(8) null,     
ord_shipper_name varchar(100) null,
ord_consignee varchar(8) null,     
ord_consignee_name varchar(100) null,
ord_consignee_city varchar(30) null,
ivh_deliverydate datetime null,
driver_name varchar(81) null,
mani varchar(30) null,
refnumbers varchar(32) null,
fgt_description varchar(60) null,
b4stk1 varchar(30) null,
afstk1 varchar(30) null,
b4stk2 varchar(30) null,
afstk2 varchar(30) null,
ivh_revtype1_t varchar(20) null,
revtype1_name varchar(20) null,
stp_arrivaldate datetime null)
		
select @v_referencenumbers = '' 

Create table #referencenumber (
ref_ident int identity
,ref_type varchar(6) null
, ref_number varchar(30) null
,ref_tablekey int
,ref_sequence int null)    

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  

SET @ret_value = 1 

SELECT @ord_shipper = o.ord_shipper FROM orderheader o 
	JOIN invoiceheader i ON o.ord_hdrnumber = i.ord_hdrnumber
	WHERE ivh_hdrnumber = @invoice_nbr

SELECT @ivh_shipper = invoiceheader.ivh_shipper FROM invoiceheader 
	WHERE ivh_hdrnumber = @invoice_nbr  

/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET   
 NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/ 

--create #temp (ref_type varchar(6),
--                    ref_number varchar(30),
--                    ref_sequence int)

INSERT INTO #invtemp_tbl
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
	ivh_remark ord_remark, -- 44168 change ord.ord_remark ord_remark,
	ivd.cmp_id stop_id,
	cmp_stop.cmp_name stop_name,  
	cmp_stop.cmp_address1 stop_addr1,  
	cmp_stop.cmp_address2 stop_addr2,           
	cmp_stop.cmp_zip stop_zip,
	CASE charindex('/', cmp_stop.cty_nmstct)
		WHEN 0 THEN cmp_stop.cty_nmstct + IsNull(cmp_stop.cmp_zip,'') 
		ELSE substring(cmp_stop.cty_nmstct,1, (charindex('/', cmp_stop.cty_nmstct)-1))+ ' ' + IsNull(cmp_stop.cmp_zip,'')
	END  stop_nmstct,
	fgt.fgt_number,
	--fgt.fgt_shipper shipper_id,
	CASE fgt_shipper 
		WHEN 'UNKNOWN' THEN fgt_shipper
		WHEN @ord_shipper THEN @ivh_shipper
		ELSE fgt_shipper
	END shipper_id,
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
	ivh.ivh_remark,
	ivh.ivh_trailer,
	ivh.ivh_tractor,
	ivh.ivh_revtype1,
	ord.ord_shipper,     
	@temp_name ord_shipper_name,
	ord.ord_consignee,     
	@temp_name ord_consignee_name, 
	@temp_city ord_consignee_city,
	ivh.ivh_deliverydate,
	isnull(mpp.mpp_firstname, '') + ' ' + isnull(mpp.mpp_lastname, '') as driver_name,
	@temp_refnum mani,
	@temp_rbol refnumbers,
	fgt.fgt_description,
	@temp_refnum b4stk1,
	@temp_refnum afstk1,
	@temp_refnum b4stk2,
	@temp_refnum afstk2,
	ivh_revtype1_t = 'RevType1',
	la.name revtype1_name,
	stp.stp_arrivaldate 
FROM invoiceheader ivh
	JOIN company cmp_billto ON ivh.ivh_billto = cmp_billto.cmp_id	
	JOIN invoicedetail ivd ON ivh.ivh_hdrnumber = ivd.ivh_hdrnumber
	JOIN orderheader ord ON ivh.ord_hdrnumber = ord.ord_hdrnumber
	JOIN company cmp_stop ON ivd.cmp_id = cmp_stop.cmp_id
	LEFT OUTER JOIN stops stp ON stp.stp_number = ivd.stp_number   -- USE FOR ACC TOO
	LEFT OUTER JOIN freightdetail fgt ON ivd.fgt_number = fgt.fgt_number
	JOIN chargetype ON ivd.cht_itemcode = chargetype.cht_itemcode
	join manpowerprofile mpp on (mpp.mpp_id = ivh.ivh_driver)
	join labelfile la on la.abbr = ord.ord_revtype1 and la.labeldefinition = 'RevType1'   
WHERE ivh.ivh_hdrnumber = @invoice_nbr
	AND ivd.ivd_type not in ('PUP','LI')
	
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
--IF (select count(*) from #invtemp_tbl) = 0 BEGIN
--	SELECT @ret_value = 0    
--	GOTO ERROR_END  
--END
--
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
WHERE r.ref_tablekey = #invtemp_tbl.ord_hdrnumber
	 AND r.ref_table = 'orderheader'
	 AND r.ref_type = 'PO#'
	 and  r.ref_sequence = (select min(ref_sequence) from referencenumber WHERE ref_tablekey = #invtemp_tbl.ord_hdrnumber
							AND ref_table = 'orderheader'
							AND ref_type = 'PO#' ) 

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

UPDATE #invtemp_tbl
SET #invtemp_tbl.mani = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.fgt_number
	 AND r.ref_table = 'freightdetail'
	 AND r.ref_type = 'MANI'

UPDATE #invtemp_tbl
SET #invtemp_tbl.b4stk1 = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.fgt_number
	 AND r.ref_table = 'freightdetail'
	 AND r.ref_type = 'B4STK1'

UPDATE #invtemp_tbl
SET #invtemp_tbl.afstk1 = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.fgt_number
	 AND r.ref_table = 'freightdetail'
	 AND r.ref_type = 'AFSTK1'

UPDATE #invtemp_tbl
SET #invtemp_tbl.b4stk2 = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.fgt_number
	 AND r.ref_table = 'freightdetail'
	 AND r.ref_type = 'B4STK2'

UPDATE #invtemp_tbl
SET #invtemp_tbl.afstk2 = r.ref_number
FROM referencenumber r
WHERE r.ref_tablekey = #invtemp_tbl.fgt_number
	 AND r.ref_table = 'freightdetail'
	 AND r.ref_type = 'AFSTK2'

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

update #invtemp_tbl
set ord_shipper_name = company.cmp_name 
from #invtemp_tbl join company on (company.cmp_id = #invtemp_tbl.ord_shipper) 

update #invtemp_tbl
set ord_consignee_name = company.cmp_name,
	ord_consignee_city = company.cty_nmstct 
from #invtemp_tbl join company on (company.cmp_id = #invtemp_tbl.ord_consignee)

Insert Into #referencenumber 
Select top 1 r.ref_type, r.ref_number,r.ref_tablekey, r.ref_sequence 
From referencenumber r join invoiceheader i on (r.ord_hdrnumber = i.ord_hdrnumber)   
Where r.ref_table = 'orderheader' and
r.ref_type = 'MANI' and
r.ref_tablekey = i.ord_hdrnumber and      
i.ivh_hdrnumber = @invoice_nbr 

Insert Into #referencenumber 
Select r.ref_type, r.ref_number,r.ref_tablekey, r.ref_sequence 
From referencenumber r 
	join #invtemp_tbl i on (r.ref_tablekey = i.fgt_number)   
Where r.ref_table = 'freightdetail' and
r.ref_type = 'MANI' and
i.ivd_type = 'DRP'
Order by r.ref_sequence,r.ref_number 

Select @v_next = Min(ref_ident) From #referencenumber     
Select @v_next = IsNull(@v_next,0)         

While @v_next > 0
BEGIN     
	select @v_referencenumbers = @v_referencenumbers + IsNull(case when datalength(ref_number) > 7 
	then (select left(ref_number,7)) else ref_number end,'') +'-'   
	from #referencenumber  where  ref_ident = @v_next
	select  @v_next = min(ref_ident) from #referencenumber where ref_ident > @v_next
	if @v_next > 4
      break
	else
      continue
END

if (select count(*) from #invtemp_tbl) = 0
begin
INSERT INTO #invtemp_tbl
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
	'',
	'0',
	ivh_remark ord_remark, -- 44168 change '',
	'',
	'',  
	'',  
	'',           
	'',
	'',
	fgt.fgt_number,
	'',
	'',
	'',  
	'',           
	'',
	'',
	chargetype.cht_itemcode,
	chargetype.cht_basis,  
	chargetype.cht_description,	
	'',
 	'',
	'',
	'',
	'',
	'',
	'',
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
	null,
	null,
	1 copies,
	ivd.ivd_unit,
	ivd.ivd_wgt,
	ivd.ivd_wgtunit,
	ivh.ivh_user_id1,
	ivh.ivh_totalmiles,
	ivh.ivh_remark,
	ivh.ivh_trailer,
	ivh.ivh_tractor,
	ivh.ivh_revtype1,
	'',     
	'',
	'',     
	'', 
	'',
	ivh.ivh_deliverydate,
	'',
	'',
	@temp_rbol,
	fgt.fgt_description,
	'',
	'',
	'',
	'',
	'',
	'',
	stp.stp_arrivaldate 
FROM invoiceheader ivh
	JOIN company cmp_billto ON ivh.ivh_billto = cmp_billto.cmp_id
	JOIN invoicedetail ivd ON ivh.ivh_hdrnumber = ivd.ivh_hdrnumber
	LEFT OUTER JOIN stops stp ON stp.stp_number = ivd.stp_number  
	LEFT OUTER JOIN freightdetail fgt ON ivd.fgt_number = fgt.fgt_number
	JOIN chargetype ON ivd.cht_itemcode = chargetype.cht_itemcode
where ivh.ivh_hdrnumber = @invoice_nbr
end

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
		ivh_remark,
		ivh_trailer,
		ivh_tractor,
		ivh_revtype1,
		ord_shipper,     
		ord_shipper_name,
		ord_consignee,     
		ord_consignee_name,
		ord_consignee_city,
		ivh_deliverydate,
		driver_name,
		mani,
		'refnumbers' = case 
			when datalength(@v_referencenumbers)>3 
			then (Select refnumbers = substring(@v_referencenumbers,1,datalength(@v_referencenumbers)-1))
			else @v_referencenumbers
		end,
		fgt_description,
		b4stk1,
		afstk1,
		b4stk2,
		afstk2,
		ivh_revtype1_t,
		revtype1_name,
		stp_arrivaldate
	FROM #invtemp_tbl    
	WHERE copies = 1
END     
                                                               
--ERROR_END:

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
	ivh_remark,
	ivh_trailer,
	ivh_tractor,
	ivh_revtype1,
	ord_shipper,     
	ord_shipper_name,
	ord_consignee,     
	ord_consignee_name,
	ord_consignee_city,
	ivh_deliverydate,
	driver_name,
	mani,
	'refnumbers' = case 
		when datalength(@v_referencenumbers)>3 
		then (Select refnumbers = substring(@v_referencenumbers,1,datalength(@v_referencenumbers)-1))
		else @v_referencenumbers
	end,
	fgt_description,
	b4stk1,
	afstk1,
	b4stk2,
	afstk2,
	ivh_revtype1_t,
	revtype1_name,
	stp_arrivaldate  
FROM #invtemp_tbl
ORDER BY ivd_sequence 
    
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */    
--IF @@ERROR != 0 select @ret_value = @@ERROR     
--return @ret_value 

drop table #invtemp_tbl

GO
GRANT EXECUTE ON  [dbo].[invoice_template115] TO [public]
GO
