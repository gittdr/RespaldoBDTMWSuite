SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill110_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	@revtype1 varchar(6), @mbstatus varchar(6),
	@shipstart datetime,@shipend datetime,@billdate datetime,@copy int)
AS

/**
 * DESCRIPTION:
 * Created to allow reprinting of masterbills
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
 * PTS 39613 create as copy of d_masterbill36_sp DPETE for AllCoast
 * PTS 41943 BDH 4/3/08  Returning orig & dest names and only records with a ivd_charge > 0.
 *
 **/

DECLARE  @gst_idnumber varchar(60)


SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'


if @revtype1 = 'UNK' select @revtype1 = 'ALL'




  
select @gst_idnumber = gi_string1
  from generalinfo
 where upper(gi_name) = 'GSTNUMBER'

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN

 
    SELECT oh.ord_number,
	invoiceheader.ord_hdrnumber,
	invoiceheader.ivh_invoicenumber,  
	invoiceheader.ivh_hdrnumber, 
        invoiceheader.ivh_billto,   
        invoiceheader.ivh_totalcharge,   
        invoiceheader.ivh_originpoint,  
        invoiceheader.ivh_destpoint,   
        invoiceheader.ivh_origincity,   
        invoiceheader.ivh_destcity,   
        invoiceheader.ivh_shipdate,   
        invoiceheader.ivh_deliverydate,   
        invoiceheader.ivh_revtype1,
	invoiceheader.ivh_mbnumber,
	shipper_name = cmp3.cmp_name,
	shipper_address = ISNULL(cmp3.cmp_address1,''),
	shipper_address2 = ISNULL(cmp3.cmp_address2,''),
	shipper_nmstct = case CHARINDEX('/',cmp3.mailto_cty_nmstct)
		WHEN 0 THEN cmp3.mailto_cty_nmstct
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct)) - 1),'')
	    END,
	shipper_zip = ISNULL(cmp3.cmp_zip,''),
	billto_name = CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_name,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_name,'')
		ELSE ISNULL(cmp1.cmp_mailto_name,'')
	    END,
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
	    CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN
              CASE  CHARINDEX('/',cmp1.cty_nmstct)
                WHEN 0 THEN cmp1.cty_nmstct
                ELSE ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
                END
		ELSE  CASE  CHARINDEX('/',cmp1.mailto_cty_nmstct)
                WHEN 0 then cmp1.mailto_cty_nmstct
                ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
		        END
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
	'',  --  ref# from format 36 not used on this format
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
	case isnull(ivd.stp_number,0) when 0 then '' else (select cty_nmstct from city where cty_code = stops.stp_city) end,
	stops.stp_city,
	cmd.cmd_name,
	invoiceheader.tar_tarriffnumber,
	cmp1.cmp_altid,
	@copy,
	cht.cht_primary,
	cht.cht_description,
	ivd.ivd_sequence,
	invoiceheader.ivh_ref_number,  
        ivd.cht_itemcode,
        cht.cht_basis ,
        cht.cht_taxtable1 ,
        cht.cht_taxtable2,
        @gst_idnumber gst_idnumber,
	isnull(invoiceheader.ivh_trailer, 'UNKNOWN')
-- 41943 start
	, cmp4.cmp_name 'orig_name'
	, cty1.cty_nmstct 'orig_nmstct'
	, cmp5.cmp_name 'dest_name'
-- 41943 end
    FROM invoiceheader  LEFT OUTER JOIN  orderheader oh  ON  invoiceheader.ord_hdrnumber  = oh.ord_hdrnumber   
			LEFT OUTER JOIN  company cmp1  ON  cmp1.cmp_id  = invoiceheader.ivh_billto   
			LEFT OUTER JOIN  company cmp3  ON  cmp3.cmp_id  = invoiceheader.ivh_shipper 
            LEFT OUTER JOIN city cty1 on invoiceheader.ivh_origincity = cty1.cty_code
            left OUTER JOIN city cty2 on invoiceheader.ivh_destcity = cty2.cty_code
	 join invoicedetail ivd on invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
     JOIN chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
     LEFT OUTER JOIN  stops  ON  ivd.stp_number  = stops.stp_number   
	 LEFT OUTER JOIN  commodity cmd  ON  ivd.cmd_code  = cmd.cmd_code 
LEFT OUTER JOIN  company cmp4  ON  cmp4.cmp_id = invoiceheader.ivh_originpoint  -- 41943
LEFT OUTER JOIN  company cmp5  ON  cmp5.cmp_id = invoiceheader.ivh_destpoint  -- 41943
   WHERE ( invoiceheader.ivh_mbnumber = @mbnumber ) 
	and IsNull(ivd.ivd_charge, 0) > 0  -- 41943
   ORDER by ivh_invoicenumber,ivd_sequence

  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN

 
    SELECT oh.ord_number,
	invoiceheader.ord_hdrnumber,
	invoiceheader.ivh_invoicenumber,  
	invoiceheader.ivh_hdrnumber, 
        invoiceheader.ivh_billto,   
        invoiceheader.ivh_totalcharge,   
        invoiceheader.ivh_originpoint,  
        invoiceheader.ivh_destpoint,   
        invoiceheader.ivh_origincity,   
        invoiceheader.ivh_destcity,   
        invoiceheader.ivh_shipdate,   
        invoiceheader.ivh_deliverydate,   
        invoiceheader.ivh_revtype1,
        @mbnumber ivh_mbnumber, 
	shipper_name = cmp3.cmp_name,
	shipper_address = ISNULL(cmp3.cmp_address1,''),
	shipper_address2 = ISNULL(cmp3.cmp_address2,''),
	shipper_nmstct = case CHARINDEX('/',cmp3.mailto_cty_nmstct)
		WHEN 0 THEN cmp3.mailto_cty_nmstct
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,(CHARINDEX('/',cmp3.mailto_cty_nmstct)) - 1),'')
	    END,
	shipper_zip = ISNULL(cmp3.cmp_zip,''),
	billto_name = CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_name,'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_name,'')
		ELSE ISNULL(cmp1.cmp_mailto_name,'')
	    END,
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
	    CASE rtrim(isnull(cmp1.cmp_mailto_name,''))
		WHEN '' THEN
              CASE  CHARINDEX('/',cmp1.cty_nmstct)
                WHEN 0 THEN cmp1.cty_nmstct
                ELSE ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
                END
		ELSE  CASE  CHARINDEX('/',cmp1.mailto_cty_nmstct)
                WHEN 0 then cmp1.mailto_cty_nmstct
                ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
		        END
	    END,
	billto_zip = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
	cty2.cty_nmstct   dest_nmstct,
	cty2.cty_state		dest_state,
	@billdate billdate,
	'', --  ref# from format 36 not used on this format
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
	case isnull(ivd.stp_number,0) when 0 then '' else (select cty_nmstct from city where cty_code = stops.stp_city) end,
	stops.stp_city,
	cmd.cmd_name,
	invoiceheader.tar_tarriffnumber,
	IsNull(cmp1.cmp_altid, ''),
	@copy,
	cht.cht_primary,
	cht.cht_description,
	ivd.ivd_sequence,
	--ILB 10-18-2002 PTS# 15194
	invoiceheader.ivh_ref_number, 
	--ILB 10-18-2002 PTS# 15194
        ivd.cht_itemcode,
         cht.cht_basis ,
        cht.cht_taxtable1 ,
        cht.cht_taxtable2,
        @gst_idnumber gst_idnumber,
	isnull(invoiceheader.ivh_trailer, 'UNKNOWN')
-- 41943 start
	, cmp4.cmp_name 'orig_name'
	, cty1.cty_nmstct 'orig_nmstct'
	, cmp5.cmp_name 'dest_name'
-- 41943 end
     FROM invoiceheader  LEFT OUTER JOIN  orderheader oh  ON  invoiceheader.ord_hdrnumber  = oh.ord_hdrnumber   
			LEFT OUTER JOIN  company cmp1  ON  cmp1.cmp_id  = invoiceheader.ivh_billto   
			LEFT OUTER JOIN  company cmp3  ON  cmp3.cmp_id  = invoiceheader.ivh_shipper 
            LEFT OUTER JOIN city cty1 on invoiceheader.ivh_origincity = cty1.cty_code
            left OUTER JOIN city cty2 on invoiceheader.ivh_destcity = cty2.cty_code
	 join invoicedetail ivd on invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
     JOIN chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
     LEFT OUTER JOIN  stops  ON  ivd.stp_number  = stops.stp_number   
	 LEFT OUTER JOIN  commodity cmd  ON  ivd.cmd_code  = cmd.cmd_code 
LEFT OUTER JOIN  company cmp4  ON  cmp4.cmp_id = invoiceheader.ivh_originpoint  -- 41943
LEFT OUTER JOIN  company cmp5  ON  cmp5.cmp_id = invoiceheader.ivh_destpoint  -- 41943
   WHERE ( invoiceheader.ivh_billto = @billto )  
     AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
     AND (ivd.cht_itemcode = cht.cht_itemcode)
     AND (invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
     AND (invoiceheader.ivh_mbstatus = 'RTP') 
     AND (@revtype1 in (invoiceheader.ivh_revtype1,'ALL')) 
     AND (cmp3.cmp_id = invoiceheader.ivh_shipper)
     AND (cty1.cty_code = invoiceheader.ivh_origincity) 
     AND (cty2.cty_code = invoiceheader.ivh_destcity)
	and IsNull(ivd.ivd_charge, 0) > 0  -- 41943
   ORDER by ivh_invoicenumber,ivd_sequence           
  END


GO
GRANT EXECUTE ON  [dbo].[d_masterbill110_sp] TO [public]
GO
