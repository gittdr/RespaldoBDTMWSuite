SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/*
   This proc is called when building a multi stop order from scratch.  It adds the information
   for a reference number on an existing freight record (added by dx_add_neworder_stop or
   dx_add_neworder_freight_to_stop).

   It must be called once for each reference number
   
ERROR RETURN  CODES 
   -1 database error
   -2 cannot locate any freight data for this freight number (should be one from 
                 dx_add_neworder_freight_to_stop)
   -3 no ref type passed
   
   

ARGUMENTS

  @fgt_number int - required. The value returned from a dx_add_neworder_freight_to_stop call.
 
  fgt_reftype varchar(6) - required if the fgt_refnum is not blank.  Identifies the type
          of reference number which follows and will be linked with this stop.
           If passed, it is a valid PS label file entry of type 'ReferenceNumbers'

  @fgt_refnum varchar(20) - required.  A reference number attached to the stop passed
          to this procedure

  EXAMPLE - calls to record a one pickup, then add an additional reference number

DECLARE @ret smallint, @New_mov int, @current_mov_nbr int, @cty_code int, @cty_nmstct varchar(25)
DECLARE @stp_number int, @fgt_number int

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
	@stp_number OUTOUT,
	@fgt_number OUTPUT

  IF @ret < 1
      ..... error handling

  EXEC @ret = dx_add_refnumber_to_freight
        @fgt_number,                -- volume and units
	'BL#','9877F'           -- reference number
 

*/

CREATE PROC [dbo].[dx_add_refnumber_to_freight]
        @fgt_number int,
        @fgt_reftype varchar(6), @fgt_refnum varchar(30)
AS

DECLARE  @cmd_name varchar(60),@ref_sequence int,@ord_hdrnumber int,@retcode int
  
  SELECT @fgt_reftype = UPPER(ISNULL(@fgt_reftype,''))
  SELECT @fgt_refnum = UPPER(@fgt_refnum)

  SELECT @ord_hdrnumber = ord_hdrnumber FROM stops WHERE stp_number = (SELECT stp_number FROM freightdetail WHERE fgt_number = @fgt_number)
 
  SELECT @ref_sequence = (SELECT MAX(ref_sequence)
                         FROM referencenumber
                         WHERE ref_table = 'freightdetail'
			 AND ref_tablekey = @fgt_number)
  /* If no ref numbers are attached set seq to one (and update stop) */
  IF @ref_sequence IS NULL 
     SELECT @ref_sequence = 1
  ELSE 
     SELECT @ref_sequence = @ref_sequence + 1

  IF @fgt_reftype = '' RETURN -3

  
  IF @ref_sequence = 1
    UPDATE freightdetail
    SET fgt_reftype = @fgt_reftype, fgt_refnum = @fgt_refnum
    WHERE fgt_number = @fgt_number

  SELECT @retcode = @@error
  IF @retcode<>0
     BEGIN
	EXEC dx_log_error 888, 'Update Ref on Freight Failed', @retcode, @fgt_number
	return -1
     END

  /* add  freight ref numbers */

  IF NOT EXISTS (SELECT 1 FROM referencenumber 
       WHERE ref_tablekey = @fgt_number AND ref_table = 'freightdetail' 
	 AND ref_type = @fgt_reftype AND ref_number = @fgt_refnum)  
    INSERT INTO referencenumber(
	ref_tablekey,
	ref_type,
	ref_number,
	ref_sequence,
	ord_hdrnumber,
	ref_table,
	ref_sid,
	ref_pickup)
    VALUES  (@fgt_number,
	@fgt_reftype,
	@fgt_refnum,
	@ref_sequence,
	@ord_hdrnumber,
	'freightdetail',
	'Y',
	Null)

  RETURN 1



GO
GRANT EXECUTE ON  [dbo].[dx_add_refnumber_to_freight] TO [public]
GO
