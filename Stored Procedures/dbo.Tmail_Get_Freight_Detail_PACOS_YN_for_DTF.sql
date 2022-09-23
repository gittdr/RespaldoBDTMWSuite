SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[Tmail_Get_Freight_Detail_PACOS_YN_for_DTF] (@stp_number int)

AS

/*
 * 
 * NAME:Tmail_Get_Freight_Detail_PACOS_YN_for_DTF
 * dbo.
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *  Pulls all freightdetail sequence info for @stp_number.  Also has a flag
 *    that indicates if this is the last freight on the stop.
 *
 * RETURNS:
 *  none
 *
 * RESULT SETS: 
 *  none
 *
 * PARAMETERS:
 * 001 - @stp_number, int, input;
 *       Stop Number
 * 
 * REVISION HISTORY:
 * 08/13/2007.01 - PTS37692 - Michalynn Kelly- Created one standard proc with the most requested customizations
 * 03/12/2012.01 - PTSnnnnn - MIZ - Brought to standards and checked into source control.
 * 
 **/

DECLARE @v_MaxSeq int

SET NOCOUNT ON

SET @v_MaxSeq = 0

SELECT @v_MaxSeq = MAX(fgt_sequence) 
FROM freightdetail 
WHERE stp_number = @stp_number

SELECT CASE WHEN fgt_sequence = @v_MaxSeq THEN 'N'
			ELSE 'Y'
	   END,
	   fgt_sequence,
	   @v_MaxSeq maxseq,
	   CASE WHEN fgt_sequence = @v_MaxSeq THEN 1
			ELSE 0
	   END
FROM freightdetail
WHERE stp_number = @stp_number
ORDER BY fgt_sequence


GO
GRANT EXECUTE ON  [dbo].[Tmail_Get_Freight_Detail_PACOS_YN_for_DTF] TO [public]
GO
