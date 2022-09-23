SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create  PROC [dbo].[d_masterbill87_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                        @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
	                        @shipstart datetime,@shipend datetime,@billdate datetime, 
                                @shipper varchar(8), @consignee varchar(8),
                                @copy int,@ivh_invoicenumber varchar(12))
AS

/**
 * 
 * NAME:
 * dbo.d_masterbill87_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
  * PARAMETERS:
 * 001 - @reprintflag varchar(10), input, null;
 *       This parameter indicates whether or not we will be doing a reprint or not. 
 *     
 * 002 - @mbnumber int, input, null;
 *       This parameter indicates our master bill number used.
 *
 * 003 - @billto varchar(8), input, null;
 *       This parameter  indicates the bill to to be filtered.
 *
 * 004 - @revtype1 varchar(6), input, null;
 *       This parameter indicates the revtype1 that will be filtered in the where clause.
 *
 * 005 - @revtype2 varchar(6), varchar(18), input, null;
 *       This parameter indicates the revtype2 that will be filtered in the where clause.
 *
 * 006 - @mbstatus varchar(6), input, null;
 *       This parameter indicates the master bill status that was entered in the datawindow.
 *
 * 007 - @shipstart datetime, varchar(18), input, null;
 *       This parameter indicates the ship start date entered in the datawindow.
 *
 * 008 - @shipend datetime, input, null;
 *       This parameter indicates the ship end date entered in the datawindow.
 *
 * 009 - @billdate datetime, input, null;
 *       This parameter indicates the bill date entered in the datawindow.  This will be
 *       used in the where clause.
 *
 * 010 - @shipper varchar(8), input, null;
 *       This parameter indicates the id of the shipper to be filtered.
 *
 * 011 - @consignee varchar(8), input, null;
 *       This parameter indicates the consignee to be filtered
 *
 * 012 - @copy int, input, null;
 *       This parameter indicates the number of copies to be printed.
 *
 * 013 - @ivh_invoicenumber varchar(12), input, null;
 *       This parameter indicates the invoice number to be selected.
 * 
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * 10/07/1999 PTS###    - dpete                   - retrieve cmp_id for d_mb_format05
 * 00/00/0000 pts6691   - dpete                   - make ivd_count and volume floats on temp table
 * 00/00/0000 pts7230   - vjh                     - roll up some data.
 * 07/25/2002 PTS 14924 - Vern Jewett(label=vmj1) - lengthen ivd_description from 30 to 60 chars
 * 07/24/2006 PTS 32550 - Imari Bremer            - New format masterbill 87
 **/

DECLARE 
@int0  int, 
@billto_altid varchar(25),
@drp_total float, 
@cht_basisunit varchar(6),
@MINORD INT, 
@MINSEQ INT, 
@BILL_QTY FLOAT,
@MinOrdShpCon int,
@MinShipper varchar(100), 
@MinShipperAddr varchar(100) ,
@MinShipperAddr2 varchar(100)  ,
@MinShipperNmctst varchar(25)   ,
@MinShipperZip VARCHAR(10) ,
@MinCon varchar(100) , 
@MinConAddr varchar(100) ,
@MinConAddr2 varchar(100)  ,
@MinConNmctst varchar(25),
@MinConZip varchar(10),
@v_counter int,
@v_ret_value int,
@v_temp int,
@v_invoice_terms int,
@v_cmp_terms    varchar(10),
@v_startpos int,
@minmov int,
@Minlgh int,
@v_lgh_trailer varchar(20),
@v_lgh_tractor varchar(20),
@v_cnt int,
@v_lghcnt int,
@stp_number int,
@v_primary_tractor_type1 varchar(20),
@v_minreftype varchar(6),
@v_refdesc varchar(20),
@v_REFSTRING varchar(500),
@v_REFseq int,
@v_MinRefSeq int,
@v_MinRefNumber varchar(30),
@lgh_cnt int,
@v_rebillcreditmemo_cnt int

SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'

SELECT @v_invoice_terms = 0
SELECT @v_cmp_terms = ''

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @v_ret_value = 1  

CREATE TABLE #masterbill_temp (	ord_hdrnumber int null,
		ivh_invoicenumber varchar(12)null,  
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
		cmp_id varchar(8) NULL,
		ord_firstref varchar(20) NULL,                
		ivh_totalweight float NULL,
		billto_altid varchar(25) null,
                cht_basis varchar(6) null,
                cht_basisunit varchar(6)null,
                ivd_distance float null,
                ivd_distunit char(6)null,
		ivd_groupcontrol int null,  
                billto_cmp_othertype1 varchar(6) null,
                cmp_contact varchar(30) null,
                cmp_primaryphone varchar(20) null,
		cmp_terms varchar(20) null,
                pay_date varchar(20) null,
                cust_po_no varchar(30) null,
                company_loc varchar(200)null,
                primary_tractor_type1 varchar(20)null,
                secondary_tractor_type1 varchar(20) null,               
                mov_number int null,
                tractor1 varchar(8)null,
                tractor2 varchar(8)null,
                trailer1 varchar(13) null,
                trailer2 varchar(13) null,
                reference_numbers varchar(500)null,
		ivh_definition varchar(6) null,
                lgh_count int null,
                rebill_creditmemo varchar(30)null,
                rebill_creditmemo_cnt int)

if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN

     INSERT INTO #masterbill_temp
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
		invoiceheader.ivh_billdate,
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
		'',--billto alt id
		cht.cht_basis,
                cht.cht_basisunit,
		ivd_distance,
                ivd_distunit,
		1,		
		cmp1.cmp_othertype1,
                cmp1.cmp_contact,
                cmp1.cmp_primaryphone,
		cmp1.cmp_terms,
		'' pay_date,
		'' cust_po_no,
                '' company_loc,
		'' primary_tractor_type1 ,
		'' secondary_tractor_type1,
		invoiceheader.mov_number,
		invoiceheader.ivh_tractor ,
                '' ,--tractor2
                invoiceheader.ivh_trailer,
                '',--trailer2
		'',--reference number  	
		invoiceheader.ivh_definition,
                '',--leg count,
		'',--rebill_creditmemo	
		0 --rebill_creditmemo_cnt
	FROM 	--invoiceheader, 
		company cmp1, 
		company cmp2,
		company cmp3,
		city cty1, 
		city cty2, 
		--invoicedetail ivd, 
		--commodity cmd, 
		chargetype cht,
		--stops stp,
		invoiceheader JOIN invoicedetail as ivd ON (ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )  
        	LEFT OUTER JOIN STOPS AS STP ON ( IVD.STP_NUMBER = STP.STP_NUMBER)   
         	LEFT OUTER JOIN commodity AS CMD ON (ivd.cmd_code = CMD.cmd_code) 

       WHERE	(invoiceheader.ivh_mbnumber = @mbnumber )
		--AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		--AND (ivd.stp_number *= stp.stp_number)
		--AND (ivd.cmd_code *= cmd.cmd_code)
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
		invoiceheader.ivh_deliverydate,  
 		invoiceheader.ivh_revtype1,
		@mbnumber ivh_mbnumber,
		--invoiceheader.ivh_mbnumber,		
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
		invoiceheader.ivh_billdate,
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
		'',--billto alt id
		cht.cht_basis,
                cht.cht_basisunit,
		ivd_distance,
                ivd_distunit,
		1,		
		cmp1.cmp_othertype1,
                cmp1.cmp_contact,
                cmp1.cmp_primaryphone,
		cmp1.cmp_terms,
		'' pay_date,
		'' cust_po_no,
                '' company_loc,
		'' primary_tractor_type1 ,
		'' secondary_tractor_type1,
		invoiceheader.mov_number,
		invoiceheader.ivh_tractor ,
                '' ,--tractor2
                invoiceheader.ivh_trailer,
                '',--trailer2
		'',--reference number  	
		invoiceheader.ivh_definition,
                '',--leg count,
		'',--rebill_creditmemo	
		0 --rebill_creditmemo_cnt
	FROM 	--invoiceheader, 
		company cmp1, 
		company cmp2,
		company cmp3,
		city cty1, 
		city cty2, 
		--invoicedetail ivd, 
		--commodity cmd, 
		chargetype cht,
		--stops stp,
		invoiceheader JOIN invoicedetail as ivd ON (ivd.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )  
        	LEFT OUTER JOIN STOPS AS STP ON ( IVD.STP_NUMBER = STP.STP_NUMBER)   
         	LEFT OUTER JOIN commodity AS CMD ON (ivd.cmd_code = CMD.cmd_code) 

       WHERE 	( invoiceheader.ivh_billto = @billto )                  
		--AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		--AND (ivd.stp_number *= stp.stp_number)
		--AND (ivd.cmd_code *= cmd.cmd_code)
		AND ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
		AND (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 
		AND (cmp1.cmp_id = invoiceheader.ivh_billto)
		AND (cmp2.cmp_id = invoiceheader.ivh_shipper)
	 	AND (cmp3.cmp_id = invoiceheader.ivh_consignee)
		AND (cty1.cty_code = invoiceheader.ivh_origincity) 
		AND (cty2.cty_code = invoiceheader.ivh_destcity)
		AND (ivd.cht_itemcode = cht.cht_itemcode)
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND (@ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master'))

  END

  --PTS# 24399 ILB 11/15/2004
  select @billto_altid = cmp_altid
    from company
   where cmp_id = @billto
  
  Update #masterbill_temp
     set billto_altid = @billto_altid  

SET @MinOrd = ''
SET @DRP_TOTAL = 0
SET @MINSEQ = 0
SET @BILL_QTY = 0 
WHILE (SELECT COUNT(*) FROM #masterbill_temp WHERE ord_hdrnumber > @MinOrd) > 0
	BEGIN
	   SELECT @MinOrd = (SELECT MIN(ord_hdrnumber) FROM #masterbill_temp WHERE ord_hdrnumber > @MinOrd)
	
           SELECT @BILL_QTY = BILL_QUANTITY 
	     FROM #masterbill_temp 
	    WHERE ORD_HDRNUMBER = @MINORD AND
                  IVD_TYPE = 'SUB' 
	
	  IF @BILL_QTY <> 0 
	     BEGIN	
		   UPDATE #masterbill_temp
	              SET BILL_QUANTITY = @BILL_QTY
	            WHERE ORD_HDRNUMBER = @MINORD AND
	                  IVD_TYPE = 'DRP'
             END             

	   --RESET VARIABLE
           SET @BILL_QTY = 0

	   UPDATE #masterbill_temp
	      SET cust_po_no = ref.ref_number
	     FROM REFERENCENUMBER REF
	    WHERE ref_type = 'PO #' and
	          ref_table = 'orderheader' and
	          ref_tablekey = @MinOrd and
	          ref_sequence = (select min(ref_sequence)
		                    from referencenumber
		                   where ref_type = 'PO #' and
		  		         ref_table = 'orderheader' and
		                         ref_tablekey = @MinOrd)


	   WHILE (SELECT COUNT(*) FROM #masterbill_temp WHERE ivd_sequence > @minseq and ord_hdrnumber = @MinOrd) > 0
	   BEGIN             
          
		select @MinSeq = min(ivd_sequence)
		  from #masterbill_temp 
	         where ord_hdrnumber = @MinOrd and
                       ivd_sequence > @MinSeq 	
 	     
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
	                  IVD_TYPE = 'DRP' AND
                          IVD_SEQUENCE = @MINSEQ
	
		   UPDATE #masterbill_temp
	              SET IVD_DISTANCE = @DRP_TOTAL,
                          IVD_WEIGHT = 0,
                          IVD_VOLUME = 0,
                          IVD_COUNT = 0
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP' AND
                          IVD_SEQUENCE = @MINSEQ	
	         end
	
		IF @cht_basisunit = 'LBS' OR @cht_basisunit = 'KGS' or @cht_basisunit = 'MTN' or 
	           @cht_basisunit = 'TON' OR @cht_basisunit = 'CWT'  
	         begin
		   SELECT @DRP_TOTAL = SUM(IVD_WEIGHT)
	             from #masterbill_temp
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'AND
                          IVD_SEQUENCE = @MINSEQ
	
		   UPDATE #masterbill_temp
	              SET IVD_WEIGHT = @DRP_TOTAL,
                          IVD_DISTANCE = 0,
                          IVD_VOLUME = 0,
                          IVD_COUNT = 0
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'AND
                          IVD_SEQUENCE = @MINSEQ
	
	         end
	
		IF @cht_basisunit = 'PCS' OR @cht_basisunit = 'BOX' or @cht_basisunit = 'SLP' or 
	           @cht_basisunit = 'CAS' or @cht_basisunit = 'PLT' or @cht_basisunit = 'COIL' 
	         begin
		   SELECT @DRP_TOTAL = SUM(IVD_COUNT)
	             from #masterbill_temp
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'AND
                          IVD_SEQUENCE = @MINSEQ
	
		    UPDATE #masterbill_temp
	              SET IVD_COUNT = @DRP_TOTAL,
			  IVD_WEIGHT = 0,
                          IVD_VOLUME = 0,
                          IVD_DISTANCE = 0
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'AND
                          IVD_SEQUENCE = @MINSEQ
		   
	         end
	
		IF @cht_basisunit = 'GAL' OR @cht_basisunit = 'BSH' or @cht_basisunit = 'LTR' or 
		   @cht_basisunit = 'CYD' or @cht_basisunit = 'CMM' or @cht_basisunit = 'CUB' 
	         
		BEGIN
		   SELECT @DRP_TOTAL = SUM(IVD_VOLUME)
	             from #masterbill_temp
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'AND
                          IVD_SEQUENCE = @MINSEQ
	
		    UPDATE #masterbill_temp
	              SET IVD_VOLUME = @DRP_TOTAL,
                          IVD_WEIGHT = 0,
                          IVD_DISTANCE = 0,
                          IVD_COUNT = 0
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'AND
                          IVD_SEQUENCE = @MINSEQ
	         END

		IF @cht_basisunit <> 'MIL' and @cht_basisunit <> 'IN' and @cht_basisunit <> 'MM' and 
		   @cht_basisunit <> 'FT' and @cht_basisunit <> 'CM' and @cht_basisunit <> 'KMS' and 
	           @cht_basisunit <> 'HUB' and @cht_basisunit <> 'LBS' and @cht_basisunit <> 'KGS' and 
		   @cht_basisunit <> 'MTN' and @cht_basisunit <> 'TON' and @cht_basisunit <> 'PCS' and 
	           @cht_basisunit <> 'BOX' and @cht_basisunit <> 'SLP' and @cht_basisunit <> 'CAS' and 
                   @cht_basisunit <> 'PLT' and @cht_basisunit <> 'COIL' and @cht_basisunit <> 'GAL' and 
                   @cht_basisunit <> 'BSH' and @cht_basisunit <> 'LTR' and @cht_basisunit <> 'CWT' AND
		   @cht_basisunit <> 'CYD' and @cht_basisunit <> 'CMM' and @cht_basisunit <> 'CUB' and
                   @cht_basisunit <> ''
	         
		 BEGIN                      
		   --SELECT @DRP_TOTAL = SUM(IVD_VOLUME)
	           --  from #masterbill_temp
	           -- where ord_hdrnumber = @minord AND
	           --       IVD_TYPE = 'DRP'
	
		    UPDATE #masterbill_temp
	              SET IVD_VOLUME = 0,
                          IVD_WEIGHT = 0,
                          IVD_DISTANCE = 0,
                          IVD_COUNT = 0
	            where ord_hdrnumber = @minord AND
	                  IVD_TYPE = 'DRP'
	         END	
              
		--Reset the variable
         	SET @DRP_TOTAL = 0
                SET @CHT_BASISUNIT = ''		

	    END
		SET @MINSEQ = 0
	END
--END PTS# 24399 ILB 11/15/2004


  UPDATE 	#masterbill_temp 
     SET	#masterbill_temp.stp_cty_nmstct = city.cty_nmstct    
    FROM	#masterbill_temp, city    
   WHERE	#masterbill_temp.stp_city = city.cty_code    

  UPDATE 	#masterbill_temp 
     SET	#masterbill_temp.ord_firstref = ref_number    
    FROM	#masterbill_temp, referencenumber   
   WHERE	#masterbill_temp.ord_hdrnumber = ref_tablekey and  
		referencenumber.ref_table='orderheader' and
		referencenumber.ref_sequence= (select min(ref_sequence)
						 from referencenumber, #masterbill_temp
                                                where #masterbill_temp.ord_hdrnumber = ref_tablekey
						  and ref_type = 'TICKET' 
                                                  and ref_table = 'orderheader') and
                referencenumber.ref_type ='TICKET'and
		ivd_sequence=1

  UPDATE 	#masterbill_temp 
     SET	#masterbill_temp.ivh_totalweight = i.ivh_totalweight
    FROM	#masterbill_temp, invoiceheader i  
   WHERE	#masterbill_temp.ivh_hdrnumber = i.ivh_hdrnumber and
 		ivd_sequence=1


  UPDATE 	a 
  SET		a.ivd_rate=b.ivd_rate,
		a.ivd_rateunit=b.ivd_rateunit,
		a.ivd_charge=b.ivd_charge,
                a.bill_quantity = b.bill_quantity	
  FROM		#masterbill_temp  a ,#masterbill_temp b
  WHERE		a.ivh_invoicenumber = b.ivh_invoicenumber and
		a.ivd_sequence =1 and
		b.ivd_sequence =(select min(c.ivd_sequence) 
		   		  from #masterbill_temp c 
		  	         where c.ivd_type='SUB' and 
                                       c.ivh_invoicenumber=a.ivh_invoicenumber)

   SELECT @MinOrdShpCon = MIN(ord_hdrnumber)
     FROM #masterbill_temp

--print cast(@minordshpcon as varchar(20))

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
          ivh_consignee_zip = @minconzip 	

  delete from #masterbill_temp
  where ivd_sequence=(select min(c.ivd_sequence) 
                        from #masterbill_temp c 
		       where c.ivd_type='SUB' and 
                             c.ivh_invoicenumber=#masterbill_temp.ivh_invoicenumber)


UPDATE #masterbill_temp
   SET company_loc = ivs_logocompanyloc
  FROM invoiceselection
 WHERE ivs_invoicedatawindow = 'd_mb_format87'  

SELECT @v_cmp_terms = min(name)
  FROM #masterbill_temp, labelfile
 WHERE abbr = cmp_terms 
   and labeldefinition = 'CreditTerms'

--PRINT @v_cmp_terms

SELECT @v_startpos = rtrim(ltrim(CHARINDEX(' ',@v_cmp_terms))) 

--PRINT CAST(@v_startpos AS VARCHAR(20))

IF @v_startpos > 0 
  BEGIN
	SELECT @v_invoice_terms = cast(SUBSTRING(@v_cmp_terms,@v_startpos + 1,999) as INT)
	UPDATE #masterbill_temp
   	   SET pay_date = cast(DATEADD(day, @v_invoice_terms, getdate()) as varchar(20))	

	--PRINT CAST(@V_INVOICE_TERMS AS VARCHAR(20))

	UPDATE #masterbill_temp
	   SET cmp_terms = @v_cmp_terms
  END
ELSE
   BEGIN
	Update #masterbill_temp
   	   SET cmp_terms = @v_cmp_terms
   END

select @minmov = 0
select @MinLgh = 0
select @v_lgh_trailer = ''
select @v_lgh_tractor = ''
select @v_cnt = 0 
select @v_lghcnt = 0
--select @minmov = min(mov_number) from #masterbill_temp
select @stp_number = 0
select @v_primary_tractor_type1 = ''
select @minord = 0

WHILE (SELECT COUNT(*) 
         FROM #MASTERBILL_TEMP
        WHERE mov_number > @MinMov) > 0
BEGIN

	SELECT @MinMov = MIN(mov_number) 
          FROM #MASTERBILL_TEMP
         WHERE mov_number > @MinMov

	SELECT @v_lghcnt = COUNT(*) FROM legheader WHERE mov_number = @MinMov 

	--print cast(@v_lghcnt as varchar(20))

	WHILE (SELECT COUNT(*) 
		 FROM legheader 
	        WHERE mov_number = @MinMov 
	          and lgh_number > @MinLgh ) > 0
	BEGIN	   
	
		   SELECT @Minlgh = (SELECT MIN(lgh_number) 
				       FROM legheader 
	                              WHERE mov_number = @MinMov and
	                                    lgh_number > @minlgh)
	
		   SELECT @MinOrd = (SELECT ord_hdrnumber
	                               FROM legheader
	                              WHERE lgh_number = @Minlgh)
	
		   --print cast(@minord as varchar(20))
	
	           SELECT @v_lgh_tractor = lgh_tractor ,
	                  @v_lgh_trailer = lgh_primary_trailer                               
		     FROM legheader 
		    WHERE lgh_number = @Minlgh 
		
	           select @v_cnt = count(*)                 
		     from #masterbill_temp, stops 
		    where #masterbill_temp.stp_number = stops.stp_number and
	                  stops.lgh_number = @Minlgh AND
	                  #masterbill_temp.ord_hdrnumber = @MinOrd	
		   
	            --print cast(@v_cnt as varchar(20))
		    --print cast(@Minlgh as varchar(20))
		    --print cast(@MinOrdShpCon as varchar(20))
	
		   select @stp_number = stops.stp_number 
	             from stops 
	            where stops.lgh_number = @Minlgh 
	              and stops.ord_hdrnumber = @MinOrd
	
		   --print cast(@stp_number as varchar(20))

		   select @lgh_cnt = count(distinct(lgh_number))
                     from legheader
                    where mov_number = @MinMov  
		
		  IF @lgh_cnt = 1 
		     Begin		  
		   	   update #masterbill_temp
		     	      set lgh_count  = @lgh_cnt
		            where mov_number = @MinMov 
			      and ivd_sequence = (select min(a.ivd_sequence)
		                                    from #masterbill_temp a
	                                           where a.mov_number = @minmov)
		     END
		
		  IF @lgh_cnt > 1 
		     Begin
			   update #masterbill_temp
		     	      set lgh_count  = @lgh_cnt
		            where mov_number = @MinMov 			      			
		     End
			
	
		   IF @v_cnt = 0 
			BEGIN	
				select @stp_number = stops.stp_number 
			          from stops 
			         where stops.lgh_number = @Minlgh 
		                   and stops.ord_hdrnumber = @MinOrd
	
				select @v_lgh_tractor = lgh_tractor,
	                               @v_lgh_trailer = lgh_primary_trailer
				  from legheader 
				 where lgh_number = @minLgh					   	    		   		 
			      
				 select @v_primary_tractor_type1 = name		  
				   from stops, legheader,tractorprofile trc, labelfile
				  where stops.lgh_number = @Minlgh and 
			                trc.trc_number = @v_lgh_tractor and
			                labeldefinition = 'TrcType1' and
			                abbr = trc.trc_type1	
		 	END	
	
		    ELSE   
	
		 	BEGIN  
					  
				   update #masterbill_temp
			              set primary_tractor_type1 = @v_primary_tractor_type1,
					  secondary_tractor_type1 = name,	
					  tractor2 = @v_lgh_tractor,
					  trailer2 = @v_lgh_trailer	  
				     from stops, legheader,#masterbill_temp, tractorprofile trc, labelfile
				    where #masterbill_temp.stp_number = @stp_number and
					  #masterbill_temp.stp_number = stops.stp_number and
			                  stops.lgh_number = @Minlgh and 
			                  trc.trc_number = @v_lgh_tractor and
			                  labeldefinition = 'TrcType1' and
			                  abbr = trc.trc_type1 AND
	                  		  #masterbill_temp.ord_hdrnumber = @MinOrd


				IF @v_lghcnt = 1 
				   BEGIN
				     UPDATE a 
				  	SET a.secondary_tractor_type1=b.secondary_tractor_type1		
				       FROM #masterbill_temp  a ,#masterbill_temp b
				      where b.secondary_tractor_type1 <> ''
				        and a.ivd_type <> 'LI'
                                        and b.mov_number = @MinMov 
	                  		and a.ord_hdrnumber = @MinOrd        
				   END
			  
					  
	                  END
	
		   
		END
END

SELECT @v_Minreftype = ''
SELECT @v_refdesc = ''
SELECT @v_REFSTRING = ''
SELECT @v_minREFseq = 0
SELECT @Minord = 0

WHILE (SELECT COUNT(*) 
         FROM #MASTERBILL_TEMP
        WHERE ORD_HDRNUMBER > @MinOrd) > 0
BEGIN

	SELECT @MinOrd = (SELECT MIN(ord_hdrnumber)
                            FROM #MASTERBILL_TEMP
                           WHERE ord_hdrnumber > @MinOrd)	

	WHILE (SELECT COUNT(*) 
		 FROM referencenumber 
	        WHERE ref_tablekey = @MinOrd 
	          and ref_table = 'orderheader' 
	          and ref_type NOT IN ('TICKET','PO #')
                  and ref_type > @v_Minreftype) > 0
	BEGIN	   		
		SELECT @v_Minreftype = (SELECT MIN(ref_type) 
			                  FROM referencenumber 
	                                 WHERE ref_tablekey = @MinOrd 
	         			   AND ref_table = 'orderheader' 
	          			   AND ref_type NOT IN ('TICKET','PO #')					   
	                                   AND REF_TYPE > @v_Minreftype)
	
		--print cast(@minord as varchar(20))
		--print @v_Minreftype 	
	
		SELECT @v_refdesc = name
	          FROM labelfile
	         WHERE labeldefinition = 'ReferenceNumbers' 
	           AND abbr = @v_Minreftype
	
		SELECT @v_REFSTRING = @v_REFSTRING + @v_refdesc+':'
		
		--print 'reftype loop' + ' '+@v_refstring       
	           
		   WHILE (SELECT COUNT(*)
	                    FROM referencenumber
	                   WHERE ref_type = @v_Minreftype
	                     AND ref_tablekey = @MinOrd
	                     and ref_sequence > @v_MinRefSeq) > 0
			BEGIN
				--print cast(@minord as varchar(20))
				SELECT @v_MinrefSeq = (SELECT min(ref_sequence)
	                    				 FROM referencenumber
				                        WHERE ref_type = @v_Minreftype
				                          AND ref_tablekey = @MinOrd
				                          AND ref_sequence > @v_MinRefSeq)

				 --print 'reftype loop '+ cast(@minord as varchar(20))
				 --print 'reftype loop '+ cast(@v_MinRefSeq as varchar(20))
				 --print 'reftype loop imari '+ @v_Minreftype				 
			
				SELECT @v_MinRefNumber = ref_number
				  FROM referencenumber
				 WHERE ref_type = @v_Minreftype
				   AND ref_tablekey = @MinOrd
				   AND ref_sequence = @v_MinRefSeq
	 
				SELECT @v_REFSTRING = @v_REFSTRING + @v_MinRefNumber+','	
				
				--print @v_refstring
			        --print cast(@v_minrefseq as varchar(20))
				 
			
			END
			--PTS# 32550 ILB 10/16/2006
			--IF len(@v_REFSTRING) > 1 
			--   BEGIN
			--	UPDATE #masterbill_temp
			--   	   SET reference_numbers = SUBSTRING ( @v_REFSTRING , 1 , len(@v_REFSTRING) - 1 ) 
			--	 WHERE ord_hdrnumber = @MinOrd
                        --           AND ivd_sequence = (select min(mas_temp.ivd_sequence)
                        --                                 from #masterbill_temp mas_temp
   			--	   			where mas_temp.ord_hdrnumber = @MinOrd)
			--   END	
				
		set @v_MinRefSeq = 0			
		END	

		--PTS# 32550 ILB 10/16/2006
		IF len(@v_REFSTRING) > 1 
		   BEGIN
			UPDATE #masterbill_temp
		   	   SET reference_numbers = SUBSTRING ( @v_REFSTRING , 1 , len(@v_REFSTRING) - 1 ) 
			 WHERE ord_hdrnumber = @MinOrd
                           AND ivd_sequence = (select min(mas_temp.ivd_sequence)
                                                 from #masterbill_temp mas_temp
				   			where mas_temp.ord_hdrnumber = @MinOrd)
		   END	
		set @v_minreftype = ''
		set @v_refstring = ''
		--print 'order loop '+ cast(@v_MinRefSeq as varchar(20))
		
		
END

UPDATE #masterbill_temp
   SET tractor1 = '',
       tractor2 = '',
       trailer1 = '',
       trailer2 = ''
 WHERE stp_number < 1


UPDATE #masterbill_temp
   SET rebill_creditmemo = name
  FROM labelfile, #masterbill_temp
 WHERE labelfile.abbr = #masterbill_temp.ivh_definition
   and labelfile.labeldefinition = 'InvoiceDefinitions'

select @v_rebillcreditmemo_cnt = count(*)
  from #masterbill_temp
 where ivh_definition IN ('CRD','RBIL') 

--PRINT CAST(@v_rebillcreditmemo_cnt AS VARCHAR(30))       

UPDATE #masterbill_temp
   SET rebill_creditmemo_cnt = @v_rebillcreditmemo_cnt

/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */  
select @v_counter = 1  
while @v_counter <>  @copy  
 begin  
 	select @v_counter = @v_counter + 1  
 	select 	ord_hdrnumber,
		ivh_invoicenumber ,  
		ivh_hdrnumber , 
		ivh_billto ,
		ivh_shipper ,
		ivh_consignee ,
		ivh_totalcharge ,   
		ivh_originpoint  ,  
		ivh_destpoint ,   
		ivh_origincity ,   
		ivh_destcity ,   
		ivh_shipdate ,   
		ivh_deliverydate ,   
		ivh_revtype1 ,
		ivh_mbnumber ,
		ivh_shipper_name  ,
		ivh_shipper_address ,
		ivh_shipper_address2 ,
		ivh_shipper_nmstct  ,
		ivh_shipper_zip ,
		ivh_billto_name ,
		ivh_billto_address ,
		ivh_billto_address2 ,
		ivh_billto_nmstct  ,
		ivh_billto_zip ,
		ivh_consignee_name ,
		ivh_consignee_address ,
		ivh_consignee_address2 ,
		ivh_consignee_nmstct ,
		ivh_consignee_zip ,
		origin_nmstct ,
		origin_state ,
		dest_nmstct ,
		dest_state ,
		billdate ,
		cmp_mailto_name ,
		bill_quantity ,
		ivd_weight ,
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
		cmd_name ,
		ivd_description ,
		ivd_type,
		stp_city ,
		stp_cty_nmstct ,
		ivd_sequence ,
		stp_number ,
		copy ,
		cmp_id ,
		ord_firstref ,                
		ivh_totalweight ,
		billto_altid ,
		cht_basis ,
		cht_basisunit ,
		ivd_distance ,
		ivd_distunit ,
		ivd_groupcontrol,
		billto_cmp_othertype1,
		cmp_contact,
		cmp_primaryphone,
		cmp_terms,
		pay_date,
		cust_po_no,
		company_loc,		
		primary_tractor_type1 ,
		secondary_tractor_type1 ,
		reference_numbers ,
                ivh_definition,
                lgh_count,
                rebill_creditmemo,
		rebill_creditmemo_cnt      	
		--mov_number
	FROM     #masterbill_temp
	where    copy = 1 
     ORDER BY ord_hdrnumber, ivd_sequence 

end   
  
ERROR_END:  
/* FINAL SELECT - FORMS RETURN SET */ 
select 
	ord_hdrnumber,
	ivh_invoicenumber ,  
	ivh_hdrnumber , 
	ivh_billto ,
	ivh_shipper ,
	ivh_consignee ,
	ivh_totalcharge ,   
	ivh_originpoint  ,  
	ivh_destpoint ,   
	ivh_origincity ,   
	ivh_destcity ,   
	ivh_shipdate ,   
	ivh_deliverydate ,   
	ivh_revtype1 ,
	ivh_mbnumber ,
	ivh_shipper_name  ,
	ivh_shipper_address ,
	ivh_shipper_address2 ,
	ivh_shipper_nmstct  ,
	ivh_shipper_zip ,
	ivh_billto_name ,
	ivh_billto_address ,
	ivh_billto_address2 ,
	ivh_billto_nmstct  ,
	ivh_billto_zip ,
	ivh_consignee_name ,
	ivh_consignee_address ,
	ivh_consignee_address2 ,
	ivh_consignee_nmstct ,
	ivh_consignee_zip ,
	origin_nmstct ,
	origin_state ,
	dest_nmstct ,
	dest_state ,
	billdate ,
	cmp_mailto_name ,
	bill_quantity ,
	ivd_weight ,
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
	cmd_name ,
	ivd_description ,
	ivd_type,
	stp_city ,
	stp_cty_nmstct ,
	ivd_sequence ,
	stp_number ,
	copy ,
	cmp_id ,
	ord_firstref ,                
	ivh_totalweight ,
	billto_altid ,
	cht_basis ,
	cht_basisunit ,
	ivd_distance ,
	ivd_distunit ,
	ivd_groupcontrol,
	billto_cmp_othertype1,
	cmp_contact,
	cmp_primaryphone,
	cmp_terms	,
	pay_date,
	cust_po_no,
	company_loc,
	primary_tractor_type1 ,
	secondary_tractor_type1,
	tractor1 ,
        tractor2 ,
        trailer1,
        trailer2,
        reference_numbers,
	ivh_definition,
        lgh_count,
        rebill_creditmemo,
	rebill_creditmemo_cnt                     
	--mov_number
    FROM #masterbill_temp
ORDER BY ord_hdrnumber, ivd_sequence


--SELECT * 
--FROM		#masterbill_temp
--ORDER BY	ord_hdrnumber, ivd_sequence

DROP TABLE #masterbill_temp

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 select @v_ret_value = @@ERROR   
return @v_ret_value  
GO
GRANT EXECUTE ON  [dbo].[d_masterbill87_sp] TO [public]
GO
