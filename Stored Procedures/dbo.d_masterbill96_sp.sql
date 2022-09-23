SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

  
CREATE  PROC [dbo].[d_masterbill96_sp] (
	@reprintflag VARCHAR(10),
	@mbnumber INT,
	@billto VARCHAR(8), 
	@revtype1 VARCHAR(6), 
	@mbstatus VARCHAR(6),
	@shipstart DATETIME,
    @shipend DATETIME,
	@billdate DATETIME, 
	@shipper VARCHAR(8),
	@consignee VARCHAR(8),
    @copy INT,
	@ivh_invoicenumber VARCHAR(12))
AS

/**
 * 
 * NAME:
 * dbo.d_masterbill96_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Return data for master bill format 96
 *
 * RETURNS:
 * na
 *
 * RESULT SETS: 
 * see retrun SET
 *
 * PARAMETERS:
 *	001 - @reprintflag VARCHAR(10),
 *	002 - @mbnumber INT,
 *  003 - @billto VARCHAR(8), 
 *  004 - @revtype1 VARCHAR(6), 
 *  005 - @mbstatus VARCHAR(6),
 *  006 - @shipstart DATETIME,
 *  007 - @shipend DATETIME,
 *  008 - @billdate DATETIME, 
 *  009 - @shipper VARCHAR(8),
 *  010 - @consignee VARCHAR(8),
 *  011 - @copy INT,
 *  012 - @ivh_invoicenumber VARCHAR(12))
 *
 * REVISION HISTORY:
 * 03/26/07.01 PTS36587 - OS - Created stored proc as modification of proc for  d_mb_format
 *
 **/

DECLARE @int0  INT
SELECT @int0 = 0

SELECT @shipstart = CONVERT(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = CONVERT(char(12),@shipend  )+'23:59:59'

CREATE TABLE #masterbill_temp (ord_hdrnumber INT,
		ivh_invoicenumber VARCHAR(12),  
		ivh_hdrnumber INT NULL, 
		ivh_billto VARCHAR(8) NULL,
		ivh_shipper VARCHAR(8) NULL,
		ivh_consignee VARCHAR(8) NULL,
		ivh_totalcharge MONEY NULL,   
		ivh_originpoint  VARCHAR(8) NULL,  
		ivh_destpoint VARCHAR(8) NULL,   
		ivh_origincity INT NULL,   
		ivh_destcity INT NULL,   
		ivh_shipdate DATETIME NULL,   
		ivh_deliverydate DATETIME NULL,   
		ivh_revtype1 VARCHAR(6) NULL,
		ivh_mbnumber INT NULL,
		ivh_billto_name VARCHAR(30)  NULL,
		ivh_billto_address VARCHAR(40) NULL,
		ivh_billto_address2 VARCHAR(40) NULL,
		ivh_billto_nmstct VARCHAR(25) NULL ,
		ivh_billto_zip VARCHAR(9) NULL,
		ivh_ref_number VARCHAR(30) NULL,
		ivh_tractor VARCHAR(8) NULL,
		ivh_trailer VARCHAR(13) NULL,
		origin_nmstct VARCHAR(25) NULL,
		origin_state VARCHAR(2) NULL,
		dest_nmstct VARCHAR(25) NULL,
		dest_state VARCHAR(2) NULL,
		billdate DATETIME NULL,
		cmp_mailto_name VARCHAR(30)  NULL,
		bill_quantity FLOAT  NULL,
		ivd_refnumber VARCHAR(30) NULL,
		ivd_weight FLOAT NULL,
		ivd_weightunit CHAR(6) NULL,
		ivd_count INT NULL,
		ivd_countunit CHAR(6) NULL,
		ivd_volume INT NULL,
		ivd_volunit CHAR(6) NULL,
		ivd_unit CHAR(6) NULL,
		ivd_rate MONEY NULL,
		ivd_rateunit CHAR(6) NULL,
		ivd_charge MONEY NULL,
		cht_description VARCHAR(30) NULL,
		cht_primary CHAR(1) NULL,
		cmd_name VARCHAR(60)  NULL,
		ivd_description VARCHAR(60) NULL,
		ivd_type CHAR(6) NULL,
		stp_city INT NULL,
		stp_cty_nmstct VARCHAR(25) NULL,
		ivd_sequence INT NULL,
		stp_number INT NULL,
		copy INT NULL,
		ref_number VARCHAR(30) NULL,
		cmp_id VARCHAR(8) NULL,
		cmp_name VARCHAR(30) NULL,
		ivh_driver VARCHAR(8) NULL,
		mpp_lastname VARCHAR(40) NULL,
		mpp_firstname VARCHAR(40) NULL,
		ivh_remark VARCHAR(254) NULL,

		ivh_shipper_name VARCHAR(30) NULL ,
		ivh_shipper_address VARCHAR(40) NULL,
		ivh_shipper_address2 VARCHAR(40) NULL,
		ivh_shipper_nmstct VARCHAR(25) NULL ,
		ivh_shipper_zip VARCHAR(9) NULL,

		ivh_consignee_name VARCHAR(30)  NULL,
		ivh_consignee_address VARCHAR(40) NULL,
		ivh_consignee_address2 VARCHAR(40) NULL,
		ivh_consignee_nmstct VARCHAR(25)  NULL,
		ivh_consignee_zip VARCHAR(9) NULL,

		tar_number INT NULL,
		tar_tariffnumber VARCHAR(12) NULL,
		tar_tariffitem VARCHAR(12) NULL)
		
		

/* IF PRINTINGFLAG IS SET TO REPRINT, RETRIEVE AN ALREADY PRINTED MB BY # */
if UPPER(@reprintflag) = 'REPRINT' 
BEGIN
	INSERT INTO #masterbill_temp
	SELECT 	ISNULL(invoiceheader.ord_hdrnumber, -1),
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
	 	ivh_billto_address = CASE
			WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
			WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
			ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    	END,
	 	ivh_billto_address2 = CASE
			WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
			WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
			ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    	END,
	 	ivh_billto_nmstct = CASE
			WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   		ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
			WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   		ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
			ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
	    	END,
		ivh_billto_zip = CASE
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
		ISNULL(ivd.ivd_refnum, ''),
		ISNULL(ivd.ivd_wgt, 0),
		ISNULL(ivd.ivd_wgtunit, ''),
		ISNULL(ivd.ivd_count, 0),
		ISNULL(ivd.ivd_countunit, ''),
		ISNULL(ivd.ivd_volume, 0),
		ISNULL(ivd.ivd_volunit, ''),
		ISNULL(ivd.ivd_unit, ''),
		ISNULL(ivd.ivd_rate, 0),
		ISNULL(ivd.ivd_rateunit, ''),
		ivd.ivd_charge,
		cht.cht_description, 
		cht.cht_primary,
		cmd.cmd_name,
		ISNULL(ivd_description, ''),
		ivd.ivd_type,
		ISNULL(stp.stp_city,''),
		'',
		ivd_sequence,
		ISNULL(stp.stp_number, -1),
		@copy,
		'',
		ivd.cmp_id cmp_id,
		cmp2.cmp_name,
		invoiceheader.ivh_driver,
		ISNULL(mpp.mpp_lastname,'UNKNOWN'),
		ISNULL(mpp.mpp_firstname,'UNKNOWN'),
		ISNULL(invoiceheader.ivh_remark,''),

		ivh_shipto_name = cmp3.cmp_name,
		ivh_shipto_address = CASE
			WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
			WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
			ELSE ISNULL(cmp3.cmp_mailto_address1,'')
	    	END,
	 	ivh_shipto_address2 = CASE
			WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
			WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
			ELSE ISNULL(cmp3.cmp_mailto_address2,'')
	    	END,
	 	ivh_shipto_nmstct = CASE
			WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   		ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',cmp3.cty_nmstct) -1 END),'')
			WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   		ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',cmp3.cty_nmstct) -1 END),'')
			ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN 0
									    ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct) -1 END),'')
	    	END,
		ivh_shipto_zip = CASE
			WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
			WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
			ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    	END,

		ivh_consignee_name = cmp4.cmp_name,
	 	ivh_consignee_address = CASE
			WHEN cmp4.cmp_mailto_name IS NULL THEN ISNULL(cmp4.cmp_address1,'')
			WHEN (cmp4.cmp_mailto_name <= ' ') THEN ISNULL(cmp4.cmp_address1,'')
			ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    	END,
	 	ivh_consignee_address2 = CASE
			WHEN cmp4.cmp_mailto_name IS NULL THEN ISNULL(cmp4.cmp_address2,'')
			WHEN (cmp4.cmp_mailto_name <= ' ') THEN ISNULL(cmp4.cmp_address2,'')
			ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    	END,
	 	ivh_consignee_nmstct = CASE
			WHEN cmp4.cmp_mailto_name IS NULL THEN 
		   		ISNULL(SUBSTRING(cmp4.cty_nmstct,1,CASE WHEN CHARINDEX('/',cmp4.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',cmp4.cty_nmstct) -1 END),'')
			WHEN (cmp4.cmp_mailto_name <= ' ') THEN 
		   		ISNULL(SUBSTRING(cmp4.cty_nmstct,1,CASE WHEN CHARINDEX('/',cmp4.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',cmp4.cty_nmstct) -1 END),'')
			ELSE ISNULL(SUBSTRING(cmp4.mailto_cty_nmstct,1,CASE WHEN CHARINDEX('/',cmp4.mailto_cty_nmstct)- 1 < 0 THEN 0
							    		    ELSE CHARINDEX('/',cmp4.mailto_cty_nmstct) -1 END),'')
	    	END,
		ivh_consignee_zip = CASE
			WHEN cmp4.cmp_mailto_name IS NULL  THEN ISNULL(cmp4.cmp_zip ,'')  
			WHEN (cmp4.cmp_mailto_name <= ' ') THEN ISNULL(cmp4.cmp_zip,'')
			ELSE ISNULL(cmp4.cmp_mailto_zip,'')

	    	END,

		ISNULL(ivd.tar_number,''),
		ISNULL(ivd.tar_tariffnumber,''),
		ISNULL(ivd.tar_tariffitem,'')
		
	FROM invoiceheader JOIN invoicedetail ivd ON (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)  
		JOIN company cmp1 ON (cmp1.cmp_id = invoiceheader.ivh_billto)
		JOIN company cmp2 ON (ivd.cmp_id = cmp2.cmp_id)
		JOIN company cmp3 ON (cmp3.cmp_id = invoiceheader.ivh_shipper) 
		JOIN company cmp4 ON (cmp4.cmp_id = invoiceheader.ivh_consignee) 
		JOIN city cty1 ON (cty1.cty_code = invoiceheader.ivh_origincity)   
		JOIN city cty2 ON (cty2.cty_code = invoiceheader.ivh_destcity)
		JOIN chargetype cht ON (ivd.cht_itemcode = cht.cht_itemcode)
		LEFT OUTER JOIN stops stp ON (ivd.stp_number = stp.stp_number)
		LEFT OUTER JOIN commodity cmd ON (ivd.cmd_code = cmd.cmd_code)
		LEFT OUTER JOIN manpowerprofile mpp ON (invoiceheader.ivh_driver = mpp.mpp_id)          
	WHERE invoiceheader.ivh_mbnumber = @mbnumber 
		AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))
		AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))
		--PTS 38010 SGB 06/29/07 Allow print for invoices with $0 
		--AND ivd.ivd_charge <> 0
END

/* FOR MASTER BILLS WITH 'RTP' STATUS */
IF UPPER(@reprintflag) <> 'REPRINT' 
BEGIN
	INSERT INTO #masterbill_temp
	SELECT ISNULL(invoiceheader.ord_hdrnumber,-1),
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
            	ivh_billto_name = cmp1.cmp_name,
            	ivh_billto_address = CASE
			WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')
			WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')
			ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	      	END,
            	ivh_billto_address2 = CASE
			WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')
			WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')
			ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	      	END,
            	ivh_billto_nmstct = CASE
			WHEN cmp1.cmp_mailto_name IS NULL THEN 
		   		ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
			WHEN (cmp1.cmp_mailto_name <= ' ') THEN 
		   		ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')
			ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')
	      	END,
            	ivh_billto_zip = CASE
			WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')  
			WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')
			ELSE ISNULL(cmp1.cmp_mailto_zip,'')
	      	END,
	    	invoiceheader.ivh_ref_number,
	    	invoiceheader.ivh_tractor,
	    	invoiceheader.ivh_trailer,
	    	cty1.cty_nmstct origin_nmstct,
            	cty1.cty_state origin_state,
            	cty2.cty_nmstct dest_nmstct,
            	cty2.cty_state dest_state,
            	@billdate billdate,
            	ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
            	ivd.ivd_quantity 'bill_quantity',
	    	ISNULL(ivd.ivd_refnum, ''),
            	ISNULL(ivd.ivd_wgt, 0),
            	ISNULL(ivd.ivd_wgtunit, ''),
            	ISNULL(ivd.ivd_count, 0),
            	ISNULL(ivd.ivd_countunit, ''),
            	ISNULL(ivd.ivd_volume, 0),
            	ISNULL(ivd.ivd_volunit, ''),
            	ISNULL(ivd.ivd_unit, ''),
            	ISNULL(ivd.ivd_rate, 0),
            	ISNULL(ivd.ivd_rateunit, ''),
            	ivd.ivd_charge,
				cht.cht_description, 
            	cht.cht_primary,
				cmd.cmd_name,
            	ISNULL(ivd_description, ''),
            	ivd.ivd_type,
            	ISNULL(stp.stp_city,''),
            	'',
            	ivd_sequence,
            	ISNULL(stp.stp_number, -1),
            	@copy,
	    		'',
            	ivd.cmp_id cmp_id,
	    	cmp2.cmp_name,
	    	invoiceheader.ivh_driver,
	    	ISNULL(mpp.mpp_lastname,'UNKNOWN'),
			ISNULL(mpp.mpp_firstname,'UNKNOWN'),
	    	ISNULL(invoiceheader.ivh_remark,''),

		ivh_shipto_name = cmp3.cmp_name,
		ivh_shipto_address = CASE
			WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address1,'')
			WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address1,'')
			ELSE ISNULL(cmp3.cmp_mailto_address1,'')
	    	END,
	 	ivh_shipto_address2 = CASE
			WHEN cmp3.cmp_mailto_name IS NULL THEN ISNULL(cmp3.cmp_address2,'')
			WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_address2,'')
			ELSE ISNULL(cmp3.cmp_mailto_address2,'')
	    	END,
	 	ivh_shipto_nmstct = CASE
			WHEN cmp3.cmp_mailto_name IS NULL THEN 
		   		ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',cmp3.cty_nmstct) -1 END),'')
			WHEN (cmp3.cmp_mailto_name <= ' ') THEN 
		   		ISNULL(SUBSTRING(cmp3.cty_nmstct,1,CASE WHEN CHARINDEX('/',cmp3.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',cmp3.cty_nmstct) -1 END),'')
			ELSE ISNULL(SUBSTRING(cmp3.mailto_cty_nmstct,1,CASE WHEN CHARINDEX('/',cmp3.mailto_cty_nmstct)- 1 < 0 THEN 0
									    ELSE CHARINDEX('/',cmp3.mailto_cty_nmstct) -1 END),'')
	    	END,
		ivh_shipto_zip = CASE
			WHEN cmp3.cmp_mailto_name IS NULL  THEN ISNULL(cmp3.cmp_zip ,'')  
			WHEN (cmp3.cmp_mailto_name <= ' ') THEN ISNULL(cmp3.cmp_zip,'')
			ELSE ISNULL(cmp3.cmp_mailto_zip,'')
	    	END,

		ivh_consignee_name = cmp4.cmp_name,
	 	ivh_consignee_address = CASE
			WHEN cmp4.cmp_mailto_name IS NULL THEN ISNULL(cmp4.cmp_address1,'')
			WHEN (cmp4.cmp_mailto_name <= ' ') THEN ISNULL(cmp4.cmp_address1,'')
			ELSE ISNULL(cmp1.cmp_mailto_address1,'')
	    	END,
	 	ivh_consignee_address2 = CASE
			WHEN cmp4.cmp_mailto_name IS NULL THEN ISNULL(cmp4.cmp_address2,'')
			WHEN (cmp4.cmp_mailto_name <= ' ') THEN ISNULL(cmp4.cmp_address2,'')
			ELSE ISNULL(cmp1.cmp_mailto_address2,'')
	    	END,
	 	ivh_consignee_nmstct = CASE
			WHEN cmp4.cmp_mailto_name IS NULL THEN 
		   		ISNULL(SUBSTRING(cmp4.cty_nmstct,1,CASE WHEN CHARINDEX('/',cmp4.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',cmp4.cty_nmstct) - 1 END),'')
			WHEN (cmp4.cmp_mailto_name <= ' ') THEN 
		   		ISNULL(SUBSTRING(cmp4.cty_nmstct,1,CASE WHEN CHARINDEX('/',cmp4.cty_nmstct)- 1 < 0 THEN 0
									ELSE CHARINDEX('/',cmp4.cty_nmstct) - 1 END),'')
			ELSE ISNULL(SUBSTRING(cmp4.mailto_cty_nmstct,1,CASE WHEN CHARINDEX('/',cmp4.mailto_cty_nmstct)- 1 < 0 THEN 0
								 	    ELSE CHARINDEX('/',cmp4.mailto_cty_nmstct)- 1 END),'')
	    	END,
		ivh_consignee_zip = CASE
			WHEN cmp4.cmp_mailto_name IS NULL  THEN ISNULL(cmp4.cmp_zip ,'')  
			WHEN (cmp4.cmp_mailto_name <= ' ') THEN ISNULL(cmp4.cmp_zip,'')
			ELSE ISNULL(cmp4.cmp_mailto_zip,'')
	    	END,
		ISNULL(ivd.tar_number,''),
		ISNULL(ivd.tar_tariffnumber,''),
		ISNULL(ivd.tar_tariffitem,'')
		
	FROM invoiceheader JOIN invoicedetail ivd ON (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)
		JOIN company cmp1 ON (cmp1.cmp_id = invoiceheader.ivh_billto)
		JOIN company cmp2 ON (ivd.cmp_id = cmp2.cmp_id)
		JOIN company cmp3 ON (cmp3.cmp_id = invoiceheader.ivh_shipper) 
		JOIN company cmp4 ON (cmp4.cmp_id = invoiceheader.ivh_consignee) 
		JOIN city cty1 ON (cty1.cty_code = invoiceheader.ivh_origincity)     
	    JOIN city cty2 ON (cty2.cty_code = invoiceheader.ivh_destcity)
		JOIN chargetype cht ON (ivd.cht_itemcode = cht.cht_itemcode)
		LEFT OUTER JOIN  commodity cmd ON (ivd.cmd_code = cmd.cmd_code)
		LEFT OUTER JOIN  stops stp ON (ivd.stp_number = stp.stp_number)
		LEFT OUTER JOIN manpowerprofile mpp ON (invoiceheader.ivh_driver = mpp.mpp_id)        
	WHERE invoiceheader.ivh_billto = @billto 
		AND invoiceheader.ivh_shipdate BETWEEN @shipstart AND @shipend 
		AND invoiceheader.ivh_mbstatus = 'RTP' 
		AND @revtype1 IN (invoiceheader.ivh_revtype1,'UNK') 
        AND @shipper IN (invoiceheader.ivh_shipper,'UNKNOWN') 
        AND @consignee IN (invoiceheader.ivh_consignee,'UNKNOWN') 
        AND @ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master')
        --PTS 38010 SGB 06/29/07 Allow print for invoices with $0 
		--AND ivd.ivd_charge <> 0
END

SELECT * FROM #masterbill_temp
ORDER BY	ord_hdrnumber, ivd_sequence 

DROP TABLE #masterbill_temp

GO
GRANT EXECUTE ON  [dbo].[d_masterbill96_sp] TO [public]
GO
