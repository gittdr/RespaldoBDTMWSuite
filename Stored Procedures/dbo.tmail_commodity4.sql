SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 * 
 * NAME:
 * dbo.tmail_commodity4
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls all commodities for a specified stop number
 *
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * Commodity Information
 *
 * PARAMETERS:
 * 001 - @stop_nbr_parm, varchar(200);
 *       May be a stop number or a comma delimited list of Stop Numbers
 * 002 - @fgt_sequence_parm, varchar(20);
 *		 Freigth Sequence to look up
 * 003 - @Flags varchar(12);
 *		 1 = Return for adjacent stops
 *		 2 = Ignore 0 Volume
 * 004 - @SeparateFieldsOn, varchar(1000);
 *		 Field list to separate adjacent stops
 *
 * REVISION HISTORY:
 * 03/31/04      - Created:	- Matthew Zerefos  
 * 08/18/04      - Fixed:   - jgf - so it can do ALL or ONE
 * 02/04/06      - 30449    - DWG - Changed to Accept list of Stop Numbers.
 *                                  Added return of Freight Sequence and stop number
 * 01/11/07      - 38187    - DWG - Added Flags and SeparateOnFields parameters
 * 10/20/09			Added	- MRK - Added fgt_parentcmd_fgt_number for fuel client and fgt_unit 
 * 09/28/11		 - 59222	- DWG - Added Flag 2 for Ignore zero Volume records
 **/

/* tmail_commodity3 **************************************************************
** 
*********************************************************************************/

CREATE PROCEDURE [dbo].[tmail_commodity4] @stop_nbr_parm varchar(200),
                                      @fgt_sequence_parm varchar(20),
									  @Flags varchar(12),
									  @SeparateFieldsOn varchar(1000)

AS

SET NOCOUNT ON 

DECLARE @stop_nbr int, 
		@fgt_sequence int,
		@sExec varchar(2000),
		@lFlags int,
		@lghNum int,
		@lStopSeq int,
		@lStopNumber int,
		@ToBeDeleted int

CREATE TABLE #tmp0 (StopNumber int, StopMoveSeq int, ToBeDeleted int) 
CREATE TABLE #tmp1 (StopNumber int, StopMoveSeq int, ToBeDeleted int) 

SET @lFlags = CONVERT(int, ISNULL(@Flags, 0))

SET @fgt_sequence = -5
IF ISNULL(@fgt_sequence_parm,'') <> ''
	SET @fgt_sequence = CONVERT(int, @fgt_sequence_parm)

SET @stop_nbr = -5	
IF ISNULL(@stop_nbr_parm, '') <> '' AND ISNUMERIC(@stop_nbr_parm) = 1
	SET @stop_nbr = CONVERT(int, @stop_nbr_parm)

IF ISNULL(@stop_nbr_parm, '') = ''
	SET @stop_nbr_parm = CONVERT(varchar(12), @stop_nbr)

IF (@Flags & 1) <> 0
	BEGIN
		SELECT @lghNum = lgh_number, @lStopSeq = stp_mfh_sequence 
		FROM stops (NOLOCK)
		WHERE stp_number = @stop_nbr_parm
		
		--Get all stops for the leg header
		INSERT INTO #tmp0
			EXEC dbo.tmail_load_assign5_sp '', '', @lghNum, '', '', '', '', '', 'StopNumber, StopMoveSeq, ToBeDeleted'

		--Get duplicate stops
		INSERT INTO #tmp1
			EXEC dbo.tmail_load_assign5_sp '', '', @lghNum, '2097152', '', '', '', @SeparateFieldsOn, 'StopNumber, StopMoveSeq, ToBeDeleted'

		--Update duplicate stops ToBeDeleted to 1
		UPDATE #tmp0
			SET ToBeDeleted = 1 
			FROM #tmp1
			RIGHT JOIN #tmp0 ON #tmp1.StopMoveSeq = #tmp0.StopMoveSeq
			WHERE NOT EXISTS (SELECT NULL 
								FROM #tmp0 
								WHERE #tmp1.StopMoveSeq = #tmp0.StopMoveSeq)

		--add all duplicate stops after the stop passed in to the list of stops to retrieve
		SELECT @lStopSeq = MIN(StopMoveSeq) 
		FROM #tmp0 
		WHERE StopMoveSeq > @lStopSeq
		WHILE ISNULL(@lStopSeq, 0) > 0 
			BEGIN
				SELECT @lStopNumber = StopNumber, @ToBeDeleted = ToBeDeleted FROM #tmp0 WHERE StopMoveSeq = @lStopSeq
			    if @ToBeDeleted = 1
					SET @stop_nbr_parm = @stop_nbr_parm +', ' + CONVERT(varchar(12), @lStopNumber)
				else
					break
	
				SELECT @lStopSeq = MIN(StopMoveSeq) FROM #tmp0 WHERE StopMoveSeq > @lStopSeq
			END
	END

IF @fgt_sequence = -5 -- get ALL commodities
  BEGIN
	SET @sExec = 'SELECT freightdetail.stp_number, 
					freightdetail.cmd_code, 
					fgt_description, 
					fgt_weight, 
					fgt_weightunit, 
					fgt_count, 
					fgt_countunit, 
					fgt_volume, 
					fgt_volumeunit, 
					fgt_refnum, 
					fgt_reftype, 
					fgt_sequence, 
					fgt_number, 
					fgt_length, 
					fgt_lengthunit, 
					fgt_height, 
					fgt_heightunit, 
					fgt_width, 
					fgt_widthunit, 
					fgt_quantity, 
					fgt_unit as fgt_quantityunit ,
					ISNULL(fgt_stackable, '''') fgt_stackable, 
					fgt_sequence DetailFreightSequence,
					freightdetail.stp_Number DetailStopNumber,
					fgt_volume2,
					fgt_volume2unit,
					fgt_ordered_volume,
					fgt_pincode,
					fgt_supplier,
					fgt_accountof,
					fgt_parentcmd_fgt_number
			FROM freightdetail
				INNER JOIN stops ON stops.stp_number = freightdetail.stp_number
			WHERE freightdetail.stp_number in (' + @stop_nbr_parm + ')'
			
			--59222 DWG Flag 2 - Ignore Zero Volume records
			IF (@Flags & 2) <> 0
				SET @sExec = @sExec + ' AND ISNULL(fgt_volume, 0) <> 0'

			SET @sExec = @sExec + ' ORDER BY fgt_sequence, stp_mfh_sequence'
			--59222 End

	EXEC (@sExec)

  END

ELSE -- get ONE freight detail by sequence
 SELECT 	stp_number, 
			cmd_code, 
			fgt_description, 
			fgt_weight, 
			fgt_weightunit, 
			fgt_count, 
			fgt_countunit, 
			fgt_volume, 
			fgt_volumeunit, 
			fgt_refnum, 
			fgt_reftype, 
			fgt_sequence, 
			fgt_number, 
			fgt_length, 
			fgt_lengthunit, 
			fgt_height, 
			fgt_heightunit, 
			fgt_width, 
			fgt_widthunit, 
			fgt_quantity, 
			fgt_unit as fgt_quantityunit,
			ISNULL(fgt_stackable, '') fgt_stackable,
			fgt_sequence DetailFreightSequence,
			stp_Number DetailStopNumber,
			fgt_volume2,
			fgt_volume2unit,
			fgt_ordered_volume,
			fgt_pincode,
			fgt_supplier,
			fgt_accountof,
			fgt_parentcmd_fgt_number
  FROM freightdetail (NOLOCK)
  WHERE stp_number = @stop_nbr
	AND fgt_sequence = @fgt_sequence

GO
GRANT EXECUTE ON  [dbo].[tmail_commodity4] TO [public]
GO
