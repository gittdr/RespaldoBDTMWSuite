SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tmail_FindFgtDetail4]
      @p_stp_number VARCHAR(200),
      @p_fgt_sequence VARCHAR(6),
      @p_cmd_code VARCHAR(8),
      @p_fgt_reftype VARCHAR(6),
      @p_fgt_refnum VARCHAR(30),
	  @p_flags VARCHAR(12),
      @p_SeparateFieldsOn VARCHAR(2000),
      @p_cmdmisc1 VARCHAR(12),
      @p_cmdmisc2 VARCHAR(12),
      @p_cmdmisc3 VARCHAR(12),
      @p_cmdmisc4 VARCHAR(12)

AS
/**
 * 
 * NAME:
 * dbo.tmail_FindFgtDetail
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * verifies that the stop number is specified and exists
 * only output is error rasied when one of the above conditions is not met.
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * fgt_number  The first sequenced freight detail number found by specified criteria
 *
 * PARAMETERS:
 * 001 - @p_stp_number VARCHAR(11), input, null;
 *       required for proper functionality,
 *       the stop number to find freight detail for
 * 002 - @p_fgt_sequence VARCHAR(6), input, null;
 *       optional, a specific freight detail on the stop
 * 003 - @p_cmd_code VARCHAR(8), input, null;
 *       optional, a specific commodity code on the stop
 * 004 - @p_fgt_reftype VARCHAR(6),
 *       optional, a reference type code
 * 005 - @p_fgt_refnum VARCHAR(30)
 *       optional, a specific reference number
 * 006 - @p_flags VARCHAR(12)
 *       optional, options
 * 007 - @p_SeparateFieldsOn VARCHAR(2000)
 *       optional, if flag 2 is set then a comma dilimited list of fields to separate on, if not fields are specified then the load assignment default separation fields will be used.
 * 
 * REFERENCES:
 * none
 * 
 * FLAGS:
 * 1 = if multiple rows match, return the one with the lowest sequence number
 * 2 = Find in adjacent stops
 *
 * REVISION HISTORY:
 * 10/06/2005.01 – PTS 30101 - Chris Harshman – initial version
 * 10/17/2005.02 - PTS 30101 - David Gudat - Converted to general TotalMail View.
 * 07/11/07      - PTS 38187 - David Gudat - Added SeparateOnFields parameter
 * 12/06/10 - PTS 54559 - Michalynn Kelly - Added c
 **/
 
SET NOCOUNT ON 
 
DECLARE
  @v_error_msg   VARCHAR(200),
  @v_fgt_number  INT,
  @v_Flags INT

DECLARE     @sExec varchar(2000),
            @lghNum int,
            @lStopSeq int,
            @lStopNumber int,
            @ToBeDeleted int

CREATE TABLE #tmp0 (StopNumber int, StopMoveSeq int, ToBeDeleted int) 
CREATE TABLE #tmp1 (StopNumber int, StopMoveSeq int, ToBeDeleted int) 
  
BEGIN

      SET NOCOUNT ON
      
      IF ISNULL(@p_stp_number, 0) = 0
      BEGIN
            SET @v_error_msg = 'Could not find freight detail, must specify stop number.'
            RAISERROR (@v_error_msg, 16, 1)
            RETURN 1
      END
      SET @v_Flags = CONVERT(INT, @p_flags)
      
      --Convert blank to NULL
      IF ISNULL(@p_fgt_sequence, '') = ''       SET @p_fgt_sequence = NULL
      IF ISNULL(@p_cmd_code, '') = ''             SET @p_cmd_code = NULL
      IF ISNULL(@p_cmdmisc1, '') = ''             SET @p_cmdmisc1 = NULL
      IF ISNULL(@p_cmdmisc2, '') = ''             SET @p_cmdmisc2 = NULL
      IF ISNULL(@p_cmdmisc3, '') = ''             SET @p_cmdmisc3 = NULL
      IF ISNULL(@p_cmdmisc4, '') = ''             SET @p_cmdmisc4 = NULL
      IF ISNULL(@p_fgt_reftype, '') = ''            SET @p_fgt_reftype = NULL
      IF ISNULL(@p_fgt_refnum, '') = ''            SET @p_fgt_refnum = NULL

      IF (@v_Flags & 2) <> 0
            BEGIN
                  SELECT @lghNum = lgh_number, @lStopSeq = stp_mfh_sequence 
                  FROM stops (NOLOCK)
                  WHERE stp_number = @p_stp_number
                  
                  --Get all stops for the leg header
                  INSERT INTO #tmp0
                        EXEC tmail_load_assign5_sp '', '', @lghNum, '', '', '', '', '', 'StopNumber, StopMoveSeq, ToBeDeleted'

                  --Get duplicate stops
                  INSERT INTO #tmp1
                        EXEC tmail_load_assign5_sp '', '', @lghNum, '2097152', '', '', '', @p_SeparateFieldsOn, 'StopNumber, StopMoveSeq, ToBeDeleted'
      
                  --Update duplicate stops ToBeDeleted to 1
                  UPDATE #tmp0
                        SET ToBeDeleted = 1 
                        FROM #tmp1
                        RIGHT JOIN #tmp0 ON #tmp1.StopMoveSeq = #tmp0.StopMoveSeq
                        WHERE NOT EXISTS (SELECT NULL FROM #tmp0 WHERE #tmp1.StopMoveSeq = #tmp0.StopMoveSeq)
      
                  --add all duplicate stops after the stop passed in to the list of stops to retrieve
                  SELECT @lStopSeq = MIN(StopMoveSeq) FROM #tmp0 WHERE StopMoveSeq > @lStopSeq
                  WHILE ISNULL(@lStopSeq, 0) > 0 
                        BEGIN
                              SELECT @lStopNumber = StopNumber, @ToBeDeleted = ToBeDeleted FROM #tmp0 WHERE StopMoveSeq = @lStopSeq
                            if @ToBeDeleted = 1
                                    SET @p_stp_number = @p_stp_number +', ' + CONVERT(varchar(12), @lStopNumber)
                              else
                                    break
            
                              SELECT @lStopSeq = MIN(StopMoveSeq) FROM #tmp0 WHERE StopMoveSeq > @lStopSeq
                        END
            END

      IF (@v_Flags & 1) <> 0 SET ROWCOUNT 1

      SET @sExec = 'SELECT fgt_number FreightNumber, fgt_sequence FreightSequenceOut, stp_number StopNumberOut, ISNULL(fgt_parentcmd_fgt_number, fgt_number) ParentNumberOut
                                                                              FROM freightdetail (NOLOCK), commodity (NOLOCK)
                                                                                          WHERE stp_number in (' + @p_stp_number + ')
                                                                                                            AND freightdetail.cmd_code = commodity.cmd_code
                                                                                                            AND ISNULL(fgt_sequence, -1) = ' + CASE WHEN ISNULL(@p_fgt_sequence, -1) = -1 THEN 'ISNULL(fgt_sequence, -1)' ELSE @p_fgt_sequence END + '
                                                                                                            AND ISNULL(freightdetail.cmd_code, ''~'')    = ' + CASE WHEN ISNULL(@p_cmd_code, '') = '' THEN 'ISNULL(freightdetail.cmd_code, ''~'')' ELSE '''' + @p_cmd_code + '''' END + '
                                                                                                            AND ISNULL(fgt_reftype, ''~'') = ' + CASE WHEN ISNULL(@p_fgt_reftype, '') = '' THEN 'ISNULL(fgt_reftype, ''~'')' ELSE '''' + @p_fgt_reftype + '''' END + '
                                                                                                            AND ISNULL(fgt_refnum, ''~'')  = ' + CASE WHEN ISNULL(@p_fgt_refnum, '') = '' THEN 'ISNULL(fgt_refnum, ''~'')' ELSE '''' + @p_fgt_refnum + '''' END + '
                                                                                                            AND ISNULL(cmd_misc1,''~'') = ' +CASE WHEN ISNULL(@p_cmdmisc1,'') = '' THEN 'ISNULL(cmd_misc1,''~'')' ELSE''''+ @p_cmdmisc1 +'''' END +'
                                                                                                            AND ISNULL(cmd_misc2,''~'') = ' +CASE WHEN ISNULL(@p_cmdmisc2,'') = '' THEN 'ISNULL(cmd_misc2,''~'')' ELSE''''+ @p_cmdmisc2 +'''' END +'
                                                                                                            AND ISNULL(cmd_misc3,''~'') = ' +CASE WHEN ISNULL(@p_cmdmisc3,'') = '' THEN 'ISNULL(cmd_misc3,''~'')' ELSE''''+ @p_cmdmisc3 +'''' END +'
                                                                                                            AND ISNULL(cmd_misc4,''~'') = ' +CASE WHEN ISNULL(@p_cmdmisc4,'') = '' THEN 'ISNULL(cmd_misc4,''~'')' ELSE''''+ @p_cmdmisc4 +'''' END +'
                              ORDER BY fgt_sequence'

      EXEC (@sExec)

      IF (@v_Flags & 1) <> 0  SET ROWCOUNT 0

END

GO
GRANT EXECUTE ON  [dbo].[tmail_FindFgtDetail4] TO [public]
GO
