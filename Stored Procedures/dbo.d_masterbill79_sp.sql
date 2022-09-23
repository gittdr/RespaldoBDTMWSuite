SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[d_masterbill79_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @revtype2 varchar(6),@mbstatus varchar(6),
	                       @shipstart datetime,@shipend datetime,@billdate datetime, 
                               @shipper varchar(8), @consignee varchar(8),
                               @copy int,@ivh_invoicenumber varchar(12),
			       @delstart datetime, @delend datetime,
			       @revtype3 varchar(6),
			       @revtype4 varchar(6))
AS
/**
 * 
 * NAME:
 * dbo.d_masterbill79_sp 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * This stored proc returns a result set to the d_mbformat79 datawindow
 *
 * RETURNS:
 * N/A 
 * 
 * RESULT SETS: 
 * See selection list
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
 * 014 - @delstart datetime, input, null;
 *       This parameter indicates the delivery start date to filter by.
 *
 * 015 - @delend datetime, input, null;
 *       This parameter indicates the delivery end date to filter by.
 *
 * 016 - @revtype3 varchar(6), input, null;
 *       This parameter indicates the revtype3 to be used in the where clause.
 *
 * 017 - @revtype4 varchar(6), input, null;
 *       This parameter indicates the revtype4 to be used in the where clause.
 *
 * REFERENCES: NONE
 *
 * 
 * REVISION HISTORY:
 * 02/13/2006.01 - PRB - New MasterBill format for Hine's Trucking.  Format 79.
 *
 **/


DECLARE @int0  int, @min_deliveryseq int, @min_shipseq int, @ord_hdrnumber int
SELECT @int0 = 0

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'


CREATE TABLE #masterbill_temp (		ord_hdrnumber int,
		ivh_invoicenumber varchar(12),
		ivh_description varchar(100) NULL,  
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
		copy int NULL,
		ord_firstdeliveryticket varchar(20) NULL,
		ivh_totalweight float NULL,
                ord_firstshipticket varchar (20))

-- if printflag is set to REPRINT, retrieve an already printed mb by #
if UPPER(@reprintflag) = 'REPRINT' 
  BEGIN
    INSERT INTO	#masterbill_temp
    SELECT 	IsNull(invoiceheader.ord_hdrnumber, -1),
		invoiceheader.ivh_invoicenumber,
		ivh_description = Case ord_hdrnumber
   		When 0 Then (Select ISNULL(cht_description, '') from invoicedetail d, chargetype c
                                       where d.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
                                       and ivd_sequence = 1
                                       and c.cht_itemcode = d.cht_itemcode)
   		Else (Select ISNULL(ivd_description, '') from invoicedetail d
                                where d.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
                                and ivd_sequence = (Select min (ivd_sequence) from
                                                    invoicedetail d2 where
                                                    d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
                                                    and ivd_type = 'DRP'))
   		END,
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
		ivh_consignee_name = ivh_consignee, --cmp3.cmp_name,
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
		cty1.cty_state	  origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state	  dest_state,
		ivh_billdate      billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		@copy,
		ord_firstdeliveryticket = ISNULL((SELECT MIN(ref_sequence)
     		 				  FROM referencenumber, invoiceheader
    		 				  WHERE invoiceheader.ord_hdrnumber = ref_tablekey
	  	 				  AND ref_table = 'orderheader'
                 				  AND ref_type = 'DT'), ''),
		invoiceheader.ivh_totalweight,
 		ord_firstshipticket = ISNULL((SELECT MIN(ref_sequence)
     		 				  FROM referencenumber, invoiceheader
    		 				  WHERE invoiceheader.ord_hdrnumber = ref_tablekey
	  	 				  AND ref_table = 'orderheader'
                 				  AND ref_type = 'ST'), '')
    FROM 	invoiceheader INNER JOIN company cmp1
		ON invoiceheader.ivh_billto = cmp1.cmp_id
		INNER JOIN company cmp2
		ON invoiceheader.ivh_shipper = cmp2.cmp_id
		INNER JOIN company cmp3
		ON invoiceheader.ivh_consignee = cmp3.cmp_id
		INNER JOIN city cty1
		ON invoiceheader.ivh_origincity = cty1.cty_code
		INNER JOIN city cty2
		ON invoiceheader.ivh_destcity = cty2.cty_code

   WHERE	( invoiceheader.ivh_mbnumber = @mbnumber )
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))

  END
-- for master bills with 'RTP' status

IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
     INSERT INTO 	#masterbill_temp
     SELECT 	IsNull(invoiceheader.ord_hdrnumber,-1) AS ord_hdrnumber,
		invoiceheader.ivh_invoicenumber,
		ivh_description = Case invoiceheader.ord_hdrnumber
   		When 0 Then (Select ISNULL(cht_description, '') from invoicedetail d,chargetype c
                                       where d.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
                                       and ivd_sequence = 1
                                       and c.cht_itemcode = d.cht_itemcode)
   		Else (Select ISNULL(ivd_description, '') from invoicedetail d
                                where d.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
                                and ivd_sequence = (Select min (ivd_sequence) from
                                                    invoicedetail d2 where
                                                    d2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
                                                    and ivd_type = 'DRP'))
   		END,  
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
	ivh_consignee_name = ivh_consignee,
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
		cty1.cty_state	  origin_state,
		cty2.cty_nmstct   dest_nmstct,
		cty2.cty_state	  dest_state,
		@billdate	  billdate,
		ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
		@copy copy,
		ord_firstdeliveryticket = ISNULL((SELECT MIN(ref_number)
     		 				  FROM referencenumber, invoiceheader
    		 				  WHERE invoiceheader.ord_hdrnumber = ref_tablekey
	  	 				  AND ref_table = 'orderheader'
                 				  AND ref_type = 'DT'), ''),
		invoiceheader.ivh_totalweight,
		ord_firstshipticket = ISNULL((SELECT MIN(ref_number)
     		 				  FROM referencenumber, invoiceheader
    		 				  WHERE invoiceheader.ord_hdrnumber = ref_tablekey
	  	 				  AND ref_table = 'orderheader'
                 				  AND ref_type = 'ST'), '')

	FROM 	invoiceheader INNER JOIN company cmp1
		ON invoiceheader.ivh_billto = cmp1.cmp_id
		INNER JOIN company cmp2
		ON invoiceheader.ivh_shipper = cmp2.cmp_id
		INNER JOIN company cmp3
		ON invoiceheader.ivh_consignee = cmp3.cmp_id
		INNER JOIN city cty1
		ON invoiceheader.ivh_origincity = cty1.cty_code
		INNER JOIN city cty2
		ON invoiceheader.ivh_destcity = cty2.cty_code

	WHERE  
		( invoiceheader.ivh_billto = @billto )
		AND ( invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
		AND ( invoiceheader.ivh_deliverydate between @delstart AND @delend )
		AND (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK'))
		AND (@revtype3 in (invoiceheader.ivh_revtype3,'UNK'))
		AND (@revtype4 in (invoiceheader.ivh_revtype4,'UNK'))
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		AND (@ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master'))
		--AND invoiceheader.ivh_totalcharge > 0)

  END
--   update  #masterbill_temp
--   Set stp_cty_nmstct = ref_number 
--   From referencenumber
--   where ref_table = 'orderheader'
--   and ref_tablekey = ord_hdrnumber
--   and ref_type = 
--  UPDATE 	#masterbill_temp 
--  SET		#masterbill_temp.stp_cty_nmstct = city.cty_nmstct
--  FROM		#masterbill_temp, city 
--  WHERE		#masterbill_temp.stp_city = city.cty_code


--Create a cursor based on the select statement below
DECLARE minseq_cursor CURSOR FOR  
 SELECT distinct(ord_hdrnumber)
   FROM #masterbill_temp

--Populate the cursor based on the select statement above  
OPEN minseq_cursor  
  
--Execute the initial fetch of the first order on the masterbill
FETCH NEXT FROM minseq_cursor INTO @ord_hdrnumber 
  
--If the fetch is succesful continue to loop
WHILE @@fetch_status = 0  
 BEGIN  
  
   --Get the sequence number for the first delivery ticket and ship ticket
   --number for the current order
   select @min_deliveryseq = min(ref_sequence)
     from referencenumber, #masterbill_temp
    where #masterbill_temp.ord_hdrnumber = ref_tablekey and
	  ref_tablekey = @ord_hdrnumber and
          ref_table = 'orderheader' and
          ref_type = 'DT'

   select @min_shipseq = min(ref_sequence)
     from referencenumber, #masterbill_temp
    where #masterbill_temp.ord_hdrnumber = ref_tablekey and
	  ref_tablekey = @ord_hdrnumber and
          ref_table = 'orderheader' and
          ref_type = 'ST'
   
   --Update the temp table with first delivery/ship ticket for the current order
   -- PTS 20029 - DJM - Modified the SQL to return 'UNKNOWN' value if the value is null
   UPDATE #masterbill_temp 
      SET #masterbill_temp.ord_firstdeliveryticket = isnull(ref_number,'UNKNOWN')
     FROM #masterbill_temp, referencenumber 
    WHERE #masterbill_temp.ord_hdrnumber = ref_tablekey and
	  ref_tablekey = @ord_hdrnumber and		  
	  ref_sequence = @min_deliveryseq and
	  ref_table = 'orderheader' and
	  ref_type = 'DT'			

   -- PTS 20029 - DJM - Modified the SQL to return 'UNKNOWN' value if the value is null
   UPDATE #masterbill_temp 
      SET #masterbill_temp.ord_firstshipticket = isnull(ref_number,'UNKNOWN')
     FROM #masterbill_temp, referencenumber 
    WHERE #masterbill_temp.ord_hdrnumber = ref_tablekey and
	  ref_tablekey = @ord_hdrnumber and		 
	  ref_sequence = @min_shipseq and
	  ref_table = 'orderheader' and
	  ref_type = 'ST'			
 	 
   --Fetch the next ord_hdrnumber from the list
   FETCH NEXT FROM minseq_cursor INTO @ord_hdrnumber
  
END  
  
--Close cursor  
CLOSE minseq_cursor
--Release cusor resources  
DEALLOCATE minseq_cursor  

SELECT * 
  FROM		#masterbill_temp
  ORDER BY	ivh_consignee_name,
		ivh_description,
		ord_firstdeliveryticket

DROP TABLE #masterbill_temp
GO
GRANT EXECUTE ON  [dbo].[d_masterbill79_sp] TO [public]
GO
