SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
  

CREATE PROC [dbo].[d_masterbill118_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
	                       @shipstart datetime,@shipend datetime,@billdate datetime, 
                               @shipper varchar(8), @consignee varchar(8),
                               @copy int,@ivh_invoicenumber varchar(12))
AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
-- 10/7/99 dpete retrieve cmp_id for d_mb_format05
-- dpete pts6691 make ivd_count and volume floats on temp table
-- vjh pts7230 roll up some data.
-- 07/25/2002	Vern Jewett (label=vmj1)	PTS 14924: lengthen ivd_description from 30 to
--											60 chars
 * 10/26/2007.01 ? PTS40029 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * BDH 04/23/08 pts 41647, created this sp from d_masterbill13_sp for Tidewater.
 **/

DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'


CREATE TABLE #masterbill_temp (		ord_hdrnumber int,
		ivh_invoicenumber varchar(12),  
		ivh_hdrnumber int NULL, 
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
		ivh_shipper_name varchar(60) NULL ,
		ivh_shipper_address varchar(50) NULL,
		ivh_shipper_address2 varchar(50) NULL,
		ivh_shipper_nmstct varchar(40) NULL ,
		ivh_shipper_zip varchar(10) NULL,
		ivh_billto_name varchar(60)  NULL,
		ivh_billto_address varchar(50) NULL,
		ivh_billto_address2 varchar(50) NULL,
		ivh_billto_nmstct varchar(40) NULL ,
		ivh_billto_zip varchar(10) NULL,
		ivh_consignee_name varchar(60)  NULL,
		ivh_consignee_address varchar(50) NULL,
		ivh_consignee_address2 varchar(50) NULL,
		ivh_consignee_nmstct varchar(30)  NULL,
		ivh_consignee_zip varchar(10) NULL,
		origin_nmstct varchar(30) NULL,
		origin_state varchar(6) NULL,
		dest_nmstct varchar(30) NULL,
		dest_state varchar(6) NULL,
		billdate datetime NULL,
		cmp_mailto_name varchar(60)  NULL,
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
		--vmj1+
		ivd_description varchar(60) NULL,
--		ivd_description varchar(30) NULL,
		--vmj1-
		ivd_type char(6) NULL,
		stp_city int NULL,
		stp_cty_nmstct varchar(30) NULL,
		ivd_sequence int NULL,
		stp_number int NULL,
		copy int NULL,
		cmp_id varchar(8) NULL,
		ord_firstref varchar(30) NULL,
		ivh_totalweight float NULL,
		cht_rollintolh int null,
	ivd_number int null)

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN
    INSERT INTO	#masterbill_temp
    SELECT 	IsNull(invoiceheader.ord_hdrnumber, -1),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
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
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_shipto_address = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address1,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address1,'')
		ELSE ISNULL(cmp2.cmp_mailto_address1,'')
	    END,
	 ivh_shipto_address2 = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address2,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address2,'')
		ELSE ISNULL(cmp2.cmp_mailto_address2,'')
	    END,
	 ivh_shipto_nmstct = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
			END),'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
			END),'')
		ELSE ISNULL(SUBSTRING(cmp2.mailto_cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp2.mailto_cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp2.mailto_cty_nmstct) -1
			END),'')
	    END,
	ivh_shipto_zip = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL  THEN ISNULL(cmp2.cmp_zip ,'')  
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_zip,'')
		ELSE ISNULL(cmp2.cmp_mailto_zip,'')
	    END,
		ivh_billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
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
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_consignee_address = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_consignee_address2 = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 ivh_consignee_nmstct = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
			END),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
			END),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct) -1
			END),'')
	    END,
	ivh_consignee_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    END,
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
		cht.cht_rollintolh,
ivd.ivd_number
    FROM 	invoiceheader, 
		company cmp1, 
		company cmp2,
		company cmp3,
		city cty1, 
		city cty2, 
		invoicedetail ivd left outer join stops stp on ivd.stp_number = stp.stp_number left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code, --pts40029 outer join conversion
		chargetype cht
   WHERE		 ( invoiceheader.ivh_mbnumber = @mbnumber )
		AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
		AND (cmp3.cmp_id = invoiceheader.ivh_consignee) 
		AND (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND (cty2.cty_code = invoiceheader.ivh_destcity)
		AND (ivd.cht_itemcode = cht.cht_itemcode)
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
     INSERT INTO 	#masterbill_temp
     SELECT 	IsNull(invoiceheader.ord_hdrnumber,-1),
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		invoiceheader.ivh_billto,   
		invoiceheader.ivh_shipper,
		invoiceheader.ivh_consignee,
		invoiceheader.ivh_totalcharge,   
		invoiceheader.ivh_originpoint,  
		invoiceheader.ivh_destpoint,   
		invoiceheader.ivh_origincity,   
		invoiceheader.ivh_destcity,   
		invoiceheader.ivh_shipdate,   
		invoiceheader.ivh_deliverydate,   		invoiceheader.ivh_revtype1,
		@mbnumber     ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_shipto_address = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address1,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address1,'')
		ELSE ISNULL(cmp2.cmp_mailto_address1,'')
	    END,
	 ivh_shipto_address2 = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address2,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address2,'')
		ELSE ISNULL(cmp2.cmp_mailto_address2,'')
	    END,
	 ivh_shipto_nmstct = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN  0
			ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
			END),'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
			END),'')
		ELSE ISNULL(SUBSTRING(cmp2.mailto_cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp2.mailto_cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp2.mailto_cty_nmstct) -1
			END),'')
	    END,
	ivh_shipto_zip = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL  THEN ISNULL(cmp2.cmp_zip ,'')  
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_zip,'')
		ELSE ISNULL(cmp2.cmp_mailto_zip,'')
	    END,
		ivh_billto_name = cmp1.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
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
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_consignee_address = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
		ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    END,
	 ivh_consignee_address2 = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
		ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    END,
	 ivh_consignee_nmstct = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE 
			WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
			END),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE 
			WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
			END),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE
			WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1
			END),'')
	    END,
	ivh_consignee_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    END,
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
		ivd.ivd_type,		stp.stp_city,
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		ivd.cmp_id cmp_id,
		'',
		0,
		cht.cht_rollintolh,
ivd.ivd_number
	FROM 	invoiceheader, 
		company cmp1,
		company cmp2,
		company cmp3,
		city cty1, 
		city cty2,
		invoicedetail ivd left outer join stops stp on ivd.stp_number = stp.stp_number left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code, 
		chargetype cht
	WHERE 	( invoiceheader.ivh_billto = @billto )  
		AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		AND    ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
		AND     (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 
		AND    (cmp1.cmp_id = invoiceheader.ivh_billto)
		AND	(cmp2.cmp_id = invoiceheader.ivh_shipper)
	 	AND	(cmp3.cmp_id = invoiceheader.ivh_consignee)
		AND    (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND    (cty2.cty_code = invoiceheader.ivh_destcity)
		AND    (ivd.cht_itemcode = cht.cht_itemcode)
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND (@ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master'))
  END

  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.stp_cty_nmstct = city.cty_nmstct
  FROM		#masterbill_temp, city 
  WHERE		#masterbill_temp.stp_city = city.cty_code 

-- 41647 requires different reference number logic.  First look for a CCode at the orderheader level then freightdetail.  
update #masterbill_temp
set ord_firstref = ref.ref_number
from referencenumber ref, invoicedetail ivd
where ref.ref_type = 'CCODE' and ref.ref_table = 'freightdetail' 
and ivd.ivd_number = #masterbill_temp.ivd_number
and ref.ref_tablekey = ivd.fgt_number



update #masterbill_temp
set ord_firstref = (select top 1 isnull(ref_number, '') from referencenumber 
					where ref_type = 'CCODE' and ref_table = 'orderheader' and ord_hdrnumber = #masterbill_temp.ord_hdrnumber)
where isnull(ord_firstref, '') = ''	
		
/*

execute dbo.d_masterbill118_sp   @reprintflag = 'NO', @mbnumber = 0, @billto = 'INVDIREC', @revtype1 = 'UNK', @revtype2 = 'UNK', @mbstatus = 'RTP', 
@shipstart = {ts '2008-05-27 00:00:00.000'}, @shipend = {ts '2008-05-31 23:59:00.000'}, @billdate = {ts '2008-05-29 16:00:56.064'}, @shipper = 'UNKNOWN', 
@consignee = 'UNKNOWN', @copy = 1, @ivh_invoicenumber = 'Master'

select * from referencenumber where ord_hdrnumber in (3151,3160)
select * from freightdetail where stp_number in (select stp_number from invoicedetail where ord_hdrnumber in (3151,3160))
select * from invoicedetail where ord_hdrnumber in (3151,3160)
*/		

--select * from referencenumber where ord_hdrnumber in (3163)
--select * from invoicedetail where ord_hdrnumber in (3151,3160)

  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.ivh_totalweight = i.ivh_totalweight
  FROM		#masterbill_temp, invoiceheader i
  WHERE		#masterbill_temp.ivh_hdrnumber = i.ivh_hdrnumber and
		ivd_sequence=1

  UPDATE 	a 
  SET		a.ivd_rate=b.ivd_rate,
		a.ivd_rateunit=b.ivd_rateunit,
		a.ivd_charge=b.ivd_charge	
  FROM		#masterbill_temp  a ,#masterbill_temp b
  WHERE		a.ivh_invoicenumber = b.ivh_invoicenumber and
		a.ivd_sequence=1 and
		b.ivd_sequence=
		(select min(c.ivd_sequence) from #masterbill_temp c 
		where c.ivd_type='SUB' and c.ivh_invoicenumber=a.ivh_invoicenumber)

  delete from #masterbill_temp
  where ivd_sequence=(select min(c.ivd_sequence) from #masterbill_temp c 
		where c.ivd_type='SUB' and c.ivh_invoicenumber=#masterbill_temp.ivh_invoicenumber)


  SELECT * 
  FROM		#masterbill_temp
  ORDER BY	ord_hdrnumber, ivd_sequence

  DROP TABLE 	#masterbill_temp
GO
GRANT EXECUTE ON  [dbo].[d_masterbill118_sp] TO [public]
GO
