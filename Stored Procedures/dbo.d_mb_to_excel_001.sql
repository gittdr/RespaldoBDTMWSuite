SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_mb_to_excel_001] @ivh_mbnumber    INTEGER
AS
DECLARE @minhdr		INTEGER,
	@discrepancy	VARCHAR(254)

CREATE TABLE #temp (
        ivh_hdrnumber		INTEGER NULL,
        sequence		INTEGER NULL,
        ord_hdrnumber		INTEGER NULL,
	import_export_repo 	VARCHAR(25) NULL,
	ivh_revtype1		VARCHAR(6) NULL,
	ivh_revtype1_desc	VARCHAR(30) NULL,
        statement_number	VARCHAR(15) NULL,
	trip_number		VARCHAR(12) NULL,
	delivery_order_date	DATETIME NULL,
	container_number	VARCHAR(13) NULL,
	chassis_number		VARCHAR(13) NULL,
	ivh_revtype3		VARCHAR(6) NULL,
	extra_info14		VARCHAR(30) NULL,
	extra_info15		VARCHAR(30) NULL,
	booking_number		VARCHAR(30) NULL,
	shipper			VARCHAR(35) NULL,
	destination		VARCHAR(35) NULL,
	rate			MONEY NULL,
	fsc			MONEY NULL,
	prepull			MONEY NULL,
	dry_run			MONEY NULL,
	bal_due			MONEY NULL,
	xtra_dray_or_drop	MONEY NULL,
	out_of_route		MONEY NULL,
	hazmat			MONEY NULL,
	detention		MONEY NULL,
	new_england		MONEY NULL,
	reefer			MONEY NULL,
	overweight		MONEY NULL,
	layover			MONEY NULL,
	cleaning_food_grade	MONEY NULL,
	kth_hc			MONEY NULL,
	scale_ticket		MONEY NULL,
	tri_axle		MONEY NULL,
	additional_comments	MONEY NULL,
	total			CHAR(1) NULL,
        paid			CHAR(1) NULL,
	discrepancy		VARCHAR(254) NULL,
        vessel			CHAR(1) NULL,
        port			CHAR(1) NULL,
	service			CHAR(1) NULL
)

CREATE TABLE #detail_desc (
	ivh_hdrnumber		INTEGER NULL,
        ivd_description		VARCHAR(30) NULL,
        cht_description		VARCHAR(30) NULL
        
)

CREATE TABLE #detail_desc_headers (
	ivh_hdrnumber		INTEGER NULL
)

INSERT INTO #temp (ivh_hdrnumber, sequence, ord_hdrnumber, import_export_repo,
                   ivh_revtype1, ivh_revtype1_desc, trip_number,
                   delivery_order_date, container_number, chassis_number,
                   ivh_revtype3, extra_info14, extra_info15, shipper,
                   destination, rate, fsc, prepull, dry_run, xtra_dray_or_drop, 
                   out_of_route, hazmat, detention, new_england, reefer, overweight, 
                   layover, cleaning_food_grade, kth_hc, scale_ticket, tri_axle,
                   additional_comments)
   SELECT invoiceheader.ivh_hdrnumber,
          1,
          invoiceheader.ord_hdrnumber,
          ISNULL((SELECT col_data
                    FROM extra_info_data
                   WHERE col_id = 65 AND
                         table_key = invoiceheader.ord_hdrnumber), ' '),
          invoiceheader.ivh_revtype1,
          UPPER(labelfile.name),
          invoiceheader.ivh_invoicenumber,
          invoiceheader.ivh_deliverydate,
          CASE invoiceheader.ivh_trailer
             WHEN 'UNKNOWN' THEN ' '
             ELSE SUBSTRING(invoiceheader.ivh_trailer, 1, 12)
          END,
          (SELECT SUBSTRING(lgh_primary_pup, 1, 12)
             FROM legheader
            WHERE lgh_number = (SELECT MIN(lgh_number)
                                  FROM stops
                                 WHERE stops.ord_hdrnumber = invoiceheader.ord_hdrnumber)),
          invoiceheader.ivh_revtype3,
          ISNULL((SELECT col_data
                    FROM extra_info_data
                   WHERE col_id = 53 AND
                         table_key = invoiceheader.ord_hdrnumber), ' '),
          ISNULL((SELECT col_data
                    FROM extra_info_data
                   WHERE col_id = 54 AND
                         table_key = invoiceheader.ord_hdrnumber), ' '),
          RTRIM(UPPER(city1.cty_name)) + ', ' + UPPER(ivh_originstate),
          RTRIM(UPPER(city2.cty_name)) + ', ' + UPPER(ivh_deststate),
         (SELECT SUM(ISNULL(ivd_charge, 0)) 
            FROM invoicedetail JOIN chargetype ON invoicedetail.cht_itemcode = chargetype.cht_itemcode AND
                                                  chargetype.cht_primary = 'Y'
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode IN ('RTFSC', 'FUELSC', 'FSCFL')),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'MSCPP'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'DRYRUN'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'DRAYCH'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'OUTROU'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'HAZMAT'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'DET'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'NEWENG'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'REEFER'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'OVERWT'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'LAYOVR'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'CLENFD'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'KTHHC'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'SCALE'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail 
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.cht_itemcode = 'TRIAX'),
         (SELECT SUM(ISNULL(ivd_charge, 0))
            FROM invoicedetail
           WHERE invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber AND
                 invoicedetail.ivd_type = 'LI' AND
                 invoicedetail.cht_itemcode NOT IN ('RTFSC', 'FUELSC', 'FSCFL', 'MSCPP', 'DRYRUN',
                                                    'DRAYCH', 'OUTROU', 'HAZMAT', 'DET', 'NEWENG',
                                                    'REEFER', 'OVERWT', 'LAYOVR', 'CLENFD', 'KTHHC',
                                                    'SCALE', 'TRIAX'))
  FROM invoiceheader JOIN labelfile ON invoiceheader.ivh_revtype1 = labelfile.abbr AND
                                       labelfile.labeldefinition = 'RevType1'
                     JOIN orderheader ON invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
                     JOIN city city1 ON invoiceheader.ivh_origincity = city1.cty_code
                     JOIN city city2 ON invoiceheader.ivh_destcity = city2.cty_code
 WHERE ivh_mbnumber = @ivh_mbnumber

UPDATE #temp
   SET ivh_revtype1_desc = 'NEW YORK'
 WHERE ivh_revtype1 = 'SKE'

UPDATE #temp
   SET statement_number = 'CKKI' + UPPER(import_export_repo)

UPDATE #temp
   SET chassis_number = ' '
 WHERE chassis_number = 'UNKNOWN'

UPDATE #temp
   SET container_number = LEFT(container_number, (CHARINDEX(',', container_number) - 1)) + 
                          RIGHT(container_number, (LEN(container_number) - CHARINDEX(',', container_number)))
 WHERE CHARINDEX(',', container_number) > 0

UPDATE #temp
   SET chassis_number = LEFT(chassis_number, (CHARINDEX(',', chassis_number) - 1)) + 
                        RIGHT(chassis_number, (LEN(chassis_number) - CHARINDEX(',', chassis_number)))
 WHERE CHARINDEX(',', chassis_number) > 0

UPDATE #temp
   SET chassis_number = container_number
 WHERE ivh_revtype3 = 'CH'

UPDATE #temp
   SET booking_number = CASE extra_info14
                           WHEN ' ' THEN extra_info15
                           ELSE extra_info14
                        END
 WHERE import_export_repo IN ('export', 'repo')

UPDATE #temp
   SET booking_number = CASE extra_info15
                           WHEN ' ' THEN extra_info14
                           ELSE extra_info15
                        END
 WHERE import_export_repo = 'import'

INSERT INTO #detail_desc (ivh_hdrnumber, ivd_description, cht_description)
   SELECT invoicedetail.ivh_hdrnumber,
          invoicedetail.ivd_description,
          chargetype.cht_description
     FROM invoicedetail JOIN chargetype ON invoicedetail.cht_itemcode = chargetype.cht_itemcode
    WHERE invoicedetail.ivh_hdrnumber IN (SELECT ivh_hdrnumber
                                            FROM invoiceheader
                                           WHERE ivh_mbnumber = @ivh_mbnumber) AND
          invoicedetail.ivd_type = 'LI' AND
          invoicedetail.cht_itemcode NOT IN ('RTFSC', 'FUELSC', 'FSCFL', 'MSCPP', 'DRYRUN',
                                             'DRAYCH', 'OUTROU', 'HAZMAT', 'DET', 'NEWENG',
                                             'REEFER', 'OVERWT', 'LAYOVR', 'CLENFD', 'KTHHC',
                                             'SCALE', 'TRIAX')

UPDATE #detail_desc
   SET cht_description = ivd_description
 WHERE ivd_description <> 'UNKNOWN'

INSERT INTO #detail_desc_headers
   SELECT DISTINCT ivh_hdrnumber
     FROM #detail_desc

SET @minhdr = 0
WHILE 1=1
BEGIN
   SELECT @minhdr = MIN(ivh_hdrnumber) 
     FROM #detail_desc_headers
    WHERE ivh_hdrnumber > @minhdr
            
   IF @minhdr IS NULL
      BREAK

   SET @discrepancy = ''

   SELECT @discrepancy = @discrepancy + RTRIM(cht_description) + ';'
     FROM #detail_desc
    WHERE ivh_hdrnumber = @minhdr

   SET @discrepancy = SUBSTRING(@discrepancy, 1, LEN(@discrepancy) - 1)

   UPDATE #temp
      SET discrepancy = @discrepancy
    WHERE #temp.ivh_hdrnumber = @minhdr
END

--Check for any rows with a detention amount.  If there
--create a second row for the invoiceheader with a sequence of 2
INSERT INTO #temp (ivh_hdrnumber, sequence, ord_hdrnumber, import_export_repo,
                   ivh_revtype1_desc, statement_number, trip_number,
                   delivery_order_date, container_number, chassis_number,
                   booking_number, shipper, destination, detention)
   SELECT ivh_hdrnumber,
          2,
          ord_hdrnumber,
          import_export_repo,
          ivh_revtype1_desc,
          statement_number,
          RTRIM(trip_number) + 'A', 
          delivery_order_date,
          container_number,
          chassis_number,
          booking_number,
          shipper,
          destination,
          detention
     FROM #temp
    WHERE detention > 0


SELECT ivh_hdrnumber,
       sequence, 
       ord_hdrnumber,
       UPPER(import_export_repo),
       UPPER(ivh_revtype1_desc),
       statement_number, 
       trip_number,
       delivery_order_date, 
       container_number, 
       chassis_number,
       UPPER(booking_number),
       shipper,
       destination, 
       rate,
       fsc, 
       prepull, 
       dry_run, 
       bal_due,
       xtra_dray_or_drop, 
       out_of_route, 
       hazmat, 
       detention,
       new_england, 
       reefer,
       overweight, 
       layover, 
       cleaning_food_grade, 
       kth_hc, 
       scale_ticket, 
       tri_axle,
       additional_comments, 
       total,
       paid, 
       UPPER(discrepancy), 
       vessel,
       port, 
       service
  FROM #temp
ORDER BY ivh_hdrnumber, sequence


GO
GRANT EXECUTE ON  [dbo].[d_mb_to_excel_001] TO [public]
GO
