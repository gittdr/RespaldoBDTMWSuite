SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pod_format04] (@ord_hdrnumber 	INTEGER) 
AS
DECLARE @temp_name   	VARCHAR(30) ,  
        @temp_addr   	VARCHAR(30) ,  
        @temp_addr2  	VARCHAR(30),  
        @temp_nmstct	VARCHAR(30),  
        @temp_altid  	VARCHAR(25),  
        @counter    	INTEGER,  
        @ret_value  	INTEGER,  
        @temp_terms    	VARCHAR(20),  
        @varchar50 	VARCHAR(50)  ,
        @ls_rateby 	CHAR(1),
	@lgh		INTEGER
  
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
	billto_credit_terms	VARCHAR(20) NULL, 
	ord_shipper  		VARCHAR(8) NULL,     
	shipper_name 		VARCHAR(100) NULL,  
	shipper_addr 		VARCHAR(100) NULL,  
	shipper_addr2 		VARCHAR(100) NULL,  
	shipper_nmstct 		VARCHAR(30) NULL,
	shipper_contact		VARCHAR(30) NULL,
	shipper_directions	TEXT NULL,  
	ord_consignee 		VARCHAR(8) NULL,     
	consignee_name 		VARCHAR(100) NULL,  
	consignee_addr 		VARCHAR(100) NULL,  
	consignee_addr2 	VARCHAR(100) NULL,  
	consignee_nmstct 	VARCHAR(30) NULL,
	consignee_contact	VARCHAR(30) NULL,
	consignee_directions	TEXT NULL,
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
        ord_enddate		DATETIME NULL,
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
	load_comment		VARCHAR(60) NULL,
	unload_comment		VARCHAR(60) NULL,
	ord_remark		VARCHAR(254) NULL,
	mov_number		INTEGER NULL,
	driver_firstname	VARCHAR(40) NULL,
	driver_lastname		VARCHAR(40) NULL,
        driver_license		VARCHAR(25) NULL,
	tractor_license		VARCHAR(12) NULL,
	trailer_license		VARCHAR(12) NULL,
	ord_bookedby		VARCHAR(20) NULL,
	ord_accessorial_chrg	MONEY NULL,
	toll_charge		MONEY NULL,
        iva_tax			VARCHAR(2) NULL,
        retention_tax		VARCHAR(2) NULL,
	consignee_phone		VARCHAR(20) NULL,
	shipper_phone		VARCHAR(20) NULL
)

SELECT @lgh = MIN(lgh_number) 
  FROM stops 
 WHERE ord_hdrnumber = @ord_hdrnumber

SELECT @ls_rateby = ord_rateby 
  FROM orderheader 
 WHERE ord_hdrnumber = @ord_hdrnumber

IF @ls_rateby = 'T' -- For rate by total create a line for linehaul from orderheader and details from invoicedetails
BEGIN
   IF (SELECT count(*) 
         FROM invoicedetail 
        WHERE ord_hdrnumber = @ord_hdrnumber AND
              ivd_type = 'SUB') < 1
   BEGIN
/*      INSERT INTO #temp (cht_itemcode, ref_type, ref_num, fgt_vol, fgt_volunits, fgt_count,
                      fgt_weight, fgt_weightunits, quantity, rate, charge, unit, rateunit, 
                      stp_number, fgt_description)
      SELECT cht_itemcode, fgt_reftype, fgt_refnum, fgt_volume ,fgt_volumeunit, fgt_count, 
             fgt_weight, fgt_weightunit, fgt_quantity, fgt_rate, fgt_charge, fgt_unit, 
             fgt_rateunit, stp_number, fgt_description
	FROM freightdetail 
       WHERE stp_number IN (SELECT stp_number 
                              FROM stops 
                             WHERE ord_hdrnumber = @ord_hdrnumber AND 
                                   stp_type = 'DRP')   */

      INSERT INTO #temp (cht_itemcode, ref_type, ref_num, fgt_vol, fgt_volunits, fgt_count,
                         fgt_weight, fgt_weightunits, quantity, rate, charge, unit, rateunit, 
                         stp_number, fgt_description)
         SELECT cht_itemcode, ord_reftype,ord_refnum, ord_totalvolume ,ord_totalvolumeunits,
                ord_totalpieces, ord_totalweight, ord_totalweightunits, ord_quantity, ord_rate, 
                ord_charge, ord_unit, ord_rateunit, 0,ord_description
	   FROM orderheader 
          WHERE ord_hdrnumber = @ord_hdrnumber
   END

/*   INSERT INTO #temp (cht_itemcode, ref_type, ref_num, fgt_vol, fgt_volunits, fgt_count, 
                      fgt_weight, fgt_weightunits, quantity, rate, charge, unit, rateunit, 
                      stp_number, fgt_description)
      SELECT cht_itemcode, ivd_reftype,ivd_refnum, ivd_volume ,ivd_volunit, ivd_count, 
                      ivd_wgt, ivd_wgtunit, ivd_quantity, ivd_rate, ivd_charge, ivd_unit, 
                      ivd_rateunit, stp_number, ivd_description
        FROM invoicedetail 
       WHERE ord_hdrnumber = @ord_hdrnumber */
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
       WHERE stp_number IN (SELECT stp_number 
                              FROM stops 
                             WHERE ord_hdrnumber = @ord_hdrnumber AND 
                                   stp_type = 'DRP')
	
   INSERT INTO #temp (cht_itemcode ,ref_type ,ref_num ,fgt_vol ,fgt_volunits , fgt_count,
                      fgt_weight, fgt_weightunits, quantity, rate, charge, unit, rateunit, 
                      stp_number, fgt_description)
      SELECT cht_itemcode, ivd_reftype,ivd_refnum, ivd_volume ,ivd_volunit, ivd_count,
             ivd_wgt, ivd_wgtunit, ivd_quantity, ivd_rate, ivd_charge, ivd_unit, ivd_rateunit, 
             stp_number, ivd_description
        FROM invoicedetail 
       WHERE ord_hdrnumber = @ord_hdrnumber
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
   SET driver_firstname = mpp_firstname,
       driver_lastname = mpp_lastname,
       driver_license = mpp_licensenumber
  FROM manpowerprofile
 WHERE mpp_id = #temp.driver AND
       #temp.driver <> 'UNKNOWN'

UPDATE #temp
   SET tractor_license = trc_licnum
  FROM tractorprofile
 WHERE trc_number = #temp.tractor AND
       #temp.tractor <> 'UNKNOWN'

UPDATE #temp
   SET trailer_license = trl_licnum
  FROM trailerprofile
 WHERE trl_id = #temp.trailer AND
       #temp.trailer <> 'UNKNOWN'

UPDATE #temp 
   SET pod_cmp_addr1 = gi_string1,
       pod_cmp_addr2 = gi_string2,
       pod_cmp_addr3 = gi_string3,
       pod_cmp_addr4 = gi_string4 
  FROM generalinfo 
 WHERE gi_name = 'PODCompany'

UPDATE #temp 
   SET ord_number = orderheader.ord_number,
       ord_bookdate = orderheader.ord_bookdate,
       ord_startdate = orderheader.ord_bookdate,
       ord_enddate = orderheader.ord_completiondate,
       ord_reftype =orderheader.ord_reftype,
       ord_refnum = orderheader.ord_refnum,
       ord_terms = orderheader.ord_terms,
       ord_remark = orderheader.ord_remark,
       mov_number = orderheader.mov_number,
       ord_bookedby = orderheader.ord_bookedby,
       ord_billto = orderheader.ord_billto,
       ord_shipper = orderheader.ord_shipper,
       ord_consignee = orderheader.ord_consignee,
       ord_rateby = orderheader.ord_rateby,
       ord_accessorial_chrg = ISNULL(orderheader.ord_accessorial_chrg, 0)
  FROM orderheader 
 WHERE ord_hdrnumber = @ord_hdrnumber

UPDATE #temp
   SET toll_charge = 0

UPDATE #temp 
   SET ord_revtype1 = labelfile.name, 
       ord_revtype1_t = labelfile.userlabelname
  FROM labelfile, orderheader
 wHERE ord_hdrnumber = @ord_hdrnumber AND
       labelfile.labeldefinition= 'RevType1' AND
       orderheader.ord_revtype1 = labelfile.abbr

UPDATE #temp 
   SET billto_name = company.cmp_name,
       billto_addr = cmp_address1,
       billto_addr2 = ISNULL(cmp_address2,''),
       billto_nmstct = CASE cty_nmstct 
                          WHEN 'UNKNOWN' THEN 'UNKNOWN' 
                          ELSE SUBSTRING(cty_nmstct, 1 , CHARINDEX('/', cty_nmstct) - 1) + '  ' + ISNULL(cmp_zip, ' ')
                       END,
       billto_credit_terms = (SELECT name
                                FROM labelfile
                               WHERE labeldefinition = 'CreditTerms' AND
                                     abbr = company.cmp_terms)
  FROM company 
 WHERE #temp.ord_billto = company.cmp_id 

UPDATE #temp 
   SET shipper_name = company.cmp_name,
       shipper_addr = cmp_address1,
       shipper_addr2 = ISNULL(cmp_address2,''),
       shipper_nmstct = CASE cty_nmstct 
                           WHEN 'UNKNOWN' THEN 'UNKNOWN' 
                           ELSE SUBSTRING(cty_nmstct, 1, CHARINDEX('/', cty_nmstct) - 1) + '  ' + ISNULL(cmp_zip, ' ')
                        END,
       shipper_contact = company.cmp_contact,
       shipper_directions = company.cmp_directions,
       shipper_phone = company.cmp_primaryphone
  FROM company 
 WHERE #temp.ord_shipper = company.cmp_id 

UPDATE #temp 
   SET consignee_name = company.cmp_name,
       consignee_addr = cmp_address1,
       consignee_addr2 = ISNULL(cmp_address2,''),
       consignee_nmstct = CASE cty_nmstct 
                             WHEN 'UNKNOWN' THEN 'UNKNOWN' 
                             ELSE SUBSTRING(cty_nmstct, 1, charindex('/', cty_nmstct) - 1) + '  ' + ISNULL(cmp_zip, ' ') 
                          END,
       consignee_contact = company.cmp_contact,
       consignee_directions = company.cmp_directions,
       consignee_phone = company.cmp_primaryphone
  FROM company 
 WHERE #temp.ord_consignee = company.cmp_id 

UPDATE #temp
   SET load_comment = stops.stp_comment
  FROM stops
 WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
       stops.stp_type = 'PUP' AND
       stops.stp_sequence = (SELECT MIN(stp_sequence)
                               FROM stops
                              WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
                                    stops.stp_type = 'PUP')

UPDATE #temp
   SET unload_comment = stops.stp_comment
  FROM stops
 WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
       stops.stp_type = 'DRP' AND
       stops.stp_sequence = (SELECT MAX(stp_sequence)
                               FROM stops
                              WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
                                    stops.stp_type = 'DRP')

UPDATE #temp
   SET iva_tax = ISNULL(gi_string1, '0'),
       retention_tax = ISNULL(gi_string2, '0')
  FROM generalinfo
 WHERE gi_name = 'PODFormat04Taxes'


/* FINAL SELECT - FORMS RETURN SET */  
SELECT *  
  FROM #temp

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0 
   SELECT @ret_value = @@ERROR
  
RETURN @ret_value  
GO
GRANT EXECUTE ON  [dbo].[pod_format04] TO [public]
GO
