SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill132_sp] (@p_reprintflag 		varchar(10),
                                @p_mbnumber 		int,
                                @p_billto 		varchar(8), 
                                @p_revtype1 		varchar(6), 
                                @p_mbstatus 		varchar(6),
                                @p_shipstart 		datetime,
                                @p_shipend 		datetime,
                                @p_billdate 		datetime, 
                                @p_shipper 		varchar(8),
                                @p_consignee 		varchar(8),
                                @p_copy 		int, 
                                @p_ivh_invoicenumber 	varchar(12))
AS
DECLARE @v_int0  		int, 
        @v_gst_total 		money, 
        @v_fuelsurcharge_total 	money, 
        @v_minord 		int,
        @v_subtotal 		money, 
        @fuelsurcharge_total 	money, 
        @v_min_chrg_found 	int, 
        @v_min_seq 		int,
        @v_ref_number 		varchar(40),
        @linehaul_charge	money,
        @accessorials		money,
	@iva_tax		money,
	@retention_tax		money,
        @temp100		VARCHAR(100),
	@tmwuser		VARCHAR(255),
	@ivh_invoicenumber	VARCHAR(12),
        @invoicelist		VARCHAR(4000),
	@counter		INTEGER,
	@toll_charge		MONEY

CREATE TABLE #masterbill_temp (		
		ord_number varchar(12),
		ivh_invoicenumber varchar(12),  
		ivh_hdrnumber int NULL, 
		ivh_billto varchar(8) NULL,
		ivh_shipper varchar(8) NULL,
		ivh_consignee varchar(8) NULL,
		ivh_totalcharge money NULL,   
		ivh_originpoint  varchar(8) NULL,  
		ivh_destpoint varchar(8) NULL,   
		ivh_origincity int NULL,		--10   
		ivh_destcity int NULL,   
		ivh_shipdate datetime NULL,   
		ivh_deliverydate datetime NULL,   
		ivh_revtype1 varchar(6) NULL,
		ivh_mbnumber int NULL,
		ivh_billto_name varchar(100)  NULL,
		ivh_billto_address varchar(100) NULL,
		ivh_billto_address2 varchar(100) NULL,
		ivh_billto_nmstct varchar(25) NULL ,
		ivh_billto_zip varchar(9) NULL,		--20
		ivh_ref_number varchar(30) NULL,
		ivh_tractor varchar(8) NULL,
		ivh_trailer varchar(13) NULL,
		origin_nmstct varchar(25) NULL,
		origin_state varchar(2) NULL,
		dest_nmstct varchar(25) NULL,
		dest_state varchar(2) NULL,
		billdate datetime NULL,
		cmp_mailto_name varchar(100)  NULL,
		bill_quantity float  NULL,		--30
		ivd_refnumber varchar(30) NULL,
		ivd_weight float NULL,
		ivd_weightunit char(6) NULL,
		ivd_count float NULL,
		ivd_countunit char(6) NULL,
		ivd_volume float NULL,
		ivd_volunit char(6) NULL,
		ivd_unit varchar(6) NULL,
		ivd_rate money NULL,
		ivd_rateunit varchar(6) NULL,		--40
		ivd_charge money NULL,
		cht_description varchar(30) NULL,
		cht_primary char(1) NULL,
		cmd_name varchar(60)  NULL,
		ivd_description varchar(60) NULL,
		ivd_type char(6) NULL,
		stp_city int NULL,
		stp_cty_nmstct varchar(25) NULL,
		ivd_sequence int NULL,
		stp_number int NULL,		--50
		copy int NULL,
		ref_number varchar(30) NULL,
		cmp_id varchar(8) NULL,
		cmp_name varchar(100) NULL,
		ivh_remark varchar(254) NULL,
                cht_itemcode varchar(6) null,
                ivh_billto_address3 varchar(100) null,
                fuelsurcharge_total money null,
                gst_total money null,
                grand_subtotal money null,		--60
                ord_hdrnumber int null,
                ivh_currency varchar(6) null,
                shipper_name		VARCHAR(100),
                shipper_address 	VARCHAR(100),
                shipper_address2	VARCHAR(100),
                shipper_nmstct		VARCHAR(40),
                consignee_name		VARCHAR(100),
                consignee_address	VARCHAR(100),
                consignee_address2	VARCHAR(100),
                consignee_nmstct	VARCHAR(40),    --70
                linehaul_charge		MONEY,
                accessorials		MONEY,
                toll_charge		MONEY,
                iva_tax			MONEY,
                retention_tax		MONEY,
                ivh_terms               VARCHAR(6),
                terms_name		VARCHAR(20),
		ivh_driver		VARCHAR(8),
		mpp_firstname		VARCHAR(40),
		mpp_lastname		VARCHAR(40),    --80
		mpp_licensenumber	VARCHAR(25),
                trc_licnum		VARCHAR(12),
                trl_licnum		VARCHAR(12),
                user_revtype2		VARCHAR(20),
                ord_bookedby		VARCHAR(20),
		billto_taxid		VARCHAR(15),
		invoicelist		VARCHAR(4000))

CREATE TABLE #toll_charge
(
	cht_itemcode	VARCHAR(6) NULL
) 

SELECT  @v_int0 = 0

SELECT  @p_shipstart = convert(char(12),@p_shipstart)+'00:00:00'
SELECT  @p_shipend   = convert(char(12),@p_shipend  )+'23:59:59'

exec gettmwuser @tmwuser output

-- if printflag is set to REPRINT, retrieve an already printed mb by #
IF UPPER(@p_reprintflag) = 'REPRINT' 
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
		invoiceheader.ivh_origincity,		--10   
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
	    CASE		--20
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	    END,
		isnull(invoiceheader.ivh_ref_number,''),
		invoiceheader.ivh_tractor,
		invoiceheader.ivh_trailer,
		cty1.cty_nmstct   origin_nmstct,
		substring(cty1.cty_state,1,2)		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		substring(cty2.cty_state,1,2)		dest_state,
		ivh_billdate      billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		ivd.ivd_quantity 'bill_quantity',		--30
		IsNull(ivd.ivd_refnum, '') ivd_refnumber,
		IsNull(ivd.ivd_wgt, 0),
        IsNull(ivd.ivd_wgtunit, ''),
        IsNull(ivd.ivd_count, 0),
        IsNull(ivd.ivd_countunit, ''),
        IsNull(ivd.ivd_volume, 0),
        IsNull(ivd.ivd_volunit, ''),
        IsNull(ivd.ivd_unit, ''),
		Case cht.cht_basis WHEN 'TAX' then IsNull(ivd.ivd_rate, 0)/ 100.0000 else IsNull(ivd.ivd_rate, 0) end,
		IsNull(ivd.ivd_rateunit, ''),		--40
		ivd.ivd_charge,
		cht.cht_description,
		cht.cht_primary,
		cmd.cmd_name,
		IsNull(ivd_description, ''),
		ivd.ivd_type,
		stp.stp_city,
		'',
		ivd_sequence,
		IsNull(stp.stp_number, -1),		--50
		@p_copy,
        (select top 1 ref_number from referencenumber where ref_table = 'stops' and ref_type = 'BL#' and ref_tablekey = ivd.stp_number and ivd.stp_number > 0),
		ivd.cmp_id cmp_id,
		cmp2.cmp_name,
		invoiceheader.ivh_remark,
                cht.cht_itemcode,
                isnull(cmp1.cmp_address3,''),
                0, --fuelsurcharge
                0, --GST total
                0, --grand subtotal minus GST Tax		--60
                invoiceheader.ord_hdrnumber,
                invoiceheader.ivh_currency,
                ' ',
                ' ',
                ' ',
                ' ',
                ' ',
                ' ',
                ' ',
                ' ',                                            --70
                0,
                0,
		0,
                0,
                0,
                invoiceheader.ivh_terms,
                ' ',
                invoiceheader.ivh_driver,
		' ',
		' ',                                            --80
		' ',                                            
                ' ',
                ' ',
                ' ',
                ' ',
                cmp1.cmp_taxid,
		' '
    FROM invoiceheader
         join invoicedetail as ivd on (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber) 	
         left outer join commodity as cmd on (ivd.cmd_code = cmd.cmd_code) 
         left outer join stops as stp on (ivd.stp_number = stp.stp_number)
         left outer join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
         left outer join city cty1 on invoiceheader.ivh_origincity = cty1.cty_code
         left outer join city cty2 on invoiceheader.ivh_destcity = cty2.cty_code
         join company cmp1 on invoiceheader.ivh_billto = cmp1.cmp_id
         left outer join company cmp2 on  ivd.cmp_id = cmp2.cmp_id

   WHERE	(invoiceheader.ivh_mbnumber = @p_mbnumber )		


  END

-- for master bills with 'RTP' status

IF UPPER(@p_reprintflag) <> 'REPRINT' 
BEGIN
     INSERT INTO #masterbill_temp
     SELECT IsNull(invoiceheader.ord_number,''),
       	    invoiceheader.ivh_invoicenumber,  
            invoiceheader.ivh_hdrnumber, 
            invoiceheader.ivh_billto,   
            invoiceheader.ivh_shipper,
            invoiceheader.ivh_consignee,
            invoiceheader.ivh_totalcharge,   
            invoiceheader.ivh_originpoint,  
            invoiceheader.ivh_destpoint,   
            invoiceheader.ivh_origincity,		--10   
            invoiceheader.ivh_destcity, 
            invoiceheader.ivh_shipdate,   
            invoiceheader.ivh_deliverydate,
            invoiceheader.ivh_revtype1,
            @p_mbnumber     ivh_mbnumber,
            ivh_billto_name = cmp1.cmp_name,
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
	      CASE		--20
		WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
		ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	      END,
	    isnull(invoiceheader.ivh_ref_number,''),
	    invoiceheader.ivh_tractor,
	    invoiceheader.ivh_trailer,
            cty1.cty_nmstct   origin_nmstct,
            substring(cty1.cty_state,1,2)		origin_state,
            cty2.cty_nmstct   dest_nmstct,
            substring(cty2.cty_state,1,2)		dest_state,
            --PTS#23284 ILB 07/28/2004 
	    @p_billdate billdate,
	    --ivh_billdate      billdate,
	    --PTS#23284 ILB 07/28/2004
            ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
            ivd.ivd_quantity 'bill_quantity',		--30
	    IsNull(ivd.ivd_refnum, '') ivd_refnumber,   
            IsNull(ivd.ivd_wgt, 0),
            IsNull(ivd.ivd_wgtunit, ''),
            IsNull(ivd.ivd_count, 0),
            IsNull(ivd.ivd_countunit, ''),
            IsNull(ivd.ivd_volume, 0),
            IsNull(ivd.ivd_volunit, ''),
            IsNull(ivd.ivd_unit, ''),
            Case cht.cht_basis WHEN 'TAX' then IsNull(ivd.ivd_rate, 0)/ 100.0000 else IsNull(ivd.ivd_rate, 0) end,
            IsNull(ivd.ivd_rateunit, ''),		--40
            ivd.ivd_charge,
            cht.cht_description,
            cht.cht_primary,
            cmd.cmd_name,
            IsNull(ivd_description, ''),
            ivd.ivd_type,
            stp.stp_city,
            '',
            ivd_sequence,
            IsNull(stp.stp_number, -1),		--50
            @p_copy,
            (select top 1 ref_number from referencenumber where ref_table = 'stops' and ref_type = 'BL#' and ref_tablekey = ivd.stp_number and ivd.stp_number > 0),
            ivd.cmp_id cmp_id,
	    cmp2.cmp_name,
	    invoiceheader.ivh_remark,
            cht.cht_itemcode,
            isnull(cmp1.cmp_address3,''),
            0, --fuelsurcharge
            0, --GST total
            0, --grand subtotal minus GST Tax		--60 
            invoiceheader.ord_hdrnumber,
            invoiceheader.ivh_currency,
            ' ',
            ' ',
            ' ',
            ' ',
            ' ',
            ' ',
            ' ',
            ' ',					--70
            0,
            0,
	    0,
            0,
            0,
            invoiceheader.ivh_terms,
            ' ',
            invoiceheader.ivh_driver,
            ' ',
            ' ',					--80
            ' ',
            ' ',
            ' ',
            ' ',
            ' ',
            cmp1.cmp_taxid,
            ' '
       FROM invoiceheader
         join invoicedetail as ivd on (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber) 	
         left outer join commodity as cmd on (ivd.cmd_code = cmd.cmd_code) 
         left outer join stops as stp on (ivd.stp_number = stp.stp_number)
         left outer join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
         left outer join city cty1 on invoiceheader.ivh_origincity = cty1.cty_code
         left outer join city cty2 on invoiceheader.ivh_destcity = cty2.cty_code
         join company cmp1 on invoiceheader.ivh_billto = cmp1.cmp_id
         left outer join company cmp2 on  ivd.cmp_id = cmp2.cmp_id

       WHERE invoiceheader.ivh_billto = @p_billto and 
            invoiceheader.ivh_shipdate between @p_shipstart AND @p_shipend and 
            invoiceheader.ivh_mbstatus = 'RTP' and 
            @p_revtype1 in (invoiceheader.ivh_revtype1,'UNK') and 
            @p_shipper in (invoiceheader.ivh_shipper,'UNKNOWN') and
            @p_consignee IN (invoiceheader.ivh_consignee,'UNKNOWN') and
            ivd.ivd_type <> 'PUP'
       ORDER BY invoiceheader.ivh_shipdate
  END

UPDATE #masterbill_temp 
   SET #masterbill_temp.stp_cty_nmstct = city.cty_nmstct
  FROM #masterbill_temp, city 
 WHERE #masterbill_temp.stp_city = city.cty_code

UPDATE #masterbill_temp  
   SET shipper_name = company.cmp_name,  
       shipper_address = company.cmp_address1,  
       shipper_address2 = company.cmp_address2,  
       shipper_nmstct = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,'')  
  FROM #masterbill_temp, company  
 WHERE company.cmp_id = #masterbill_temp.ivh_shipper

UPDATE #masterbill_temp  
   SET consignee_name = company.cmp_name,  
       consignee_address = company.cmp_address1,  
       consignee_address2 = company.cmp_address2,  
       consignee_nmstct = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + IsNull(company.cmp_zip,'')  
  FROM #masterbill_temp, company  
 WHERE company.cmp_id = #masterbill_temp.ivh_consignee

UPDATE #masterbill_temp  
   SET terms_name = la.name  
  FROM labelfile la  
 WHERE la.labeldefinition = 'creditterms' 
	   AND la.abbr = #masterbill_temp.ivh_terms

SELECT @linehaul_charge = SUM(ivd_charge)
  FROM #masterbill_temp
 WHERE #masterbill_temp.ivd_type = 'SUB'

UPDATE #masterbill_temp
   SET linehaul_charge = @linehaul_charge

SELECT @accessorials = ISNULL(SUM(ivd_charge), 0)
  FROM #masterbill_temp
 WHERE #masterbill_temp.ivd_type = 'LI' AND
       #masterbill_temp.cht_itemcode NOT IN ('PST', 'GST')

UPDATE #masterbill_temp
   SET accessorials = @accessorials

INSERT INTO #toll_charge
   SELECT DISTINCT cht_itemcode
     FROM tollbooth
    WHERE cht_itemcode IS NOT NULL AND
          cht_itemcode <> 'UNK'
SELECT @toll_charge = ISNULL(SUM(ivd_charge), 0)
  FROM #masterbill_temp
 WHERE #masterbill_temp.ivd_type = 'LI' AND
       #masterbill_temp.cht_itemcode IN (SELECT #toll_charge.cht_itemcode
                                           FROM #toll_charge)

UPDATE #masterbill_temp
   SET toll_charge = @toll_charge

SELECT @iva_tax = ISNULL(SUM(ivd_charge), 0)
  FROM #masterbill_temp
 WHERE #masterbill_temp.ivd_type = 'LI' AND
       #masterbill_temp.cht_itemcode = 'GST'

UPDATE #masterbill_temp
   SET iva_tax = @iva_tax

SELECT @retention_tax = ISNULL(SUM(ivd_charge), 0)
  FROM #masterbill_temp
 WHERE #masterbill_temp.ivd_type = 'LI' AND
       #masterbill_temp.cht_itemcode = 'PST'

UPDATE #masterbill_temp
   SET retention_tax = @retention_tax

UPDATE #masterbill_temp
   SET mpp_firstname = manpowerprofile.mpp_firstname,
       mpp_lastname = manpowerprofile.mpp_lastname,
       mpp_licensenumber = manpowerprofile.mpp_licensenumber
  FROM #masterbill_temp, manpowerprofile
 WHERE manpowerprofile.mpp_id = #masterbill_temp.ivh_driver AND
       #masterbill_temp.ivh_driver <> 'UNKNOWN'

UPDATE #masterbill_temp
   SET trc_licnum = tractorprofile.trc_licnum
  FROM #masterbill_temp, tractorprofile
 WHERE tractorprofile.trc_number = #masterbill_temp.ivh_tractor AND
       #masterbill_temp.ivh_tractor <> 'UNKNOWN'

UPDATE #masterbill_temp
   SET trl_licnum = trailerprofile.trl_licnum
  FROM #masterbill_temp, trailerprofile
 WHERE trailerprofile.trl_number = #masterbill_temp.ivh_trailer AND
       #masterbill_temp.ivh_trailer <> 'UNKNOWN'

UPDATE #masterbill_temp
   SET user_revtype2 = ISNULL(labelfile.name,'UNKNOWN')
  FROM labelfile
 WHERE labelfile.labeldefinition = 'RevType2' AND
       labelfile.abbr = (SELECT usr_type2
                           FROM ttsusers
                          WHERE usr_userid = @tmwuser)

UPDATE #masterbill_temp
   SET ord_bookedby = orderheader.ord_bookedby
  FROM #masterbill_temp, orderheader
 WHERE orderheader.ord_hdrnumber = #masterbill_temp.ord_hdrnumber

DECLARE curs1 CURSOR FOR
   SELECT DISTINCT ivh_invoicenumber
     FROM #masterbill_temp

SET @counter = 0
OPEN curs1
FETCH NEXT FROM curs1 into @ivh_invoicenumber
WHILE @@FETCH_STATUS = 0
BEGIN
   IF @counter = 0
   BEGIN
      SET @invoicelist = @ivh_invoicenumber
      SET @counter = 1
   END
   ELSE
   BEGIN
      SET @invoicelist = @invoicelist + ', ' + @ivh_invoicenumber
   END

   FETCH NEXT FROM curs1 INTO @ivh_invoicenumber
END
CLOSE curs1
DEALLOCATE curs1

UPDATE #masterbill_temp
   SET invoicelist = @invoicelist

SELECT ord_number ,
       ivh_invoicenumber, 
       ivh_hdrnumber, 
       ivh_billto,
       ivh_shipper,
       ivh_consignee,
       ivh_totalcharge,   
       ivh_originpoint,  
       ivh_destpoint,   
       ivh_origincity ,		--10   
       ivh_destcity ,   
       ivh_shipdate ,   
       ivh_deliverydate ,   
       ivh_revtype1 ,
       ivh_mbnumber ,
       ivh_billto_name ,
       ivh_billto_address ,
       ivh_billto_address2 ,
       ivh_billto_nmstct ,
       ivh_billto_zip,		--20
       ivh_ref_number ,
       ivh_tractor ,   
       ivh_trailer ,
       origin_nmstct ,
       origin_state ,
       dest_nmstct ,
       dest_state ,
       billdate,
       cmp_mailto_name ,
       bill_quantity ,		--30
       ivd_refnumber ,
       ivd_weight ,
       ivd_weightunit ,
       ivd_count ,
       ivd_countunit ,
       ivd_volume ,
       ivd_volunit ,
       ivd_unit ,
       ivd_rate,
       ivd_rateunit ,		--40
       ivd_charge ,
       cht_description ,
       cht_primary ,
       cmd_name,
       ivd_description,
       ivd_type ,
       stp_city,
       stp_cty_nmstct ,
       ivd_sequence ,
       stp_number,		--50
       copy ,
       ref_number ,
       cmp_id ,
       cmp_name ,
       ivh_remark ,
        cht_itemcode,
       ivh_billto_address3 ,
       fuelsurcharge_total,
       gst_total ,
       grand_subtotal,		--60
       ord_hdrnumber ,
       ivh_currency,
       shipper_name,
       shipper_address,
       shipper_address2,
       shipper_nmstct,
       consignee_name,
       consignee_address,
       consignee_address2,
       consignee_nmstct,	--70
       linehaul_charge,
       accessorials,
       toll_charge,
       iva_tax,
       retention_tax,
       ivh_terms,
       terms_name,
       ivh_driver,
       mpp_firstname,
       mpp_lastname,            --80
       mpp_licensenumber,
       trc_licnum,
       trl_licnum,
       user_revtype2,
       ord_bookedby,
       billto_taxid,
       invoicelist
  FROM		#masterbill_temp
  ORDER BY	ord_number, ivd_sequence

  DROP TABLE 	#masterbill_temp
GO
GRANT EXECUTE ON  [dbo].[d_masterbill132_sp] TO [public]
GO
