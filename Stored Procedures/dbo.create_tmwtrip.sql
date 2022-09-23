SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[create_tmwtrip] @origin_cmp	VARCHAR(8),
				@dest_cmp	VARCHAR(8),
				@ipt_number	VARCHAR(5),
				@cmd_code	VARCHAR(8),
				@trailer_id	VARCHAR(13)
AS
DECLARE @ord_hdrnumber		INT,		@mov_number			INT,
	@lgh_number		INT,		@stp_number			INT,
	@stp_number2		INT,		@fgt_number			INT,
        @fgt_number2		INT,		@evt_number			INT,
        @evt_number2		INT,		@ret				SMALLINT,
        @pupdrp			VARCHAR(8),	@cmd_name			VARCHAR(60),
        @cmp_name		VARCHAR(30),	@cmp_city			INT,
        @stp_state		VARCHAR(2),	@arrivaldate			DATETIME,
        @earlydate		DATETIME,	@latedate			DATETIME,
	@stp_phonenumber	VARCHAR(20),	@stp_zip			VARCHAR(10),
	@stp_address1		VARCHAR(40),	@stp_address2			VARCHAR(40),
	@stp_contact		VARCHAR(30),	@ord_originpoint		VARCHAR(8),
	@ord_destpoint		VARCHAR(8),	@ord_origincity			INT,
	@ord_destcity		INT,		@ord_originstate		CHAR(2),
	@ord_deststate		CHAR(2),	@ord_originregion1		VARCHAR(6),
	@ord_destregion1	VARCHAR(6),	@ord_startdate			DATETIME,
	@ord_completiondate	DATETIME,	@ord_originregion2		VARCHAR(6),
	@ord_originregion3	VARCHAR(6),	@ord_originregion4		VARCHAR(6),
	@ord_destregion2	VARCHAR(6),	@ord_destregion3		VARCHAR(6),
	@ord_destregion4	VARCHAR(6),	@Pup_stp			INT,
	@drp_stp		INT,		@ord_origin_earliestdate	DATETIME,
	@ord_origin_latestdate	DATETIME,	@ord_stopcount			INT,
	@ord_dest_earliestdate	DATETIME,	@ord_dest_latestdate		DATETIME,
	@ord_totalweight	INT,		@ord_weightunit			VARCHAR(6),
	@ord_totalvolume	INT,		@ord_volumeunit			VARCHAR(6),
	@ord_totalcount		INT,		@ord_countunit			VARCHAR(6),
	@ord_company		VARCHAR(8),	@ord_number			CHAR(12),
	@ord_bookedby		CHAR(20),	@ord_billto			VARCHAR(8),
	@ord_totalmiles		INT,		@ord_remark			VARCHAR(254),
	@ord_quantity		FLOAT,		@ord_unit			VARCHAR(6),
	@ord_rate		MONEY,		@ord_charge			MONEY,
	@cmd			VARCHAR(8),	@origin_billto			CHAR(1),
	@dest_billto		CHAR(1),	@origin_revtype1		VARCHAR(6),
	@origin_revtype2	VARCHAR(6),	@origin_revtype3		VARCHAR(6),
	@origin_revtype4	VARCHAR(6),	@dest_revtype1			VARCHAR(6),
	@dest_revtype2		VARCHAR(6),	@dest_revtype3			VARCHAR(6),
	@dest_revtype4		VARCHAR(6),	@billto				VARCHAR(8),
	@count			INT,		@move				INT,
	@fgt_sequence		INT,		@valid_orig_cmp			CHAR(1),	
	@valid_dest_cmp		CHAR(1),	@valid_cmd_code			CHAR(1),	
	@valid_trl_id		CHAR(1),	@valid_billto			CHAR(1),	
	@invalid_orig_cmp	VARCHAR(8),	@invalid_dest_cmp		VARCHAR(8),	
	@invalid_cmd_code	VARCHAR(8),	@invalid_trl_id			VARCHAR(8),	
	@invalid_billto		VARCHAR(8),	@cmp_revtype1			VARCHAR(6),
	@cmp_revtype2		VARCHAR(6),	@cmp_revtype3			VARCHAR(6),
	@cmp_revtype4		VARCHAR(6),	@start_cmp			VARCHAR(8)

SET @valid_orig_cmp = 'Y'
SET @valid_dest_cmp = 'Y'
SET @valid_cmd_code = 'Y'
SET @valid_trl_id = 'Y'
SET @valid_billto = 'Y'


/* BEGIN PTS 	43867 Hotfix 
SELECT @move = legheader.mov_number
  FROM legheader, stops
 WHERE legheader.lgh_primary_trailer = @trailer_id AND
       legheader.lgh_outstatus = 'PND' AND
       legheader.stp_number_start = stops.stp_number AND
       stops.cmp_id = @origin_cmp
 */
SELECT	@move = min(legheader.mov_number)
  FROM	legheader 
		join stops o on legheader.stp_number_start = o.stp_number
		join stops d on legheader.stp_number_end = d.stp_number
 WHERE	legheader.lgh_primary_trailer = @trailer_id AND 
		legheader.lgh_outstatus = 'PND' AND
		o.cmp_id = @origin_cmp  AND 
		d.cmp_id = @dest_cmp        
		-- END PTS 	43867 
       
IF @move IS NULL or @move < 1
BEGIN
   SET @ord_company = 'UNKNOWN'
   SET @ord_bookedby = 'INTERPLANT'
    SET @ord_totalmiles = 0
   SET @ord_quantity = 0
   SET @ord_unit = 'UNK' 
   SET @ord_rate = 0.00
   SET @ord_charge = 0.00

   SELECT @count = COUNT(*)
     FROM company
    WHERE cmp_id = @origin_cmp
   IF @count = 0
      SET @valid_orig_cmp = 'N'
	   
   SELECT @count = COUNT(*)
     FROM company
    WHERE cmp_id = @dest_cmp
   IF @count = 0
      SET @valid_dest_cmp = 'N'

   SELECT @count = COUNT(*)
     FROM commodity
    WHERE cmd_code = @cmd_code
   IF @count = 0
      SET @valid_cmd_code = 'N'

   SELECT @count = COUNT(*)
     FROM trailerprofile
    WHERE trl_id = @trailer_id
   IF @count = 0
      SET @valid_trl_id = 'N'

   IF @valid_orig_cmp = 'N' OR @valid_dest_cmp = 'N' OR @valid_cmd_code = 'N' OR @valid_trl_id = 'N'
      GOTO ERROR
	   
   SELECT @cmd_name = ISNULL(cmd_name,'UNKNOWN') 
     FROM commodity 
    WHERE cmd_code = @cmd_code

   SELECT @pupdrp = fgt_event 
     FROM eventcodetable 
    WHERE abbr = 'HPL'

   SELECT @cmp_name = cmp_name,
          @cmp_city = cmp_city,
          @stp_phonenumber = cmp_primaryphone,
          @stp_zip = cmp_zip,
          @stp_address1 = cmp_address1,
          @stp_address2 = cmp_address2,
          @stp_contact = cmp_contact,
          @origin_billto = cmp_billto,
          @origin_revtype1 = cmp_revtype1,
          @origin_revtype2 = cmp_revtype2,
          @origin_revtype3 = cmp_revtype3,
          @origin_revtype4 = cmp_revtype4,
          @origin_billto = cmp_billto
     FROM company 
    WHERE cmp_id = @origin_cmp
	 
   SELECT @stp_state = cty_state 
     FROM city 
    WHERE cty_code = @cmp_city
	 
   SET @arrivaldate = GETDATE()
   SET @earlydate = @arrivaldate
   SET @latedate = @arrivaldate

   --Get system numbers.
   EXEC @ord_hdrnumber = dbo.getsystemnumber 'ORDHDR',NULL
   EXEC @mov_number =  dbo.getsystemnumber 'MOVNUM', NULL       
   EXEC @lgh_number =  dbo.getsystemnumber 'LEGHDR', NULL
   EXEC @stp_number =  dbo.getsystemnumber 'STPNUM', NULL
   EXEC @fgt_number =  dbo.getsystemnumber 'FGTNUM', NULL
   EXEC @evt_number =  dbo.getsystemnumber 'EVTNUM', NULL
   EXEC @stp_number2 =  dbo.getsystemnumber 'STPNUM', NULL
   EXEC @fgt_number2 =  dbo.getsystemnumber 'FGTNUM', NULL
   EXEC @evt_number2 =  dbo.getsystemnumber 'EVTNUM', NULL

   BEGIN TRAN T1

   --Create HPL stop
   INSERT INTO freightdetail (stp_number, fgt_sequence, fgt_number, 			--1	
                              cmd_code, fgt_description, fgt_reftype, 			--2
                              fgt_refnum,fgt_pallets_in, 				--3
                              fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1,	--4	
                              fgt_carryins2, skip_trigger, fgt_quantity,		--5
                              fgt_weight, fgt_weightunit, fgt_count,			--6
                              fgt_countunit, fgt_volume, fgt_volumeunit)		--7
                      VALUES (@stp_number, 1, @fgt_number, 				--1
                              @cmd_code, @cmd_name, 'IPT',				--2
                              @ipt_number,0,						--3
                              0, 0, 0,							--4
                              0, 1, 0,							--5
                              0, 'LBS', 0,						--6
                              'PCS', 0, 'GAL')						--7
   IF @@error <> 0
   BEGIN
      SET @ret = -1
      GOTO ERROR
   END
		                       
   --Add Reference number record
   INSERT INTO referencenumber (ref_tablekey, ref_type, ref_number, ord_hdrnumber, ref_sequence, ref_table)
			VALUES (@fgt_number, 'IPT', @ipt_number, @ord_hdrnumber, 1, 'freightdetail')

   INSERT INTO event (evt_driver1, evt_driver2, evt_tractor, 		--1
                      evt_trailer1, evt_trailer2, ord_hdrnumber,	--2
                      stp_number, evt_startdate, evt_earlydate, 	--3
                      evt_latedate, evt_enddate, evt_reason, 		--4
                      evt_carrier, evt_sequence, fgt_number, 		--5
                      evt_number, evt_pu_dr, evt_eventcode, 		--6
                      evt_status, evt_departure_status, skip_trigger) 	--7
              VALUES ('UNKNOWN', 'UNKNOWN', 'UNKNOWN', 			--1
                      @trailer_id, 'UNKNOWN', @ord_hdrnumber, 		--2
                      @stp_number, @arrivaldate, @earlydate, 		--3	
                      @latedate, @arrivaldate, 'UNK', 			--4
                      'UNKNOWN', 1, @fgt_number, 			--5
                      @evt_number, @pupdrp, 'HPL', 			--6
                      'OPN' , 'OPN', 1)					--7
   IF @@error <> 0
   BEGIN
      SET @ret = -1
      GOTO ERROR
   END

   INSERT INTO stops (trl_id, ord_hdrnumber, stp_number, 			--1
                      stp_city, stp_arrivaldate, stp_schdtearliest, 		--2
                      stp_schdtlatest, cmp_id, cmp_name, 			--3
                      stp_departuredate, stp_reasonlate, lgh_number, 		--4
                      stp_reasonlate_depart, stp_sequence, stp_mfh_sequence,	--5	
                      cmd_code, stp_description, stp_type, 			--6
                      stp_event, stp_status, stp_departure_status, mfh_number,	--7
                      mov_number, stp_origschdt, stp_paylegpt, 			--8
                      stp_region1, stp_region2, stp_region3, 			--9
                      stp_region4, stp_state, stp_lgh_status, 			--10
                      stp_reftype, stp_refnum,stp_loadstatus, stp_redeliver,	--11
                      stp_phonenumber, stp_delayhours, stp_zipcode, 		--12
                      stp_ooa_stop, stp_address, stp_contact, 			--13
                      stp_address2 , skip_trigger, stp_phonenumber2,		--14
                      stp_weight, stp_weightunit, stp_count,			--15 
                      stp_countunit, stp_volume, stp_volumeunit) 		--16
              VALUES (@trailer_id, @ord_hdrnumber, @stp_number, 		--1
                      @cmp_city, @arrivaldate, @earlydate,			--2 
                      @latedate, @origin_cmp, @cmp_name,			--3 
                      @arrivaldate, 'UNK', @lgh_number, 			--4
                      'UNK', 1, 1, 						--5
                      @cmd_code, @cmd_name, @pupdrp, 				--6
                      'HPL', 'OPN', 'OPN', 0, 					--7
                      @mov_number, @arrivaldate, 'Y', 				--8
                      'UNK', 'UNK', 'UNK', 					--9
                      'UNK', @stp_state, 'PND', 				--10
                      NULL , NULL, 'LD', '0', 					--11
                      @stp_phonenumber, 0, @stp_zip,				--12 
                      0, @stp_address1, @stp_contact, 				--13
                      @stp_address2 , 1, '',					--14
                      0, 'LBS', 0,						--15
                      'PCS', 0, 'GAL')						--16
   IF @@error <> 0
   BEGIN
      SET @ret = -1
      GOTO ERROR
   END
		               
   SELECT @pupdrp = fgt_event 
     FROM eventcodetable 
    WHERE abbr = 'DRL'

   SELECT @cmp_name = cmp_name,
          @cmp_city = cmp_city,
          @stp_phonenumber = cmp_primaryphone,
          @stp_zip = cmp_zip,
          @stp_address1 = cmp_address1,
          @stp_address2 = cmp_address2,
          @stp_contact = cmp_contact,
          @dest_billto = cmp_billto,
          @dest_revtype1 = cmp_revtype1,
          @dest_revtype2 = cmp_revtype2,
          @dest_revtype3 = cmp_revtype3,
          @dest_revtype4 = cmp_revtype4,
          @dest_billto = cmp_billto
     FROM company 
    WHERE cmp_id = @dest_cmp
	 
    SELECT @stp_state = cty_state 
      FROM city 
     WHERE cty_code = @cmp_city

   SET @arrivaldate = DATEADD(hour, 1, GETDATE()) 
   SET @earlydate = @arrivaldate
   SET @latedate = @arrivaldate

   --Create DRL stop.
   INSERT INTO freightdetail (stp_number, fgt_sequence, fgt_number, 			--1
                              cmd_code, fgt_description, fgt_reftype, 			--2
                              fgt_refnum,fgt_pallets_in, 				--3
                              fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1,	--4	
                              fgt_carryins2, skip_trigger, fgt_quantity,		--5
                              fgt_weight, fgt_weightunit, fgt_count,			--6
                              fgt_countunit, fgt_volume, fgt_volumeunit)		--7
                      VALUES (@stp_number2, 1, @fgt_number2, 				--1
                              @cmd_code, @cmd_name, 'IPT',				--2
                              @ipt_number,0,						--3
                              0, 0, 0,							--4
                              0, 1, 0,							--5
                              0, 'LBS', 0,						--6
                              'PCS', 0, 'GAL')						--7
   IF @@error <> 0
   BEGIN
      SET @ret = -1
      GOTO ERROR
   END
		                       
   --Add Reference number record
   INSERT INTO referencenumber (ref_tablekey, ref_type, ref_number, ord_hdrnumber, ref_sequence, ref_table)
			VALUES (@fgt_number2, 'IPT', @ipt_number, @ord_hdrnumber, 1, 'freightdetail')
   IF @@error <> 0
   BEGIN
      SET @ret = -1
      GOTO ERROR
   END

   INSERT INTO event (evt_driver1, evt_driver2, evt_tractor, 		--1
                      evt_trailer1, evt_trailer2, ord_hdrnumber,	--2
                      stp_number, evt_startdate, evt_earlydate, 	--3
                      evt_latedate, evt_enddate, evt_reason, 		--4
                      evt_carrier, evt_sequence, fgt_number, 		--5
                      evt_number, evt_pu_dr, evt_eventcode, 		--6
                      evt_status, evt_departure_status, skip_trigger)	--7
              VALUES ('UNKNOWN', 'UNKNOWN', 'UNKNOWN', 			--1
                      @trailer_id, 'UNKNOWN', @ord_hdrnumber, 		--2
                      @stp_number2, @arrivaldate, @earlydate, 		--3	
                      @latedate, @arrivaldate, 'UNK', 			--4
                      'UNKNOWN', 1, @fgt_number2, 			--5
                      @evt_number2, @pupdrp, 'DRL', 			--6
                      'OPN', 'OPN', 1)					--7
   IF @@error <> 0
   BEGIN
      SET @ret = -1
      GOTO ERROR
   END

   INSERT INTO stops (trl_id, ord_hdrnumber, stp_number, 			--1
                      stp_city, stp_arrivaldate, stp_schdtearliest, 		--2
                      stp_schdtlatest, cmp_id, cmp_name, 			--3
                      stp_departuredate, stp_reasonlate, lgh_number, 		--4
                      stp_reasonlate_depart, stp_sequence, stp_mfh_sequence,	--5	
                      cmd_code, stp_description, stp_type, 			--6
                      stp_event, stp_status, stp_departure_status, mfh_number, 	--7
                      mov_number, stp_origschdt, stp_paylegpt, 			--8
                      stp_region1, stp_region2, stp_region3, 			--9
                      stp_region4, stp_state, stp_lgh_status, 			--10
                      stp_reftype, stp_refnum,stp_loadstatus, stp_redeliver,	--11
                      stp_phonenumber, stp_delayhours, stp_zipcode, 		--12
                      stp_ooa_stop, stp_address, stp_contact, 			--13
                      stp_address2 , skip_trigger, stp_phonenumber2,		--14
                      stp_weight, stp_weightunit, stp_count,			--15 
                      stp_countunit, stp_volume, stp_volumeunit) 		--16
              VALUES (@trailer_id, @ord_hdrnumber, @stp_number2, 		--1
                      @cmp_city, @arrivaldate, @earlydate,			--2 
                      @latedate, @dest_cmp, @cmp_name,				--3 
                      @arrivaldate, 'UNK', @lgh_number, 			--4
                      'UNK', 2, 2, 						--5
                      @cmd_code, @cmd_name, @pupdrp, 				--6
                      'DRL', 'OPN', 'OPN', 0, 					--7
                      @mov_number, @arrivaldate, 'Y', 				--8
                      'UNK', 'UNK', 'UNK', 					--9
                      'UNK', @stp_state, 'PND', 				--10
                      NULL , NULL, 'LD', '0', 					--11
                      @stp_phonenumber, 0, @stp_zip,				--12 
                      0, @stp_address1, @stp_contact, 				--13
                      @stp_address2 , 1, '',					--14
                      0, 'LBS', 0,						--15
                      'PCS', 0, 'GAL')						--16
   IF @@error <> 0
   BEGIN
      SET @ret = -1
      GOTO ERROR
   END
		               
   --Create orderheader record 
   SELECT @ord_totalweight = SUM(ISNULL(stp_weight,0)),
          @ord_totalvolume = SUM(ISNULL(stp_volume,0)),
          @ord_totalcount = SUM(ISNULL(stp_count,0))
     FROM stops
    WHERE ord_hdrnumber = @ord_hdrnumber AND
          stp_type = 'DRP'

   SELECT @drp_stp = MIN(stp_sequence) 
     FROM stops
    WHERE ord_hdrnumber = @ord_hdrnumber AND
          stp_type = 'DRP'

   SELECT @ord_weightunit = stp_weightunit,
          @ord_volumeunit = stp_volumeunit,
          @ord_countunit = stp_countunit
     FROM stops
    WHERE ord_hdrnumber = @ord_hdrnumber AND 
          stp_sequence = @drp_stp

   SELECT @pup_stp = MIN(stp_number)
     FROM stops 
    WHERE ord_hdrnumber = @ord_hdrnumber AND 
          stp_sequence = (SELECT MIN(s2.stp_sequence) 
                            FROM stops s2
                           WHERE s2.ord_hdrnumber = @ord_hdrnumber AND 
                                 stp_type ='PUP')


   SELECT @drp_stp = MAX(stp_number)
     FROM stops 
    WHERE ord_hdrnumber = @ord_hdrnumber AND 
          stp_sequence = (SELECT MAX(s2.stp_sequence) 
                            FROM stops s2
                           WHERE s2.ord_hdrnumber = @ord_hdrnumber AND 
                                 stp_type = 'DRP')

   SELECT @ord_originpoint=origin.cmp_id, @ord_destpoint = dest.cmp_id, 
          @ord_origincity = origin.stp_city, @ord_destcity = dest.stp_city, 
          @ord_originstate = oc.cty_state, @ord_deststate = dc.cty_state, 
          @ord_originregion1 = oc.cty_region1, @ord_destregion1 = dc.cty_region1,
          @ord_startdate = origin.stp_arrivaldate, @ord_completiondate = dest.stp_departuredate,
          @ord_originregion2 = oc.cty_region2, @ord_originregion3 = oc.cty_region3, 	
          @ord_originregion4 = oc.cty_region4, @ord_destregion2  = dc.cty_region2, 
          @ord_destregion3 = dc.cty_region3, @ord_destregion4 = dc.cty_region4,
          @cmd = origin.cmd_code, @cmd_name=origin.stp_description,
          @ord_origin_earliestdate = origin.stp_schdtearliest,
          @ord_origin_latestdate = origin.stp_schdtlatest, 
          @ord_dest_earliestdate = dest.stp_schdtearliest,
          @ord_dest_latestdate = dest.stp_schdtlatest
     FROM stops origin, stops dest, city oc, city dc
    WHERE origin.stp_number = @pup_stp AND
          dest.stp_number = @drp_stp AND
          origin.stp_city = oc.cty_code AND
          dest.stp_city = dc.cty_code
	      
   SET @ord_number = CONVERT(VARCHAR(12), @ord_hdrnumber)

   SET @ord_billto = 'UNKNOWN'

   SELECT @ord_stopcount = count(*) 
     FROM stops
    WHERE ord_hdrnumber = @ord_hdrnumber

   --Figure out who the billto is.
   IF SUBSTRING(@origin_revtype4, 1, 2) = 'DC'
   BEGIN
      IF SUBSTRING(@dest_revtype4, 1, 2) = 'DC'
         SET @ord_billto = 'SXHIPT'
      ELSE
         IF @dest_billto = 'Y'
            SET @ord_billto = @dest_cmp
         ELSE
            SET @ord_billto = 'SXHIPT'
   END
   ELSE
   BEGIN
      IF SUBSTRING(@origin_revtype4, 1, 2) = 'WH'
         IF SUBSTRING(@dest_revtype4, 1, 2) = 'WH'
            SET @ord_billto = @origin_cmp
         ELSE
            IF @dest_billto = 'Y'
               SET @ord_billto = @dest_cmp
            ELSE
               SET @ord_billto = @origin_cmp
      ELSE
         IF @origin_billto = 'Y'
            SET @ord_billto = @origin_cmp
         ELSE
            IF @dest_billto = 'Y'
               SET @ord_billto = @dest_cmp
            ELSE
               SET @ord_billto = 'SXHIPT'
   END

   SELECT @count = COUNT(*)
     FROM company
    WHERE cmp_id = @ord_billto
   IF @count = 0
   BEGIN
      SET @valid_billto = 'N'
      SET @ret = -1
      GOTO ERROR
   END

   SELECT @cmp_revtype1 = ISNULL(cmp_revtype1, 'UNK'),
          @cmp_revtype2 = ISNULL(cmp_revtype2, 'UNK'),
          @cmp_revtype3 = ISNULL(cmp_revtype3, 'UNK'),
          @cmp_revtype4 = ISNULL(cmp_revtype4, 'UNK')
     FROM company
    WHERE cmp_id = @ord_billto

   INSERT INTO orderheader (ord_company, ord_number, ord_customer,					--1
                            ord_bookdate, ord_bookedby, ord_status, 					--2
                            ord_originpoint, ord_destpoint, ord_invoicestatus, 				--3	
                            ord_origincity, ord_destcity, ord_originstate, 				--4
                            ord_deststate, ord_originregion1, ord_destregion1, 				--5
                            ord_supplier, ord_billto, ord_startdate, 					--6
                            ord_completiondate, ord_revtype1, ord_revtype2, 				--7
                            ord_revtype3, ord_revtype4, ord_totalweight, ord_totalvolume,		--8
                            ord_totalpieces, ord_totalmiles, ord_odmetermiles,ord_totalcharge,		--9
                            ord_currency, ord_currencydate,  						--10
                            ord_hdrnumber, ord_remark, ord_shipper, 					--11
                            ord_consignee, ord_originregion2, ord_originregion3, 			--12
                            ord_originregion4, ord_destregion2, ord_destregion3,			--13 
                            ord_destregion4, ord_priority, mov_number, 					--14
                            ord_showshipper, ord_showcons, ord_subcompany, 				--15
                            ord_lowtemp, ord_hitemp, ord_quantity,					--16
                            ord_rate, ord_charge, ord_rateunit, 					--17
                            ord_unit, trl_type1, ord_driver1, 						--18
                            ord_driver2, ord_tractor, ord_trailer, 					--19
                            ord_length, ord_width, ord_height, 						--20	
                            ord_reftype, ord_refnum, cmd_code, ord_description, 			--21
                            ord_terms, cht_itemcode, ord_origin_earliestdate, 				--22
                            ord_origin_latestdate, ord_stopcount,					--23
                            ord_dest_earliestdate, ord_dest_latestdate, ord_cmdvalue,			--24
                            ord_accessorial_chrg, ord_availabledate, ord_miscqty, 			--25
                            ord_datetaken, ord_totalweightunits, ord_totalvolumeunits,			--26 
                            ord_totalcountunits, ord_loadtime, ord_unloadtime, 				--27
                            ord_drivetime, ord_rateby, ord_thirdpartytype1, 				--28
                            ord_thirdpartytype2, ord_quantity_type, ord_charge_type, ord_cod_amount)	--29						--30 
                    VALUES (@ord_company, @ord_number, 'UNKNOWN', 	        			--1
                            GETDATE(), @ord_bookedby, 'PND', 						--2
                            @ord_originpoint, @ord_destpoint, 'PND',					--3
                            @ord_origincity, @ord_destcity, @ord_originstate, 				--4
                            @ord_deststate, @ord_originregion1, @ord_destregion1, 			--5
                            'UNKNOWN', @ord_billto, @ord_startdate, 					--6
                            @ord_completiondate, @cmp_revtype1, @cmp_revtype2, 				--7
                            @cmp_revtype3, @cmp_revtype4, @ord_totalweight,@ord_totalvolume,		--8
                            @ord_totalcount, @ord_totalmiles,  @ord_totalmiles,@ord_charge,		--9
                            'US$', getdate(), 								--10 
                            @ord_hdrnumber, @ord_remark,@ord_originpoint,				--11	
                            @ord_destpoint, @ord_originregion2, @ord_originregion3, 			--12
                            @ord_originregion4, @ord_destregion2, @ord_destregion3,			--13 
                            @ord_destregion4, 'UNK', @mov_number, 					--14
                            'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 						--15
                            0, 0, @ord_quantity,     							--16
                            @ord_rate, @ord_charge, 'FLT', 						--17
                            @ord_unit, 'UNK', 'UNKNOWN', 						--18
                            'UNKNOWN', 'UNKNOWN', @trailer_id, 						--19
                            0.0000, 0.0000, 0.0000, 							--20
                            NULL, NULL, @cmd, @cmd_name, 						--21
                            'UNK', 'LHF', @ord_origin_earliestdate, 					--22
                            @ord_origin_latestdate, @ord_stopcount, 					--23
                            @ord_dest_earliestdate, @ord_dest_latestdate, 0.0,				--24	
                            0.0000, getdate(), 0.0000, 							--25
                            getdate(), @ord_weightunit, @ord_volumeunit, 				--26
                            @ord_countunit, 0, 0, 							--27
                            0, 'T', 'UNKNOWN', 			        				--28
                            NULL, 0, 0, 0) 								--29
                           
   IF @@error <> 0
   BEGIN
      SET @ret = -1
      GOTO ERROR
   END

   COMMIT TRAN T1
		                    
   EXEC @ret = update_move_light @mov_number
   IF @ret < 0
   BEGIN
      EXEC purge_delete @mov_number, 0
   END
END
ELSE
BEGIN
   SELECT @cmd_name = ISNULL(cmd_name,'UNKNOWN') 
     FROM commodity 
    WHERE cmd_code = @cmd_code
	 
   --Get system numbers.
   EXEC @fgt_number =  dbo.getsystemnumber 'FGTNUM', NULL
   EXEC @fgt_number2 =  dbo.getsystemnumber 'FGTNUM', NULL

   BEGIN TRAN T1

   --Find first pickup event to tie this freight record to. 		
   SELECT @stp_number = stp_number,
          @ord_hdrnumber = ord_hdrnumber
     FROM stops
    WHERE mov_number = @move AND
          stp_type = 'PUP' AND
          stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                                FROM stops
                               WHERE mov_number = @move AND
                                     stp_type = 'PUP')
   IF @stp_number > 0
   BEGIN
      --Get next fgt_sequence for the stop.
      SELECT @fgt_sequence = MAX(fgt_sequence) + 1
        FROM freightdetail
       WHERE stp_number = @stp_number
      IF @fgt_sequence = 0 or @fgt_sequence IS NULL
         SET @fgt_sequence = 1
      --Create new freightdetail record
      INSERT INTO freightdetail (stp_number, fgt_sequence, fgt_number, 				--1	
                                 cmd_code, fgt_description, fgt_reftype, 			--2
                                 fgt_refnum,fgt_pallets_in, 					--3
                                 fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1,	--4	
                                 fgt_carryins2, skip_trigger, fgt_quantity,			--5
                                 fgt_weight, fgt_weightunit, fgt_count,				--6
                                 fgt_countunit, fgt_volume, fgt_volumeunit)			--7
                         VALUES (@stp_number, @fgt_sequence, @fgt_number,			--1
                                 @cmd_code, @cmd_name, 'IPT',					--2
                                 @ipt_number,0,							--3
                                 0, 0, 0,							--4
                                 0, 1, 0,							--5
                                 0, 'LBS', 0,							--6
                                 'PCS', 0, 'GAL')						--7
      IF @@error <> 0
      BEGIN
         SET @ret = -1
         GOTO ERROR
      END
	   
      --Add Reference number record
      INSERT INTO referencenumber (ref_tablekey, ref_type, ref_number, ord_hdrnumber, ref_sequence, ref_table)
                           VALUES (@fgt_number, 'IPT', @ipt_number, @ord_hdrnumber, 1, 'freightdetail')
      IF @@error <> 0
      BEGIN
         SET @ret = -1
         GOTO ERROR
      END
   END

   --Find last drop event to tie this freight record to. 		
   SELECT @stp_number = stp_number,
          @ord_hdrnumber = ord_hdrnumber
     FROM stops
    WHERE mov_number = @move AND
          stp_type = 'DRP' AND
          stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                                FROM stops
                               WHERE mov_number = @move AND
                                     stp_type = 'DRP')
   IF @stp_number > 0
   BEGIN
      --Get next fgt_sequence for the stop.
      SELECT @fgt_sequence = MAX(fgt_sequence) + 1
        FROM freightdetail
       WHERE stp_number = @stp_number
      IF @fgt_sequence = 0 or @fgt_sequence IS NULL
         SET @fgt_sequence = 1
      --Create new freightdetail record
      INSERT INTO freightdetail (stp_number, fgt_sequence, fgt_number, 				--1	
                                 cmd_code, fgt_description, fgt_reftype, 			--2
                                 fgt_refnum,fgt_pallets_in, 					--3
                                 fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1,	--4	
                                 fgt_carryins2, skip_trigger, fgt_quantity,			--5
                                 fgt_weight, fgt_weightunit, fgt_count,				--6
                                 fgt_countunit, fgt_volume, fgt_volumeunit)			--7
                         VALUES (@stp_number, @fgt_sequence, @fgt_number2,			--1
                                 @cmd_code, @cmd_name, 'IPT',					--2
                                 @ipt_number,0,							--3
                                 0, 0, 0,							--4
                                 0, 1, 0,							--5
                                 0, 'LBS', 0,							--6
                                 'PCS', 0, 'GAL')						--7
      IF @@error <> 0
      BEGIN
         SET @ret = -1
         GOTO ERROR
      END
	   
      --Add Reference number record
      INSERT INTO referencenumber (ref_tablekey, ref_type, ref_number, ord_hdrnumber, ref_sequence, ref_table)
                           VALUES (@fgt_number2, 'IPT', @ipt_number, @ord_hdrnumber, 1, 'freightdetail')
      IF @@error <> 0
      BEGIN
         SET @ret = -1
         GOTO ERROR
      END
   END

   COMMIT TRAN T1
		                    
   EXEC @ret = update_move_light @move
END

ERROR:
IF @ret = -1
   ROLLBACK TRAN T1

IF @valid_orig_cmp = 'N'
   SET @invalid_orig_cmp = @origin_cmp
IF @valid_dest_cmp = 'N'
   SET @invalid_dest_cmp = @dest_cmp
IF @valid_cmd_code = 'N'
   SET @invalid_cmd_code = @cmd_code
IF @valid_trl_id = 'N'
   SET @invalid_trl_id = @trailer_id
IF @valid_billto = 'N'
   SET @invalid_billto = @ord_billto

IF @valid_orig_cmp = 'N' OR @valid_dest_cmp = 'N' OR @valid_cmd_code = 'N' OR @valid_trl_id = 'N' OR
   @valid_billto = 'N'
   INSERT INTO IPTErrorTable (ipt_number, orig_company, dest_company, ord_billto, cmd_code, trl_id, err_text, err_date)
                      VALUES (@ipt_number, @invalid_orig_cmp, @invalid_dest_cmp, @invalid_billto, @invalid_cmd_code, 
                              @invalid_trl_id, 'Invalid Data', GETDATE())
 
GO
GRANT EXECUTE ON  [dbo].[create_tmwtrip] TO [public]
GO
