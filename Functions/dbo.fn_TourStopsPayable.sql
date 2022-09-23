SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_TourStopsPayable]
( @asgn_type                  VARCHAR(6)
, @asgn_id                    VARCHAR(13)
, @lgh_number                 INT
, @ShowCompanyStopOffSettings CHAR(1)
, @StopOffPayEvents           VARCHAR(1000)
, @IgnoreDuplicateStop        CHAR(1)
)
RETURNS INT
AS
/**
 *
 * NAME:
 * dbo.fn_TourStopsPayable
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function to return Payable Stop Count for a given leg and asset
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
 *
 * REVISION HISTORY:
 * PTS 65914 SPN 12/05/12 - Initial Version Created
 * PTS 66382 SPN 01/03/13 - Added new Parm @IgnoreDuplicateStop
 *
 **/

BEGIN

   DECLARE @pyd_atd_id  INT
   DECLARE @tourstops   INT

   SELECT @pyd_atd_id = pyd_atd_id
        , @tourstops  = tourstops
     FROM dbo.fn_get_TourStopForAssetLeg(@asgn_type,@asgn_id,@lgh_number,@ShowCompanyStopOffSettings,@StopOffPayEvents,@IgnoreDuplicateStop)

   RETURN @tourstops

END
GO
GRANT EXECUTE ON  [dbo].[fn_TourStopsPayable] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fn_TourStopsPayable] TO [public]
GO
