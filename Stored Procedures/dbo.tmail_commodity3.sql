SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 * 
 * NAME:
 * dbo.tmail_commodity3
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
 *		 Flags
 * 004 - @SeparateFieldsOn, varchar(1000);
 *		 Field list to separate adjacent stops
 *
 * REVISION HISTORY:
 * 03/31/04      - Created:	- Matthew Zerefos  
 * 08/18/04      - Fixed:   - jgf - so it can do ALL or ONE
 * 02/04/06      - 30449    - DWG - Changed to Accept list of Stop Numbers.
 *                                  Added return of Freight Sequence and stop number
 * 01/11/07      - 38187    - DWG - Added Flags and SeparateOnFields parameters
 *
 **/

/* tmail_commodity2 **************************************************************
** 
*********************************************************************************/

CREATE PROCEDURE [dbo].[tmail_commodity3] @stop_nbr_parm varchar(200),
                                      @fgt_sequence_parm varchar(20),
									  @Flags varchar(12),
									  @SeparateFieldsOn varchar(1000)

AS

EXEC tmail_commodity4 @stop_nbr_parm,
                      @fgt_sequence_parm,
					  @Flags,
					  @SeparateFieldsOn
GO
GRANT EXECUTE ON  [dbo].[tmail_commodity3] TO [public]
GO
