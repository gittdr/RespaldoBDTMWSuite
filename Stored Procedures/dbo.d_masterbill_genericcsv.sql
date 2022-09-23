SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_masterbill_genericcsv] (@p_reprintflag  VARCHAR(10),
                                              @p_mbnumber     INTEGER,
                                              @p_billto       VARCHAR(8),
                                              @p_shipstart    DATETIME,
                                              @p_shipend      DATETIME,
                                              @p_billdate     DATETIME)
AS
DECLARE @ref	     	VARCHAR(100),
        @ord         	INTEGER,
        @inv         	INTEGER,
        @day         	VARCHAR(2),
        @days        	INTEGER,
        @acc_desc    	VARCHAR(200)

CREATE TABLE #masterbill (
   ivh_invoicenumber	VARCHAR(12) NULL,
   ivh_billdate			DATETIME NULL,
   ord_number			VARCHAR(12) NULL,
   mov_number			INTEGER NULL,
   ivh_shipdate         DATETIME NULL,
   ivh_deliverydate     DATETIME NULL,
   appt_date			DATETIME NULL,
   po_number			VARCHAR(100) NULL,
   bol_number           VARCHAR(100) NULL,
   cmd_code				VARCHAR(8) NULL,
   cmd_name				VARCHAR(60) NULL,
   shipper_city			VARCHAR(30) NULL,
   shipper_state		VARCHAR(6) NULL,
   shipper_code			VARCHAR(8) NULL,
   shipper_name			VARCHAR(100) NULL,
   shipper_address		VARCHAR(100) NULL,
   shipper_zip			VARCHAR(10) NULL,
   consignee_city		VARCHAR(30) NULL,
   consignee_state		VARCHAR(6) NULL,
   consignee_code		VARCHAR(8) NULL,
   consignee_name		VARCHAR(100) NULL,
   consignee_address	VARCHAR(100) NULL, 
   consignee_zip		VARCHAR(10) NULL,
   ivh_revtype3			VARCHAR(6) NULL,
   ivh_totalmiles		INTEGER NULL,
   ivh_totalweight		INTEGER NULL,
   ivh_totalpieces		INTEGER NULL,
   skids				INTEGER NULL,
   length				MONEY NULL,
   width				MONEY NULL,
   height				MONEY NULL,
   fbm					INTEGER NULL,
   linehaul				MONEY NULL,
   fuelsurcharge		MONEY NULL,
   accessorial			MONEY NULL,
   acc_description		VARCHAR(200),
   gst					MONEY NULL,
   hst					MONEY NULL,
   qst					MONEY NULL,
   ivh_totalcharge		MONEY NULL,
   tar_number			INTEGER NULL,
   bill_date			DATETIME NULL,
   mbnumber				INTEGER NULL,
   ivh_hdrnumber		INTEGER NULL,
   ord_hdrnumber		INTEGER NULL,
   ivh_billto			VARCHAR(8) NULL,
   billto_name			VARCHAR(100) NULL,
   billto_address		VARCHAR(100) NULL,
   billto_city			VARCHAR(100) NULL,
   billto_zip			VARCHAR(10) NULL,
   billto_terms			INTEGER NULL,
   billto_currency		VARCHAR(20) NULL
)

IF UPPER(@p_reprintflag) <> 'REPRINT'
BEGIN
   INSERT INTO #masterbill
      SELECT i.ivh_invoicenumber,
             i.ivh_billdate,
             o.ord_number,
             i.mov_number,
             i.ivh_shipdate,
             i.ivh_deliverydate, 
            (SELECT MAX(stp_schdtlatest)
	           FROM stops 
	          WHERE stops.ord_hdrnumber = i.ord_hdrnumber AND 
	                stops.stp_type = 'DRP' AND
			        stops.stp_appointmentstatus = 'SCH'),
            (SELECT MIN(ref_number)
               FROM referencenumber 
              WHERE ref_table = 'orderheader' AND
                    ref_tablekey = i.ord_hdrnumber AND
                    ref_type = 'PO#'),
            (SELECT MIN(ref_number)
               FROM referencenumber 
              WHERE ref_table = 'orderheader' AND
                    ref_tablekey = i.ord_hdrnumber AND
                    ref_type = 'BL#'),
             o.cmd_code,
             cmd.cmd_name,
             c1.cty_name,
             c1.cty_state,
             cmp1.cmp_id, 
             cmp1.cmp_name,
             cmp1.cmp_address1,
             cmp1.cmp_zip,
             c2.cty_name,
             c2.cty_state,
             cmp2.cmp_id,
             cmp2.cmp_name,
             cmp2.cmp_address1,
             cmp2.cmp_zip,
             i.ivh_revtype3,
             i.ivh_totalmiles,
             i.ivh_totalweight,
             i.ivh_totalpieces,
             0,
             o.ord_length, 
             o.ord_width, 
             o.ord_height,
             0,
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
                    ivd_type = 'LI' AND 
                    cht_itemcode NOT IN (SELECT cht_itemcode
					                        FROM chargetype
										   WHERE cht_itemcode in ('CUA', 'GST', 'HST') OR 
										         cht_category1 = 'FUEL')),
             ' ',
            (SELECT ISNULL(SUM(ivd_charge), 0)
               FROM invoicedetail
              WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                    cht_itemcode IN ('GST')),
            (SELECT ISNULL(SUM(ivd_charge), 0)
               FROM invoicedetail
              WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                    cht_itemcode IN ('HST')),
            (SELECT ISNULL(SUM(ivd_charge), 0)
               FROM invoicedetail
              WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                    cht_itemcode IN ('QST')),
             i.ivh_totalcharge,
             i.tar_number,
             @p_billdate,
             @p_mbnumber,
             i.ivh_hdrnumber,
             i.ord_hdrnumber,
             i.ivh_billto,
             cmp3.cmp_name,
             cmp3.cmp_address1,
             c3.cty_nmstct,
             cmp3.cmp_zip,
             0,
             CASE cmp3.cmp_currency
                WHEN 'CA$' THEN 'CANADIAN'
                WHEN 'CAD' THEN 'CANADIAN'
                WHEN 'US$' THEN 'US'
                WHEN 'USD' THEN 'US'
                ELSE ' '
             END
        FROM invoiceheader i JOIN orderheader o ON i.ord_hdrnumber = o.ord_hdrnumber
                             JOIN commodity cmd ON o.cmd_code = cmd.cmd_code
                             JOIN company cmp1 ON i.ivh_shipper = cmp1.cmp_id
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
      SELECT i.ivh_invoicenumber,
             i.ivh_billdate,
             o.ord_number,
             i.mov_number,
             i.ivh_shipdate,
             i.ivh_deliverydate, 
            (SELECT MAX(stp_schdtlatest)
	           FROM stops 
	          WHERE stops.ord_hdrnumber = i.ord_hdrnumber AND 
	                stops.stp_type = 'DRP' AND
			        stops.stp_appointmentstatus = 'SCH'),
            (SELECT MIN(ref_number)
               FROM referencenumber 
              WHERE ref_table = 'orderheader' AND
                    ref_tablekey = i.ord_hdrnumber AND
                    ref_type = 'PO#'),
            (SELECT MIN(ref_number)
               FROM referencenumber 
              WHERE ref_table = 'orderheader' AND
                    ref_tablekey = i.ord_hdrnumber AND
                    ref_type = 'BL#'),
             o.cmd_code,
             cmd.cmd_name,
             c1.cty_name,
             c1.cty_state,
             cmp1.cmp_id, 
             cmp1.cmp_name,
             cmp1.cmp_address1,
             cmp1.cmp_zip,
             c2.cty_name,
             c2.cty_state,
             cmp2.cmp_id,
             cmp2.cmp_name,
             cmp2.cmp_address1,
             cmp2.cmp_zip,
             i.ivh_revtype3,
             i.ivh_totalmiles,
             i.ivh_totalweight,
             i.ivh_totalpieces,
             0,
             o.ord_length, 
             o.ord_width, 
             o.ord_height,
             0,
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
                    ivd_type = 'LI' AND 
                    cht_itemcode NOT IN (SELECT cht_itemcode
					                        FROM chargetype
										   WHERE cht_itemcode in ('CUA', 'GST', 'HST') OR 
										         cht_category1 = 'FUEL')),
             ' ',
            (SELECT ISNULL(SUM(ivd_charge), 0)
               FROM invoicedetail
              WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                    cht_itemcode IN ('GST')),
            (SELECT ISNULL(SUM(ivd_charge), 0)
               FROM invoicedetail
              WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                    cht_itemcode IN ('HST')),
            (SELECT ISNULL(SUM(ivd_charge), 0)
               FROM invoicedetail
              WHERE invoicedetail.ivh_hdrnumber = i.ivh_hdrnumber AND
                    cht_itemcode IN ('QST')),
             i.ivh_totalcharge,
             i.tar_number,
             @p_billdate,
             @p_mbnumber,
             i.ivh_hdrnumber,
             i.ord_hdrnumber,
             i.ivh_billto,
             cmp3.cmp_name,
             cmp3.cmp_address1,
             c3.cty_nmstct,
             cmp3.cmp_zip,
             0,
             CASE cmp3.cmp_currency
                WHEN 'CA$' THEN 'CANADIAN'
                WHEN 'CAD' THEN 'CANADIAN'
                WHEN 'US$' THEN 'US'
                WHEN 'USD' THEN 'US'
                ELSE ' '
             END
        FROM invoiceheader i JOIN orderheader o ON i.ord_hdrnumber = o.ord_hdrnumber
                             JOIN commodity cmd ON o.cmd_code = cmd.cmd_code
                             JOIN company cmp1 ON i.ivh_shipper = cmp1.cmp_id
                             JOIN city c1 ON cmp1.cmp_city = c1.cty_code
                             JOIN company cmp2 ON i.ivh_consignee = cmp2.cmp_id
                             JOIN city c2 ON cmp2.cmp_city = c2.cty_code
                             JOIN company cmp3 ON i.ivh_billto = cmp3.cmp_id 
                             JOIN city c3 ON cmp3.cmp_city = c3.cty_code
       WHERE i.ivh_mbnumber = @p_mbnumber
END

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
   SELECT @acc_desc = @acc_desc + chargetype.cht_description + '@$' + CAST(ivd_charge AS VARCHAR(10)) + ','
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
         SET acc_description = @acc_desc
       WHERE ivh_hdrnumber = @inv
   END
END

SELECT ISNULL(ivh_invoicenumber, ' ') ivh_invoicenumber,
       ISNULL(ivh_billdate, ' ') ivh_billdate,
       ISNULL(ord_number, ' ') ord_number,
       ISNULL(mov_number, 0) mov_number,
       ISNULL(ivh_shipdate, ' ') ivh_shipdate,
       ISNULL(ivh_deliverydate, ' ') ivh_deliverydate,
       ISNULL(appt_date, ' ') appt_date,
       ISNULL(po_number, ' ') po_number,
       ISNULL(bol_number, ' ') bol_number,
       ISNULL(cmd_code, ' ') cmd_code,
       ISNULL(cmd_name, ' ') cmd_name,
       ISNULL(shipper_city, ' ') shipper_city,
       ISNULL(shipper_state, ' ') shipper_state,
       ISNULL(shipper_code, ' ') shipper_code,
       ISNULL(shipper_name, ' ') shipper_name,
       ISNULL(shipper_address, ' ') shipper_address,
       ISNULL(shipper_zip, ' ') shipper_zip,
       ISNULL(consignee_city, ' ') consignee_city,
       ISNULL(consignee_state, ' ') consignee_state,
       ISNULL(consignee_code, ' ') consignee_code,
       ISNULL(consignee_name, ' ') consignee_name,
       ISNULL(consignee_address, ' ') consignee_address,
       ISNULL(consignee_zip, ' ') consignee_zip,
       ISNULL(ivh_revtype3, ' ') ivh_revtype3,
       ISNULL(ivh_totalmiles, 0) ivh_totalmiles,
       ISNULL(ivh_totalweight, 0) ivh_totalweight,
       ISNULL(ivh_totalpieces, 0) ivh_totalpieces,
       ISNULL(skids, 0) skids,
       ISNULL(length, 0) length,
       ISNULL(width, 0) width,
       ISNULL(height, 0) height,
       ISNULL(fbm, 0) fbm,
       ISNULL(linehaul, 0) linehaul,
       ISNULL(fuelsurcharge, 0) fuelsurcharge,
       ISNULL(accessorial, 0) accessorial,
       ISNULL(acc_description, ' ') acc_description,
       ISNULL(gst, 0) gst,
       ISNULL(hst, 0) hst,
       ISNULL(qst, 0) qst,
       ISNULL(ivh_totalcharge, 0) ivh_totalcharge,
       ISNULL(tar_number, 0) tar_number,
       ISNULL(bill_date, ' ') bill_date,
       ISNULL(mbnumber, 0) mbnumber,
       ISNULL(ivh_hdrnumber, 0) ivh_hdrnumber,
       ISNULL(ord_hdrnumber, 0) ord_hdrnumber,
       ISNULL(ivh_billto, ' ') ivh_billto,
       ISNULL(billto_name, ' ') billto_name,
       ISNULL(billto_address, ' ') billto_address,
       ISNULL(billto_city, ' ') billto_city,
       ISNULL(billto_zip, ' ') billto_zip,
       ISNULL(billto_terms, 0) billto_terms,
       ISNULL(billto_currency, ' ') billto_currency
  FROM #masterbill

GO
GRANT EXECUTE ON  [dbo].[d_masterbill_genericcsv] TO [public]
GO
