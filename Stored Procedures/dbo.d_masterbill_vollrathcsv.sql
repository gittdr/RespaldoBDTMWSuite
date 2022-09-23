SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_masterbill_vollrathcsv] (@p_reprintflag  VARCHAR(10),
                                               @p_mbnumber     INTEGER,
                                               @p_billto       VARCHAR(8),
                                               @p_shipstart    DATETIME,
                                               @p_shipend      DATETIME,
                                               @p_billdate     DATETIME)
AS
DECLARE @inv   INTEGER,
        @ord   INTEGER,
        @ref   VARCHAR(254)

CREATE TABLE #masterbill (
	pro_num		    VARCHAR(12) NULL,
	bol_num		    VARCHAR(254) NULL,
	load_date	    DATETIME NULL,
	shipper		    VARCHAR(100) NULL,
	shipper_city	VARCHAR(30) NULL,
	consignee	    VARCHAR(100) NULL,
	consignee_city	VARCHAR(30) NULL,
	linehaul	    MONEY NULL,
    fuelsurcharge	MONEY NULL,
	beyond_amt	    MONEY NULL,
    extras		    MONEY NULL,
	gst             MONEY NULL,
    hst             MONEY NULL,
    hst_rate        MONEY NULL,
    weight          INTEGER NULL,
	bill_date	    DATETIME NULL,
	mbnumber	    INTEGER NULL,
    ivh_hdrnumber   INTEGER NULL,
    ivh_billto      VARCHAR(8) NULL,
	billto_name     VARCHAR(100) NULL,
	billto_currency	VARCHAR(20) NULL,
    ord_hdrnumber	INTEGER NULL
)

IF UPPER(@p_reprintflag) <> 'REPRINT'
BEGIN
   INSERT INTO #masterbill
      SELECT i.ivh_invoicenumber,
             ' ',
             i.ivh_shipdate,
             cmp1.cmp_name,
             c1.cty_nmstct,
             cmp2.cmp_name,
             c2.cty_nmstct,
             i.ivh_charge,
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode IN (SELECT cht_itemcode
                                        FROM chargetype
                                       WHERE cht_category1 = 'FUEL')),
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode IN ('BEYND')),
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     ivd_type <> 'SUB' AND
                     cht_itemcode NOT IN (SELECT cht_itemcode
					                        FROM chargetype
										   WHERE cht_itemcode in ('GST', 'HST', 'BEYND') OR 
										         cht_category1 = 'FUEL')),
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
             @p_billdate,
             @p_mbnumber,
             i.ivh_hdrnumber,
             i.ivh_billto,
			 cmp3.cmp_name,
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
       WHERE i.ivh_billto = @p_billto AND
             i.ivh_shipdate BETWEEN @p_shipstart AND @p_shipend AND
             i.ivh_mbstatus = 'RTP'
END

IF UPPER(@p_reprintflag) = 'REPRINT'
BEGIN
   INSERT INTO #masterbill
      SELECT i.ivh_invoicenumber,
             ' ',
             i.ivh_shipdate,
             cmp1.cmp_name,
             c1.cty_nmstct,
             cmp2.cmp_name,
             c2.cty_nmstct,
             i.ivh_charge,
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode IN (SELECT cht_itemcode
                                        FROM chargetype
                                       WHERE cht_category1 = 'FUEL')),
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode IN ('BEYND')),
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     ivd_type <> 'SUB' AND
                     cht_itemcode NOT IN (SELECT cht_itemcode
					                        FROM chargetype
										   WHERE cht_itemcode in ('GST', 'HST', 'BEYND') OR 
										         cht_category1 = 'FUEL')),
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
             @p_billdate,
             @p_mbnumber,
             i.ivh_hdrnumber,
             i.ivh_billto,
			 cmp3.cmp_name,
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
       WHERE i.ivh_mbnumber = @p_mbnumber
END

SET @inv = 0
WHILE 1=1
BEGIN
   SELECT @inv = MIN(ivh_hdrnumber)
     FROM #masterbill 
    WHERE ivh_hdrnumber > @inv

   IF @inv IS NULL
      BREAK

   SET @ref = ''
   SELECT @ord = ord_hdrnumber 
     FROM #masterbill
    WHERE ivh_hdrnumber = @inv

   SELECT @ref = @ref + ref_number + ';'
     FROM referencenumber
    WHERE ref_table = 'orderheader' AND
          ord_hdrnumber = @ord AND
          ref_type = 'BL#'

   IF LEN(@ref) > 0
   BEGIN
      SET @ref = LTRIM(LEFT(@ref, LEN(@ref) - 2))
      UPDATE #masterbill
         SET bol_num = @ref
       WHERE ivh_hdrnumber = @inv
   END
END

SELECT ISNULL(pro_num, ' ') pro_num,
       ISNULL(bol_num, ' ') bol_num,
       ISNULL(load_date, ' ') load_date,
       ISNULL(shipper, ' ') shipper,
       ISNULL(shipper_city, ' ') shipper_city,
       ISNULL(consignee, ' ') consignee,
       ISNULL(consignee_city, ' ') consignee_city,
       ISNULL(linehaul, 0) linehaul,
       ISNULL(fuelsurcharge, 0) fuelsurcharge,
       ISNULL(beyond_amt, 0) beyond_amt,
       ISNULL(extras, 0) extras,
       ISNULL(gst, 0) gst,
       ISNULL(hst, 0) hst,
       ISNULL(hst_rate, 0) hst_rate,
       ISNULL(weight, 0) weight,
       bill_date,
       mbnumber,
       ivh_hdrnumber,
       ivh_billto,
	   billto_name,
	   billto_currency,
	   ord_hdrnumber
  FROM #masterbill

GO
GRANT EXECUTE ON  [dbo].[d_masterbill_vollrathcsv] TO [public]
GO
