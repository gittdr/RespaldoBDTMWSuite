SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[addfreight_tmwtrip]	@trailer	VARCHAR(13),
									@ipt_number	VARCHAR(5),
									@cmd_code	VARCHAR(8)
AS
DECLARE	@fgt_number		INT,
        @fgt_number2	INT,
		@ret			SMALLINT,
		@cmd_name		VARCHAR(60),
		@fgt_sequence	INT,
		@stp_number		INT,
		@ord_hdrnumber	INT,
		@move			INT

SELECT @move = mov_number
  FROM legheader
 WHERE lgh_primary_trailer = @trailer AND
       lgh_outstatus = 'PND'
IF @move IS NULL or @move < 1
BEGIN
   SET @ret = -2
   GOTO error
END

SELECT @cmd_name = ISNULL(cmd_name,'UNKNOWN') 
  FROM commodity 
 WHERE cmd_code = @cmd_code
 
--Get system numbers.
EXEC @fgt_number =  dbo.getsystemnumber 'FGTNUM', NULL
EXEC @fgt_number2 =  dbo.getsystemnumber 'FGTNUM', NULL

BEGIN TRAN T1

--Find first pickup event to tie this freight record to. 		
SELECT @stp_number = stp_number,
	   @ord_hdrnumber = ord_hdrnumber
  FROM stops
 WHERE mov_number = @move AND
       stp_type = 'PUP' AND
       stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)
                             FROM stops
                            WHERE mov_number = @move AND
                                  stp_type = 'PUP')
IF @stp_number > 0
BEGIN
   --Get next fgt_sequence for the stop.
   SELECT @fgt_sequence = MAX(fgt_sequence) + 1
     FROM freightdetail
    WHERE stp_number = @stp_number
   IF @fgt_sequence = 0 or @fgt_sequence IS NULL
      SET @fgt_sequence = 1
   --Create new freightdetail record
   INSERT INTO freightdetail (stp_number, fgt_sequence, fgt_number, 					--1	
	                          cmd_code, fgt_description, fgt_reftype, 					--2
	                          fgt_refnum,fgt_pallets_in, 								--3
	                          fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1,	--4	
	                          fgt_carryins2, skip_trigger, fgt_quantity,				--5
	                          fgt_weight, fgt_weightunit, fgt_count,					--6
	                          fgt_countunit, fgt_volume, fgt_volumeunit)				--7
                      VALUES (@stp_number, @fgt_sequence, @fgt_number,				    --1
	                          @cmd_code, @cmd_name, 'IPT#',							    --2
	                          @ipt_number,0,											--3
	                          0, 0, 0,													--4
	                          0, 1, 0,													--5
	                          0, 'LBS', 0,												--6
	                          'PCS', 0, 'GAL')											--7
   IF @@error <> 0
   BEGIN
      SET @ret = -1
      GOTO ERROR
   END
   
   --Add Reference number record
   INSERT INTO referencenumber (ref_tablekey, ref_type, ref_number, ord_hdrnumber, ref_sequence, ref_table)
                        VALUES (@fgt_number, 'IPT#', @ipt_number, @ord_hdrnumber, 1, 'freightdetail')
   IF @@error <> 0
   BEGIN
      SET @ret = -1
      GOTO ERROR
   END
END

--Find last drop event to tie this freight record to. 		
SELECT @stp_number = stp_number,
	   @ord_hdrnumber = ord_hdrnumber
  FROM stops
 WHERE mov_number = @move AND
       stp_type = 'DRP' AND
       stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                             FROM stops
                            WHERE mov_number = @move AND
                                  stp_type = 'DRP')
IF @stp_number > 0
BEGIN
   --Get next fgt_sequence for the stop.
   SELECT @fgt_sequence = MAX(fgt_sequence) + 1
     FROM freightdetail
    WHERE stp_number = @stp_number
   IF @fgt_sequence = 0 or @fgt_sequence IS NULL
      SET @fgt_sequence = 1
   --Create new freightdetail record
   INSERT INTO freightdetail (stp_number, fgt_sequence, fgt_number, 					--1	
	                          cmd_code, fgt_description, fgt_reftype, 					--2
	                          fgt_refnum,fgt_pallets_in, 								--3
	                          fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1,	--4	
	                          fgt_carryins2, skip_trigger, fgt_quantity,				--5
	                          fgt_weight, fgt_weightunit, fgt_count,					--6
	                          fgt_countunit, fgt_volume, fgt_volumeunit)				--7
                      VALUES (@stp_number, @fgt_sequence, @fgt_number2,				    --1
	                          @cmd_code, @cmd_name, 'IPT#',							    --2
	                          @ipt_number,0,											--3
	                          0, 0, 0,													--4
	                          0, 1, 0,													--5
	                          0, 'LBS', 0,												--6
	                          'PCS', 0, 'GAL')											--7
   IF @@error <> 0
   BEGIN
      SET @ret = -1
      GOTO ERROR
   END
   
   --Add Reference number record
   INSERT INTO referencenumber (ref_tablekey, ref_type, ref_number, ord_hdrnumber, ref_sequence, ref_table)
                        VALUES (@fgt_number2, 'IPT#', @ipt_number, @ord_hdrnumber, 1, 'freightdetail')
   IF @@error <> 0
   BEGIN
      SET @ret = -1
      GOTO ERROR
   END
END

COMMIT TRAN T1
	                    
EXEC @ret = update_move_light @move

RETURN 1

ERROR:
   IF @ret = -1
      ROLLBACK TRAN T1
   RETURN @ret
 
GO
GRANT EXECUTE ON  [dbo].[addfreight_tmwtrip] TO [public]
GO
