SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill93_sp] (@p_reprintflag varchar(10),@p_mbnumber int,@p_billto varchar(8), 
	                       @p_revtype1 varchar(6), @p_revtype2 varchar(6),@p_mbstatus varchar(6),
	                       @p_shipstart datetime,@p_shipend datetime,@p_billdate datetime, 
                               @p_shipper varchar(8), @p_consignee varchar(8),
                               @p_copy int,@p_ivh_invoicenumber varchar(12),@p_refnum varchar(30),
			       @p_delstart datetime, @p_delend datetime, @p_revtype3 varchar(6), 
			       @p_revtype4 varchar(6))
AS


/**
 * 
 * NAME:
 * dbo.d_masterbill93_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return data for Masterbill 93
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * 001 - ord_hdrnumber int,
 * 002 - ivh_invoicenumber varchar(12),  
 * 003 - ivh_hdrnumber int NULL, 
 * 004 - ivh_billto varchar(8) NULL,
 * 005 - ivh_shipper varchar(8) NULL,
 * 006 - ivh_consignee varchar(8) NULL,
 * 007 - ivh_totalcharge money NULL,   
 * 008 - ivh_originpoint  varchar(8) NULL,  
 * 009 - ivh_destpoint varchar(8) NULL,   
 * 010 - ivh_origincity int NULL,   
 * 011 - ivh_destcity int NULL,   
 * 012 - ivh_shipdate datetime NULL,   
 * 013 - ivh_deliverydate datetime NULL,   
 * 014 - ivh_revtype1 varchar(6) NULL,
 * 015 - ivh_mbnumber int NULL,
 * 016 - ivh_shipper_name varchar(30) NULL ,
 * 017 - ivh_shipper_address varchar(40) NULL,
 * 018 - ivh_shipper_address2 varchar(40) NULL,
 * 019 - ivh_shipper_nmstct varchar(25) NULL ,
 * 020 - ivh_shipper_zip varchar(9) NULL,
 * 021 - ivh_billto_name varchar(30)  NULL,
 * 022 - ivh_billto_address varchar(40) NULL,
 * 023 - ivh_billto_address2 varchar(40) NULL,
 * 024 - ivh_billto_nmstct varchar(25) NULL ,
 * 025 - ivh_billto_zip varchar(9) NULL,
 * 026 - ivh_consignee_name varchar(30)  NULL,
 * 027 - ivh_consignee_address varchar(40) NULL,
 * 028 - ivh_consignee_address2 varchar(40) NULL,
 * 029 - ivh_consignee_nmstct varchar(25)  NULL,
 * 030 - ivh_consignee_zip varchar(9) NULL,
 * 031 - origin_nmstct varchar(25) NULL,
 * 032 - origin_state varchar(2) NULL,
 * 033 - dest_nmstct varchar(25) NULL,
 * 034 - dest_state varchar(2) NULL,
 * 035 - billdate datetime NULL,
 * 036 - cmp_mailto_name varchar(30)  NULL,
 * 037 - bill_quantity float  NULL,
 * 038 - ivd_weight float NULL,
 * 039 - ivd_weightunit char(6) NULL,
 * 040 - ivd_count float NULL,
 * 041 - ivd_countunit char(6) NULL,
 * 042 - ivd_volume float NULL,
 * 043 - ivd_volunit char(6) NULL,
 * 044 - ivd_unit char(6) NULL,
 * 045 - ivd_rate money NULL,
 * 046 - ivd_rateunit char(6) NULL,
 * 047 - ivd_charge money NULL,
 * 048 - cht_description varchar(30) NULL,
 * 049 - cht_primary char(1) NULL,
 * 050 - cmd_name varchar(60)  NULL,
 * 051 - ivd_description varchar(60) NULL,
 * 052 - ivd_type char(6) NULL,
 * 053 - stp_city int NULL,
 * 054 - stp_cty_nmstct varchar(25) NULL,
 * 055 - ivd_sequence int NULL,
 * 056 - stp_number int NULL,
 * 057 - copy int NULL,
 * 058 - cmp_id varchar(8) NULL,
 * 059 - cht_basis varchar(6) null,
 * 060 - cht_basisunit varchar(6)null,
 * 061 - ivd_distance float null,
 * 062 - ivd_distunit char(6)null,
 * 063 - ref_number1 varchar(36) null,
 * 064 - ref_number2 varchar(36) null,
 * 065 - ref_number3 varchar(36) null,
 * 066 - ref_number4 varchar(36) null,
 * 067 - ref_number5 varchar(36) null,
 * 068 - rte_ref_number varchar(20) null,
 * 069 - ivh_rateby varchar(10) null
 * 070 - mb_ordercount int null
 * 071 - ivh_arcurrency varchar(6) null,
 * 072 - duedate datetime null,
 * 073 - ivh_remark varchar(254)
 *
 * PARAMETERS:
 * 001 - @p_reprintflag varchar(10),
 * 002 - @p_mbnumber int,
 * 003 - @p_billto varchar(8),
 * 004 - @p_revtype1 varchar(6),
 * 005 - @p_revtype2 varchar(6),
 * 006 - @p_mbstatus varchar(6),
 * 007 - @p_shipstart datetime,
 * 008 - @p_shipend datetime,
 * 009 - @p_billdate datetime, 
 * 010 - @p_shipper varchar(8),
 * 011 - @p_consignee varchar(8),
 * 012 - @p_copy int,
 * 013 - @p_ivh_invoicenumber varchar(12),
 * 014 - @p_refnum varchar(30)
 * 015 - @p_delstart datetime
 * 016 - @p_delend datetime,
 * 017 - @p_reftype3 varchar(6),
 * 018 - @p_reftype4 varchar(6)
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 11/27/2006.01 PRB - Created stored proc for use with Master Bill Format 93.  This was created originally
 *                   - under format 81 and is an extension of that format.
 *
 **/

DECLARE
@int0  int, @MinOrd int, @drp_total float, @cht_basisunit varchar(6),
@minref varchar(30), @REF_TYPE VARCHAR(6), @REF_STRING VARCHAR(10),
@COUNT INT, @MAX_SEQUENCE INT,@REF_STRING1 VARCHAR(36),@REF_STRING2 VARCHAR(36),
@REF_STRING3 VARCHAR(36),@REF_STRING4 VARCHAR(36),@REF_STRING5 VARCHAR(36),
@MinOrdShpCon int,@MinShipper varchar(100), @MinSeq int,
@MinShipperAddr varchar(100) ,
@MinShipperAddr2 varchar(100)  ,
@MinShipperNmctst varchar(25)   ,
@MinShipperZip VARCHAR(10) ,
@MinCon varchar(100) , 
@MinConAddr varchar(100) ,
@MinConAddr2 varchar(100)  ,
@MinConNmctst varchar(25),
@MinConZip varchar(10),
@found1 int,
@found2 int,
@found3 int,
@found4 int,
@rte_ref_number varchar(20)

SELECT @int0 = 0

SELECT @p_shipstart = convert(char(12),@p_shipstart)+'00:00:00'
SELECT @p_shipend   = convert(char(12),@p_shipend  )+'23:59:59'
SELECT @p_delstart = convert(char(12),@p_delstart)+'00:00:00'
SELECT @p_delend   = convert(char(12),@p_delend)+'23:59:59'


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
		ivh_shipper_name varchar(30) NULL ,
		ivh_shipper_address varchar(40) NULL,
		ivh_shipper_address2 varchar(40) NULL,
		ivh_shipper_nmstct varchar(25) NULL ,
		ivh_shipper_zip varchar(9) NULL,
		ivh_billto_name varchar(30)  NULL,
		ivh_billto_address varchar(40) NULL,
		ivh_billto_address2 varchar(40) NULL,
		ivh_billto_nmstct varchar(25) NULL ,
		ivh_billto_zip varchar(9) NULL,
		ivh_consignee_name varchar(30)  NULL,
		ivh_consignee_address varchar(40) NULL,
		ivh_consignee_address2 varchar(40) NULL,
		ivh_consignee_nmstct varchar(25)  NULL,
		ivh_consignee_zip varchar(9) NULL,
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
		ivd_description varchar(60) NULL,
		ivd_type char(6) NULL,
		stp_city int NULL,
		stp_cty_nmstct varchar(25) NULL,
		ivd_sequence int NULL,
		stp_number int NULL,
		copy int NULL,
		cmp_id varchar(8) NULL,
		cht_basis varchar(6) null,
		cht_basisunit varchar(6)null,
		ivd_distance float null,
		ivd_distunit char(6)null,
		ref_number1 varchar(36) null,
		ref_number2 varchar(36) null,
		ref_number3 varchar(36) null,
		ref_number4 varchar(36) null,
		ref_number5 varchar(36) null,
		rte_ref_number varchar(20) null,
		ivh_rateby varchar(10) null,
		mb_ordercount int null,
		ivh_arcurrency varchar(6) null,
		duedate datetime null,
		ivh_remark varchar(254))

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@p_reprintflag) = 'REPRINT' 
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
		'', --stp.stp_city,
		'', --'',
		ivd_sequence,
		0, --IsNull(stp.stp_number, -1),
		@p_copy,
		ivd.cmp_id cmp_id,
                cht.cht_basis,
                cht.cht_basisunit,
                ivd_distance,
                ivd_distunit,
                '', --reference1 number place holder
		'', --reference2 number place holder
		'', --reference3 number place holder
                '', --reference4 number place holder
                '', --reference5 number place holder
		'',  --route ref_number(RTE) from the first order
                ivh_rateby,
		0,  --mb_ordercount place holder
		invoiceheader.ivh_currency,
		duedate = (SELECT DATEADD(day, Convert(INT, CASE ISNUMERIC(cmp1.cmp_othertype1)
								WHEN 0 THEN '0'
								ELSE ISNULL(cmp1.cmp_othertype1, '0')
								END), @p_billdate)),
		
                ISNULL(invoiceheader.ivh_remark, '')

    FROM 	invoiceheader  
		join company cmp1 on cmp1.cmp_id = invoiceheader.ivh_billto
		join company cmp2 on cmp2.cmp_id = invoiceheader.ivh_shipper
		join company cmp3 on cmp3.cmp_id = invoiceheader.ivh_consignee
		join city cty1 on cty1.cty_code = invoiceheader.ivh_origincity
		join city cty2 on cty2.cty_code = invoiceheader.ivh_destcity
		join invoicedetail ivd on invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
		left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code
		join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode

   WHERE	( invoiceheader.ivh_mbnumber = @p_mbnumber )
		AND (@p_shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@p_consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
                AND (@p_refnum IN (invoiceheader.ivh_ref_number,''))


  END

-- for master bills with 'RTP' status

IF UPPER(@p_reprintflag) <> 'REPRINT' 
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
		@p_mbnumber     ivh_mbnumber,
		ivh_shipto_name = cmp2.cmp_name,
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
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
						           0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
						      END),'')
		WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE 
							WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN
						           0
							ELSE CHARINDEX('/',cmp3.cty_nmstct) - 1
						      END),'')
		ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE
								 WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN
								    0
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
		cmd.cmd_name,
		IsNull(ivd_description, ''),
		ivd.ivd_type,		
		'',--stp.stp_city,
		'',--'',
		ivd_sequence,
		0,--IsNull(stp.stp_number, -1),
		@p_copy,
		ivd.cmp_id cmp_id,
                cht.cht_basis,
                cht.cht_basisunit,
                ivd_distance,
                ivd_distunit,
                '', --reference1 number place holder
		'', --reference2 number place holder
		'', --reference3 number place holder
                '', --reference4 number place holder
                '', --reference5 number place holder
		'', --route ref_number(RTE) from the first order
		ivh_rateby,
		0,  --mb_ordercount place holder
		invoiceheader.ivh_currency,
		duedate = (SELECT DATEADD(day, Convert(INT, CASE ISNUMERIC(cmp1.cmp_othertype1)
								WHEN 0 THEN '0'
								ELSE ISNULL(cmp1.cmp_othertype1, '0')
								END), @p_billdate)),
		ISNULL(invoiceheader.ivh_remark, '')
	FROM 	invoiceheader
		join company cmp1 on cmp1.cmp_id = invoiceheader.ivh_billto
		join company cmp2 on cmp2.cmp_id = invoiceheader.ivh_shipper
		join company cmp3 on cmp3.cmp_id = invoiceheader.ivh_consignee
		join city cty1 on cty1.cty_code = invoiceheader.ivh_origincity
		join city cty2 on cty2.cty_code = invoiceheader.ivh_destcity
		join invoicedetail ivd on invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber
		left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code
		join chargetype cht on ivd.cht_itemcode = cht.cht_itemcode
	WHERE 	( invoiceheader.ivh_billto = @p_billto )  
		AND (invoiceheader.ivh_shipdate between @p_shipstart AND @p_shipend )
		AND (invoiceheader.ivh_deliverydate between @p_delstart AND @p_delend )
		AND (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@p_revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@p_revtype2 in (invoiceheader.ivh_revtype2,'UNK'))
		AND (@p_revtype3 in (invoiceheader.ivh_revtype3,'UNK'))
		AND (@p_revtype4 in (invoiceheader.ivh_revtype4,'UNK'))
		AND (@p_shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@p_consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND (@p_ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master'))
                AND (@p_refnum IN (invoiceheader.ivh_ref_number,''))
  END


-- looping
SET @MinOrd = ''
SET @MinSeq = 0
SET @DRP_TOTAL = 0
SET @COUNT = 0
SET @MinRef = ''
SET @REF_TYPE = ''
SET @MAX_SEQUENCE = 0
SET @REF_STRING1 = ''
SET @REF_STRING2 = ''
SET @REF_STRING3 = ''
SET @REF_STRING4 = ''
SET @REF_STRING5 = ''
SET @MinSeq = 0
SET @found1 = ''
SET @found2 = ''
SET @found3 = ''
SET @found4 = ''

WHILE (SELECT COUNT(*) FROM #masterbill_temp WHERE ord_hdrnumber > @MinOrd) > 0
	BEGIN
	SELECT @MinOrd = (SELECT MIN(ord_hdrnumber) FROM #masterbill_temp WHERE ord_hdrnumber > @MinOrd)
	
	select @cht_basisunit = UPPER(ivd_rateunit)	
          from #masterbill_temp
         where ord_hdrnumber = @minord and
               ivd_type = 'sub'

        IF @cht_basisunit = 'MIL' or @cht_basisunit = 'IN' or @cht_basisunit = 'MM' or 
	   @cht_basisunit = 'FT' or @cht_basisunit = 'CM' or @cht_basisunit = 'KMS' or 
           @cht_basisunit = 'HUB' 
         begin
	   SELECT @DRP_TOTAL = SUM(IVD_DISTANCE)
             from #masterbill_temp
            where ord_hdrnumber = @minord AND
                  IVD_TYPE = 'DRP'

	   UPDATE #masterbill_temp
              SET IVD_DISTANCE = @DRP_TOTAL
            where ord_hdrnumber = @minord and
                  ivd_type = 'sub'

         end

	IF @cht_basisunit = 'LBS' OR @cht_basisunit = 'KGS' or @cht_basisunit = 'MTN' or 
           @cht_basisunit = 'TON'  
         begin
	   SELECT @DRP_TOTAL = SUM(IVD_WEIGHT)
             from #masterbill_temp
            where ord_hdrnumber = @minord AND
                  IVD_TYPE = 'DRP'

	   UPDATE #masterbill_temp
              SET IVD_WEIGHT = @DRP_TOTAL
            where ord_hdrnumber = @minord and
                  ivd_type = 'sub'

         end

	IF @cht_basisunit = 'PCS' OR @cht_basisunit = 'BOX' or @cht_basisunit = 'SLP' or 
           @cht_basisunit = 'CAS' or @cht_basisunit = 'PLT' or @cht_basisunit = 'COIL' 
         begin
	   SELECT @DRP_TOTAL = SUM(IVD_COUNT)
             from #masterbill_temp
            where ord_hdrnumber = @minord AND
                  IVD_TYPE = 'DRP'

	    UPDATE #masterbill_temp
              SET IVD_COUNT = @DRP_TOTAL
            where ord_hdrnumber = @minord and
                  ivd_type = 'sub'
	   
         end

	IF @cht_basisunit = 'GAL' OR @cht_basisunit = 'BSH' or @cht_basisunit = 'LTR' or 
	   @cht_basisunit = 'CYD' or @cht_basisunit = 'CMM' or @cht_basisunit = 'CUB' 
         
	BEGIN
	   SELECT @DRP_TOTAL = SUM(IVD_VOLUME)
             from #masterbill_temp
            where ord_hdrnumber = @minord AND
                  IVD_TYPE = 'DRP'

	    UPDATE #masterbill_temp
              SET IVD_VOLUME = @DRP_TOTAL
            where ord_hdrnumber = @minord and
                  ivd_type = 'sub'
         END
        
	 WHILE (SELECT COUNT(*) FROM referencenumber WHERE ref_sequence > @MinSeq and ref_tablekey = @MinOrd and ref_table = 'orderheader' and ref_type IN ('BOL#')) > 0
	     BEGIN
               SELECT @count = @count + 1	
               SELECT @MinSeq = (SELECT MIN(ref_sequence) FROM referencenumber WHERE ref_sequence > @MinSeq and ref_tablekey = @MinOrd and ref_table = 'orderheader' and ref_type IN ('BOL#'))       	       
	              
               select @ref_type = ref_type,
                      @MinRef = ref_number
                 from referencenumber
                where ref_sequence = @MinSeq and
                      ref_tablekey = @MinOrd                  

	       IF @count = 1
		BEGIN
			SELECT @REF_STRING1 = @REF_STRING1+@REF_TYPE+' '+@MINREF
		
			SELECT @MAX_SEQUENCE = MAX(IVD_SEQUENCE)
          		  FROM #MASTERBILL_TEMP
         		 WHERE ord_hdrnumber = @MINORD
         
	 		UPDATE #MASTERBILL_TEMP
            		   SET REF_NUMBER1 = @REF_STRING1
          		 WHERE ord_hdrnumber = @MINORD AND
                	       IVD_SEQUENCE = @MAX_SEQUENCE
                END
		
		IF @count = 2
		BEGIN
			select @found1 = CHARINDEX('BOL#',@REF_STRING1)
                        
			IF @found1 > 0 and @ref_type = 'BOL#'
			 Begin
			   SELECT @REF_STRING2 = @REF_STRING2+@MINREF
			 End
			ELSE
			 Begin
			   SELECT @REF_STRING2 = @REF_STRING2+@REF_TYPE+' '+@MINREF
			 End
		
			SELECT @MAX_SEQUENCE = MAX(IVD_SEQUENCE)
          		  FROM #MASTERBILL_TEMP
         		 WHERE ord_hdrnumber = @MINORD
         
	 		UPDATE #MASTERBILL_TEMP
            		   SET REF_NUMBER2 = @REF_STRING2
          		 WHERE ord_hdrnumber = @MINORD AND
                	       IVD_SEQUENCE = @MAX_SEQUENCE
                END

		IF @count = 3
		BEGIN			
			select @found2 = CHARINDEX('BOL#',@REF_STRING2)

			IF (@found1 > 0 or @found2 > 0) and @ref_type = 'BOL#'
			 Begin
			   SELECT @REF_STRING3 = @REF_STRING3+@MINREF
			 End
			ELSE
			 Begin
			   SELECT @REF_STRING3 = @REF_STRING3+@REF_TYPE+' '+@MINREF
			 End			
		
			SELECT @MAX_SEQUENCE = MAX(IVD_SEQUENCE)
          		  FROM #MASTERBILL_TEMP
         		 WHERE ord_hdrnumber = @MINORD
         
	 		UPDATE #MASTERBILL_TEMP
            		   SET REF_NUMBER3 = @REF_STRING3
          		 WHERE ord_hdrnumber = @MINORD AND
                	       IVD_SEQUENCE = @MAX_SEQUENCE
                END

		IF @count = 4
		BEGIN			
			select @found3 = CHARINDEX('BOL#',@REF_STRING3)
			
			IF (@found1 > 0 or @found2 > 0 or @found3 > 0) and @ref_type = 'BOL#'
			 Begin
			   SELECT @REF_STRING4 = @REF_STRING4+@MINREF
			 End
			ELSE
			 Begin
			   SELECT @REF_STRING4 = @REF_STRING4+@REF_TYPE+' '+@MINREF
			 End			
		
			SELECT @MAX_SEQUENCE = MAX(IVD_SEQUENCE)
          		  FROM #MASTERBILL_TEMP
         		 WHERE ord_hdrnumber = @MINORD
         
	 		UPDATE #MASTERBILL_TEMP
            		   SET REF_NUMBER4 = @REF_STRING4
          		 WHERE ord_hdrnumber = @MINORD AND
                	       IVD_SEQUENCE = @MAX_SEQUENCE
                END

		IF @count = 5
		BEGIN			
			select @found4 = CHARINDEX('BOL#',@REF_STRING4)
			
			IF (@found1 > 0 or @found2 > 0 or @found3 > 0 or @found4 > 0) and @ref_type = 'BOL#'
			 Begin
			   SELECT @REF_STRING5 = @REF_STRING5+@MINREF
			 End
			ELSE
			 Begin
			   SELECT @REF_STRING5 = @REF_STRING5+@REF_TYPE+' '+@MINREF
			 End			
		
			SELECT @MAX_SEQUENCE = MAX(IVD_SEQUENCE)
          		  FROM #MASTERBILL_TEMP
         		 WHERE ord_hdrnumber = @MINORD
         
	 		UPDATE #MASTERBILL_TEMP
            		   SET REF_NUMBER5 = @REF_STRING5
          		 WHERE ord_hdrnumber = @MINORD AND
                	       IVD_SEQUENCE = @MAX_SEQUENCE
                END

	  	if @COUNT > 5 break
	END	       
	
         SET @MinSeq = 0
	 WHILE (SELECT COUNT(*) FROM referencenumber WHERE ref_sequence > @MinSeq and ref_tablekey = @MinOrd and ref_table = 'orderheader' and ref_type IN ('ESR#','PO#')) > 0
	     BEGIN
	       
	      
               SELECT @count = @count + 1	
               SELECT @MinSeq = (SELECT MIN(ref_sequence) FROM referencenumber WHERE ref_sequence > @MinSeq and ref_tablekey = @MinOrd and ref_table = 'orderheader' and ref_type IN ('ESR#','PO#'))       	       
	          
               select @ref_type = ref_type,
                      @MinRef = ref_number
                 from referencenumber
                where ref_sequence = @MinSeq and
                      ref_tablekey = @MinOrd 
	      
	       IF @count = 1
		BEGIN
			SELECT @REF_STRING1 = @REF_STRING1+@REF_TYPE+' '+@MINREF
		
			SELECT @MAX_SEQUENCE = MAX(IVD_SEQUENCE)
          		  FROM #MASTERBILL_TEMP
         		 WHERE ord_hdrnumber = @MINORD
         
	 		UPDATE #MASTERBILL_TEMP
            		   SET REF_NUMBER1 = @REF_STRING1
          		 WHERE ord_hdrnumber = @MINORD AND
                	       IVD_SEQUENCE = @MAX_SEQUENCE
                END
		
		IF @count = 2
		BEGIN
 	  	        SELECT @REF_STRING2 = @REF_STRING2+@REF_TYPE+' '+@MINREF
		
			SELECT @MAX_SEQUENCE = MAX(IVD_SEQUENCE)
          		  FROM #MASTERBILL_TEMP
         		 WHERE ord_hdrnumber = @MINORD
         
	 		UPDATE #MASTERBILL_TEMP
            		   SET REF_NUMBER2 = @REF_STRING2
          		 WHERE ord_hdrnumber = @MINORD AND
                	       IVD_SEQUENCE = @MAX_SEQUENCE
                END

		IF @count = 3
		BEGIN			
		        SELECT @REF_STRING3 = @REF_STRING3+@REF_TYPE+' '+@MINREF
					
			SELECT @MAX_SEQUENCE = MAX(IVD_SEQUENCE)
          		  FROM #MASTERBILL_TEMP
         		 WHERE ord_hdrnumber = @MINORD
         
	 		UPDATE #MASTERBILL_TEMP
            		   SET REF_NUMBER3 = @REF_STRING3
          		 WHERE ord_hdrnumber = @MINORD AND
                	       IVD_SEQUENCE = @MAX_SEQUENCE
                END

		IF @count = 4
		BEGIN			
			SELECT @REF_STRING4 = @REF_STRING4+@REF_TYPE+' '+@MINREF
					
			SELECT @MAX_SEQUENCE = MAX(IVD_SEQUENCE)
          		  FROM #MASTERBILL_TEMP
         		 WHERE ord_hdrnumber = @MINORD
         
	 		UPDATE #MASTERBILL_TEMP
            		   SET REF_NUMBER4 = @REF_STRING4
          		 WHERE ord_hdrnumber = @MINORD AND
                	       IVD_SEQUENCE = @MAX_SEQUENCE
                END

		IF @count = 5
		BEGIN			
			SELECT @REF_STRING5 = @REF_STRING5+@REF_TYPE+' '+@MINREF
					
			SELECT @MAX_SEQUENCE = MAX(IVD_SEQUENCE)
          		  FROM #MASTERBILL_TEMP
         		 WHERE ord_hdrnumber = @MINORD
         
	 		UPDATE #MASTERBILL_TEMP
            		   SET REF_NUMBER5 = @REF_STRING5
          		 WHERE ord_hdrnumber = @MINORD AND
                	       IVD_SEQUENCE = @MAX_SEQUENCE
                END
	       			
     	       IF @count > 5 BREAK
		
	     END


	 --Reset the variable
         set @count = 0
         SET @DRP_TOTAL = 0
         SET @MinRef = ''
         SET @ref_string = ''
         SET @MAX_SEQUENCE = 0
         SET @REF_STRING5 = ''
	 SET @REF_STRING4 = ''
	 SET @REF_STRING3 = ''
	 SET @REF_STRING2 = ''
	 SET @REF_STRING1 = ''
	 SET @REF_TYPE = ''
	 SET @MinSeq = 0
	 SET @found1 = ''
	 SET @found2 = ''
	 SET @found3 = ''
	 SET @found4 = ''

 END


   SELECT @MinOrdShpCon = MIN(ord_hdrnumber)
     FROM #masterbill_temp

   SELECT @MinShipper = ivh_shipper_Name, 
	  @MinShipperAddr = ivh_shipper_Address ,
	  @MinShipperAddr2 = ivh_shipper_Address2 ,
          @MinShipperNmctst = ivh_shipper_nmstct ,
	  @MinShipperZip = ivh_shipper_zip ,
	  @MinCon = ivh_consignee_name, 
	  @MinConAddr = ivh_consignee_Address ,
	  @MinConAddr2 = ivh_consignee_Address2 ,
	  @MinConNmctst = ivh_consignee_nmstct ,
	  @MinConZip = ivh_consignee_zip                      
     FROM #masterbill_temp 
    where ord_hdrnumber = @MinOrdShpCon


select @rte_ref_number = MIN(ref_number)
    from referencenumber
   where ref_tablekey = @MinOrdShpCon and
         ref_table = 'orderheader' and
         ref_type IN ('RTE#', 'RTEID') and
         ref_sequence = (select min(ref_sequence)
                           from referencenumber
 			  where ref_tablekey = @MinOrdShpCon and
         			ref_table = 'orderheader' and
         			ref_type IN ('RTE#', 'RTEID'))

 UPDATE #masterbill_temp
 SET ivh_shipper_name = @minshipper,
     ivh_shipper_address = @minshipperaddr,
     ivh_shipper_address2 = @minshipperaddr2,
     ivh_shipper_nmstct = @minshippernmctst,
     ivh_shipper_zip = @minshipperzip,
     ivh_consignee_name = @mincon,
     ivh_consignee_address = @minconaddr,
     ivh_consignee_address2 = @minconaddr2,
     ivh_consignee_nmstct = @minconnmctst,
     ivh_consignee_zip = @minconzip,
     rte_ref_number = @rte_ref_number

update #masterbill_temp
 SET mb_ordercount=(select count(distinct(ord_hdrnumber)) from #masterbill_temp)
                             

    SELECT ord_hdrnumber,
	        ivh_invoicenumber,  
		ivh_hdrnumber, 
		ivh_billto,
		ivh_shipper,
		ivh_consignee,
		ivh_totalcharge,   
		ivh_originpoint,  
		ivh_destpoint,   
		ivh_origincity,   
		ivh_destcity,   
		ivh_shipdate,   
		ivh_deliverydate,   
		ivh_revtype1,
		ivh_mbnumber,
		ivh_shipper_name,
		ivh_shipper_address,
		ivh_shipper_address2,
		ivh_shipper_nmstct,
		ivh_shipper_zip,
		ivh_billto_name,
		ivh_billto_address,
		ivh_billto_address2,
		ivh_billto_nmstct,
		ivh_billto_zip,
		ivh_consignee_name,
		ivh_consignee_address,
		ivh_consignee_address2,
		ivh_consignee_nmstct,
		ivh_consignee_zip,
		origin_nmstct,
		origin_state,
		dest_nmstct,
		dest_state,
		billdate,
		cmp_mailto_name,
		bill_quantity,
		ivd_weight,
		ivd_weightunit,
		ivd_count,
		ivd_countunit,
		ivd_volume,
		ivd_volunit,
		ivd_unit,
		ivd_rate,
		ivd_rateunit,
		ivd_charge,
		cht_description,
		cht_primary,
		cmd_name,
		ivd_description,
		ivd_type,
		stp_city,
		stp_cty_nmstct,
		ivd_sequence,
		stp_number,
		copy,
		cmp_id,
		cht_basis,
		cht_basisunit,
		ivd_distance,
		ivd_distunit,
		ref_number1,
		ref_number2,
		ref_number3,
		ref_number4,
		ref_number5,
		rte_ref_number,
		ivh_rateby,
		mb_ordercount,
		ivh_arcurrency,
		duedate,
		ivh_remark
      FROM #masterbill_temp
     WHERE ivd_type NOT IN ('DRP','PUP','NONE') or
           ivh_rateby = 'D'
  ORDER BY ord_hdrnumber,ivh_invoicenumber, ivd_sequence

  DROP TABLE 	#masterbill_temp

GO
GRANT EXECUTE ON  [dbo].[d_masterbill93_sp] TO [public]
GO
