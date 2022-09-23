SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_masterbill_cargillcsv] (@p_reprintflag  VARCHAR(10),
                                              @p_mbnumber     INTEGER,
                                              @p_billto       VARCHAR(8),
                                              @p_shipstart    DATETIME,
                                              @p_shipend      DATETIME,
                                              @p_billdate     DATETIME)
AS
DECLARE @inv  INTEGER,
        @ord  INTEGER,
        @day  VARCHAR(2),
        @days INTEGER,
        @acc_desc VARCHAR(254)

CREATE TABLE #masterbill (
	pro_num				VARCHAR(12) NULL,
	ref_type			VARCHAR(6) NULL,
	ref_number			VARCHAR(30) NULL,
    ref_sequence		INTEGER NULL,
	load_date			DATETIME NULL,
	shipper				VARCHAR(100) NULL,
	shipper_city		VARCHAR(30) NULL,
	shipper_zip			VARCHAR(10) NULL,
	consignee			VARCHAR(100) NULL,
	consignee_city		VARCHAR(30) NULL,
	consignee_zip		VARCHAR(10) NULL,
	miles				INTEGER NULL,
	linehaul			MONEY NULL,
	other				MONEY NULL,
    description     	VARCHAR(254) NULL,
	fuelsurcharge		MONEY NULL,
	cua             	MONEY NULL,
    gst             	MONEY NULL,
    hst             	MONEY NULL,
    hst_rate        	MONEY NULL,
    weight				INTEGER NULL,
    tar_number      	INTEGER NULL,
	bill_date			DATETIME NULL,
	mbnumber			INTEGER NULL,
    ivh_hdrnumber   	INTEGER NULL,
    ivh_billto      	VARCHAR(8) NULL,
	billto_name     	VARCHAR(100) NULL,
    billto_terms		INTEGER NULL,
	billto_currency		VARCHAR(20) NULL,
    ord_hdrnumber		INTEGER NULL
)

IF UPPER(@p_reprintflag) = 'REPRINT' 
BEGIN
   INSERT INTO #masterbill
      SELECT i.ivh_invoicenumber,
             r.ref_type,
             r.ref_number,
             ISNULL(r.ref_sequence, 1),
             i.ivh_shipdate,
             cmp1.cmp_name,
             c1.cty_nmstct,
             cmp1.cmp_zip,
             cmp2.cmp_name,
             c2.cty_nmstct,
             cmp2.cmp_zip,
             i.ivh_totalmiles,
             i.ivh_charge,
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     ivd_type = 'LI' AND
					 cht_itemcode NOT IN (SELECT cht_itemcode
					                        FROM chargetype
										   WHERE cht_itemcode in ('CUA', 'GST', 'HST') OR 
										         cht_category1 = 'FUEL')),
             ' ',
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode IN (SELECT cht_itemcode
                                        FROM chargetype
                                       WHERE cht_category1 = 'FUEL')),
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode IN ('CUA')),
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode IN ('GST')),
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode = 'HST'),
             (SELECT ivd_rate
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode = 'HST'),
             i.ivh_totalweight,
             i.tar_number,
             @p_billdate,
             @p_mbnumber,
             i.ivh_hdrnumber,
             i.ivh_billto,
			 cmp3.cmp_name,
             0,
			 CASE cmp3.cmp_currency
                WHEN 'CA$' THEN 'CANADIAN'
                WHEN 'CAD' THEN 'CANADIAN'
                WHEN 'US$' THEN 'US'
                WHEN 'USD' THEN 'US'
                ELSE ' '
             END,
             i.ord_hdrnumber
        FROM invoiceheader i JOIN company cmp1 ON i.ivh_shipper = cmp1.cmp_id
                             JOIN city c1 ON cmp1.cmp_city = c1.cty_code
                             JOIN company cmp2 ON i.ivh_consignee = cmp2.cmp_id
                             JOIN city c2 ON cmp2.cmp_city = c2.cty_code
							 JOIN company cmp3 ON i.ivh_billto = cmp3.cmp_id 
                             LEFT OUTER JOIN referencenumber r ON i.ord_hdrnumber = r.ref_tablekey AND
                                  ref_table = 'orderheader'
       WHERE i.ivh_mbnumber = @p_mbnumber 
END

IF UPPER(@p_reprintflag) <> 'REPRINT'
BEGIN
   INSERT INTO #masterbill
      SELECT i.ivh_invoicenumber,
             r.ref_type,
             r.ref_number,
             ISNULL(r.ref_sequence, 1),
             i.ivh_shipdate,
             cmp1.cmp_name,
             c1.cty_nmstct,
             cmp1.cmp_zip,
             cmp2.cmp_name,
             c2.cty_nmstct,
             cmp2.cmp_zip,
             i.ivh_totalmiles,
             i.ivh_charge,
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     ivd_type = 'LI' AND
                    cht_itemcode NOT IN (SELECT cht_itemcode
					                        FROM chargetype
										   WHERE cht_itemcode in ('CUA', 'GST', 'HST') OR 
										         cht_category1 = 'FUEL')),
             ' ',
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode IN (SELECT cht_itemcode
                                        FROM chargetype
                                       WHERE cht_category1 = 'FUEL')),
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode IN ('CUA')),
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode IN ('GST')),
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode = 'HST'),
             (SELECT ivd_rate
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode = 'HST'),
             i.ivh_totalweight,
             i.tar_number,
             @p_billdate,
             @p_mbnumber,
             i.ivh_hdrnumber,
             i.ivh_billto,
			 cmp3.cmp_name,
             0,
			 CASE cmp3.cmp_currency
                WHEN 'CA$' THEN 'CANADIAN'
                WHEN 'CAD' THEN 'CANADIAN'
                WHEN 'US$' THEN 'US'
                WHEN 'USD' THEN 'US'
                ELSE ' '
             END,
             i.ord_hdrnumber
        FROM invoiceheader i JOIN company cmp1 ON i.ivh_shipper = cmp1.cmp_id
                             JOIN city c1 ON cmp1.cmp_city = c1.cty_code
                             JOIN company cmp2 ON i.ivh_consignee = cmp2.cmp_id
                             JOIN city c2 ON cmp2.cmp_city = c2.cty_code
							 JOIN company cmp3 ON i.ivh_billto = cmp3.cmp_id
                             LEFT OUTER JOIN referencenumber r ON i.ord_hdrnumber = r.ref_tablekey AND
                                  ref_table = 'orderheader'
       WHERE i.ivh_billto = @p_billto AND
             i.ivh_shipdate BETWEEN @p_shipstart AND @p_shipend AND
             i.ivh_mbstatus = 'RTP'
END

UPDATE #masterbill 
   SET linehaul = 0,
       other = 0,
       fuelsurcharge = 0,
       cua = 0,
       gst = 0,
       hst = 0
 WHERE ref_sequence > 1

SELECT @day = ISNULL(LEFT(cmp_terms,2), '0')
  FROM company
 WHERE cmp_id = @p_billto

IF ISNUMERIC(@day) = 1
BEGIN
   SET @days = CAST(@day AS INTEGER)
END
ELSE
BEGIN
   SET @days = 0
END

UPDATE #masterbill 
   SET billto_terms = @days

SET @inv = 0
WHILE 1=1
BEGIN
   SELECT @inv = MIN(ivh_hdrnumber)
     FROM #masterbill 
    WHERE ivh_hdrnumber > @inv

    IF @inv IS NULL
      BREAK

   SET @acc_desc = ''
   SELECT @acc_desc = @acc_desc + chargetype.cht_description + '@$' + CAST(invoicedetail.ivd_charge AS VARCHAR(10)) + ','
     FROM invoicedetail JOIN chargetype ON invoicedetail.cht_itemcode = chargetype.cht_itemcode
    WHERE invoicedetail.ivh_hdrnumber = @inv AND
          invoicedetail.ivd_type = 'LI' AND
          invoicedetail.cht_itemcode NOT IN (SELECT cht_itemcode
					                        FROM chargetype
										   WHERE cht_itemcode in ('CUA', 'GST', 'HST') OR 
										         cht_category1 = 'FUEL')
   
   IF LEN(@acc_desc) > 0 
   BEGIN
      SET @acc_desc = LEFT(@acc_desc, LEN(@acc_desc) - 1)
      UPDATE #masterbill
         SET description = @acc_desc
       WHERE ivh_hdrnumber = @inv
   END
END


SELECT ISNULL(pro_num, ' ') pro_num,
       ISNULL(ref_type, ' ') ref_type,
       ISNULL(ref_number, ' ') ref_number,
       ISNULL(ref_sequence, 0) ref_sequence,
       ISNULL(load_date, ' ') load_date,
       ISNULL(shipper, ' ') shipper,
       ISNULL(shipper_city, ' ') shipper_city,
       ISNULL(shipper_zip, ' ') shipper_zip,
       ISNULL(consignee, ' ') consignee,
       ISNULL(consignee_city, ' ') consignee_city,
       ISNULL(consignee_zip, ' ') consignee_zip,
       ISNULL(miles, 0) miles,
       ISNULL(linehaul, 0) linehaul,
       ISNULL(other, 0) other,
       ISNULL(description, ' ') description,
       ISNULL(fuelsurcharge, 0) fuelsurcharge,
       ISNULL(cua, 0) cua,
       ISNULL(gst, 0) gst,
       ISNULL(hst, 0) hst,
       ISNULL(hst_rate, 0) hst_rate,
       ISNULL(weight, 0) weight,
       ISNULL(tar_number, 0) tar_number,
       bill_date,
       mbnumber,
       ivh_hdrnumber,
       ivh_billto,
	   billto_name,
       ISNULL(billto_terms, 0) billto_terms,
	   ISNULL(billto_currency, ' ') billto_currency,
       ISNULL(ord_hdrnumber, 0) ord_hdrnumber
  FROM #masterbill
ORDER BY ivh_hdrnumber, ref_sequence

GO
GRANT EXECUTE ON  [dbo].[d_masterbill_cargillcsv] TO [public]
GO
