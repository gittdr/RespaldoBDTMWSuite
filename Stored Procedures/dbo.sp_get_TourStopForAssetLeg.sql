SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_get_TourStopForAssetLeg]
( @asgn_type                  VARCHAR(6)
, @asgn_id                    VARCHAR(13)
, @lgh_number                 INT
, @ShowCompanyStopOffSettings CHAR(1)
, @StopOffPayEvents           VARCHAR(1000)
, @IgnoreDuplicateStop        CHAR(1)
, @pyd_atd_id                 INT OUTPUT
, @tourstops                  INT OUTPUT
) AS
/**
 *
 * NAME:
 * dbo.sp_get_TourStopForAssetLeg
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for computing number of tour stops for a given leg and asset
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @asgn_type                   VARCHAR(6)
 * 002 @asgn_id                     VARCHAR(13)
 * 003 @lgh_number                  INT
 * 004 @ShowCompanyStopOffSettings  CHAR(1)
 * 005 @StopOffPayEvents            VARCHAR(1000)
 * 006 @IgnoreDuplicateStop         CHAR(1)
 * 007 @pyd_atd_id                  INT OUTPUT
 * 008 @tourstops                   INT OUTPUT
 *
 * REVISION HISTORY:
 * PTS 62995 SPN 10/01/12 - Initial Version Created
 * PTS 65914 SPN 12/07/12 - Moved original code into a new function fn_get_TourStopForAssetLeg
 * PTS 66382 SPN 01/03/13 - Added new Parm @IgnoreDuplicateStop
 *
 **/

SET NOCOUNT ON

BEGIN

   SELECT @pyd_atd_id = pyd_atd_id
        , @tourstops  = tourstops
     FROM dbo.fn_get_TourStopForAssetLeg(@asgn_type,@asgn_id,@lgh_number,@ShowCompanyStopOffSettings,@StopOffPayEvents,@IgnoreDuplicateStop)

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_get_TourStopForAssetLeg] TO [public]
GO
