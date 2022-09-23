SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.update_trlonlgh    Script Date: 8/20/97 1:59:55 PM ******/
CREATE PROC [dbo].[update_trlonlgh] @lgh int, @primary_trl char (13) OUT, @primary_pup char (13) OUT, @splitpup char(1) OUT, @chassis char (13) OUT, @chassis2 char (13) OUT, @dolly char (13) OUT, @dolly2 char (13) OUT, @trailer3 char (13) OUT, @trailer4 char (13) OUT
-- JET - 5/8/01 - created a new stored procedure called update_trlonstops to do correct all events/stops for a trailer
--	change.  That stored proc will be called by update move for Order Entry.  Update move and update move light 
--	will call this procedure to look up the loaded trailer on a segment, and update the trailer correctly on the
--	leg header.
-- JET - 5/9/02 - added code to make sure a trailer ID is assigned on the leg header for a deadhead split.
--	Schneider needs the information to make sure the trailer has been assigned on the deadhead portion of the trip
--  JLB PTS 49323 adding in new trailing equipment
AS

DECLARE @trlchange SMALLINT, 
        @stpnumber INT, 
        @deadhead  SMALLINT, 
-- PTS 30853 -- BL (start)
	@stp_mfh_sequence INT
-- PTS 30853 -- BL (end)

SELECT @trlchange = COUNT(stp_number) 
  FROM stops 
 WHERE lgh_number = @lgh AND 
       stp_event in ('CTR', 'HCT')

SELECT @splitpup = 'N'
IF @trlchange IS NULL OR @trlchange < 1
BEGIN
     -- added new check for stop count for the segment
     SELECT @deadhead = COUNT(stp_number) 
       FROM stops 
      WHERE lgh_number = @lgh 
     
     -- if stop count is not 2, then treat trip as in the past
     IF @deadhead <> 2 
        SELECT @splitpup = 'Y'
END

-- PTS 30853 -- BL (start)
--SELECT @stpnumber = MIN(stp_number) 
--  FROM stops 
-- WHERE (stp_type = 'PUP' OR 
--        stp_loadstatus = 'LD' OR 
--        stp_event in ('HLT', 'HCT')) AND 
--       lgh_number = @lgh 

SELECT @stp_mfh_sequence = MIN(stp_mfh_sequence) 
  FROM stops 
 WHERE (stp_type = 'PUP' OR 
        (stp_loadstatus = 'LD' AND stp_mfh_sequence > (SELECT MIN(stp_mfh_sequence) FROM stops WHERE lgh_number = @lgh)) OR 
        stp_event in ('HLT', 'HCT')) AND 
       lgh_number = @lgh 
       
 IF isnull(@stp_mfh_sequence, 0) <> 0
	SELECT @stpnumber = stp_number
	FROM stops
	WHERE lgh_number = @lgh
	AND stp_mfh_sequence = @stp_mfh_sequence
-- PTS 30853 -- BL (end)
-- JLB PTS 34034
-- IF @deadhead = 2 
--      SELECT @stpnumber = MIN(stp_number) 
--        FROM stops 
--       WHERE lgh_number = @lgh 

 ELSE 
   BEGIN
     SELECT @stp_mfh_sequence = MIN(stp_mfh_sequence) 
       FROM stops, event 
      WHERE stops.stp_number = event.stp_number
        AND event.evt_sequence = 1
        AND event.evt_trailer1 <> 'UNKNOWN'
        AND lgh_number = @lgh
      --PTS 39449 SGB 10/03/07  
      --IF isnull(@stp_mfh_sequence, 0) <> 0
      IF isnull(@stp_mfh_sequence, 0) = 0
     	SELECT @stpnumber = stp_number
     	FROM stops
     	WHERE lgh_number = @lgh
     	AND stp_mfh_sequence = 1
      ELSE
     	SELECT @stpnumber = stp_number
     	FROM stops
     	WHERE lgh_number = @lgh
     	AND stp_mfh_sequence = @stp_mfh_sequence
   END
--end 34034


SELECT @primary_trl = evt_trailer1, 
       @primary_pup = evt_trailer2,
       @chassis = evt_chassis,
       @chassis2 = evt_chassis2,
       @dolly = evt_dolly,
       @dolly2 = evt_dolly2,
       @trailer3 = evt_trailer3,
       @trailer4 = evt_trailer4
  FROM event 
 WHERE stp_number = @stpnumber 
-- PTS 24832 -- BL (start)
and evt_sequence = 1
-- PTS 24832 -- BL (end)

IF @primary_trl IS NULL OR RTRIM(@primary_trl) = ''
   SELECT @primary_trl = 'UNKNOWN'
IF @primary_pup IS NULL OR RTRIM(@primary_pup) = ''
   SELECT @primary_pup = 'UNKNOWN'
IF @chassis IS NULL OR RTRIM(@chassis) = ''
   SELECT @chassis = 'UNKNOWN'
IF @chassis2 IS NULL OR RTRIM(@chassis2) = ''
   SELECT @chassis2 = 'UNKNOWN'
IF @dolly IS NULL OR RTRIM(@dolly) = ''
   SELECT @dolly = 'UNKNOWN'
IF @dolly2 IS NULL OR RTRIM(@dolly2) = ''
   SELECT @dolly2 = 'UNKNOWN'
IF @trailer3 IS NULL OR RTRIM(@trailer3) = ''
   SELECT @trailer3 = 'UNKNOWN'
IF @trailer4 IS NULL OR RTRIM(@trailer4) = ''
   SELECT @trailer4 = 'UNKNOWN'


GO
GRANT EXECUTE ON  [dbo].[update_trlonlgh] TO [public]
GO
