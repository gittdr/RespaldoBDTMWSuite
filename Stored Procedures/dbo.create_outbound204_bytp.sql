SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[create_outbound204_bytp] @lgh_number	INT,
					@edi_cmpid	VARCHAR(8), 
					@carrier_pro     VARCHAR(12),
					@type		       VARCHAR(6)


/**
 * 
 * NAME:
 * dbo.create_outbound204_bytp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Creates records in outbound 204 tables for a new edi 204 out to be sent to a trading partner
 * RETURNS:
 * 
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @lgh_number, int, input, null;
 *       This parameter indicates the LEGHEADER NUMBER(ie.lgh_number)
 *       The value must be non-null and non-empty.
 * 002 - @edi_cmpid,varchar(8),input
 *	This parameter indicates the company id that will be used to retrieve trading partner setup information.
 *	The value must be non-null and non-empty
 * 003 - @carrier_pro, varchar(12),input;
 *	This parameter indicates the order number for which the 204 is being created.
 * 004 - @type,varchar(6),input
 *	This parameter indicates the type of transaction being created(ADD,CANCEL or UPDATE)
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
  *
 * REVISION HISTORY:
 * 03/01/2005.01 – PTSnnnnn - AuthorName – Revision Description
 * 08/15/2008.02   PTS44117 - A. Rossman	- Added support for asset records in output.
 * 09/16/2008.03  PTSxxxxx - A. Rossman		- Added freight actual quantity and units
 * 09/19/2008.04 PTSxxxxx - A.Rossman - Use GI SCAC for Revtype1/Sender ID
 * 10/05/2008.05 PTSxxxxx 				- Allow for 204-06 or CONFIRM
 **/  


AS
DECLARE @ord_hdrnumber			INT,
        @ord_company			VARCHAR(8),
	@ord_shipper			VARCHAR(8),
        @ord_consignee			VARCHAR(8),
        @ord_billto					VARCHAR(8),		--44117
        @ob_cmp_name			VARCHAR(35),
	@ob_cmp_address1		VARCHAR(35),
	@ob_cmp_address2		VARCHAR(35),
	@ob_cmp_city			VARCHAR(20),
	@ob_cmp_state			VARCHAR(6),
	@ob_cmp_zip			VARCHAR(10),
	@ob_location_code	VARCHAR(20),		--44117
	@sh_cmp_name			VARCHAR(35),
	@sh_cmp_address1		VARCHAR(35),
	@sh_cmp_address2		VARCHAR(35),
	@sh_cmp_city			VARCHAR(20),
	@sh_cmp_state			VARCHAR(6),
	@sh_cmp_zip			VARCHAR(10),
	@sh_location_code	VARCHAR(20),	--44117
	@cn_cmp_name			VARCHAR(35),
	@cn_cmp_address1		VARCHAR(35),
	@cn_cmp_address2		VARCHAR(35),
	@cn_cmp_city			VARCHAR(20),
	@cn_cmp_state			VARCHAR(6),
	@cn_cmp_zip			VARCHAR(10),
	@cn_location_code	VARCHAR(20),	--44117
	@trp_id				VARCHAR(20),
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
	@IncludeCarDesc		CHAR(1),		--44117
	@UseCarMisc			VARCHAR(10),	--44117
	@IncludeOrderNotes	CHAR(1),		--44117
	@IncludeAssets		CHAR(1),		--44117
	@lgh_driver			VARCHAR(8),	--44117
	@lgh_tractor			VARCHAR(12),	--44117
	@lgh_trailer1			VARCHAR(13),	--44117
	@lgh_trailer2			VARCHAR(13),	--44117
	@ord_carrier			VARCHAR(8),
	@useScacForRev		CHAR(1)
	

/* PTS 33570 -- moved ob_204id to just before it is actually used
EXECUTE @ob_204id = getsystemnumber 'OB204',''
*/

SELECT @ord_hdrnumber = ord_hdrnumber,
   		   @car_mileage = ISNULL(lgh_miles, 0),
   		  @car_charge = ISNULL(lgh_car_totalcharge, 0)
  FROM legheader
 WHERE lgh_number = @lgh_number

 
 --get trading partner id for receiver
 --SELECT @trp_id = trp_id 	FROM edi_trading_partner 	WHERE cmp_id = @edi_cmpid

IF @type = 'CANCEL'
BEGIN
	SELECT @ib_990id = MAX(trn_id) 
	  FROM edi_inbound990_records
	 WHERE ord_hdrnumber = @ord_hdrnumber
	--   AND SCAC = @car_scac

	IF ISNULL(@ib_990id,0) > 0
	BEGIN
		IF (SELECT [Action] FROM edi_inbound990_records WHERE trn_id = @ib_990id) = 'D'
			RETURN
	END
END
-- PTS 33570 -- end block

SELECT @ord_company = ord_company,
       @ord_shipper = ord_shipper,
       @ord_consignee = ord_consignee,
       @ord_number = ord_number,
       @ord_refnum = ord_refnum,
       @ord_revtype1 = ord_revtype1,
       @ord_terms = ord_terms,
       @ord_bookdate = ord_bookdate,
       @ord_startdate = ord_startdate,
       @ord_completiondate = ord_completiondate,
       @ord_remark = ord_remark,
       @ord_carrier = ord_carrier,			--PTS 44117 AJR
  	@ord_billto	=  ord_billto
  FROM orderheader
 WHERE ord_hdrnumber = @ord_hdrnumber

--get the trading partner id from the billto
SELECT @trp_id = isnull(trp_id,'UNKNOWN') FROM edi_trading_partner where cmp_id = @ord_billto
--edi company should always be equal to the billto
SELECT @edi_cmpid = @ord_billto

--Update the reference number to be the primary SID reference
SELECT @ord_refnum = ISNULL(MAX(ref_number),@ord_number)
FROM	referencenumber
WHERE	ref_table = 'orderheader'
	AND	ref_type = 'SID' 
	AND	ref_tablekey = @ord_hdrnumber

--PTS #40745 set ordernumber equalto carrier pro when different
IF @ord_number <> @carrier_pro and @carrier_pro <> '0'
	SET @ord_number = @carrier_pro

SELECT @ob_cmp_name = SUBSTRING(company.cmp_name, 1, 35),
       @ob_cmp_address1 = SUBSTRING(company.cmp_address1, 1, 35),
       @ob_cmp_address2 = SUBSTRING(company.cmp_address2, 1, 35),
       @ob_cmp_city = city.cty_name,
       @ob_cmp_state = city.cty_state,
       @ob_cmp_zip = company.cmp_zip,
       @ob_location_code = SUBSTRING(cmpcmp.ediloc_code,1,20)
  FROM company, city
  LEFT OUTER JOIN cmpcmp
  		on cmp_id = @ord_company
  			AND billto_cmp_id = @ord_billto
 WHERE company.cmp_id = @ord_company AND
       company.cmp_city = city.cty_code
       

SELECT @sh_cmp_name = SUBSTRING(company.cmp_name, 1, 35),
       @sh_cmp_address1 = SUBSTRING(company.cmp_address1, 1, 35),
       @sh_cmp_address2 = SUBSTRING(company.cmp_address2, 1, 35),
       @sh_cmp_city = city.cty_name,
       @sh_cmp_state = city.cty_state,
       @sh_cmp_zip = company.cmp_zip,
       @sh_location_code = SUBSTRING(ediloc_code,1,20)
  FROM company, city
  	LEFT OUTER JOIN cmpcmp
  			on cmp_id = @ord_shipper
  				AND billto_cmp_id = @ord_billto
 WHERE company.cmp_id = @ord_shipper AND
       company.cmp_city = city.cty_code

SELECT @cn_cmp_name = SUBSTRING(company.cmp_name, 1, 35),
       @cn_cmp_address1 = SUBSTRING(company.cmp_address1, 1, 35),
       @cn_cmp_address2 = SUBSTRING(company.cmp_address2, 1, 35),
       @cn_cmp_city = city.cty_name,
       @cn_cmp_state = city.cty_state,
       @cn_cmp_zip = company.cmp_zip,
       @cn_location_code =  SUBSTRING(ediloc_code,1,20)
  FROM company, city
  	LEFT OUTER JOIN cmpcmp
  		on cmp_id = @ord_consignee
  			AND billto_cmp_id  = @ord_billto
 WHERE company.cmp_id = @ord_consignee AND
       company.cmp_city = city.cty_code

--***PTS 44117 AJR 08/15/08  START ***
SELECT @IncludeCarDesc = ISNULL(UPPER(LEFT(gi_string1,1)),'N'),
		   @UseCarMisc =  ISNULL(UPPER(gi_string2),'NONE')
FROM	   generalinfo
WHERE	gi_name =  'IncludeCarDescOnOutbound204'


SELECT @IncludeOrderNotes = ISNULL(UPPER(LEFT(gi_string1,1)),'N')
	FROM 	generalinfo
	WHERE gi_name ='IncludeOrderNotesOnOutbound204'

SELECT @IncludeAssets = ISNULL(UPPER(LEFT(gi_string1,1)),'N')
	FROM	generalinfo
	WHERE  gi_name = 'IncludeAssetsOnOutbound204'
	
SELECT @UseScacForRev = ISNULL(UPPER(LEFT(gi_string1,1)),'N')
FROM	   generalinfo
WHERE	gi_name =  'UseScacOnOutbound204_tp'	
	
IF (SELECT ISNULL(@IncludeAssets,'N')) = 'Y'
	SELECT	@lgh_driver =  lgh_driver1,
				@lgh_tractor = lgh_tractor,
				@lgh_trailer1 =  lgh_primary_trailer,
				@lgh_trailer2 = lgh_primary_pup
	FROM		legheader
	WHERE	lgh_number = @lgh_number
	
	
--Set the revtype 1 value(sender ID) to the SCAC from the generalinfo table if setting is enabled
IF @UseScacForRev = 'Y'
	SELECT @ord_revtype1 =  ISNULL(UPPER(LEFT(gi_string1,4)),'SCAC')
	FROM		generalinfo
	WHERE	gi_name = 'SCAC'

--***PTS 44117 END ***

--PTS38879 MBR 08/28/07
SELECT @broker_linehaul_paytype = ISNULL(gi_string1, 'BRKLH')
  FROM generalinfo
 WHERE gi_name = 'BrokerLinehaulPayType'
/* PTS 40745 - commented out for trading partner edi 
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
*/
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
                                           broker_total_charge, ord_remark,ob_location_code,sh_location_code,cn_location_code)
	                          VALUES  (@ob_204id, @ord_number, @ord_hdrnumber, @ord_refnum, @ord_revtype1,
	                                   @ord_bookdate, @ord_startdate, @ord_completiondate, @ord_company,
	                                   @ob_cmp_name, @ob_cmp_address1, @ob_cmp_address2, @ob_cmp_city,
	                                   @ob_cmp_state, @ob_cmp_zip, @ord_shipper, @sh_cmp_name,
	                                   @sh_cmp_address1, @sh_cmp_address2, @sh_cmp_city, @sh_cmp_state,
	                                   @sh_cmp_zip, @ord_consignee, @cn_cmp_name, @cn_cmp_address1,
	                                   @cn_cmp_address2, @cn_cmp_city, @cn_cmp_state, @cn_cmp_zip,
	                                   @edi_cmpid, @ord_terms, @trp_id, GETDATE(), '00', 'N',
                                           @car_mileage, @car_charge, @broker_linehaul, @broker_fuel,
                                           @broker_accessorial, @broker_totalcharge, @ord_remark,@ob_location_code,@sh_location_code,@cn_location_code)
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
                                           broker_total_charge, ord_remark,ob_location_code,sh_location_code,cn_location_code)
	                          VALUES  (@ob_204id, @ord_number, @ord_hdrnumber, @ord_refnum, @ord_revtype1,
	                                   @ord_bookdate, @ord_startdate, @ord_completiondate, @ord_company,
	                                   @ob_cmp_name, @ob_cmp_address1, @ob_cmp_address2, @ob_cmp_city,
	                                   @ob_cmp_state, @ob_cmp_zip, @ord_shipper, @sh_cmp_name,
	                                   @sh_cmp_address1, @sh_cmp_address2, @sh_cmp_city, @sh_cmp_state,
	                                   @sh_cmp_zip, @ord_consignee, @cn_cmp_name, @cn_cmp_address1,
	                                   @cn_cmp_address2, @cn_cmp_city, @cn_cmp_state, @cn_cmp_zip,
	                                   @edi_cmpid, @ord_terms, @trp_id, GETDATE(), '01', 'N',
                                           @car_mileage, @car_charge, @broker_linehaul, @broker_fuel,
                                           @broker_accessorial, @broker_totalcharge, @ord_remark,@ob_location_code,@sh_location_code,@cn_location_code)
END

IF @type = 'CHANGE'
BEGIN
	INSERT INTO edi_outbound204_order (ob_204id, ord_number, ord_hdrnumber, ord_refnumber, ord_revtype1,
	                                   ord_bookdate, ord_startdate, ord_completiondate, ob_cmp_id,
	                                   ob_name, ob_address1, ob_address2, ob_city, ob_state, ob_zip,
	                                   sh_cmp_id, sh_name, sh_address1, sh_address2, sh_city, sh_state,
	                                   sh_zip, cn_cmp_id, cn_name, cn_address1, cn_address2, cn_city,
	                                   cn_state, cn_zip, car_id, ord_terms, car_edi_scac, created_dt,
	                                   edi_code, process_status, car_mileage, car_charge,
                                           broker_linehaul_charge, broker_fuel_charge, broker_accessorial_charge,
                                           broker_total_charge, ord_remark,ob_location_code,sh_location_code,cn_location_code)
	                          VALUES  (@ob_204id, @ord_number, @ord_hdrnumber, @ord_refnum, @ord_revtype1,
	                                   @ord_bookdate, @ord_startdate, @ord_completiondate, @ord_company,
	                                   @ob_cmp_name, @ob_cmp_address1, @ob_cmp_address2, @ob_cmp_city,
	                                   @ob_cmp_state, @ob_cmp_zip, @ord_shipper, @sh_cmp_name,
	                                   @sh_cmp_address1, @sh_cmp_address2, @sh_cmp_city, @sh_cmp_state,
	                                   @sh_cmp_zip, @ord_consignee, @cn_cmp_name, @cn_cmp_address1,
	                                   @cn_cmp_address2, @cn_cmp_city, @cn_cmp_state, @cn_cmp_zip,
	                                   @edi_cmpid, @ord_terms, @trp_id, GETDATE(), '04', 'N',
                                           @car_mileage, @car_charge, @broker_linehaul, @broker_fuel,
                                           @broker_accessorial, @broker_totalcharge, @ord_remark,@ob_location_code,@sh_location_code,@cn_location_code)
END

IF @type = 'CONFRM'
BEGIN
	INSERT INTO edi_outbound204_order (ob_204id, ord_number, ord_hdrnumber, ord_refnumber, ord_revtype1,
	                                   ord_bookdate, ord_startdate, ord_completiondate, ob_cmp_id,
	                                   ob_name, ob_address1, ob_address2, ob_city, ob_state, ob_zip,
	                                   sh_cmp_id, sh_name, sh_address1, sh_address2, sh_city, sh_state,
	                                   sh_zip, cn_cmp_id, cn_name, cn_address1, cn_address2, cn_city,
	                                   cn_state, cn_zip, car_id, ord_terms, car_edi_scac, created_dt,
	                                   edi_code, process_status, car_mileage, car_charge,
                                           broker_linehaul_charge, broker_fuel_charge, broker_accessorial_charge,
                                           broker_total_charge, ord_remark,ob_location_code,sh_location_code,cn_location_code)
	                          VALUES  (@ob_204id, @ord_number, @ord_hdrnumber, @ord_refnum, @ord_revtype1,
	                                   @ord_bookdate, @ord_startdate, @ord_completiondate, @ord_company,
	                                   @ob_cmp_name, @ob_cmp_address1, @ob_cmp_address2, @ob_cmp_city,
	                                   @ob_cmp_state, @ob_cmp_zip, @ord_shipper, @sh_cmp_name,
	                                   @sh_cmp_address1, @sh_cmp_address2, @sh_cmp_city, @sh_cmp_state,
	                                   @sh_cmp_zip, @ord_consignee, @cn_cmp_name, @cn_cmp_address1,
	                                   @cn_cmp_address2, @cn_cmp_city, @cn_cmp_state, @cn_cmp_zip,
	                                   @edi_cmpid, @ord_terms, @trp_id, GETDATE(), '06', 'N',
                                           @car_mileage, @car_charge, @broker_linehaul, @broker_fuel,
                                           @broker_accessorial, @broker_totalcharge, @ord_remark,@ob_location_code,@sh_location_code,@cn_location_code)
END                                          
	
 
INSERT INTO edi_outbound204_stops (ob_204id, ord_hdrnumber, stp_number, cmp_id, cmp_name, cmp_address1, 
                                   cmp_address2, cmp_city, cmp_state, cmp_zip, stp_sequence, stp_event, 
                                   stp_weight, stp_weightunit, stp_count, stp_countunit, stp_volume, 
                                   stp_volumeunit, stp_arrivaldate, stp_departuredate, stp_schdtearliest, 
                                   stp_schdtlatest,cmp_location_code)
   SELECT @ob_204id, stops.ord_hdrnumber, stops.stp_number, stops.cmp_id, stops.cmp_name, 
          stops.stp_address, '', city.cty_name, city.cty_state,stops.stp_zipcode, stops.stp_sequence, 
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
          stops.stp_schdtlatest,cmpcmp.ediloc_code
     FROM stops 
	INNER JOIN city
		ON stp_city = cty_code
     	LEFT OUTER JOIN cmpcmp
     		ON stops.cmp_id = cmpcmp.cmp_id
     			AND billto_cmp_id =  @ord_billto
    WHERE stops.lgh_number = @lgh_number
			AND stops.stp_type in('PUP','DRP') --AND
         -- stops.stp_city = city.cty_code
          
          
INSERT INTO edi_outbound204_fgt (ob_204id, ord_hdrnumber, stp_number, fgt_number, fgt_sequence, 
                                 fgt_count, fgt_countunit, fgt_weight, fgt_weightunit, fgt_volume, 
                                 fgt_volumeunit, fgt_rate, fgt_rateunit, fgt_charge, cmd_code, 
                                 fgt_description,fgt_actual_quantity,fgt_actual_unit,edi_commodity)
   SELECT @ob_204id, @ord_hdrnumber, fgt.stp_number, fgt.fgt_number, fgt.fgt_sequence, fgt.fgt_count, 
          fgt.fgt_countunit, fgt.fgt_weight, fgt.fgt_weightunit, fgt.fgt_volume, fgt.fgt_volumeunit, 
          fgt.fgt_rate, fgt.fgt_rateunit, fgt.fgt_charge, fgt.cmd_code, fgt.fgt_description,fgt.fgt_actual_quantity,fgt.fgt_actual_unit,e.edi_cmd_code
     FROM freightdetail fgt
     	INNER JOIN  stops
     		     ON     stops.stp_number = fgt.stp_number
     	LEFT OUTER JOIN	edicommodity e
     		ON fgt.cmd_code = e.cmd_code
     			and e.cmp_id  = @ord_billto
    WHERE stops.lgh_number = @lgh_number 
			AND stops.stp_type in('PUP','DRP')  
          
          
 IF (SELECT ISNULL(@IncludeOrderNotes,'N')) = 'Y'       
 	INSERT INTO edi_outbound204_notes (ob_204id, ord_hdrnumber, not_sentby, ntb_table, nre_tablekey, 
	                                   not_type, not_sequence, not_text)
	   SELECT @ob_204id, nre_tablekey, not_sentby, ntb_table, nre_tablekey, not_type, not_sequence, not_text
	     FROM notes
	    WHERE ntb_table = 'orderheader' AND
        		  nre_tablekey = @ord_hdrnumber 
ELSE		--only insert edi and carrier notes        		  
	INSERT INTO edi_outbound204_notes (ob_204id, ord_hdrnumber, not_sentby, ntb_table, nre_tablekey, 
                                   not_type, not_sequence, not_text)
	   SELECT @ob_204id, nre_tablekey, not_sentby, ntb_table, nre_tablekey, not_type, not_sequence, not_text
	     FROM notes
	    WHERE ntb_table = 'orderheader' AND
		          nre_tablekey = @ord_hdrnumber AND
		          /*PTS29060 MBR 07/25/05*/
		          /*PTS33934 MBR 07/31/06*/
		         (not_type = 'E' or not_type = 'CA')
        
        
INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, 
                                  ref_type, ref_number)
   SELECT @ob_204id, @ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, ref_type, ref_number
     FROM referencenumber
    WHERE ref_table = 'orderheader' AND
          		ref_tablekey = @ord_hdrnumber
          AND ref_number is not null
          
INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, 
                                  ref_type, ref_number)
   SELECT @ob_204id, @ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, ref_type, ref_number
     FROM referencenumber
    WHERE ref_table = 'stops' AND
          ref_tablekey IN (SELECT stp_number
                             FROM stops
                            WHERE ord_hdrnumber = @ord_hdrnumber)
        AND ref_number is NOT NULL
                            
INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, 
                                  ref_type, ref_number)
   SELECT @ob_204id, @ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, ref_type, ref_number
     FROM referencenumber
    WHERE ref_table = 'freightdetail' AND
          ref_tablekey IN (SELECT fgt_number
                             FROM freightdetail
                            WHERE stp_number IN (SELECT stp_number
                                                   FROM stops
                                                  WHERE ord_hdrnumber = @ord_hdrnumber))
		AND ref_number is NOT NULL       
			                                           
IF (SELECT ISNULL(@IncludeAssets,'N')) = 'Y'			--PTS 44117 AJR
	BEGIN
		INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, 
                                  ref_type, ref_number)
                 SELECT @ob_204id,@ord_hdrnumber,@ord_hdrnumber,'orderheader',98,'_RS',
                 			@lgh_driver + REPLICATE(CHAR(32),8 - DATALENGTH(@lgh_driver)) 	+
                 			@lgh_tractor + REPLICATE(CHAR(32),12 - DATALENGTH(@lgh_tractor)) +
                 			@lgh_trailer1 + REPLICATE(CHAR(32),13 - DATALENGTH(@lgh_trailer1))
		INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, 
                                  ref_type, ref_number)
                 SELECT @ob_204id,@ord_hdrnumber,@ord_hdrnumber,'orderheader',99,'_RT',@lgh_trailer2
         END        
IF((SELECT ISNULL(@IncludeCarDesc,'N')) = 'Y' AND @ord_carrier <> 'UNKNOWN')
	BEGIN		
		INSERT INTO edi_outbound204_refs (ob_204id, ord_hdrnumber, ref_tablekey, ref_table, ref_sequence, 
                                  ref_type, ref_number)
		SELECT	@ob_204id,@ord_hdrnumber,@ord_hdrnumber,'orderheader',97,'CRDESC',
						CASE @UseCarMisc
								WHEN 'CARMISC1'	THEN car_misc1
								WHEN	'CARMISC2' THEN	car_misc2
								WHEN	'CARMISC3' THEN	car_misc3
								WHEN	'CARMISC4' THEN  car_misc4
								ELSE	'NO DESCRIPTION'
						END
		FROM	carrier
		WHERE	car_id =  @ord_carrier
								
	END	/*PTS 4417 END*/    
                                                  



--update legheader and orderheader tradi ng partner data    
IF isnull(@trp_id,'UNKNOWN') <> 'UNKNOWN'                                              
UPDATE legheader
SET	lgh_204_tradingpartner = @trp_id
WHERE	lgh_number = @lgh_number

--do not set the trading partner value on the orderheader
/*UPDATE	orderheader
SET 		ord_editradingpartner = @trp_id
WHERE	ord_hdrnumber = @ord_hdrnumber
*/

GO
GRANT EXECUTE ON  [dbo].[create_outbound204_bytp] TO [public]
GO
