SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_IsAssetLegTourAware]
( @asgn_type   VARCHAR(6)
, @asgn_id     VARCHAR(13)
, @lgh_number  INT
)
RETURNS CHAR
AS
/**
 *
 * NAME:
 * dbo.fn_IsAssetLegTourAware
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * Function to tell if a given leg and asset is TourAware
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @asgn_type    VARCHAR(6)
 * 002 @asgn_id      VARCHAR(13)
 * 003 @lgh_number   INT
 *
 * REVISION HISTORY:
 * PTS 65914 SPN 12/05/12 - Initial Version Created
 *
 **/

BEGIN

   DECLARE @TourAware   CHAR(1)

   SELECT @TourAware = 'N'

   IF EXISTS (SELECT 1
                FROM assetassignment_tour_hdr h
                JOIN assetassignment_tour_dtl d ON h.ath_id = d.ath_id
               WHERE h.asgn_type  = @asgn_type
                 AND h.asgn_id    = @asgn_id
                 AND d.lgh_number = @lgh_number
             )
      SELECT @TourAware = 'Y'

   RETURN @TourAware

END
GO
GRANT EXECUTE ON  [dbo].[fn_IsAssetLegTourAware] TO [public]
GO
