SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pod_format03] (@lgh		INTEGER,
                               @ord_hdrnumber 	INTEGER,
                               @stp_number	INTEGER,
			       @sequence	INTEGER) 
AS
DECLARE @temp_name   		VARCHAR(30) ,  
        @temp_addr   		VARCHAR(30) ,  
        @temp_addr2  		VARCHAR(30),  
        @temp_nmstct		VARCHAR(30),  
        @temp_altid  		VARCHAR(25),  
        @counter    		INTEGER,  
        @ret_value  		INTEGER,  
        @temp_terms    		VARCHAR(20),  
        @varchar50 		VARCHAR(50),
        @ls_rateby 		CHAR(1),
        @taxable_charges	MONEY,
        @gst_taxrate		DECIMAL(7,4),
	@gst_tax		MONEY,
	@gst_desc		VARCHAR(30),
	@stp_count		INTEGER,
        @stp_gsttax		MONEY,
	@cht_itemcode		VARCHAR(6),
        @cht_charge		MONEY,
	@minchgid		INTEGER,
	@stp_charge		MONEY,
	@tax_charge		MONEY,
	@pod_note		VARCHAR(254),
	@ord_string		VARCHAR(20),
	@gst_taxstring		VARCHAR(6),
	@stp_sequence_max	INTEGER,
	@taxable_accessorials	MONEY,
	@taxable_total		MONEY,
	@tax_total		MONEY,
	@tax_perstop		MONEY,
	@ord_pieces		MONEY,
	@ord_weight		MONEY,
	@ord_quantity		MONEY,
	@stp_pieces		MONEY,
	@stp_weight		MONEY,
	@stp_quantity		MONEY,
	@ord_terms		VARCHAR(6),
	@podshowchargeterms	VARCHAR(20),
	@show_charges		SMALLINT,
	@ord_billto		VARCHAR(8),
	@show_tax		CHAR(1)
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
SELECT @ret_value = 1

/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET  */
CREATE TABLE #temp
(
	sort_sequence 		INTEGER IDENTITY NOT NULL,
	ord_number 		VARCHAR(20) NULL,
	ord_billto 		VARCHAR(8) NULL,
	billto_name 		VARCHAR(100) NULL,  
	billto_addr 		VARCHAR(100)  NULL,  
	billto_addr2 		VARCHAR(100) NULL,           
	billto_nmstct 		VARCHAR(30) NULL,  
	ord_shipper  		VARCHAR(8) NULL,     
	shipper_name 		VARCHAR(100) NULL,  
	shipper_addr 		VARCHAR(100) NULL,  
	shipper_addr2 		VARCHAR(100) NULL,  
	shipper_nmstct 		VARCHAR(30) NULL,  
	ord_consignee 		VARCHAR(8) NULL,     
	consignee_name 		VARCHAR(100) NULL,  
	consignee_addr 		VARCHAR(100) NULL,  
	consignee_addr2 	VARCHAR(100) NULL,  
	consignee_nmstct 	VARCHAR(30) NULL,
	ord_rateby 		CHAR(1) NULL,
	cht_itemcode 		VARCHAR(8) NULL, 
	ref_type 		VARCHAR(6) NULL,
	ref_num 		VARCHAR(30) NULL,
	fgt_vol 		MONEY NULL,
	fgt_volunits 		VARCHAR(6) NULL,
	fgt_count		MONEY NULL,
	fgt_weight		MONEY NULL,
	fgt_weightunits		VARCHAR(6) NULL,
	quantity 		MONEY NULL,   
	rate 			MONEY NULL,   
	charge 			MONEY NULL,
	pod_cmp_addr1 		VARCHAR(100) NULL,   
	pod_cmp_addr2 		VARCHAR(100) NULL,   
	pod_cmp_addr3 		VARCHAR(100) NULL,   
	pod_cmp_addr4 		VARCHAR(100) NULL,
	ord_bookdate 		DATETIME NULL,
	ord_startdate 		DATETIME NULL,
	ord_reftype 		VARCHAR(6) NULL,
	ord_refnum 		VARCHAR(30) NULL,
	tractor 		VARCHAR(8) NULL,
	trailer 		VARCHAR(13) NULL,
	driver 			VARCHAR(8) NULL,
	ord_revtype1_t 		VARCHAR(20) NULL,
	ord_revtype2_t 		VARCHAR(20) NULL,
	ord_revtype3_t 		VARCHAR(20) NULL,
	ord_revtype4_t 		VARCHAR(20) NULL,
	ord_revtype1 		VARCHAR(20) NULL,
	ord_revtype2 		VARCHAR(20) NULL,
	ord_revtype3 		VARCHAR(20) NULL,
	ord_revtype4 		VARCHAR(20) NULL,
	unit 			VARCHAR(6) NULL,
	rateunit 		VARCHAR(6) NULL,
	unitdesc 		VARCHAR(20) NULL,
	rateunitdesc 		VARCHAR(20) NULL,
	stp_number 		INTEGER NULL,
	cmp_id 			VARCHAR(8) NULL,
	cmp_name 		VARCHAR(100) NULL,
	cmp_nmstct 		VARCHAR(30) NULL,
	fgt_description	 	VARCHAR(60) NULL,
	cht_description	 	VARCHAR(30) NULL,
	det_description		VARCHAR(255) NULL,
	ord_terms		VARCHAR(6) NULL,
	stp_comment		VARCHAR(255) NULL,
	zero_terms		VARCHAR(100) NULL,
	gst_number		VARCHAR(100) NULL,
	stp_refnum		VARCHAR(30) NULL,
	pod_note		VARCHAR(254) NULL
)

CREATE TABLE #charges (
	chg_id	 		INTEGER IDENTITY NOT NULL,
	ord_hdrnumber		INTEGER,
        cht_itemcode		VARCHAR(6),
        cht_taxtable1		CHAR(1),
        charge			MONEY,
	ord_totalpieces		MONEY,
	ord_totalweight		MONEY,
	ord_quantity		MONEY
)

CREATE TABLE #accessorials (
	chg_id	 		INTEGER IDENTITY NOT NULL,
	ord_hdrnumber		INTEGER,
        cht_itemcode		VARCHAR(6),
        cht_taxtable1		CHAR(1),
        charge			MONEY
)

SELECT @ord_terms = ord_terms,
       @ord_billto = ord_billto
  FROM orderheader
 WHERE ord_hdrnumber = @ord_hdrnumber

SELECT @show_tax = ISNULL(cmp_taxtable1, 'N')
  FROM company
 WHERE cmp_id = @ord_billto

SELECT @podshowchargeterms = gi_string1
  FROM generalinfo
 WHERE gi_name = 'PODShowChargeTerms'

SET @show_charges = CHARINDEX(',' + @ord_terms + ',', @podshowchargeterms)

IF @show_charges > 0
BEGIN
   SELECT @gst_desc = cht_description
     FROM chargetype
    WHERE cht_itemcode = 'GST'

   INSERT INTO #charges
      SELECT o.ord_hdrnumber, o.cht_itemcode, c.cht_taxtable1, o.ord_charge, 
             o.ord_totalpieces, o.ord_totalweight, o.ord_quantity 
        FROM orderheader o JOIN chargetype c ON o.cht_itemcode = c.cht_itemcode
       WHERE ord_hdrnumber = @ord_hdrnumber AND
             ord_charge > 0

   INSERT INTO #accessorials
      SELECT i.ord_hdrnumber, i.cht_itemcode, c.cht_taxtable1, i.ivd_charge
        FROM invoicedetail i JOIN chargetype c ON i.cht_itemcode = c.cht_itemcode
       WHERE i.ord_hdrnumber = @ord_hdrnumber

   IF @show_tax = 'Y' 
   BEGIN
      SELECT @gst_taxstring = ISNULL(gi_string1, '0')
        FROM generalinfo
       WHERE gi_name = 'PODGSTTaxRate'
      SET @gst_taxrate = CAST(@gst_taxstring AS DECIMAL(7,4))/100
   END
   ELSE
      SET @gst_taxrate = 0
END

SELECT @stp_count = Count(*),
       @stp_sequence_max = MAX(stp_sequence)
  FROM stops
 WHERE ord_hdrnumber = @ord_hdrnumber AND
       stp_type = 'DRP'

SELECT @ls_rateby = ord_rateby 
  FROM orderheader 
 WHERE ord_hdrnumber = @ord_hdrnumber

IF @ls_rateby = 'T' -- For rate by total create a line for linehaul from orderheader and details from invoicedetails
BEGIN
   INSERT INTO #temp (cht_itemcode, ref_type, ref_num, fgt_vol, fgt_volunits, fgt_count,
                      fgt_weight, fgt_weightunits, quantity, rate, charge, unit, rateunit, 
                      stp_number, fgt_description)
      SELECT cht_itemcode, fgt_reftype, fgt_refnum, fgt_volume ,fgt_volumeunit, fgt_count, 
             fgt_weight, fgt_weightunit, fgt_quantity, fgt_rate, fgt_charge, fgt_unit, 
             fgt_rateunit, stp_number, fgt_description
        FROM freightdetail 
       WHERE stp_number = @stp_number

   IF @show_charges > 0
   BEGIN
      INSERT INTO #temp (cht_itemcode, ref_type, ref_num, fgt_vol, fgt_volunits, fgt_count,
                         fgt_weight, fgt_weightunits, quantity, rate, charge, unit, rateunit, 
                         stp_number, fgt_description)
         SELECT o.cht_itemcode, ord_reftype,ord_refnum, ord_totalvolume ,ord_totalvolumeunits,
                ord_totalpieces, ord_totalweight, ord_totalweightunits, ord_quantity, ord_rate, 
                ord_charge, ord_unit, ord_rateunit, 0, c.cht_description
           FROM orderheader o LEFT OUTER JOIN chargetype c ON o.cht_itemcode = c.cht_itemcode
          WHERE ord_hdrnumber = @ord_hdrnumber AND
                ord_charge > 0
   
      INSERT INTO #temp (cht_itemcode, ref_type, ref_num, fgt_vol, fgt_volunits, fgt_count, 
                         fgt_weight, fgt_weightunits, quantity, rate, charge, unit, rateunit, 
                         stp_number, fgt_description)
         SELECT cht_itemcode, ivd_reftype,ivd_refnum, ivd_volume ,ivd_volunit, ivd_count, 
                ivd_wgt, ivd_wgtunit, ivd_quantity, ivd_rate, ivd_charge, ivd_unit, 
                ivd_rateunit, stp_number, ivd_description
           FROM invoicedetail 
          WHERE ord_hdrnumber = @ord_hdrnumber
   END
      
-- IF @gst_tax > 0
--    INSERT INTO #temp (cht_itemcode, quantity, rate, charge, fgt_description)
--               VALUES ('GST', 1, @gst_tax, @gst_tax, @gst_desc)
END
ELSE -- For rate by detail get all the information from freightdetails
BEGIN
   INSERT INTO #temp (cht_itemcode, ref_type, ref_num, fgt_vol, fgt_volunits, fgt_count,
                      fgt_weight, fgt_weightunits, quantity, rate, charge, unit, rateunit, 
                      stp_number, fgt_description)
      SELECT cht_itemcode, fgt_reftype, fgt_refnum, fgt_volume ,fgt_volumeunit, fgt_count, 
             fgt_weight, fgt_weightunit, fgt_quantity, fgt_rate, fgt_charge, fgt_unit, 
             fgt_rateunit, stp_number, fgt_description
	FROM freightdetail 
       WHERE stp_number = @stp_number

   IF @show_charges > 0
   BEGIN	
      INSERT INTO #temp (cht_itemcode ,ref_type ,ref_num ,fgt_vol ,fgt_volunits , fgt_count,
                         fgt_weight, fgt_weightunits, quantity, rate, charge, unit, rateunit, 
                         stp_number, fgt_description)
         SELECT cht_itemcode, ivd_reftype,ivd_refnum, ivd_volume ,ivd_volunit, ivd_count,
                ivd_wgt, ivd_wgtunit, ivd_quantity, ivd_rate, ivd_charge, ivd_unit, ivd_rateunit, 
                stp_number, ivd_description
           FROM invoicedetail 
          WHERE ord_hdrnumber = @ord_hdrnumber
   END
END

IF @show_charges > 0
BEGIN
   --Attempt to apportion each charge type across all stops
   --Loop through the charges table and apportion by stop
   --if order was rated by total
   IF @ls_rateby = 'T'
   BEGIN
      SET @minchgid = 0
      WHILE 1=1
      BEGIN

         SELECT @minchgid = MIN(chg_id) 
           FROM #charges
          WHERE chg_id > @minchgid
            
         IF @minchgid IS NULL
            BREAK

         SELECT @cht_itemcode = cht_itemcode,
                @cht_charge = charge,
                @ord_pieces = ord_totalpieces,
                @ord_weight = ord_totalweight,
                @ord_quantity = ord_quantity
           FROM #charges
          WHERE chg_id = @minchgid

         IF @cht_charge > 0
         BEGIN
            SET @stp_charge = ROUND((@cht_charge/@stp_count), 2)
            IF @stp_charge > 0
            BEGIN
               SET @stp_pieces = ROUND((@ord_pieces/@stp_count), 2)
               SET @stp_weight = ROUND((@ord_weight/@stp_count), 2)
               SET @stp_quantity = ROUND((@ord_quantity/@stp_count), 2)
               IF @sequence < @stp_sequence_max
               BEGIN
                  UPDATE #temp
                     SET charge = @stp_charge,
                         fgt_count = @stp_pieces,
                         fgt_weight = @stp_weight,
                         quantity = @stp_quantity
                   WHERE cht_itemcode = @cht_itemcode
               END
               ELSE
               BEGIN
                  SET @stp_charge = ROUND(@cht_charge - (@stp_charge * (@stp_count - 1)), 2)
                  SET @stp_pieces = ROUND(@ord_pieces - (@stp_pieces * (@stp_count - 1)), 2)
                  SET @stp_weight = ROUND(@ord_weight - (@stp_weight * (@stp_count - 1)), 2)
                  SET @stp_quantity = ROUND(@ord_quantity - (@stp_quantity * (@stp_count - 1)), 2)
                  UPDATE #temp
                     SET charge = @stp_charge,
                         fgt_count = @stp_pieces,
                         fgt_weight = @stp_weight,
                         quantity = @stp_quantity
                   WHERE cht_itemcode = @cht_itemcode
               END
            END
         END
      END
   END

   --Attempt to apportion each charge type across all stops
   --Loop through the accessorials table and apportion by stop
   SET @minchgid = 0
   WHILE 1=1
   BEGIN

      SELECT @minchgid = MIN(chg_id) 
        FROM #accessorials
       WHERE chg_id > @minchgid
            
      IF @minchgid IS NULL
         BREAK

      SELECT @cht_itemcode = cht_itemcode,
             @cht_charge = charge
        FROM #accessorials
       WHERE chg_id = @minchgid

      IF @cht_charge > 0
      BEGIN
         SET @stp_charge = ROUND((@cht_charge/@stp_count), 2)
         IF @stp_charge > 0
         BEGIN
            IF @sequence < @stp_sequence_max
            BEGIN
               UPDATE #temp
                  SET charge = @stp_charge
                WHERE cht_itemcode = @cht_itemcode
            END
            ELSE
            BEGIN
               SET @stp_charge = ROUND(@cht_charge - (@stp_charge * (@stp_count - 1)), 2)
               UPDATE #temp
                  SET charge = @stp_charge
                WHERE cht_itemcode = @cht_itemcode
            END
         END
      END
   END

   --Compute tax charges if gst tax rate is set and the billto companies taxtable1 is set
   IF @gst_taxrate > 0 and not exists (select 1 from invoicedetail where ord_hdrnumber = @ord_hdrnumber and 
   cht_itemcode = 'GST')
   BEGIN
      SELECT @taxable_charges = ISNULL(SUM(charge), 0)
        FROM #charges
       WHERE cht_taxtable1 = 'Y'
      SELECT @taxable_accessorials = ISNULL(SUM(charge), 0)
        FROM #accessorials
       WHERE cht_taxtable1 = 'Y'
      IF @taxable_charges IS NULL
         SET @taxable_charges = 0
      IF @taxable_accessorials IS NULL
         SET @taxable_accessorials = 0
      SET @taxable_total = @taxable_charges + @taxable_accessorials
      IF @taxable_total > 0
      BEGIN
         SET @tax_total = ROUND((@taxable_total * @gst_taxrate), 2)
         SET @tax_charge = ROUND((@taxable_total/@stp_count), 2)
         IF @sequence = @stp_sequence_max
            SET @tax_charge = ROUND(@taxable_total - (@tax_charge * (@stp_count - 1)), 2)
         IF @sequence < @stp_sequence_max
            SET @gst_tax = ROUND((@tax_charge * @gst_taxrate), 2)
         IF @sequence = @stp_sequence_max
         BEGIN
            SET @tax_perstop = ROUND(@tax_total/@stp_count, 2)
            SET @gst_tax = ROUND(@tax_total - (@tax_perstop * (@stp_count - 1)), 2)
         END
         INSERT INTO #temp (cht_itemcode, quantity, rate, charge, fgt_description)
                    VALUES ('GST', @tax_charge, @gst_taxrate, @gst_tax, @gst_desc)
      END
   END
END

UPDATE #temp 
   SET cht_description = chargetype.cht_description 
  FROM chargetype 
 WHERE #temp.cht_itemcode = chargetype.cht_itemcode

UPDATE #temp 
   SET #temp.cmp_id = stops.cmp_id,
       #temp.cmp_name = company.cmp_name
  FROM stops,company 
 WHERE #temp.stp_number > 0 AND
       #temp.stp_number = stops.stp_number AND
       stops.cmp_id = company.cmp_id

UPDATE #temp 
   SET #temp.cmp_nmstct = SUBSTRING(city.cty_nmstct, 1, CHARINDEX('/', city.cty_nmstct) - 1) 
  FROM company,city
 WHERE #temp.cmp_id = company.cmp_id AND
       company.cmp_city = city.cty_code

UPDATE #temp 
   SET unitdesc = name  
  FROM labelfile 
 WHERE labeldefinition LIKE '%Units%' AND
       #temp.unit = abbr

UPDATE #temp 
   SET rateunitdesc = name  
  FROM labelfile 
 WHERE labeldefinition = 'RateBy' AND
       #temp.rateunit = abbr

UPDATE #temp 
   SET driver = lgh_driver1, 
       tractor = lgh_tractor, 
       trailer = lgh_primary_trailer
  FROM legheader 
 WHERE lgh_number = @lgh

UPDATE #temp 
   SET pod_cmp_addr1 = gi_string1,
       pod_cmp_addr2 = gi_string2,
       pod_cmp_addr3 = gi_string3,
       pod_cmp_addr4 = gi_string4 
  FROM generalinfo 
 WHERE gi_name = 'PODCompany'

UPDATE #temp
   SET gst_number = gi_string1
  FROM generalinfo
 WHERE gi_name = 'GSTNumber'

UPDATE #temp
   SET zero_terms = ISNULL(gi_string1, ' ')
  FROM generalinfo
 WHERE gi_name = 'PODShowChargeTerms'

UPDATE #temp 
   SET ord_number = orderheader.ord_number,
       ord_bookdate = orderheader.ord_bookdate,
       ord_startdate = orderheader.ord_bookdate,
       ord_reftype =orderheader.ord_reftype,
       ord_refnum = orderheader.ord_refnum,
       ord_terms = orderheader.ord_terms
  FROM orderheader 
 WHERE ord_hdrnumber = @ord_hdrnumber

UPDATE #temp 
   SET ord_revtype1 = labelfile.name, 
       ord_revtype1_t = labelfile.userlabelname
  FROM labelfile, orderheader
 wHERE ord_hdrnumber = @ord_hdrnumber AND
       labelfile.labeldefinition= 'RevType1' AND
       orderheader.ord_revtype1 = labelfile.abbr


UPDATE #temp 
   SET ord_billto = orderheader.ord_billto,
       ord_shipper = orderheader.ord_shipper,
       ord_consignee = orderheader.ord_consignee,
       ord_rateby = orderheader.ord_rateby
  FROM orderheader 
 WHERE ord_hdrnumber = @ord_hdrnumber

UPDATE #temp 
   SET billto_name = company.cmp_name,
       billto_addr = cmp_address1,
       billto_addr2 = ISNULL(cmp_address2,''),
       billto_nmstct = CASE cty_nmstct 
                          WHEN 'UNKNOWN' THEN 'UNKNOWN' 
                          ELSE SUBSTRING(cty_nmstct, 1 , CHARINDEX('/', cty_nmstct) - 1) + '  ' + cmp_zip
                       END
  FROM company 
 WHERE #temp.ord_billto = company.cmp_id 

UPDATE #temp 
   SET shipper_name = company.cmp_name,
       shipper_addr = cmp_address1,
       shipper_addr2 = ISNULL(cmp_address2,''),
       shipper_nmstct = CASE cty_nmstct 
                           WHEN 'UNKNOWN' THEN 'UNKNOWN' 
                           ELSE SUBSTRING(cty_nmstct, 1, CHARINDEX('/', cty_nmstct) - 1) + '  ' + cmp_zip 
                        END
  FROM company 
 WHERE #temp.ord_shipper = company.cmp_id 

UPDATE #temp 
   SET consignee_name = company.cmp_name,
       consignee_addr = cmp_address1,
       consignee_addr2 = ISNULL(cmp_address2,''),
       consignee_nmstct = CASE cty_nmstct 
                             WHEN 'UNKNOWN' THEN 'UNKNOWN' 
                             ELSE SUBSTRING(cty_nmstct, 1, charindex('/', cty_nmstct) - 1) + '  ' + cmp_zip 
                          END
  FROM company 
 WHERE #temp.cmp_id = company.cmp_id 

UPDATE #temp
   SET stp_comment = stops.stp_comment,
       stp_refnum = stops.stp_refnum
  FROM stops
 WHERE #temp.stp_number = stops.stp_number and 
       #temp.stp_number > 0

SET @ord_string = CAST(@ord_hdrnumber AS VARCHAR(20))
SELECT @pod_note = MIN(not_text)
  FROM notes
 WHERE ntb_table = 'orderheader' AND
       nre_tablekey = @ord_string AND
       not_type = 'POD'
IF @pod_note IS NOT NULL
   UPDATE #temp
      SET pod_note = @pod_note
    WHERE stp_number = @stp_number


/* FINAL SELECT - FORMS RETURN SET */  
SELECT *  
  FROM #temp

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 
   SELECT @ret_value = @@ERROR
  
RETURN @ret_value  
GO
GRANT EXECUTE ON  [dbo].[pod_format03] TO [public]
GO
