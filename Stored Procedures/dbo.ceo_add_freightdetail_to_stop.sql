SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
   This proc is called when using the copy_existing_order proc to make copies of existing orders. It adds a freight detail and updates
   the order totalweight, volume and count fields

   It must be called for each additional commodity to be pickup up or delivered
   for every stop 
ERROR RETURN  CODES 
   -1 database error
   -2 cannot locate any freight for this stop number (should be one from add_neworder_stop)
   -3 cannot find a stop with this @stp_number
      validate codes
   -4 invalid commodity code
   -5 Invalid reference number type
   -6 Invalid weight unit (no labelfile entry under 'WeighUnits')
   -7 Invalid count unit
   -8 Invalid volume unit
   
   

ARGUMENTS

  @validate CHAR(1) (N or Y) required. If 'Y' validation of codes will be done and
      return with error codes will id the problem.  If a db error occurs all of the
      data recorded for this move number so far will be removed.  If not 'Y' no
      validation is done and nothing backed out if a db error occurs.

  @stp_number int - required. The value returned from a tmw_add_neworder_stop call.

  @cmd_code varchar(8) - required.  Must be a valid PowerSuite (PS) commodity code.
        Identifies the commodity picked up or delivered.

  @weight float - optional.  The weight of goods picked up or delivered.  

  @weightunit varchar(6) - required if the @Weight > 0, otherwise it msut be a valid PS
          label file entry of type 'WeightUnits' (not validated)
 
  @count float - optional.  The count of goods picked up or delivered.

  @countunit varchar(6) - required if the @count > 0, otherwise it msut be a valid PS
          label file entry of type 'CountUnits'(not validated)
 
  @volume float - optional.  The volume of goods picked up or delivered.

  @volumeunit varchar(6) - required if the @volume > 0, otherwise it must be a valid PS
          label file entry of type 'VolumeUnits'(not validated)
 
  fgt_reftype varchar(6) - required is the fgt_refnum is not blank.  Identifies the type
          of reference number which follows and will be linked with the first commodity
          associated with this stop.
           If passed, it is a valid PS label file entry of type 'ReferenceNumbers'

  @fgt_refnum varchar(30) - optional.  A referenc enumber attached to the commodity passed
          to this procedure

	@Quantitysource varchar(3) - optional If ('WGT','VOL', or 'CNT') will copy the weight, volume or count to the fgt_quantity
			and the fgt_weightunit, or volunit or countunti to the fgt_unit.

  @@fgt_number int OUTPUT  Needed to attach any aditional reference numbers to this 
          commodoity

  EXAMPLE - calls to record a one pickup, then add an additional commodity

DECLARE @ret smallint, @New_mov int, @current_mov_nbr int, @cty_code int, @cty_nmstct varchar(25)
DECLARE @stp_number int,@fgt_number int

SELECT @current_mov_nbr = 0
    -- ADD FIRST STOP
EXEC @ret = tmwv_add_neworder_stop
        'N',
        @current_mov_nbr ,                  -- first stop mov number is zero
	1,                         -- stop sequence
	'LLD',                     -- event is live load
	'DET1',0,                  -- cmp_id, city code (one reqd)
         0,                        -- miles from prior stop
	'detcontact', 'detphone',  -- stop contact and phone
	'11-14-00 07:00','1-1-50 00:00','11-14-00 07:00', -- est arrive,early,late
        'gas',                     -- commodity code
	895, 'LBS',                --wgt, wgt unit
        65, 'BOX',                 --count, count unit
	342, 'GAL',                -- volume, volume unit
	'','',                     -- stop reference type & number
        '','',                    -- freight reference type and number
	@new_mov  OUTPUT,
	@stp_number OUTOUT,
	@fgt_number OUTPUT

  IF @ret < 1
      ..... error handling since vlaidate was sent as N

  EXEC @ret = tmwv_add_neworder_freight_to_stop
        'N',
        @stp_number,
	'CAR1',                  -- commodity code
        456,'LBS',               -- weight and unit
	0,'UNK',                 -- count and units
        87,'GAL',                -- volume and units
	'BL#','9877F',           -- reference number
	'WGT',						-- place weight in billing qty field
        @fgt_number OUPUT        -- returns key to the freight record with this commodity

*/

CREATE PROC [dbo].[ceo_add_freightdetail_to_stop]
        @validate char(1),
        @stp_number int,
        @cmd_code varchar(8),
	@weight float, @weightunit varchar(6), 
	@count smallint, @countunit varchar(6),
	@volume float, @volumeunit varchar(6),
        @fgt_reftype varchar(6), @fgt_refnum varchar(30),
	@Quantitysource varchar(3) ,
	@@fgt_number int OUTPUT
AS

DECLARE  @fgt_sequence int,@mov_number int,
        @cmd_name varchar(60),@last_fgt_cmd_code varchar(8) ,
        @last_fgt_cmd_description varchar(30),@fgtquantity float,@fgtunit varchar(6),@ordhdrnumber int,
			@totalweight float,@totalweightunits varchar(6),@totalvolume float,@totalvolumeunits varchar(6),
		@totalcount float, @totalcountunits varchar(6),@ordrateby char(1),@minstpsequence int


  SELECT @mov_number = mov_number,
		@ordhdrnumber = ord_hdrnumber
  FROM stops 
  WHERE stp_number = @stp_number

  IF @mov_number IS NULL
  RETURN -3

  SELECT @validate = 
     CASE UPPER(ISNULL(@validate,'N'))
       WHEN 'Y' then 'Y'
       ELSE 'N'
     END

  SELECT @cmd_code = UPPER(RTRIM(ISNULL(@cmd_code,'UNKNOWN')))
  IF LEN(@cmd_code) = 0 SELECT @cmd_code = 'UNKNOWN'
  IF @validate = 'Y'  
    BEGIN
      IF (SELECT COUNT(*)
          FROM commodity
          WHERE cmd_code = @cmd_code) = 0
        RETURN -4
    END
  SELECT @cmd_name = ISNULL(cmd_name,'UNKNOWN') 
  FROM commodity 
  WHERE cmd_code = @cmd_code
  SELECT @cmd_name = ISNULL(@cmd_name,'UNKNOWN')


  SELECT @fgt_reftype = UPPER(RTRIM(ISNULL(@fgt_reftype,'')))
  IF @validate = 'Y' AND LEN(@fgt_reftype) > 0
    BEGIN
      IF (SELECT COUNT(*)
          FROM labelfile
          WHERE labeldefinition = 'ReferenceNumbers'
          AND abbr = @fgt_reftype) = 0
        RETURN -5

		IF (SELECT COUNT(*)
          FROM labelfile
          WHERE labeldefinition = 'WeightUnits'
          AND abbr = @weightunit) = 0
        RETURN -6

		IF (SELECT COUNT(*)
          FROM labelfile
          WHERE labeldefinition = 'CountUnits'
          AND abbr = @countunit) = 0
        RETURN -7

		IF (SELECT COUNT(*)
          FROM labelfile
          WHERE labeldefinition = 'VolumeUnits'
          AND abbr = @volumeunit) = 0
        RETURN -8
     END
  SELECT @fgt_refnum = UPPER(@fgt_refnum)

SELECT @fgtquantity = CASE @quantitySource
				WHEN 'WGT' THEN @weight
				WHEN 'VOL' THEN @volume
				WHEN 'CNT' THEN @count
				ELSE 0
			END

SELECT @fgtunit = CASE @quantitySource
				WHEN 'WGT' THEN @weightunit
				WHEN 'VOL' THEN @volumeunit
				WHEN 'CNT' THEN @countunit
				ELSE 'UNK'
			END
 
  SELECT @fgt_sequence = (SELECT MAX(fgt_sequence)
                         FROM freightdetail
                         WHERE stp_number = @stp_number)
  IF @fgt_sequence IS NULL RETURN -2

 /* if the freight record 1 has no commodity, update with this commodity */
 IF @fgt_sequence = 1
     SELECT @last_fgt_cmd_code = cmd_code,@last_fgt_cmd_description = fgt_description,
            @@fgt_number = fgt_number
     FROM freightdetail
     WHERE stp_number = @stp_number
     AND fgt_sequence = @fgt_sequence
 
  

 IF @fgt_sequence = 1 
   AND @last_fgt_cmd_code = 'UNKNOWN' 
   AND @last_fgt_cmd_description = 'UNKNOWN'
   BEGIN
     UPDATE freightdetail
     SET cmd_code = @cmd_code,fgt_description = @cmd_name,
         fgt_reftype = @fgt_reftype,fgt_refnum = @fgt_refnum,
         skip_trigger = 1,fgt_weight = @weight,fgt_weightunit =  @weightunit,
         fgt_count = @count, fgt_countunit = @countunit,
         fgt_volume = @volume, fgt_volumeunit = @volumeunit,fgt_quantity = @fgtquantity,fgt_unit = @fgtunit
     WHERE fgt_number = @@fgt_number 
     IF @@error<>0
       BEGIN	
         EXEC tmw_log_error 0, 'INSERT INTO freightdetail Failed', @@error, ''
         IF @validate = 'Y'
	    GOTO ERROR_EXIT
         ELSE
            RETURN -1
       END

     UPDATE stops
     SET cmd_code = @cmd_code,stp_description = @cmd_name,
         skip_trigger = 1,stp_weight = @weight,stp_weightunit =  @weightunit,
         stp_count = @count, stp_countunit = @countunit,
         stp_volume = @volume, stp_volumeunit = @volumeunit
     WHERE stp_number = @stp_number
     IF @@error<>0
       BEGIN	
         EXEC tmw_log_error 0, 'UPDATE stops Failed', @@error, ''
         IF @validate = 'Y'
	    GOTO ERROR_EXIT
         ELSE
            RETURN -1
       END
   END
 /* otherwise add a freight detail */
 ELSE
   BEGIN
     SELECT @fgt_sequence = @fgt_sequence + 1
     EXEC @@fgt_number = dbo.getsystemnumber 'FGTNUM',NULL
     INSERT INTO freightdetail 
	( stp_number, fgt_sequence, fgt_number, 		--1	
	cmd_code, fgt_description, fgt_reftype, 		--2
	fgt_refnum,fgt_pallets_in, 				--3
	fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1, --4	
	fgt_carryins2, skip_trigger,		--5
	fgt_weight, fgt_weightunit, fgt_count,			--6
	fgt_countunit, fgt_volume, fgt_volumeunit,		--7
	fgt_quantity,fgt_unit)								--8
     VALUES ( @stp_number, @fgt_sequence, @@fgt_number, 		--1
	@cmd_code, @cmd_name, @fgt_reftype,			--2
	@fgt_refnum,0,					--3
	0, 0, 0,						--4
	0, 1, 					--5
	@weight, @weightunit, @count,				--6
	@countunit, @volume, @volumeunit,			--7 
	@fgtquantity,@fgtunit)
   END
  IF @@error<>0
    BEGIN	
      EXEC tmw_log_error 0, 'INSERT INTO freightdetail Failed', @@error, ''
      IF @validate = 'Y'
	    GOTO ERROR_EXIT
        ELSE
            RETURN -1
    END



  /* add stop and freight ref numbers */
 
  IF @fgt_reftype <> '' 
     INSERT INTO referencenumber(
	ref_tablekey,
	ref_type,
	ref_number,
	ref_sequence,
	ref_table,
	ref_sid,
	ref_pickup)
    VALUES  (@@fgt_number,
	@fgt_reftype,
	@fgt_refnum,
	1,
	'feightdetail',
	'Y',
	Null)

/* accumulate totals and update the order header total weight, vol, vount */

SELECT @totalweight = SUM(ISNULL(fgt_weight,0)),
	@totalcount = SUM(ISNULL(fgt_count,0)),
	@totalvolume = SUM(ISNULL( fgt_volume,0))
FROM freightdetail, stops
WHERE stops.ord_hdrnumber = @ordhdrnumber
AND freightdetail.stp_number = stops.stp_number
AND stp_type = 'DRP'

SELECT @minstpsequence = MIN(stp_sequence)
FROM stops
WHERE stops.ord_hdrnumber = @ordhdrnumber
AND stp_type = 'DRP'
AND stp_weight <> 0

IF @minstpsequence IS NOT NULL
  SELECT @totalweightunits = stp_weightunit
	FROM stops
	WHERE stops.ord_hdrnumber = @ordhdrnumber
	AND stp_type = 'DRP'
	AND stp_weight <> 0
	AND stp_sequence = @minstpsequence
ELSE
	SELECT @totalweightunits = 'UNK'

SELECT @minstpsequence = MIN(stp_sequence)
FROM stops
WHERE stops.ord_hdrnumber = @ordhdrnumber
AND stp_type = 'DRP'
AND stp_volume <> 0

IF @minstpsequence IS NOT NULL
  SELECT @totalvolumeunits = stp_volumeunit
	FROM stops
	WHERE stops.ord_hdrnumber = @ordhdrnumber
	AND stp_type = 'DRP'
	AND stp_volume <> 0
	AND stp_sequence = @minstpsequence
ELSE
	SELECT @totalvolumeunits = 'UNK'

SELECT @minstpsequence = MIN(stp_sequence)
FROM stops
WHERE stops.ord_hdrnumber = @ordhdrnumber
AND stp_type = 'DRP'
AND stp_count <> 0

IF @minstpsequence IS NOT NULL
  SELECT @totalcountunits = stp_countunit
	FROM stops
	WHERE stops.ord_hdrnumber = @ordhdrnumber
	AND stp_type = 'DRP'
	AND stp_count <> 0
	AND stp_sequence = @minstpsequence
ELSE
	SELECT @totalcountunits = 'UNK'

UPDATE orderheader
SET ord_totalweight = @totalweight,
	ord_totalpieces = @totalcount,
	ord_totalvolume = @totalvolume,
	ord_totalweightunits = @totalweightunits,
	ord_totalcountunits = @totalcountunits,
	ord_totalvolumeunits = @totalvolumeunits,
	ord_quantity = 
		CASE ord_rateby
			WHEN 'D' THEN 0
			ELSE
				CASE ord_quantity_type
					WHEN 1 THEN ord_quantity
					WHEN 2 THEN ord_quantity
					ELSE 
						CASE ord_unit
							WHEN 'UNK' THEN 0
							WHEN @totalweightunits THEN @totalweight
							WHEN @totalvolumeunits THEN @totalvolume
							WHEN @totalcountunits THEN @totalcount
							ELSE ord_quantity
						END
				END
		END
WHERE ord_hdrnumber = @ordhdrnumber


  RETURN 1

ERROR_EXIT:
   EXEC purge_delete @mov_number,0
   SELECT 'ERROR :imported freight:',@mov_number
   RETURN -1

GO
GRANT EXECUTE ON  [dbo].[ceo_add_freightdetail_to_stop] TO [public]
GO
