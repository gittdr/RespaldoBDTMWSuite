SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  PROC [dbo].[admin_end_of_move] @mov_number int,
                                                                                      @lgh_number int,
			                      @stp_mfh_sequence int,
                                                                                      @driver1 varchar(8),
                                                                                      @driver2 varchar(8),
                                                                                      @tractor varchar(8),
                                                                                      @trailer1 varchar(13),
                                                                                      @trailer2 varchar(13),
				@carrier varchar(8)
AS

DECLARE @new_move int,
                      @ord_count int,
                      @ord_hdrnumber int,
                      @stp_number int,
                      @fgt_number int,
                      @evt_number int,
                      @seq int,
                      @stp_city int,
                      @cmp_id varchar(8),
                      @stp_zip varchar(9),
	 @stp_datetime datetime,
	 @stp_xdu datetime,
	 @stp_xdl datetime,
	 @stp_transfer_stp int,
                      @stp_seq int,
                      @new_lgh int,
	@upd_stp_number int,
	@evt_driver1 varchar(8),
	@evt_driver2 varchar(8),
	@evt_tractor varchar(8),
	@evt_trailer1 varchar(13),
	@evt_trailer2 varchar(13),
	@evt_carrier varchar(8),
                     @xduxdl_count int

CREATE TABLE #prev_orders
(ord_hdrnumber int null)

CREATE TABLE #post_orders
(ord_hdrnumber int null)

CREATE TABLE #orders
(ord_hdrnumber int null)

CREATE TABLE #move_orders
(ord_hdrnumber int null)

BEGIN TRANSACTION                      

INSERT INTO #prev_orders
     SELECT DISTINCT ord_hdrnumber
         FROM stops
      WHERE mov_number = @mov_number AND
                        stp_mfh_sequence <= @stp_mfh_sequence AND
                        ord_hdrnumber > 0

INSERT INTO #post_orders
     SELECT DISTINCT ord_hdrnumber
         FROM stops
      WHERE mov_number = @mov_number AND
                        stp_mfh_sequence > @stp_mfh_sequence AND
                        ord_hdrnumber > 0

INSERT INTO #orders
     SELECT #post_orders.ord_hdrnumber
         FROM #post_orders, #prev_orders
      WHERE #post_orders.ord_hdrnumber = #prev_orders.ord_hdrnumber

SELECT @ord_count = Count(*)
     FROM #orders

INSERT INTO #move_orders
     SELECT DISTINCT #post_orders.ord_hdrnumber
         FROM #post_orders
     WHERE NOT exists (SELECT * FROM #prev_orders where #post_orders.ord_hdrnumber = #prev_orders.ord_hdrnumber )

EXECUTE @new_move = GetSystemNumber 'MOVNUM',''
EXECUTE @new_lgh = GetSystemNumber 'LEGHDR',''

IF @new_move > 0
BEGIN
     SELECT @cmp_id = cmp_id,
                       @stp_city = stp_city,
                       @stp_zip = stp_zipcode,
                       @stp_datetime = stp_departuredate
          FROM stops
      WHERE mov_number = @mov_number AND
                        stp_mfh_sequence = @stp_mfh_sequence

     SET @stp_xdu = DATEADD( mi , 1, @stp_datetime) 
     SET @stp_xdl = DATEADD(mi, 2, @stp_datetime)

     DECLARE upd_cursor CURSOR FOR
          SELECT stp_number
               FROM stops
           WHERE mov_number = @mov_number AND
                             stp_mfh_sequence > @stp_mfh_sequence
     OPEN upd_cursor
     FETCH NEXT FROM upd_cursor INTO @upd_stp_number
     WHILE @@FETCH_STATUS = 0
     BEGIN
          SELECT @evt_driver1 = evt_driver1,
                            @evt_driver2 = evt_driver2,
                            @evt_tractor = evt_tractor,
                            @evt_trailer1 = evt_trailer1,
                            @evt_trailer2 = evt_trailer2,
                            @evt_carrier = evt_carrier
               FROM event
           WHERE stp_number = @upd_stp_number AND
                             evt_sequence = 1
    
          UPDATE stops
                   SET mov_number = @new_move,
                             lgh_number = @new_lgh,
                             stp_mfh_sequence = (stp_mfh_sequence - @stp_mfh_sequence + @ord_count)
            WHERE stp_number = @upd_stp_number

          UPDATE event 
                   SET evt_driver1 = @evt_driver1,
                             evt_driver2 = @evt_driver2,
                             evt_tractor = @evt_tractor,
                             evt_trailer1 = @evt_trailer1,
                             evt_trailer2 = @evt_trailer2,
                             evt_carrier = @evt_carrier,
                             evt_mov_number = @new_move
           WHERE stp_number = @upd_stp_number AND
                             evt_sequence = 1

          FETCH NEXT FROM upd_cursor INTO @upd_stp_number
     END
     CLOSE upd_cursor
     DEALLOCATE upd_cursor
     
     DECLARE ins_cursor CURSOR FOR
          SELECT ord_hdrnumber FROM #orders
     OPEN ins_cursor
     FETCH NEXT FROM ins_cursor INTO @ord_hdrnumber

     SET @seq = 1
     WHILE @@FETCH_STATUS = 0
     BEGIN
          EXECUTE @stp_number = GetSystemNumber 'STPNUM',''
          SET @stp_transfer_stp = @stp_number
          SET @stp_seq = @stp_mfh_sequence + @seq
          SET @stp_xdu = DATEADD( ss , 1, @stp_xdu) 
          EXECUTE @fgt_number = GetSystemNumber 'FGTNUM',''
          EXECUTE @evt_number = GetSystemNumber 'EVTNUM',''
          EXECUTE aeom_insert_stop @mov_number, @ord_hdrnumber, @lgh_number, @stp_number, @fgt_number,
                                                                     @evt_number, 'XDU', 0, @stp_seq,
                                                                     'UNKNOWN', @cmp_id, @stp_city, @stp_zip, NULL, NULL, NULL, NULL, NULL,
                                                                     @stp_xdu, @stp_xdu, @stp_xdu, 0, NULL, 0, NULL, 0, NULL, 0, 
                                                                      NULL, @stp_transfer_stp,1, @driver1, @driver2, @tractor, @trailer1, @trailer2,
                                                                     @carrier, 'AEM'
          EXECUTE @stp_number = GetSystemNumber 'STPNUM',''
          EXECUTE @fgt_number = GetSystemNumber 'FGTNUM',''
          EXECUTE @evt_number = GetSystemNumber 'EVTNUM',''
          SET @stp_xdl = DATEADD(ss, 1, @stp_xdl)
          EXECUTE aeom_insert_stop @new_move, @ord_hdrnumber, @new_lgh, @stp_number, @fgt_number,
                                                                     @evt_number, 'XDL', 0, @seq,
                                                                     'UNKNOWN', @cmp_id, @stp_city, @stp_zip, NULL, NULL, NULL, NULL, NULL, 
                                                                     @stp_xdl, @stp_xdl, @stp_xdl, 0, NULL, 0, NULL, 0, NULL, 0, 
                                                                      NULL, @stp_transfer_stp, 2, @driver1, @driver2, @tractor, @trailer1, @trailer2,
                                                                     @carrier, 'AEM'
          SET @seq = @seq + 1
          FETCH NEXT FROM ins_cursor INTO @ord_hdrnumber
     END

     CLOSE ins_cursor
     DEALLOCATE ins_cursor

     UPDATE orderheader
               SET mov_number = @new_move
       WHERE ord_hdrnumber IN (SELECT ord_hdrnumber from #move_orders) AND
                         mov_number = @mov_number
END

EXECUTE update_assetassignment @mov_number
EXECUTE update_move_light @mov_number

EXECUTE update_assetassignment @new_move
EXECUTE update_move_light @new_move

DROP TABLE #prev_orders
DROP TABLE #post_orders
DROP TABLE #orders
DROP TABLE #move_orders

COMMIT TRANSACTION

GO
GRANT EXECUTE ON  [dbo].[admin_end_of_move] TO [public]
GO
