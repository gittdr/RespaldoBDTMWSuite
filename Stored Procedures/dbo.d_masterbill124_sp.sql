SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill124_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	@revtype1 varchar(6), @mbstatus varchar(6),@shipstart datetime,
        @shipend datetime,@billdate datetime, @shipper varchar(8),@consignee varchar(8),
        @copy int, @ivh_invoicenumber varchar(12))
AS
/**
 * DESCRIPTION:
 *
 * REVISION HISTORY:
-- 10/13/08 DPETE convert form d_masterbill08_ sp for PTD 44520
 *
 **/

DECLARE @int0  int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'


declare @masterbill_temp TABLE  (		ord_hdrnumber int,
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
		ivh_billto_name varchar(100)  NULL,
		ivh_billto_address varchar(100) NULL,
		ivh_billto_address2 varchar(100) NULL,
        ivh_billto_address3 varchar(100) NULL,
		ivh_billto_ctynmstct  varchar(30) NULL ,    --**
		ivh_billto_zip varchar(10) NULL,  --**
		ivh_ref_number varchar(30) NULL,
		ivh_tractor varchar(8) NULL,
		ivh_trailer varchar(13) NULL,
		origin_nmstct varchar(25) NULL,
		origin_state varchar(2) NULL,
		dest_nmstct varchar(25) NULL,
		dest_state varchar(2) NULL,
		billdate datetime NULL,
		--cmp_mailto_name varchar(30)  NULL,  --**
		bill_quantity float  NULL,
		ivd_refnumber varchar(30) NULL,
		ivd_weight float NULL,
		ivd_weightunit char(6) NULL,
		ivd_count int NULL,
		ivd_countunit char(6) NULL,
		ivd_volume float NULL,  --**sp_help invoicedetail
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
		stp_cty_nmstct varchar(30) NULL,  --**
		ivd_sequence int NULL,
		stp_number int NULL,
		copy int NULL,
		ref_number varchar(255) NULL,
		cmp_id varchar(8) NULL,
		cmp_name varchar(30) NULL,
		ivh_driver varchar(8) NULL,
		mpp_lastname varchar(40) NULL,
		mpp_firstname varchar(40) NULL,
		ivh_remark varchar(254) NULL,
        ord_number varchar(13) NULL )   --**



-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN
    INSERT INTO	@masterbill_temp
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
		ivh_billto_name = CASE isnull(cmp1.cmp_mailto_name,'') 
          when '' then cmp1.cmp_name
          else  cmp1.cmp_mailto_name
          end,
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
     ivh_billto_address3 = case isnull(cmp1.cmp_MAILTO_NAME,'')
        WHEN '' THEN ISNULL(CMP1.CMP_ADDRESS3,'')
        else ''
        end,  
	 ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct +'/',1,(CHARINDEX('/',cmp1.cty_nmstct + '/'))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct + '/',1,(CHARINDEX('/',cmp1.cty_nmstct + '/'))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct + '/',1,(CHARINDEX('/',cmp1.mailto_cty_nmstct + '/')) - 1),'')
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
		ref_number = case ivd_sequence
         when 1 then 
            case invoiceheader.ord_hdrnumber
            when 0 then dbo.RefsToCSV_fn('invoiceheader',invoiceheader.ivh_hdrnumber,'WITHTYPES')
            else dbo.RefsToCSV_fn('orderheader',invoiceheader.ord_hdrnumber,'WITHTYPES')
            end
         else ''
         end,
		ivd.cmp_id cmp_id,
		cmp2.cmp_name,
		invoiceheader.ivh_driver,
		mpp.mpp_lastname,
		mpp.mpp_firstname,
		invoiceheader.ivh_remark,
        ord_number
    --pts40029 jg outer join conversion
    FROM 	invoiceheader left outer join referencenumber ref on (invoiceheader.ord_hdrnumber = ref.ref_tablekey and ref.ref_table = 'orderheader' and ref.ref_sequence = 2)
						  left outer join manpowerprofile mpp on invoiceheader.ivh_driver = mpp.mpp_id, 
		company cmp1,
		company cmp2, 
        city bcty,
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
		AND ivd.cmp_id = cmp2.cmp_id 
        and bcty.cty_code = cmp1.cmp_city

  END

-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
     INSERT INTO 	@masterbill_temp
     SELECT IsNull(invoiceheader.ord_hdrnumber,-1),
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
            ivh_billto_name = CASE isnull(cmp1.cmp_mailto_name,'') 
          when '' then cmp1.cmp_name
          else  cmp1.cmp_mailto_name
          end,
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
     ivh_billto_address3 = case isnull(cmp1.cmp_MAILTO_NAME,'')
        WHEN '' THEN ISNULL(CMP1.CMP_ADDRESS3,'')
        else ''
        end,  
	 ivh_billto_nmstct = 
	    CASE
		WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct +'/',1,(CHARINDEX('/',cmp1.cty_nmstct + '/'))- 1),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct + '/',1,(CHARINDEX('/',cmp1.cty_nmstct + '/'))- 1),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct + '/',1,(CHARINDEX('/',cmp1.mailto_cty_nmstct + '/')) - 1),'')
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
            @billdate	billdate,
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
	    ref_number = case ivd_sequence
         when 1 then 
            case invoiceheader.ord_hdrnumber
            when 0 then dbo.RefsToCSV_fn('invoiceheader',invoiceheader.ivh_hdrnumber,'WITHTYPES')
            else dbo.RefsToCSV_fn('orderheader',invoiceheader.ord_hdrnumber,'WITHTYPES')
            end
         else ''
         end,
            ivd.cmp_id cmp_id,
	    cmp2.cmp_name,
	    invoiceheader.ivh_driver,
	    mpp.mpp_lastname,
	    mpp.mpp_firstname,
	    invoiceheader.ivh_remark,
        ord_number
       FROM invoiceheader left outer join referencenumber ref on (invoiceheader.ord_hdrnumber = ref.ref_tablekey and ref.ref_table = 'orderheader' and ref.ref_sequence = 2)
				left outer join manpowerprofile mpp on invoiceheader.ivh_driver = mpp.mpp_id, 
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
            cmp1.cmp_id = invoiceheader.ivh_billto and
            cty1.cty_code = invoiceheader.ivh_origincity and 
            cty2.cty_code = invoiceheader.ivh_destcity and
            ivd.cht_itemcode = cht.cht_itemcode and
            @shipper in (invoiceheader.ivh_shipper,'UNKNOWN') and
            @consignee IN (invoiceheader.ivh_consignee,'UNKNOWN') and
            @ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master') and
	        ivd.cmp_id = cmp2.cmp_id 

  END

  UPDATE 	@masterbill_temp 
  SET		stp_cty_nmstct = city.cty_nmstct
  FROM		@masterbill_temp mt join city on mt.stp_city = city.cty_code
  

  SELECT ord_hdrnumber ,
		ivh_invoicenumber , 
		ivh_hdrnumber , 
		ivh_billto ,
		ivh_shipper,
		ivh_consignee ,
		ivh_totalcharge,   
		ivh_originpoint,  
		ivh_destpoint,   
		ivh_origincity ,   
		ivh_destcity ,  
		ivh_shipdate ,   
		ivh_deliverydate ,   
		ivh_revtype1 ,
		ivh_mbnumber,
		ivh_billto_name ,
		ivh_billto_address ,
		ivh_billto_address2 ,
        ivh_billto_address3 ,
		ivh_billto_ctynmstct ,
		ivh_billto_zip ,
		ivh_ref_number ,
		ivh_tractor ,
		ivh_trailer ,
		origin_nmstct ,
		origin_state ,
		dest_nmstct ,
		dest_state,
		billdate ,
		bill_quantity ,
		ivd_refnumber ,
		ivd_weight,
		ivd_weightunit ,
		ivd_count ,
		ivd_countunit ,
		ivd_volume ,
		ivd_volunit ,
		ivd_unit ,
		ivd_rate ,
		ivd_rateunit ,
		ivd_charge ,
		cht_description ,
		cht_primary ,
		cmd_name,
		ivd_description ,
		ivd_type ,
		stp_city ,
		stp_cty_nmstct ,
		ivd_sequence ,
		stp_number ,
		copy ,
		ref_number ,
		cmp_id ,
		cmp_name ,
		ivh_driver ,
		mpp_lastname,
		mpp_firstname ,
		ivh_remark ,
        ord_number
  FROM		@masterbill_temp
  ORDER BY	ord_hdrnumber, ivd_sequence

 
GO
GRANT EXECUTE ON  [dbo].[d_masterbill124_sp] TO [public]
GO
