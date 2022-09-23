SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill121_sp] (
	@p_reprintflag varchar(10),
	@p_mbnumber int,
	@p_billto varchar(8), 
	@p_revtype1 varchar(6), 
	@p_mbstatus varchar(6),
	@p_shipstart datetime,
	@p_shipend datetime,
	@p_billdate datetime, 
	@p_shipper varchar(8),
	@p_consignee varchar(8),
	@p_copy int, 
	@p_ivh_invoicenumber varchar(12)
)
AS

/*
 * 
 * NAME:d_masterbill121_sp
 * dbo.
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoices 
 * based on the Billto selected in the interface.
 *
 * RETURNS:
 * 0 - uniqueness has not been violated 
 * 0 - uniqueness has been violated   
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_reprintflag, int, input, null;
 *       Has the masterbill been printed
 * 002 - @p_mbnumber, varchar(20), input, null;
 *       masterbill number
 * 003 - @p_billto, varchar(6), input, null;
 *       Billto selected
 * 004 - @p_revtype1, varchar(8), input, null;
 *       revtype 1 value
 * 005 - @p_mbstatus, int, output, null;
 *       status of masterbill ie XFR 
 * 006 - @p_shipstart, int, input, null;
 *       start date
 * 007 - @p_shipend, varchar(20), input, null;
 *       end date
 * 008 - @p_billdate, varchar(6), input, null;
 *       bill date
 * 009 - @p_copy, varchar(8), input, null;
 *       number of copies requested
 * 010 - @p_ivh_invoicenumber, varchar(12), input, null;
 *       invoiceheader invoice number (ie. Master)
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 **/


DECLARE @v_int0  		INT, 
        @v_gst_total 		MONEY, 
        @v_fuelsurcharge_total	MONEY, 
        @v_minord 		INT,
        @v_subtotal 		MONEY, 
        @fuelsurcharge_total 	MONEY, 
        @v_min_chrg_found 	INT, 
        @v_min_seq 		INT,
        @v_ref_number 		VARCHAR(40)

CREATE TABLE #masterbill_temp 
(		
	ord_number 		VARCHAR(12),
	ivh_invoicenumber 	VARCHAR(12),  
	ivh_hdrnumber 		INT NULL, 
	ivh_billto 		VARCHAR(8) NULL,
	ivh_shipper 		VARCHAR(8) NULL,
	ivh_consignee 		VARCHAR(8) NULL,
	ivh_totalcharge 	MONEY NULL,   
	ivh_originpoint  	VARCHAR(8) NULL,  
	ivh_destpoint 		VARCHAR(8) NULL,   
	ivh_origincity 		INT NULL,		   
	ivh_destcity 		INT NULL,   
	ivh_shipdate 		DATETIME NULL,   
	ivh_deliverydate 	DATETIME NULL,   
	ivh_revtype1 		VARCHAR(6) NULL,
	ivh_mbnumber 		INT NULL,
	ivh_billto_name 	VARCHAR(30)  NULL,
	ivh_billto_address 	VARCHAR(40) NULL,
	ivh_billto_address2 	VARCHAR(40) NULL,
	ivh_billto_address3	VARCHAR(40) NULL,
	ivh_billto_nmstct 	VARCHAR(25) NULL ,
	ivh_billto_zip 		VARCHAR(9) NULL,		
	ivh_ref_number 		VARCHAR(30) NULL,
	ivh_tractor 		VARCHAR(8) NULL,
	ivh_trailer 		VARCHAR(13) NULL,
	origin_nmstct 		VARCHAR(25) NULL,
	origin_state 		VARCHAR(2) NULL,
	dest_nmstct 		VARCHAR(25) NULL,
	dest_state 		VARCHAR(2) NULL,
	billdate 		DATETIME NULL,
	cmp_mailto_name 	VARCHAR(30)  NULL,
	bill_quantity 		FLOAT  NULL,		
	cmd_name 		VARCHAR(60)  NULL,
	copy 			INT NULL,
	ord_hdrnumber 		INT NULL,
        ivh_shipper_name 	VARCHAR(30) NULL,
	bill_rate 		MONEY NULL,
        bill_charge 		MONEY NULL,
        fsc_charge		MONEY NULL,
	gst_charge		MONEY NULL
)

SELECT  @v_int0 = 0

SELECT  @p_shipstart = CONVERT(CHAR(12),@p_shipstart)+'00:00:00'
SELECT  @p_shipend   = CONVERT(CHAR(12),@p_shipend  )+'23:59:59'

-- if printflag is set to REPRINT, retrieve an already printed mb by #
IF UPPER(@p_reprintflag) = 'REPRINT' 
BEGIN
   INSERT INTO #masterbill_temp
      SELECT IsNull(invoiceheader.ord_number, ''),
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
             ISNULL(cmp1.cmp_address3,''),
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
	     ISNULL(invoiceheader.ivh_ref_number,''),
	     invoiceheader.ivh_tractor,
	     invoiceheader.ivh_trailer,
	     cty1.cty_nmstct   origin_nmstct,
	     substring(cty1.cty_state,1,2) origin_state,
	     cty2.cty_nmstct dest_nmstct,
	     substring(cty2.cty_state,1,2) dest_state,
	     ivh_billdate billdate,
	     ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	     0,
	     ' ',
	     @p_copy,
     	     invoiceheader.ord_hdrnumber,
             cmp2.cmp_name,
             0,
             0,
             0,
             0    
        FROM invoiceheader LEFT OUTER JOIN city cty1 ON invoiceheader.ivh_origincity = cty1.cty_code
                           LEFT OUTER JOIN city cty2 ON invoiceheader.ivh_destcity = cty2.cty_code
             		   JOIN company cmp1 ON invoiceheader.ivh_billto = cmp1.cmp_id
             		   LEFT OUTER JOIN company cmp2 ON invoiceheader.ivh_shipper = cmp2.cmp_id
       WHERE invoiceheader.ivh_mbnumber = @p_mbnumber		
END

-- for master bills with 'RTP' status

IF UPPER(@p_reprintflag) <> 'REPRINT' 
BEGIN
   INSERT INTO #masterbill_temp
      SELECT ISNULL(invoiceheader.ord_number,''),
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
             @p_mbnumber ivh_mbnumber,
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
             ISNULL(cmp1.cmp_address3,''),
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
	     ISNULL(invoiceheader.ivh_ref_number,''),
	     invoiceheader.ivh_tractor,
	     invoiceheader.ivh_trailer,
             cty1.cty_nmstct   origin_nmstct,
             substring(cty1.cty_state,1,2) origin_state,
             cty2.cty_nmstct   dest_nmstct,
             substring(cty2.cty_state,1,2) dest_state,
             @p_billdate billdate,
	     ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,
	     0,
             ' ',
             @p_copy,
             invoiceheader.ord_hdrnumber,
             cmp2.cmp_name,
             0,
             0,
             0,
             0
        FROM invoiceheader LEFT OUTER JOIN city cty1 ON invoiceheader.ivh_origincity = cty1.cty_code
                           LEFT OUTER JOIN city cty2 ON invoiceheader.ivh_destcity = cty2.cty_code
                           JOIN company cmp1 ON invoiceheader.ivh_billto = cmp1.cmp_id
                           LEFT OUTER JOIN company cmp2 ON invoiceheader.ivh_shipper = cmp2.cmp_id
       WHERE invoiceheader.ivh_billto = @p_billto AND 
             invoiceheader.ivh_shipdate BETWEEN @p_shipstart AND @p_shipend AND 
             invoiceheader.ivh_mbstatus = 'RTP' AND 
             @p_revtype1 IN (invoiceheader.ivh_revtype1,'UNK') AND
             @p_shipper IN (invoiceheader.ivh_shipper,'UNKNOWN') AND
             @p_consignee IN (invoiceheader.ivh_consignee,'UNKNOWN')
END

UPDATE #masterbill_temp
   SET bill_quantity = ivd_quantity,
       bill_rate = ivd_rate,
       bill_charge = ivd_charge,
       cmd_name = ivd_description
  FROM invoicedetail JOIN #masterbill_temp ON invoicedetail.ivh_hdrnumber = #masterbill_temp.ivh_hdrnumber AND
                                              invoicedetail.ivd_type = 'SUB'
UPDATE #masterbill_temp
   SET fsc_charge = (SELECT SUM(ivd_charge)
                       FROM invoicedetail
                      WHERE #masterbill_temp.ivh_hdrnumber = invoicedetail.ivh_hdrnumber AND
                            invoicedetail.ivd_type = 'LI' AND
                            invoicedetail.cht_itemcode LIKE 'FSC%')

UPDATE #masterbill_temp
   SET gst_charge = ISNULL(ivd_charge, 0)
  FROM invoicedetail JOIN #masterbill_temp ON invoicedetail.ivh_hdrnumber = #masterbill_temp.ivh_hdrnumber AND
                                              invoicedetail.ivd_type = 'LI' AND
                                              invoicedetail.cht_itemcode = 'GST'

UPDATE #masterbill_temp
   SET cmd_name = ivd_description
  FROM invoicedetail JOIN #masterbill_temp ON invoicedetail.ivh_hdrnumber = #masterbill_temp.ivh_hdrnumber AND
                                              invoicedetail.ivd_type = 'DRP' AND
                                              invoicedetail.ivd_sequence = (SELECT MIN(ivd_sequence)
                                                                              FROM invoicedetail
                                                                             WHERE invoicedetail.ivh_hdrnumber = #masterbill_temp.ivh_hdrnumber AND
                                                                                   invoicedetail.ivd_type = 'DRP')

  
SELECT ord_number ,
       ivh_invoicenumber, 
       ivh_hdrnumber, 
       ivh_billto,
       ivh_shipper,
       ivh_consignee,
       ivh_totalcharge,   
       ivh_originpoint,  
       ivh_destpoint,   
       ivh_origincity ,		   
       ivh_destcity ,   
       ivh_shipdate ,   
       ivh_deliverydate ,   
       ivh_revtype1 ,
       ivh_mbnumber ,
       ivh_billto_name ,
       ivh_billto_address ,
       ivh_billto_address2 ,
       ivh_billto_address3,
       ivh_billto_nmstct ,
       ivh_billto_zip,		
       ivh_ref_number ,
       ivh_tractor ,
       ivh_trailer ,
       origin_nmstct ,
       origin_state ,
       dest_nmstct ,
       dest_state ,
       billdate,
       cmp_mailto_name ,
       bill_quantity ,		
       cmd_name,
       copy ,
       ord_hdrnumber ,
       ivh_shipper_name,
       bill_rate,
       bill_charge,
       fsc_charge,
       gst_charge
  FROM #masterbill_temp
  
DROP TABLE #masterbill_temp

GO
GRANT EXECUTE ON  [dbo].[d_masterbill121_sp] TO [public]
GO
