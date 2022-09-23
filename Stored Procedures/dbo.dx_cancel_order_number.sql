SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROC [dbo].[dx_cancel_order_number]
        @ord_number varchar(12),
	@modify_order_number char(1)
AS

DECLARE  @new_ord_number varchar(12), @xpos int, @suffix char(2), @ord_hdrnumber int,
         @mov_number int, @ord_status varchar(6), @retcode int

  SELECT @modify_order_number = 
    CASE UPPER(@modify_order_number)
      WHEN 'Y' THEN 'Y'
      WHEN 'X' Then 'X'
      WHEN 'R' Then 'R'
      ELSE 'N'
    END
     

  SELECT @ord_hdrnumber = ord_hdrnumber, @mov_number = mov_number, @ord_status = ord_status
      FROM orderheader
      WHERE ord_number = @ord_number
  IF @ord_hdrnumber IS NULL RETURN -2

  IF (SELECT code
      FROM labelfile
      WHERE labeldefinition = 'DispStatus'
      AND abbr = @ord_status) >= 325
     RETURN -4
  
IF @modify_order_number = 'Y'
 BEGIN
  SELECT @new_ord_number = MAX(ord_number)
     FROM orderheader
     WHERE ord_number like @ord_number+'%'


  IF @new_ord_number = @ord_number
     SELECT @new_ord_number = @ord_number+'X0'
  ELSE
    BEGIN
      SELECT @xpos = CHARINDEX('X',@new_ord_number)

      IF @xpos = 0  SELECT @new_ord_number = @ord_number+'X0'
      ELSE
        BEGIN
          SELECT @suffix = 
            CASE SUBSTRING(@new_ord_number,@xpos + 1,1)
		WHEN '0' THEN 'X1'
		WHEN '1' THEN 'X2'
		WHEN '2' THEN 'X3'
		WHEN '3' THEN 'X4'
		WHEN '4' THEN 'X5'
		WHEN '5' THEN 'X6'
		WHEN '6' THEN 'X7'
		WHEN '7' THEN 'X8'
		WHEN '8' THEN 'X9'
		ELSE 'XX'
	    END
	 IF @suffix = 'XX' RETURN -3
	 SELECT @new_ord_number = @ord_number + @suffix
      END
      
    END

    UPDATE orderheader
    SET ord_number = @new_ord_number
    WHERE ord_hdrnumber = @ord_hdrnumber
    
 END

IF @modify_order_number IN ('R','N')
 BEGIN
	DECLARE @stp_number INT
	SELECT @stp_number = 0
	WHILE 1=1
	BEGIN
		SELECT @stp_number = MIN(stp_number) FROM stops WHERE mov_number = @mov_number AND stp_number > @stp_number
		IF @stp_number IS NULL BREAK
		UPDATE stops
		   SET stp_status = 'NON', stp_departure_status = 'NON', skip_trigger = 1
		 WHERE stp_number = @stp_number
	END
 END

IF @modify_order_number = 'X'
 BEGIN
    EXEC purge_delete @mov_number,0
    RETURN 1
 END
ELSE
 BEGIN
	IF (SELECT UPPER(SUBSTRING(gi_string1, 1,1)) 
	      FROM generalinfo WITH (NOLOCK) 
	     WHERE gi_name = 'ProcessOutbound204') = 'Y'
		UPDATE legheader
		   SET lgh_carrier = 'UNKNOWN'
		 WHERE ord_hdrnumber = @ord_hdrnumber

		 declare @ordcount int
		 declare @errormsg varchar(255)
		 select @ordcount = count(distinct ord_hdrnumber) from stops where mov_number = @mov_number and isNull(ord_hdrnumber,0) > 0
		if @ordcount > 1
			exec DeconsolidateOrder_sp @ord_hdrnumber, @mov_number, @errormsg

	UPDATE orderheader
   	SET ord_status = CASE @modify_order_number WHEN 'R' THEN 'REJ' ELSE 'CAN' END
	  , ord_invoicestatus = 'XIN'
    	WHERE ord_hdrnumber = @ord_hdrnumber
 END


SELECT @retcode = @@error
IF @retcode <> 0
 BEGIN
	EXEC dx_log_error 888, 'Cancel order Failed', @retcode, @ord_hdrnumber 
	return -1
 END
    /* update ord fixes assignments, etc. */
 EXEC update_move @mov_number
 --EXEC update_ord @mov_number,'UNK'

 RETURN 1


GO
GRANT EXECUTE ON  [dbo].[dx_cancel_order_number] TO [public]
GO
