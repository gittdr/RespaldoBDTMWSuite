SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill07_sp] (
			@reprintflag varchar(10),
			@mbnumber int,
			@billto varchar(8), 
			@revtype1 varchar(6),
			@revtype2 varchar(6),		-- PTS 70500
			@revtype3 varchar(6),		-- PTS 70500
			@revtype4 varchar(6),		-- PTS 70500
			@mbstatus varchar(6),
			@shipstart datetime,
			@shipend datetime,
			@billdate datetime, 
			@shipper varchar(8),
			@consignee varchar(8),
			@copy int, 
			@ivh_invoicenumber varchar(12))
AS
/**
 * DESCRIPTION:
 *
 * REVISION HISTORY:
-- 10/7/99 dpete retrieve cmp_id for d_mb_format05
-- 10/9/01 dpete retrieve order number instead of ord_hdrnumber
-- 07/25/2002	Vern Jewett (label=vmj1)	PTS 14924: lengthen ivd_description from 30 to
--											60 chars
 * 10/29/2007.01 ? PTS40029 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 03/10/2010 PTS 51350 SGB Add cht_itemcode column
 * 07/03/2013 PTS 70500 NQIAO - add inputs @revtype2 ~ @revtype4
 **/


DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'


CREATE TABLE #masterbill_temp (		ord_number varchar(12),
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
		ivh_billto_name varchar(30)  NULL,
		ivh_billto_address varchar(40) NULL,
		ivh_billto_address2 varchar(40) NULL,
		ivh_billto_nmstct varchar(25) NULL ,
		ivh_billto_zip varchar(9) NULL,
		ivh_ref_number varchar(30) NULL,
		ivh_tractor varchar(8) NULL,
		ivh_trailer varchar(13) NULL,
		origin_nmstct varchar(25) NULL,
		origin_state varchar(2) NULL,
		dest_nmstct varchar(25) NULL,
		dest_state varchar(2) NULL,
		billdate datetime NULL,
		cmp_mailto_name varchar(30)  NULL,
		bill_quantity float  NULL,
		ivd_refnumber varchar(30) NULL,
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
		ref_number varchar(30) NULL,
		cmp_id varchar(8) NULL,
		cmp_name varchar(30) NULL,
		ivh_remark varchar(254) NULL,
		cht_itemcode varchar(6) NULL) -- PTS 51350 SGB 03/10/2010



-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN
    INSERT INTO	#masterbill_temp
    SELECT 	IsNull(invoiceheader.ord_number, ''),
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
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
	    END,
	ivh_billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		invoiceheader.ivh_ref_number,
		invoiceheader.ivh_tractor,
		invoiceheader.ivh_trailer,
		cty1.cty_nmstct   origin_nmstct,
		cty1.cty_state		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state		dest_state,
		ivh_billdate      billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',
		IsNull(ivd.ivd_refnum, ''),
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
		ref.ref_number,
		ivd.cmp_id cmp_id,
		cmp2.cmp_name,
		invoiceheader.ivh_remark,
		cht.cht_itemcode -- PTS 51350 SGB 03/10/2010
    --pts40029 jg outer join conversion
    FROM 	invoiceheader left outer join referencenumber ref on (invoiceheader.ord_hdrnumber = ref.ref_tablekey and ref.ref_table = 'orderheader' and ref.ref_sequence = 2), 
		company cmp1,
		company cmp2, 
		city cty1, 
		city cty2, 
		invoicedetail ivd left outer join stops stp on ivd.stp_number = stp.stp_number left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code, 
		chargetype cht
   WHERE	( invoiceheader.ivh_mbnumber = @mbnumber )
		AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		AND (cmp1.cmp_id = invoiceheader.ivh_billto) 
		AND (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND (cty2.cty_code = invoiceheader.ivh_destcity)
		AND (ivd.cht_itemcode = cht.cht_itemcode)
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND ivd.cmp_id = cmp2.cmp_id 

  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
     INSERT INTO 	#masterbill_temp
     SELECT IsNull(invoiceheader.ord_number,''),
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
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
	      END,
            ivh_billto_zip = 
	      CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	      END,
	    invoiceheader.ivh_ref_number,
	    invoiceheader.ivh_tractor,
	    invoiceheader.ivh_trailer,
            cty1.cty_nmstct   origin_nmstct,
            cty1.cty_state		origin_state,
            cty2.cty_nmstct   dest_nmstct,
            cty2.cty_state		dest_state,
            --PTS#23284 ILB 07/28/2004 
	    @billdate billdate,
	    --ivh_billdate      billdate,
	    --PTS#23284 ILB 07/28/2004
            ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
            ivd.ivd_quantity 'bill_quantity',
	    IsNull(ivd.ivd_refnum, ''),
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
	    ref.ref_number,
            ivd.cmp_id cmp_id,
	    cmp2.cmp_name,
	    invoiceheader.ivh_remark,
		cht.cht_itemcode -- PTS 51350 SGB 03/10/2010
       --pts40029 jg outer join conversion
       FROM invoiceheader left outer join referencenumber ref on (invoiceheader.ord_hdrnumber = ref.ref_tablekey and ref.ref_table = 'orderheader' and ref.ref_sequence = 2), 
            company cmp1,
	        company cmp2,
            city cty1, 
            city cty2,
            invoicedetail ivd left outer join stops stp on ivd.stp_number = stp.stp_number left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code, 
            chargetype cht
      WHERE invoiceheader.ivh_billto = @billto and
            invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber and
            invoiceheader.ivh_shipdate between @shipstart AND @shipend and 
            invoiceheader.ivh_mbstatus = 'RTP' and 
            @revtype1 in (invoiceheader.ivh_revtype1,'UNK') and 
            @revtype2 in (invoiceheader.ivh_revtype2,'UNK') and		-- PTS 70500
            @revtype3 in (invoiceheader.ivh_revtype3,'UNK') and		-- PTS 70500
            @revtype4 in (invoiceheader.ivh_revtype4,'UNK') and		-- PTS 70500
            cmp1.cmp_id = invoiceheader.ivh_billto and
            cty1.cty_code = invoiceheader.ivh_origincity and 
            cty2.cty_code = invoiceheader.ivh_destcity and
            ivd.cht_itemcode = cht.cht_itemcode and
            @shipper in (invoiceheader.ivh_shipper,'UNKNOWN') and
            @consignee IN (invoiceheader.ivh_consignee,'UNKNOWN') and
            @ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master') and
	        ivd.cmp_id = cmp2.cmp_id 

  END

  UPDATE 	#masterbill_temp 
  SET		#masterbill_temp.stp_cty_nmstct = city.cty_nmstct
  FROM		#masterbill_temp, city 
  WHERE		#masterbill_temp.stp_city = city.cty_code 

  SELECT * 
  FROM		#masterbill_temp
  ORDER BY	ord_number, ivd_sequence

  DROP TABLE 	#masterbill_temp
GO
GRANT EXECUTE ON  [dbo].[d_masterbill07_sp] TO [public]
GO
