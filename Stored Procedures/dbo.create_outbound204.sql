SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[create_outbound204] @lgh_number	INT,
					@lgh_carrier	VARCHAR(8), 
					@type		VARCHAR(6)
AS
DECLARE @ord_hdrnumber			INT,
        @ord_company			VARCHAR(8),
	@ord_shipper			VARCHAR(8),
        @ord_consignee			VARCHAR(8),
        @ob_cmp_name			VARCHAR(35),
	@ob_cmp_address1		VARCHAR(35),
	@ob_cmp_address2		VARCHAR(35),
	@ob_cmp_city			VARCHAR(20),
	@ob_cmp_state			VARCHAR(6),
	@ob_cmp_zip			VARCHAR(10),
	@ob_cmp_phone			VARCHAR(20),
	@ob_cmp_contact			VARCHAR(30),
	@ob_cmp_county			VARCHAR(3),
	@sh_cmp_name			VARCHAR(35),
	@sh_cmp_address1		VARCHAR(35),
	@sh_cmp_address2		VARCHAR(35),
	@sh_cmp_city			VARCHAR(20),
	@sh_cmp_state			VARCHAR(6),
	@sh_cmp_zip			VARCHAR(10),
	@sh_cmp_phone			VARCHAR(20),
	@sh_cmp_contact			VARCHAR(30),
	@sh_cmp_county			VARCHAR(3),
	@cn_cmp_name			VARCHAR(35),
	@cn_cmp_address1		VARCHAR(35),
	@cn_cmp_address2		VARCHAR(35),
	@cn_cmp_city			VARCHAR(20),
	@cn_cmp_state			VARCHAR(6),
	@cn_cmp_zip			VARCHAR(10),
	@cn_cmp_phone			VARCHAR(20),
	@cn_cmp_contact			VARCHAR(30),
	@cn_cmp_county			VARCHAR(3),
	@car_scac			VARCHAR(4),
	@ord_number			VARCHAR(12),
	@ord_refnum			VARCHAR(30),
	@ord_revtype1			VARCHAR(6),
	@ord_terms			VARCHAR(6),
	@ord_bookdate			DATETIME,
	@ord_startdate			DATETIME,
	@ord_completiondate		DATETIME,
	@ob_204id			INT,
	@ib_990id			INT,  --PTS 33570
	@car_mileage			INT,
	@broker_linehaul_paytype	VARCHAR(30),
	@broker_fuel_paytype		VARCHAR(30),
	@broker_accessorial_paytype	VARCHAR(30),
	@car_charge			MONEY,
	@broker_linehaul		MONEY,
	@broker_fuel			MONEY,
	@broker_accessorial		MONEY,
	@broker_totalcharge		MONEY,
	@ord_remark			VARCHAR(254),
	@ord_trailer			VARCHAR(13),
	@UseEdiCode			CHAR(1),
	@brokerage_edi_basis		CHAR(1),	--PTS47736
	@lgh204status			VARCHAR(8),
	@204updateYN			CHAR(1),
	@trl_type1			VARCHAR(6),
	@ord_extrainfo11		VARCHAR(30),
	@ship_conditions		VARCHAR(30),
	@scid				INT,
	@sc_code			VARCHAR(6),
	@stp_number_start		INT,
	@stp_number_end			INT,
	@lgh_externalrating_miles	INT,
	@useRevtype			VARCHAR(8),	--PTS50435
	@start_event			VARCHAR(6),	--PTS50640 MBR 01/26/10
	@end_event			VARCHAR(6),	--PTS50640 MBR 01/26/10
	@lgh_stop_count			SMALLINT,	--PTS50640 MBR 01/26/10
	@trailer_weight			INTEGER,	--PTS40640 MBR 01/26/10
 	@edi_message_type   		VARCHAR(3),	--PTS 51808 AR  4/2/10
  	@car_type1          		VARCHAR(6),	--PTS 51808  AR  4/2/10
  	@gi_carType         		VARCHAR(6),	--PTS 51808 AR 4/2/10
  	@lgh_cmp_start      		VARCHAR(8),	--PTS 51808 AR 4/2/10
  	@lgh_cmp_end        		VARCHAR(8),	--PTS 51808 AR 4/2/10
	@lgh_railtemplatedetail_id	INTEGER,	--PTS53586 MBR 08/25/10
	@DoPreProcessSQL		CHAR(1),	--PTS54294 AR 10/07/10
        --PTS54693 MBR 11/08/10 
        @rth_id                         INTEGER,
        @rth_origin_ramp_actual         VARCHAR(30),
        @rth_shipper                    VARCHAR(8),
        @rth_dest_ramp_actual           VARCHAR(30),
        @rth_consignee                  VARCHAR(8),
        @rth_billto                     VARCHAR(8),
        @rth_notifyparty                VARCHAR(8),
        @rth_notifyfax                  VARCHAR(10),
        @rtd_quote                      VARCHAR(20),
        @rtd_plan                       VARCHAR(20),
        @rtd_service                    VARCHAR(6),
        @rtd_loaded                     VARCHAR(3),
        @rtd_mode                       VARCHAR(10),
        @rtd_length                     VARCHAR(6),
        @rtd_benown                     VARCHAR(8),
        @billto_name                    VARCHAR(100),
        @billto_nmstct                  VARCHAR(25),
        @billto_zip                     VARCHAR(10),
        @rtd_loaded_desc                VARCHAR(10),
        @rtd_service_desc               VARCHAR(30),
        @rtd_length_desc                VARCHAR(30),
        @rtd_benown_desc                VARCHAR(100),
        @rtd_sequence			INTEGER,
        @minid                          INTEGER,
        @rtr_location                   VARCHAR(6),
        @rtr_interchange_to             VARCHAR(8),
        @rtr_rule11                     CHAR(1),
        @rtr_location_desc              VARCHAR(30),
        @rtr_sequence                   INTEGER,
        @ref_type                       VARCHAR(6),
        @outbound204usebillto           CHAR(1),
        @ord_billto                     VARCHAR(8),
        @mov_number			INTEGER,
	@outbound204trltype		CHAR(1),
	@trailertype			VARCHAR(20), 
	@legcount			INTEGER,
	@legid				INTEGER,
	@cmp_start_railramp		CHAR(1),
	@cmp_end_railramp		CHAR(1),
	@lghcarrier			VARCHAR(8),
	@lgh_carrier_type		VARCHAR(6),
	@ingatenote			VARCHAR(65),
	@outgatenote			VARCHAR(65),
 	@notesequence			SMALLINT,
 	@addStopNotes		CHAR(1),
 	@stopNoteType		VARCHAR(6),
    	@lgh_primary_trl	VARCHAR(13),		-- PTS62338 DMA 4/2/2012
	@stp_mfh_sequence               INTEGER,
	@freightcount			INTEGER,
	@freight_stop_type		VARCHAR(6),
	--PTS64702 DWG 
	@Outbound204OutputPay varchar(1),
    @lgh_createapp        VARCHAR(128)
	
--PTS64209 MBR 08/10/12
CREATE TABLE #legs (
	leg_id			INT IDENTITY(1,1) NOT NULL,
	lgh_number		INTEGER NULL,
	lgh_cmp_start		VARCHAR(8) NULL,
	cmp_start_name 		VARCHAR(35) NULL,
	cmp_start_nmstct	VARCHAR(25) NULL,
	cmp_start_railramp	CHAR(1) NULL,
	lgh_cmp_end		VARCHAR(8) NULL,
	cmp_end_name		VARCHAR(35) NULL,
	cmp_end_nmstct		VARCHAR(25) NULL,
	cmp_end_railramp	CHAR(1) NULL,
	lgh_carrier		VARCHAR(8) NULL,
	car_type1		VARCHAR(6) NULL
	)

--PTS72027 MBR 09/10/13
DECLARE @freight TABLE (
	ob_204id		INTEGER,
	fgt_number		INTEGER,
	fgt_sequence		SMALLINT,
	fgt_count		DECIMAL(10,2),
	fgt_countunit		VARCHAR(6),
	fgt_weight		FLOAT,
	fgt_weightunit		VARCHAR(6),
	fgt_volume		FLOAT,
	fgt_volumeunit		VARCHAR(6),
	fgt_rate		MONEY,
	fgt_rateunit		VARCHAR(6),
	fgt_charge		MONEY,
	cmd_code		VARCHAR(8),
	fgt_description		VARCHAR(60),
	cmd_stcc		VARCHAR(8),
        cmd_haz_num		VARCHAR(20)
	)

/* PTS 33570 -- moved ob_204id to just before it is actually used
EXECUTE @ob_204id = getsystemnumber 'OB204',''
*/

--PTS 54294 Start
SELECT @DoPreProcessSQL = ISNULL(LEFT(UPPER(gi_string1), 1), 'N')
FROM	generalinfo 
WHERE 	gi_name =  'Outbound204PreProcessing'

--PTS54693 MBR 11/09/10
SELECT @Outbound204UseBillTo = ISNULL(LEFT(UPPER(gi_string1), 1), 'N')
  FROM generalinfo
 WHERE gi_name = 'Outbound204UseBillTo'

--PTS64209 MBR 08/09/12
SELECT @outbound204trltype = LEFT(gi_string1, 1)
  FROM generalinfo 
 WHERE gi_name = 'Outbound204TrlType'

--PTS72027 MBR 10/09/13
SELECT @freight_stop_type = ISNULL(UPPER(gi_string1), 'DRP')
  FROM generalinfo
 WHERE gi_name = 'RailBillingFreightStopType'

SELECT @Outbound204OutputPay = ISNULL(UPPER(gi_string1), 'N')
  FROM generalinfo
 WHERE gi_name = 'Outbound204OutputPay'


IF ISNULL(@DoPreProcessSQL,'N') = 'Y'
	EXEC outbound204_preprocess @lgh_number

--PTS 54294 End	
--PTS66497 AR 01/11/13
SELECT @addStopNotes = ISNULL(LEFT(UPPER(gi_string1), 1), 'N'),
		@stopNoteType = ISNULL(LEFT(UPPER(gi_string2),6),'DI')
	FROM generalinfo	
   WHERE gi_name = 'Outbound204_AddStopComment'
   

SELECT @ord_hdrnumber = ord_hdrnumber,
       @car_mileage = ISNULL(lgh_miles, 0),
       @car_charge = ISNULL(lgh_car_totalcharge, 0),
       @lgh_externalrating_miles = ISNULL(lgh_externalrating_miles, 0),
       @lgh204status = lgh_204status,
       @stp_number_start = stp_number_start,
       @stp_number_end = stp_number_end ,
       @lgh_cmp_start = cmp_id_start,
       @lgh_cmp_end   = cmp_id_end,
       @lgh_railtemplatedetail_id = ISNULL(lgh_railtemplatedetail_id, 0),
       @mov_number = mov_number,
       @lgh_primary_trl = lgh_primary_trailer,
       @lgh_createapp = lgh_createapp
  FROM legheader
 WHERE lgh_number = @lgh_number

IF ((@lgh_createapp = '.LT') or (@lgh_createapp = 'LTL OE'))
BEGIN
   RETURN;
END

IF @lgh_externalrating_miles > 0
BEGIN
   SET @car_mileage = @lgh_externalrating_miles
END

IF @type = 'CANCEL'
BEGIN
   SET @car_charge = 0
END

--51808
SELECT @gi_carType = UPPER(LEFT(gi_string1,6))
FROM generalinfo 
WHERE gi_name  = 'Outbound404CarrierType'

SELECT @204UpdateYN = gi_string3
  FROM generalinfo
 WHERE gi_name = 'ProcessOutbound204'

-- PTS 33570 -- start block; moved car_scac higher, uses it to check if carrier sent a decline 990 to prevent cancellation 204
SELECT @car_scac = car_scac ,@car_type1 = car_type1
  FROM carrier
 WHERE car_id = @lgh_carrier

IF @type = 'CANCEL'
BEGIN
	SELECT @ib_990id = MAX(trn_id) 
	  FROM edi_inbound990_records
	 WHERE ord_hdrnumber = @ord_hdrnumber
	   AND SCAC = @car_scac

	IF ISNULL(@ib_990id,0) > 0
	BEGIN
		IF (SELECT Count(1) FROM edi_inbound990_records WHERE trn_id = @ib_990id and Action = 'D') > 0
			RETURN
	END
END
-- PTS 33570 -- end block

--PTS 50435
SELECT @useRevtype = ISNULL(LEFT(UPPER(gi_string1),8),'REVTYPE1')
  FROM generalinfo
  WHERE gi_name = 'Outbound204Revtype'

SELECT @ord_company = ord_company,
       @ord_shipper = ord_shipper,
       @ord_consignee = ord_consignee,
       @ord_number = ord_number,
       @ord_refnum = ord_refnum,
       @ord_revtype1 =  CASE @useRevtype 
                           WHEN 'REVTYPE1' THEN ord_revtype1
                           WHEN 'REVTYPE2' THEN ord_revtype2
                           WHEN 'REVTYPE3' THEN ord_revtype3
                           WHEN 'REVTYPE4' THEN ord_revtype4
                           ELSE 'REVTYPE1' 
                        END,
       @ord_terms = ord_terms,
       @ord_bookdate = ord_bookdate,
       @ord_startdate = ord_startdate,
       @ord_completiondate = ord_completiondate,
       @ord_remark = replace(ord_remark,char(13)+char(10),char(32)),
       @ord_trailer = ord_trailer, --PTS44968 MBR 03/09/09
       @trl_type1 = trl_type1,
       @ord_extrainfo11 = ord_extrainfo11,
       @ord_billto = ord_billto
  FROM orderheader
 WHERE ord_hdrnumber = @ord_hdrnumber

--PTS64209 MBR 08/09/12
IF @outbound204TrlType IS NOT NULL AND @outbound204trltype <> '' AND @ord_trailer <> 'UNKNOWN'
BEGIN
   IF @outbound204TrlType = '1'
   BEGIN
      SELECT @trailertype = name
        FROM labelfile 
       WHERE labeldefinition = 'TrlType1' AND
             abbr = (SELECT trl_type1
                       FROM trailerprofile
                      WHERE trl_id = @ord_trailer)
   END
   IF @outbound204TrlType = '2'
   BEGIN
      SELECT @trailertype = name
        FROM labelfile 
       WHERE labeldefinition = 'TrlType2' AND
             abbr = (SELECT trl_type2
                       FROM trailerprofile
                      WHERE trl_id = @ord_trailer)
   END
   IF @outbound204TrlType = '3'
   BEGIN
      SELECT @trailertype = name
        FROM labelfile 
       WHERE labeldefinition = 'TrlType3' AND
             abbr = (SELECT trl_type3
                       FROM trailerprofile
                      WHERE trl_id = @ord_trailer)
   END
   IF @outbound204TrlType = '4'
   BEGIN
      SELECT @trailertype = name
        FROM labelfile 
       WHERE labeldefinition = 'TrlType4' AND
             abbr = (SELECT trl_type4
                       FROM trailerprofile
                      WHERE trl_id = @ord_trailer)
   END
END

--PTS54693 MBR 11/09/10
IF @Outbound204UseBillTo = 'Y'
BEGIN
   SET @ord_company = @ord_billto
END

-- PLIU 8/31/09 --Trailer type 1 will pull the EDI Code instead of abbr in the TrlType1 label file    
--PTS 79395 AP/JJF 20140618
--SELECT @trl_type1 = ISNULL(edicode, abbr)    
SELECT @trl_type1 = isnull(nullif(edicode, '') ,abbr)  FROM labelfile
 WHERE labeldefinition = 'TrlType1' AND
       abbr = @trl_type1

--PTS45507 MBR 03/09/09
SELECT @UseEdiCode = ISNULL(LEFT(UPPER(gi_string1), 1), 'N')
  FROM generalinfo
 WHERE gi_name = 'OutboundRevType1UseEdiCode'
IF @useEdiCode = 'Y'
BEGIN
   SELECT @ord_revtype1 = ISNULL(edicode, ' ')
     FROM labelfile
    WHERE labeldefinition = @useRevtype AND --'RevType1' AND
          abbr = @ord_revtype1
END

--PTS 47736 AR 06.04.09
SELECT @brokerage_edi_basis =  ISNULL(LEFT(UPPER(gi_string1),1),'O')
  FROM	generalinfo
  WHERE	gi_name = 'BrokerageEDIBasis'

SELECT @ob_cmp_name = SUBSTRING(company.cmp_name, 1, 35),
       @ob_cmp_address1 = SUBSTRING(company.cmp_address1, 1, 35),
       @ob_cmp_address2 = SUBSTRING(company.cmp_address2, 1, 35),
       @ob_cmp_city = city.cty_name,
       @ob_cmp_state = city.cty_state,
       @ob_cmp_zip = company.cmp_zip,
       @ob_cmp_phone = company.cmp_primaryphone,
       @ob_cmp_contact = company.cmp_contact,
       @ob_cmp_county = city.cty_county
  FROM company, city
 WHERE company.cmp_id = @ord_company AND
       company.cmp_city = city.cty_code

--PTS42845 MBR 01/11/10
IF @ord_shipper = 'UNKNOWN'
BEGIN
   SELECT @sh_cmp_name = SUBSTRING(stops.cmp_name, 1, 35), 						
          @sh_cmp_address1 = SUBSTRING(stops.stp_address, 1, 35),
          @sh_cmp_address2 = SUBSTRING(stops.stp_address2, 1, 35),
          @sh_cmp_city = city.cty_name,
          @sh_cmp_state = city.cty_state,
          @sh_cmp_zip = stops.stp_zipcode,
          @sh_cmp_county = city.cty_county,
          @sh_cmp_phone = stops.stp_phonenumber,
          @sh_cmp_contact = stops.stp_contact
     FROM stops, city
    WHERE stp_number = @stp_number_start AND
          stops.stp_city = city.cty_code
END
ELSE
BEGIN
   SELECT @sh_cmp_name = SUBSTRING(company.cmp_name, 1, 35),
          @sh_cmp_address1 = SUBSTRING(company.cmp_address1, 1, 35),
          @sh_cmp_address2 = SUBSTRING(company.cmp_address2, 1, 35),
          @sh_cmp_city = city.cty_name,
          @sh_cmp_state = city.cty_state,
          @sh_cmp_zip = company.cmp_zip,
          @sh_cmp_county = city.cty_county
     FROM company, city
    WHERE company.cmp_id = @ord_shipper AND
          company.cmp_city = city.cty_code

   SELECT @sh_cmp_phone = stops.stp_phonenumber,
          @sh_cmp_contact = stops.stp_contact
     FROM stops
    WHERE stp_number = @stp_number_start
END

IF @ord_consignee = 'UNKNOWN'
BEGIN
   SELECT @cn_cmp_name = SUBSTRING(stops.cmp_name, 1, 35),
          @cn_cmp_address1 = SUBSTRING(stops.stp_address, 1, 35),
          @cn_cmp_address2 = SUBSTRING(stops.stp_address2, 1, 35),
          @cn_cmp_city = city.cty_name,
          @cn_cmp_state = city.cty_state,
          @cn_cmp_zip = stops.stp_zipcode,
          @cn_cmp_county = city.cty_county,
          @cn_cmp_phone = stops.stp_phonenumber,
          @cn_cmp_contact = stops.stp_contact
  FROM stops, city
 WHERE stp_number = @stp_number_end AND
       stops.stp_city = city.cty_code
END
ELSE
BEGIN
   SELECT @cn_cmp_name = SUBSTRING(company.cmp_name, 1, 35),
          @cn_cmp_address1 = SUBSTRING(company.cmp_address1, 1, 35),
          @cn_cmp_address2 = SUBSTRING(company.cmp_address2, 1, 35),
          @cn_cmp_city = city.cty_name,
          @cn_cmp_state = city.cty_state,
          @cn_cmp_zip = company.cmp_zip,
          @cn_cmp_county = city.cty_county
     FROM company, city
    WHERE company.cmp_id = @ord_consignee AND
          company.cmp_city = city.cty_code

   SELECT @cn_cmp_phone = stops.stp_phonenumber,
          @cn_cmp_contact = stops.stp_contact
     FROM stops
    WHERE stp_number = @stp_number_end
END
--PTS 51808 determine message type based on leg origin and dest/car_type1
 IF((select isnull(cmp_port,'N') from company where cmp_id = @lgh_cmp_start)='Y' OR (select isnull(cmp_railramp,'N') from company where cmp_id = @lgh_cmp_start) = 'Y') AND 
    ((select isnull(cmp_port,'N') from company where cmp_id = @lgh_cmp_end)='Y' OR (select isnull(cmp_railramp,'N') from company where cmp_id = @lgh_cmp_end) = 'Y') AND @car_type1 = @gi_CarType
    SELECT @edi_message_type = '404'
 ELSE
    SELECT @edi_message_type = '204'

--end 51808
        
--PTS42845 MBR 01/11/10
SET @scid = 0
WHILE 1=1
BEGIN
   SELECT @scid = MIN(sc_id)
     FROM ship_conditions
    WHERE lgh_number = @lgh_number AND
          sc_id > @scid

   IF @scid IS NULL
      BREAK

   SELECT @sc_code = RTRIM(sc_code)
     FROM ship_conditions
    WHERE sc_id = @scid

   IF LEN(@ship_conditions) > 0
      SET @ship_conditions = @ship_conditions + ',' + @sc_code
   ELSE
      SET @ship_conditions = @sc_code

END

--PTS38879 MBR 08/28/07
SELECT @broker_linehaul_paytype = ISNULL(gi_string1, 'BRKLH')
  FROM generalinfo
 WHERE gi_name = 'BrokerLinehaulPayType'

SELECT @broker_linehaul = ISNULL(SUM(pyd_amount), 0)
  FROM paydetail
 WHERE asgn_type = 'CAR' AND
       asgn_id = @lgh_carrier AND
       lgh_number = @lgh_number AND
       pyt_itemcode = @broker_linehaul_paytype

SELECT @broker_fuel_paytype = ISNULL(gi_string1, 'BRKFC')
  FROM generalinfo
 WHERE gi_name = 'BrokerFuelCostPayType'

SELECT @broker_fuel = ISNULL(SUM(pyd_amount), 0)
  FROM paydetail
 WHERE asgn_type = 'CAR' AND
       asgn_id = @lgh_carrier AND
       lgh_number = @lgh_number AND
       pyt_itemcode = @broker_fuel_paytype

SELECT @broker_accessorial_paytype = ISNULL(gi_string1, 'BRKACC')
  FROM generalinfo
 WHERE gi_name = 'BrokerAccessorialCostPayType'

SELECT @broker_accessorial = ISNULL(SUM(pyd_amount), 0)
  FROM paydetail
 WHERE asgn_type = 'CAR' AND
       asgn_id = @lgh_carrier AND
       lgh_number = @lgh_number AND
       pyt_itemcode = @broker_accessorial_paytype

SET @broker_totalcharge = @broker_linehaul + @broker_fuel + @broker_accessorial

/*PTS 33570 -- move car_scac lookup higher and ob_204id lower
SELECT @car_scac = car_scac
  FROM carrier
 WHERE car_id = @lgh_carrier
*/

EXECUTE @ob_204id = getsystemnumber 'OB204',''

IF @type = 'ADD'
BEGIN
	INSERT INTO edi_outbound204_order (ob_204id, ord_number, ord_hdrnumber, ord_refnumber, ord_revtype1,
	                                   ord_bookdate, ord_startdate, ord_completiondate, ob_cmp_id,
	                                   ob_name, ob_address1, ob_address2, ob_city, ob_state, ob_zip,
	                                   sh_cmp_id, sh_name, sh_address1, sh_address2, sh_city, sh_state,
	                                   sh_zip, cn_cmp_id, cn_name, cn_address1, cn_address2, cn_city,
	                                   cn_state, cn_zip, car_id, ord_terms, car_edi_scac, created_dt,
	                                   edi_code, process_status, car_mileage, car_charge,
                                           broker_linehaul_charge, broker_fuel_charge, broker_accessorial_charge,
                                           broker_total_charge, ord_remark, sh_phone, sh_contact, sh_county, 
                                           cn_phone, cn_contact, cn_county, trl_type1, ord_extrainfo11,
                                           ship_conditions, ob_phone, ob_contact, ob_county, lgh_number,
                                           edi_message_type, rtd_id)
	                          VALUES  (@ob_204id, @ord_number, @ord_hdrnumber, @ord_refnum, @ord_revtype1,
	                                   @ord_bookdate, @ord_startdate, @ord_completiondate, @ord_company,
	                                   @ob_cmp_name, @ob_cmp_address1, @ob_cmp_address2, @ob_cmp_city,
	                                   @ob_cmp_state, @ob_cmp_zip, @ord_shipper, @sh_cmp_name,
	                                   @sh_cmp_address1, @sh_cmp_address2, @sh_cmp_city, @sh_cmp_state,
	                                   @sh_cmp_zip, @ord_consignee, @cn_cmp_name, @cn_cmp_address1,
	                                   @cn_cmp_address2, @cn_cmp_city, @cn_cmp_state, @cn_cmp_zip,
	                                   @lgh_carrier, @ord_terms, @car_scac, GETDATE(), '00', 'N',
                                           @car_mileage, @car_charge, @broker_linehaul, @broker_fuel,
                                           @broker_accessorial, @broker_totalcharge, @ord_remark, @sh_cmp_phone, 
                                           @sh_cmp_contact, @sh_cmp_county, @cn_cmp_phone, @cn_cmp_contact, 
                                           @cn_cmp_county, @trl_type1, @ord_extrainfo11, @ship_conditions, 
                                           @ob_cmp_phone, @ob_cmp_contact, @ob_cmp_county, @lgh_number,
                                           @edi_message_type, @lgh_railtemplatedetail_id)
END

IF @type = 'CANCEL'
BEGIN
	INSERT INTO edi_outbound204_order (ob_204id, ord_number, ord_hdrnumber, ord_refnumber, ord_revtype1,
	                                   ord_bookdate, ord_startdate, ord_completiondate, ob_cmp_id,
	                                   ob_name, ob_address1, ob_address2, ob_city, ob_state, ob_zip,
	                                   sh_cmp_id, sh_name, sh_address1, sh_address2, sh_city, sh_state,
	                                   sh_zip, cn_cmp_id, cn_name, cn_address1, cn_address2, cn_city,
	                                   cn_state, cn_zip, car_id, ord_terms, car_edi_scac, created_dt,
	                                   edi_code, process_status, car_mileage, car_charge,
                                           broker_linehaul_charge, broker_fuel_charge, broker_accessorial_charge,
                                           broker_total_charge, ord_remark, sh_phone, sh_contact, sh_county, 
                                           cn_phone, cn_contact, cn_county, trl_type1, ord_extrainfo11,
                                           ship_conditions, ob_phone, ob_contact, ob_county, lgh_number,
                                           edi_message_type, rtd_id)
	                          VALUES  (@ob_204id, @ord_number, @ord_hdrnumber, @ord_refnum, @ord_revtype1,
	                                   @ord_bookdate, @ord_startdate, @ord_completiondate, @ord_company,
	                                   @ob_cmp_name, @ob_cmp_address1, @ob_cmp_address2, @ob_cmp_city,
	                                   @ob_cmp_state, @ob_cmp_zip, @ord_shipper, @sh_cmp_name,
	                                   @sh_cmp_address1, @sh_cmp_address2, @sh_cmp_city, @sh_cmp_state,
	                                   @sh_cmp_zip, @ord_consignee, @cn_cmp_name, @cn_cmp_address1,
	                                   @cn_cmp_address2, @cn_cmp_city, @cn_cmp_state, @cn_cmp_zip,
	                                   @lgh_carrier, @ord_terms, @car_scac, GETDATE(), '01', 'N',
                                           @car_mileage, @car_charge, @broker_linehaul, @broker_fuel,
                                           @broker_accessorial, @broker_totalcharge, @ord_remark, @sh_cmp_phone, 
                                           @sh_cmp_contact, @sh_cmp_county, @cn_cmp_phone, @cn_cmp_contact, 
                                           @cn_cmp_county, @trl_type1, @ord_extrainfo11, @ship_conditions, 
                                           @ob_cmp_phone, @ob_cmp_contact, @ob_cmp_county, @lgh_number,
                                           @edi_message_type, @lgh_railtemplatedetail_id)
END

IF @type = 'CHANGE' AND (((@204UpdateYN <> 'N') OR (@204UpdateYN is NULL)) OR
    (@204UpdateYN = 'N' and @Lgh204Status = 'TDA'))
BEGIN
	INSERT INTO edi_outbound204_order (ob_204id, ord_number, ord_hdrnumber, ord_refnumber, ord_revtype1,
	                                   ord_bookdate, ord_startdate, ord_completiondate, ob_cmp_id,
	                                   ob_name, ob_address1, ob_address2, ob_city, ob_state, ob_zip,
	                                   sh_cmp_id, sh_name, sh_address1, sh_address2, sh_city, sh_state,
	                                   sh_zip, cn_cmp_id, cn_name, cn_address1, cn_address2, cn_city,
	                                   cn_state, cn_zip, car_id, ord_terms, car_edi_scac, created_dt,
	                                   edi_code, process_status, car_mileage, car_charge,
                                           broker_linehaul_charge, broker_fuel_charge, broker_accessorial_charge,
                                           broker_total_charge, ord_remark,sh_phone, sh_contact, sh_county, 
                                           cn_phone, cn_contact, cn_county, trl_type1, ord_extrainfo11,
                                           ship_conditions, ob_phone, ob_contact, ob_county, lgh_number,
                                           edi_message_type, rtd_id)
	                          VALUES  (@ob_204id, @ord_number, @ord_hdrnumber, @ord_refnum, @ord_revtype1,
	                                   @ord_bookdate, @ord_startdate, @ord_completiondate, @ord_company,
	                                   @ob_cmp_name, @ob_cmp_address1, @ob_cmp_address2, @ob_cmp_city,
	                                   @ob_cmp_state, @ob_cmp_zip, @ord_shipper, @sh_cmp_name,
	                                   @sh_cmp_address1, @sh_cmp_address2, @sh_cmp_city, @sh_cmp_state,
	                                   @sh_cmp_zip, @ord_consignee, @cn_cmp_name, @cn_cmp_address1,
	                                   @cn_cmp_address2, @cn_cmp_city, @cn_cmp_state, @cn_cmp_zip,
	                                   @lgh_carrier, @ord_terms, @car_scac, GETDATE(), '04', 'N',
                                           @car_mileage, @car_charge, @broker_linehaul, @broker_fuel,
                                           @broker_accessorial, @broker_totalcharge, @ord_remark, @sh_cmp_phone, 
                                           @sh_cmp_contact, @sh_cmp_county, @cn_cmp_phone, @cn_cmp_contact, 
                                           @cn_cmp_county, @trl_type1, @ord_extrainfo11, @ship_conditions, 
                                           @ob_cmp_phone, @ob_cmp_contact, @ob_cmp_county, @lgh_number,
                                           @edi_message_type, @lgh_railtemplatedetail_id)
END

--PTS64702 DWG 10/12/13 Insert Pay Detail records
if @Outbound204OutputPay = 'Y'
	INSERT INTO edi_outbound204_paydetail (	ob_204id, lgh_number, ord_hdrnumber, 
											pyd_number, asgn_id, pyt_itemcode, pyd_description, 
											pyd_quantity, pyd_unit, pyd_rate, pyd_rateunit, pyd_amount)
		SELECT	@ob_204id, lgh_number, @ord_hdrnumber, 
				pyd_number, asgn_id, pyt_itemcode, pyd_description, 
				pyd_quantity, pyd_unit, pyd_rate, pyd_rateunit, pyd_amount
		  FROM paydetail
		 WHERE asgn_type = 'CAR' AND
			   asgn_id = @lgh_carrier AND
			   lgh_number = @lgh_number 

--PTS44968 MBR 03/09/09 Added the trailer to the stop insert
--PTS64209 MBR 08/09/12 Added the trailer type to the stop insert 
INSERT INTO edi_outbound204_stops (ob_204id, ord_hdrnumber, stp_number, cmp_id, cmp_name, cmp_address1, 
                                   cmp_address2, cmp_city, cmp_state, cmp_zip, stp_sequence, stp_event, 
                                   stp_weight, stp_weightunit, stp_count, stp_countunit, stp_volume, 
                                   stp_volumeunit, stp_arrivaldate, stp_departuredate, stp_schdtearliest, 
                                   stp_schdtlatest, cmp_phone, cmp_contact, cmp_county, stp_trailer1, 
                                   stp_trailertype)
   SELECT @ob_204id, stops.ord_hdrnumber, stops.stp_number, stops.cmp_id, stops.cmp_name, 
          stops.stp_address, stops.stp_address2, city.cty_name, city.cty_state,stops.stp_zipcode, stops.stp_mfh_sequence, 
          stops.stp_event, (SELECT SUM(ISNULL(fgt_weight, 0)) 
                              FROM freightdetail 
                             WHERE freightdetail.stp_number = stops.stp_number),
          stops.stp_weightunit, (SELECT SUM(ISNULL(fgt_count, 0))
                                   FROM freightdetail
                                  WHERE freightdetail.stp_number = stops.stp_number),
          stops.stp_countunit, (SELECT SUM(ISNULL(fgt_volume, 0))
                                  FROM freightdetail
                                 WHERE freightdetail.stp_number = stops.stp_number),
          stops.stp_volumeunit, stops.stp_arrivaldate, stops.stp_departuredate, stops.stp_schdtearliest, 
          stops.stp_schdtlatest, stops.stp_phonenumber, stops.stp_contact, city.cty_county, @lgh_primary_trl, 
          @trailertype
     FROM stops, city
    WHERE stops.lgh_number = @lgh_number AND
          stops.stp_city = city.cty_code

--PTS50640 MBR 01/26/10
SELECT @start_event = stops1.stp_event,
       @end_event = stops2.stp_event
  FROM legheader JOIN stops stops1 ON legheader.stp_number_start = stops1.stp_number
                 JOIN stops stops2 ON legheader.stp_number_end = stops2.stp_number
 WHERE legheader.lgh_number = @lgh_number
SET @lgh_stop_count = 0
SELECT @lgh_stop_count = Count(*)
  FROM stops
 WHERE lgh_number = @lgh_number
IF ((@start_event = 'BMT' OR @start_event = 'IBMT') AND
   (@end_event = 'EMT' OR @end_event = 'IEMT')) AND
    @lgh_stop_count = 2 AND @lgh_primary_trl <> 'UNKNOWN'
BEGIN
   SELECT @trailer_weight = ISNULL(trl_mtwgt, 0)
     FROM trailerprofile
    WHERE trl_id = @lgh_primary_trl
   UPDATE edi_outbound204_stops
      SET stp_weight = @trailer_weight
    WHERE ob_204id = @ob_204id
END
          
--PTS72027 MBR 09/10/13
SELECT @legcount = COUNT(*)
  FROM legheader
 WHERE mov_number = @mov_number

IF @legcount = 1
BEGIN
   INSERT INTO edi_outbound204_fgt (ob_204id, ord_hdrnumber, stp_number, fgt_number, fgt_sequence, 
                                    fgt_count, fgt_countunit, fgt_weight, fgt_weightunit, fgt_volume, 
                                    fgt_volumeunit, fgt_rate, fgt_rateunit, fgt_charge, cmd_code, 
                                    fgt_description,commodity_stcc, cmd_haz_num)
      SELECT @ob_204id, @ord_hdrnumber, fgt.stp_number, fgt.fgt_number, fgt.fgt_sequence, fgt.fgt_count, 
             fgt.fgt_countunit, fgt.fgt_weight, fgt.fgt_weightunit, fgt.fgt_volume, fgt.fgt_volumeunit, 
             fgt.fgt_rate, fgt.fgt_rateunit, fgt.fgt_charge, fgt.cmd_code, fgt.fgt_description,cmd.cmd_stcc,
             cmd.cmd_haz_num
        FROM freightdetail fgt, stops, commodity cmd
       WHERE stops.lgh_number = @lgh_number AND
             stops.stp_number = fgt.stp_number AND 
             fgt.cmd_code = cmd.cmd_code
END
IF @legcount > 1
BEGIN
   IF @freight_stop_type = 'DRP'
   BEGIN
      SELECT @stp_mfh_sequence = stp_mfh_sequence
        FROM stops 
       WHERE stp_number = @stp_number_start
   
      INSERT INTO @freight
         SELECT @ob_204id, fgt.fgt_number, fgt.fgt_sequence, fgt.fgt_count, fgt.fgt_countunit, fgt.fgt_weight, 
                fgt.fgt_weightunit, fgt.fgt_volume, fgt.fgt_volumeunit, fgt.fgt_rate, fgt.fgt_rateunit, fgt.fgt_charge, 
                fgt.cmd_code, fgt.fgt_description, commodity.cmd_stcc, commodity.cmd_haz_num
           FROM freightdetail fgt JOIN commodity ON fgt.cmd_code = commodity.cmd_code 
          WHERE fgt.stp_number IN (SELECT stp_number
                                     FROM stops
                                    WHERE mov_number = @mov_number AND
                                          ord_hdrnumber > 0 AND
                                          stp_type = 'DRP' AND
                                          stp_mfh_sequence >= @stp_mfh_sequence) AND
                fgt.cmd_code <> 'UNKNOWN'
   END
   IF @freight_stop_type = 'PUP'
   BEGIN
      SELECT @stp_mfh_sequence = stp_mfh_sequence
        FROM stops 
       WHERE stp_number = @stp_number_end
   
      INSERT INTO @freight
         SELECT @ob_204id, fgt.fgt_number, fgt.fgt_sequence, fgt.fgt_count, fgt.fgt_countunit, fgt.fgt_weight, 
                fgt.fgt_weightunit, fgt.fgt_volume, fgt.fgt_volumeunit, fgt.fgt_rate, fgt.fgt_rateunit, fgt.fgt_charge, 
                fgt.cmd_code, fgt.fgt_description, commodity.cmd_stcc, commodity.cmd_haz_num
           FROM freightdetail fgt JOIN commodity ON fgt.cmd_code = commodity.cmd_code 
          WHERE fgt.stp_number IN (SELECT stp_number
                                     FROM stops
                                    WHERE mov_number = @mov_number AND
                                          ord_hdrnumber > 0 AND
                                          stp_type = 'PUP' AND
                                          stp_mfh_sequence <= @stp_mfh_sequence) AND
                fgt.cmd_code <> 'UNKNOWN'
   END

   SET @freightcount = 0
   SELECT @freightcount = COUNT(*)
     FROM @freight
   IF @freightcount > 0
   BEGIN
      INSERT INTO edi_outbound204_fgt (ob_204id, ord_hdrnumber, stp_number, fgt_number, fgt_sequence,
                                       fgt_count, fgt_countunit, fgt_weight, fgt_weightunit, fgt_volume,
                                       fgt_volumeunit, fgt_rate, fgt_rateunit, fgt_charge, cmd_code,
                                       fgt_description, commodity_stcc, cmd_haz_num)
         SELECT s.ob_204id, s.ord_hdrnumber, s.stp_number, f.fgt_number, f.fgt_sequence,
                f.fgt_count, f.fgt_countunit, f.fgt_weight, f.fgt_weightunit, f.fgt_volume,
                f.fgt_volumeunit, f.fgt_rate, f.fgt_rateunit, f.fgt_charge, f.cmd_code,
                f.fgt_description, f.cmd_stcc, f.cmd_haz_num
           FROM edi_outbound204_stops s JOIN @freight f ON s.ob_204id = f.ob_204id
          WHERE s.ob_204id = @ob_204id
         ORDER BY s.stp_sequence
   END
   ELSE
   BEGIN
      INSERT INTO edi_outbound204_fgt (ob_204id, ord_hdrnumber, stp_number, fgt_number, fgt_sequence, 
                                       fgt_count, fgt_countunit, fgt_weight, fgt_weightunit, fgt_volume, 
                                       fgt_volumeunit, fgt_rate, fgt_rateunit, fgt_charge, cmd_code, 
                                       fgt_description,commodity_stcc, cmd_haz_num)
         SELECT @ob_204id, @ord_hdrnumber, fgt.stp_number, fgt.fgt_number, fgt.fgt_sequence, fgt.fgt_count, 
                fgt.fgt_countunit, fgt.fgt_weight, fgt.fgt_weightunit, fgt.fgt_volume, fgt.fgt_volumeunit, 
                fgt.fgt_rate, fgt.fgt_rateunit, fgt.fgt_charge, fgt.cmd_code, fgt.fgt_description,cmd.cmd_stcc,
                cmd.cmd_haz_num
           FROM freightdetail fgt, stops, commodity cmd
          WHERE stops.lgh_number = @lgh_number AND
                stops.stp_number = fgt.stp_number AND 
                fgt.cmd_code = cmd.cmd_code
   END
END
          
INSERT INTO edi_outbound204_notes (ob_204id, ord_hdrnumber, not_sentby, ntb_table, nre_tablekey, 
                                   not_type, not_sequence, not_text)
   SELECT @ob_204id, nre_tablekey, not_sentby, ntb_table, nre_tablekey, not_type, not_sequence, not_text
     FROM notes
    WHERE ntb_table = 'orderheader' AND
          nre_tablekey = CONVERT(VARCHAR(18), @ord_hdrnumber) AND
          /*PTS29060 MBR 07/25/05*/
          /*PTS33934 MBR 07/31/06*/
         (not_type = 'E' or not_type = 'CA') AND
          ISNULL(not_text, '') <> '' --PTS 60964 PSL 01.12.2012

--PTS64209 MBR 08/10/12  Get ingate and outgate info for the rail leg
INSERT INTO #legs (lgh_number, lgh_cmp_start, cmp_start_name, cmp_start_nmstct, cmp_start_railramp,
                   lgh_cmp_end, cmp_end_name, cmp_end_nmstct, cmp_end_railramp, lgh_carrier, car_type1)
   SELECT lgh_number, cmp_id_start, SUBSTRING(c1.cmp_name,1,35), c1.cty_nmstct, ISNULL(c1.cmp_railramp, 'N'), cmp_id_end, 
          SUBSTRING(c2.cmp_name,1,35), c2.cty_nmstct, ISNULL(c2.cmp_railramp, 'N'), lgh_carrier, ISNULL(car_type1, 'UNK')
     FROM legheader JOIN company c1 ON legheader.cmp_id_start = c1.cmp_id
                    JOIN company c2 ON legheader.cmp_id_end = c2.cmp_id
                    JOIN carrier ON legheader.lgh_carrier = carrier.car_id
    WHERE legheader.mov_number = @mov_number
   ORDER BY lgh_startdate

SELECT @legcount = COUNT(*)
  FROM #legs

IF @legcount > 0 
BEGIN
   SELECT @legid = leg_id,
          @cmp_start_railramp = cmp_start_railramp,
          @cmp_end_railramp = cmp_end_railramp,
          @lghcarrier = lgh_carrier,
          @lgh_carrier_type = car_type1
     FROM #legs
    WHERE lgh_number = @lgh_number
   
   --Get the ingate and outgate info from the next rail segment
   IF @cmp_start_railramp = 'N' and @cmp_end_railramp = 'Y'
   BEGIN
      SELECT @notesequence = ISNULL(MAX(not_sequence), 0)
        FROM edi_outbound204_notes
       WHERE ob_204id = @ob_204id

      SELECT @ingatenote = 'Next Ingate: ' + cmp_start_name + '-' + cmp_start_nmstct,
             @outgatenote = 'Next Outgate: ' + cmp_end_name + '-' + cmp_end_nmstct
        FROM #legs 
       WHERE leg_id = @legid + 1

      IF @ingatenote IS NOT NULL and @ingatenote <> ''
      BEGIN
         INSERT INTO edi_outbound204_notes (ob_204id, ord_hdrnumber, ntb_table, not_type, nre_tablekey, 
                                            not_sequence, not_text)
                                    VALUES (@ob_204id, @ord_hdrnumber, 'orderheader', 'CA', 
                                           @ord_hdrnumber, @notesequence + 1, @ingatenote)
      END
      IF @outgatenote IS NOT NULL AND @outgatenote <> ''
      BEGIN
         INSERT INTO edi_outbound204_notes (ob_204id, ord_hdrnumber, ntb_table, not_type, nre_tablekey, 
                                            not_sequence, not_text)
                                    VALUES (@ob_204id, @ord_hdrnumber, 'orderheader', 'CA', 
                                            @ord_hdrnumber, @notesequence + 2, @outgatenote)
      END
   END

   --Get the ingate and outgate info from the previous rail segment
   IF @cmp_start_railramp = 'Y' and @cmp_end_railramp = 'N'
   BEGIN
      SELECT @notesequence = ISNULL(MAX(not_sequence), 0)
        FROM edi_outbound204_notes
       WHERE ob_204id = @ob_204id

      SELECT @ingatenote = 'Prev Ingate: ' + cmp_start_name + '-' + cmp_start_nmstct,
             @outgatenote = 'Prev Outgate: ' + cmp_end_name + '-' + cmp_end_nmstct
        FROM #legs 
       WHERE leg_id = @legid - 1

      IF @ingatenote IS NOT NULL and @ingatenote <> ''
      BEGIN
         INSERT INTO edi_outbound204_notes (ob_204id, ord_hdrnumber, ntb_table, not_type, nre_tablekey,
                                            not_sequence, not_text)
                                    VALUES (@ob_204id, @ord_hdrnumber, 'orderheader', 'CA', 
                                            @ord_hdrnumber, @notesequence + 1, @ingatenote)
      END
      IF @outgatenote IS NOT NULL AND @outgatenote <> ''
      BEGIN
         INSERT INTO edi_outbound204_notes (ob_204id, ord_hdrnumber, ntb_table, not_type, nre_tablekey,
                                            not_sequence, not_text)
                                    VALUES (@ob_204id, @ord_hdrnumber, 'orderheader', 'CA',
                                            @ord_hdrnumber, @notesequence + 2, @outgatenote)
      END
   END
   --Get the ingate and outgate info from the previous and next rail segments
   IF @cmp_start_railramp = 'Y' and @cmp_end_railramp = 'Y' and @lgh_carrier_type <> 'RAL'
   BEGIN
      SELECT @notesequence = ISNULL(MAX(not_sequence), 0)
        FROM edi_outbound204_notes
       WHERE ob_204id = @ob_204id

      SELECT @ingatenote = 'Prev Ingate: ' + cmp_start_name + '-' + cmp_start_nmstct,
             @outgatenote = 'Prev Outgate: ' + cmp_end_name + '-' + cmp_end_nmstct
        FROM #legs 
       WHERE leg_id = @legid - 1

      IF @ingatenote IS NOT NULL and @ingatenote <> ''
      BEGIN
         INSERT INTO edi_outbound204_notes (ob_204id, ord_hdrnumber, ntb_table, not_type, nre_tablekey,
                                            not_sequence, not_text)
                                    VALUES (@ob_204id, @ord_hdrnumber, 'orderheader', 'CA', 
                                            @ord_hdrnumber, @notesequence + 1, @ingatenote)
      END
      IF @outgatenote IS NOT NULL AND @outgatenote <> ''
      BEGIN
         INSERT INTO edi_outbound204_notes (ob_204id, ord_hdrnumber, ntb_table, not_type, nre_tablekey,
                                            not_sequence, not_text)
                                    VALUES (@ob_204id, @ord_hdrnumber, 'orderheader', 'CA',
                                            @ord_hdrnumber, @notesequence + 2, @outgatenote)
      END

	SET @ingatenote = ''	--64738
	SET @outgatenote = ''
		
      SELECT @notesequence = ISNULL(MAX(not_sequence), 0)
        FROM edi_outbound204_notes
       WHERE ob_204id = @ob_204id

      SELECT @ingatenote = 'Next Ingate: ' + cmp_start_name + '-' + cmp_start_nmstct,
             @outgatenote = 'Next Outgate: ' + cmp_end_name + '-' + cmp_end_nmstct
        FROM #legs 
       WHERE leg_id = @legid + 1

      IF @ingatenote IS NOT NULL and @ingatenote <> ''
      BEGIN
         INSERT INTO edi_outbound204_notes (ob_204id, ord_hdrnumber, ntb_table, not_type, nre_tablekey, 
                                            not_sequence, not_text)
                                    VALUES (@ob_204id, @ord_hdrnumber, 'orderheader', 'CA', 
                                           @ord_hdrnumber, @notesequence + 1, @ingatenote)
      END
      IF @outgatenote IS NOT NULL AND @outgatenote <> ''
      BEGIN
         INSERT INTO edi_outbound204_notes (ob_204id, ord_hdrnumber, ntb_table, not_type, nre_tablekey, 
                                            not_sequence, not_text)
                                    VALUES (@ob_204id, @ord_hdrnumber, 'orderheader', 'CA', 
                                            @ord_hdrnumber, @notesequence + 2, @outgatenote)
      END
   END
END

--PTS 66468 AR
--PTS 70953 Start
--Get count of distinct ord_hdrnumber for leg > 0
--if > 0, then use lgh_number to retrieve orderheader refs, otherwise use the mov_number
declare @lgh_ordhdr_cnt INT

SELECT  @lgh_ordhdr_cnt  = (SELECT count(DISTINCT(ord_hdrnumber)) FROM stops with(nolock)
 WHERE lgh_number = @lgh_number and ord_hdrnumber > 0)
--PTS 70953 End
   
INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, 
                                  ref_type, ref_number)
   SELECT @ob_204id, @ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, ref_type, ref_number
     FROM referencenumber 
    WHERE ref_table = 'orderheader' AND
--PTS 70953 start
          ( (@lgh_ordhdr_cnt > 0 and ref_tablekey IN (SELECT DISTINCT(ord_hdrnumber) FROM stops with(nolock) WHERE lgh_number = @lgh_number)) 
		  OR 
		    (@lgh_ordhdr_cnt = 0 and ref_tablekey IN (SELECT DISTINCT(ord_hdrnumber) FROM stops with(nolock) WHERE mov_number = @mov_number))
		  )  --PTS 70953 end
          AND ISNULL(ref_number,'') <> '' --PTS55967
   ORDER BY ref_sequence --PSL 10/22/2010 - added order by to control ref number sequence
 --PTS 47736 AR 06.04.2009 - Add reference to Order Number when basis is set to L
 IF @brokerage_edi_basis <> 'O'
 	INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, 
                                  ref_type, ref_number)
	SELECT	@ob_204id,@ord_hdrnumber,@ord_hdrnumber,'orderheader',99,'TMWORD',@ord_number                                  
INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, 
                                  ref_type, ref_number)
   SELECT @ob_204id, @ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, ref_type, ref_number
     FROM referencenumber
    WHERE ref_table = 'stops' AND
          ref_tablekey IN (SELECT stp_number
                             FROM stops
                            WHERE lgh_number = @lgh_number) AND 		--PTS 45676
                            --WHERE ord_hdrnumber = @ord_hdrnumber)
                                  ISNULL(ref_number,'') <> '' --PTS55967
   ORDER BY ref_sequence --PSL 10/22/2010 - added order by to control ref number sequence
--PTS66497 AR
IF @addStopNotes = 'Y'
BEGIN	
	
    INSERT INTO edi_outbound204_refs(ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, 
                                    ref_type, ref_number)
    SELECT @ob_204id,@ord_hdrnumber, stp_number,'stops',null, @stopNoteType, stp_comment
    FROM	stops
    WHERE  lgh_number = @lgh_number	
		AND ISNULL(stp_comment, '') <> ''   
	
END	--66497                            
INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, 
                                  ref_type, ref_number)
   SELECT @ob_204id, @ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, ref_type, ref_number
     FROM referencenumber
    WHERE ref_table = 'freightdetail' AND
          ref_tablekey IN (SELECT fgt_number
                             FROM freightdetail
                            WHERE stp_number IN (SELECT stp_number
                                                   FROM stops
                                                  WHERE lgh_number = @lgh_number)) AND
                                                  --WHERE ord_hdrnumber = @ord_hdrnumber))
						 ISNULL(ref_number,'') <> '' --PTS55967
   ORDER BY ref_sequence --PSL 10/22/2010 - added order by to control ref number sequence

--PTS54693 MBR 11/08/10
IF @lgh_railtemplatedetail_id > 0
BEGIN
   SELECT @rth_id = rth_id
     FROM railtemplatedetail
    WHERE rtd_id = @lgh_railtemplatedetail_id

   SELECT @rth_origin_ramp_actual = ISNULL(rth_origin_ramp_actual, ' '),
          @rth_shipper = ISNULL(rth_shipper, ' '),
          @rth_dest_ramp_actual = ISNULL(rth_dest_ramp_actual, ' '),
          @rth_consignee = ISNULL(rth_consignee, ' '),
          @rth_billto = ISNULL(rth_billto, ' '),
          @rth_notifyparty = ISNULL(rth_notifyparty, ' '),
          @rth_notifyfax = ISNULL(rth_notifyfax, ' ')
     FROM railtemplateheader
    WHERE rth_id = @rth_id

   IF @rth_billto <> 'UNKNOWN'
   BEGIN
      SELECT @billto_name = ISNULL(cmp_name, ' '),
             @billto_nmstct = ISNULL(cty_nmstct, ' '),
             @billto_zip = ISNULL(cmp_zip, ' ')
        FROM company
       WHERE cmp_id = @rth_billto
   END

   SELECT @rtd_quote = ISNULL(rtd_quote, ' '),
          @rtd_plan = ISNULL(rtd_plan, ' '),
          @rtd_service = ISNULL(rtd_service, ' '),
          @rtd_loaded = ISNULL(rtd_loaded, ' '),
          @rtd_mode = ISNULL(rtd_mode, ' '),
          @rtd_length = ISNULL(rtd_length, ' '),
          @rtd_benown = ISNULL(rtd_benown, ' ')
     FROM railtemplatedetail
    WHERE rtd_id = @lgh_railtemplatedetail_id

   IF @rtd_loaded = 'LD'
   BEGIN
      SET @rtd_loaded_desc = 'Loaded'
   END
   IF @rtd_loaded = 'MT'
   BEGIN
      SET @rtd_loaded_desc = 'Empty'
   END

   SELECT @rtd_service_desc = ISNULL(labelfile.name, ' ')
     FROM labelfile
    WHERE labeldefinition = 'LghType2' AND
          abbr = @rtd_service

   SELECT @rtd_length_desc = ISNULL(labelfile.name, ' ')
     FROM labelfile
    WHERE labeldefinition = 'TrlType2' AND
          abbr = @rtd_length

   IF @rtd_benown <> 'UNKNOWN'
   BEGIN
      SELECT @rtd_benown_desc = cmp_name
        FROM company
       WHERE cmp_id = @rtd_benown
   END
   ELSE
   BEGIN
      SET @rtd_benown_desc = ' '
   END

   SET @rtd_sequence = 100
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT01', @rth_origin_ramp_actual)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT02', @rth_shipper)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT03', @rth_dest_ramp_actual)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT04', @rth_consignee)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT05', @rth_billto)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT06', @billto_name)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT07', @billto_nmstct)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT08', @billto_zip)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT09', @rth_notifyparty)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT10', @rth_notifyfax)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT11', @rtd_quote)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT12', @rtd_plan)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT13', @rtd_service_desc)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT14', @rtd_loaded_desc)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT15', @rtd_mode)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT16', @rtd_length_desc)
   SET @rtd_sequence = @rtd_sequence + 1
   INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     'RT17', @rtd_benown_desc)

   SET @minid = 0
   SET @rtr_sequence = 17
   WHILE 1=1
   BEGIN
      SELECT @minid = MIN(rtr_id)
        FROM railtemplaterouting
       WHERE rth_id = @rth_id AND
             rtr_id > @minid

      IF @minid IS NULL
         BREAK

      SELECT @rtr_location = ISNULL(rtr_location, ' '),
             @rtr_interchange_to = ISNULL(rtr_interchange_to, ' '),
             @rtr_rule11 = ISNULL(rtr_rule11, ' ')
        FROM railtemplaterouting
       WHERE rtr_id = @minid
      
      SELECT @rtr_location_desc = ISNULL(labelfile.name, ' ')
        FROM labelfile
       WHERE labeldefinition = 'InterchangeLocation' AND
             abbr = @rtr_location
      IF @rtr_location_desc IS NULL
      BEGIN
         SET @rtr_location_desc = ' '
      END

      SET @rtd_sequence = @rtd_sequence + 1
      SET @rtr_sequence = @rtr_sequence + 1
      SET @ref_type = 'RT' + CAST(@rtr_sequence AS VARCHAR(3))
      INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     @ref_type, @rtr_location_desc)
      SET @rtd_sequence = @rtd_sequence + 1
      SET @rtr_sequence = @rtr_sequence + 1
      SET @ref_type = 'RT' + CAST(@rtr_sequence AS VARCHAR(3))
      INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     @ref_type, @rtr_interchange_to)
      SET @rtd_sequence = @rtd_sequence + 1
      SET @rtr_sequence = @rtr_sequence + 1
      SET @ref_type = 'RT' + CAST(@rtr_sequence AS VARCHAR(3))
      INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence,
                                     ref_type, ref_number)
                             VALUES (@ob_204id, @ord_hdrnumber, @ord_hdrnumber, 'orderheader', @rtd_sequence,
                                     @ref_type, @rtr_rule11)
   END

   --PTS55147 MBR 12/20/10 Check for rule11 interchange locations and add them as thirdparty assignments
   SET @minid = 0
   WHILE 1=1
   BEGIN
      SELECT @minid = MIN(rtr_id)
        FROM railtemplaterouting
       WHERE rth_id = @rth_id AND
             rtr_rule11 = 'Y' AND
             rtr_id > @minid

      IF @minid IS NULL
         BREAK

      SELECT @rtr_interchange_to = ISNULL(rtr_interchange_to, 'UNKNOWN')
        FROM railtemplaterouting
       WHERE rtr_id = @minid

      IF @rtr_interchange_to <> 'UNKNOWN'
      BEGIN
         if @type = 'ADD'
         BEGIN
            INSERT INTO thirdpartyassignment (tpr_id, lgh_number, mov_number, tpa_status, pyd_status, 
                                              tpr_type, ord_number)
                                      VALUES (@rtr_interchange_to, @lgh_number, @mov_number, 'MANUAL', 'NPD',
                                              'TPR', @ord_number)
         END
         IF @type = 'CANCEL'
         BEGIN
            DELETE FROM thirdpartyassignment
             WHERE tpr_id = @rtr_interchange_to AND
                   tpr_type = 'TPR' AND
                   lgh_number = @lgh_number 
         END
      END
   END
END

--PTS79051 JJF 20140619
--It's desired not to send out an identical 204 as compared to the most recent.  This will check and if this is indeed a duplicate, it will mark entry as process_status = 'D'
EXEC outbound204_dupcheck @ob_204id

GO
GRANT EXECUTE ON  [dbo].[create_outbound204] TO [public]
GO
