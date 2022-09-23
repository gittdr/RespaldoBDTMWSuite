SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE    PROC [dbo].[dx_add_neworder_freight_to_stop]
        @validate char(1),
        @stp_number int,
        @cmd_code varchar(8), @cmd_description varchar(60),
		@weight float, @weightunit varchar(6), 
		@count float, @countunit varchar(6),
		@volume float, @volumeunit varchar(6),
        @fgt_reftype varchar(6), @fgt_refnum varchar(30),
		@fgt_rate money, @fgt_rateunit varchar(6), @fgt_charge money,
		@fgt_length float, @fgt_lengthunit varchar(6), 
		@fgt_width float, @fgt_widthunit varchar(6),
		@fgt_height float, @fgt_heightunit varchar(6),
		@count2 float, @count2unit varchar(6),@fgt_actual_qty float,@fgt_actual_unit varchar(6),
		@@fgt_number int OUTPUT
AS
DECLARE @fgt_number int, @fgt_sequence int, @mov_number int,
        @cmd_name varchar(60), @last_fgt_weight float, @last_fgt_count decimal(10,2),
	@last_fgt_volume float, @cmd_gravity float, @retcode int, @last_cmd_code varchar(8)

  IF @validate = 'X' return 1

  SELECT @mov_number = mov_number
  FROM stops 
  WHERE stp_number = @stp_number
  IF @mov_number IS NULL
  RETURN -3

  SELECT @validate = 
     CASE UPPER(ISNULL(@validate,'N'))
       WHEN 'Y' then 'Y'
       WHEN 'I' then 'I'
       ELSE 'N'
     END

  SELECT @cmd_code = CASE ISNULL(@cmd_code,'') WHEN '' THEN 'UNKNOWN' ELSE UPPER(RTRIM(@cmd_code)) END

  IF @validate != 'N' AND @cmd_code <> 'UNKNOWN'
  BEGIN
      SELECT @cmd_gravity = ISNULL(cmd_specificgravity, 0.0) FROM commodity WHERE cmd_code = @cmd_code
      IF @@ROWCOUNT = 0
      BEGIN
      --IF (SELECT COUNT(*)
      --    FROM commodity
      --    WHERE cmd_code = @cmd_code) = 0
        IF @validate = 'I' SELECT @cmd_code = 'UNKNOWN' ELSE RETURN -4
      END
  END

  IF ISNULL(@cmd_description,'') = ''
  BEGIN
      IF @cmd_code <> 'UNKNOWN'
	  SELECT @cmd_name = ISNULL(cmd_name,'UNKNOWN'), @cmd_gravity = ISNULL(cmd_specificgravity, 0.0)
	  FROM commodity 
	  WHERE cmd_code = @cmd_code
  END
  ELSE
  BEGIN
      IF @cmd_code = 'UNKNOWN'
	  SELECT @cmd_code = ISNULL(cmd_code,'UNKNOWN'), @cmd_gravity = ISNULL(cmd_specificgravity, 0.0)
	    FROM commodity
	   WHERE cmd_name = @cmd_description
      SELECT @cmd_name = @cmd_description, @cmd_code = ISNULL(@cmd_code,'UNKNOWN')
  END

  SELECT @cmd_name = CASE ISNULL(@cmd_name,'') WHEN '' THEN 'UNKNOWN' ELSE @cmd_name END

  SELECT @fgt_reftype = UPPER(RTRIM(ISNULL(@fgt_reftype,'')))
  IF @validate = 'Y' AND LEN(@fgt_reftype) > 0
    BEGIN
      IF (SELECT COUNT(*)
          FROM labelfile
          WHERE labeldefinition = 'ReferenceNumbers'
          AND abbr = @fgt_reftype) = 0
        RETURN -5
     END
  SELECT @fgt_refnum = UPPER(@fgt_refnum)

  IF ISNULL(@fgt_charge,0) > 0
  BEGIN
     SELECT @fgt_rate = ISNULL(@fgt_rate,0)
     IF @fgt_rate = 0 AND ISNULL(@count, 0) = 0
	  SELECT @fgt_rate = 1, @count = @fgt_charge, @fgt_rateunit = 'FLT'
  END

  SELECT @fgt_rateunit = CASE ISNULL(@fgt_rateunit,'') WHEN '' THEN 'UNK' ELSE @fgt_rateunit END

  IF @validate = 'I' AND ISNULL(@weightunit,'') = 'LBS' and ISNULL(@weight,0.0) > 0.0 and ISNULL(@volume,0.0) = 0.0 and ISNULL(@cmd_gravity,0.0) > 0.0
       SELECT @volume = CEILING(CEILING(@weight) / CEILING(@cmd_gravity)), @volumeunit = 'GAL'
       
  SELECT @fgt_lengthunit = NULLIF(@fgt_lengthunit, '')
       , @fgt_widthunit = NULLIF(@fgt_widthunit, '')
       , @fgt_heightunit = NULLIF(@fgt_heightunit, '')
       , @count2unit = CASE ISNULL(@countunit, '') WHEN '' THEN 'PCS' ELSE @count2unit END
       , @fgt_actual_unit = NULLIF(@fgt_actual_unit,'LBS')
	   --PRINT 'PASO1'
  IF @validate = 'I' and ISNULL(@@fgt_number,0) > 0  --EDI UPDATE ROUTINE
 
  BEGIN
	SELECT @fgt_sequence = fgt_sequence
	  FROM freightdetail
	 WHERE fgt_number = @@fgt_number
	 
	IF ISNULL(@fgt_sequence, 0) = 0 RETURN -2
	
	UPDATE freightdetail
	   SET cmd_code = CASE @cmd_code WHEN 'UNKNOWN' THEN cmd_code WHEN '' THEN cmd_code ELSE @cmd_code END,
		   fgt_description = CASE @cmd_name WHEN 'UNKNOWN' THEN fgt_description WHEN '' THEN fgt_description ELSE @cmd_name END,
	       fgt_weight = @weight,fgt_weightunit =  @weightunit,
	       fgt_count = @count, fgt_countunit = @countunit,
	       fgt_volume = @volume, fgt_volumeunit = @volumeunit,
	       fgt_rate = @fgt_rate, fgt_rateunit = @fgt_rateunit,
	       fgt_charge = @fgt_charge, fgt_quantity = @count, fgt_unit = @countunit,
	       fgt_length = @fgt_length, fgt_lengthunit = @fgt_lengthunit,
	       fgt_width = @fgt_width, fgt_widthunit = @fgt_widthunit,
	       fgt_height = @fgt_height, fgt_heightunit = @fgt_heightunit,
	       fgt_count2 = @count2, fgt_count2unit = @count2unit,
	       fgt_actual_quantity = @fgt_actual_qty,fgt_actual_unit = @fgt_actual_unit
	 WHERE fgt_number = @@fgt_number
	IF @@ERROR <> 0 RETURN -1
	
	--update legheader for fgt_sequence 1 1.21.09
	UPDATE legheader
	SET		cmd_code = @cmd_code
			,fgt_description =  @cmd_name
	WHERE	mov_number =  @mov_number		
	
	IF @fgt_sequence = 1
	
    	BEGIN
		UPDATE stops
		   SET cmd_code = CASE @cmd_code WHEN 'UNKNOWN' THEN cmd_code WHEN '' THEN cmd_code ELSE @cmd_code END,
		   stp_description = CASE @cmd_name WHEN 'UNKNOWN' THEN stp_description WHEN '' THEN stp_description ELSE @cmd_name END,
			stp_weight = @weight, stp_weightunit =  @weightunit,
			stp_count = @count, stp_countunit = @countunit,
			stp_volume = @volume, stp_volumeunit = @volumeunit,
			stp_count2 = @count2, stp_countunit2 = @count2unit
         	WHERE stp_number = @stp_number
		IF @@ERROR <> 0 RETURN -1
	
    	END
	RETURN 1
  END
  --PRINT 'PASO1.2'
	--PRINT @fgt_sequence
  SELECT @fgt_sequence = (SELECT MAX(fgt_sequence)
                         FROM freightdetail
                         WHERE stp_number = @stp_number)
	--PRINT @fgt_sequence					 
  IF @fgt_sequence IS NULL RETURN -2
  --PRINT 'PASO2'
 /* if the freight record 1 has no commodity, update with this commodity */
 IF @fgt_sequence = 1
     SELECT @last_fgt_weight = isnull(fgt_weight, 0)
	  , @last_fgt_count = isnull(fgt_count, 0)
	  , @last_fgt_volume = isnull(fgt_volume, 0)
        , @fgt_number = fgt_number
		, @last_cmd_code = CASE ISNULL(cmd_code,'') WHEN '' THEN 'UNKNOWN' ELSE UPPER(RTRIM(cmd_code)) END
     FROM freightdetail
     WHERE stp_number = @stp_number
     AND fgt_sequence = @fgt_sequence
 
 IF @fgt_sequence = 1 
   AND @last_fgt_weight = 0
   AND @last_fgt_count = 0
   AND @last_fgt_volume = 0
   AND @last_cmd_code = 'UNKNOWN'
   
   BEGIN
   --PRINT 'PASO3'
     /* UPDATE freightdetail
     SET cmd_code = @cmd_code,fgt_description = @cmd_name,
         fgt_reftype = @fgt_reftype,fgt_refnum = @fgt_refnum,
         skip_trigger = 1,fgt_weight = @weight,fgt_weightunit =  @weightunit,
         fgt_count = @count, fgt_countunit = @countunit,
         fgt_volume = @volume, fgt_volumeunit = @volumeunit
     WHERE fgt_number = @@fgt_number */
     UPDATE freightdetail
     SET cmd_code = CASE @cmd_code WHEN 'UNKNOWN' THEN cmd_code WHEN '' THEN cmd_code ELSE @cmd_code END,
		 fgt_description = CASE @cmd_name WHEN 'UNKNOWN' THEN fgt_description WHEN '' THEN fgt_description ELSE @cmd_name END,
         fgt_reftype = @fgt_reftype,fgt_refnum = @fgt_refnum,
         skip_trigger = 1,fgt_weight = @weight,fgt_weightunit =  @weightunit,
         fgt_count = @count, fgt_countunit = @countunit,
         fgt_volume = @volume, fgt_volumeunit = @volumeunit,
		 fgt_rate = @fgt_rate, fgt_rateunit = @fgt_rateunit,
		 fgt_charge = @fgt_charge, fgt_quantity = @count, fgt_unit = @countunit,
		 fgt_length = @fgt_length, fgt_lengthunit = @fgt_lengthunit,
		 fgt_width = @fgt_width, fgt_widthunit = @fgt_widthunit,
		 fgt_height = @fgt_height, fgt_heightunit = @fgt_heightunit,
		 fgt_count2 = @count2, fgt_count2unit = @count2unit,
		 fgt_actual_quantity = @fgt_actual_qty,fgt_actual_unit = @fgt_actual_unit
     WHERE fgt_number = @fgt_number      
     SELECT @retcode = @@error
     IF @retcode<>0
       BEGIN	
         EXEC dx_log_error 0, 'INSERT INTO freightdetail Failed', @retcode, ''
         IF @validate != 'N'
	    GOTO ERROR_EXIT
         ELSE
            RETURN -1
       END
       
		--update legheader for fgt_sequence 1 1.21.09
		UPDATE legheader
		SET		cmd_code = @cmd_code
				,fgt_description =  @cmd_name
		WHERE	mov_number =  @mov_number		

     UPDATE stops
     SET cmd_code = CASE @cmd_code WHEN 'UNKNOWN' THEN cmd_code WHEN '' THEN cmd_code ELSE @cmd_code END,
		   stp_description = CASE @cmd_name WHEN 'UNKNOWN' THEN stp_description WHEN '' THEN stp_description ELSE @cmd_name END,
         skip_trigger = 1,stp_weight = @weight,stp_weightunit =  @weightunit,
         stp_count = @count, stp_countunit = @countunit,
         stp_volume = @volume, stp_volumeunit = @volumeunit,
         stp_count2 = @count2, stp_countunit2 = @count2unit
     WHERE stp_number = @stp_number

     SELECT @retcode = @@error
     IF @retcode<>0
       BEGIN	
         EXEC dx_log_error 0, 'UPDATE stops Failed', @retcode, ''
         IF @validate != 'N'
	    GOTO ERROR_EXIT
         ELSE
            RETURN -1
       END
   END
 /* otherwise add a freight detail */
 ELSE
 --PRINT 'PASO5'
   BEGIN
     SELECT @fgt_sequence = @fgt_sequence + 1
     EXEC @fgt_number = dbo.getsystemnumber 'FGTNUM',NULL
	 --PRINT @fgt_number
     INSERT INTO freightdetail 
	( stp_number, fgt_sequence, fgt_number, 		--1	
	cmd_code, fgt_description, fgt_reftype, 		--2
	fgt_refnum,fgt_pallets_in, 				--3
	fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1, --4	
	fgt_carryins2, skip_trigger, fgt_quantity,		--5
	fgt_weight, fgt_weightunit, fgt_count,			--6
	fgt_countunit, fgt_volume, fgt_volumeunit,		--7
	fgt_rate, fgt_rateunit, fgt_charge, fgt_unit, cht_itemcode,
	fgt_length, fgt_lengthunit, fgt_width, fgt_widthunit,
	fgt_height, fgt_heightunit, fgt_count2, fgt_count2unit,
	fgt_actual_quantity,fgt_actual_unit)
     VALUES ( @stp_number, @fgt_sequence, @fgt_number, 		--1
	@cmd_code, @cmd_name, @fgt_reftype,			--2
	@fgt_refnum,0,					--3
	0, 0, 0,						--4
	0, 1, @count,						--5
	@weight, @weightunit, @count,				--6
	@countunit, @volume, @volumeunit,			--7 
	@fgt_rate, @fgt_rateunit, @fgt_charge, @countunit, 'UNK',
	@fgt_length, @fgt_lengthunit, @fgt_width, @fgt_widthunit,
	@fgt_height, @fgt_heightunit, @count2, @count2unit,
	@fgt_actual_qty,@fgt_actual_unit)
   END
  SELECT @retcode = @@error
  IF @retcode<>0
    BEGIN	
      EXEC dx_log_error 0, 'INSERT INTO freightdetail Failed', @retcode, ''
      IF @validate != 'N'
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
    VALUES  (@fgt_number,
	@fgt_reftype,
	@fgt_refnum,
	1,
	'freightdetail',
	'Y',
	Null)
	
  -- MRH PTS 18031
  select @@fgt_number = @fgt_number
  RETURN 1

ERROR_EXIT:
   EXEC purge_delete @mov_number,0
   SELECT 'ERROR :imported freight:',@mov_number
   RETURN -1

GO
GRANT EXECUTE ON  [dbo].[dx_add_neworder_freight_to_stop] TO [public]
GO
