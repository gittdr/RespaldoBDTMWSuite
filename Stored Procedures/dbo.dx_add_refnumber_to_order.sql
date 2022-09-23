SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
   This proc is called to add the information
   for a reference number on an existing order record.

   It must be called once for each reference number
   
ERROR RETURN  CODES 
   -1 database error
   -2 cannot locate any order data for this order number
   -3 no ref type passed
   
   

ARGUMENTS

  @ord_number varchar(12) - required. The order number returned from a call to 
           dx_create_order_from_stops.
  @ord_reftype varchar(6) - required if the ord_refnum is not blank.  Identifies the type
          of reference number which follows and will be linked with this stop.
           If passed, it is a valid PS label file entry of type 'ReferenceNumbers'

  @ord_refnum varchar(20) - required.  A reference number attached to the order passed
          to this procedure

  EXAMPLE - Add a reference to order 'I9887'

DECLARE @ret smallint, @New_mov int, @current_mov_nbr int, @cty_code int, @cty_nmstct varchar(25)
DECLARE @stp_number int, @ord_number int




  EXEC @ret = dx_add_refnumber_to_order
        @ord_number,                -- either assinged or returned from add order call
	'BL#','9877F'           -- reference number
 

*/

CREATE    PROC [dbo].[dx_add_refnumber_to_order]
        @ord_number varchar(12),
        @ord_reftype varchar(6), 
		@ord_refnum varchar(30),
		@ref_sid char(1) = '',
		@hdr_flag char(1) = 'N'
AS

DECLARE  @ord_hdrnumber int,@cmd_name varchar(60), @ref_sequence int, @retcode int
  
  SELECT @ord_reftype = UPPER(ISNULL(@ord_reftype,''))
  SELECT @ord_refnum = UPPER(@ord_refnum)
  SELECT @ref_sid = CASE ISNULL(@ref_sid,'') WHEN 'Y' THEN 'Y' ELSE null END

  IF @hdr_flag = 'Y'
	SELECT @ord_hdrnumber = case isnumeric(@ord_number) when 1 then convert(int, @ord_number) else null end
  ELSE
	SELECT @ord_hdrnumber = ord_hdrnumber
	  FROM orderheader
	 WHERE ord_number = @ord_number

  IF @ord_hdrnumber IS NULL RETURN -2
 
  SELECT @ref_sequence = (SELECT MAX(ref_sequence)
                         FROM referencenumber
                         WHERE ref_table = 'orderheader'
			 AND ref_tablekey = @ord_hdrnumber)

  /* If no ref numbers are attached set seq to one (and update stop) */
  IF @ref_sequence IS NULL 
     SELECT @ref_sequence = 1
  ELSE 
     SELECT @ref_sequence = @ref_sequence + 1

  IF @ord_reftype = '' RETURN -3

  IF @ref_sid = 'Y'
	UPDATE referencenumber
	   SET ref_sid = null
	 WHERE ref_table = 'orderheader'
	   AND ref_tablekey = @ord_hdrnumber
	   AND ref_sid = 'Y'

  IF @ref_sequence = 1
    UPDATE orderheader
    SET ord_reftype = @ord_reftype, ord_refnum = @ord_refnum
    WHERE ord_hdrnumber = @ord_hdrnumber

  SELECT @retcode = @@error
  IF @retcode<>0
    BEGIN
	EXEC dx_log_error 888, 'Update Ref on order Failed', @retcode, @ord_number
	return -1
    END

  /* add  order ref numbers */
 
  IF NOT EXISTS (SELECT 1 FROM referencenumber 
       WHERE ref_tablekey = @ord_hdrnumber AND ref_table = 'orderheader' 
	 AND ref_type = @ord_reftype AND ref_number = @ord_refnum)
    INSERT INTO referencenumber(
	ref_tablekey,
	ref_type,
	ref_number,
	ref_sequence,
	ord_hdrnumber,
	ref_table,
	ref_sid,
	ref_pickup)
    VALUES  (@ord_hdrnumber,
	@ord_reftype,
	@ord_refnum,
	@ref_sequence,
	@ord_hdrnumber,
	'orderheader',
	@ref_sid,
	Null)



  RETURN 1



GO
GRANT EXECUTE ON  [dbo].[dx_add_refnumber_to_order] TO [public]
GO
