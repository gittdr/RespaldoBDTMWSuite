SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[create_segment_output] (@lgh_number	INT,
										@split		CHAR(1),
										@completed	CHAR(1)) 
AS   
DECLARE @output_string			VARCHAR(2000),
		@split_count			SMALLINT,
		@next_count				SMALLINT,
		@split_order			CHAR(1),
		@status					CHAR(1),
		@mov_number 			INT,
		@ord_hdrnumber			INT,
		@ord_number				CHAR(8),
		@lgh_start_city			CHAR(15),
		@lgh_start_state		CHAR(2),
		@lgh_end_city			CHAR(15),
		@lgh_end_state			CHAR(2),
		@lgh_class1				CHAR(6),
		@cmd_code				CHAR(8),
		@mpp_otherid			CHAR(5),
		@lgh_tractor			CHAR(5),
		@trc_type1				CHAR(6),
		@lgh_primary_trailer	CHAR(5),
		@trl_type1				CHAR(6),
		@shipper_id				CHAR(7),
		@shipper_name			CHAR(25),
		@shipper_city			CHAR(15),
		@shipper_state			CHAR(2),
		@cons_id				CHAR(7),
		@cons_name				CHAR(25),
		@cons_city				CHAR(15),
		@cons_state				CHAR(2),
		@empty_date				CHAR(16),
		@lgh_tot_weight			CHAR(5),
		@ord_remark				CHAR(20),
		@pickup_date			CHAR(16),
		@latest_date			CHAR(16),
		@loaded_date			CHAR(16),
		@arrive_date			CHAR(16),
		@stp_reasonlate			CHAR(6),
		@dispatch_date			CHAR(16),
		@lgh_outstatus			VARCHAR(6),
		@bol					CHAR(18),
		@loaded					INT,
		@empty					INT,
		@loaded_miles			CHAR(6),
		@empty_miles			CHAR(6),
		@update_dt				DATETIME,
		@mpp_type1				CHAR(6),
		@leg					CHAR(10),
		@lgh_createdby			CHAR(20),
		@car_type4				CHAR(6),
		@lgh_type1				CHAR(6),
		@evt_carrier			VARCHAR(8),
		@pto_id					VARCHAR(12),
		@pto_altid				CHAR(12),
		@car_otherid			CHAR(5),
		@ord_revtype4			CHAR(6),
		@ord_status			VARCHAR(6)

SET @status = ' '
		
SELECT @mov_number = legheader.mov_number,
       @ord_hdrnumber = legheader.ord_hdrnumber,
	   @lgh_class1 = legheader.lgh_class1,
	   @mpp_otherid = ISNULL(manpowerprofile.mpp_otherid, '     '),
	   @mpp_type1 = ISNULL(manpowerprofile.mpp_type1, '      '),
	   @lgh_tractor = legheader.lgh_tractor,
	   @lgh_primary_trailer = legheader.lgh_primary_trailer,
	   @lgh_start_city = a.cty_name,
       @lgh_start_state = a.cty_state,
       @lgh_end_city = b.cty_name,
       @lgh_end_state = b.cty_state,
       @lgh_tot_weight = CONVERT(CHAR(5), lgh_tot_weight),
       @lgh_outstatus = legheader.lgh_outstatus,
       @cmd_code = legheader.cmd_code,
       @trc_type1 = tractorprofile.trc_type1,
       @trl_type1 = trailerprofile.trl_type1,
       @lgh_createdby = ISNULL(CONVERT(CHAR(20), lgh_createdby), '                    '),
       @car_type4 = carrier.car_type4,
       @lgh_type1 = legheader.lgh_type1
  FROM legheader JOIN city a ON lgh_startcity = a.cty_code
				 JOIN city b ON lgh_endcity = b.cty_code
				 JOIN manpowerprofile ON lgh_driver1 = manpowerprofile.mpp_id
				 JOIN tractorprofile ON lgh_tractor = tractorprofile.trc_number
				 JOIN trailerprofile ON lgh_primary_trailer = trailerprofile.trl_id
				 JOIN carrier ON lgh_carrier = carrier.car_id
 WHERE lgh_number = @lgh_number
 
SELECT @split_count = COUNT(*)
  FROM legheader
 WHERE mov_number = @mov_number
IF @split_count < 2
   SET @split_order = '1'
ELSE
BEGIN
   SELECT @next_count = COUNT(*)
     FROM legheader
    WHERE mov_number = @mov_number AND
          lgh_number > @lgh_number
   SET @split_order = @split_count - @next_count
END
   
IF @lgh_outstatus = 'AVL' OR @lgh_outstatus = 'PLN'
   SET @status = ' '
IF @lgh_outstatus = 'STD'
   SET @status = '1'
IF @lgh_outstatus = 'CMP' or @completed = 'Y'
   SET @status = '2'  

IF @split = 'Y'
   SET @status = '5'
   
IF @lgh_tractor = 'UNKNO' 
   SET @lgh_tractor = '     '
IF @lgh_primary_trailer = 'UNKNO'
   SET @lgh_primary_trailer = '     '
   
SELECT @shipper_id = ISNULL(a.cmp_altid, '       '),
       @shipper_name = ISNULL(a.cmp_name, '                         '),
       @shipper_city = c.cty_name,
       @shipper_state = c.cty_state,
       @cons_id = ISNULL(b.cmp_altid, '       '),
       @cons_name = ISNULL(b.cmp_name, '                         '),
       @cons_city = d.cty_name,
       @cons_state = d.cty_state,
       @ord_remark = ISNULL(orderheader.ord_remark, '                    '),
       @ord_number = orderheader.ord_number,
       @ord_revtype4 = ISNULL(orderheader.ord_revtype4, '      '),
       @ord_status = ord_status
  FROM orderheader JOIN company a ON orderheader.ord_shipper = a.cmp_id 
                   JOIN city c ON a.cmp_city = c.cty_code
                   JOIN company b ON orderheader.ord_consignee = b.cmp_id 
                   JOIN city d ON b.cmp_city = d.cty_code
 WHERE orderheader.ord_hdrnumber = @ord_hdrnumber

IF @ord_status = 'CAN'
   SET @status = 'C'
 
WHILE LEN(@ord_number) < 8
BEGIN
   SET @ord_number = '0' + @ord_number
END
 
SELECT @bol = referencenumber.ref_number
  FROM referencenumber
 WHERE ref_table = 'orderheader' AND
       ref_tablekey = @ord_hdrnumber AND
       ref_type = 'BL#'
       
SELECT @pickup_date = ISNULL(CONVERT(CHAR(16), stp_arrivaldate, 120), '                '),
       @loaded_date = ISNULL(CONVERT(CHAR(16), stp_departuredate, 120), '                ')
  FROM stops
 WHERE lgh_number = @lgh_number AND 
       stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                             FROM stops
                            WHERE lgh_number = @lgh_number AND
                                  stp_type = 'PUP')
IF @pickup_date IS NULL
   SELECT @pickup_date = ISNULL(CONVERT(CHAR(16), stp_arrivaldate, 120), '                '),
          @loaded_date = ISNULL(CONVERT(CHAR(16), stp_departuredate, 120), '                ')
     FROM stops
    WHERE lgh_number = @lgh_number AND 
          stp_event = 'HLT'
                                  
SELECT @arrive_date = ISNULL(CONVERT(CHAR(16), stp_arrivaldate, 120), '                '),
       @empty_date = ISNULL(CONVERT(CHAR(16), stp_departuredate, 120), '                '),
       @latest_date = ISNULL(CONVERT(CHAR(16), stp_schdtlatest, 120), '                '),
       @stp_reasonlate = stp_reasonlate,
       @evt_carrier = event.evt_carrier
  FROM stops JOIN event ON stops.stp_number = event.stp_number AND
                           event.evt_sequence = 1
 WHERE lgh_number = @lgh_number AND
       stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                             FROM stops
                            WHERE lgh_number = @lgh_number AND
                                  stp_type = 'DRP')
IF @arrive_date IS NULL
   SELECT @arrive_date = ISNULL(CONVERT(CHAR(16), stp_arrivaldate, 120), '                '),
          @empty_date = ISNULL(CONVERT(CHAR(16), stp_departuredate, 120), '                '),
          @latest_date = ISNULL(CONVERT(CHAR(16), stp_schdtlatest, 120), '                '),
          @stp_reasonlate = stp_reasonlate,
          @evt_carrier = event.evt_carrier
     FROM stops JOIN event ON stops.stp_number = event.stp_number AND
                              event.evt_sequence = 1
    WHERE lgh_number = @lgh_number AND
          stp_event = 'DLT'
          
SELECT @loaded = ISNULL(SUM(ISNULL(stp_lgh_mileage, 0)), 0)
  FROM stops
 WHERE lgh_number = @lgh_number AND
       stp_loadstatus = 'LD'
       
SELECT @empty = ISNULL(SUM(ISNULL(stp_lgh_mileage, 0)), 0)
  FROM stops
 WHERE lgh_number = @lgh_number AND
       stp_loadstatus = 'MT'
             
IF @stp_reasonlate = 'UNK' 
   SET @stp_reasonlate = '      '
IF @cmd_code = 'UNKNOWN' or @cmd_code = 'UNK'
   SET @cmd_code = '        '
IF @trc_type1 = 'UNK'
   SET @trc_type1 = '      '
IF @trl_type1 = 'UNK'
   SET @trl_type1 = '      '
SET @update_dt = GETDATE()
SET @dispatch_date = CONVERT(CHAR(16), @update_dt, 120)

--Check every variable to see if any are null and if they are then set them to the correct number of blanks. This
--will ensure that the output string is never set to null.
IF @status IS NULL
   SET @status = ' '
IF @ord_number IS NULL
   SET @ord_number = '        '
IF @split_order IS NULL
   SET @split_order = ' '
IF @lgh_class1 IS NULL
   SET @lgh_class1 = '      '
IF @mpp_otherid IS NULL
   SET @mpp_otherid = '00000'
IF @lgh_tractor IS NULL
   SET @lgh_tractor = '00000'
IF @lgh_primary_trailer IS NULL
   SET @lgh_primary_trailer = '00000'
IF @cons_id IS NULL
   SET @cons_id = '0000000'
IF @shipper_id IS NULL
   SET @shipper_id = '0000000'
IF @dispatch_date IS NULL
   SET @dispatch_date = '0000000000000000'
IF @lgh_tot_weight IS NULL
   SET @lgh_tot_weight = '00000'
IF @empty_date IS NULL
   SET @empty_date = '0000000000000000'
IF @lgh_start_city IS NULL
   SET @lgh_start_city = '               '
IF @lgh_start_state IS NULL
   SET @lgh_start_state = '  '
IF @lgh_end_city IS NULL
   SET @lgh_end_city = '               '
IF @lgh_end_state IS NULL
   SET @lgh_end_state = '  '
IF @cmd_code IS NULL
   SET @cmd_code = '        '
IF @ord_remark IS NULL
   SET @ord_remark = '                    '
IF @pickup_date IS NULL
   SET @pickup_date = '0000000000000000'
IF @latest_date IS NULL
   SET @latest_date = '0000000000000000'
IF @shipper_name IS NULL
   SET @shipper_name = '                         '
IF @shipper_city IS NULL
   SET @shipper_city = '               '
IF @shipper_state IS NULL
   SET @shipper_state = '  '
IF @cons_name IS NULL
   SET @cons_name = '                         '
IF @cons_city IS NULL
   SET @cons_city = '               '
IF @cons_state IS NULL
   SET @cons_state = '  '
IF @loaded_date IS NULL
   SET @loaded_date = '0000000000000000'
IF @trc_type1 IS NULL
   SET @trc_type1 = '      '
IF @trl_type1 IS NULL
   SET @trl_type1 = '      '
IF @bol IS NULL
   SET @bol = '                  '
IF @arrive_date IS NULL
   SET @arrive_date = '0000000000000000'
IF @stp_reasonlate IS NULL
   SET @stp_reasonlate = '      '
IF @mpp_type1 IS NULL
   SET @mpp_type1 = '      '
IF @car_type4 IS NULL
   SET @car_type4 = '      '
IF @lgh_type1 IS NULL
   SET @lgh_type1 = '      '
IF @ord_revtype4 IS NULL
   SET @ord_revtype4 = '      '

IF @evt_carrier IS NULL
   SET @evt_carrier = 'UNKNOWN'
IF @evt_carrier <> 'UNKNOWN'
BEGIN
   SELECT @pto_id = ISNULL(carrier.pto_id, 'UNKNOWN'),
          @car_otherid = ISNULL(carrier.car_otherid, 'UNKNO')
     FROM carrier
    WHERE car_id = @evt_carrier
   IF @pto_id <> 'UNKNOWN'
      SELECT @pto_altid = payto.pto_altid
        FROM payto
       WHERE pto_id = @pto_id
   SET @mpp_otherid = @car_otherid
END

IF @pto_altid IS NULL
   SET @pto_altid = '            '
   
WHILE LEN(@mpp_otherid) < 5
BEGIN
   SET @mpp_otherid = '0' + @mpp_otherid
END
WHILE LEN(@lgh_tractor) < 5
BEGIN
   SET @lgh_tractor = '0' + @lgh_tractor
END
WHILE LEN(@lgh_primary_trailer) < 5
BEGIN
   SET @lgh_primary_trailer = '0' + @lgh_primary_trailer
END
WHILE LEN(@shipper_id) < 7
BEGIN
   SET @shipper_id = '0' + @shipper_id
END
WHILE LEN(@cons_id) < 7
BEGIN
   SET @cons_id = '0' + @cons_id
END
WHILE LEN(@lgh_tot_weight) < 5
BEGIN
   SET @lgh_tot_weight = '0' + @lgh_tot_weight
END
SET @loaded_miles = CONVERT(CHAR(6), @loaded)
WHILE LEN(@loaded_miles) < 6
BEGIN
   SET @loaded_miles = '0' + @loaded_miles
END
SET @empty_miles = CONVERT(CHAR(6), @empty)
WHILE LEN(@empty_miles) < 6
BEGIN
   SET @empty_miles = '0' + @empty_miles
END
SET @leg = CONVERT(CHAR(10), @lgh_number)
WHILE LEN(@leg) < 10
BEGIN
   SET @leg = '0' + @leg
END

SET @output_string = @status + @ord_number + @split_order + @lgh_class1 + @mpp_otherid + @lgh_tractor + 
					 @lgh_primary_trailer + @shipper_id + @cons_id + SUBSTRING(@dispatch_date, 1, 4) + 
					 SUBSTRING(@dispatch_date, 6, 2) + SUBSTRING(@dispatch_date, 9, 2) + 
					 SUBSTRING(@dispatch_date, 12, 2) + SUBSTRING(@dispatch_date, 15, 2) + @lgh_tot_weight + 
					 SUBSTRING(@empty_date, 1, 4) + SUBSTRING(@empty_date, 6, 2) + SUBSTRING(@empty_date, 9, 2) + 
					 SUBSTRING(@empty_date, 12, 2) + SUBSTRING(@empty_date, 15, 2) + @lgh_start_city + 
					 @lgh_start_state + @lgh_end_city + @lgh_end_state + @cmd_code + @ord_remark + 
					 SUBSTRING(@pickup_date, 1, 4) + SUBSTRING(@pickup_date, 6, 2) + SUBSTRING(@pickup_date, 9, 2) + 
					 SUBSTRING(@pickup_date, 12, 2) + SUBSTRING(@pickup_date, 15, 2) + SUBSTRING(@latest_date, 1, 4) + 
					 SUBSTRING(@latest_date, 6, 2) + SUBSTRING(@latest_date, 9, 2) + SUBSTRING(@latest_date, 12, 2) + 
					 SUBSTRING(@latest_date, 15, 2) + @shipper_name + @shipper_city + @shipper_state + @cons_name + 
					 @cons_city + @cons_state + SUBSTRING(@loaded_date, 1, 4) + SUBSTRING(@loaded_date, 6, 2) + 
					 SUBSTRING(@loaded_date, 9, 2) + SUBSTRING(@loaded_date, 12, 2) + SUBSTRING(@loaded_date, 15, 2) + 
					 @trc_type1 + @trl_type1 + @bol + SUBSTRING(@arrive_date, 1, 4) + SUBSTRING(@arrive_date, 6, 2) + 
					 SUBSTRING(@arrive_date, 9, 2) + SUBSTRING(@arrive_date, 12, 2) + SUBSTRING(@arrive_date, 15, 2) + 
					 @stp_reasonlate + @lgh_createdby + @loaded_miles + @empty_miles + @mpp_type1 + @leg + @car_type4 +
					 @lgh_type1 + @pto_altid + @ord_revtype4

INSERT INTO load_file_export (lfe_output) 
                      VALUES (@output_string)

GO
GRANT EXECUTE ON  [dbo].[create_segment_output] TO [public]
GO
