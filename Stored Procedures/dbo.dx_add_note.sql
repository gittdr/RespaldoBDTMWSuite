SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROC [dbo].[dx_add_note]
        @attach_to varchar(20),
        @order_number varchar(12), 
	@stp_number int,
	@fgt_number int,
	@note varchar(254),
	@note_is_urgent char(1),
	@applies_to varchar(6),
	@note_update varchar(254) = ''
	
	
AS

DECLARE  @ord_hdrnumber int, @note_sequence int, @ntb_table varchar(18), 
	 @not_urgent char(1), @not_number int, @nre_tablekey char(18), @not_count int, @retcode int
  
  IF UPPER(@attach_to) = 'DELIVERYINSTRUCTIONS'
  BEGIN
	IF ISNULL(@stp_number, 0) > 0
	BEGIN
		IF ISNULL(@note_update, '') <> ''  --EDI UPDATE ROUTINE
		BEGIN
			UPDATE stops
			   SET stp_comment = REPLACE(stp_comment, @note_update, @note)
			 WHERE stp_number = @stp_number
		END
		ELSE
		BEGIN
			UPDATE stops
			   SET stp_comment = CASE RTRIM(ISNULL(stp_comment,'')) WHEN '' THEN '' ELSE RTRIM(stp_comment) + ' ' END + @note
			 WHERE stp_number = @stp_number
		END
		RETURN 1
	END
	SELECT @attach_to = 'STOP'
  END

  SELECT @ord_hdrnumber = ord_hdrnumber
  FROM orderheader
  WHERE ord_number = @order_number

  IF @ord_hdrnumber IS NULL RETURN -2

  SELECT @nre_tablekey = convert(char(18), @ord_hdrnumber)

  /*
  IF  @attach_to = 'STOP' or  @attach_to = 'COMMODITY'
     BEGIN
       SELECT @stp_number = MAX(stp_number)
       FROM stops
       WHERE ord_hdrnumber = @ord_hdrnumber
       AND cmp_id = @company_id

       IF @stp_number IS NULL RETURN -2

       SELECT @nre_tablekey = @stp_number
     END

  IF @attach_to = 'COMMODITY'
     BEGIN
       IF @commodity_code IS NULL RETURN -2
       
       SELECT @fgt_number = MAX(fgt_number)
       FROM freightdetail
       WHERE stp_number = @stp_number
       AND cmd_code = @commodity_code

       IF @fgt_number IS NULL RETURN -2

       SELECT @nre_tablekey = @fgt_number
     END

  SELECT @ntb_table = 
     CASE UPPER(ISNULL(@attach_to,''))
       WHEN 'ORDER' THEN 'orderheader'
       WHEN 'STOP' THEN 'stops'
       WHEN 'COMMODITY' THEN 'freightdetail'
       ELSE 'x'
     END

  IF @ntb_table = 'x' RETURN -3
  */

  SELECT @ntb_table = 'orderheader' 

  SELECT @not_urgent = 
    CASE UPPER(ISNULL(@note_is_urgent,''))
       WHEN 'Y' THEN 'A'
       WHEN '1' THEN 'A'  --for LTSL2
       ELSE 'N'
    END

  SELECT @applies_to = UPPER(@applies_to)
  IF LEN(RTRIM(@applies_to)) = 0 SELECT @applies_to = 'NONE' 

  IF ISNULL(@note_update, '') <> ''  --EDI UPDATE ROUTINE
  BEGIN
	SELECT @note_sequence = MAX(not_sequence)
	  FROM notes
	 WHERE ntb_table = @ntb_table
	   AND nre_tablekey = @nre_tablekey
	   AND not_text = @note_update
	IF ISNULL(@note_sequence, 0) > 0
	BEGIN
		SET ROWCOUNT 1
		UPDATE notes
		   SET not_text = @note, not_type = @applies_to, not_urgent = @not_urgent, last_updatedby = 'IMPORT', last_updatedatetime = getdate()
		 WHERE ntb_table = @ntb_table AND nre_tablekey = @nre_tablekey and not_sequence = @note_sequence AND not_text = @note_update 
		SELECT @not_count = @@ROWCOUNT
		SET ROWCOUNT 0
		IF @not_count > 0 RETURN 1
	END
  END

  EXEC @not_number = dbo.getsystemnumber 'NOTES',NULL

  SELECT @note_sequence = MAX(not_sequence)
  FROM notes
  WHERE ntb_table = @ntb_table
  AND   nre_tablekey = @nre_tablekey

  IF @note_sequence IS NULL 
    SELECT @note_sequence = 1
  ELSE
    SELECT @note_sequence = @note_sequence + 1
     
  INSERT 
  INTO notes (
      not_number, not_text, not_type,                       --1
      not_urgent, not_expires, ntb_table,                   --2
      nre_tablekey, not_sequence, last_updatedby,            --3
      last_updatedatetime                                   --4
      )
  VALUES (
      @not_number, @note, @applies_to,                       --1
      @not_urgent, '12-31-49 23:59',@ntb_table,              --2
      @nre_tablekey, @note_sequence, 'IMPORT',                --3
      getdate()                                              --4
      )

  SELECT @retcode = @@error
  IF @retcode<>0
     BEGIN
	EXEC dx_log_error 888, 'Update Note Failed', @retcode, @ord_hdrnumber
	return -1
     END
 

  RETURN 1

GO
GRANT EXECUTE ON  [dbo].[dx_add_note] TO [public]
GO
