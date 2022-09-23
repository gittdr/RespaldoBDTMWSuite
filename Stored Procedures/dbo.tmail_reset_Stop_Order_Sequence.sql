SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_reset_Stop_Order_Sequence] @vs_mov_number varchar(12)
AS 
DECLARE @i                 int,
	@vi_temp_ord_hdrnumber int,
	@vi_hold_ord_hdrnumber int,
	@vi_stp_sequence       int,
	@vi_mov_number 		   int,
	@o						int

SET NOCOUNT ON

IF ISNULL(@vs_mov_number, 0) = 0 
	RAISERROR ('Move number must be specified', 16, 1)

SET @vi_mov_number = CONVERT(int, @vs_mov_number)

-- Table used to calculate the stops.stp_sequence field
DECLARE @tbl_stp_sequence table (temp_stp_number int, temp_stp_mfh_sequence int, temp_ord_hdrnumber int, temp_stp_sequence int)

-- Set the stops.stp_sequence fields 
INSERT INTO @tbl_stp_sequence (temp_stp_number, temp_stp_mfh_sequence, temp_ord_hdrnumber)
SELECT stp_number, stp_mfh_sequence, ord_hdrnumber
FROM stops (NOLOCK)
WHERE mov_number = @vi_mov_number

SET @vi_hold_ord_hdrnumber = 0
SET @vi_stp_sequence = 0


SELECT @o = ISNULL(MIN(ISNULL(temp_ord_hdrnumber,-1)),-1)
FROM @tbl_stp_sequence

WHILE @o > -1
	BEGIN

		SET @vi_stp_sequence = 0
		SELECT @vi_temp_ord_hdrnumber = @o

		SELECT @i = ISNULL(MIN(ISNULL(temp_stp_mfh_sequence,0)),0)
		FROM @tbl_stp_sequence where @vi_temp_ord_hdrnumber = temp_ord_hdrnumber
		
		WHILE @i > 0
			BEGIN
			
				
				IF (ISNULL(@vi_temp_ord_hdrnumber, 0) = 0)
					-- Non-billable stop, so set stp_sequence = 0
					SET @vi_stp_sequence = 0
				ELSE
					SET @vi_stp_sequence = @vi_stp_sequence + 1	
				
				UPDATE @tbl_stp_sequence
				SET temp_stp_sequence = @vi_stp_sequence
				WHERE temp_stp_mfh_sequence = @i
				
				SELECT @i = ISNULL(MIN(ISNULL(temp_stp_mfh_sequence,0)),0)
				FROM @tbl_stp_sequence
				WHERE temp_stp_mfh_sequence > @i
					AND @vi_temp_ord_hdrnumber = temp_ord_hdrnumber
			
			END

			SELECT @o = ISNULL(MIN(ISNULL(temp_ord_hdrnumber,-1)),-1)
			FROM @tbl_stp_sequence
			WHERE temp_ord_hdrnumber > @o

	END
					
		
		UPDATE stops
		SET stp_sequence = temp_stp_sequence
		FROM @tbl_stp_sequence
		WHERE stops.mov_number = @vi_mov_number
			AND stp_mfh_sequence = temp_stp_mfh_sequence
		
GO
GRANT EXECUTE ON  [dbo].[tmail_reset_Stop_Order_Sequence] TO [public]
GO
