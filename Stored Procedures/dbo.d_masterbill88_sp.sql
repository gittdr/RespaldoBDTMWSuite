SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


  
-- 10/7/99 dpete retrieve cmp_id for d_mb_format05
-- dpete pts6691 make ivd_count and volume floats on temp table
-- 07/25/2002	Vern Jewett (label=vmj1)	PTS 14924: lengthen ivd_description from 30 to
--
--											60 chars.
-- pts 31145 pbidi do not use mail to address for shipper and consignee.


CREATE PROC [dbo].[d_masterbill88_sp] (@p_reprintflag varchar(10),@p_mbnumber int,@p_billto varchar(8), 
	                       @p_revtype1 varchar(6), @p_revtype2 varchar(6),@p_mbstatus varchar(6),
	                       @p_shipstart datetime,@p_shipend datetime,@p_billdate datetime, 
                               @p_shipper varchar(8), @p_consignee varchar(8),
                               @p_copy int,@p_ivhinvoicenumber varchar(12))
AS
/**
 * 
 * NAME:
 * dbo.d_masterbill88_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION: Retrieves data to print a master bill (modified from d_mbformat04_sp
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @p_reprintflag varchar(10)
 * 002 - @p_mbnumber int,@p_billto varchar(8)
 * 003 - @p_revtype1 varchar(6)
 * 004 - @p_revtype2 varchar(6)
 * 005 - @p_mbstatus varchar(6)
 * 006 - @p_shipstart datetime
 * 007 - @p_shipend datetime
 * 008 - @p_billdate datetime 
 * 009 - @p_shipper varchar(8)
 * 010 - @p_consignee varchar(8)
 * 011 - @p_copy int
 * 012 - @p_ivhinvoicenumber varchar(12)
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 072406.01 PTS33610 - created for NOrthwest Tank copy of d_mbformat04_sp with additional return set
 * 020707.01 PTS36034 - declared @v_gstnumber variable to return gstnumber 
 *
 **/
--072406.01 PTS33610 - created for NOrthwest Tank copy of d_mbformat04_sp with additional return set
declare @v_gstnumber varchar(30)

select @v_gstnumber = gi_string1  from generalinfo
where gi_name = 'GSTNUMBER'

 




SELECT @p_shipstart = convert(char(12),@p_shipstart)+'00:00:00'
SELECT @p_shipend   = convert(char(12),@p_shipend  )+'23:59:59'




-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@p_reprintflag) = 'REPRINT' 
  BEGIN
    
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
	 ivh_shipto_address = ISNULL(cmp2.cmp_address1,''),
	 ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),
	 ivh_shipto_nmstct =  
	 ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
	 WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
	 ELSE CHARINDEX('/',cmp3.cty_nmstct) -1 END),''),
	ivh_shipto_zip = ISNULL(cmp2.cmp_zip,''),
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
	 ivh_consignee_address = ISNULL(cmp3.cmp_address1,''),
	 ivh_consignee_address2 = ISNULL(cmp3.cmp_address2,''),
	 ivh_consignee_nmstct = 
	 ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE
		WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.cty_nmstct) -1
		END),''),
	ivh_consignee_zip =  ISNULL(cmp3.cmp_zip,''),
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
		cmd_name = case isnull(cmd.cmd_name,'UNKNOWN') when 'UNKNOWN' then '' else cmd.cmd_name end, 
		IsNull(ivd_description, ''),
		ivd.ivd_type,
                ivd.cht_itemcode,
		stp_ctynmstct = Case isnull(ivd.stp_number,0) 
                  When 0 then '' else (select cty_nmstct from city where cty_code = stp_city) end,
/* put tax at the end */
		ivd_sequence = case ivd.cht_itemcode when 'GST'then 900 when 'QST' then 901 when 'PST' then 902 when 'HST' then 902 else ivd_sequence end,
		IsNull(stp.stp_number, -1),
		@p_copy,
		ivd.cmp_id cmp_id
        ,cmp_currency = isnull(cmp1.cmp_currency,'UNK')
        ,cht_basis = isnull(cht_basis,'UNK'),
		@v_gstnumber
    FROM 	invoiceheader
    join  company cmp1 on  invoiceheader.ivh_billto = cmp1.cmp_id
    join  company cmp2 on  invoiceheader.ivh_shipper = cmp2.cmp_id
    join  company cmp3 on  invoiceheader.ivh_consignee = cmp3.cmp_id
    join  city cty1 on  invoiceheader.ivh_origincity = cty1.cty_code
    join  city cty2 on  invoiceheader.ivh_destcity = cty2.cty_code
    join  invoicedetail ivd on  invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
    left outer join  commodity cmd on  ivd.cmd_code = cmd.cmd_code
    join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
    left outer join stops stp on ivd.stp_number = stp.stp_number
    WHERE ( invoiceheader.ivh_mbnumber = @p_mbnumber )
    AND ivd_type <> 'PUP'


  END

-- for master bills with 'RTP' status

IF UPPER(@p_reprintflag) <> 'REPRINT' 
  BEGIN
     
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
		@p_mbnumber     ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
-- dpete for LOR pts4785 provide for maitlto override of billto
	 ivh_shipto_address = ISNULL(cmp2.cmp_address1,''),
	 ivh_shipto_address2 = ISNULL(cmp2.cmp_address2,''),
	 ivh_shipto_nmstct =
	 ISNULL(SUBSTRING(cmp2.cty_nmstct,1,CASE
		WHEN CHARINDEX('/',cmp2.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp2.cty_nmstct) -1
		END),''),
	ivh_shipto_zip = ISNULL(cmp2.cmp_zip,''),
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
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
						      END),'')
		WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp1.cty_nmstct,1,CASE
							WHEN CHARINDEX('/',cmp1.cty_nmstct)- 1 < 0 THEN
							   0
							ELSE CHARINDEX('/',cmp1.cty_nmstct)- 1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,CASE
								  WHEN CHARINDEX('/',cmp1.mailto_cty_nmstct) - 1 < 0 THEN
								     0
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
	 ivh_consignee_address = ISNULL(cmp3.cmp_address1,''),
	 ivh_consignee_address2 = ISNULL(cmp3.cmp_address2,''),
	 ivh_consignee_nmstct = 
	 ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE 
		WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
			ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
		END),''),
	ivh_consignee_zip = ISNULL(cmp3.cmp_mailto_zip,''),
		cty1.cty_nmstct   origin_nmstct,
		cty1.cty_state		origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state		dest_state,
		@p_billdate	billdate,
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
		cmd_name = case isnull(cmd.cmd_name,'UNKNOWN') when 'UNKNOWN' then '' else cmd.cmd_name end, 
		IsNull(ivd_description, ''),
		ivd.ivd_type,		
                ivd.cht_itemcode,
		stp_ctynmstct = Case isnull(ivd.stp_number,0) 
                  When 0 then '' else (select cty_nmstct from city where cty_code = stp_city) end,
 /* put tax at the end */
		ivd_sequence = case ivd.cht_itemcode when 'GST'then 900 when 'QST' then 901 when 'PST' then 902 when 'HST' then 902 else ivd_sequence end,
		IsNull(stp.stp_number, -1),
		@p_copy,
		ivd.cmp_id cmp_id
        ,cmp_currency = isnull(cmp1.cmp_currency,'UNK')
        ,cht_basis = isnull(cht_basis,'UNK'),
		@v_gstnumber
   FROM 	invoiceheader
    join  company cmp1 on  invoiceheader.ivh_billto = cmp1.cmp_id
    join  company cmp2 on  invoiceheader.ivh_shipper = cmp2.cmp_id
    join  company cmp3 on  invoiceheader.ivh_consignee = cmp3.cmp_id
    join  city cty1 on  invoiceheader.ivh_origincity = cty1.cty_code
    join  city cty2 on  invoiceheader.ivh_destcity = cty2.cty_code
    join  invoicedetail ivd on  invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
    left outer join  commodity cmd on  ivd.cmd_code = cmd.cmd_code
    join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
    left outer join stops stp on ivd.stp_number = stp.stp_number
    WHERE ( invoiceheader.ivh_billto = @p_billto )
	AND    ( invoiceheader.ivh_shipdate between @p_shipstart AND @p_shipend ) 
	AND     (invoiceheader.ivh_mbstatus = 'RTP')  
	AND (@p_revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
	AND (@p_revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 
	AND (@p_shipper = invoiceheader.ivh_shipper)
	AND (@p_consignee = invoiceheader.ivh_consignee)
        AND ivd_type <> 'PUP'

  END

 

  
GO
GRANT EXECUTE ON  [dbo].[d_masterbill88_sp] TO [public]
GO
