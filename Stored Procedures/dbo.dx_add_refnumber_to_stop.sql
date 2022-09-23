SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
   This proc is called when building a multi stop order from scratch.  It adds the information
   for a reference number on an existing stop (added by dx_add_neworder_stop).

   It must be called once for each reference number
   
ERROR RETURN  CODES 
   -1 database error
   -2 cannot locate any stop data for this stop number (should be one from add_neworder_stop)
   -3 no ref type passed
   
   

ARGUMENTS

  @stp_number int - required. The value returned from a dx_add_neworder_stop call.
 
  stp_reftype varchar(6) - required if the stp_refnum is not blank.  Identifies the type
          of reference number which follows and will be linked with this stop.
           If passed, it is a valid PS label file entry of type 'ReferenceNumbers'

  @stp_refnum varchar(20) - required.  A reference number attached to the stop passed
          to this procedure

  EXAMPLE - calls to record a one pickup, then add an additional reference number

DECLARE @ret smallint, @New_mov int, @current_mov_nbr int, @cty_code int, @cty_nmstct varchar(25)
DECLARE @stp_number int,@fgt_number int

SELECT @current_mov_nbr = 0
    -- ADD FIRST STOP
EXEC @ret = dx_add_neworder_stop
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
	@stp_number OUTPUT,
	@fgt_number OUTPUT

  IF @ret < 1
      ..... error handling

  EXEC @ret = dx_add_refnumber_to_stop
        @stp_number,                -- volume and units
	'BL#','9877F'           -- reference number
 

*/

CREATE PROC [dbo].[dx_add_refnumber_to_stop]
        @stp_number int,
        @stp_reftype varchar(6), @stp_refnum varchar(30)
AS

DECLARE  @cmd_name varchar(60),@ref_sequence int,@ord_hdrnumber int,@retcode int, @OkStop int
  
  SELECT @stp_reftype = UPPER(ISNULL(@stp_reftype,''))
  SELECT @stp_refnum = UPPER(@stp_refnum)

  SELECT @ord_hdrnumber = ord_hdrnumber FROM stops WHERE stp_number = @stp_number
  
  SELECT @ref_sequence = (SELECT MAX(ref_sequence)
                         FROM referencenumber
                         WHERE ref_table = 'stops'
			 AND ref_tablekey = @stp_number)


  /* If no ref numbers are attached set seq to one (and update stop) */
  IF @ref_sequence IS NULL 
     SELECT @ref_sequence = 1
  ELSE 
     SELECT @ref_sequence = @ref_sequence + 1


  IF @stp_reftype = '' RETURN -3

  
  IF @ref_sequence = 1
    BEGIN
		--avoid updating stops if the values are already correct. MTC 2014.08.20
	
      select @OkStop = count(*) from stops where stp_reftype = @stp_reftype and stp_refnum = @stp_refnum  and stp_number = @stp_number
      
      if @OkStop = 0
	      UPDATE stops
		  SET stp_reftype = @stp_reftype, stp_refnum = @stp_refnum
			WHERE stp_number = @stp_number

      SELECT @retcode = @@error
      IF @retcode<>0
        BEGIN
	  EXEC dx_log_error 888, 'UPdate Ref on Stop Failed', @retcode, @stp_number
	  return -1
        END

    END

  /* add stop ref numbers */
  ELSE
    IF NOT EXISTS (SELECT 1 FROM referencenumber 
         WHERE ref_tablekey = @stp_number AND ref_table = 'stops' 
	   AND ref_type = @stp_reftype AND ref_number = @stp_refnum)
      INSERT INTO referencenumber(
	ref_tablekey,
	ref_type,
	ref_number,
	ref_sequence,
	ord_hdrnumber,
	ref_table,
	ref_sid,
	ref_pickup)
      VALUES  (@stp_number,
	@stp_reftype,
	@stp_refnum,
	@ref_sequence,
	@ord_hdrnumber,
	'stops',
	'Y',
	Null)



  RETURN 1




GO
GRANT EXECUTE ON  [dbo].[dx_add_refnumber_to_stop] TO [public]
GO
