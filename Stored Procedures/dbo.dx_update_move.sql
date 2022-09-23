SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_update_move] (
	@validate char(1),
    @mov_number int,  
	@carrier varchar(8),
	@dispatch_status varchar(6),
	@lgh_type1 varchar(6),
	@ord_hdrnumber int
)
AS 
declare @retcode int, @err_ret int, @evt_number int
 IF @validate = 'I'
 BEGIN
  EXEC dbo.update_move @mov_number
 END
 ELSE
  EXEC dbo.update_move_light @mov_number
  
 /* if carrier is to be assigned, update events, legheader */
  IF @carrier <> 'UNKNOWN'
	BEGIN
	  SELECT @evt_number = 0 
	  WHILE @evt_number is not null
 		BEGIN
		  SELECT @evt_number = MIN(evt_number)
		  FROM event
		  WHERE stp_number in (SELECT stp_number FROM stops where ord_hdrnumber = @ord_hdrnumber
			AND evt_number > @evt_number)
		  IF @evt_number IS NOT NULL
                    BEGIN
			UPDATE event
			SET evt_carrier = @carrier
			WHERE evt_number = @evt_number
		     SELECT @retcode = @@error
		     IF @retcode<>0
    			BEGIN
			  exec dx_log_error 0, 'Import update carrier in event Failed', @retcode, ''
			 IF @validate != 'N'
                           BEGIN
			         SELECT @err_ret = -1
	   			 GOTO ERROR_EXIT
	                   END
       			 ELSE
           			RETURN -1
    			END
		   END
		END
	  UPDATE legheader
	  SET lgh_carrier = @carrier, lgh_outstatus = @dispatch_status, lgh_type1 = @lgh_type1
	  WHERE mov_number = @mov_number
	  SELECT @retcode = @@error
	  IF @retcode<>0
    	    BEGIN
		EXEC dx_log_error 0, 'Import update carrier in leg Failed', @retcode, ''
		IF @validate != 'N'
                  BEGIN
                   SELECT @err_ret = -1
	   	   GOTO ERROR_EXIT
                  END
       		ELSE
           	  RETURN -1
    	    END

	  EXEC update_assetassignment @mov_number
  END

  IF @carrier = 'UNKNOWN' AND @lgh_type1 <> 'UNK'
	BEGIN
	  UPDATE legheader
	  SET lgh_type1 = @lgh_type1
	  WHERE mov_number = @mov_number
	  SELECT @retcode = @@error
	  IF @retcode<>0
	    BEGIN
		EXEC dx_log_error 0, 'Import update LegType1 in leg Failed', @retcode, ''
		IF @validate != 'N'
		  BEGIN
		   SELECT @err_ret = -1
		   GOTO ERROR_EXIT
		  END
		ELSE
		  RETURN -1
 	    END
	END
	
RETURN 1

ERROR_EXIT:
   IF @mov_number > 0
     EXEC purge_delete @mov_number,0
   SELECT 'ERROR dx_create_order_from_stops',@mov_number
   RETURN @err_ret 

GO
GRANT EXECUTE ON  [dbo].[dx_update_move] TO [public]
GO
