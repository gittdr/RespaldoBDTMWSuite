SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill56_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
	                       @shipstart datetime,@shipend datetime,@billdate datetime, 
                               @showshipper varchar(8), @showconsignee varchar(8),
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
-- 07/25/2002	Vern Jewett (label=vmj1)	PTS 14924: lengthen ivd_description from 30 to
--											60 chars.
 * 10/30/2007.01 ? PTS40029 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
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
		ivh_shipper_name varchar(30) NULL ,  --16
		ivh_shipper_address varchar(40) NULL,
		ivh_shipper_address2 varchar(40) NULL,
		ivh_shipper_address3 varchar(40) NULL,
		ivh_shipper_nmstct varchar(25) NULL ,
		ivh_shipper_zip varchar(9) NULL,
		ivh_showshipper_name varchar(30) NULL ,  --22
		ivh_showshipper_address varchar(40) NULL,
		ivh_showshipper_address2 varchar(40) NULL,
		ivh_showshipper_address3 varchar(40) NULL,
		ivh_showshipper_nmstct varchar(25) NULL ,
		ivh_showshipper_zip varchar(9) NULL,
		ivh_billto_name varchar(30)  NULL,   --28
		ivh_billto_address varchar(40) NULL,
		ivh_billto_address2 varchar(40) NULL,
		ivh_billto_address3 varchar(40) NULL,
		ivh_billto_nmstct varchar(25) NULL ,
		ivh_billto_zip varchar(9) NULL,
		ivh_consignee_name varchar(30)  NULL,  --34
		ivh_consignee_address varchar(40) NULL,
		ivh_consignee_address2 varchar(40) NULL,
		ivh_consignee_address3 varchar(40) NULL,
		ivh_consignee_nmstct varchar(25)  NULL,
		ivh_consignee_zip varchar(9) NULL,
		ivh_showconsignee_name varchar(30) NULL ,  --40
		ivh_showconsignee_address varchar(40) NULL,
		ivh_showconsignee_address2 varchar(40) NULL,
		ivh_showconsignee_address3 varchar(40) NULL,
		ivh_showconsignee_nmstct varchar(25) NULL ,
		ivh_showconsignee_zip varchar(9) NULL, 
		origin_nmstct varchar(25) NULL,
		origin_state varchar(2) NULL,
		dest_nmstct varchar(25) NULL,
		dest_state varchar(2) NULL,
		billdate datetime NULL,
		cmp_mailto_name varchar(30)  NULL,
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
		stp_cty_nmstct varchar(25) NULL,
		ivd_sequence int NULL,
		stp_number int NULL,
		copy int NULL,
		cmp_id varchar(8) NULL,
		billto_terms varchar(20) NULL)



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
		ivh_shipto_name = cmp2.cmp_name,  --16
-- dpete for LOR pts4785 provide for maitlto override of billto
/*JLB PTS 26876 do not use mailto info
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
	 ivh_shipto_address3 = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address3,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address3,'')
		ELSE ISNULL(cmp2.cmp_mailto_address3,'')
	    END,
	 ivh_shipto_nmstct = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp2.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.mailto_cty_nmstct)- 1 < 0 THEN
							   0
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
	 ivh_billto_address3 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address3,'')
		ELSE ISNULL(cmp1.cmp_mailto_address3,'')
	    END,
	 ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN
							   0
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
	 ivh_consignee_address3 = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address3,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address3,'')
		ELSE ISNULL(cmp1.cmp_mailto_address3,'')
	    END,
	 ivh_consignee_nmstct = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
						      END),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct) -1
						      END),'')
	    END,
	ivh_consignee_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    END,
*/
	 ivh_shipto_address = ISNULL(cmp2.cmp_address1,''),
	 ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),
	 ivh_shipto_address3 = ISNULL(cmp2.cmp_address3,''),
	 ivh_shipto_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1 END),''),
	ivh_shipto_zip = ISNULL(cmp2.cmp_zip ,''),
	 ivh_showshipper_name = ISNULL(cmp4.cmp_name,''),
	 ivh_showshipper_address = ISNULL(cmp4.cmp_address1,''),
	 ivh_showshipper_address2 = ISNULL(cmp4.cmp_address2,''),
	 ivh_showshipper_address3 = ISNULL(cmp4.cmp_address3,''),  --25
	 ivh_showshipper_nmstct = ISNULL(SUBSTRING(cmp4.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp4.cty_nmstct)- 1 < 0 THEN 0
							ELSE CHARINDEX('/',cmp4.cty_nmstct) -1 END),''),
	ivh_showshipper_zip = ISNULL(cmp4.cmp_zip ,''),
		ivh_billto_name = cmp1.cmp_name,
	 ivh_billto_address = ISNULL(cmp1.cmp_address1,''),
	 ivh_billto_address2 = ISNULL(cmp1.cmp_address2,''),
	 ivh_billto_address3 = ISNULL(cmp1.cmp_address3,''),
	 ivh_billto_nmstct = ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1 END),''),
	ivh_billto_zip = ISNULL(cmp1.cmp_zip,''),
		ivh_consignee_name = cmp3.cmp_name,
	 ivh_consignee_address = ISNULL(cmp3.cmp_address1,''),
	 ivh_consignee_address2 = ISNULL(cmp3.cmp_address2,''),
	 ivh_consignee_address3 = ISNULL(cmp3.cmp_address3,''),
	 ivh_consignee_nmstct = ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) -1 END),''),
	ivh_consignee_zip = ISNULL(cmp3.cmp_zip,''),
		ivh_showconsignee_name = cmp5.cmp_name,
	 ivh_showconsignee_address = ISNULL(cmp5.cmp_address1,''),
	 ivh_showconsignee_address2 = ISNULL(cmp5.cmp_address2,''),
	 ivh_showconsignee_address3 = ISNULL(cmp5.cmp_address3,''),
	 ivh_showconsignee_nmstct = ISNULL(SUBSTRING(cmp5.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp5.cty_nmstct)- 1 < 0 THEN 0
							ELSE CHARINDEX('/',cmp5.cty_nmstct) -1 END),''),
	ivh_showconsignee_zip = ISNULL(cmp5.cmp_zip,''),    --45
--end PTS 26876
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
		cmd.cmd_name,							--65
		IsNull(ivd_description, ''),
		ivd.ivd_type,
		stp.stp_city,
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		ivd.cmp_id cmp_id,
		(select name from labelfile where labeldefinition = 'CreditTerms' and abbr = cmp1.cmp_terms) as 'cmp_terms'						--74
    FROM 	invoiceheader, 
		company cmp1, 
		company cmp2,
		company cmp3,
		company cmp4,
		company cmp5,
		city cty1, 
		city cty2, 
		invoicedetail ivd left outer join stops stp on ivd.stp_number = stp.stp_number left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code, 
		chargetype cht
   WHERE		 ( invoiceheader.ivh_mbnumber = @mbnumber )
		AND cmp4.cmp_id = invoiceheader.ivh_showshipper
		AND cmp5.cmp_id = invoiceheader.ivh_showcons
		AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
		AND (cmp3.cmp_id = invoiceheader.ivh_consignee) 
		AND (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND (cty2.cty_code = invoiceheader.ivh_destcity)
		AND (ivd.cht_itemcode = cht.cht_itemcode)
		AND (@showshipper IN(invoiceheader.ivh_showshipper,'UNKNOWN'))
		AND (@showconsignee IN (invoiceheader.ivh_showcons,'UNKNOWN'))

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
		invoiceheader.ivh_deliverydate,   		
		invoiceheader.ivh_revtype1,
		@mbnumber     ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,  --16
/*JLB PTS 26876 do not use mailto info
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
	 ivh_shipto_address3 = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN ISNULL(cmp2.cmp_address3,'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN ISNULL(cmp2.cmp_address3,'')
		ELSE ISNULL(cmp2.cmp_mailto_address3,'')
	    END,
	 ivh_shipto_nmstct = 
	    CASE
		WHEN cmp2.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),'')
		WHEN (cmp2.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp2.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.mailto_cty_nmstct)- 1 < 0 THEN
							   0
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
	 ivh_billto_address3 = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address3,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address3,'')
		ELSE ISNULL(cmp1.cmp_mailto_address3,'')
	    END,
	 ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct)- 1 < 0 THEN
							   0
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
	 ivh_consignee_address3 = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address3,'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address3,'')
		ELSE ISNULL(cmp1.cmp_mailto_address3,'')
	    END,
	 ivh_consignee_nmstct = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
						      END),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct) -1
						      END),'')
	    END,
	ivh_consignee_zip = 
	    CASE
		WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
		ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    END,
*/
	 ivh_shipto_address = ISNULL(cmp2.cmp_address1,''),
	 ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),
	 ivh_shipto_address3 = ISNULL(cmp2.cmp_address3,''),
	 ivh_shipto_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
							ELSE CHARINDEX('/',cmp2.cty_nmstct) -1 END),''),
	ivh_shipto_zip = ISNULL(cmp2.cmp_zip ,''),
    ivh_showshipper_name = ISNULL(cmp4.cmp_name,''),
	 ivh_showshipper_address = ISNULL(cmp4.cmp_address1,''),
	 ivh_showshipper_address2 = ISNULL(cmp4.cmp_address2,''),
	 ivh_showshipper_address3 = ISNULL(cmp4.cmp_address3,''),    --25
	 ivh_showshipper_nmstct = ISNULL(SUBSTRING(cmp4.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp4.cty_nmstct)- 1 < 0 THEN 0
							ELSE CHARINDEX('/',cmp4.cty_nmstct) -1 END),''),
	ivh_showshipper_zip = ISNULL(cmp4.cmp_zip ,''),
		ivh_billto_name = cmp1.cmp_name,
	 ivh_billto_address = ISNULL(cmp1.cmp_address1,''),
	 ivh_billto_address2 = ISNULL(cmp1.cmp_address2,''),
	 ivh_billto_address3 = ISNULL(cmp1.cmp_address3,''),
	 ivh_billto_nmstct = ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN 0
							ELSE CHARINDEX('/',cmp1.cty_nmstct) -1 END),''),
	ivh_billto_zip = ISNULL(cmp1.cmp_zip,''),
		ivh_consignee_name = cmp3.cmp_name,
	 ivh_consignee_address = ISNULL(cmp3.cmp_address1,''),
	 ivh_consignee_address2 = ISNULL(cmp3.cmp_address2,''),
	 ivh_consignee_address3 = ISNULL(cmp3.cmp_address3,''),
	 ivh_consignee_nmstct = ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) -1 END),''),
	ivh_consignee_zip = ISNULL(cmp3.cmp_zip,''),
		ivh_showconsignee_name = cmp5.cmp_name,		--40
	 ivh_showconsignee_address = ISNULL(cmp5.cmp_address1,''),
	 ivh_showconsignee_address2 = ISNULL(cmp5.cmp_address2,''),
	 ivh_showconsignee_address3 = ISNULL(cmp5.cmp_address3,''),
	 ivh_showconsignee_nmstct = ISNULL(SUBSTRING(cmp5.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp5.cty_nmstct)- 1 < 0 THEN 0
							ELSE CHARINDEX('/',cmp5.cty_nmstct) -1 END),''),
	ivh_showconsignee_zip = ISNULL(cmp5.cmp_zip,''),    --45
--end PTS 26876
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
		cmd.cmd_name,					--65
		IsNull(ivd_description, ''),
		ivd.ivd_type,
		stp.stp_city,
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		ivd.cmp_id cmp_id,	
		(select name from labelfile where labeldefinition = 'CreditTerms' and abbr = cmp1.cmp_terms) as 'cmp_terms'						--74
	FROM 	invoiceheader, 
		company cmp1,
		company cmp2,
		company cmp3,
		company cmp4,
		company cmp5,
		city cty1, 
		city cty2,
		invoicedetail ivd left outer join stops stp on ivd.stp_number = stp.stp_number left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code, 
		chargetype cht
	WHERE 	( invoiceheader.ivh_billto = @billto )  
      AND cmp4.cmp_id = invoiceheader.ivh_showshipper
      AND cmp5.cmp_id = invoiceheader.ivh_showcons
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
		AND (@showshipper IN(invoiceheader.ivh_showshipper,'UNKNOWN'))
		AND (@showconsignee IN (invoiceheader.ivh_showcons,'UNKNOWN'))
		AND (@ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master'))

  END

  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.stp_cty_nmstct = city.cty_nmstct
  FROM		#masterbill_temp, city 
  WHERE		#masterbill_temp.stp_city = city.cty_code 

  SELECT * 
  FROM		#masterbill_temp
  ORDER BY	ord_hdrnumber, ivh_invoicenumber, ivd_sequence

  DROP TABLE 	#masterbill_temp
GO
GRANT EXECUTE ON  [dbo].[d_masterbill56_sp] TO [public]
GO
