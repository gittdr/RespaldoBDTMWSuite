SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_load_rail_billing_tender] (@lgh_number	INTEGER)
AS
DECLARE	@start_event	    VARCHAR(3),
	@seal_type	    VARCHAR(6),
        @notify_type	    VARCHAR(6),
        @notify_fax         VARCHAR(6),
	@ord_hdrnumber	    INTEGER,
	@ord_number	    VARCHAR(12),
	@mov_number	    INTEGER,
	@seal_number	    VARCHAR(30),
        @cmdstring	    VARCHAR(72),
        @ord_totalweight    INTEGER,
        @weightfrompickups  CHAR(1)

CREATE TABLE #temp1 
(
	lgh_number			INTEGER NULL,
	cmp_id_start			VARCHAR(12) NULL,
	cmp_id_end			VARCHAR(12) NULL,
	lgh_carrier			VARCHAR(8) NULL,
	lgh_primary_trailer		VARCHAR(13) NULL,
	lgh_204status			VARCHAR(6) NULL,
        lgh_204date			DATETIME NULL,
	car_204tender			CHAR(1) NULL,
	car_204update			VARCHAR(3) NULL,
	lgh_raildispatchstatus		VARCHAR(6) NULL,
	origin_name			VARCHAR(100) NULL,
	origin_location			VARCHAR(25) NULL,
	origin_zip			VARCHAR(10) NULL,
	dest_name			VARCHAR(100) NULL,
	dest_location			VARCHAR(25) NULL,
	dest_zip			VARCHAR(10) NULL,
	rth_masterbillid		VARCHAR(20) NULL,
	rth_origin_ramp_actual		VARCHAR(30) NULL,
	rth_shipper			VARCHAR(8) NULL,
	rth_dest_ramp_actual		VARCHAR(30) NULL,
	rth_consignee			VARCHAR(8) NULL,
	rth_billto			VARCHAR(8) NULL,
	billto_name			VARCHAR(100) NULL,
	billto_location			VARCHAR(25) NULL,
	billto_zip			VARCHAR(10) NULL,
	rth_terms			VARCHAR(6) NULL,
	rth_notifyparty			VARCHAR(30) NULL,
	rth_notifyfax			VARCHAR(30) NULL,
	stp_start_event			VARCHAR(6) NULL,
	load_empty			VARCHAR(3) NULL,
	trl_equipmenttype		VARCHAR(10) NULL,
	trl_type2			VARCHAR(6) NULL,
	ord_totalweight			INTEGER NULL,
	Seal_number			VARCHAR(30) NULL,
	ord_billto			VARCHAR(8) NULL,
	lgh_type2               	VARCHAR(6) NULL,
	rtd_quote			VARCHAR(20) NULL,
	rtd_plan			VARCHAR(20) NULL,
        rtd_stcc			VARCHAR(72) NULL,
	ord_number			VARCHAR(12) NULL,
	lgh_railtemplatedetail_id	INTEGER NULL,
	ord_hdrnumber		INT			--PTS 70351
)

CREATE TABLE #cmdcodes (
	cmd_stcc		VARCHAR(8) NULL
)

SELECT @weightfrompickups = UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
  FROM generalinfo
 WHERE gi_name = 'RailBillingWeightFromPickups'

SELECT @ord_hdrnumber = ISNULL(ord_hdrnumber, 0),
       @mov_number = mov_number
  FROM legheader
 WHERE lgh_number = @lgh_number

IF @ord_hdrnumber > 0
BEGIN
   SELECT @ord_number = ord_number,
          @ord_totalweight = ISNULL(ord_totalweight, 0)
     FROM orderheader
    WHERE ord_hdrnumber = @ord_hdrnumber

   IF @weightfrompickups = 'Y'
   BEGIN
      SELECT @ord_totalweight = SUM(fgt_weight)
        FROM freightdetail 
       WHERE stp_number IN (SELECT stp_number 
                              FROM stops 
                             WHERE ord_hdrnumber = @ord_hdrnumber AND
                                   stp_type = 'PUP')
      IF @ord_totalweight IS NULL
      BEGIN
         SET @ord_totalweight = 0
      END
   END 
END

SELECT @seal_type = ISNULL(gi_string1, 'UNK')
  FROM generalinfo
 WHERE gi_name = 'RailBillingTenderSealType'
IF @seal_type <> 'UNK'
BEGIN
   IF @ord_hdrnumber > 0
   BEGIN
      SELECT @seal_number = ref_number
        FROM referencenumber
       WHERE ref_type = @seal_type AND
             ref_table = 'orderheader' AND
             ref_tablekey = @ord_hdrnumber AND
             ref_sequence = (SELECT MIN(ref_sequence)
                               FROM referencenumber
                              WHERE ref_type = @seal_type AND
                                    ref_table = 'orderheader' AND
                                    ref_tablekey = @ord_hdrnumber)
   END
END

SELECT @notify_type = ISNULL(gi_string1, 'UNK'),
       @notify_fax = ISNULL(gi_string2, 'UNK')
  FROM generalinfo
 WHERE gi_name = 'RailBillingTenderNotifyType'

INSERT INTO #cmdcodes
   SELECT cmd_stcc
     FROM commodity
    WHERE cmd_code IN (SELECT DISTINCT cmd_code
                         FROM freightdetail
                        WHERE stp_number IN (SELECT stp_number
                                               FROM stops
                                              WHERE mov_number = @mov_number) AND
                              cmd_code NOT IN ('FAK', 'UNKNOWN'))
SET @cmdstring = ''
SELECT @cmdstring = @cmdstring + cmd_stcc + ', '
  FROM #cmdcodes
 WHERE cmd_stcc IS NOT NULL
IF LEN(@cmdstring) > 0
   SET @cmdstring = LEFT(@cmdstring, LEN(@cmdstring) - 1)

INSERT INTO #temp1 (lgh_number, cmp_id_start, cmp_id_end, lgh_carrier, lgh_primary_trailer,
                   lgh_204status, lgh_204date, car_204tender, car_204update, lgh_raildispatchstatus,
                   origin_name, origin_location, origin_zip, dest_name, dest_location,
                   dest_zip, stp_start_event, trl_equipmenttype, trl_type2, 
                   orderheader.ord_totalweight, seal_number, ord_billto, lgh_type2,
                   rth_notifyparty, rth_notifyfax, rtd_stcc, ord_number, lgh_railtemplatedetail_id,
				   ord_hdrnumber)							--PTS 70351
   SELECT legheader.lgh_number, 
          legheader.cmp_id_start, 
          legheader.cmp_id_end, 
          legheader.lgh_carrier, 
          legheader.lgh_primary_trailer, 
          legheader.lgh_204status,
          legheader.lgh_204date, 
          ISNULL(carrier.car_204tender, 'M'), 
          ISNULL(carrier.car_204update, 'ALL'), 
          legheader.lgh_raildispatchstatus, 
          cmp1.cmp_name,
          cmp1.cty_nmstct, 
          cmp1.cmp_zip, 
          cmp2.cmp_name,
          cmp2.cty_nmstct, 
          cmp2.cmp_zip, 
          stops.stp_event,
          trailerprofile.trl_equipmenttype, 
          trailerprofile.trl_type2, 
          @ord_totalweight,
          @seal_number, 
          orderheader.ord_billto, 
          legheader.lgh_type2,
          (SELECT TOP 1 ref_number
             FROM referencenumber
            WHERE ref_type = @notify_type AND
                  ref_table = 'orderheader' AND
                  ref_tablekey = @ord_hdrnumber),
          (SELECT TOP 1 ref_number
             FROM referencenumber
            WHERE ref_type = @notify_fax AND
                  ref_table = 'orderheader' AND
                  ref_tablekey = @ord_hdrnumber),
          @cmdstring,
          @ord_number,
          ISNULL(lgh_railtemplatedetail_id, 0),
		  @ord_hdrnumber								--PTS 70351
     FROM legheader JOIN carrier ON legheader.lgh_carrier = carrier.car_id
                    JOIN company cmp1 ON legheader.cmp_id_start = cmp1.cmp_id
                    JOIN company cmp2 ON legheader.cmp_id_end = cmp2.cmp_id
                    JOIN stops ON legheader.stp_number_start = stops.stp_number
                    JOIN trailerprofile ON legheader.lgh_primary_trailer = trailerprofile.trl_id
                    JOIN orderheader ON legheader.ord_hdrnumber = orderheader.ord_hdrnumber
    WHERE legheader.lgh_number = @lgh_number

SELECT @start_event = stp_start_event
  FROM #temp1

IF RIGHT(@start_event, 2) = 'MT'
   UPDATE #temp1
      SET load_empty = 'MT'
ELSE
   UPDATE #temp1
      SET load_empty = 'LD'

SELECT lgh_number,
       cmp_id_start,
       cmp_id_end,
       lgh_carrier,
       lgh_primary_trailer,
       lgh_204status,
       lgh_204date,
       car_204tender,
       car_204update,
       lgh_raildispatchstatus,
       origin_name,
       origin_location,
       origin_zip,
       dest_name,
       dest_location,
       dest_zip,
       rth_masterbillid,
       rth_origin_ramp_actual,
       rth_shipper,
       rth_dest_ramp_actual,
       rth_consignee,
       rth_billto,
       billto_name,
       billto_location,
       billto_zip,
       rth_terms,
       rth_notifyparty,
       rth_notifyfax,
       stp_start_event,
       load_empty,
       trl_equipmenttype,
       trl_type2,
       ord_totalweight,
       seal_number,
       ord_billto,
       lgh_type2,
       rtd_quote,
       rtd_plan,
       rtd_stcc,
       ord_number,
       lgh_railtemplatedetail_id,
	   ord_hdrnumber					-- PTS70351
  FROM #temp1

GO
GRANT EXECUTE ON  [dbo].[d_load_rail_billing_tender] TO [public]
GO
