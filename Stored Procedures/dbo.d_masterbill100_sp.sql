SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE      PROC [dbo].[d_masterbill100_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
	                       @shipstart datetime,@shipend datetime,@billdate datetime, 
                               @shipper varchar(8), @consignee varchar(8),
                               @copy int,@ivh_invoicenumber varchar(12))
AS

/*
 * 
 * NAME:d_masterbill100_sp
 * dbo.
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return SET of all the invoices a master bill.
 * 
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
 * 001 - @reprintflag, varchar, input;
 *       Is the masterbill a reprint
 * 002 - @mbnumber, int, input;
 *       Masterbill number
 * 003 - @billto, varchar, input;
 *	 Masterbill Billto
 * 004 - @revtype1, varchar, input, NULL;
 *       Revtype 1
 * 005 - @revtype2, varchar, input, NULL;
 *	 Revtype 2
 * 006 - @mbstatus, varchar, input;
 *	 Status of mastebill RTP, PRN, etc.
 * 007 - @shipstart, datetime, input, 01/01/1950;
 *
 * 008 - @shipend, datetime, input, 12/31/2049;
 *
 * 009 - @billdate, datetime, input, currentdate;
 *
 * 010 - @shipper, varchar, input, NULL;
 *	 invoice shipper
 * 011 - @consignee, varchar, input, NULL;
 * 	 invoice consignee
 * 012 - @copy, int, input, NULL;
 *	 Number of copies
 * 013 - @ivh_invoicenumber, varchar, input, NULL;
 *
 * REFERENCES: (called by AND calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * REVISION HISTORY:
 * 07/13/2007.01 - PTS38242 - Michalynn Kelly 	- Created
 * 07/13/2007.02 - PTS38242 - Michalynn Kelly	- Added the startdate and enddate to the results set of the temp table, Update billing quatity
 * 07/13/2007.03 - PTS38242 - Glenn Behra   	- The stored proc ?where? clause needs to be changed from ivh_shipdate to ivh_deliverydate 
 * 08/13/2007.04 - PTS38242 - Michalynn Kelly	- Extended company name fields to 50 characters
 * 09/10/2007.04 - PTS38242 - Eric Kelly		- No changes, but re-checked in due to UNICODE error
 * 10/12/2007.05 - PTS39901 - Eric Kelly		- Shipper and consignee location should not pull from mail-to address
 * 11/1/07 DPET 40147 cusotmer is using mail to address override and notice mail to name did nto print
 **/
SET NOCOUNT ON
DECLARE @v_int0  int
SELECT @v_int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'


CREATE TABLE #masterbill_temp (		ord_hdrnumber int,
		ivh_invoicenumber varchar(12),  
		ivh_hdrnumber int NULL, 
		ivd_number int NULL,
		ivh_billto varchar(8) NULL,
		ivh_shipper varchar(8) NULL,
		ivh_consignee varchar(8) NULL,
		ivh_totalcharge money NULL,   
		ivh_originpoint  varchar(8) NULL,  
		ivh_destpoint varchar(8) NULL,   
		ivh_origincity int NULL,   
		ivh_destcity int NULL,   
		ivh_shipdate datetime NULL,   
		ivh_deliverydate datetime NULL,   
		ivh_revtype1 varchar(6) NULL,
		ivh_mbnumber int NULL,
		ivh_shipper_name varchar(100) NULL ,
		ivh_shipper_address varchar(100) NULL,
		ivh_shipper_address2 varchar(100) NULL,
		ivh_shipper_nmstct varchar(30) NULL ,
		ivh_shipper_zip varchar(10) NULL,
		ivh_billto_name varchar(100)  NULL,
		ivh_billto_address varchar(100) NULL,
		ivh_billto_address2 varchar(100) NULL,
		ivh_billto_nmstct varchar(30) NULL ,
		ivh_billto_zip varchar(10) NULL,
		ivh_consignee_name varchar(100)  NULL,
		ivh_consignee_address varchar(100) NULL,
		ivh_consignee_address2 varchar(100) NULL,
		ivh_consignee_nmstct varchar(30)  NULL,
		ivh_consignee_zip varchar(10) NULL,
		origin_nmstct varchar(30) NULL,
		origin_state varchar(2) NULL,
		dest_nmstct varchar(30) NULL,
		dest_state varchar(2) NULL,
		billdate datetime NULL,
		cmp_mailto_name varchar(100)  NULL,
		bill_quantity float  NULL,
		ivd_weight float NULL,
		ivd_weightunit char(6) NULL,
		ivd_count float NULL,
		ivd_countunit char(6) NULL,
		ivd_volume float NULL,
		ivd_volunit char(6) NULL,
		ivd_unit char(6) NULL,
		ivd_rate money NULL,
		ivd_rateunit char(6) NULL,
		ivd_charge money NULL,
		cht_description varchar(30) NULL,
		cht_primary char(1) NULL,
		cmd_name varchar(60)  NULL,
		ivd_description varchar(60) NULL,
		ivd_type char(6) NULL,
		stp_city int NULL,
		stp_cty_nmstct varchar(25) NULL,
		ivd_sequence int NULL,
		stp_number int NULL,
		copy int NULL,
		cmp_id varchar(8) NULL,
		ord_firstref varchar(30) NULL,
		ord_totalweight float NULL,
		billto_cmp_altid varchar(25) NULL,
		minumum_charge_text varchar(6) NULL,
		cht_itemcode	varchar(6) NULL,
-- PTS 38242 -- MRK (start)
		startdate datetime,
		enddate datetime)
-- PTS 38242 -- MRK (end)

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN
    INSERT INTO	#masterbill_temp
    SELECT 	IsNull(invoiceheader.ord_hdrnumber, -1),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		ivd.ivd_number,
		invoiceheader.ivh_billto,
		invoiceheader.ivh_shipper,
		invoiceheader.ivh_consignee,   
		invoiceheader.ivh_totalcharge,   
		invoiceheader.ivh_originpoint,  
		invoiceheader.ivh_destpoint,   
		invoiceheader.ivh_origincity,   
		invoiceheader.ivh_destcity,   
		invoiceheader.ivh_shipdate,   
		invoiceheader.ivh_deliverydate,   
		invoiceheader.ivh_revtype1,
		invoiceheader.ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
--PTS 39901 EMK - Removed mailto overrides for shipper
	 ivh_shipto_address = ISNULL(cmp2.cmp_address1,''),
	 ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),
	 ivh_shipto_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
									WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
									END),''),
	ivh_shipto_zip =  ISNULL(cmp2.cmp_zip ,''),  
	ivh_billto_name = CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_name,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_name,'')
		ELSE ISNULL(cmp1.cmp_mailto_name,'')
	    END,
--PTS 39901 
--  provide for maitlto override of billto
	 ivh_billto_address = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_billto_address2 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
			END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
			END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) -1
			END),'')
	    END,
	ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		ivh_consignee_name = cmp3.cmp_name,
	--PTS 39901 EMK - Removed mailto overrides for consignee
	 ivh_consignee_address = ISNULL(cmp3.cmp_address1,''),
	 ivh_consignee_address2 = ISNULL(cmp3.cmp_address2,''),
	 ivh_consignee_nmstct = ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
			END),''),
	ivh_consignee_zip = ISNULL(cmp3.cmp_zip ,''),
	--PTS 39901 EMK
		cty1.cty_nmstct   origin_nmstct,
		cty1.cty_state		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state		dest_state,
		ivh_billdate      billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		IsNull(ivd.ivd_wgt, 0),
		IsNull(ivd.ivd_wgtunit, ''),
		IsNull(ivd.ivd_count, 0),
		IsNull(ivd.ivd_countunit, ''),
		IsNull(ivd.ivd_volume, 0),
		IsNull(ivd.ivd_volunit, ''),
		IsNull(ivd.ivd_unit, ''),
		IsNull(ivd.ivd_rate, 0),
		IsNull(ivd.ivd_rateunit, ''),
		ivd.ivd_charge,
		cht.cht_description,
		cht.cht_primary,
		cmd.cmd_name,
		IsNull(ivd_description, ''),
		ivd.ivd_type,
		stp.stp_city,
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		ivd.cmp_id cmp_id,
		'',
		0,
		cmp1.cmp_altid,
		'' minimum_charge_text,
		ivd.cht_itemcode,
-- PTS 38242 -- MRK (start)
		@shipstart,
		@shipend
-- PTS 38242 -- MRK (end)
		FROM invoiceheader 
			INNER JOIN invoicedetail ivd ON invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber 
			INNER JOIN company cmp1 ON invoiceheader.ivh_billto = cmp1.cmp_id 
			INNER JOIN company cmp2 ON invoiceheader.ivh_shipper = cmp2.cmp_id 
			INNER JOIN company cmp3 ON invoiceheader.ivh_consignee = cmp3.cmp_id 
			INNER JOIN city cty1 ON invoiceheader.ivh_origincity = cty1.cty_code 
			INNER JOIN city cty2 ON invoiceheader.ivh_destcity = cty2.cty_code 
			INNER JOIN chargetype cht ON ivd.cht_itemcode = cht.cht_itemcode 
			LEFT OUTER JOIN stops stp ON ivd.stp_number = stp.stp_number 
			LEFT OUTER JOIN commodity cmd ON ivd.cmd_code = cmd.cmd_code
		WHERE     (invoiceheader.ivh_mbnumber = @mbnumber) 
				AND (@shipper IN (invoiceheader.ivh_shipper, 'UNKNOWN')) 
				AND (@consignee IN (invoiceheader.ivh_consignee, 'UNKNOWN')) 
	END

-- for master bills with 'RTP' status
IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
     INSERT INTO 	#masterbill_temp
     SELECT 	IsNull(invoiceheader.ord_hdrnumber,-1),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber,
		ivd.ivd_number, 
		invoiceheader.ivh_billto,   
		invoiceheader.ivh_shipper,
		invoiceheader.ivh_consignee,
		invoiceheader.ivh_totalcharge,   
		invoiceheader.ivh_originpoint,  
		invoiceheader.ivh_destpoint,   
		invoiceheader.ivh_origincity,   
		invoiceheader.ivh_destcity,   
		invoiceheader.ivh_shipdate,   
		invoiceheader.ivh_deliverydate,   		
		invoiceheader.ivh_revtype1,
		@mbnumber     ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
--PTS 39901 EMK - Removed mailto overrides for shipper
	 ivh_shipto_address = ISNULL(cmp2.cmp_address1,''),
	 ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),
	 ivh_shipto_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
									WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
									END),''),
	ivh_shipto_zip =  ISNULL(cmp2.cmp_zip ,''),  
	ivh_billto_name = CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_name,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_name,'')
		ELSE ISNULL(cmp1.cmp_mailto_name,'')
	    END,
--PTS 39901 
--  provide for maitlto override of billto
	 ivh_billto_address = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_billto_address2 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
			END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
			END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct) - 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp1.mailto_cty_nmstct) - 1
			END),'')
	    END,
	ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		ivh_consignee_name = cmp3.cmp_name,
	--PTS 39901 EMK - Removed mailto overrides for consignee
	 ivh_consignee_address = ISNULL(cmp3.cmp_address1,''),
	 ivh_consignee_address2 = ISNULL(cmp3.cmp_address2,''),
	 ivh_consignee_nmstct = ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
			END),''),
	ivh_consignee_zip = ISNULL(cmp3.cmp_zip ,''),
	--PTS 39901 EMK
		cty1.cty_nmstct   origin_nmstct,
		cty1.cty_state		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state		dest_state,
		@billdate	billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		IsNull(ivd.ivd_wgt, 0),
		IsNull(ivd.ivd_wgtunit, ''),
		IsNull(ivd.ivd_count, 0),
		IsNull(ivd.ivd_countunit, ''),
		IsNull(ivd.ivd_volume, 0),
		IsNull(ivd.ivd_volunit, ''),
		IsNull(ivd.ivd_unit, ''),
		IsNull(ivd.ivd_rate, 0),
		IsNull(ivd.ivd_rateunit, ''),
		ivd.ivd_charge,
		cht.cht_description,
		cht.cht_primary,
		cmd.cmd_name,
		IsNull(ivd_description, ''),
		ivd.ivd_type,		
		stp.stp_city,
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		ivd.cmp_id cmp_id,
		'',
		0,
		cmp1.cmp_altid,
		'' minimum_charge_text,
		ivd.cht_itemcode,
-- PTS 38242 -- MRK (start)
		@shipstart,
		@shipend
-- PTS 38242 -- MRK (end)

		FROM invoiceheader INNER JOIN invoicedetail ivd ON invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber 
		INNER JOIN company cmp1 ON invoiceheader.ivh_billto = cmp1.cmp_id 
		INNER JOIN company cmp2 ON invoiceheader.ivh_shipper = cmp2.cmp_id 
		INNER JOIN company cmp3 ON invoiceheader.ivh_consignee = cmp3.cmp_id 
		INNER JOIN city cty1 ON invoiceheader.ivh_origincity = cty1.cty_code 
		INNER JOIN city cty2 ON invoiceheader.ivh_destcity = cty2.cty_code 
		INNER JOIN chargetype cht ON ivd.cht_itemcode = cht.cht_itemcode 
		LEFT OUTER JOIN stops stp ON ivd.stp_number = stp.stp_number 
		LEFT OUTER JOIN commodity cmd ON ivd.cmd_code = cmd.cmd_code
		--PTS 38242 EMK - Removed invoiceheader.ivh_mbnumber = @mbnumber, added @billto line
		WHERE @shipper IN (invoiceheader.ivh_shipper, 'UNKNOWN') 
				AND (invoiceheader.ivh_billto = @billto )  
				AND @consignee IN (invoiceheader.ivh_consignee, 'UNKNOWN')
				AND @ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master')
				AND invoiceheader.ivh_deliverydate between @shipstart AND @shipend  -- PTS 38242 -- SGB 
				AND invoiceheader.ivh_mbstatus = 'RTP'  
				AND @revtype1 in (invoiceheader.ivh_revtype1,'UNK')
				AND @revtype2 in (invoiceheader.ivh_revtype2,'UNK') 

  END

  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.stp_cty_nmstct = city.cty_nmstct
  FROM		#masterbill_temp, city 
  WHERE		#masterbill_temp.stp_city = city.cty_code 

  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.ord_firstref = ref_number
  FROM		#masterbill_temp, referencenumber 
  WHERE		#masterbill_temp.ord_hdrnumber = ref_tablekey and
		ref_table='orderheader' and
		ref_sequence=1 and
		ivd_sequence=1
		and ref_type in ('BL#', 'BOL')


-- Update the minumum_charge_text field, marking which charges are 
-- considered the 'minimum charge'
  UPDATE	#masterbill_temp
  SET		minumum_charge_text = 'MINCHG'
  WHERE		ivd_number in (SELECT distinct ivd_number FROM #masterbill_temp WHERE cht_itemcode = 'MIN')

  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.ord_totalweight = o.ord_totalweight
  FROM		#masterbill_temp, orderheader o 
  WHERE		#masterbill_temp.ord_hdrnumber = o.ord_hdrnumber and
		ivd_sequence=1

  UPDATE 	a 
  SET		a.ivd_rate=b.ivd_rate,
		a.ivd_rateunit=b.ivd_rateunit,
		a.ivd_charge=b.ivd_charge,	
-- PTS 38242 -- MRK (start)
		a.bill_quantity=b.bill_quantity
-- PTS 38242 -- MRK (end)
  FROM		#masterbill_temp  a ,#masterbill_temp b
  WHERE		a.ivh_invoicenumber = b.ivh_invoicenumber 
		and a.ivd_sequence =1 
		and b.ivd_sequence = (select min(c.ivd_sequence) from #masterbill_temp c 
		where c.ivd_type='SUB' and c.ivh_invoicenumber=a.ivh_invoicenumber)

  

 delete from #masterbill_temp where ivd_sequence=(select min(c.ivd_sequence) from #masterbill_temp c 
		where c.ivd_type='SUB' and c.ivh_invoicenumber=#masterbill_temp.ivh_invoicenumber)


  SELECT * 
  FROM		#masterbill_temp
  ORDER BY	ord_hdrnumber, ivd_sequence

  DROP TABLE 	#masterbill_temp
GO
GRANT EXECUTE ON  [dbo].[d_masterbill100_sp] TO [public]
GO
