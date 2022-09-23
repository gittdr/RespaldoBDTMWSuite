SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[invoice_template115_subshipper] (@invoice_nbr int)  
AS  
/*
 * 
 * NAME:dbo.invoice_template115_subshipper
 * 
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all shippers
 * based on the invoice selected.
 *
 * RETURNS:
 * n/a
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @invoice_nbr, int, input, null;
 *       Invoice number
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * REVISION HISTORY:
 * 07/03/2007 - PTS 35717 - OS - Created 
 **/
DECLARE	@temp_name	varchar(100),  
 	@temp_addr		varchar(100),  
	@temp_zip		varchar(10),
	@temp_nmstct	varchar(30),
	@temp_int		int,
	@ord_shipper	varchar(8),
	@ivh_shipper	varchar(8)

SELECT @ord_shipper = o.ord_shipper FROM orderheader o 
	JOIN invoiceheader i ON o.ord_hdrnumber = i.ord_hdrnumber
	WHERE ivh_hdrnumber = @invoice_nbr

SELECT @ivh_shipper = invoiceheader.ivh_shipper FROM invoiceheader 
	WHERE ivh_hdrnumber = @invoice_nbr  
 	
SELECT ivh.ivh_hdrnumber,
	ivh.mov_number,
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
	@temp_int pickup_stp_number,
	ivd.ivd_type,
	ivd.ivd_sequence,
	ivd.cmd_code,
	chargetype.cht_basis
INTO #invtemp_tbl 
FROM invoiceheader ivh
	JOIN company cmp_billto ON ivh.ivh_billto = cmp_billto.cmp_id	
	JOIN invoicedetail ivd ON ivh.ivh_hdrnumber = ivd.ivh_hdrnumber
	JOIN orderheader ord ON ivh.ord_hdrnumber = ord.ord_hdrnumber
	JOIN company cmp_stop ON ivd.cmp_id = cmp_stop.cmp_id
	LEFT OUTER JOIN stops stp ON stp.stp_number = ivd.stp_number 
	LEFT OUTER JOIN freightdetail fgt ON ivd.fgt_number = fgt.fgt_number
	JOIN chargetype ON ivd.cht_itemcode = chargetype.cht_itemcode
	join manpowerprofile mpp on (mpp.mpp_id = ivh.ivh_driver)
WHERE ivh.ivh_hdrnumber = @invoice_nbr
AND ivd.ivd_type <> 'PUP' 

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

SELECT distinct shipper_id,
	shipper_name,
	shipper_addr1,
	shipper_addr2,
	shipper_zip,
	shipper_nmstct
FROM #invtemp_tbl
where cht_basis = 'SHP' 

drop table #invtemp_tbl

GO
GRANT EXECUTE ON  [dbo].[invoice_template115_subshipper] TO [public]
GO
