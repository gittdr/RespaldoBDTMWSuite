SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[transfertrip_cancel] @mov_number INT,
                                    @lgh_number INT,
				    @original_mov_number INT,
				    @original_lgh_number INT,
                                    @cancel_type VARCHAR(3)
AS

DECLARE @min_stp_number INT,
	@stp_transfer_stp INT,
	@ord_hdrnumber INT

IF @cancel_type = 'TRN'
BEGIN
   BEGIN transaction
   SET @min_stp_number = 0
   WHILE 1=1
   BEGIN

      SELECT @min_stp_number = MIN(stp_number)
        FROM stops
       WHERE mov_number = @mov_number AND
             lgh_number = @lgh_number AND
             stp_transferred = 'Y' AND
             stp_number > @min_stp_number

      IF @min_stp_number IS NULL
         BREAK

      SELECT @stp_transfer_stp = stp_transfer_stp,
             @ord_hdrnumber = ord_hdrnumber
        FROM stops
       WHERE stp_number = @min_stp_number

      IF @stp_transfer_stp > 0
      BEGIN
         DELETE FROM stops
	   WHERE stp_transferred = 'Y' AND
	        mov_number = @original_mov_number AND
	        lgh_number = @original_lgh_number AND
	        stp_transfer_stp = @stp_transfer_stp
         IF @@ERROR <> 0
         BEGIN
            ROLLBACK transaction
            RETURN -1
         END

         DELETE FROM stops
          WHERE stp_transferred = 'Y' AND
	        mov_number = @mov_number AND
	        lgh_number = @lgh_number AND
	        stp_transfer_stp = @stp_transfer_stp
         IF @@ERROR <> 0
         BEGIN
            ROLLBACK transaction
            RETURN -1
         END

         UPDATE stops
	    SET mov_number = @original_mov_number,
	        lgh_number = @original_lgh_number
          WHERE mov_number = @mov_number AND
	        lgh_number = @lgh_number AND
	        ord_hdrnumber = @ord_hdrnumber
         IF @@ERROR <> 0
         BEGIN
            ROLLBACK transaction
            RETURN -1
         END
      END
   END
       
   COMMIT transaction
END

IF @cancel_type = 'AEM'
BEGIN
   BEGIN transaction
   SET @min_stp_number = 0
   WHILE 1=1
   BEGIN

      SELECT @min_stp_number = MIN(stp_number)
        FROM stops
       WHERE mov_number = @mov_number AND
             lgh_number = @lgh_number AND
             stp_transfer_type = 'AEM' AND
             stp_number > @min_stp_number

      IF @min_stp_number IS NULL
         BREAK

      SELECT @stp_transfer_stp = stp_transfer_stp,
             @ord_hdrnumber = ord_hdrnumber
        FROM stops
       WHERE stp_number = @min_stp_number

      IF @stp_transfer_stp > 0
      BEGIN
         DELETE FROM stops
	   WHERE stp_transfer_type = 'AEM' AND
	        mov_number = @original_mov_number AND
	        lgh_number = @original_lgh_number AND
	        stp_transfer_stp = @stp_transfer_stp
         IF @@ERROR <> 0
         BEGIN
            ROLLBACK transaction
            RETURN -1
         END

         DELETE FROM stops
          WHERE stp_transfer_type = 'AEM' AND
	        mov_number = @mov_number AND
	        lgh_number = @lgh_number AND
	        stp_transfer_stp = @stp_transfer_stp
         IF @@ERROR <> 0
         BEGIN
            ROLLBACK transaction
            RETURN -1
         END

         UPDATE stops
	    SET mov_number = @original_mov_number,
	        lgh_number = @original_lgh_number
          WHERE mov_number = @mov_number AND
	        lgh_number = @lgh_number AND
	        ord_hdrnumber = @ord_hdrnumber
         IF @@ERROR <> 0
         BEGIN
            ROLLBACK transaction
            RETURN -1
         END
      END
   END
       
   COMMIT transaction
END

RETURN 0

GO
GRANT EXECUTE ON  [dbo].[transfertrip_cancel] TO [public]
GO
