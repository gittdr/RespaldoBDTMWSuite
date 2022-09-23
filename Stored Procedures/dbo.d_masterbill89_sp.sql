SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create  PROC [dbo].[d_masterbill89_sp] (
	@p_reprintflag		varchar(10),
	@p_mbnumber			int,
	@p_billto			varchar(8), 
	@p_revtype1			varchar(6),
	@p_mbstatus			varchar(6),
	@p_shipstart		datetime,
	@p_shipend			datetime,
	@p_billdate			datetime,
	@p_copy				int,
	@p_revtype2			varchar(6),
	@p_revtype3			varchar(6),
	@p_revtype4			varchar(6))
AS


/*
 * 
 * NAME:dbo.d_masterbill89_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all invoices grouped together in a masterbill based upon the input values
 * that are passed into this proc.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * See selection list for #masterbill_temp.
 *
 * PARAMETERS:
 * 001 - @p_reprintflag varchar(10), input
 *       flag for reprinting
 * 002 - @p_mbnumber INT, input
 *       The masterbill number
 * 003 - @p_billto varchar(8), input
 *       Our bill to.
 * 004 - @p_revtype1 varchar(6), input
 *       revtype to sort on.
 * 005 - @p_mbstatus varchar(6), input
 *       Masterbill status.
 * 006 - @p_shipstart datetime, input
 *       date shipped used in where clause to specify range.
 * 007 - @p_shipend datetime), input
 *       end date for shep used in where clause for range.
 * 008 - @p_billdate datetime, input
 *       date to mark on masterbill.
 * 009 - @p_copies, int, input, null;
 *       number of required copies
 * 010 - @p_revtype2 varchar(6), input
 *       sort by revtype
 * 011 - @p_revtype3 varchar(6), input
 *       sort by revtype
 * 012 - @p_revtype4 varchar(6), input
 *       sort by revtype
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 - PTSnnnnn - AuthorName -Revision Description 
 * 08/07/2006.02- PRB - Created MB Format 89 for Kenan Advantage Group.
 * 08/08/2006.03 - History:
 * dpete pts 6691 change ivd_coutn and ivd_volume on temp tableto float
 * DPETE PTS17762 When 'ALL' ispassed in @p_revtype1 (for format 03b), match to all revtypes.
 * 10/04/2011 - NQIAO (PTS58852)increase temp table field sizes from varchar(30) to varchar(100) for shipper_name & ivh_billto_name
 **/

DECLARE @int0  int
SELECT @int0 = 0

SELECT @p_shipstart = convert(char(12),@p_shipstart)+'00:00:00'
SELECT @p_shipend   = convert(char(12),@p_shipend  )+'23:59:59'


CREATE TABLE #masterbill_temp
	(ord_number varchar(12) NULL,
	ord_hdrnumber int,
	ivh_invoicenumber varchar(12) NULL ,  
	ivh_hdrnumber int NULL, 
	ivh_billto varchar(8) NULL,   
    ivh_totalcharge money NULL,   
    ivh_originpoint varchar(109) NULL,  
    ivh_destpoint varchar(109) NULL,   
    ivh_origincity int NULL,   
    ivh_destcity int NULL,   
    ivh_shipdate datetime NULL,   
    ivh_deliverydate datetime NULL,   
    ivh_revtype1 varchar(6) NULL,
	ivh_mbnumber int NULL,
	shipper_name varchar(100) NULL,
	shipper_addr varchar(40) NULL,
	shipper_addr2 varchar(40) NULL,
	shipper_nmstct varchar(25) NULL,
	shipper_zip varchar(10) NULL,
	ivh_billto_name varchar(100) NULL,
	ivh_billto_address varchar(40) NULL,
	ivh_billto_address2 varchar(40) NULL,
	ivh_billto_nmstct varchar(25) NULL,
	ivh_billto_zip varchar(10) NULL,
	dest_nmstct varchar(25) NULL,
	dest_state char(2) NULL,
	billdate datetime NULL,
	shipticket varchar(30) NULL,
	cmp_mailto_name varchar(30) NULL,
	ivd_wgt float NULL,
	ivd_wgtunit char(6) NULL,
	ivd_count float NULL,
	ivd_countunit char(6) NULL,
	ivd_volume float NULL,
	ivd_volunit char(6) NULL,
	ivd_quantity float NULL,
	ivd_unit varchar(6) NULL,
	ivd_rate money NULL,
	ivd_rateunit varchar(6) NULL,
	ivd_charge money NULL,
	ivd_volume2 float NULL,
	stp_nmstct varchar(25) NULL,
	stp_city int NULL,
	cmd_name varchar(60) NULL,
	tar_tarriff_number varchar(12) NULL,
	cmp_altid varchar(25) NULL,
	copy int NULL,
	cht_primary char(1) NULL,
	cht_description varchar(60) NULL,
	ivd_sequence int NULL,
	ivh_ref_number varchar(30)NULL,
	fgt_refnum varchar(30) NULL, --PRB PTS33716
    revtype1_t varchar(20) NULL --PRB PTS33716
) 
  

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@p_reprintflag) = 'REPRINT' 
  BEGIN

    INSERT INTO #masterbill_temp

    SELECT oh.ord_number,
	invoiceheader.ord_hdrnumber,
	invoiceheader.ivh_invoicenumber,  
	invoiceheader.ivh_hdrnumber, 
        invoiceheader.ivh_billto,   
        invoiceheader.ivh_totalcharge,   
        invoiceheader.ivh_originpoint + '-' + (SELECT ISNULL(cmp_name, '') + ' @'
												FROM company
												WHERE cmp_id = invoiceheader.ivh_originpoint),  
        invoiceheader.ivh_destpoint  + '-' + (SELECT ISNULL(cmp_name, '') + ' @'
												FROM company
												WHERE cmp_id = invoiceheader.ivh_destpoint),   
        invoiceheader.ivh_origincity,   
        invoiceheader.ivh_destcity,   
        invoiceheader.ivh_shipdate,   
        invoiceheader.ivh_deliverydate,   
        invoiceheader.ivh_revtype1,
	invoiceheader.ivh_mbnumber,
	shipper_name = cmp3.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	shipper_address = 
	   CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
		ELSE ISNULL(cmp3.cmp_mailto_address1,'')
	    END,
	shipper_address2 = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
		ELSE ISNULL(cmp3.cmp_mailto_address2,'')
	    END,
	shipper_nmstct = 
	    CASE
		WHEN cmp3.cmp_id = 'UNKNOWN' THEN
		     'UNKNOWN'
		WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct)) - 1),'')
	    END,
	shipper_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    END,
	billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	billto_address = 
	   CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	billto_address2 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_id = 'UNKNOWN' THEN
		     'UNKNOWN'
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
	    END,
	billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	cty2.cty_nmstct   dest_nmstct,
	cty2.cty_state		dest_state,
	ivh_billdate      billdate,
	'',
	ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	IsNull(ivd.ivd_wgt, 0),
	IsNull(ivd.ivd_wgtunit, ''),
	IsNull(ivd.ivd_count, 0),
	IsNull(ivd.ivd_countunit, ''),
	IsNull(ivd.ivd_volume, 0),
	IsNull(ivd.ivd_volunit, ''),
	IsNull(ivd.ivd_quantity, 0),
	IsNull(ivd.ivd_unit, ''),
	IsNull(ivd.ivd_rate, 0),
	IsNull(ivd.ivd_rateunit, ''),
	IsNull(ivd.ivd_charge, 0),
	IsNull(ivd.ivd_volume, 0),
	'',
	stops.stp_city,
	cmd.cmd_name,
	invoiceheader.tar_tarriffnumber,
	cmp1.cmp_altid,
	@p_copy,
	cht.cht_primary,
	cht.cht_description,
	ivd.ivd_sequence,
	--ILB 10-18-2002 PTS# 15194
	invoiceheader.ivh_ref_number,  
	--ILB 10-18-2002 PTS# 15194
	ISNULL(f.fgt_refnum, 'UNKNOWN'), --PRB PTS33716
    'RevType1' --PRB PTS33716
    
    FROM invoiceheader
	 JOIN invoicedetail ivd ON (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
	 LEFT OUTER JOIN orderheader oh ON (invoiceheader.ord_hdrnumber = oh.ord_hdrnumber)  
	 RIGHT OUTER JOIN company cmp1 ON (cmp1.cmp_id = invoiceheader.ivh_billto)
	 RIGHT OUTER JOIN company cmp3 ON (cmp3.cmp_id = invoiceheader.ivh_shipper)
	 JOIN city cty1 ON (cty1.cty_code = invoiceheader.ivh_origincity)
	 JOIN city cty2 ON (cty2.cty_code = invoiceheader.ivh_destcity)
	 JOIN chargetype cht ON (ivd.cht_itemcode = cht.cht_itemcode)
	 LEFT OUTER JOIN commodity cmd ON (ivd.cmd_code = cmd.cmd_code)
	 LEFT OUTER JOIN stops ON  (ivd.stp_number = stops.stp_number)
	 LEFT OUTER JOIN freightdetail f ON (ivd.fgt_number = f.fgt_number)
   WHERE --(invoiceheader.ord_hdrnumber *= oh.ord_hdrnumber)
	invoiceheader.ivh_mbnumber = @p_mbnumber 
	--AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
	--AND (ivd.stp_number *= stops.stp_number)
	--AND (ivd.cmd_code *= cmd.cmd_code)
	--AND (ivd.cht_itemcode = cht.cht_itemcode)
	--AND (cmp1.cmp_id =* invoiceheader.ivh_billto) 
	--AND (cmp3.cmp_id =* invoiceheader.ivh_shipper)
	--AND (cty1.cty_code = invoiceheader.ivh_origincity) 
	--AND (cty2.cty_code = invoiceheader.ivh_destcity)
	AND (ivd.ivd_volume > 0 OR ivd_quantity > 0)

  END

-- for master bills with 'RTP' status

IF UPPER(@p_reprintflag) <> 'REPRINT' 
  BEGIN

     INSERT INTO #masterbill_temp

    SELECT oh.ord_number,
	invoiceheader.ord_hdrnumber,
	invoiceheader.ivh_invoicenumber,  
	invoiceheader.ivh_hdrnumber, 
        invoiceheader.ivh_billto,   
        invoiceheader.ivh_totalcharge,   
        invoiceheader.ivh_originpoint + '-' + (SELECT ISNULL(cmp_name, '')
												FROM company
												WHERE cmp_id = invoiceheader.ivh_originpoint),  
        invoiceheader.ivh_destpoint  + '-' + (SELECT ISNULL(cmp_name, '')
												FROM company
												WHERE cmp_id = invoiceheader.ivh_destpoint),   
        invoiceheader.ivh_origincity,   
        invoiceheader.ivh_destcity,   
        invoiceheader.ivh_shipdate,   
        invoiceheader.ivh_deliverydate,   
        invoiceheader.ivh_revtype1,
-- JET - 1/28/00 - PTS #7169, this was not returning a mb number
--	invoiceheader.ivh_mbnumber,
        @p_mbnumber ivh_mbnumber, 
	shipper_name = cmp3.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	shipper_address = 
	   CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
		ELSE ISNULL(cmp3.cmp_mailto_address1,'')
	    END,
	shipper_address2 = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
		ELSE ISNULL(cmp3.cmp_mailto_address2,'')
	    END,
	shipper_nmstct = 
	    CASE
		WHEN cmp3.cmp_id = 'UNKNOWN' THEN
		     'UNKNOWN'
		WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,(CHARINDEX('/',cmp3.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct)) - 1),'')
	    END,
	shipper_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    END,
	billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	billto_address = 
	   CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	billto_address2 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_id = 'UNKNOWN' THEN
		     'UNKNOWN'
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
	    END,
	billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	cty2.cty_nmstct   dest_nmstct,
	cty2.cty_state		dest_state,
	ivh_billdate      billdate,
	'',
	ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	IsNull(ivd.ivd_wgt, 0),
	IsNull(ivd.ivd_wgtunit, ''),
	IsNull(ivd.ivd_count, 0),
	IsNull(ivd.ivd_countunit, ''),
	IsNull(ivd.ivd_volume, 0),
	IsNull(ivd.ivd_volunit, ''),
	IsNull(ivd.ivd_quantity, 0),
	IsNull(ivd.ivd_unit, ''),
	IsNull(ivd.ivd_rate, 0),
	IsNull(ivd.ivd_rateunit, ''),
	IsNull(ivd.ivd_charge, 0),
	IsNull(ivd.ivd_volume, 0),
	'',
	stops.stp_city,
	cmd.cmd_name,
	invoiceheader.tar_tarriffnumber,
	IsNull(cmp1.cmp_altid, ''),
	@p_copy,
	cht.cht_primary,
	cht.cht_description,
	ivd.ivd_sequence,
	--ILB 10-18-2002 PTS# 15194
	invoiceheader.ivh_ref_number, 
	--ILB 10-18-2002 PTS# 15194
	ISNULL(f.fgt_refnum, 'UNKNOWN'), --PRB PTS33716
    'RevType1' --PRB PTS33716

    FROM invoiceheader
	 JOIN invoicedetail ivd ON (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
	 LEFT OUTER JOIN orderheader oh ON (invoiceheader.ord_hdrnumber = oh.ord_hdrnumber)  
	 RIGHT OUTER JOIN company cmp1 ON (cmp1.cmp_id = invoiceheader.ivh_billto)
	 RIGHT OUTER JOIN company cmp3 ON (cmp3.cmp_id = invoiceheader.ivh_shipper)
	 JOIN city cty1 ON (cty1.cty_code = invoiceheader.ivh_origincity)
	 JOIN city cty2 ON (cty2.cty_code = invoiceheader.ivh_destcity)
	 JOIN chargetype cht ON (ivd.cht_itemcode = cht.cht_itemcode)
	 LEFT OUTER JOIN commodity cmd ON (ivd.cmd_code = cmd.cmd_code)
	 LEFT OUTER JOIN stops ON  (ivd.stp_number = stops.stp_number)
	 LEFT OUTER JOIN freightdetail f ON ivd.fgt_number = f.fgt_number
    WHERE --(invoiceheader.ord_hdrnumber *= oh.ord_hdrnumber) 
     ( invoiceheader.ivh_billto = @p_billto )  
     --AND    (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
     --AND    (ivd.stp_number *= stops.stp_number) 
     --AND    (ivd.cmd_code *= cmd.cmd_code) 
     --AND	(ivd.cht_itemcode = cht.cht_itemcode)
     AND    ( invoiceheader.ivh_shipdate between @p_shipstart AND @p_shipend ) 
     AND    (invoiceheader.ivh_mbstatus = 'RTP') 
   --  AND    (@p_revtype1 in (invoiceheader.ivh_revtype1,'UNK')) 
   --  AND    (@p_revtype1 in (invoiceheader.ivh_revtype1,'ALL'))
     AND (@p_revtype1 in (invoiceheader.ivh_revtype1,'ALL'))
     AND (@p_revtype2 in (invoiceheader.ivh_revtype2,'UNK'))
     AND (@p_revtype3 in (invoiceheader.ivh_revtype3,'UNK'))
     AND (@p_revtype4 in (invoiceheader.ivh_revtype4,'UNK'))
     --AND    (cmp1.cmp_id =* invoiceheader.ivh_billto)
     --AND    (cmp3.cmp_id = invoiceheader.ivh_shipper)
     --AND    (cty1.cty_code = invoiceheader.ivh_origincity) 
     --AND    (cty2.cty_code = invoiceheader.ivh_destcity)
     AND    (ivd.ivd_volume > 0 OR ivd_quantity > 0)
END

/* Old ANSI JOINS
    FROM orderheader oh, invoiceheader, company cmp1, city cty1, 
	city cty2, invoicedetail ivd, stops,  commodity cmd, company cmp3, chargetype cht
   WHERE (invoiceheader.ord_hdrnumber *= oh.ord_hdrnumber) 
	AND ( invoiceheader.ivh_billto = @p_billto )  
     AND    (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
     AND    (ivd.stp_number *= stops.stp_number) 
     AND    (ivd.cmd_code *= cmd.cmd_code) 
     AND	(ivd.cht_itemcode = cht.cht_itemcode)
     AND    ( invoiceheader.ivh_shipdate between @p_shipstart AND @p_shipend ) 
     AND    (invoiceheader.ivh_mbstatus = 'RTP') 
   --  AND    (@p_revtype1 in (invoiceheader.ivh_revtype1,'UNK')) 
	 AND    (@p_revtype1 in (invoiceheader.ivh_revtype1,'ALL')) 
     AND    (cmp1.cmp_id =* invoiceheader.ivh_billto)
     AND    (cmp3.cmp_id = invoiceheader.ivh_shipper)
     AND    (cty1.cty_code = invoiceheader.ivh_origincity) 
     AND    (cty2.cty_code = invoiceheader.ivh_destcity)
     AND    (ivd.ivd_volume > 0 OR ivd_quantity > 0)

  END

*/

UPDATE #masterbill_temp set shipticket = (SELECT 	IsNull(MIN(ref_number), '')
						FROM 	referencenumber ref
						WHERE 	ref.ref_table = 'orderheader' AND
							ref.ref_tablekey = #masterbill_temp.ord_hdrnumber AND
							ref.ref_type = 'SHIPTK')
UPDATE	 	#masterbill_temp 

SET		#masterbill_temp.stp_nmstct = city.cty_nmstct
FROM		#masterbill_temp, city 
WHERE		#masterbill_temp.stp_city = city.cty_code


SELECT * from #masterbill_temp
ORDER BY ivh_invoicenumber,  ivd_sequence

DROP TABLE #masterbill_temp

GO
GRANT EXECUTE ON  [dbo].[d_masterbill89_sp] TO [public]
GO
