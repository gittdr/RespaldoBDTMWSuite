SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[update_move_light] (@mov int)
AS 
/**************************************************************************************************************************************************************************
 **
 ** Parameters:
 **   Input:
 **     @mov              INTEGER
 **       - mov_number to process
 **
 ** Revison History:
 **   INT-106022 - RJE 03/31/2017 - Created new procedure update_move_processing_sp to consolidate update_move and update_move_light 
 **                                 processing to make it simpler to keep them in sync, update_move passes 'Y' in second parameter
 **                                 which causes update_assetassignment to run.
 **************************************************************************************************************************************************************************/

EXECUTE update_move_processing_sp @mov, 'N'

RETURN 

GO
GRANT EXECUTE ON  [dbo].[update_move_light] TO [public]
GO
