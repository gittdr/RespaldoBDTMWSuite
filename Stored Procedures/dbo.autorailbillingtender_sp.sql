SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[autorailbillingtender_sp] @lgh_number    INTEGER,
                                              @carrier       VARCHAR(8),
                                              @tender_status VARCHAR(6) OUTPUT
AS
DECLARE @cmp_id_start			VARCHAR(8),
	@cmp_id_end			VARCHAR(8),
	@mov_number			INTEGER,
	@ord_hdrnumber			INTEGER,
	@ord_number			VARCHAR(12),
	@lgh_raildispatchstatus		CHAR(1),
	@return				VARCHAR(6),
	@header_count			INTEGER,
	@detail_count			INTEGER,
	@rth_id				INTEGER,
	@seal_type			VARCHAR(6),
	@seal_number			VARCHAR(30),
	@service			VARCHAR(6),
	@length				VARCHAR(6),
        @mode				VARCHAR(10),
	@ord_billto			VARCHAR(8),
	@lgh_primary_trailer		VARCHAR(13),
        @stp_number_start		INTEGER,
	@stp_event			VARCHAR(6),
	@load_empty			VARCHAR(3),
	@ord_totalweight		INTEGER,
	@notify_type			VARCHAR(6),
	@notify_fax			VARCHAR(6),
	@cmdstring			VARCHAR(72),
	@notify_party			VARCHAR(30),
	@notify_faxref			VARCHAR(30),
	@car_204tender			CHAR(1),
	@rth_notifyparty		VARCHAR(8),
	@rth_notifyfax			VARCHAR(10),
	@rtd_id				INTEGER,
	@lgh_railtemplatedetail_id 	INTEGER,
	@weightfrompickups		CHAR(1)

DECLARE @tender_status_tendered varchar(6)

CREATE TABLE #header (
	rth_id		        INTEGER NULL,
	rth_masterbillid	VARCHAR(20) NULL,
	car_id			VARCHAR(8) NULL,
	rth_origin_ramp		VARCHAR(8)  NULL,
	rth_origin_ramp_actual	VARCHAR(30) NULL,
	rth_shipper		VARCHAR(8) NULL,
	rth_dest_ramp		VARCHAR(8)  NULL,
	rth_dest_ramp_actual	VARCHAR(30) NULL,
	rth_consignee		VARCHAR(8) NULL,
	rth_billto		VARCHAR(8) NULL,
	rth_terms		VARCHAR(6) NULL,
	rth_notifyparty		VARCHAR(8) NULL,
	rth_notifyfax		VARCHAR(10) NULL
)

CREATE TABLE #cmdcodes (
	cmd_stcc		VARCHAR(8) NULL
)

CREATE TABLE #detail (
	rtd_id			INTEGER NULL,
	rth_id			INTEGER NULL,
	rtd_quote		VARCHAR(20) NULL,
	rtd_plan		VARCHAR(20) NULL,
	rtd_service		VARCHAR(6) NULL,
	rtd_loaded		VARCHAR(3) NULL,
	rtd_mode		VARCHAR(10) NULL,
	rtd_length		VARCHAR(6) NULL,
	rtd_stcc		VARCHAR(72) NULL,
	rtd_benown		VARCHAR(8) NULL
)

SELECT @car_204tender = car_204tender
  FROM carrier
 WHERE car_id = @carrier

SELECT @weightfrompickups = UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
  FROM generalinfo
 WHERE gi_name = 'RailBillingWeightFromPickups'

SELECT @cmp_id_start = cmp_id_start,
       @cmp_id_end = cmp_id_end,
       @lgh_raildispatchstatus = ISNULL(lgh_raildispatchstatus, 'N'),
       @mov_number = mov_number,
       @ord_hdrnumber = ISNULL(ord_hdrnumber, 0),
       @service = ISNULL(lgh_type2, 'UNK'),
       @lgh_primary_trailer = ISNULL(lgh_primary_trailer, 'UNKNOWN'),
       @stp_number_start = stp_number_start,
       @lgh_railtemplatedetail_id = ISNULL(lgh_railtemplatedetail_id, 0)
  FROM legheader
 WHERE lgh_number = @lgh_number

--PTS72162 MBR 09/13/13
IF @ord_hdrnumber > 0
BEGIN
   SELECT @ord_number = ord_number,
          @ord_billto = ISNULL(ord_billto, 'UNKNOWN'),
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

INSERT INTO #header
   SELECT rth_id, rth_masterbillid, car_id, rth_origin_ramp, rth_origin_ramp_actual,
          rth_shipper, rth_dest_ramp, rth_dest_ramp_actual, rth_consignee, rth_billto,
          rth_terms, rth_notifyparty, rth_notifyfax
     FROM railtemplateheader
    WHERE rth_origin_ramp = @cmp_id_start AND
          rth_dest_ramp = @cmp_id_end AND
          car_id = @carrier

SET @header_count = 0
SELECT @header_count = COUNT(*)
  FROM #header

IF @header_count = 0
BEGIN
   SET @tender_status = 'NOHDR'
   RETURN 0
END

IF @header_count > 1
BEGIN
   SET @tender_status = 'MULHDR'
   RETURN 0
END

IF @lgh_primary_trailer = 'UNKNOWN'
BEGIN
   SET @tender_status = 'NOTRL'
   RETURN 0
END

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

SELECT @length = ISNULL(trl_type2, 'UNK'),
       @mode = trl_equipmenttype
  FROM trailerprofile
 WHERE trl_id = @lgh_primary_trailer

SELECT @stp_event = stp_event
  FROM stops
 WHERE stp_number = @stp_number_start

IF RIGHT(@stp_event, 2) = 'MT'
   SET @load_empty = 'MT'
ELSE
   SET @load_empty = 'LD'

SELECT @rth_id = rth_id
  FROM #header

IF @lgh_railtemplatedetail_id > 0 
BEGIN
   INSERT INTO #detail
      SELECT rtd_id, rth_id, rtd_quote, rtd_plan, rtd_service, rtd_loaded, 
             rtd_mode, rtd_length, rtd_stcc, rtd_benown
        FROM railtemplatedetail
       WHERE rth_id = @rth_id AND
             rtd_id = @lgh_railtemplatedetail_id
   
   SET @detail_count = 0
   SELECT @detail_count = COUNT(*)
     FROM #detail
   
   IF @detail_count > 1
   BEGIN
      SET @tender_status = 'MULDET'
      RETURN 0
   END

   IF @detail_count = 0
   BEGIN
      SET @tender_status = 'NODET'
      RETURN 0
   END
END
ELSE
BEGIN
   INSERT INTO #detail
      SELECT rtd_id, rth_id, rtd_quote, rtd_plan, rtd_service, rtd_loaded, 
             rtd_mode, rtd_length, rtd_stcc, rtd_benown
        FROM railtemplatedetail
       WHERE rth_id = @rth_id AND
             rtd_service = @service AND
             rtd_loaded = @load_empty AND
             rtd_mode = @mode AND
             rtd_length = @length AND
             rtd_benown = @ord_billto

   SET @detail_count = 0
   SELECT @detail_count = COUNT(*)
     FROM #detail

   IF @detail_count = 0
   BEGIN
      INSERT INTO #detail
         SELECT rtd_id, rth_id, rtd_quote, rtd_plan, rtd_service, rtd_loaded,
                rtd_mode, rtd_length, rtd_stcc, rtd_benown
           FROM railtemplatedetail
          WHERE rth_id = @rth_id AND
                rtd_service = @service AND
                rtd_loaded = @load_empty AND
                rtd_mode = @mode AND
                rtd_length = @length AND
               (rtd_benown = 'UNKNOWN' OR rtd_benown IS NULL)
   END

   SET @detail_count = 0
   SELECT @detail_count = COUNT(*)
     FROM #detail

   IF @detail_count > 1
   BEGIN
      SET @tender_status = 'MULDET'
      RETURN 0
   END

   IF @detail_count = 0
   BEGIN
      SET @tender_status = 'NODET'
      RETURN 0
   END
END

IF @ord_totalweight = 0
BEGIN
   SET @tender_status = 'MISINF'
   RETURN 0
END

SELECT @seal_type = ISNULL(gi_string1, 'UNK')
  FROM generalinfo
 WHERE gi_name = 'RailBillingTenderSealType'
IF @seal_type <> 'UNK'
BEGIN
   IF @ord_hdrnumber > 0
   BEGIN
      SET @seal_number = ''
      SELECT @seal_number = ISNULL(ref_number, '')
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
IF LEN(@seal_number) = 0
BEGIN
   SET @tender_status = 'MISINF'
   RETURN 0
END

SELECT @notify_type = ISNULL(gi_string1, 'UNK'),
       @notify_fax = ISNULL(gi_string2, 'UNK')
  FROM generalinfo
 WHERE gi_name = 'RailBillingTenderNotifyType'

SET @notify_party = ''
SELECT @notify_party = ref_number
  FROM referencenumber
 WHERE ref_type = @notify_type AND
       ref_table = 'orderheader' AND
       ref_tablekey = @ord_hdrnumber
IF Len(@notify_party) > 0
BEGIN
   UPDATE #header
      SET rth_notifyparty = @notify_party
END

SET @notify_faxref = ''
SELECT @notify_faxref = ref_number
  FROM referencenumber
 WHERE ref_type = @notify_fax AND
       ref_table = 'orderheader' AND
       ref_tablekey = @ord_hdrnumber
IF LEN(@notify_faxref) > 0
BEGIN
   UPDATE #header
      SET rth_notifyfax = @notify_faxref
END

SELECT @rth_notifyparty = ISNULL(rth_notifyparty, ''),
       @rth_notifyfax = ISNULL(rth_notifyfax, '')
  FROM #header
 WHERE rth_id = @rth_id

IF LEN(@rth_notifyparty) = 0
BEGIN
   SET @tender_status = 'MISINF'
   RETURN 0
END

IF LEN(@rth_notifyfax) = 0
BEGIN
   SET @tender_status = 'MISINF'
   RETURN 0
END

IF @lgh_raildispatchstatus = 'N'
BEGIN
   SET @tender_status = 'DRAERR'
   RETURN 0
END

IF LEN(@cmdstring) > 0
BEGIN
   UPDATE #detail
      SET rtd_stcc = @cmdstring
END

IF @car_204tender = 'M'
BEGIN
   SET @tender_status = 'RTD'
   RETURN 0
END

IF @car_204tender = 'A'
BEGIN
   SELECT @rtd_id = rtd_id
     FROM #detail
    WHERE rth_id = @rth_id

   UPDATE legheader
      SET lgh_railtemplatedetail_id = @rtd_id
    WHERE lgh_number = @lgh_number
 
   EXEC create_outbound204 @lgh_number, @carrier, 'ADD'
   
   INSERT INTO railbillinghistory (ord_number, lgh_number, rbh_masterbillid, car_id, rbh_origin_ramp,
                                   origin_name, origin_location, origin_zip, rbh_origin_ramp_actual,
                                   rbh_shipper, rbh_dest_ramp, dest_name, dest_location, dest_zip,
                                   rbh_dest_ramp_actual, rbh_consignee, rbh_billto, billto_name,
                                   billto_location, billto_zip, rbh_terms, rbh_loaded, rbh_type,
                                   rbh_trailer, rbh_length, rbh_weight, rbh_seal_number, rbh_benowner,
                                   rbh_quote, rbh_plan, rbh_service, rbh_stcc, rbh_tenderdate, rth_id)
      SELECT @ord_number, @lgh_number, #header.rth_masterbillid, @carrier, #header.rth_origin_ramp,
             c1.cmp_name, c1.cmp_address1, c1.cmp_zip, #header.rth_origin_ramp_actual,
             #header.rth_shipper, #header.rth_dest_ramp, c2.cmp_name, c2.cmp_address1, c2.cmp_zip,
             #header.rth_dest_ramp_actual, #header.rth_consignee, #header.rth_billto, c3.cmp_name,
             c3.cmp_address1, c3.cmp_zip, #header.rth_terms, #detail.rtd_loaded, #detail.rtd_mode, 
             @lgh_primary_trailer, #detail.rtd_length, @ord_totalweight, @seal_number, #detail.rtd_benown,
             #detail.rtd_quote, #detail.rtd_plan, #detail.rtd_service, #detail.rtd_stcc, GETDATE(), #header.rth_id
        FROM #header JOIN #detail ON #header.rth_id = #detail.rth_id
                     JOIN company c1 ON #header.rth_origin_ramp = c1.cmp_id
                     JOIN company c2 ON #header.rth_dest_ramp = c2.cmp_id
                     JOIN company c3 ON #header.rth_billto = c3.cmp_id
   	
	--PTS 82221 JJF 20140905 - soft code tender status to allow for TDA
	SELECT	@tender_status_tendered = ISNULL(gi_string2, 'TND')
	FROM	generalinfo
	WHERE	gi_name = 'Outbound204RailBilling'

	IF @tender_status_tendered = '' BEGIN
		SELECT @tender_status_tendered = 'TND'
	END
	SET @tender_status = @tender_status_tendered  

    --SET @tender_status = 'TND'  
	--END PTS 82221 JJF 20140905 - soft code tender status to allow for TDA


   RETURN 0
END

GO
GRANT EXECUTE ON  [dbo].[autorailbillingtender_sp] TO [public]
GO
