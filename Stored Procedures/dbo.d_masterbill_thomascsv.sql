SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_masterbill_thomascsv] (@p_reprintflag  VARCHAR(10),
                                             @p_mbnumber     INTEGER,
                                             @p_billto       VARCHAR(8),
                                             @p_shipstart    DATETIME,
                                             @p_shipend      DATETIME,
                                             @p_billdate     DATETIME)
AS
DECLARE @ref	     VARCHAR(100),
        @ord         INTEGER,
        @inv         INTEGER,
        @acc_desc    VARCHAR(200)

CREATE TABLE #masterbill (
        bl_num          VARCHAR(100) NULL,
        load_date		DATETIME NULL,
        pro_num			VARCHAR(12) NULL,
        consignee		VARCHAR(100) NULL,
        consignee_city  VARCHAR(30) NULL,
        consignee_state VARCHAR(6) NULL,
        shipper			VARCHAR(100) NULL,
        shipper_city	VARCHAR(30) NULL,
        shipper_state   VARCHAR(6) NULL,
        ivh_revtype3    VARCHAR(6) NULL,
        pieces          INTEGER NULL,
        weight          INTEGER NULL,
        delivery_date   DATETIME NULL,
        carrier         VARCHAR(8) NULL,
        linehaul		MONEY NULL,
        accessorials    MONEY NULL,
        acc_description VARCHAR(200) NULL,
        fuelsurcharge	MONEY NULL,
        gst             MONEY NULL,
        hst             MONEY NULL,
        hst_rate        MONEY NULL,
        bill_date		DATETIME NULL,
        mbnumber		INTEGER NULL,
        ivh_hdrnumber   INTEGER NULL,
        ord_hdrnumber   INTEGER NULL,
        ivh_billto      VARCHAR(8) NULL,
        billto_name		VARCHAR(100) NULL,
        billto_address  VARCHAR(100) NULL,
        billto_city     VARCHAR(100) NULL,
        billto_zip      VARCHAR(10) NULL,
		billto_currency VARCHAR(20) NULL
)

IF UPPER(@p_reprintflag) <> 'REPRINT'
BEGIN
   INSERT INTO #masterbill
      SELECT '',
             i.ivh_shipdate,
             i.ivh_invoicenumber,
             cmp2.cmp_name,
             c2.cty_name,
             c2.cty_state,
             cmp1.cmp_name,
             c1.cty_name, 
             c1.cty_state,
             i.ivh_revtype3,
             i.ivh_totalpieces,
             i.ivh_totalweight,
             i.ivh_deliverydate,
             i.ivh_carrier,
             i.ivh_charge,
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     ivd_type <> 'SUB' AND 
                     cht_itemcode NOT IN (SELECT cht_itemcode
					                        FROM chargetype
										   WHERE cht_itemcode in ('GST', 'HST') OR 
										         cht_category1 = 'FUEL')),
             '',
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode IN (SELECT cht_itemcode
                                        FROM chargetype
                                       WHERE cht_category1 = 'FUEL')),
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
             @p_billdate,
             @p_mbnumber,
             i.ivh_hdrnumber,
             i.ord_hdrnumber,
             i.ivh_billto,
             cmp3.cmp_name,
             cmp3.cmp_address1,
             c3.cty_nmstct,
             cmp3.cmp_zip,
			 CASE cmp3.cmp_currency
                WHEN 'CA$' THEN 'CANADIAN'
                WHEN 'CAD' THEN 'CANADIAN'
                WHEN 'US$' THEN 'US'
                WHEN 'USD' THEN 'US'
                ELSE ' '
             END
        FROM invoiceheader i JOIN company cmp1 ON i.ivh_shipper = cmp1.cmp_id
                             JOIN city c1 ON cmp1.cmp_city = c1.cty_code
                             JOIN company cmp2 ON i.ivh_consignee = cmp2.cmp_id
                             JOIN city c2 ON cmp2.cmp_city = c2.cty_code
                             JOIN company cmp3 ON i.ivh_billto = cmp3.cmp_id 
                             JOIN city c3 ON cmp3.cmp_city = c3.cty_code
       WHERE i.ivh_billto = @p_billto AND
             i.ivh_shipdate BETWEEN @p_shipstart AND @p_shipend AND
             i.ivh_mbstatus = 'RTP'
END

IF UPPER(@p_reprintflag) = 'REPRINT'
BEGIN
   INSERT INTO #masterbill
      SELECT '',
             i.ivh_shipdate,
             i.ivh_invoicenumber,
             cmp2.cmp_name,
             c2.cty_name,
             c2.cty_state,
             cmp1.cmp_name,
             c1.cty_name, 
             c1.cty_state,
             i.ivh_revtype3,
             i.ivh_totalpieces,
             i.ivh_totalweight,
             i.ivh_deliverydate,
             i.ivh_carrier,
             i.ivh_charge,
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     ivd_type <> 'SUB' AND 
                     cht_itemcode NOT IN (SELECT cht_itemcode
					                        FROM chargetype
										   WHERE cht_itemcode in ('GST', 'HST') OR 
										         cht_category1 = 'FUEL')),
             '',
             (SELECT ISNULL(SUM(ivd_charge), 0)
                FROM invoicedetail
               WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                     cht_itemcode IN (SELECT cht_itemcode
                                        FROM chargetype
                                       WHERE cht_category1 = 'FUEL')),
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
             @p_billdate,
             @p_mbnumber,
             i.ivh_hdrnumber,
             i.ord_hdrnumber,
             i.ivh_billto,
             cmp3.cmp_name,
             cmp3.cmp_address1,
             c3.cty_nmstct,
             cmp3.cmp_zip,
			 CASE cmp3.cmp_currency
                WHEN 'CA$' THEN 'CANADIAN'
                WHEN 'CAD' THEN 'CANADIAN'
                WHEN 'US$' THEN 'US'
                WHEN 'USD' THEN 'US'
                ELSE ' '
             END
        FROM invoiceheader i JOIN company cmp1 ON i.ivh_shipper = cmp1.cmp_id
                             JOIN city c1 ON cmp1.cmp_city = c1.cty_code
                             JOIN company cmp2 ON i.ivh_consignee = cmp2.cmp_id
                             JOIN city c2 ON cmp2.cmp_city = c2.cty_code
                             JOIN company cmp3 ON i.ivh_billto = cmp3.cmp_id 
                             JOIN city c3 ON cmp3.cmp_city = c3.cty_code
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

   SELECT @ref = @ref + ref_number + ' & '
     FROM referencenumber
    WHERE ref_table = 'orderheader' AND
          ord_hdrnumber = @ord AND
          ref_type = 'BL#'

   IF LEN(@ref) > 0
   BEGIN
      SET @ref = LTRIM(LEFT(@ref, LEN(@ref) - 2))
      UPDATE #masterbill
         SET bl_num = @ref
       WHERE ivh_hdrnumber = @inv
   END

   SET @acc_desc = ''
   SELECT @acc_desc = @acc_desc + chargetype.cht_description + '@$' + CAST(ivd_charge AS VARCHAR(10)) + ','
     FROM invoicedetail JOIN chargetype ON invoicedetail.cht_itemcode = chargetype.cht_itemcode
    WHERE invoicedetail.ivh_hdrnumber = @inv AND
          invoicedetail.ivd_type = 'LI' AND
          invoicedetail.cht_itemcode NOT IN (SELECT cht_itemcode
					                        FROM chargetype
										   WHERE cht_itemcode in ('GST', 'HST') OR 
										         cht_category1 = 'FUEL')

   IF LEN(@acc_desc) > 0 
   BEGIN
      SET @acc_desc = LEFT(@acc_desc, LEN(@acc_desc) - 1)
      UPDATE #masterbill
         SET acc_description = @acc_desc
       WHERE ivh_hdrnumber = @inv
   END
END

SELECT ISNULL(bl_num, ' ') bl_num,
       ISNULL(load_date, ' ') load_date,
       ISNULL(pro_num, ' ') pro_num,
       ISNULL(consignee, ' ') consignee,
       ISNULL(consignee_city, ' ') consignee_city,
       ISNULL(consignee_state, ' ') consignee_state,
       ISNULL(shipper, ' ') shipper,
       ISNULL(shipper_city, ' ') shipper_city,
       ISNULL(shipper_state, ' ') shipper_state,
       ISNULL(ivh_revtype3, ' ') ivh_revtype3,
       ISNULL(pieces, 0) pieces,
       ISNULL(weight, 0) weight,
       ISNULL(delivery_date, ' ') delivery_date,
       ISNULL(carrier, ' ') carrier,
       ISNULL(linehaul, 0) linehaul,
       ISNULL(accessorials, 0) accessorials,
       ISNULL(acc_description, ' ') acc_description,
       ISNULL(fuelsurcharge, 0) fuelsurcharge,
       ISNULL(gst, 0) gst,
       ISNULL(hst, 0) hst,
       ISNULL(hst_rate, 0) hst_rate,
       bill_date,
       mbnumber,
       ivh_hdrnumber,
       ord_hdrnumber,
       ivh_billto,
       ISNULL(billto_name, ' ') billto_name,
       ISNULL(billto_address, ' ') billto_address,
       ISNULL(billto_city, ' ') billto_city,
       ISNULL(billto_zip, ' ') billto_zip,
	   ISNULL(billto_currency, ' ') billto_currency
  FROM #masterbill

GO
GRANT EXECUTE ON  [dbo].[d_masterbill_thomascsv] TO [public]
GO
