SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROC [dbo].[dx_add_note_to_stop]
	@stp_number int,
	@note varchar(254),
	@note_is_urgent char(1),
	@applies_to varchar(6)

	
	
AS


DECLARE  @ord_hdrnumber int, @note_sequence int, @ntb_table varchar(18), 
	 @not_urgent char(1), @not_number int, @nre_tablekey char(18), @not_count int, @retcode int

 BEGIN

       IF @stp_number IS NULL RETURN -2

       	SELECT @nre_tablekey = @stp_number
        SELECT @ntb_table = 'stops'
 END

  SELECT @not_urgent = 
    CASE UPPER(ISNULL(@note_is_urgent,''))
       WHEN 'Y' THEN 'A'
       WHEN '1' THEN 'A'  --for LTSL2
       ELSE 'N'
    END

  SELECT @applies_to = UPPER(@applies_to)
  IF LEN(RTRIM(@applies_to)) = 0 SELECT @applies_to = 'NONE' 


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
GRANT EXECUTE ON  [dbo].[dx_add_note_to_stop] TO [public]
GO
