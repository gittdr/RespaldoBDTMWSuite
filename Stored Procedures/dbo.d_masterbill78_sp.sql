SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[d_masterbill78_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
	                       @shipstart datetime,@shipend datetime,@billdate datetime, 
                               @shipper varchar(8), @consignee varchar(8),
                               @copy int,@ivh_invoicenumber varchar(12),
			       @delstart datetime, @delend datetime,
			       @revtype3 varchar(6), @revtype4 varchar(6))
AS

DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
Select @delstart = convert(char(12),@delstart)+'00:00:00'  
Select @delend   = convert(char(12),@delend  )+'23:59:59'


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
		ivd_description varchar(60) NULL,
		ivd_type char(6) NULL,
		stp_city int NULL,
		stp_cty_nmstct varchar(30) NULL,
		ivd_sequence int NULL,
		stp_number int NULL,
		copy int NULL,
		--MRK
		ref_number varchar(50) NULL,
		cmd_code   varchar(8) NULL,
		--MRK
		cmp_id varchar(8) NULL,
		ord_firstref varchar(30) NULL,
		ivh_totalweight float NULL,
		ivd_groupcontrol float,
		ivd_refnum VARCHAR(30) NULL,		
		cht_basisunit varchar(6) NULL,
		fgt_number INT NULL)
	
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

	 ivh_shipto_address =  ISNULL(cmp2.cmp_address1,''),

	 ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),

	 ivh_shipto_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
			     WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
			     ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
			    END),''),
		
	ivh_shipto_zip = ISNULL(cmp2.cmp_zip ,''), 
	ivh_billto_name = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_name,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_name,'')
		ELSE ISNULL(cmp1.cmp_mailto_name,'')
	   END,
		
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
	 ivh_consignee_address = ISNULL(cmp3.cmp_address1,''),
	
	 ivh_consignee_address2 = ISNULL(cmp3.cmp_address2,''),

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
		--ivh_billdate      billdate,
		case invoiceheader.ivh_invoicestatus
			--when 'RTP' then getdate()			-- NQIAO 08/27/12 PTS 61310 <start>
			--else ivh_billdate
			when 'NTP' then getdate()
			when 'RTP' then getdate()
			else ivh_printdate					-- NQIAO 08/27/12 PTS 61310 <end>
		end billdate,  
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
		IsNull(ivd.ivd_description, ''),
		ivd.ivd_type,
		stp.stp_city,
		'',
		ivd.ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		-- MRK
		'',
		cmd.cmd_code,
		-- MRK
		ivd.cmp_id cmp_id,
		ISNULL(ivh_ref_number, ''),
		ivh_totalweight,
		0 ivd_groupcontrol,
		ivd_refnum = ISNULL(ivd.ivd_refnum, ''),
		cht.cht_basisunit,
		ISNULL(ivd.fgt_number, 0)
				
	FROM 	invoiceheader INNER JOIN invoicedetail ivd
	        ON invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
		LEFT OUTER JOIN stops stp
		ON ivd.stp_number = stp.stp_number
		LEFT OUTER JOIN commodity cmd
		ON ivd.cmd_code = cmd.cmd_code
		INNER JOIN company cmp1
		ON invoiceheader.ivh_billto = cmp1.cmp_id
		INNER JOIN company cmp2
		ON invoiceheader.ivh_shipper = cmp2.cmp_id
		INNER JOIN company cmp3
		ON invoiceheader.ivh_consignee = cmp3.cmp_id
		INNER JOIN city cty1
		ON invoiceheader.ivh_origincity = cty1.cty_code
		INNER JOIN city cty2
		ON invoiceheader.ivh_destcity = cty2.cty_code
		INNER JOIN chargetype cht
		ON ivd.cht_itemcode = cht.cht_itemcode
	WHERE   ( invoiceheader.ivh_mbnumber = @mbnumber )
		AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
	
		
		-- MRK
		--update #masterbill_temp
		--set ref_number = (select dbo.fcn_Freightreferencenumbers_by_type_comma_sep(fgt_number)
		--		from freightdetail fgt
		--		where fgt.stp_number = #masterbill_temp.stp_number
		--		and fgt.cmd_code = #masterbill_temp.cmd_code)
		--from #masterbill_temp
		-- MRK
		
		

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
	 ivh_shipto_address =  ISNULL(cmp2.cmp_address1,''),

	 ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),

	 ivh_shipto_nmstct = ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
			     WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
			     ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
			    END),''),
		
	ivh_shipto_zip = ISNULL(cmp2.cmp_zip ,''), 
	ivh_billto_name = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_name,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_name,'')
		ELSE ISNULL(cmp1.cmp_mailto_name,'')
	   END,
		
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
	 ivh_consignee_address = ISNULL(cmp3.cmp_address1,''),
	
	 ivh_consignee_address2 = ISNULL(cmp3.cmp_address2,''),

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
		--ivh_billdate      billdate,
		case invoiceheader.ivh_invoicestatus
			--when 'RTP' then getdate()			-- NQIAO 08/27/12 PTS 61310 <start>
			--else ivh_billdate
			when 'NTP' then getdate()
			when 'RTP' then getdate()
			else ivh_printdate					-- NQIAO 08/27/12 PTS 61310 <end>
		end billdate,  
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
		IsNull(ivd.ivd_description, ''),
		ivd.ivd_type,
		stp.stp_city,
		'',
		ivd.ivd_sequence,
		IsNull(stp.stp_number, -1),
		@copy,
		--MRK
		'',
		cmd.cmd_code,
		--MRK
		ivd.cmp_id cmp_id,
		ISNULL(ivh_ref_number, ''),
		ivh_totalweight,
		0 ivd_groupcontrol,
		ivd_refnum = ISNULL(ivd.ivd_refnum, ''),
		cht.cht_basisunit,
		ISNULL(ivd.fgt_number, 0)
				
	FROM 	invoiceheader INNER JOIN invoicedetail ivd
	        ON invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber AND 
		invoiceheader.ivh_billto = @billto
		LEFT OUTER JOIN stops stp
		ON ivd.stp_number = stp.stp_number
		LEFT OUTER JOIN commodity cmd
		ON ivd.cmd_code = cmd.cmd_code
		INNER JOIN company cmp1
		ON invoiceheader.ivh_billto = cmp1.cmp_id
		INNER JOIN company cmp2
		ON invoiceheader.ivh_shipper = cmp2.cmp_id
		INNER JOIN company cmp3
		ON invoiceheader.ivh_consignee = cmp3.cmp_id
		INNER JOIN city cty1
		ON invoiceheader.ivh_origincity = cty1.cty_code
		INNER JOIN city cty2
		ON invoiceheader.ivh_destcity = cty2.cty_code
		INNER JOIN chargetype cht
		ON ivd.cht_itemcode = cht.cht_itemcode

	WHERE  
		( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
		AND    ( invoiceheader.ivh_deliverydate between @delstart AND @delend )
		AND     (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK'))
		AND (@revtype3 in (invoiceheader.ivh_revtype3,'UNK'))
		AND (@revtype4 in (invoiceheader.ivh_revtype4,'UNK'))
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND (@ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master'))
		
		-- MRK
		--update #masterbill_temp
		--set ref_number = (select dbo.fcn_Freightreferencenumbers_by_type_comma_sep(fgt_number, 'BL#')
		--		from freightdetail fgt
		--		where fgt.stp_number = #masterbill_temp.stp_number
		---		and fgt.cmd_code = #masterbill_temp.cmd_code)
		--from #masterbill_temp
		-- MRK

  END

  SELECT * 
  FROM		#masterbill_temp
  ORDER BY	ord_hdrnumber, ivd_sequence

  DROP TABLE 	#masterbill_temp


GO
GRANT EXECUTE ON  [dbo].[d_masterbill78_sp] TO [public]
GO
